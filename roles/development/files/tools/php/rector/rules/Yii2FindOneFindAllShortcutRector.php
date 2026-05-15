<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ArrayItem;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Expr\StaticCall;
use PhpParser\Node\Identifier;
use PhpParser\Node\Scalar\String_;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
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
            [
                new CodeSample(
                    "Model::find()->where(['id' => \$id])->one();",
                    'Model::findOne($id);'
                ),
            ]
        );
    }

    /**
     * Specifies which node types this Rector rule should process.
     *
     * @return list<class-string<Node>>
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
        if (!$node->name instanceof Identifier) {
            return null;
        }

        $methodName = $node->name->toString();

        if (!in_array($methodName, ['one', 'all'], true)) {
            return null;
        }

        $whereCall = $node->var;

        if ($whereCall instanceof MethodCall && $whereCall->name instanceof Identifier && $whereCall->name->toString() === 'limit') {
            return null;
        }

        if (
            !($whereCall instanceof MethodCall)
            || !($whereCall->name instanceof Identifier)
            || $whereCall->name->toString() !== 'where'
        ) {
            return null;
        }

        $findCall = $whereCall->var;

        if (
            !($findCall instanceof StaticCall)
            || !($findCall->name instanceof Identifier)
            || $findCall->name->toString() !== 'find'
        ) {
            return null;
        }

        $newMethod = $methodName === 'one' ? 'findOne' : 'findAll';
        $newArgs = $this->resolveShortcutArgs($whereCall);

        return new StaticCall(
            $findCall->class,
            new Identifier($newMethod),
            $newArgs
        );
    }

    /**
     * @return list<Arg>
     */
    private function resolveShortcutArgs(MethodCall $whereCall): array
    {
        if (count($whereCall->args) !== 1) {
            return $whereCall->args;
        }

        $firstArg = $whereCall->args[0]->value;

        if (!$firstArg instanceof Array_) {
            return $whereCall->args;
        }

        $shortcutArg = $this->resolveSingleIdArg($firstArg);

        if (!$shortcutArg instanceof Arg) {
            return $whereCall->args;
        }

        return [$shortcutArg];
    }

    /**
     * @return Arg|null
     */
    private function resolveSingleIdArg(Array_ $array): ?Arg
    {
        if (count($array->items) !== 1) {
            return null;
        }

        $item = $array->items[0];

        if (!$item instanceof ArrayItem) {
            return null;
        }

        if (!$item->key instanceof String_ || $item->key->value !== 'id') {
            return null;
        }

        return new Arg($item->value);
    }
}
