<?php

/**
 * @see https://cs.symfony.com/doc/rules/index.html
 */

declare(strict_types=1);

use CustomFixer\BlankLineAfterStatementFixer;
use CustomFixer\CatchExceptionToThrowableFixer;
use CustomFixer\IssetCoalesceFixer;
use CustomFixer\NoYodaComparisonFixer;
use CustomFixer\NumericLiteralSeparatorFixer;
use CustomFixer\RemoveUnusedCatchVariableFixer;
use CustomFixer\RemoveUnusedForeachKeyFixer;
use CustomFixer\PhpDocOpeningLineFixer;
use CustomFixer\RemoveDocBlockTagsFixer;
use CustomFixer\RequireNullSafeOperatorFixer;
use PhpCsFixer\Config;
use PhpCsFixer\Runner\Parallel\ParallelConfigFactory;

require_once __DIR__ . '/Fixer/NumericLiteralSeparatorFixer.php';
require_once __DIR__ . '/Fixer/BlankLineAfterStatementFixer.php';
require_once __DIR__ . '/Fixer/NoYodaComparisonFixer.php';
require_once __DIR__ . '/Fixer/IssetCoalesceFixer.php';
require_once __DIR__ . '/Fixer/CatchExceptionToThrowableFixer.php';
require_once __DIR__ . '/Fixer/RemoveUnusedCatchVariableFixer.php';
require_once __DIR__ . '/Fixer/RemoveUnusedForeachKeyFixer.php';
require_once __DIR__ . '/Fixer/PhpDocOpeningLineFixer.php';
require_once __DIR__ . '/Fixer/RequireNullSafeOperatorFixer.php';
require_once __DIR__ . '/Fixer/RemoveDocBlockTagsFixer.php';

