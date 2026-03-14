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

final class IssetCoalesceFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/isset_coalesce';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Simplifies null coalescing comparisons to isset/!isset when semantically equivalent.',
            [
                new CodeSample(
                    "<?php\nif ((\$chat['poll'] ?? null) !== null) {}\nif (null === (\$value ?? null)) {}\n"
                ),
            ],
            'Transforms (... ?? null) !== null to isset(...) and (... ?? null) === null to !isset(...) for cleaner code.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAllTokenKindsFound([T_COALESCE, T_IS_IDENTICAL]);
    }

    #[Override]
    public function getPriority(): int
    {
        // Run after no_yoda_comparison to work with normalized comparisons
        return -15;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            $token = $tokens[$index];

            // Look for strict comparison operators
            if (!$token->isGivenKind([T_IS_IDENTICAL, T_IS_NOT_IDENTICAL])) {
                continue;
            }

            $this->fixCoalesceComparison($tokens, $index);
        }
    }

    private function fixCoalesceComparison(Tokens $tokens, int $operatorIndex): void
    {
        $leftEnd = $tokens->getPrevMeaningfulToken($operatorIndex);
        $rightStart = $tokens->getNextMeaningfulToken($operatorIndex);

        if ($leftEnd === null || $rightStart === null) {
            return;
        }

        // Try pattern 1: (... ?? null) !== null or (... ?? null) === null
        if ($this->isNull($tokens, $rightStart)) {
            $this->tryReplaceCoalesceWithIsset($tokens, $operatorIndex, $leftEnd, true);

            return;
        }

        // Try pattern 2: null !== (... ?? null) or null === (... ?? null)
        if ($this->isNull($tokens, $leftEnd)) {
            $this->tryReplaceCoalesceWithIsset($tokens, $operatorIndex, $rightStart, false);

            return;
        }
    }

    private function tryReplaceCoalesceWithIsset(
        Tokens $tokens,
        int $operatorIndex,
        int $coalesceEndIndex,
        bool $isLeftOperand
    ): void {
        // Check if the operand ends with closing parenthesis
        if (!$tokens[$coalesceEndIndex]->equals(')')) {
            return;
        }

        // Find matching opening parenthesis
        $parenStart = $this->findMatchingOpenParenthesis($tokens, $coalesceEndIndex);

        if ($parenStart === null) {
            return;
        }

        // Parse the content inside parentheses to find coalesce operator
        $coalesceInfo = $this->parseCoalesceExpression($tokens, $parenStart, $coalesceEndIndex);

        if ($coalesceInfo === null) {
            return;
        }

        // Verify fallback is exactly null
        if (!$this->isNull($tokens, $coalesceInfo['fallback_start'])) {
            return;
        }

        // Verify expression is safe for isset
        if (!$this->isSafeForIsset($tokens, $coalesceInfo['expr_start'], $coalesceInfo['expr_end'])) {
            return;
        }

        // Determine if we need negation
        $operator = $tokens[$operatorIndex];
        $needsNegation = $operator->isGivenKind(T_IS_IDENTICAL); // === null means !isset

        // Build replacement
        $this->buildIssetReplacement(
            $tokens,
            $operatorIndex,
            $parenStart,
            $coalesceEndIndex,
            $coalesceInfo['expr_start'],
            $coalesceInfo['expr_end'],
            $needsNegation,
            $isLeftOperand
        );
    }

    private function findMatchingOpenParenthesis(Tokens $tokens, int $closeIndex): ?int
    {
        $depth = 1;

        for ($i = $closeIndex - 1; $i >= 0; --$i) {
            if ($tokens[$i]->equals(')')) {
                ++$depth;
            } elseif ($tokens[$i]->equals('(')) {
                --$depth;

                if ($depth === 0) {
                    return $i;
                }
            }
        }

        return null;
    }

    private function parseCoalesceExpression(Tokens $tokens, int $start, int $end): ?array
    {
        $coalesceIndex = null;
        $depth = 0;

        // Find the coalesce operator at the same nesting level
        for ($i = $start + 1; $i < $end; ++$i) {
            if ($tokens[$i]->equals('(') || $tokens[$i]->equals('[') || $tokens[$i]->equals('{')) {
                ++$depth;
            } elseif ($tokens[$i]->equals(')') || $tokens[$i]->equals(']') || $tokens[$i]->equals('}')) {
                --$depth;
            } elseif ($depth === 0 && $tokens[$i]->isGivenKind(T_COALESCE)) {
                $coalesceIndex = $i;

                break;
            }
        }

        if ($coalesceIndex === null) {
            return null;
        }

        // Find boundaries of expression (left of ??)
        $exprStart = $tokens->getNextMeaningfulToken($start);
        $exprEnd = $tokens->getPrevMeaningfulToken($coalesceIndex);

        // Find start of fallback (right of ??)
        $fallbackStart = $tokens->getNextMeaningfulToken($coalesceIndex);

        if ($exprStart === null || $exprEnd === null || $fallbackStart === null) {
            return null;
        }

        return [
            'coalesce_index' => $coalesceIndex,
            'expr_start' => $exprStart,
            'expr_end' => $exprEnd,
            'fallback_start' => $fallbackStart,
        ];
    }

    private function isNull(Tokens $tokens, int $index): bool
    {
        $token = $tokens[$index];

        if (!$token->isGivenKind(T_STRING)) {
            return false;
        }

        return mb_strtolower($token->getContent()) === 'null';
    }

    private function isSafeForIsset(Tokens $tokens, int $start, int $end): bool
    {
        // isset() only works with: variables, array/object access, nullsafe operator chains
        // It does NOT work with: function calls, operators, literals, etc.

        $meaningfulTokens = [];

        for ($i = $start; $i <= $end; ++$i) {
            if (!$tokens[$i]->isWhitespace() && !$tokens[$i]->isComment()) {
                $meaningfulTokens[] = $i;
            }
        }

        if ($meaningfulTokens === []) {
            return false;
        }

        // First token should be a variable
        $firstToken = $tokens[$meaningfulTokens[0]];

        if (!$firstToken->isGivenKind(T_VARIABLE)) {
            return false;
        }

        // Check remaining tokens - only allow safe isset constructs
        $allowedKinds = [
            T_VARIABLE,
            T_OBJECT_OPERATOR,      // ->
            T_NULLSAFE_OBJECT_OPERATOR, // ?->
            T_DOUBLE_COLON,         // ::
            T_STRING,               // property/method names
            '[',                    // array access
            ']',
        ];

        for ($i = 1; $i < count($meaningfulTokens); ++$i) {
            $tokenIndex = $meaningfulTokens[$i];
            $token = $tokens[$tokenIndex];

            // Check if token is allowed
            $isAllowed = false;

            foreach ($allowedKinds as $kind) {
                if (is_string($kind)) {
                    if ($token->equals($kind)) {
                        $isAllowed = true;

                        break;
                    }
                } elseif ($token->isGivenKind($kind)) {
                    $isAllowed = true;

                    break;
                }
            }

            // Allow numeric and string literals only for array/object access
            if (!$isAllowed && $token->isGivenKind([T_LNUMBER, T_DNUMBER, T_CONSTANT_ENCAPSED_STRING])) {
                $isAllowed = true;
            }

            if (!$isAllowed) {
                return false;
            }

            // Disallow function calls (string followed by opening parenthesis)
            if ($token->isGivenKind(T_STRING)) {
                $nextMeaningful = $tokens->getNextMeaningfulToken($tokenIndex);

                if ($nextMeaningful !== null && $tokens[$nextMeaningful]->equals('(')) {
                    return false;
                }
            }
        }

        return true;
    }

    private function buildIssetReplacement(
        Tokens $tokens,
        int $operatorIndex,
        int $parenStart,
        int $parenEnd,
        int $exprStart,
        int $exprEnd,
        bool $needsNegation,
        bool $isLeftOperand
    ): void {
        // Extract the expression tokens
        $exprTokens = [];

        for ($i = $exprStart; $i <= $exprEnd; ++$i) {
            $exprTokens[] = clone $tokens[$i];
        }

        // Build isset(...) or !isset(...)
        $replacement = [];

        if ($needsNegation) {
            $replacement[] = new Token([T_STRING, '!isset']);
        } else {
            $replacement[] = new Token([T_STRING, 'isset']);
        }

        $replacement[] = new Token('(');
        $replacement = array_merge($replacement, $exprTokens);
        $replacement[] = new Token(')');

        if ($isLeftOperand) {
            // Replace from parenStart to end of null operand
            $nullIndex = $tokens->getNextMeaningfulToken($operatorIndex);
            $replacementEnd = $nullIndex;
        } else {
            // Replace from start of null operand to parenEnd
            $nullIndex = $tokens->getPrevMeaningfulToken($operatorIndex);
            $replacementEnd = $parenEnd;
            $parenStart = $nullIndex;
        }

        // Clear the range and insert replacement
        $tokens->clearRange($parenStart, $replacementEnd);
        $tokens->insertAt($parenStart, $replacement);
    }
}
