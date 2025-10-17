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
 * This Rector rule replaces chained calls like:
 * Model::find()->where([...])->delete()
 * with a more concise:
 * Model::deleteAll([...])
 *
 * It only applies when the chain strictly follows the pattern:
 * StaticCall -> MethodCall('where') -> MethodCall('delete')
 */
final class Yii2DeleteAllShortcutRector extends AbstractRector
{
    /**
     * @return RuleDefinition
     */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replaces Model::find()->where([...])->delete() with Model::deleteAll([...])',
            []
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [MethodCall::class];
    }

    /**
     * @param MethodCall $node
     */
    public function refactor(Node $node): ?Node
    {
        // Ensure it's a ->delete() method
        if (!($node->name instanceof Identifier) || $node->name->toString() !== 'delete') {
            return null;
        }

        // Ensure it's called after ->where(...)
        $whereCall = $node->var;
        if (
            !($whereCall instanceof MethodCall) ||
            !($whereCall->name instanceof Identifier) ||
            $whereCall->name->toString() !== 'where'
        ) {
            return null;
        }

        // Ensure the base call is a static call to ::find()
        $findCall = $whereCall->var;
        if (
            !($findCall instanceof StaticCall) ||
            !($findCall->name instanceof Identifier) ||
            $findCall->name->toString() !== 'find'
        ) {
            return null;
        }

        // Generate: Model::deleteAll([...])
        return new StaticCall(
            $findCall->class,
            new Identifier('deleteAll'),
            [$whereCall->args[0] ?? new Array_([])]
        );
    }
}
