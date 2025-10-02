<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Expr\StaticCall;
use PhpParser\Node\Identifier;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * This Rector rule transforms verbose update chains like:
 * Model::find()->where([...])->update([...])
 * into a direct call to:
 * Model::updateAll([...], [...])
 *
 * It ensures both update data and condition are preserved.
 */
final class Yii2UpdateAllShortcutRector extends AbstractRector
{
    /**
     * Provides documentation and example code for the rule.
     *
     * @return RuleDefinition
     */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replaces Model::find()->where([...])->update([...]) with Model::updateAll([...], [...])',
            []
        );
    }

    /**
     * Specifies the node types this Rector rule should process.
     *
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [MethodCall::class];
    }

    /**
     * Performs the transformation for matching MethodCall nodes.
     *
     * @param  MethodCall      $node
     * @return StaticCall|null
     */
    public function refactor(Node $node): ?Node
    {
        // Only match ->update(...)
        if (!$node->name instanceof Identifier || $node->name->toString() !== 'update') {
            return null;
        }

        // Ensure it's preceded by ->where(...)
        $whereCall = $node->var;
        if (
            !$whereCall instanceof MethodCall ||
            !$whereCall->name instanceof Identifier ||
            $whereCall->name->toString() !== 'where'
        ) {
            return null;
        }

        // Ensure that before that is a static ::find() call
        $findCall = $whereCall->var;
        if (
            !$findCall instanceof StaticCall ||
            !$findCall->name instanceof Identifier ||
            $findCall->name->toString() !== 'find'
        ) {
            return null;
        }

        // Ensure the update call has at least one argument
        if (empty($node->args)) {
            return null;
        }

        // Convert to: Model::updateAll($data, $condition)
        return new StaticCall(
            $findCall->class,
            new Identifier('updateAll'),
            [
                $node->args[0],
                $whereCall->args[0] ?? new Array_([]),
            ]
        );
    }
}
