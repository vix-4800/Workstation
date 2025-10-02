<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\Assign;
use PhpParser\Node\Expr\BinaryOp;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\BinaryOp\NotIdentical;
use PhpParser\Node\Expr\BinaryOp\Equal;
use PhpParser\Node\Expr\BinaryOp\NotEqual;
use PhpParser\Node\Stmt\Expression;
use PhpParser\Node\Stmt\If_;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Extract assignment from if condition to separate statement for better readability
 */
final class ExtractAssignmentFromIfConditionRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Extract assignment from if condition to separate statement',
            [
                new CodeSample(
                    'if (($model = Model::findOne($id)) !== null) {
    return $model;
}',
                    '$model = Model::findOne($id);
if ($model !== null) {
    return $model;
}'
                ),
                new CodeSample(
                    'if (($user = $this->getUser()) != false) {
    echo $user->name;
}',
                    '$user = $this->getUser();
if ($user != false) {
    echo $user->name;
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
        return [If_::class];
    }

    /**
     * @param If_ $node
     */
    public function refactor(Node $node): ?array
    {
        if (!$node instanceof If_) {
            return null;
        }

        // Проверяем, что условие - это бинарная операция сравнения
        if (!$node->cond instanceof BinaryOp) {
            return null;
        }

        $binaryOp = $node->cond;

        // Поддерживаем различные типы сравнений
        if (!$this->isSupportedComparison($binaryOp)) {
            return null;
        }

        $assignment = null;
        $comparisonValue = null;
        $isLeftAssignment = false;

        // Проверяем, есть ли присвоение в левой части
        if ($binaryOp->left instanceof Assign) {
            $assignment = $binaryOp->left;
            $comparisonValue = $binaryOp->right;
            $isLeftAssignment = true;
        }
        // Проверяем, есть ли присвоение в правой части
        elseif ($binaryOp->right instanceof Assign) {
            $assignment = $binaryOp->right;
            $comparisonValue = $binaryOp->left;
            $isLeftAssignment = false;
        }

        if ($assignment === null) {
            return null;
        }

        // Создаем новое условие без присвоения
        $newCondition = $isLeftAssignment
            ? $this->createBinaryOp($binaryOp, $assignment->var, $comparisonValue)
            : $this->createBinaryOp($binaryOp, $comparisonValue, $assignment->var);

        // Создаем новый if с обновленным условием
        $newIf = clone $node;
        $newIf->cond = $newCondition;

        // Возвращаем массив: сначала присвоение, потом if
        return [
            new Expression($assignment),
            $newIf
        ];
    }

    private function isSupportedComparison(BinaryOp $binaryOp): bool
    {
        return $binaryOp instanceof Identical ||
               $binaryOp instanceof NotIdentical ||
               $binaryOp instanceof Equal ||
               $binaryOp instanceof NotEqual;
    }

    private function createBinaryOp(BinaryOp $originalOp, Node $left, Node $right): BinaryOp
    {
        if ($originalOp instanceof Identical) {
            return new Identical($left, $right);
        }
        if ($originalOp instanceof NotIdentical) {
            return new NotIdentical($left, $right);
        }
        if ($originalOp instanceof Equal) {
            return new Equal($left, $right);
        }
        if ($originalOp instanceof NotEqual) {
            return new NotEqual($left, $right);
        }

        // Fallback, хотя это не должно происходить
        return new NotIdentical($left, $right);
    }
}
