<?php

declare(strict_types=1);

use PhpCsFixer\Config;

return (new Config())
    ->setRiskyAllowed(true)
    ->setRules([
        '@PSR12' => true,

        // PHPDoc
        'header_comment' => ['header' => ''],
        'phpdoc_align' => ['align' => 'vertical'],
        'phpdoc_scalar' => true,
        'phpdoc_separation' => true,
        'phpdoc_trim' => true,
        'phpdoc_trim_consecutive_blank_line_separation' => true,
        'phpdoc_order' => ['order' => ['param', 'return', 'throws']],
        'phpdoc_indent' => true,
        'no_blank_lines_after_phpdoc' => true,

        // Imports
        'no_unused_imports' => true,
        'single_line_after_imports' => true,
        'no_leading_import_slash' => true,
        'single_import_per_statement' => true,
        'global_namespace_import' => [
            'import_classes' => true,
            'import_functions' => true,
            'import_constants' => true,
        ],
        'fully_qualified_strict_types' => ['import_symbols' => true],
        'no_unneeded_import_alias' => true,

        'method_argument_space' => [
            'on_multiline' => 'ensure_fully_multiline',
            'after_heredoc' => true,
            'attribute_placement' => 'ignore',
            'keep_multiple_spaces_after_comma' => false,
        ],

        'single_trait_insert_per_statement' => true,
        'class_attributes_separation' => ['elements' => [
            'const' => 'one',
            'property' => 'one',
            'method' => 'one',
            'trait_import' => 'none',
        ]],
        'array_syntax' => ['syntax' => 'short'],
    ])
    ->setUsingCache(false);
