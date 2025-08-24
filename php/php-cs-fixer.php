<?php

declare(strict_types=1);

use PhpCsFixer\Config;

return (new Config())
    ->setRiskyAllowed(true)
    ->setRules([
        '@PSR12' => true, // General PSR-12 formatting (indentation, braces, naming, etc.)

        // PHPDoc
        'phpdoc_add_missing_param_annotation' => true, // Adds missing @param tags
        'phpdoc_align' => ['align' => 'vertical'], // Aligns tags like @param, @return, etc.
        'phpdoc_order' => ['order' => ['param', 'return', 'throws']], // Orders tags: @param → @return → @throws
        'phpdoc_summary' => false, // Doesn't require a period at the end of the first sentence
        'phpdoc_to_comment' => false, // Doesn't convert /** */ into regular // comments
        'phpdoc_scalar' => true, // Normalizes scalar types (e.g., integer → int)

        // Imports
        'ordered_imports' => true, // Alphabetical ordering of use-statements

        // Arrays
        'array_indentation' => true, // Indentation within arrays
        'array_syntax' => ['syntax' => 'short'], // Uses [] instead of array()
        'trailing_comma_in_multiline' => ['elements' => ['arrays']], // Trailing comma in multiline arrays
        'multiline_whitespace_before_semicolons' => ['strategy' => 'no_multi_line'], // Prevents newline before ;
        'trim_array_spaces' => true, // Trims spaces inside array brackets

        // Style
        'yoda_style' => false, // Disables Yoda conditions
        'no_extra_blank_lines' => ['tokens' => ['extra']], // Removes extra blank lines
        'indentation_type' => true, // Uses spaces for indentation
        'no_trailing_whitespace' => true, // Removes trailing whitespace
        'no_whitespace_in_blank_line' => true, // No spaces on empty lines
        'single_blank_line_at_eof' => true, // Only one blank line at the end of file
        'line_ending' => true, // Unifies line endings
        'blank_line_after_namespace' => true, // Requires a blank line after the namespace declaration
        'blank_line_after_opening_tag' => true, // Requires a blank line after the opening <?php tag

        // Argument and array formatting
        'method_argument_space' => ['on_multiline' => 'ensure_fully_multiline'], // Ensures fully multiline arguments
        'braces' => ['position_after_functions_and_oop_constructs' => 'same'], // Keeps opening brace on the same line

        'ternary_to_null_coalescing' => true, // Converts ternary to null coalescing (?: → ??)
        'standardize_not_equals' => true, // Converts != to !==

        'use_arrow_functions' => true, // Use arrow functions where possible (potentially unsafe)
        'declare_strict_types' => true, // Force strict types declaration in all files.
        'strict_comparison' => true, // Uses === and !== instead of == and !=
        'strict_param' => true, // Enforces strict parameter types
        'no_unused_imports' => true, // Removes unused imports
        'single_quote' => true, // Converts double quotes to single quotes
    ])
    ->setUsingCache(false);
