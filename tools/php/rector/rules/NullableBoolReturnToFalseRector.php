<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\ConstFetch;
use PhpParser\Node\Identifier;
use PhpParser\Node\Name;
use PhpParser\Node\NullableType;
use PhpParser\Node\Stmt\ClassMethod;
use PhpParser\Node\Stmt\Expression;
use PhpParser\Node\Stmt\Function_;
use PhpParser\Node\Stmt\Return_;
use PhpParser\NodeFinder;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Removes nullable from ?bool return types and replaces `return null` with `return false`.
 */
final class NullableBoolReturnToFalseRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace nullable bool return type with bool and replace `return null` with `return false`',
            [
                new CodeSample(
                    <<<'PHP'
function foo(): ?bool
{
    if ($this->var === null) {
        return null;
    }

    return true;
}
PHP,
                    <<<'PHP'
function foo(): bool
{
    if ($this->var === null) {
        return false;
    }

    return true;
}
PHP
                ),
            ]
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [ClassMethod::class, Function_::class];
    }

    /**
     * @param ClassMethod|Function_ $node
     */
    public function refactor(Node $node): ?Node
    {
        if (!$this->hasNullableBoolReturnType($node)) {
            return null;
        }

        $nullReturns = $this->findDirectNullReturns($node);

        // Change ?bool → bool
        /** @var NullableType $returnType */
        $returnType = $node->returnType;
        $node->returnType = $returnType->type;

        // Replace each `return null` with `return false`
        foreach ($nullReturns as $return) {
            $return->expr = $this->nodeFactory->createFalse();
        }

        return $node;
    }

    /**
     * @param ClassMethod|Function_ $node
     */
    private function hasNullableBoolReturnType(Node $node): bool
    {
        if (!$node->returnType instanceof NullableType) {
            return false;
        }

        $inner = $node->returnType->type;

        return $inner instanceof Identifier && $inner->toLowerString() === 'bool';
    }

    /**
     * Finds all `return null` statements that belong directly to this function,
     * not to any nested closure or anonymous function inside it.
     *
     * @param ClassMethod|Function_ $node
     * @return Return_[]
     */
    private function findDirectNullReturns(Node $node): array
    {
        $nullReturns = [];

        $this->traverseStmts($node->stmts ?? [], $nullReturns);

        return $nullReturns;
    }

    /**
     * @param Node\Stmt[] $stmts
     * @param Return_[]   $nullReturns
     */
    private function traverseStmts(array $stmts, array &$nullReturns): void
    {
        foreach ($stmts as $stmt) {
            // Don't descend into nested functions/closures/arrow functions — they are
            // separate scopes with their own return types.
            if ($stmt instanceof Function_ || $stmt instanceof ClassMethod) {
                continue;
            }

            if ($stmt instanceof Return_) {
                if ($this->isNullConstFetch($stmt->expr)) {
                    $nullReturns[] = $stmt;
                }

                continue;
            }

            // Recurse into any compound statement that may contain returns.
            foreach ($stmt->getSubNodeNames() as $subNodeName) {
                $sub = $stmt->$subNodeName;

                if (is_array($sub)) {
                    $this->traverseStmts($sub, $nullReturns);
                } elseif ($sub instanceof Node\Stmt) {
                    $this->traverseStmts([$sub], $nullReturns);
                }
            }
        }
    }

    private function isNullConstFetch(?Node $node): bool
    {
        return $node instanceof ConstFetch
            && strtolower($node->name->toString()) === 'null';
    }
}
