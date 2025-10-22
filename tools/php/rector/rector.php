<?php

declare(strict_types=1);

$rulesDir = __DIR__ . '/rules';
$ruleFiles = glob("{$rulesDir}/*.php");
foreach ($ruleFiles as $ruleFile) {
    require_once $ruleFile;
}

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
use Rector\CodeQuality\Rector\LogicalAnd\LogicalToBooleanRector;
use Rector\CodeQuality\Rector\Switch_\SingularSwitchToIfRector;
use Rector\CodeQuality\Rector\Ternary\ArrayKeyExistsTernaryThenValueToCoalescingRector;
use Rector\CodeQuality\Rector\Ternary\SimplifyTautologyTernaryRector;
use Rector\CodeQuality\Rector\Ternary\TernaryEmptyArrayArrayDimFetchToCoalesceRector;
use Rector\CodeQuality\Rector\Ternary\UnnecessaryTernaryExpressionRector;
use Rector\CodingStyle\Rector\Encapsed\EncapsedStringsToSprintfRector;
use Rector\Config\RectorConfig;
use Rector\Custom\Rules\ExtractAssignmentFromIfConditionRector;
use Rector\Custom\Rules\ReplaceMultipleEqualWithInArrayRector;
use Rector\Custom\Rules\Yii2DeleteAllShortcutRector;
use Rector\Custom\Rules\Yii2FindAllIdShortcutRector;
use Rector\Custom\Rules\Yii2FindOneFindAllShortcutRector;
use Rector\Custom\Rules\Yii2FindOneIdShortcutRector;
use Rector\Custom\Rules\Yii2PropertyAccessRector;
use Rector\Custom\Rules\Yii2UpdateAllShortcutRector;
use Rector\Custom\Rules\Yii2UseExistsInsteadOfOneNotNullRector;
use Rector\Custom\Rules\Yii2UserFindOneToIdentityRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\Concat\RemoveConcatAutocastRector;
use Rector\DeadCode\Rector\Property\RemoveUnusedPrivatePropertyRector;
use Rector\Php55\Rector\String_\StringClassNameToClassConstantRector;
use Rector\Php73\Rector\FuncCall\JsonThrowOnErrorRector;
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
        'storage',
        'runtime',
        'tests',
        '*.blade.php',
    ])
    ->withPhpSets(php83: true)
    ->withTypeCoverageLevel(2) // Type coverage level: 0 — no requirement for full type coverage
    ->withDeadCodeLevel(2) // Dead code detection level: 0 — do not analyze dead code
    ->withCodeQualityLevel(3) // Code quality improvement level: 0 — do not apply globally
    ->withNoDiffs()
    ->withPreparedSets(
        earlyReturn: true,
        strictBooleans: true,
        privatization: true,
        codingStyle: true,
    )
    ->withImportNames(removeUnusedImports: true) // Import use-statements and remove unused ones
    ->withSkip([
        EncapsedStringsToSprintfRector::class
    ])
    ->withRules([
        // Simplifying conditions
        SimplifyBoolIdenticalTrueRector::class, // Replaces $a === true with just $a
        SimplifyIfReturnBoolRector::class, // Simplifies if-statements that return true/false
        SimplifyConditionsRector::class,
        CombineIfRector::class,
        ShortenElseIfRector::class,
        SimplifyDeMorganBinaryRector::class,

        // Code optimization
        SimplifyUselessVariableRector::class,
        UnusedForeachValueToArrayKeysRector::class,
        SimplifyIfElseToTernaryRector::class, // Replaces if/else with a ternary operator
        UnnecessaryTernaryExpressionRector::class, // Removes redundant ternary expressions

        // Safety and strong typing
        AddReturnTypeDeclarationRector::class,
        UseIdenticalOverEqualWithSameTypeRector::class,
        CompleteDynamicPropertiesRector::class,
        // IssetOnPropertyObjectToPropertyExistsRector::class,
        AddVoidReturnTypeWhereNoReturnRector::class, // Adds void return type where no return is present
        AddParamTypeDeclarationRector::class, // Adds parameter type declaration where missing
        AddPropertyTypeDeclarationRector::class, // Adds property type declaration where missing
        AddMethodCallBasedStrictParamTypeRector::class, // Adds strict parameter type based on method calls

        // Remove dead code
        RemoveUnusedPrivateMethodRector::class, // Removes unused private methods
        RemoveUnusedPrivatePropertyRector::class, // Removes unused private properties
        RemoveConcatAutocastRector::class,

        // Modern PHP constructs and functions
        StringClassNameToClassConstantRector::class, // Replaces string class names with ClassName::class
        ClassPropertyAssignToConstructorPromotionRector::class, // Promotes class property assignments to constructor parameters
        SingularSwitchToIfRector::class, // Replaces singular switch statements with if-statements
        ConsecutiveNullCompareReturnsToNullCoalesceQueueRector::class, // Replaces consecutive null compares with null coalesce
        TernaryEmptyArrayArrayDimFetchToCoalesceRector::class, // Replaces empty array checks in ternary conditions with null coalescing
        ArrayKeyExistsTernaryThenValueToCoalescingRector::class, // Replaces array_key_exists checks in ternary conditions with null coalescing
        SimplifyTautologyTernaryRector::class, // Simplifies tautological ternary expressions
        JsonThrowOnErrorRector::class, // Adds JSON_THROW_ON_ERROR flag to json_decode/encode

        // Arrays
        ChangeArrayPushToArrayAssignRector::class,

        // Strings
        SimplifyStrposLowerRector::class,
        SimplifyRegexPatternRector::class,

        // Code style
        InlineIfToExplicitIfRector::class,
        LogicalToBooleanRector::class,

        // Custom code quality rules
        ExtractAssignmentFromIfConditionRector::class, // Extract assignment from if condition to improve readability
        ReplaceMultipleEqualWithInArrayRector::class, // Replace multiple === comparisons with in_array()

        // Custom Yii2 rules - Improve readability and modernize Yii2 code patterns
        Yii2PropertyAccessRector::class, // Convert Yii::$app->user->getId() to Yii::$app->user->id
        Yii2DeleteAllShortcutRector::class, // Simplify ActiveRecord deleteAll operations
        Yii2FindAllIdShortcutRector::class, // Optimize findAll queries by ID
        Yii2FindOneFindAllShortcutRector::class, // Convert findOne/findAll patterns to more efficient forms
        Yii2FindOneIdShortcutRector::class, // Simplify findOne operations by ID
        Yii2UpdateAllShortcutRector::class, // Streamline ActiveRecord updateAll operations
        Yii2UserFindOneToIdentityRector::class, // Replace User::findOne() with identity access patterns
        Yii2UseExistsInsteadOfOneNotNullRector::class, // Replace ->one() !== null with ->exists()
    ]);
