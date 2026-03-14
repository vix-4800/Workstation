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
 * Removes unused variables from catch blocks using PHP 8.0+ non-capturing catch syntax.
 */
final class RemoveUnusedCatchVariableFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/remove_unused_catch_variable';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Removes unused variables from catch blocks (PHP 8.0+ non-capturing catch syntax).',
            [
                new CodeSample(
                    "<?php\ntry {\n    doWork();\n} catch (\\Exception \$e) {\n    return false;\n}\n"
                ),
            ],
            'Uses PHP 8.0+ non-capturing catch when the exception variable is never referenced in the catch body.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_CATCH);
    }

    #[Override]
    public function getPriority(): int
    {
        return 0;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind(T_CATCH)) {
                continue;
            }

            $this->removeUnusedVariable($tokens, $index);
        }
    }

    private function removeUnusedVariable(Tokens $tokens, int $catchIndex): void
    {
        $openParen = $tokens->getNextMeaningfulToken($catchIndex);

        if ($openParen === null || !$tokens[$openParen]->equals('(')) {
            return;
        }

        $closeParen = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $openParen);

        $variableIndex = null;

        for ($i = $openParen + 1; $i < $closeParen; ++$i) {
            if ($tokens[$i]->isGivenKind(T_VARIABLE)) {
                $variableIndex = $i;

                break;
            }
        }

        if ($variableIndex === null) {
            return;
        }

        $variableName = $tokens[$variableIndex]->getContent();

        $openBrace = $tokens->getNextMeaningfulToken($closeParen);

        if ($openBrace === null || !$tokens[$openBrace]->equals('{')) {
            return;
        }

        $closeBrace = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_CURLY_BRACE, $openBrace);

        for ($i = $openBrace + 1; $i < $closeBrace; ++$i) {
            if ($tokens[$i]->isGivenKind(T_VARIABLE) && $tokens[$i]->getContent() === $variableName) {
                return;
            }
        }

        // Remove variable and the whitespace immediately before it
        for ($i = $variableIndex; $i > $openParen; --$i) {
            if ($tokens[$i]->isGivenKind(T_VARIABLE) || $tokens[$i]->isWhitespace()) {
                $tokens->clearAt($i);

                continue;
            }

            break;
        }
    }
}
