<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ArrayItem;
use PhpParser\Node\Expr\Assign;
use PhpParser\Node\Expr\Closure;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Expr\Variable;
use PhpParser\Node\Name;
use PhpParser\Node\Scalar\String_;
use PhpParser\Node\Stmt;
use PhpParser\Node\Stmt\ClassMethod;
use PhpParser\Node\Stmt\Expression;
use PhpParser\Node\Stmt\Function_;
use PhpParser\Node\Stmt\Return_;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Collapses consecutive str_replace() calls with the same replacement into one call.
 */
final class CollapseSequentialStrReplaceRector extends AbstractRector
{
    /**
     * Describe the transformation this rule applies.
     */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Collapse consecutive str_replace() calls with the same replacement into a single call with an array search argument',
            [
                new CodeSample(
                    <<<'PHP'
                        $q = str_replace('+', '', $number);
                        $q = str_replace(' ', '', $q);
                        $q = str_replace('(', '', $q);
                        $q = str_replace(')', '', $q);
                        return str_replace('-', '', $q);
                        PHP,
                    <<<'PHP'
                        return str_replace(['+', ' ', '(', ')', '-'], '', $number);
                        PHP
                ),
            ]
        );
    }

    /**
     * @return list<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [ClassMethod::class, Closure::class, Function_::class];
    }

    /**
     * @param ClassMethod|Closure|Function_ $node
     */
    public function refactor(Node $node): ?Node
    {
        if ($node->stmts === null || $node->stmts === []) {
            return null;
        }

        $hasChanged = $this->refactorStatements($node->stmts);

        return $hasChanged ? $node : null;
    }

    /**
     * @param list<Stmt> $statements
     */
    private function refactorStatements(array &$statements): bool
    {
        $hasChanged = false;

        foreach ($statements as $statement) {
            $hasChanged = $this->refactorNestedStatements($statement) || $hasChanged;
        }

        $index = 0;
        $statementsCount = count($statements);

        while ($index < $statementsCount) {
            $statement = $statements[$index];

            if (!$statement instanceof Return_) {
                ++$index;

                continue;
            }

            $match = $this->matchSequentialStrReplace($statements, $index);

            if ($match === null) {
                ++$index;

                continue;
            }

            array_splice($statements, $match['start_index'], $index - $match['start_index'] + 1, [$match['return']]);
            $index = $match['start_index'] + 1;
            $statementsCount = count($statements);
            $hasChanged = true;
        }

        return $hasChanged;
    }

    /**
     * Recurse into nested statement lists and apply the same collapse there.
     */
    private function refactorNestedStatements(Stmt $statement): bool
    {
        $hasChanged = false;

        if (property_exists($statement, 'stmts') && is_array($statement->stmts) && $statement->stmts !== []) {
            $hasChanged = $this->refactorStatements($statement->stmts) || $hasChanged;
        }

        if ($statement instanceof Stmt\TryCatch) {
            foreach ($statement->catches as $catch) {
                if ($catch->stmts === []) {
                    continue;
                }

                $hasChanged = $this->refactorStatements($catch->stmts) || $hasChanged;
            }

            if ($statement->finally !== null && $statement->finally->stmts !== []) {
                $hasChanged = $this->refactorStatements($statement->finally->stmts) || $hasChanged;
            }
        }

        if ($statement instanceof Stmt\Switch_) {
            foreach ($statement->cases as $case) {
                if ($case->stmts === []) {
                    continue;
                }

                $hasChanged = $this->refactorStatements($case->stmts) || $hasChanged;
            }
        }

        return $hasChanged;
    }

    /**
     * @param list<Stmt> $statements
     *
     * @return array{return: Return_, start_index: int}|null
     */
    private function matchSequentialStrReplace(array $statements, int $returnIndex): ?array
    {
        $return = $statements[$returnIndex];

        if (!$return instanceof Return_ || !$return->expr instanceof FuncCall) {
            return null;
        }

        $finalCall = $this->matchStrReplaceCall($return->expr);

        if ($finalCall === null || !$finalCall['subject'] instanceof Variable) {
            return null;
        }

        $variableName = $this->getVariableName($finalCall['subject']);

        if ($variableName === null) {
            return null;
        }

        $searchGroups = [$finalCall['searches']];
        $replacement = $finalCall['replacement'];
        $subject = null;
        $startIndex = $returnIndex;
        $matchedAssignments = 0;

        for ($index = $returnIndex - 1; $index >= 0; --$index) {
            $statement = $statements[$index];

            if (!$statement instanceof Expression || !$statement->expr instanceof Assign) {
                break;
            }

            $call = $this->matchAssignedVariableStrReplace($statement, $variableName, $replacement);

            if ($call === null) {
                break;
            }

            $searchGroups[] = $call['searches'];
            $subject = $call['subject'];
            $startIndex = $index;
            ++$matchedAssignments;

            if (!$call['subject'] instanceof Variable || $this->getVariableName($call['subject']) !== $variableName) {
                break;
            }
        }

        if ($matchedAssignments === 0 || $subject === null) {
            return null;
        }

        return [
            'return' => $this->createCollapsedReturn($this->flattenSearchGroups($searchGroups), $replacement, $subject),
            'start_index' => $startIndex,
        ];
    }

    /**
     * @return array{searches: list<String_>, subject: Expr}|null
     */
    private function matchAssignedVariableStrReplace(Stmt $statement, string $variableName, Expr $replacement): ?array
    {
        if (!$statement instanceof Expression || !$statement->expr instanceof Assign) {
            return null;
        }

        $assign = $statement->expr;

        if (!$assign->var instanceof Variable || $this->getVariableName($assign->var) !== $variableName) {
            return null;
        }

        if (!$assign->expr instanceof FuncCall) {
            return null;
        }

        $call = $this->matchStrReplaceCall($assign->expr);

        if ($call === null || !$this->areNodesEqual($replacement, $call['replacement'])) {
            return null;
        }

        return [
            'searches' => $call['searches'],
            'subject' => $call['subject'],
        ];
    }

    /**
     * @return array{replacement: Expr, searches: list<String_>, subject: Expr}|null
     */
    private function matchStrReplaceCall(FuncCall $funcCall): ?array
    {
        if (!$this->isName($funcCall, 'str_replace') || count($funcCall->args) !== 3) {
            return null;
        }

        $searches = $this->extractSearchStrings($funcCall->args[0]->value);

        if ($searches === []) {
            return null;
        }

        return [
            'replacement' => $funcCall->args[1]->value,
            'searches' => $searches,
            'subject' => $funcCall->args[2]->value,
        ];
    }

    /**
     * @param list<list<String_>> $searchGroups
     *
     * @return list<String_>
     */
    private function flattenSearchGroups(array $searchGroups): array
    {
        $searches = [];

        for ($index = count($searchGroups) - 1; $index >= 0; --$index) {
            foreach ($searchGroups[$index] as $search) {
                $searches[] = $search;
            }
        }

        return $searches;
    }

    /**
     * Build the collapsed return statement.
     *
     * @param list<String_> $searches
     */
    private function createCollapsedReturn(array $searches, Expr $replacement, Expr $subject): Return_
    {
        return new Return_(
            new FuncCall(
                new Name('str_replace'),
                [
                    new Arg($this->createSearchArray($searches)),
                    new Arg($replacement),
                    new Arg($subject),
                ]
            )
        );
    }

    /**
     * @param list<String_> $searches
     */
    private function createSearchArray(array $searches): Array_
    {
        return new Array_(array_map(
            static fn (String_ $search): ArrayItem => new ArrayItem($search),
            $searches
        ));
    }

    /**
     * @return list<String_>
     */
    private function extractSearchStrings(Expr $search): array
    {
        if ($search instanceof String_) {
            return [new String_($search->value)];
        }

        if (!$search instanceof Array_) {
            return [];
        }

        $searches = [];

        foreach ($search->items as $item) {
            if (!$item instanceof ArrayItem || !$item->value instanceof String_) {
                return [];
            }

            $searches[] = new String_($item->value->value);
        }

        return $searches;
    }

    /**
     * Resolve a plain variable name and skip dynamic variables.
     */
    private function getVariableName(Variable $variable): ?string
    {
        return is_string($variable->name) ? $variable->name : null;
    }
}
