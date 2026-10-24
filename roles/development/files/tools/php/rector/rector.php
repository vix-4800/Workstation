<?php

declare(strict_types=1);

use Rector\CodeQuality\Rector\Identical\FlipTypeControlToUseExclusiveTypeRector;
use Rector\Config\RectorConfig;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessParamTagRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessReturnTagRector;
use Rector\DeadCode\Rector\Property\RemoveUselessVarTagRector;
use Rector\Php80\Rector\Class_\ClassPropertyAssignToConstructorPromotionRector;
use Rector\Php83\Rector\ClassMethod\AddOverrideAttributeToOverriddenMethodsRector;
use Rector\PHPUnit\CodeQuality\Rector\Class_\PreferTestsWithCamelCaseRector;
use Rector\TypeDeclaration\Rector\BooleanAnd\BinaryOpNullableToInstanceofRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddParamTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\ClassMethod\AddReturnTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\Property\AddPropertyTypeDeclarationRector;
use Rector\TypeDeclaration\Rector\While_\WhileNullableToInstanceofRector;
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
use Vix\RectorRules\LegacyRector\AddParamArrayDocblockBasedOnArrayMapRector;
use Vix\RectorRules\LegacyRector\AddReturnArrayDocblockBasedOnArrayMapRector;
use Vix\RectorRules\LegacyRector\AddReturnDocblockForDimFetchArrayFromAssignsRector;
use Vix\RectorRules\LegacyRector\AddSensitiveParameterAttributeRector;
use Vix\RectorRules\LegacyRector\ChangeNestedForeachIfsToEarlyContinueRector;
use Vix\RectorRules\LegacyRector\ChangeNestedIfsToEarlyReturnRector;
use Vix\RectorRules\LegacyRector\ChangeOrIfContinueToMultiContinueRector;
use Vix\RectorRules\LegacyRector\CombineIfRector;
use Vix\RectorRules\LegacyRector\ConstAndTraitDeprecatedAttributeRector;
use Vix\RectorRules\LegacyRector\CountArrayToEmptyArrayComparisonRector;
use Vix\RectorRules\LegacyRector\DeprecatedAnnotationToDeprecatedAttributeRector;
use Vix\RectorRules\LegacyRector\DisallowedEmptyRuleFixerRector;
use Vix\RectorRules\LegacyRector\ExplicitBoolCompareRector;
use Vix\RectorRules\LegacyRector\FluentSettersToStandaloneCallMethodRector;
use Vix\RectorRules\LegacyRector\JsonThrowOnErrorRector;
use Vix\RectorRules\LegacyRector\NestedFuncCallsToPipeOperatorRector;
use Vix\RectorRules\LegacyRector\NestedTernaryToMatchRector;
use Vix\RectorRules\LegacyRector\NewInInitializerRector;
use Vix\RectorRules\LegacyRector\RemoveNamedArgsInDataProviderRector;
use Vix\RectorRules\LegacyRector\RenameDeprecatedMethodCallRector;
use Vix\RectorRules\LegacyRector\ReplaceTestFunctionPrefixWithAttributeRector;
use Vix\RectorRules\LegacyRector\ReturnBinaryOrToEarlyReturnRector;
use Vix\RectorRules\LegacyRector\SequentialAssignmentsToPipeOperatorRector;
use Vix\RectorRules\LegacyRector\ShortenElseIfRector;
use Vix\RectorRules\LegacyRector\SimplifyIfElseToTernaryRector;
use Vix\RectorRules\LegacyRector\SwitchNegatedTernaryRector;
use Vix\RectorRules\NullableBoolReturnToFalseRector;
use Vix\RectorRules\ReplaceMultipleEqualWithInArrayRector;
use Vix\RectorRules\TernaryNullCheckToNullsafeOperatorRector;
use Vix\RectorRules\Yii2\Yii2AddPropertyTagsRector;
use Vix\RectorRules\Yii2\Yii2AddRelationQueryGenericRector;
use Vix\RectorRules\Yii2\Yii2FindAllIdShortcutRector;
use Vix\RectorRules\Yii2\Yii2FindOneFindAllShortcutRector;
use Vix\RectorRules\Yii2\Yii2FindOneIdShortcutRector;
use Vix\RectorRules\Yii2\Yii2MergeModelRulesRector;
use Vix\RectorRules\Yii2\Yii2PropertyAccessRector;
use Vix\RectorRules\Yii2\Yii2RedundantActiveRecordSelfLookupRector;
use Vix\RectorRules\Yii2\Yii2UseExistsInsteadOfCountRector;
use Vix\RectorRules\Yii2\Yii2UseExistsInsteadOfOneNotNullRector;
use Vix\RectorRules\Yii2\Yii2UserFindOneToIdentityRector;

