<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class RequireNullSafeOperatorFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/require_null_safe_operator';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Converts ternary null checks to the null-safe operator ?->.',
            [
                new CodeSample(
                    "<?php\n\$name = \$user !== null ? \$user->getName() : null;\n\$city = \$user !== null ? \$user->getAddress()->getCity() : null;\n"
                ),
            ],
            'Transforms $x !== null ? $x->method() : null (and != null) into $x?->method() for cleaner PHP 8+ code.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAnyTokenKindsFound([T_IS_NOT_IDENTICAL, T_IS_NOT_EQUAL])
            && $tokens->isTokenKindFound(T_OBJECT_OPERATOR);
    }

    #[Override]
    public function getPriority(): int
    {
        // Run after no_yoda_comparison so conditions are already normalized
        return -20;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind([T_IS_NOT_IDENTICAL, T_IS_NOT_EQUAL])) {
                continue;
            }

            $this->tryFix($tokens, $index);
        }
    }

    private function tryFix(Tokens $tokens, int $comparisonIndex): void
    {
        $leftIndex = $tokens->getPrevMeaningfulToken($comparisonIndex);
        $rightIndex = $tokens->getNextMeaningfulToken($comparisonIndex);

        if ($leftIndex === null || $rightIndex === null) {
            return;
        }

        // Must be: $var !== null  (non-Yoda; NoYodaComparisonFixer runs first)
        if (!$tokens[$leftIndex]->isGivenKind(T_VARIABLE)) {
            return;
        }

        if (!$this->isNullToken($tokens[$rightIndex])) {
            return;
        }

        $varName = $tokens[$leftIndex]->getContent();

        // Find the ? after the null (may be preceded by a closing paren if condition was wrapped)
        $afterNull = $tokens->getNextMeaningfulToken($rightIndex);

        if ($afterNull === null) {
            return;
        }

        $questionMarkIndex = $afterNull;
        $conditionStart = $leftIndex;

        // Handle: ($var !== null) ? ...
        if ($tokens[$afterNull]->equals(')')) {
            $parenOpen = $tokens->findBlockStart(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $afterNull);
            $beforeParen = $tokens->getPrevMeaningfulToken($parenOpen);

            // Make sure the ( isn't part of a function call or cast
            if ($beforeParen !== null && $tokens[$beforeParen]->isGivenKind([T_STRING, T_VARIABLE])) {
                return;
            }

            $conditionStart = $parenOpen;
            $questionMarkIndex = $tokens->getNextMeaningfulToken($afterNull);

            if ($questionMarkIndex === null) {
                return;
            }
        }

        if (!$tokens[$questionMarkIndex]->equals('?')) {
            return;
        }

        // True branch must start with $var->
        $trueBranchVar = $tokens->getNextMeaningfulToken($questionMarkIndex);

        if ($trueBranchVar === null) {
            return;
        }

        if (!$tokens[$trueBranchVar]->isGivenKind(T_VARIABLE)) {
            return;
        }

        if ($tokens[$trueBranchVar]->getContent() !== $varName) {
            return;
        }

        $objectOpIndex = $tokens->getNextMeaningfulToken($trueBranchVar);

        if ($objectOpIndex === null || !$tokens[$objectOpIndex]->isGivenKind(T_OBJECT_OPERATOR)) {
            return;
        }

        // Find the ternary colon matching our ?
        $colonIndex = $this->findTernaryColon($tokens, $questionMarkIndex);

        if ($colonIndex === null) {
            return;
        }

        // False branch must be exactly null
        $falseBranchStart = $tokens->getNextMeaningfulToken($colonIndex);

        if ($falseBranchStart === null || !$this->isNullToken($tokens[$falseBranchStart])) {
            return;
        }

        // Verify false branch is a bare null (not $x?->null or null->something)
        $afterFalseNull = $tokens->getNextMeaningfulToken($falseBranchStart);

        if ($afterFalseNull !== null && $tokens[$afterFalseNull]->isGivenKind(T_OBJECT_OPERATOR)) {
            return;
        }

        $this->performReplacement($tokens, $conditionStart, $objectOpIndex, $colonIndex, $falseBranchStart, $varName);
    }

    private function performReplacement(
        Tokens $tokens,
        int $conditionStart,
        int $objectOpIndex,
        int $colonIndex,
        int $falseBranchEnd,
        string $varName
    ): void {
        // Collect the method chain tokens (everything after -> up to but not including the colon,
        // preserving inner content but stripping trailing whitespace)
        $methodChainTokens = [];

        for ($i = $objectOpIndex + 1; $i < $colonIndex; ++$i) {
            $methodChainTokens[] = clone $tokens[$i];
        }

        // Trim trailing whitespace tokens from the method chain
        while ($methodChainTokens !== [] && $methodChainTokens[count($methodChainTokens) - 1]->isWhitespace()) {
            array_pop($methodChainTokens);
        }

        // Build the replacement token list: $var?->METHOD_CHAIN
        $replacement = new Tokens();
        $replacement->insertAt(0, new Token([T_VARIABLE, $varName]));
        $replacement->insertAt(1, new Token([T_NULLSAFE_OBJECT_OPERATOR, '?->']));

        foreach ($methodChainTokens as $offset => $token) {
            $replacement->insertAt(2 + $offset, $token);
        }

        // Replace the entire span [conditionStart..falseBranchEnd] with the replacement
        $tokens->overrideRange($conditionStart, $falseBranchEnd, $replacement);
    }

    /**
     * Finds the ternary : that pairs with the ? at $questionMarkIndex.
     *
     * Tracks bracket depth to skip colons inside (), [], {}, and tracks
     * nested ternary depth to match the correct colon.
     *
     * @param Tokens $tokens
     * @param int    $questionMarkIndex
     */
    private function findTernaryColon(Tokens $tokens, int $questionMarkIndex): ?int
    {
        $ternaryDepth = 0;

        for ($i = $questionMarkIndex + 1, $count = $tokens->count(); $i < $count; ++$i) {
            $token = $tokens[$i];

            if ($token->isGivenKind(T_OBJECT_OPERATOR)) {
                continue;
            }

            if ($token->isGivenKind(T_NULLSAFE_OBJECT_OPERATOR)) {
                continue;
            }

            // Track opening brackets – skip colons inside them
            if ($token->equalsAny(['(', '[', '{'])) {
                // Use findBlockEnd to jump past the whole block
                $blockType = $token->equals('(')
                    ? Tokens::BLOCK_TYPE_PARENTHESIS_BRACE
                    : ($token->equals('[') ? Tokens::BLOCK_TYPE_ARRAY_SQUARE_BRACE : Tokens::BLOCK_TYPE_CURLY_BRACE);

                $i = $tokens->findBlockEnd($blockType, $i);

                continue;
            }

            // Nested ternary ?
            if ($token->equals('?')) {
                ++$ternaryDepth;

                continue;
            }

            if ($token->equals(':')) {
                if ($ternaryDepth === 0) {
                    return $i;
                }

                --$ternaryDepth;
            }
        }

        return null;
    }

    private function isNullToken(Token $token): bool
    {
        return $token->isGivenKind(T_STRING) && mb_strtolower($token->getContent()) === 'null';
    }
}
