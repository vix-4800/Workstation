<?php

declare(strict_types=1);

namespace Rector\Custom\Rules;

use PhpParser\Node;
use PhpParser\Node\Const_;
use PhpParser\Node\Expr\Array_;
use PhpParser\Node\Expr\ConstFetch;
use PhpParser\Node\Expr\UnaryMinus;
use PhpParser\Node\Identifier;
use PhpParser\Node\Scalar\Float_;
use PhpParser\Node\Scalar\Int_;
use PhpParser\Node\Scalar\String_;
use PhpParser\Node\Stmt\ClassConst;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

/**
 * Adds explicit types to untyped class/interface/enum constants where the type
 * can be unambiguously inferred from a scalar literal value.
 *
 * Handles:  int, float, string, bool, array
 * Skips:    null (no single concrete type), expressions, constant references
 *
 * Requires PHP 8.3+.
 */
final class AddTypedClassConstantRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Add explicit type to class constants inferred from their scalar literal value',
            [
                new CodeSample(
                    <<<'PHP'
class Foo
{
    public const MAX_VALUE = 42;
    public const NAME = 'John Doe';
    public const ENABLED = true;
}
PHP,
                    <<<'PHP'
class Foo
{
    public const int MAX_VALUE = 42;
    public const string NAME = 'John Doe';
    public const bool ENABLED = true;
}
PHP
                ),
            ]
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [ClassConst::class];
    }

    /**
     * @param ClassConst $node
     */
    public function refactor(Node $node): ?Node
    {
        // Already has a type – nothing to do.
        if ($node->type !== null) {
            return null;
        }

        // A ClassConst node can declare multiple constants in one statement,
        // e.g. `public const A = 1, B = 2;`
        // We only add a type when every const in the group resolves to the
        // *same* type; otherwise skip to avoid ambiguous situations.
        $types = [];

        foreach ($node->consts as $const) {
            $type = $this->resolveScalarType($const);

            if ($type === null) {
                return null; // at least one value is non-inferrable → skip whole node
            }

            $types[] = $type;
        }

        $uniqueTypes = array_unique($types);

        if (count($uniqueTypes) !== 1) {
            return null; // mixed types in one statement → skip
        }

        $node->type = new Identifier($uniqueTypes[0]);

        return $node;
    }

    private function resolveScalarType(Const_ $const): ?string
    {
        $value = $const->value;

        // int literal
        if ($value instanceof Int_) {
            return 'int';
        }

        // float literal
        if ($value instanceof Float_) {
            return 'float';
        }

        // string literal
        if ($value instanceof String_) {
            return 'string';
        }

        // bool literals (true / false)
        if ($value instanceof ConstFetch) {
            $name = strtolower($value->name->toString());

            if ($name === 'true' || $name === 'false') {
                return 'bool';
            }

            // null or other constant references → skip
            return null;
        }

        // array literal [ ... ]
        if ($value instanceof Array_) {
            return 'array';
        }

        // negative number: -1, -3.14
        if ($value instanceof UnaryMinus) {
            if ($value->expr instanceof Int_) {
                return 'int';
            }

            if ($value->expr instanceof Float_) {
                return 'float';
            }
        }

        // Anything else (binary ops, const fetches, function calls, …) → skip
        return null;
    }
}
