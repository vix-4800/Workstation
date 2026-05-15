<?php

declare(strict_types=1);

namespace CustomFixer;

use PhpCsFixer\Tokenizer\Tokens;

final readonly class FluentChainCollector
{
    /**
     * @param Tokens $tokens Token stream being analyzed.
     */
    public function __construct(
        private Tokens $tokens,
    ) {
    }

    /**
     * @return list<array{start: int, end: int, calls: list<array{operator: int, open: int, close: int}>}>
     */
    public function collectChains(): array
    {
        $chains = [];
        $processedOperators = [];

        for ($index = 0, $count = $this->tokens->count(); $index < $count; ++$index) {
            if (array_key_exists($index, $processedOperators) || !$this->isMethodCallOperator($index)) {
                continue;
            }

            $chain = $this->collectMethodCallChain($index);

            foreach ($chain['calls'] as $call) {
                $processedOperators[$call['operator']] = true;
            }

            $chains[] = $chain;
        }

        return $chains;
    }

    /**
     * Checks whether the collected chain already spans multiple lines.
     */
    public function shouldFormatChain(int $startIndex, int $endIndex): bool
    {
        return $this->chainContainsNewline($startIndex, $endIndex)
            || $this->hasLeadingLineBreak($startIndex)
            || $this->isInsideMultilineStructure($startIndex);
    }

    /**
     * Checks whether the collected chain already spans multiple lines.
     */
    private function chainContainsNewline(int $startIndex, int $endIndex): bool
    {
        for ($index = $startIndex; $index <= $endIndex; ++$index) {
            if (!$this->tokens[$index]->isWhitespace()) {
                continue;
            }

            if (str_contains($this->tokens[$index]->getContent(), "\n")) {
                return true;
            }
        }

        return false;
    }

    /**
     * Detects chains that already begin on a continuation line.
     */
    private function hasLeadingLineBreak(int $startIndex): bool
    {
        $previousIndex = $startIndex - 1;

        if ($previousIndex < 0 || !$this->tokens[$previousIndex]->isWhitespace()) {
            return false;
        }

        return str_contains($this->tokens[$previousIndex]->getContent(), "\n");
    }

    /**
     * Returns indentation of the line that owns the chain root expression.
     */
    public function detectChainIndentation(int $startIndex): string
    {
        $lookupIndex = $startIndex;

        if ($this->hasLeadingLineBreak($startIndex)) {
            $lookupIndex = $startIndex - 1;
        }

        return $this->findIndentationBeforeIndex($lookupIndex);
    }

    /**
     * Detects chains nested inside a multiline wrapper such as arrays or argument lists.
     */
    private function isInsideMultilineStructure(int $startIndex): bool
    {
        $parenthesisDepth = 0;
        $squareDepth = 0;

        for ($index = $startIndex - 1; $index >= 0; --$index) {
            if ($this->registerClosingBlock($index, $parenthesisDepth, $squareDepth)) {
                continue;
            }

            if ($this->isOpeningMultilineBlock(
                $startIndex,
                $index,
                '(',
                $parenthesisDepth,
                Tokens::BLOCK_TYPE_PARENTHESIS_BRACE,
            )) {
                return true;
            }

            if ($this->isOpeningMultilineBlock(
                $startIndex,
                $index,
                '[',
                $squareDepth,
                Tokens::BLOCK_TYPE_ARRAY_SQUARE_BRACE,
            )) {
                return true;
            }

            if ($this->shouldStopMultilineSearch($index, $parenthesisDepth, $squareDepth)) {
                break;
            }
        }

        return false;
    }

    /**
     * Tracks nested closing blocks while scanning backwards.
     */
    private function registerClosingBlock(int $index, int &$parenthesisDepth, int &$squareDepth): bool
    {
        if ($this->tokens[$index]->equals(')')) {
            ++$parenthesisDepth;

            return true;
        }

        if ($this->tokens[$index]->equals(']')) {
            ++$squareDepth;

            return true;
        }

        return false;
    }

    /**
     * Checks whether the current opening token encloses the chain inside a multiline wrapper.
     */
    private function isOpeningMultilineBlock(
        int $startIndex,
        int $index,
        string $openingToken,
        int &$depth,
        int $blockType,
    ): bool {
        if (!$this->tokens[$index]->equals($openingToken)) {
            return false;
        }

        if ($depth > 0) {
            --$depth;

            return false;
        }

        $blockEnd = $this->tokens->findBlockEnd($blockType, $index);

        return $blockEnd > $startIndex && $this->blockContainsNewline($index, $blockEnd);
    }

    /**
     * Stops searching once the scan leaves the local statement scope.
     */
    private function shouldStopMultilineSearch(int $index, int $parenthesisDepth, int $squareDepth): bool
    {
        return $parenthesisDepth === 0
            && $squareDepth === 0
            && $this->tokens[$index]->equalsAny([';', '{']);
    }

    /**
     * Checks whether a wrapper block already spans multiple lines.
     */
    private function blockContainsNewline(int $startIndex, int $endIndex): bool
    {
        for ($index = $startIndex; $index <= $endIndex; ++$index) {
            if (!$this->tokens[$index]->isWhitespace()) {
                continue;
            }

            if (str_contains($this->tokens[$index]->getContent(), "\n")) {
                return true;
            }
        }

        return false;
    }

    /**
     * Finds indentation immediately after the nearest previous line break.
     */
    private function findIndentationBeforeIndex(int $index): string
    {
        for ($currentIndex = $index - 1; $currentIndex >= 0; --$currentIndex) {
            if (!$this->tokens[$currentIndex]->isWhitespace()) {
                continue;
            }

            $content = $this->tokens[$currentIndex]->getContent();
            $newlinePosition = strrpos($content, "\n");

            if ($newlinePosition === false) {
                continue;
            }

            return substr($content, $newlinePosition + 1);
        }

        return '';
    }

    /**
     * @return array{start: int, end: int, calls: list<array{operator: int, open: int, close: int}>}
     */
    private function collectMethodCallChain(int $startOperator): array
    {
        $calls = [];
        $currentOperator = $startOperator;

        while ($this->isMethodCallOperator($currentOperator)) {
            $methodNameIndex = $this->tokens->getNextMeaningfulToken($currentOperator);
            $openParenthesisIndex = $methodNameIndex === null ? null : $this->tokens->getNextMeaningfulToken($methodNameIndex);

            if ($openParenthesisIndex === null || !$this->tokens[$openParenthesisIndex]->equals('(')) {
                break;
            }

            $closeParenthesisIndex = $this->tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $openParenthesisIndex);

            $calls[] = [
                'operator' => $currentOperator,
                'open' => $openParenthesisIndex,
                'close' => $closeParenthesisIndex,
            ];

            $nextOperator = $this->tokens->getNextMeaningfulToken($closeParenthesisIndex);

            if ($nextOperator === null || !$this->isMethodCallOperator($nextOperator)) {
                break;
            }

            $currentOperator = $nextOperator;
        }

        $lastCall = $calls === [] ? null : $calls[array_key_last($calls)];

        return [
            'start' => $startOperator,
            'end' => $lastCall['close'] ?? $startOperator,
            'calls' => $calls,
        ];
    }

    /**
     * Detects fluent chain operators that are followed by a real method call.
     */
    private function isMethodCallOperator(int $index): bool
    {
        if ($index < 0 || $index >= $this->tokens->count()) {
            return false;
        }

        if (!$this->tokens[$index]->isGivenKind([T_OBJECT_OPERATOR, T_NULLSAFE_OBJECT_OPERATOR])) {
            return false;
        }

        $methodNameIndex = $this->tokens->getNextMeaningfulToken($index);

        if ($methodNameIndex === null || !$this->tokens[$methodNameIndex]->isGivenKind(T_STRING)) {
            return false;
        }

        $openParenthesisIndex = $this->tokens->getNextMeaningfulToken($methodNameIndex);

        return $openParenthesisIndex !== null && $this->tokens[$openParenthesisIndex]->equals('(');
    }
}
