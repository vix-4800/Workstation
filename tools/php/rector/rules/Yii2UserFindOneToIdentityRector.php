<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Expr;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\PropertyFetch;
use PhpParser\Node\Expr\StaticCall;
use PhpParser\Node\Expr\StaticPropertyFetch;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

final class Yii2UserFindOneToIdentityRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replaces User::findOne(Yii::$app->user->id) with Yii::$app->user->identity',
            []
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [StaticCall::class];
    }

    /**
     * @param StaticCall $node
     */
    public function refactor(Node $node): ?Node
    {
        if (!$this->isUserFindOneCall($node)) {
            return null;
        }

        $args = $node->getArgs();

        if (count($args) !== 1) {
            return null;
        }

        $value = $args[0]->value;

        // User::findOne(Yii::$app->user->id)
        if ($this->isYiiUserIdPropertyFetch($value)) {
            return $this->createYiiUserIdentityPropertyFetch();
        }

        // User::findOne([Yii::$app->user->id])
        if ($this->isArrayOfSingleYiiUserId($value)) {
            return $this->createYiiUserIdentityPropertyFetch();
        }

        return null;
    }

    private function isUserFindOneCall(StaticCall $node): bool
    {
        if (!$this->isName($node->name, 'findOne')) {
            return false;
        }

        if ($node->class instanceof Name) {
            $className = $this->getName($node->class);
            $baseName = $className ? basename(str_replace('\\', '/', $className)) : null;

            return $baseName === 'User';
        }

        return false;
    }

    private function isYiiUserIdPropertyFetch(Expr $expr): bool
    {
        return $expr instanceof PropertyFetch
            && $this->getName($expr->name) === 'id'
            && $expr->var instanceof PropertyFetch
            && $this->getName($expr->var->name) === 'user'
            && $expr->var->var instanceof StaticPropertyFetch
            && $this->isName($expr->var->var->class, 'Yii')
            && $this->isName($expr->var->var->name, 'app');
    }

    private function isArrayOfSingleYiiUserId(Expr $expr): bool
    {
        if ($expr instanceof Array_ && count($expr->items) === 1) {
            $item = $expr->items[0];

            if ($item && $item->value && $this->isYiiUserIdPropertyFetch($item->value)) {
                return true;
            }
        }

        return false;
    }

    private function createYiiUserIdentityPropertyFetch(): PropertyFetch
    {
        return new PropertyFetch(
            new PropertyFetch(
                new StaticPropertyFetch(new Name('Yii'), 'app'),
                'user'
            ),
            'identity'
        );
    }
}
