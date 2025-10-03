<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Expr\StaticCall;
use PhpParser\Node\Identifier;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * This Rector rule converts query chains like:
 * Model::find()->where([...])->one() / all()
 * into their shorter equivalents:
 * Model::findOne([...]) / findAll([...])
 *
 * Applies only when the call chain exactly matches the structure:
 * StaticCall::find() -> MethodCall::where(...) -> MethodCall::one()/all()
 */
final class Yii2FindOneFindAllShortcutRector extends AbstractRector
{
    /**
     * Provides documentation and example code for the rule.
     *
     * @return RuleDefinition
     */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Converts Model::find()->where([...])->one()/all() into Model::findOne([...]) or findAll([...]). Skips chains with limit() to preserve behavior.',
            []
        );
    }

    /**
     * Specifies which node types this Rector rule should process.
     *
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [MethodCall::class];
    }

    /**
     * Performs the transformation on matching MethodCall nodes.
     *
     * @param MethodCall $node
     *
     * @return StaticCall|null
     */
    public function refactor(Node $node): ?Node
    {
        // Check for ->one() or ->all()
        if (!($node->name instanceof Identifier)) {
            return null;
        }

        $methodName = $node->name->toString();
        if (!in_array($methodName, ['one', 'all'], true)) {
            return null;
        }

        // Get the previous method call (should be ->where(...))
        $whereCall = $node->var;

        // Skip transformation if there's a ->limit() call
        // because findOne/findAll don't apply limit internally
        if ($whereCall instanceof MethodCall && $whereCall->name instanceof Identifier && $whereCall->name->toString() === 'limit') {
            return null;
        }

        // Ensure the previous call is ->where(...)
        if (
            !($whereCall instanceof MethodCall) ||
            !($whereCall->name instanceof Identifier) ||
            $whereCall->name->toString() !== 'where'
        ) {
            return null;
        }

        // Ensure the base call is a static ::find()
        $findCall = $whereCall->var;
        if (
            !($findCall instanceof StaticCall) ||
            !($findCall->name instanceof Identifier) ||
            $findCall->name->toString() !== 'find'
        ) {
            return null;
        }

        // Determine the appropriate static method to replace with
        $newMethod = $methodName === 'one' ? 'findOne' : 'findAll';

        return new StaticCall(
            $findCall->class,
            new Identifier($newMethod),
            $whereCall->args
        );
    }
}
