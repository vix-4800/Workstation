<?php

declare(strict_types=1);

namespace CustomFixer;

use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;

final readonly class FluentChainWhitespaceFormatter
{
    /**
     * @param Tokens $tokens Token stream being rewritten.
     * @param string $lineBreak Configured project line ending.
     * @param string $indent Single indentation unit from php-cs-fixer whitespace config.
     */
    public function __construct(
        private Tokens $tokens,
        private string $lineBreak,
        private string $indent,
    ) {
    }

    /**
     * Removes wrapper-only newlines from an argument list when the inner content is already single-line.
     */
    public function compactArgumentsIfPossible(int $openParenthesisIndex, int $closeParenthesisIndex): bool
    {
        if (!$this->canCompactArguments($openParenthesisIndex, $closeParenthesisIndex)) {
            return false;
        }

        return $this->compactArguments($openParenthesisIndex, $closeParenthesisIndex);
    }

    /**
     * Forces the operator onto its own continuation line.
     */
    public function ensureLineBreakBeforeOperator(int $operatorIndex, string $targetIndentation): bool
    {
        $targetWhitespace = $this->lineBreak . $targetIndentation;
        $previousIndex = $operatorIndex - 1;

        if ($previousIndex >= 0 && $this->tokens[$previousIndex]->isWhitespace()) {
            if ($this->tokens[$previousIndex]->getContent() === $targetWhitespace) {
                return false;
            }

            $this->tokens[$previousIndex] = new Token([T_WHITESPACE, $targetWhitespace]);

            return true;
        }

        $this->tokens->insertAt($operatorIndex, new Token([T_WHITESPACE, $targetWhitespace]));

        return true;
    }

    /**
     * Checks whether only outer wrapping whitespace would be removed.
     */
    private function canCompactArguments(int $openParenthesisIndex, int $closeParenthesisIndex): bool
    {
        $firstMeaningful = $this->tokens->getNextMeaningfulToken($openParenthesisIndex);
        $lastMeaningful = $this->tokens->getPrevMeaningfulToken($closeParenthesisIndex);

        if ($firstMeaningful === null || $lastMeaningful === null) {
            return false;
        }

        if ($firstMeaningful >= $closeParenthesisIndex || $lastMeaningful <= $openParenthesisIndex) {
            return false;
        }

        $content = '';

        for ($index = $openParenthesisIndex + 1; $index < $closeParenthesisIndex; ++$index) {
            if ($this->tokens[$index]->isComment()) {
                return false;
            }

            $content .= $this->tokens[$index]->getContent();
        }

        $trimmedContent = trim($content);

        return $trimmedContent !== ''
            && !str_contains($trimmedContent, "\n")
            && !str_contains($trimmedContent, "\r");
    }

    /**
     * Clears only boundary whitespace so built-in fixers can finish single-line normalization.
     */
    private function compactArguments(int $openParenthesisIndex, int $closeParenthesisIndex): bool
    {
        $firstMeaningful = $this->tokens->getNextMeaningfulToken($openParenthesisIndex);
        $lastMeaningful = $this->tokens->getPrevMeaningfulToken($closeParenthesisIndex);

        if ($firstMeaningful === null || $lastMeaningful === null) {
            return false;
        }

        $hasChanges = false;

        for ($index = $openParenthesisIndex + 1; $index < $firstMeaningful; ++$index) {
            if (!$this->tokens[$index]->isWhitespace()) {
                continue;
            }

            if ($this->tokens[$index]->getContent() === '') {
                continue;
            }

            $this->tokens->clearAt($index);
            $hasChanges = true;
        }

        for ($index = $lastMeaningful + 1; $index < $closeParenthesisIndex; ++$index) {
            if (!$this->tokens[$index]->isWhitespace()) {
                continue;
            }

            if ($this->tokens[$index]->getContent() === '') {
                continue;
            }

            $this->tokens->clearAt($index);
            $hasChanges = true;
        }

        return $hasChanges;
    }
}
