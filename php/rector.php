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
use Rector\CodeQuality\Rector\If_\ConsecutiveNullCompareReturnsToNullCoalesceQueueRector;
use Rector\CodeQuality\Rector\If_\ShortenElseIfRector;
use Rector\CodeQuality\Rector\If_\SimplifyIfElseToTernaryRector;
use Rector\CodeQuality\Rector\If_\SimplifyIfReturnBoolRector;
use Rector\CodeQuality\Rector\Isset_\IssetOnPropertyObjectToPropertyExistsRector;
use Rector\CodeQuality\Rector\LogicalAnd\LogicalToBooleanRector;
use Rector\CodeQuality\Rector\Switch_\SingularSwitchToIfRector;
use Rector\CodeQuality\Rector\Ternary\ArrayKeyExistsTernaryThenValueToCoalescingRector;
use Rector\CodeQuality\Rector\Ternary\SimplifyTautologyTernaryRector;
use Rector\CodeQuality\Rector\Ternary\TernaryEmptyArrayArrayDimFetchToCoalesceRector;
use Rector\CodeQuality\Rector\Ternary\UnnecessaryTernaryExpressionRector;
use Rector\CodingStyle\Rector\ClassMethod\NewlineBeforeNewAssignSetRector;
use Rector\Config\RectorConfig;
use Rector\DeadCode\Rector\Array_\RemoveDuplicatedArrayKeyRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\Concat\RemoveConcatAutocastRector;
use Rector\DeadCode\Rector\Property\RemoveUnusedPrivatePropertyRector;
use Rector\EarlyReturn\Rector\Foreach_\ChangeNestedForeachIfsToEarlyContinueRector;
use Rector\EarlyReturn\Rector\If_\ChangeIfElseValueAssignToEarlyReturnRector;
use Rector\EarlyReturn\Rector\If_\RemoveAlwaysElseRector;
use Rector\EarlyReturn\Rector\Return_\PreparedValueToEarlyReturnRector;
use Rector\Php55\Rector\String_\StringClassNameToClassConstantRector;
use Rector\Php80\Rector\Class_\ClassPropertyAssignToConstructorPromotionRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddMethodCallBasedStrictParamTypeRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddParamTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddReturnTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturnRector;
use Rector\TypeDeclaration\Rector\Property\AddPropertyTypeDeclarationRector;

return RectorConfig::configure()
    ->withRootFiles()
    ->withParallel()
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
        SimplifyIfElseToTernaryRector::class, // Replaces if/else with a ternary operator
        UnnecessaryTernaryExpressionRector::class, // Removes redundant ternary expressions

        // Safety and strong typing
        AddReturnTypeDeclarationRector::class,
        UseIdenticalOverEqualWithSameTypeRector::class,
        CompleteDynamicPropertiesRector::class,
        IssetOnPropertyObjectToPropertyExistsRector::class,
        AddVoidReturnTypeWhereNoReturnRector::class, // Adds void return type where no return is present
        AddParamTypeDeclarationRector::class, // Adds parameter type declaration where missing
        AddPropertyTypeDeclarationRector::class, // Adds property type declaration where missing
        AddMethodCallBasedStrictParamTypeRector::class, // Adds strict parameter type based on method calls

        // Remove dead code
        RemoveUnusedPrivateMethodRector::class, // Removes unused private methods
        RemoveUnusedPrivatePropertyRector::class, // Removes unused private properties
        RemoveDuplicatedArrayKeyRector::class,
        RemoveConcatAutocastRector::class,

        // Modern PHP constructs
        StringClassNameToClassConstantRector::class,
        ClassPropertyAssignToConstructorPromotionRector::class, // Promotes class property assignments to constructor parameters
        SingularSwitchToIfRector::class, // Replaces singular switch statements with if-statements
        ConsecutiveNullCompareReturnsToNullCoalesceQueueRector::class, // Replaces consecutive null compares with null coalesce
        TernaryEmptyArrayArrayDimFetchToCoalesceRector::class, // Replaces empty array checks in ternary conditions with null coalescing
        ArrayKeyExistsTernaryThenValueToCoalescingRector::class, // Replaces array_key_exists checks in ternary conditions with null coalescing
        SimplifyTautologyTernaryRector::class, // Simplifies tautological ternary expressions

        // Arrays
        ChangeArrayPushToArrayAssignRector::class,

        // Strings
        SimplifyStrposLowerRector::class,
        SimplifyRegexPatternRector::class,

        // Code style
        NewlineBeforeNewAssignSetRector::class, // Enforces newline style before `new` assignments
        InlineIfToExplicitIfRector::class,
        LogicalToBooleanRector::class,
        RemoveAlwaysElseRector::class, // Removes else branches that are always executed
        ChangeNestedForeachIfsToEarlyContinueRector::class,
    ]);
