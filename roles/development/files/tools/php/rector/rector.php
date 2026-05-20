<?php

declare(strict_types=1);

use Rector\CodeQuality\Rector\CallLike\AddNameToBooleanArgumentRector;
use Rector\CodingStyle\Rector\ArrowFunction\StaticArrowFunctionRector;
use Rector\CodingStyle\Rector\Assign\NestedTernaryToMatchRector;
use Rector\CodingStyle\Rector\Closure\StaticClosureRector;
use Rector\CodingStyle\Rector\FuncCall\ArraySpreadInsteadOfArrayMergeRector;
use Rector\Config\RectorConfig;
use Rector\Php52\Rector\Switch_\ContinueToBreakInSwitchRector;
use Rector\Php80\Rector\Class_\ClassPropertyAssignToConstructorPromotionRector;
use Rector\Php80\Rector\NotIdentical\MbStrContainsRector;
use Rector\Php82\Rector\Param\AddSensitiveParameterAttributeRector;
use Rector\Php83\Rector\ClassMethod\AddOverrideAttributeToOverriddenMethodsRector;
use Rector\Php84\Rector\Class_\PropertyHookRector;
use Rector\Php85\Rector\Const_\ConstAndTraitDeprecatedAttributeRector;
use Rector\Php85\Rector\Expression\NestedFuncCallsToPipeOperatorRector;
use Rector\Php85\Rector\Property\AddOverrideAttributeToOverriddenPropertiesRector;
use Rector\Php85\Rector\StmtsAwareInterface\SequentialAssignmentsToPipeOperatorRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddParamTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddReturnTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\Property\AddPropertyTypeDeclarationRector;
use Rector\Unambiguous\Rector\Class_\RemoveReturnThisFromSetterClassMethodRector;
use Rector\ValueObject\PhpVersion;
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
use Vix\RectorRules\AddTypedClassConstantRector;
use Vix\RectorRules\CollapseSequentialStrReplaceRector;
use Vix\RectorRules\ExtractAssignmentFromIfConditionRector;
use Vix\RectorRules\NullableBoolReturnToFalseRector;
use Vix\RectorRules\ReplaceMultipleEqualWithInArrayRector;
use Vix\RectorRules\Yii2FindAllIdShortcutRector;
use Vix\RectorRules\Yii2FindOneFindAllShortcutRector;
use Vix\RectorRules\Yii2FindOneIdShortcutRector;
use Vix\RectorRules\Yii2PropertyAccessRector;
use Vix\RectorRules\Yii2RedundantActiveRecordSelfLookupRector;
use Vix\RectorRules\Yii2UseExistsInsteadOfCountRector;
use Vix\RectorRules\Yii2UseExistsInsteadOfOneNotNullRector;
use Vix\RectorRules\Yii2UserFindOneToIdentityRector;

$laravelRulesEnabled = false;
$yii2RulesEnabled = false;

$home = getenv('HOME');
$globalComposerAutoloadPath = $home . '/.config/composer/vendor/autoload.php';

require_once $globalComposerAutoloadPath;

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
    Yii2RedundantActiveRecordSelfLookupRector::class, // Remove redundant self lookups in ActiveRecord queries
];

$config = RectorConfig::configure()
    ->withRootFiles()
    ->withFluentCallNewLine()
    ->withParallel()
    ->withSkip([
        'vendor',
        'storage',
        'runtime',
        'tests',
        '*.blade.php',
        '_ide_helper.php',
        '_ide_helper_models.php',
        'bootstrap/cache',
    ])
    ->withPhpSets(php84: true)
    ->withPhpVersion(PhpVersion::PHP_84)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        codingStyle: true,
        typeDeclarations: true,
        typeDeclarationDocblocks: true,
        privatization: true,
        naming: true,
        instanceOf: true,
        earlyReturn: true,
        rectorPreset: true,
    )
    ->withImportNames(removeUnusedImports: true)
    ->withConfiguredRule(
        AddSensitiveParameterAttributeRector::class,
        [
            'sensitive_parameters' => [
                'password',
                'newPassword',
                'oldPassword',
                'secret',
                'apiKey',
                'token',
                'accessToken',
                'refreshToken',
                'authToken',
            ],
        ],
    )
    ->withAttributesSets()
    ->withMemoryLimit('2G');

$rules = [
    AddReturnTypeDeclarationRector::class,
    // IssetOnPropertyObjectToPropertyExistsRector::class,
    AddParamTypeDeclarationRector::class, // Adds parameter type declaration where missing
    AddPropertyTypeDeclarationRector::class, // Adds property type declaration where missing
    // JsonThrowOnErrorRector::class, // Adds JSON_THROW_ON_ERROR flag to json_decode/encode
    ClassPropertyAssignToConstructorPromotionRector::class, // Promotes class property assignments to constructor parameters
    AddOverrideAttributeToOverriddenMethodsRector::class, // Adds #[Override] attribute to overridden methods
    AddOverrideAttributeToOverriddenPropertiesRector::class, // Adds #[Override] attribute to overridden properties
    ConstAndTraitDeprecatedAttributeRector::class, // Adds #[Deprecated] attribute to deprecated constants and traits
    StaticClosureRector::class,
    ArraySpreadInsteadOfArrayMergeRector::class, // Replace array_merge() with array spread operator where possible
    NestedTernaryToMatchRector::class, // Convert nested ternary operators to match expressions
    StaticArrowFunctionRector::class, // Convert arrow functions to static where possible
    RemoveReturnThisFromSetterClassMethodRector::class, // Remove return $this; from setter methods
    MbStrContainsRector::class, // Replace mb_strpos() !== false and mb_strstr() with str_contains()
    PropertyHookRector::class, // Replace getter/setter with property hook
    // SequentialAssignmentsToPipeOperatorRector::class, // Convert sequential assignments to use the pipe operator
    // NestedFuncCallsToPipeOperatorRector::class, // Convert nested function calls to use the pipe operator
    ContinueToBreakInSwitchRector::class, // Use break instead of continue in switch statements

    // Custom code quality rules
    AddTypedClassConstantRector::class, // Add explicit type to class constants inferred from scalar literals (PHP 8.3+)
    CollapseSequentialStrReplaceRector::class, // Collapse sequential str_replace() calls with the same replacement into one call
    ExtractAssignmentFromIfConditionRector::class, // Extract assignment from if condition to improve readability
    NullableBoolReturnToFalseRector::class, // Replace ?bool return type with bool and return null → return false
    ReplaceMultipleEqualWithInArrayRector::class, // Replace multiple === comparisons with in_array()
    AddNameToBooleanArgumentRector::class, // Add argument name to boolean arguments for better readability
];

if ($laravelRulesEnabled) {
    foreach ($laravelRules as $laravelRule) {
        $rules[] = $laravelRule;
    }

    $config
        ->withSetProviders(LaravelSetProvider::class)
        ->withComposerBased(laravel: true);
}

if ($yii2RulesEnabled) {
    foreach ($yii2Rules as $yii2Rule) {
        $rules[] = $yii2Rule;
    }
}

return $config->withRules($rules);
