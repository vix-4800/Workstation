<?php

declare(strict_types=1);

use PhpCsFixer\Config;

return (new Config())
    ->setRiskyAllowed(true)
    ->setRules([
        // ─────────────────────────────────────────────────────────────
        // Base preset
        // ─────────────────────────────────────────────────────────────
        '@PSR12' => true, // General PSR-12 formatting (indentation, braces, naming, etc.)

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
        'no_superfluous_phpdoc_tags' => false, // Removes unnecessary PHPDoc tags
        'phpdoc_types_order' => [
            'null_adjustment' => 'always_last',
            'sort_algorithm' => 'alpha',
        ],
        'phpdoc_indent' => true, // Indents PHPDoc comments
        'phpdoc_no_alias_tag' => false, // Removes PHPDoc alias tags
        'phpdoc_no_package' => false, // Removes PHPDoc package tags
        'phpdoc_no_useless_inheritdoc' => false, // Removes useless PHPDoc inheritdoc tags
        'phpdoc_single_line_var_spacing' => true, // Ensures single line spacing for var tags
        'phpdoc_types' => true, // Normalizes PHPDoc types
        'phpdoc_var_annotation_correct_order' => true, // Ensures correct order of var annotations
        'phpdoc_var_without_name' => true, // Allows var annotations without a variable name
        'single_line_comment_spacing' => true, // Ensures single line spacing for comments
        'comment_to_phpdoc' => true, // Converts single-line comments to PHPDoc
        'no_empty_comment' => true, // Removes empty comments
        'no_empty_phpdoc' => true, // Removes empty PHPDoc blocks
        'no_blank_lines_after_phpdoc' => true, // Removes blank lines after PHPDoc

        // ─────────────────────────────────────────────────────────────────────────
        // Imports
        // ─────────────────────────────────────────────────────────────────────────
        'single_import_per_statement' => true, // Each import must be on a separate line
        'global_namespace_import' => [
            'import_classes' => true,
            'import_functions' => true,
            'import_constants' => true,
        ],
        'no_unneeded_import_alias' => true,
        'no_unused_imports' => true, // Removes unused imports
        'fully_qualified_strict_types' => ['import_symbols' => true], // Removes the leading part of fully qualified symbol references if a given symbol is imported
        'single_line_after_imports' => true, // Ensures a single blank line after import statements

        // ─────────────────────────────────────────────────────────────────────────
        // Arrays & collections
        // ─────────────────────────────────────────────────────────────────────────
        'array_indentation' => true, // Indentation within arrays
        'array_syntax' => ['syntax' => 'short'], // Uses [] instead of array()
        'list_syntax' => ['syntax' => 'short'], // Uses [] instead of list()
        'trim_array_spaces' => true, // Trims spaces inside array brackets
        'no_trailing_comma_in_singleline' => true, // No trailing comma in single-line arrays
        'whitespace_after_comma_in_array' => true, // Ensures whitespace after commas in arrays
        'no_whitespace_before_comma_in_array' => true, // No whitespace before commas in arrays
        'no_multiline_whitespace_around_double_arrow' => true, // No multiline whitespace around double arrow

        // ─────────────────────────────────────────────────────────────────────────
        // Spacing, operators, and general style
        // ─────────────────────────────────────────────────────────────────────────
        'yoda_style' => false, // Disables Yoda conditions
        'concat_space' => ['spacing' => 'one'],
        'binary_operator_spaces' => ['default' => 'single_space'],
        'no_extra_blank_lines' => true, // Removes extra blank lines
        'no_trailing_whitespace' => true, // Removes trailing whitespace
        'no_whitespace_in_blank_line' => true, // No spaces on empty lines
        'line_ending' => true, // Unifies line endings
        'single_blank_line_at_eof' => true, // Only one blank line at the end of file
        'cast_spaces' => ['space' => 'single'], // Consistent spacing in casts
        'combine_consecutive_issets' => true, // Combines isset($a) && isset($b)
        'combine_consecutive_unsets' => true, // Combines unset($a); unset($b);
        'explicit_string_variable' => true, // Use {$var} instead of $var in strings
        'no_empty_statement' => true, // Removes empty statements
        'blank_line_before_statement' => [
            'statements' => ['return', 'throw', 'continue', 'break', 'try'],
        ], // Requires a blank line before statements (return, throw, continue)
        'single_space_around_construct' => true, // Ensures single space around constructs
        'simplified_if_return' => true, // Simplifies if return statements
        'simplified_null_return' => true, // Simplifies null return statements
        'return_assignment' => true, // Simplifies return assignments
        'nullable_type_declaration' => ['syntax' => 'question_mark'], // Uses ? for nullable types
        'statement_indentation' => [
            'stick_comment_to_next_continuous_control_statement' => true,
        ], // Ensures consistent indentation for statements
        'is_null' => true, // Replaces is_null($var) expression with null === $var
        'types_spaces' => ['space' => 'none'], // Consistent spacing in types
        'short_scalar_cast' => true,
        'single_line_empty_body' => true, // Ensures single line empty body
        'no_useless_concat_operator' => true, // Removes unnecessary concatenation of strings
        'no_unneeded_control_parentheses' => [
            'statements' => ['break', 'clone', 'continue', 'echo_print', 'return', 'switch_case', 'yield'],
        ], // Removes unneeded control parentheses
        'clean_namespace' => true, // Removes unused use statements
        'no_unneeded_braces' => true, // Removes unneeded braces
        'no_unneeded_final_method' => true, // Removes unneeded final methods

        // ─────────────────────────────────────────────────────────────────────────
        // File / opening tags / namespaces
        // ─────────────────────────────────────────────────────────────────────────
        'full_opening_tag' => true, // Requires full opening tag (<?php)
        'blank_line_after_namespace' => true, // Requires a blank line after the namespace declaration
        'blank_lines_before_namespace' => true, // Requires blank lines before the namespace declaration
        'blank_line_after_opening_tag' => true, // Requires a blank line after the opening <?php tag
        'semicolon_after_instruction' => false, // Requires a semicolon after each instruction
        'no_closing_tag' => true, // Removes closing PHP tags
        'include' => true, // File path should not be placed within parentheses
        'echo_tag_syntax' => ['format' => 'short'],

        // ─────────────────────────────────────────────────────────────────────────
        // Class & members layout
        // ─────────────────────────────────────────────────────────────────────────
        'class_attributes_separation' => ['elements' => [
            'const' => 'one',
            'property' => 'one',
            'method' => 'one',
            'trait_import' => 'none',
        ]], // Enforces separation between class attributes
        // 'ordered_class_elements' => [
        //     'order' => [
        //         'use_trait',
        //         'constant_public', 'constant_protected', 'constant_private',
        //         'property_public', 'property_protected', 'property_private',
        //         'construct',
        //         'method_public', 'method_protected', 'method_private',
        //     ],
        // ], // Enforces order of class elements
        'single_class_element_per_statement' => ['elements' => ['const', 'property']], // Enforces single class element per statement
        'single_trait_insert_per_statement' => true,

        // ─────────────────────────────────────────────────────────────────────────
        // Functions, signatures & arguments
        // ─────────────────────────────────────────────────────────────────────────
        'method_argument_space' => [
            'on_multiline' => 'ensure_fully_multiline',
            'after_heredoc' => true,
            'attribute_placement' => 'ignore',
            'keep_multiple_spaces_after_comma' => false,
        ], // Ensures fully multiline arguments
        'return_type_declaration' => ['space_before' => 'none'],
        'nullable_type_declaration_for_default_null_value' => true,
        'new_with_braces' => true,
        'function_declaration' => ['closure_function_spacing' => 'one'], // Ensures one space after the function keyword

        // ─────────────────────────────────────────────────────────────────────────
        // Chaining, ternaries and comparisons
        // ─────────────────────────────────────────────────────────────────────────
        'method_chaining_indentation' => true, // Ensures method chaining is properly indented
        'elseif' => true,
        'control_structure_continuation_position' => true,
        'no_useless_else' => true, // Removes useless else statements
        'no_useless_return' => true, // Removes useless return statements in void functions
        'ternary_to_null_coalescing' => true, // Converts ternary to null coalescing (?: → ??)
        'assign_null_coalescing_to_coalesce_equal' => true, // $a = $a ?? $b becomes $a ??= $b
        'no_superfluous_elseif' => true,

        // ─────────────────────────────────────────────────────────────────────────
        // Type-related
        // ─────────────────────────────────────────────────────────────────────────
        // 'phpdoc_to_param_type' => true, // Converts PHPDoc @param to type hints
        // 'phpdoc_to_return_type' => true, // Converts PHPDoc @return to return type declarations
        // 'phpdoc_to_property_type' => true, // Converts PHPDoc @var to property type declarations
        // 'declare_strict_types' => true, // Force strict types declaration in all files.
        // 'strict_comparison' => true, // Uses === and !== instead of == and !=
        // 'strict_param' => true, // Enforces strict parameter types
        'void_return' => true, // Enforces void return type for functions that do not return a value

        // ─────────────────────────────────────────────────────────────────────────
        // Security & Best Practices
        // ─────────────────────────────────────────────────────────────────────────
        'modernize_types_casting' => true,
        'no_alias_functions' => true, // Disallow the use of alias functions
        'random_api_migration' => true,
        'visibility_required' => ['elements' => ['property', 'method', 'const']], // Enforces visibility for all class properties and methods
        'self_accessor' => true, // Enforces the use of self:: for accessing static properties and methods
        'mb_str_functions' => true, // Enforces the use of mb_str_* functions for multibyte string operations

        // ─────────────────────────────────────────────────────────────────────────
        // Misc
        // ─────────────────────────────────────────────────────────────────────────
        'multiline_whitespace_before_semicolons' => ['strategy' => 'no_multi_line'], // Prevents newline before ;
        'indentation_type' => true, // Uses spaces for indentation
        'use_arrow_functions' => true, // Use arrow functions where possible (potentially unsafe)
        'static_lambda' => true,
        'final_public_method_for_abstract_class' => true,
        'no_mixed_echo_print' => ['use' => 'echo'],
        'heredoc_to_nowdoc' => true,
        'modernize_strpos' => true, // Replace strpos() and stripos() calls with str_starts_with() or str_contains() if possible.
        'no_alias_language_construct_call' => true,
        'get_class_to_class_keyword' => true, // Replaces get_class() calls with the class keyword
    ])
    ->setUsingCache(false);