define('LARAVEL_RULES_ENABLED', value: false);
define('YII2_RULES_ENABLED', value: false);

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
    Yii2AddRelationQueryGenericRector::class, // Add generic type to relation query methods
    Yii2PropertyAccessRector::class, // Convert Yii::$app->user->getId() to Yii::$app->user->id
    Yii2FindAllIdShortcutRector::class, // Optimize findAll queries by ID
    Yii2FindOneFindAllShortcutRector::class, // Convert findOne/findAll patterns to more efficient forms
    Yii2FindOneIdShortcutRector::class, // Simplify findOne operations by ID
    Yii2MergeModelRulesRector::class, // Merge model validation rules with identical validators and options
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
        '*.blade.php',
        '_ide_helper.php',
        '_ide_helper_models.php',
        'bootstrap/cache',

        FlipTypeControlToUseExclusiveTypeRector::class,
        WhileNullableToInstanceofRector::class,
        BinaryOpNullableToInstanceofRector::class,
        RemoveUselessParamTagRector::class,
        RemoveUselessReturnTagRector::class,
        RemoveUselessVarTagRector::class,
    ])
    ->withPhpSets(php84: true)
    ->withPhpVersion(PhpVersion::PHP_84)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        codingStyle: true,
        privatization: true,
        // naming: true,
        instanceOf: true,
        earlyReturn: true,
        rectorPreset: true,
        // namedArgs: true,

        typeDeclarations: true,
        typeDeclarationDocblocks: true,

        phpunitCodeQuality: true,
        phpunitNarrowAsserts: true,
        phpunitMockToStub: true,
    )
    ->withComposerBased(
        phpunit: true,
        laravel: false,
        doctrine: false,
        symfony: false,
    )
    ->withImportNames()
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
    ->withConfiguredRule(
        Yii2AddPropertyTagsRector::class,
        [
            Yii2AddPropertyTagsRector::REFINE_PROPERTY_TAG_KINDS => true,
            Yii2AddPropertyTagsRector::REMOVE_UNRESOLVED_PROPERTY_TAGS => false,
        ]
    )
    ->reportUnusedSkips()
    ->withAttributesSets()
    ->withMemoryLimit('2G');

$rules = [
    AddReturnTypeDeclarationRector::class,
    // IssetOnPropertyObjectToPropertyExistsRector::class,
    AddParamTypeDeclarationRector::class, // Adds parameter type declaration where missing
    AddPropertyTypeDeclarationRector::class, // Adds property type declaration where missing
    ClassPropertyAssignToConstructorPromotionRector::class, // Promotes class property assignments to constructor parameters
    AddOverrideAttributeToOverriddenMethodsRector::class, // Adds #[Override] attribute to overridden methods

    // Custom code quality rules
    AddTypedClassConstantRector::class, // Add explicit type to class constants inferred from scalar literals (PHP 8.3+)
    CollapseSequentialStrReplaceRector::class, // Collapse sequential str_replace() calls with the same replacement into one call
    ExtractAssignmentFromIfConditionRector::class, // Extract assignment from if condition to improve readability
    NullableBoolReturnToFalseRector::class, // Replace ?bool return type with bool and return null → return false
    ReplaceMultipleEqualWithInArrayRector::class, // Replace multiple === comparisons with in_array()
    // AddNameToBooleanArgumentRector::class, // Add argument name to boolean arguments for better readability
    // AddNameToNullArgumentRector::class, // Add argument name to null arguments for better readability
    TernaryNullCheckToNullsafeOperatorRector::class, // Convert ternary null checks to nullsafe operator where possible

    // Restored legacy rules
    AddParamArrayDocblockBasedOnArrayMapRector::class,
    AddReturnArrayDocblockBasedOnArrayMapRector::class,
    AddReturnDocblockForDimFetchArrayFromAssignsRector::class,
    ChangeNestedForeachIfsToEarlyContinueRector::class,
    ChangeNestedIfsToEarlyReturnRector::class,
    ChangeOrIfContinueToMultiContinueRector::class,
    CombineIfRector::class,
    ConstAndTraitDeprecatedAttributeRector::class,
    CountArrayToEmptyArrayComparisonRector::class,
    DeprecatedAnnotationToDeprecatedAttributeRector::class,
    DisallowedEmptyRuleFixerRector::class,
    ExplicitBoolCompareRector::class,
    FluentSettersToStandaloneCallMethodRector::class,
    JsonThrowOnErrorRector::class,
    NestedFuncCallsToPipeOperatorRector::class,
    NestedTernaryToMatchRector::class,
    NewInInitializerRector::class,
    RemoveNamedArgsInDataProviderRector::class,
    RenameDeprecatedMethodCallRector::class,
    ReplaceTestFunctionPrefixWithAttributeRector::class,
    ReturnBinaryOrToEarlyReturnRector::class,
    SequentialAssignmentsToPipeOperatorRector::class,
    ShortenElseIfRector::class,
    SimplifyIfElseToTernaryRector::class,
    SwitchNegatedTernaryRector::class,

    // PHPUnit rules
    PreferTestsWithCamelCaseRector::class,
];

if (LARAVEL_RULES_ENABLED) {
    foreach ($laravelRules as $laravelRule) {
        $rules[] = $laravelRule;
    }

    $config
        ->withSetProviders(LaravelSetProvider::class)
        ->withComposerBased(laravel: true);
}

if (YII2_RULES_ENABLED) {
    foreach ($yii2Rules as $yii2Rule) {
        $rules[] = $yii2Rule;
    }
}

return $config->withRules($rules);
