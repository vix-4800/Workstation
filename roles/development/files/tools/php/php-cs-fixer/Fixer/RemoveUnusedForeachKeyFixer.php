<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

/**
 * Removes unused key variables from foreach loops.
 */
final class RemoveUnusedForeachKeyFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/remove_unused_foreach_key';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Removes unused key variables from foreach loops.',
            [
                new CodeSample(
                    "<?php\nforeach (\$items as \$key => \$value) {\n    echo \$value;\n}\n"
                ),
            ],
            'When the key variable in a foreach is never referenced in the loop body, the "key =>" part is removed.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_FOREACH);
    }

    #[Override]
    public function getPriority(): int
    {
        return 0;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind(T_FOREACH)) {
                continue;
            }

            $this->fixForeach($tokens, $index);
        }
    }

    private function fixForeach(Tokens $tokens, int $foreachIndex): void
    {
        $openParen = $tokens->getNextMeaningfulToken($foreachIndex);

        if ($openParen === null || !$tokens[$openParen]->equals('(')) {
            return;
        }

        $closeParen = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $openParen);

        // Find T_AS inside the foreach parentheses
        $asIndex = null;

        for ($i = $openParen + 1; $i < $closeParen; ++$i) {
            if ($tokens[$i]->isGivenKind(T_AS)) {
                $asIndex = $i;

                break;
            }
        }

        if ($asIndex === null) {
            return;
        }

        // Find T_DOUBLE_ARROW between T_AS and close paren (at paren depth 0)
        $doubleArrowIndex = null;
        $depth = 0;

        for ($i = $asIndex + 1; $i < $closeParen; ++$i) {
            if ($tokens[$i]->equals('(') || $tokens[$i]->equals('[')) {
                ++$depth;

                continue;
            }

            if ($tokens[$i]->equals(')') || $tokens[$i]->equals(']')) {
                --$depth;

                continue;
            }

            if ($depth === 0 && $tokens[$i]->isGivenKind(T_DOUBLE_ARROW)) {
                $doubleArrowIndex = $i;

                break;
            }
        }

        if ($doubleArrowIndex === null) {
            return;
        }

        // Collect meaningful tokens between T_AS and T_DOUBLE_ARROW — must be exactly one T_VARIABLE
        $keyTokens = [];

        for ($i = $asIndex + 1; $i < $doubleArrowIndex; ++$i) {
            if (!$tokens[$i]->isWhitespace() && !$tokens[$i]->isComment()) {
                $keyTokens[] = $i;
            }
        }

        if (count($keyTokens) !== 1 || !$tokens[$keyTokens[0]]->isGivenKind(T_VARIABLE)) {
            return;
        }

        $keyIndex = $keyTokens[0];
        $keyName = $tokens[$keyIndex]->getContent();

        // Find the foreach body
        $openBrace = $tokens->getNextMeaningfulToken($closeParen);

        if ($openBrace === null || !$tokens[$openBrace]->equals('{')) {
            return;
        }

        $closeBrace = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_CURLY_BRACE, $openBrace);

        // Check if key variable is used anywhere in the body
        for ($i = $openBrace + 1; $i < $closeBrace; ++$i) {
            if ($tokens[$i]->isGivenKind(T_VARIABLE) && $tokens[$i]->getContent() === $keyName) {
                return;
            }
        }

        // Remove everything from (exclusive) T_AS up to (inclusive) T_DOUBLE_ARROW and surrounding whitespace
        for ($i = $asIndex + 1; $i <= $doubleArrowIndex; ++$i) {
            $tokens->clearAt($i);
        }

        // Remove the whitespace directly after T_DOUBLE_ARROW
        if (isset($tokens[$doubleArrowIndex + 1]) && $tokens[$doubleArrowIndex + 1]->isWhitespace()) {
            $tokens->clearAt($doubleArrowIndex + 1);
        }
    }
}