return (new Config())
    ->setRiskyAllowed(true)
    ->setParallelConfig(ParallelConfigFactory::detect())
    ->setUsingCache(false)
    ->setUnsupportedPhpVersionAllowed(true)
    ->registerCustomFixers([
        new NumericLiteralSeparatorFixer(),
        new BlankLineAfterStatementFixer(),
        new NoYodaComparisonFixer(),
        new IssetCoalesceFixer(),
        new CatchExceptionToThrowableFixer(),
        new RemoveUnusedCatchVariableFixer(),
        new RemoveUnusedForeachKeyFixer(),
        new PhpDocOpeningLineFixer(),
        new RequireNullSafeOperatorFixer(),
        new RemoveDocBlockTagsFixer(),
    ])
    ->setRules([
        // ─────────────────────────────────────────────────────────────
        // Base preset
        // ─────────────────────────────────────────────────────────────
        '@PSR12' => true, // General PSR-12 formatting (indentation, braces, naming, etc.)

        // ─────────────────────────────────────────────────────────────
        // Modern PHP & Performance optimizations
        // ─────────────────────────────────────────────────────────────
        'psr_autoloading' => true, // Enforces PSR-4 autoloading standards
        'date_time_immutable' => true, // Prefers DateTimeImmutable over DateTime for safety
        'dir_constant' => true, // Replaces dirname(__FILE__) with __DIR__ (faster)
        'function_to_constant' => true, // Replaces functions with constants where possible (phpversion() → PHP_VERSION)
        'no_php4_constructor' => true, // Forbids PHP4-style constructors
        'pow_to_exponentiation' => true, // Replaces pow($a, $b) with $a ** $b
        'set_type_to_cast' => true, // Replaces settype() with type casting ((int) instead of settype())
        'ereg_to_preg' => true, // Replaces deprecated ereg functions with preg
        'fopen_flag_order' => true, // Orders fopen flags for readability
        'fopen_flags' => true, // Normalizes fopen flags
        'implode_call' => true, // Normalizes implode calls (correct parameter order)
        'magic_constant_casing' => true, // Normalizes magic constant casing (__FILE__, __DIR__)
        'magic_method_casing' => true, // Normalizes magic method casing (__construct, __toString)
        'native_function_casing' => true, // Normalizes native function casing
        'native_type_declaration_casing' => true, // Normalizes native type declaration casing (int, string, etc.)
        'no_binary_string' => true, // Removes b prefix from strings (for compatibility)
        'no_homoglyph_names' => true, // Forbids using homoglyphs in names
        'no_short_bool_cast' => true, // Forbids short boolean casting (!!)
        'no_unset_cast' => true, // Forbids unset casting (deprecated)
        'no_unset_on_property' => true, // Forbids unset on object properties
        'standardize_not_equals' => true, // Standardizes inequality operators (!= → !==)
        'string_implicit_backslashes' => true, // Escapes implicit backslashes in strings
        'explicit_indirect_variable' => true, // Uses braces for variable variables
        'logical_operators' => true, // Uses && and || instead of and and or for logical operations
        'non_printable_character' => true, // Removes non-printable characters from code
        'no_null_property_initialization' => true, // Removes explicit property initialization to null

        // ─────────────────────────────────────────────────────────────
        // PHPDOC and comments
        // ─────────────────────────────────────────────────────────────
        'phpdoc_align' => ['align' => 'vertical'], // Aligns tags like @param, @return, etc.
        'phpdoc_order' => ['order' => ['param', 'return', 'throws']], // Orders tags: @param → @return → @throws
        'phpdoc_summary' => false, // Doesn't require a period at the end of the first sentence
        'phpdoc_to_comment' => false, // Doesn't convert /** */ into regular // comments
        'phpdoc_scalar' => true, // Normalizes scalar types (e.g., integer → int)
        'phpdoc_separation' => true, // Ensures separation between different types of tags
        'phpdoc_trim' => true, // Trims PHPDoc comments
        'phpdoc_trim_consecutive_blank_line_separation' => true, // Trims blank line separation in PHPDoc comments
        // 'no_superfluous_phpdoc_tags' => true, // Removes unnecessary PHPDoc tags
        'phpdoc_types_order' => [
            'null_adjustment' => 'always_last',
            'sort_algorithm' => 'alpha',
        ],
        'phpdoc_indent' => true, // Indents PHPDoc comments
        'phpdoc_list_type' => true, // Normalizes list types in PHPDoc (e.g., array<int> → int[])
        'phpdoc_line_span' => true, // Changes doc blocks from single to multi line, or reversed.
        'phpdoc_no_alias_tag' => [
            'replacements' => [
                'const' => 'var',
                'type' => 'var',
                'link' => 'see',
            ],
        ], // Removes PHPDoc alias tags
        'CustomFixer/remove_doc_block_tags' => [
            'tags' => [
                'category',
                'package',
                'subpackage',
                'author',
                'copyright',
                'license',
                'link',
                'version',
            ],
        ],
        'phpdoc_no_useless_inheritdoc' => true, // Removes useless PHPDoc inheritdoc tags
        'phpdoc_no_empty_return' => true, // Removes empty @return tags
        'phpdoc_single_line_var_spacing' => true, // Ensures single line spacing for var tags
        'phpdoc_types' => true, // Normalizes PHPDoc types
        'phpdoc_var_annotation_correct_order' => true, // Ensures correct order of var annotations
        'phpdoc_var_without_name' => true, // Allows var annotations without a variable name
        'single_line_comment_spacing' => true, // Ensures single line spacing for comments
        'comment_to_phpdoc' => true, // Converts single-line comments to PHPDoc
        'no_empty_phpdoc' => true, // Removes empty PHPDoc blocks
        'header_comment' => ['header' => ''], // Removes header comments
        'no_blank_lines_after_phpdoc' => true, // Removes blank lines after PHPDoc
        'multiline_comment_opening_closing' => true, // Ensures proper opening and closing of multiline comments
        'phpdoc_add_missing_param_annotation' => ['only_untyped' => false], // Adds missing @param annotations in PHPDoc
        'phpdoc_array_type' => true, // PHPDoc array<T> type must be used instead of T[].
        'phpdoc_param_order' => true, // Orders @param tags according to method signature
        'phpdoc_tag_casing' => true, // Fixes casing of PHPDoc tags.

        // ─────────────────────────────────────────────────────────────────────────
        // Imports
        // ─────────────────────────────────────────────────────────────────────────
        'ordered_imports' => [
            'imports_order' => ['class', 'function', 'const'],
            'sort_algorithm' => 'alpha',
        ], // Orders imports: class, function, const
        'single_import_per_statement' => ['group_to_single_imports' => true], // Each import must be on a separate line
        'global_namespace_import' => [
            'import_classes' => true,
            'import_functions' => true,
            'import_constants' => true,
        ],
        'no_unneeded_import_alias' => true,
        'no_unused_imports' => true, // Removes unused imports
        'fully_qualified_strict_types' => ['import_symbols' => true], // Removes the leading part of fully qualified symbol references if a given symbol is imported

        // ─────────────────────────────────────────────────────────────────────────
        // Arrays & collections
        // ─────────────────────────────────────────────────────────────────────────
        'array_push' => true, // Replaces array_push() with [] for adding elements to arrays
        'array_indentation' => true, // Indentation within arrays
        'array_syntax' => ['syntax' => 'short'], // Uses [] instead of array()
        'list_syntax' => ['syntax' => 'short'], // Uses [] instead of list()
        'trim_array_spaces' => true, // Trims spaces inside array brackets
        'no_trailing_comma_in_singleline' => true, // No trailing comma in single-line arrays
        'whitespace_after_comma_in_array' => true, // Ensures whitespace after commas in arrays
        'no_whitespace_before_comma_in_array' => true, // No whitespace before commas in arrays
        'no_multiline_whitespace_around_double_arrow' => true, // No multiline whitespace around double arrow
        'normalize_index_brace' => true, // Normalizes index braces in arrays

        // ─────────────────────────────────────────────────────────────────────────
        // Spacing, operators, and general style
        // ─────────────────────────────────────────────────────────────────────────
        'yoda_style' => false, // Disables Yoda conditions
        'concat_space' => ['spacing' => 'one'],
        'binary_operator_spaces' => ['default' => 'single_space'],
        'no_extra_blank_lines' => ['tokens' => [
            'extra',
            'break',
            'continue',
            'return',
            'throw',
            'use',
            'curly_brace_block',
            'parenthesis_brace_block',
            'square_brace_block',
            'switch',
            'case',
            'default',
        ]], // Removes extra blank lines
        'single_quote' => true, // Converts double quotes to single quotes
        'cast_spaces' => true, // Consistent spacing in casts
        'combine_consecutive_issets' => true, // Combines isset($a) && isset($b)
        'combine_consecutive_unsets' => true, // Combines unset($a); unset($b);
        'explicit_string_variable' => true, // Use {$var} instead of $var in strings
        'no_empty_statement' => true, // Removes empty statements
        'blank_line_before_statement' => [
            'statements' => [
                'break',
                'continue',
                'declare',
                'do',
                'exit',
                'for',
                'foreach',
                'if',
                'include',
                'include_once',
                'require',
                'require_once',
                'return',
                'switch',
                'throw',
                'try',
                'while',
            ],
        ], // Requires a blank line before statements (return, throw, continue)
        'single_space_around_construct' => true, // Ensures single space around constructs
        'simplified_if_return' => true, // Simplifies if return statements
        'simplified_null_return' => true, // Simplifies null return statements
        'return_assignment' => true, // Simplifies return assignments
        'nullable_type_declaration' => ['syntax' => 'question_mark'], // Uses ? for nullable types
        'is_null' => true, // Replaces is_null($var) expression with null === $var
        'types_spaces' => ['space' => 'none'], // Consistent spacing in types
        'no_useless_concat_operator' => true, // Removes unnecessary concatenation of strings
        'no_unneeded_control_parentheses' => [
            'statements' => [
                'break',
                'clone',
                'continue',
                'echo_print',
                'negative_instanceof',
                'others',
                'return',
                'switch_case',
                'yield',
                'yield_from',
            ],
        ], // Removes unneeded control parentheses
        'clean_namespace' => true, // Removes unused use statements
        'no_unneeded_braces' => true, // Removes unneeded braces
        'no_unneeded_final_method' => true, // Removes unneeded final methods
        'simple_to_complex_string_variable' => true, // Uses complex variable interpolation {$var} instead of simple $var in strings
        'string_length_to_empty' => true, // Replaces strlen($str) === 0 with $str === ''
        'no_unreachable_default_argument_value' => true, // Removes unreachable default argument values

        // ─────────────────────────────────────────────────────────────────────────
        // File / opening tags / namespaces
        // ─────────────────────────────────────────────────────────────────────────
        'semicolon_after_instruction' => true, // Requires a semicolon after each instruction
        'include' => true, // File path should not be placed within parentheses
        'echo_tag_syntax' => ['format' => 'short'],
        'class_reference_name_casing' => true, // Normalizes class reference name casing

        // -────────────────────────────────────────────────────────────────────────
        // Attributes
        // ─────────────────────────────────────────────────────────────────────────
        'attribute_block_no_spaces' => true, // Removes spaces between attribute blocks
        'attribute_empty_parentheses' => true, // Removes empty parentheses from attributes
        'ordered_attributes' => true, // Orders attributes alphabetically

        // ─────────────────────────────────────────────────────────────────────────
        // Class & members layout
        // ─────────────────────────────────────────────────────────────────────────
        'class_attributes_separation' => [
            'elements' => [
                'trait_import' => 'one',
                'case' => 'one',
                'const' => 'one',
                'property' => 'one',
                'method' => 'one',
            ],
        ], // Enforces separation between class attributes
        'ordered_class_elements' => [
            'order' => [
                'use_trait',
                'case',
                'constant',
                'property',
                'construct',
                'destruct',

                // Methods
                // 'method_public',
                // 'method_protected',
                // 'method_private',
            ],
        ], // Enforces order of class elements
        'single_class_element_per_statement' => ['elements' => ['const', 'property']], // Enforces single class element per statement
        'single_trait_insert_per_statement' => true,

        // ─────────────────────────────────────────────────────────────────────────
        // Functions, signatures & arguments
        // ─────────────────────────────────────────────────────────────────────────
        'method_argument_space' => [
            'on_multiline' => 'ensure_fully_multiline',
            'after_heredoc' => true,
            'attribute_placement' => 'same_line',
            'keep_multiple_spaces_after_comma' => false,
        ], // Ensures fully multiline arguments
        'nullable_type_declaration_for_default_null_value' => true,
        'new_with_parentheses' => true,
        'unary_operator_spaces' => true, // Ensures consistent spacing for unary operators

        // ─────────────────────────────────────────────────────────────────────────
        // Chaining, ternaries and comparisons
        // ─────────────────────────────────────────────────────────────────────────
        'method_chaining_indentation' => true, // Ensures method chaining is properly indented
        'no_useless_else' => true, // Removes useless else statements
        'no_useless_return' => true, // Removes useless return statements in void functions
        'ternary_to_null_coalescing' => true, // Converts ternary to null coalescing (?: → ??)
        'assign_null_coalescing_to_coalesce_equal' => true, // $a = $a ?? $b becomes $a ??= $b
        'no_superfluous_elseif' => true,

        // ─────────────────────────────────────────────────────────────────────────
        // Type-related
        // ─────────────────────────────────────────────────────────────────────────
        'phpdoc_to_param_type' => true, // Converts PHPDoc @param to type hints
        'phpdoc_to_return_type' => true, // Converts PHPDoc @return to return type declarations
        'phpdoc_to_property_type' => true, // Converts PHPDoc @var to property type declarations
        'declare_strict_types' => true, // Force strict types declaration in all files.
        'strict_comparison' => true, // Uses === and !== instead of == and !=
        'strict_param' => true, // Enforces strict parameter types
        'void_return' => true, // Enforces void return type for functions that do not return a value

        // ─────────────────────────────────────────────────────────────────────────
        // Security & Best Practices
        // ─────────────────────────────────────────────────────────────────────────
        'modernize_types_casting' => true, // Uses (int), (float), (string), (bool) for type casting
        'no_alias_functions' => true, // Disallow the use of alias functions
        'random_api_migration' => true, // Replaces deprecated random number generation functions with modern ones
        'modifier_keywords' => ['elements' => ['property', 'method', 'const']], // Enforces visibility for all class properties and methods
        'self_accessor' => true, // Enforces the use of self:: for accessing static properties and methods
        'mb_str_functions' => true, // Enforces the use of mb_str_* functions for multibyte string operations

        // ─────────────────────────────────────────────────────────────────────────
        // Custom fixers
        // ─────────────────────────────────────────────────────────────────────────
        'CustomFixer/numeric_literal_separator' => ['min_digits' => 5],
        'CustomFixer/blank_line_after_statement' => [
            'statements' => [
                'if',
                'do',
                'while',
                'for',
                'foreach',
                'switch',
                'try',
            ],
        ],
        'CustomFixer/no_yoda_comparison' => true, // Converts Yoda-style comparisons to standard style
        'CustomFixer/isset_coalesce' => true, // Simplifies (... ?? null) !== null to isset(...)
        'CustomFixer/catch_exception_to_throwable' => true, // Replaces Exception catches with Throwable
        'CustomFixer/remove_unused_catch_variable' => true, // Removes unused variables in catch blocks (PHP 8.0+ non-capturing catch)
        'CustomFixer/remove_unused_foreach_key' => true, // Removes unused key variables from foreach loops
        'CustomFixer/phpdoc_opening_line' => true, // Ensures multi-line PHPDoc /** is on its own line
        'CustomFixer/require_null_safe_operator' => true, // Converts $x !== null ? $x->method() : null to $x?->method()

        // ─────────────────────────────────────────────────────────────────────────
        // Misc
        // ─────────────────────────────────────────────────────────────────────────
        'multiline_whitespace_before_semicolons' => ['strategy' => 'no_multi_line'], // Prevents newline before ;
        'use_arrow_functions' => true, // Use arrow functions where possible
        'static_lambda' => true,
        'lambda_not_used_import' => true, // Removes unused imports in lambda functions
        'final_public_method_for_abstract_class' => true,
        'final_class' => true, // Makes classes final if they are not abstract
        'no_mixed_echo_print' => true, // Disallows using both echo and print in the same file
        'modernize_strpos' => true, // Replaces strpos() calls with str_contains() where possible
        'no_alias_language_construct_call' => true, // Removes calls to alias language constructs
        'get_class_to_class_keyword' => true, // Replaces get_class() calls with the class keyword
        'no_useless_sprintf' => true, // Removes useless sprintf calls
        'operator_linebreak' => true, // Ensures operators are at the beginning of the line in multiline expressions
        'integer_literal_case' => true, // Normalizes integer literal casing (0x1A → 0x1a)
        'standardize_increment' => true, // Standardizes increment and decrement operators
        'long_to_shorthand_operator' => true, // Converts long-form assignment operators to their shorthand versions (e.g., $a = $a + 1 → $a += 1)
        'single_line_comment_style' => true, // Converts single-line comments to use // instead of #
    ]);
