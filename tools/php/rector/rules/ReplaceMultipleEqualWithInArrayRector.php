<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node\Expr\Variable;
use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ArrayItem;
use PhpParser\Node\Expr\BinaryOp\BooleanOr;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Replaces multiple === comparisons with logical OR to in_array() calls
 * Example: $var === 'a' || $var === 'b' || $var === 'c'
 * becomes: in_array($var, ['a', 'b', 'c'])
 */
final class ReplaceMultipleEqualWithInArrayRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace multiple === comparisons with logical OR to in_array() calls',
            [
                new CodeSample(
                    'if ($var === \'a\' || $var === \'b\' || $var === \'c\') {
    return true;
}',
                    'if (in_array($var, [\'a\', \'b\', \'c\'])) {
    return true;
}'
                ),
                new CodeSample(
                    'if ($status === \'active\' || $status === \'pending\' || $status === \'approved\') {
    // do something
}',
                    'if (in_array($status, [\'active\', \'pending\', \'approved\'])) {
    // do something
}'
                ),
            ]
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [BooleanOr::class];
    }

    /**
     * @param BooleanOr $node
     */
    public function refactor(Node $node): ?Node
    {
        if (!$node instanceof BooleanOr) {
            return null;
        }

        $comparisons = $this->collectIdenticalComparisons($node);

        if (count($comparisons) < 2) {
            return null;
        }

        $firstVariable = null;
        $values = [];

        foreach ($comparisons as $comparison) {
            if (!$comparison instanceof Identical) {
                return null;
            }

            $variable = null;
            $value = null;

            if ($this->areNodesEqual($comparison->left, $firstVariable ?? $comparison->left)) {
                $variable = $comparison->left;
                $value = $comparison->right;
            } elseif ($this->areNodesEqual($comparison->right, $firstVariable ?? $comparison->right)) {
                $variable = $comparison->right;
                $value = $comparison->left;
            } else {
                return null;
            }

            if ($firstVariable === null) {
                $firstVariable = $variable;
            }

            $values[] = $value;
        }

        $arrayItems = [];
        foreach ($values as $value) {
            $arrayItems[] = new ArrayItem($value);
        }
        $valuesArray = new Array_($arrayItems);

        return new FuncCall(
            new Name('in_array'),
            [
                new Arg($firstVariable),
                new Arg($valuesArray)
            ]
        );
    }

    /**
     * Рекурсивно собирает все Identical сравнения из цепочки BooleanOr
     *
     * @return Identical[]
     */
    private function collectIdenticalComparisons(Node $node): array
    {
        if ($node instanceof Identical) {
            return [$node];
        }

        if ($node instanceof BooleanOr) {
            return array_merge(
                $this->collectIdenticalComparisons($node->left),
                $this->collectIdenticalComparisons($node->right)
            );
        }

        return [];
    }

    /**
     * Простое сравнение узлов - для простых переменных должно работать
     */
    private function areNodesEqual(?Node $node1, ?Node $node2): bool
    {
        if ($node1 === null && $node2 === null) {
            return true;
        }

        if ($node1 === null || $node2 === null) {
            return false;
        }

        if ($node1::class !== $node2::class) {
            return false;
        }

        if ($node1 instanceof Variable && $node2 instanceof Variable) {
            return $node1->name === $node2->name;
        }

        return false;
    }
}
