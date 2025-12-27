<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\BinaryOp\Equal;
use PhpParser\Node\Expr\BinaryOp\Greater;
use PhpParser\Node\Expr\BinaryOp\GreaterOrEqual;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\BinaryOp\NotEqual;
use PhpParser\Node\Expr\BinaryOp\NotIdentical;
use PhpParser\Node\Expr\BinaryOp\Smaller;
use PhpParser\Node\Expr\BinaryOp\SmallerOrEqual;
use PhpParser\Node\Expr\BooleanNot;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Identifier;
use PhpParser\Node\Scalar\LNumber;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Replaces Model::find()->where()->count() > 0 with Model::find()->where()->exists()
 * Also handles:
 * - count() >= 1 -> exists()
 * - count() != 0 -> exists()
 * - count() !== 0 -> exists()
 * - count() == 0 -> !exists()
 * - count() === 0 -> !exists()
 * - count() < 1 -> !exists()
 * - count() <= 0 -> !exists()
 * And their mirrored variants (0 < count(), etc.)
 */
final class Yii2UseExistsInsteadOfCountRector extends AbstractRector
{
    /** Returns rule definition for documentation */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace Model::find()->where()->count() > 0 with Model::find()->where()->exists()',
            [
                new CodeSample(
                    'if (Model::find()->where([\'id\' => $id])->count() > 0) {
    return true;
}',
                    'if (Model::find()->where([\'id\' => $id])->exists()) {
    return true;
}'
                ),
                new CodeSample(
                    'if (Model::find()->where([\'id\' => $id])->count() === 0) {
    return false;
}',
                    'if (!Model::find()->where([\'id\' => $id])->exists()) {
    return false;
}'
                ),
            ]
        );
    }

    /**
     * Get node types this rector processes
     *
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [
            Greater::class,
            GreaterOrEqual::class,
            Smaller::class,
            SmallerOrEqual::class,
            Equal::class,
            NotEqual::class,
            Identical::class,
            NotIdentical::class,
        ];
    }

    /**
     * Refactor the node to replace count() comparisons with exists()
     *
     * @param Equal|Greater|GreaterOrEqual|Identical|NotEqual|NotIdentical|Smaller|SmallerOrEqual $node Comparison node
     */
    public function refactor(Node $node): ?Node
    {
        $methodCall = null;
        $numberValue = null;

        if ($this->isMethodCallCount($node->left) && $this->isNumber($node->right)) {
            $methodCall = $node->left;
            $numberValue = $node->right;
        } elseif ($this->isNumber($node->left) && $this->isMethodCallCount($node->right)) {
            $methodCall = $node->right;
            $numberValue = $node->left;
        }

        if ($methodCall === null || $numberValue === null) {
            return null;
        }

        $number = $numberValue->value;
        $shouldNegate = $this->shouldNegateExists($node, $number);

        if ($shouldNegate === null) {
            return null;
        }

        $existsCall = new MethodCall(
            $methodCall->var,
            new Identifier('exists')
        );

        return $shouldNegate ? new BooleanNot($existsCall) : $existsCall;
    }

    /**
     * Check if node is a method call to count()
     *
     * @param Node $node Node to check
     */
    private function isMethodCallCount(Node $node): bool
    {
        if (!$node instanceof MethodCall) {
            return false;
        }

        if (!$node->name instanceof Identifier) {
            return false;
        }

        return $node->name->toString() === 'count';
    }

    /**
     * Check if node is a number literal
     *
     * @param Node $node Node to check
     */
    private function isNumber(Node $node): bool
    {
        return $node instanceof LNumber;
    }

    /**
     * Determine if exists() should be negated
     *
     * @param Equal|Greater|GreaterOrEqual|Identical|NotEqual|NotIdentical|Smaller|SmallerOrEqual $node   Comparison node
     * @param int                                                                                 $number Number compared
     *
     * @return bool|null True if should negate, false if not, null if pattern doesn't match
     */
    private function shouldNegateExists(Node $node, int $number): ?bool
    {
        return match (true) {
            $node instanceof Greater && $number === 0 => false,
            $node instanceof GreaterOrEqual && $number === 1 => false,
            $node instanceof Smaller && $number === 1 => true,
            $node instanceof SmallerOrEqual && $number === 0 => true,
            ($node instanceof NotEqual || $node instanceof NotIdentical) && $number === 0 => false,
            ($node instanceof Equal || $node instanceof Identical) && $number === 0 => true,
            default => null,
        };
    }
}
