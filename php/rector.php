<?php

declare(strict_types=1);

use Rector\CodeQuality\Rector\BooleanNot\SimplifyDeMorganBinaryRector;
use Rector\CodeQuality\Rector\Class_\CompleteDynamicPropertiesRector;
use Rector\CodeQuality\Rector\Equal\UseIdenticalOverEqualWithSameTypeRector;
use Rector\CodeQuality\Rector\Expression\InlineIfToExplicitIfRector;
use Rector\CodeQuality\Rector\Foreach_\UnusedForeachValueToArrayKeysRector;
use Rector\CodeQuality\Rector\FuncCall\ChangeArrayPushToArrayAssignRector;
use Rector\CodeQuality\Rector\FuncCall\SimplifyRegexPatternRector;
use Rector\CodeQuality\Rector\FuncCall\SimplifyStrposLowerRector;
use Rector\CodeQuality\Rector\FunctionLike\SimplifyUselessVariableRector;
use Rector\CodeQuality\Rector\Identical\SimplifyBoolIdenticalTrueRector;
use Rector\CodeQuality\Rector\Identical\SimplifyConditionsRector;
use Rector\CodeQuality\Rector\If_\CombineIfRector;
use Rector\CodeQuality\Rector\If_\ShortenElseIfRector;
use Rector\CodeQuality\Rector\If_\SimplifyIfElseToTernaryRector;
use Rector\CodeQuality\Rector\If_\SimplifyIfReturnBoolRector;
use Rector\CodeQuality\Rector\Isset_\IssetOnPropertyObjectToPropertyExistsRector;
use Rector\CodeQuality\Rector\LogicalAnd\LogicalToBooleanRector;
use Rector\CodeQuality\Rector\Ternary\ArrayKeyExistsTernaryThenValueToCoalescingRector;
use Rector\CodeQuality\Rector\Ternary\UnnecessaryTernaryExpressionRector;
use Rector\CodingStyle\Rector\ClassMethod\NewlineBeforeNewAssignSetRector;
use Rector\Config\RectorConfig;
use Rector\DeadCode\Rector\Array_\RemoveDuplicatedArrayKeyRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\Concat\RemoveConcatAutocastRector;
use Rector\DeadCode\Rector\Property\RemoveUnusedPrivatePropertyRector;
use Rector\EarlyReturn\Rector\If_\ChangeIfElseValueAssignToEarlyReturnRector;
use Rector\EarlyReturn\Rector\Return_\PreparedValueToEarlyReturnRector;
use Rector\Php55\Rector\String_\StringClassNameToClassConstantRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddReturnTypeDeclarationRector;

return RectorConfig::configure()
    ->withRootFiles()
    ->withSkip([
        'vendor',
    ])
    ->withPhpSets(php84: true)
    ->withTypeCoverageLevel(0) // Type coverage level: 0 — no requirement for full type coverage
    ->withDeadCodeLevel(0) // Dead code detection level: 0 — do not analyze dead code
    ->withCodeQualityLevel(0) // Code quality improvement level: 0 — do not apply globally
    ->withImportNames(removeUnusedImports: true) // Import use-statements and remove unused ones
    ->withRules([
        // Simplifying conditions
        SimplifyBoolIdenticalTrueRector::class, // Replaces $a === true with just $a
        SimplifyIfReturnBoolRector::class, // Simplifies if-statements that return true/false
        SimplifyConditionsRector::class,
        CombineIfRector::class,
        ShortenElseIfRector::class,
        SimplifyDeMorganBinaryRector::class,

        // Code optimization
        ChangeIfElseValueAssignToEarlyReturnRector::class,
        PreparedValueToEarlyReturnRector::class,
        SimplifyUselessVariableRector::class,
        UnusedForeachValueToArrayKeysRector::class,
        ArrayKeyExistsTernaryThenValueToCoalescingRector::class,
        SimplifyIfElseToTernaryRector::class, // Replaces if/else with a ternary operator
        UnnecessaryTernaryExpressionRector::class, // Removes redundant ternary expressions

        // Safety and strong typing
        AddReturnTypeDeclarationRector::class,
        UseIdenticalOverEqualWithSameTypeRector::class,
        CompleteDynamicPropertiesRector::class,
        IssetOnPropertyObjectToPropertyExistsRector::class,

        // Remove dead code
        RemoveUnusedPrivateMethodRector::class, // Removes unused private methods
        RemoveUnusedPrivatePropertyRector::class, // Removes unused private properties
        RemoveDuplicatedArrayKeyRector::class,
        RemoveConcatAutocastRector::class,

        // Modern PHP constructs
        StringClassNameToClassConstantRector::class,

        // Arrays
        ChangeArrayPushToArrayAssignRector::class,

        // Strings
        SimplifyStrposLowerRector::class,
        SimplifyRegexPatternRector::class,

        // Code style
        NewlineBeforeNewAssignSetRector::class, // Enforces newline style before `new` assignments
        InlineIfToExplicitIfRector::class,
        LogicalToBooleanRector::class,
    ]);
