<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr\MethodCall;
use PhpParser\Node\Expr\PropertyFetch;
use PhpParser\Node\Expr\StaticPropertyFetch;
use PhpParser\Node\Identifier;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Рефакторинг Yii2 кода для улучшения читабельности:
 * - Yii::$app->user->getId() → Yii::$app->user->id
 * - Yii::$app->user->getIdentity() → Yii::$app->user->identity
 */
final class Yii2PropertyAccessRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Refactor Yii2 user method calls to property access for better readability',
            [
                new CodeSample(
                    'Yii::$app->user->getId()',
                    'Yii::$app->user->id'
                ),
                new CodeSample(
                    'Yii::$app->user->getIdentity()',
                    'Yii::$app->user->identity'
                ),
            ]
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
        if (!$node instanceof MethodCall) {
            return null;
        }

        // Проверяем, что это вызов метода getId() или getIdentity()
        if (!$this->isName($node->name, 'getId') && !$this->isName($node->name, 'getIdentity')) {
            return null;
        }

        // Проверяем, что это вызов на объекте user
        if (!$node->var instanceof PropertyFetch) {
            return null;
        }

        $propertyFetch = $node->var;
        if (!$this->isName($propertyFetch->name, 'user')) {
            return null;
        }

        // Проверяем, что это Yii::$app->user
        if (!$propertyFetch->var instanceof StaticPropertyFetch) {
            return null;
        }

        $staticPropertyFetch = $propertyFetch->var;
        if (!$staticPropertyFetch->class instanceof Name) {
            return null;
        }

        if (!$this->isName($staticPropertyFetch->class, 'Yii')) {
            return null;
        }

        if (!$this->isName($staticPropertyFetch->name, 'app')) {
            return null;
        }

        // Определяем, какое свойство должно быть вместо метода
        $newPropertyName = null;
        if ($this->isName($node->name, 'getId')) {
            $newPropertyName = 'id';
        } elseif ($this->isName($node->name, 'getIdentity')) {
            $newPropertyName = 'identity';
        }

        if ($newPropertyName === null) {
            return null;
        }

        // Создаем новый PropertyFetch вместо MethodCall
        return new PropertyFetch($node->var, new Identifier($newPropertyName));
    }
}
