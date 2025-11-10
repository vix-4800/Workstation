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
 * Custom fixer to replace legacy magic constants with modern alternatives.
 *
 * Replacements:
 * - __CLASS__ → self::class (in classes) or static::class (context-aware)
 * - __TRAIT__ → self::class (traits are classes, modern PHP uses self::class)
 *
 * Note: __METHOD__, __FUNCTION__, __FILE__, __DIR__, __LINE__, __NAMESPACE__
 * remain unchanged as they have no modern alternatives and are still standard.
 */
final class ModernMagicConstantsFixer extends AbstractFixer
{
    /**
     * @return string
     */
    public function getName(): string
    {
        return 'App/modern_magic_constants';
    }

    /**
     * @return FixerDefinitionInterface
     */
    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Replace legacy magic constants (__CLASS__, __TRAIT__) with modern alternatives (self::class).',
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

                    trait ExampleTrait
                    {
                        public function traitMethod()
                        {
                            return __TRAIT__;
                        }
                    }'
                ),
            ],
            'Modernizes magic constants for better code readability and consistency with current PHP standards.'
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
        return $tokens->isTokenKindFound(T_CLASS_C)
            || $tokens->isTokenKindFound(T_TRAIT_C);
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

            // Replace __CLASS__ with self::class
            if ($token->isGivenKind(T_CLASS_C)) {
                $this->replaceWithSelfClass($tokens, $index);
                continue;
            }

            // Replace __TRAIT__ with self::class
            if ($token->isGivenKind(T_TRAIT_C)) {
                $this->replaceWithSelfClass($tokens, $index);
                continue;
            }
        }
    }

    /**
     * Replace magic constant with self::class.
     *
     * @param Tokens $tokens
     * @param int    $index
     *
     * @return void
     */
    private function replaceWithSelfClass(Tokens $tokens, int $index): void
    {
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
