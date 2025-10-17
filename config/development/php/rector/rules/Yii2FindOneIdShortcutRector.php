<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Arg;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ArrayItem;
use PhpParser\Node\Expr\StaticCall;
use PhpParser\Node\Identifier;
use PhpParser\Node\Scalar\String_;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * This Rector rule simplifies redundant array usage in findOne().
 * Specifically, it transforms:
 *     Model::findOne(['id' => $id])
 * into:
 *     Model::findOne($id)
 *
 * This only applies when the array contains a single key 'id'.
 */
final class Yii2FindOneIdShortcutRector extends AbstractRector
{
    /**
     * Provides documentation and example code for the rule.
     *
     * @return RuleDefinition
     */
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replaces Model::findOne([\'id\' => $id]) with Model::findOne($id)',
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
        return [StaticCall::class];
    }

    /**
     * Performs the transformation for matching StaticCall nodes.
     *
     * @param  StaticCall      $node
     * @return StaticCall|null
     */
    public function refactor(Node $node): ?Node
    {
        // Must be a call to ::findOne(...)
        if (!$node->name instanceof Identifier || $node->name->toString() !== 'findOne') {
            return null;
        }

        // Ensure there is exactly one argument and it is an array
        if (
            count($node->args) !== 1 ||
            !$node->args[0]->value instanceof Array_
        ) {
            return null;
        }

        $array = $node->args[0]->value;

        // Must contain exactly one item
        if (count($array->items) !== 1) {
            return null;
        }

        $item = $array->items[0];

        // The key must be a string 'id'
        if (!$item instanceof ArrayItem || !$item->key instanceof String_ || $item->key->value !== 'id') {
            return null;
        }

        // Transform to: Model::findOne($id)
        return new StaticCall(
            $node->class,
            new Identifier('findOne'),
            [new Arg($item->value)]
        );
    }
}
