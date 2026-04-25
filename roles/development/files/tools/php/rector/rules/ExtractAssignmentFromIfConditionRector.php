<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr\Assign;
use PhpParser\Node\Expr\BinaryOp;
use PhpParser\Node\Expr\BinaryOp\Equal;
use PhpParser\Node\Expr\BinaryOp\Identical;
use PhpParser\Node\Expr\BinaryOp\NotEqual;
use PhpParser\Node\Expr\BinaryOp\NotIdentical;
use PhpParser\Node\Expr\BooleanNot;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Name;
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
                new CodeSample(
                    'if (!is_null(($model = WebPushSubscription::findOne($id)))) {
    return $model;
}',
                    '$model = WebPushSubscription::findOne($id);
if (!is_null($model)) {
    return $model;
}'
                ),
                new CodeSample(
                    'if (is_array(($items = $this->getItems()))) {
    return $items;
}',
                    '$items = $this->getItems();
if (is_array($items)) {
    return $items;
}'
                ),
            ]
        );
    }

    /**
     * @return list<class-string<Node>>
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

        $condition = $node->cond;

        if ($condition instanceof BinaryOp && $this->isSupportedComparison($condition)) {
            return $this->handleBinaryOpCondition($node, $condition);
        }

        if ($condition instanceof BooleanNot) {
            return $this->handleBooleanNotCondition($node, $condition);
        }

        if ($condition instanceof FuncCall) {
            return $this->handleFuncCallCondition($node, $condition);
        }

        return null;
    }

    private function handleBinaryOpCondition(If_ $node, BinaryOp $binaryOp): ?array
    {
        $assignment = null;
        $comparisonValue = null;
        $isLeftAssignment = false;

        if ($binaryOp->left instanceof Assign) {
            $assignment = $binaryOp->left;
            $comparisonValue = $binaryOp->right;
            $isLeftAssignment = true;
        } elseif ($binaryOp->right instanceof Assign) {
            $assignment = $binaryOp->right;
            $comparisonValue = $binaryOp->left;
            $isLeftAssignment = false;
        }

        if ($assignment === null) {
            return null;
        }

        $newCondition = $isLeftAssignment
            ? $this->createBinaryOp($binaryOp, $assignment->var, $comparisonValue)
            : $this->createBinaryOp($binaryOp, $comparisonValue, $assignment->var);

        $newIf = clone $node;
        $newIf->cond = $newCondition;

        return [
            new Expression($assignment),
            $newIf,
        ];
    }

    private function handleBooleanNotCondition(If_ $node, BooleanNot $booleanNot): ?array
    {
        if (!$booleanNot->expr instanceof FuncCall) {
            return null;
        }

        $funcCall = $booleanNot->expr;

        $assignment = $this->extractAssignmentFromFuncCall($funcCall);

        if ($assignment === null) {
            return null;
        }

        $newFuncCall = $this->createFuncCallWithoutAssignment($funcCall, $assignment->var);
        $newCondition = new BooleanNot($newFuncCall);

        $newIf = clone $node;
        $newIf->cond = $newCondition;

        return [
            new Expression($assignment),
            $newIf,
        ];
    }

    private function handleFuncCallCondition(If_ $node, FuncCall $funcCall): ?array
    {
        $assignment = $this->extractAssignmentFromFuncCall($funcCall);

        if ($assignment === null) {
            return null;
        }

        $newCondition = $this->createFuncCallWithoutAssignment($funcCall, $assignment->var);

        $newIf = clone $node;
        $newIf->cond = $newCondition;

        return [
            new Expression($assignment),
            $newIf,
        ];
    }

    private function extractAssignmentFromFuncCall(FuncCall $funcCall): ?Assign
    {
        if (!$this->isSupportedFunction($funcCall)) {
            return null;
        }

        foreach ($funcCall->args as $arg) {
            if ($arg->value instanceof Assign) {
                return $arg->value;
            }
        }

        return null;
    }

    private function isSupportedFunction(FuncCall $funcCall): bool
    {
        if (!$funcCall->name instanceof Name) {
            return false;
        }

        $functionName = $funcCall->name->toString();

        return in_array($functionName, [
            'is_null',
            'is_array',
            'is_object',
            'is_string',
            'is_numeric',
            'is_bool',
            'is_resource',
            'is_int',
            'is_float',
            'is_scalar',
            'is_callable',
            'is_countable',
            'is_iterable',
        ], true);
    }

    private function createFuncCallWithoutAssignment(FuncCall $originalFuncCall, Node $replacementVar): FuncCall
    {
        $newArgs = [];

        foreach ($originalFuncCall->args as $arg) {
            $newArgs[] = $arg->value instanceof Assign ? new Arg($replacementVar) : $arg;
        }

        return new FuncCall($originalFuncCall->name, $newArgs);
    }

    private function isSupportedComparison(BinaryOp $binaryOp): bool
    {
        return $binaryOp instanceof Identical
            || $binaryOp instanceof NotIdentical
            || $binaryOp instanceof Equal
            || $binaryOp instanceof NotEqual;
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

        return new NotIdentical($left, $right);
    }
}
