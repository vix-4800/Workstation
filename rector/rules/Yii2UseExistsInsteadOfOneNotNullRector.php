<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node\Expr\BooleanNot;
use PhpParser\Node;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\BinaryOp\NotIdentical;
use PhpParser\Node\Expr\ConstFetch;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Identifier;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Replaces Model::find()->where()->one() !== null with Model::find()->where()->exists()
 * Also handles Model::find()->where()->one() === null with !Model::find()->where()->exists()
 */
final class Yii2UseExistsInsteadOfOneNotNullRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace Model::find()->where()->one() !== null with Model::find()->where()->exists()',
            [
                new CodeSample(
                    'if (Model::find()->where([\'id\' => $id])->one() !== null) {
    return true;
}',
                    'if (Model::find()->where([\'id\' => $id])->exists()) {
    return true;
}'
                ),
                new CodeSample(
                    'if (Model::find()->where([\'id\' => $id])->one() === null) {
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
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [Identical::class, NotIdentical::class];
    }

    /**
     * @param Identical|NotIdentical $node
     */
    public function refactor(Node $node): ?Node
    {
        if (!$node instanceof Identical && !$node instanceof NotIdentical) {
            return null;
        }

        $methodCall = null;
        $nullValue = null;

        if ($this->isMethodCallOne($node->left) && $this->isNull($node->right)) {
            $methodCall = $node->left;
            $nullValue = $node->right;
        } elseif ($this->isNull($node->left) && $this->isMethodCallOne($node->right)) {
            $methodCall = $node->right;
            $nullValue = $node->left;
        }

        if ($methodCall === null || $nullValue === null) {
            return null;
        }

        $existsCall = new MethodCall(
            $methodCall->var,
            new Identifier('exists')
        );

        if ($node instanceof NotIdentical) {
            return $existsCall;
        }

        return new BooleanNot($existsCall);
    }

    private function isMethodCallOne(Node $node): bool
    {
        if (!$node instanceof MethodCall) {
            return false;
        }

        if (!$node->name instanceof Identifier) {
            return false;
        }

        return $node->name->toString() === 'one';
    }

    private function isNull(Node $node): bool
    {
        if (!$node instanceof ConstFetch) {
            return false;
        }

        if (!$node->name instanceof Name) {
            return false;
        }

        return strtolower($node->name->toString()) === 'null';
    }
}
