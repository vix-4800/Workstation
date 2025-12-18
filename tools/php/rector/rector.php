<?php

declare(strict_types=1);

$rulesDir = __DIR__ . '/rules';
$ruleFiles = glob("{$rulesDir}/*.php");

if ($ruleFiles !== false) {
    foreach ($ruleFiles as $ruleFile) {
        if (!file_exists($ruleFile) || !is_readable($ruleFile)) {
            continue;
        }

        require_once $ruleFile;
    }
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
use Rector\Custom\Rules\Yii2FindAllIdShortcutRector;
use Rector\Custom\Rules\Yii2FindOneFindAllShortcutRector;
use Rector\Custom\Rules\Yii2FindOneIdShortcutRector;
use Rector\Custom\Rules\Yii2PropertyAccessRector;
use Rector\Custom\Rules\Yii2UseExistsInsteadOfCountRector;
use Rector\Custom\Rules\Yii2UseExistsInsteadOfOneNotNullRector;
use Rector\Custom\Rules\Yii2UserFindOneToIdentityRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\Concat\RemoveConcatAutocastRector;
use Rector\DeadCode\Rector\Property\RemoveUnusedPrivatePropertyRector;
use Rector\Php52\Rector\Switch_\ContinueToBreakInSwitchRector;
use Rector\Php55\Rector\String_\StringClassNameToClassConstantRector;
use Rector\Php73\Rector\FuncCall\JsonThrowOnErrorRector;
use Rector\Php73\Rector\FuncCall\JsonThrowOnErrorRector;
use Rector\Php80\Rector\Class_\ClassPropertyAssignToConstructorPromotionRector;
use Rector\Php80\Rector\NotIdentical\MbStrContainsRector;
use Rector\Php83\Rector\ClassMethod\AddOverrideAttributeToOverriddenMethodsRector;
use Rector\Php84\Rector\Class_\DeprecatedAnnotationToDeprecatedAttributeRector;
use Rector\Php84\Rector\Param\ExplicitNullableParamTypeRector;
use Rector\Privatization\Rector\Property\PrivatizeFinalClassPropertyRector;
use Rector\Strict\Rector\Empty_\DisallowedEmptyRuleFixerRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddMethodCallBasedStrictParamTypeRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddParamTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddReturnTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturnRector;
use Rector\TypeDeclaration\Rector\Property\AddPropertyTypeDeclarationRector;
use RectorLaravel\Rector\ArrayDimFetch\EnvVariableToEnvHelperRector;
use RectorLaravel\Rector\ArrayDimFetch\RequestVariablesToRequestFacadeRector;
use RectorLaravel\Rector\ArrayDimFetch\ServerVariableToRequestFacadeRector;
use RectorLaravel\Rector\ArrayDimFetch\SessionVariableToSessionFacadeRector;
use RectorLaravel\Rector\Empty_\EmptyToBlankAndFilledFuncRector;
use RectorLaravel\Rector\Expr\AppEnvironmentComparisonToParameterRector;
use RectorLaravel\Rector\FuncCall\FactoryFuncCallToStaticCallRector;
use RectorLaravel\Rector\FuncCall\NotFilledBlankFuncCallToBlankFilledFuncCallRector;
use RectorLaravel\Rector\FuncCall\NowFuncWithStartOfDayMethodCallToTodayFuncRector;
use RectorLaravel\Rector\FuncCall\RemoveDumpDataDeadCodeRector;
use RectorLaravel\Rector\FuncCall\ThrowIfAndThrowUnlessExceptionsToUseClassStringRector;
use RectorLaravel\Rector\If_\AbortIfRector;
use RectorLaravel\Rector\If_\ThrowIfRector;
use RectorLaravel\Rector\MethodCall\AssertStatusToAssertMethodRector;
use RectorLaravel\Rector\MethodCall\EloquentOrderByToLatestOrOldestRector;
use RectorLaravel\Rector\MethodCall\EloquentWhereRelationTypeHintingParameterRector;
use RectorLaravel\Rector\MethodCall\EloquentWhereTypeHintClosureParameterRector;
use RectorLaravel\Rector\MethodCall\RedirectBackToBackHelperRector;
use RectorLaravel\Rector\MethodCall\RedirectRouteToToRouteHelperRector;
use RectorLaravel\Rector\MethodCall\ResponseHelperCallToJsonResponseRector;
use RectorLaravel\Rector\MethodCall\ValidationRuleArrayStringValueToArrayRector;
use RectorLaravel\Rector\StaticCall\EloquentMagicMethodToQueryBuilderRector;
use RectorLaravel\Rector\StaticCall\RequestStaticValidateToInjectRector;
use RectorLaravel\Set\LaravelSetProvider;

$laravelRules = [
    AbortIfRector::class,
    ThrowIfRector::class,
    RemoveDumpDataDeadCodeRector::class,
    EmptyToBlankAndFilledFuncRector::class,
    AssertStatusToAssertMethodRector::class,
    EloquentOrderByToLatestOrOldestRector::class,
    EloquentWhereRelationTypeHintingParameterRector::class,
    EloquentWhereTypeHintClosureParameterRector::class,
    ResponseHelperCallToJsonResponseRector::class,
    AppEnvironmentComparisonToParameterRector::class,
    ValidationRuleArrayStringValueToArrayRector::class,
    NotFilledBlankFuncCallToBlankFilledFuncCallRector::class,
    RedirectRouteToToRouteHelperRector::class,
    RedirectBackToBackHelperRector::class,
    FactoryFuncCallToStaticCallRector::class,
    NowFuncWithStartOfDayMethodCallToTodayFuncRector::class,
    ThrowIfAndThrowUnlessExceptionsToUseClassStringRector::class,
    RequestStaticValidateToInjectRector::class,
    EloquentMagicMethodToQueryBuilderRector::class,
    SessionVariableToSessionFacadeRector::class,
    ServerVariableToRequestFacadeRector::class,
    EnvVariableToEnvHelperRector::class,
    RequestVariablesToRequestFacadeRector::class,
];

$yii2Rules = [
    Yii2PropertyAccessRector::class, // Convert Yii::$app->user->getId() to Yii::$app->user->id
    Yii2FindAllIdShortcutRector::class, // Optimize findAll queries by ID
    Yii2FindOneFindAllShortcutRector::class, // Convert findOne/findAll patterns to more efficient forms
    Yii2FindOneIdShortcutRector::class, // Simplify findOne operations by ID
    Yii2UserFindOneToIdentityRector::class, // Replace User::findOne() with identity access patterns
    Yii2UseExistsInsteadOfOneNotNullRector::class, // Replace ->one() !== null with ->exists()
    Yii2UseExistsInsteadOfCountRector::class, // Replace ->count() > 0 with ->exists()
];

return RectorConfig::configure()
    ->withRootFiles()
    ->withParallel()
    ->withSkip([
        'vendor',
        'storage',
        'runtime',
        'tests',
        '*.blade.php',
        'tests',
        '_ide_helper.php',
        '_ide_helper_models.php',
        'bootstrap/cache',
    ])
    ->withPhpSets(php83: true)
    ->withSetProviders(LaravelSetProvider::class)
    ->withComposerBased(laravel: true)
    ->withTypeCoverageLevel(2) // Type coverage level: 0 — no requirement for full type coverage
    ->withDeadCodeLevel(2) // Dead code detection level: 0 — do not analyze dead code
    ->withCodeQualityLevel(3) // Code quality improvement level: 0 — do not apply globally
    ->withPreparedSets(
        codingStyle: true,
        privatization: true,
        rectorPreset: true,
        earlyReturn: true,
    )
    ->withImportNames(removeUnusedImports: true)
    ->withAttributesSets()
    ->withSkip([
        EncapsedStringsToSprintfRector::class,
        PrivatizeFinalClassPropertyRector::class,
    ])
    ->withRules([
        // Laravel specific refactorings
        ...$laravelRules,

        // Yii2 specific refactorings
        ...$yii2Rules,

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
        ContinueToBreakInSwitchRector::class,

        // Safety and strong typing
        AddReturnTypeDeclarationRector::class,
        UseIdenticalOverEqualWithSameTypeRector::class,
        CompleteDynamicPropertiesRector::class,
        // IssetOnPropertyObjectToPropertyExistsRector::class,
        AddVoidReturnTypeWhereNoReturnRector::class, // Adds void return type where no return is present
        AddParamTypeDeclarationRector::class, // Adds parameter type declaration where missing
        AddPropertyTypeDeclarationRector::class, // Adds property type declaration where missing
        AddMethodCallBasedStrictParamTypeRector::class, // Adds strict parameter type based on method calls
        DisallowedEmptyRuleFixerRector::class, // Disallow usage of empty()
        JsonThrowOnErrorRector::class, // Adds JSON_THROW_ON_ERROR flag to json_decode/encode

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
        AddOverrideAttributeToOverriddenMethodsRector::class, // Adds #[Override] attribute to overridden methods
        DeprecatedAnnotationToDeprecatedAttributeRector::class, // Converts @deprecated annotations to #[Deprecated] attributes

        // Arrays
        ChangeArrayPushToArrayAssignRector::class,

        // Strings
        SimplifyStrposLowerRector::class,
        SimplifyRegexPatternRector::class,
        MbStrContainsRector::class,

        // Code style
        InlineIfToExplicitIfRector::class,
        LogicalToBooleanRector::class,

        ExplicitNullableParamTypeRector::class,

        // Custom code quality rules
        ExtractAssignmentFromIfConditionRector::class, // Extract assignment from if condition to improve readability
        ReplaceMultipleEqualWithInArrayRector::class, // Replace multiple === comparisons with in_array()
    ]);
