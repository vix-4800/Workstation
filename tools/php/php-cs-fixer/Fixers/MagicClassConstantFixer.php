<?php

declare(strict_types=1);

namespace App\PhpCsFixer\Fixers;

use PhpCsFixer\AbstractFixer;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

/**
 * Custom fixer to replace __CLASS__ magic constant with self::class.
 *
 * This fixer replaces all occurrences of __CLASS__ with self::class,
 * which is the modern PHP approach for getting class name.
 */
final class MagicClassConstantFixer extends AbstractFixer
{
    /**
     * @return string
     */
    public function getName(): string
    {
        return 'App/magic_class_constant';
    }

    /**
     * @return FixerDefinitionInterface
     */
    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Replace __CLASS__ magic constant with self::class.',
            [
                new CodeSample(
                    '<?php
                    class Example
                    {
                        public function test()
                        {
                            return __CLASS__;
                        }
                    }
                    '
                ),
            ],
            'Replaces __CLASS__ with self::class for better code readability and consistency.'
        );
    }

    /**
     * @return int
     */
    public function getPriority(): int
    {
        // Should run before other fixers that might format the code
        return 0;
    }

    /**
     * @param Tokens $tokens
     *
     * @return bool
     */
    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_CLASS_C);
    }

    /**
     * @param SplFileInfo $file
     * @param Tokens      $tokens
     *
     * @return void
     */
    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            $token = $tokens[$index];

            if (!$token->isGivenKind(T_CLASS_C)) {
                continue;
            }

            // Replace __CLASS__ with self::class
            $tokens->overrideRange(
                $index,
                $index,
                [
                    new Token([T_STRING, 'self']),
                    new Token([T_DOUBLE_COLON, '::']),
                    new Token([T_STRING, 'class']),
                ]
            );
        }
    }
}
