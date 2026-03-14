<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ArrayItem;
use PhpParser\Node\Expr\BinaryOp\BooleanOr;
use PhpParser\Node\Expr\BinaryOp\Equal;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\ConstFetch;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Expr\Variable;
use PhpParser\Node\Name;
use PhpParser\Node\Scalar\LNumber;
use PhpParser\Node\Scalar\String_;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Replaces multiple === or == comparisons with logical OR to in_array() calls
 * Example: $var === 'a' || $var === 'b' || $var === 'c'
 * becomes: in_array($var, ['a', 'b', 'c'], true)
 *
 * Example: $var == 'a' || $var == 'b'
 * becomes: in_array($var, ['a', 'b'])
 */
final class ReplaceMultipleEqualWithInArrayRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace multiple === or == comparisons with logical OR to in_array() calls',
            [
                new CodeSample(
                    'if ($var === \'a\' || $var === \'b\' || $var === \'c\') {
    return true;
}',
                    'if (in_array($var, [\'a\', \'b\', \'c\'], true)) {
    return true;
}'
                ),
                new CodeSample(
                    'if ($status == \'active\' || $status == \'pending\') {
    // do something
}',
                    'if (in_array($status, [\'active\', \'pending\'])) {
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

        $comparisons = $this->collectComparisons($node);

        if (count($comparisons) < 2) {
            return null;
        }

        if (count($comparisons) === 2 && $this->isSimpleNullOrEmptyCheck($comparisons)) {
            return null;
        }

        $isStrict = null;
        $isMixed = false;

        foreach ($comparisons as $comparison) {
            if ($comparison instanceof Identical) {
                if ($isStrict === false) {
                    $isMixed = true;
                }

                $isStrict = true;
            } elseif ($comparison instanceof Equal) {
                if ($isStrict === true) {
                    $isMixed = true;
                }

                $isStrict = false;
            } else {
                return null;
            }
        }

        if ($isMixed) {
            $isStrict = true;
        }

        $firstVariable = null;
        $values = [];

        foreach ($comparisons as $comparison) {
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

        $args = [
            new Arg($firstVariable),
            new Arg($valuesArray)
        ];

        if ($isStrict) {
            $args[] = new Arg(new ConstFetch(new Name('true')));
        }

        return new FuncCall(
            new Name('in_array'),
            $args
        );
    }

    /**
     * Recursively collects all Identical and Equal comparisons from BooleanOr chain
     *
     * @return array<Equal|Identical>
     */
    private function collectComparisons(Node $node): array
    {
        if ($node instanceof Identical || $node instanceof Equal) {
            return [$node];
        }

        if ($node instanceof BooleanOr) {
            return array_merge(
                $this->collectComparisons($node->left),
                $this->collectComparisons($node->right)
            );
        }

        return [];
    }

    /**
     * Simple node comparison - should work for simple variables
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

    /**
     * Checks if the construct is a simple null/empty string check
     * Such constructs usually appear after refactoring empty() and look better in the original form
     * Examples:
     * - $var === null || $var === ''
     * - $var === '' || $var === null
     * - $var === null || $var === 0
     * - $var === false || $var === null
     *
     * @param array<Equal|Identical> $comparisons
     */
    private function isSimpleNullOrEmptyCheck(array $comparisons): bool
    {
        if (count($comparisons) !== 2) {
            return false;
        }

        $values = [];

        foreach ($comparisons as $comparison) {
            if ($comparison->left instanceof Variable) {
                $values[] = $comparison->right;
            } elseif ($comparison->right instanceof Variable) {
                $values[] = $comparison->left;
            } else {
                return false;
            }
        }

        return $this->containsOnlySimpleValues($values);
    }

    /**
     * Checks if the array contains only "simple" values for comparison
     * Simple values: null, empty string, false, true, 0
     *
     * @param array<Node> $values
     */
    private function containsOnlySimpleValues(array $values): bool
    {
        $simpleValueCount = 0;

        foreach ($values as $value) {
            if ($this->isSimpleValue($value)) {
                $simpleValueCount++;
            }
        }

        return $simpleValueCount === count($values);
    }

    /**
     * Checks if the value is "simple" (null, '', false, true, 0)
     */
    private function isSimpleValue(Node $value): bool
    {
        if ($value instanceof ConstFetch && $value->name->toString() === 'null') {
            return true;
        }

        if ($value instanceof ConstFetch && in_array($value->name->toString(), ['true', 'false'], true)) {
            return true;
        }

        if ($value instanceof String_ && $value->value === '') {
            return true;
        }

        return (bool) ($value instanceof LNumber && $value->value === 0);
    }
}
