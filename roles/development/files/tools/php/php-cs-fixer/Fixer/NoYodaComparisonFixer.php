<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\CT;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class NoYodaComparisonFixer extends AbstractFixer
{
    private const array COMPARISON_OPERATORS = [
        T_IS_EQUAL,
        T_IS_NOT_EQUAL,
        T_IS_IDENTICAL,
        T_IS_NOT_IDENTICAL,
        T_IS_SMALLER_OR_EQUAL,
        T_IS_GREATER_OR_EQUAL,
    ];

    private const array LITERAL_TOKEN_KINDS = [
        T_LNUMBER,
        T_DNUMBER,
        T_CONSTANT_ENCAPSED_STRING,
        T_STRING,
    ];

    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/no_yoda_comparison';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Comparisons should be written with the variable on the left side (non-Yoda style).',
            [
                new CodeSample(
                    "<?php\nif (null === \$var) {}\nif (true === \$condition) {}\nif (42 === \$count) {}\n"
                ),
            ],
            'Converts Yoda-style comparisons to standard comparisons for better readability.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAnyTokenKindsFound(self::COMPARISON_OPERATORS);
    }

    #[Override]
    public function getPriority(): int
    {
        return -10;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            $token = $tokens[$index];

            if (!$token->isGivenKind(self::COMPARISON_OPERATORS)) {
                continue;
            }

            $this->fixComparison($tokens, $index);
        }
    }

    private function fixComparison(Tokens $tokens, int $operatorIndex): void
    {
        $leftEnd = $tokens->getPrevMeaningfulToken($operatorIndex);

        if ($leftEnd === null) {
            return;
        }

        $rightStart = $tokens->getNextMeaningfulToken($operatorIndex);

        if ($rightStart === null) {
            return;
        }

        if (!$this->isLiteralOrConstant($tokens, $leftEnd)) {
            return;
        }

        if ($this->isLiteralOrConstant($tokens, $rightStart)) {
            return;
        }

        $leftStartIndex = $this->findExpressionStart($tokens, $leftEnd);
        $rightEndIndex = $this->findExpressionEnd($tokens, $rightStart);

        if ($leftStartIndex === null || $rightEndIndex === null) {
            return;
        }

        $leftTokens = $this->extractTokens($tokens, $leftStartIndex, $leftEnd);
        $rightTokens = $this->extractTokens($tokens, $rightStart, $rightEndIndex);

        $newOperatorToken = $this->getFlippedOperator($tokens[$operatorIndex]);

        $this->replaceTokens($tokens, $leftStartIndex, $rightEndIndex, $rightTokens, $newOperatorToken, $leftTokens);
    }

    private function isLiteralOrConstant(Tokens $tokens, int $index): bool
    {
        $token = $tokens[$index];

        if ($token->isGivenKind(self::LITERAL_TOKEN_KINDS)) {
            if ($token->isGivenKind(T_STRING)) {
                $content = mb_strtolower($token->getContent());

                return in_array($content, ['null', 'true', 'false'], true);
            }

            return true;
        }

        if ($token->isGivenKind(CT::T_ARRAY_SQUARE_BRACE_CLOSE)) {
            $openBrace = $tokens->findBlockStart(Tokens::BLOCK_TYPE_ARRAY_SQUARE_BRACE, $index);

            return $tokens->getPrevMeaningfulToken($openBrace) !== null
                && !$tokens[$tokens->getPrevMeaningfulToken($openBrace)]->isGivenKind(T_VARIABLE);
        }

        return false;
    }

    private function findExpressionStart(Tokens $tokens, int $index): ?int
    {
        $token = $tokens[$index];

        if ($token->isGivenKind(CT::T_ARRAY_SQUARE_BRACE_CLOSE)) {
            return $tokens->findBlockStart(Tokens::BLOCK_TYPE_ARRAY_SQUARE_BRACE, $index);
        }

        if ($token->equals(')')) {
            $start = $tokens->findBlockStart(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $index);
            $prev = $tokens->getPrevMeaningfulToken($start);

            if ($prev !== null && $tokens[$prev]->isGivenKind(T_STRING)) {
                return $prev;
            }

            return $start;
        }

        return $index;
    }

    private function findExpressionEnd(Tokens $tokens, int $index): ?int
    {
        $token = $tokens[$index];

        if ($token->isGivenKind(T_VARIABLE)) {
            return $this->followVariableChain($tokens, $index);
        }

        if ($token->equals('(')) {
            return $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $index);
        }

        if ($token->isGivenKind([T_STRING, T_NS_SEPARATOR])) {
            return $this->followFunctionCallOrConstant($tokens, $index);
        }

        if ($token->isGivenKind(CT::T_ARRAY_SQUARE_BRACE_OPEN)) {
            return $tokens->findBlockEnd(Tokens::BLOCK_TYPE_ARRAY_SQUARE_BRACE, $index);
        }

        if ($token->equals('[')) {
            return $tokens->findBlockEnd(Tokens::BLOCK_TYPE_INDEX_SQUARE_BRACE, $index);
        }

        if ($token->isGivenKind(T_NEW)) {
            return $this->followNewExpression($tokens, $index);
        }

        return $index;
    }

    private function followVariableChain(Tokens $tokens, int $index): int
    {
        $current = $index;

        while (true) {
            $next = $tokens->getNextMeaningfulToken($current);

            if ($next === null) {
                break;
            }

            $nextToken = $tokens[$next];

            if ($nextToken->isGivenKind(T_OBJECT_OPERATOR) || $nextToken->isGivenKind(T_NULLSAFE_OBJECT_OPERATOR)) {
                $propertyOrMethod = $tokens->getNextMeaningfulToken($next);

                if ($propertyOrMethod === null) {
                    break;
                }

                $current = $propertyOrMethod;
                $afterProperty = $tokens->getNextMeaningfulToken($current);

                if ($afterProperty !== null && $tokens[$afterProperty]->equals('(')) {
                    $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $afterProperty);
                }

                continue;
            }

            if ($nextToken->isGivenKind(T_DOUBLE_COLON)) {
                $methodOrConst = $tokens->getNextMeaningfulToken($next);

                if ($methodOrConst === null) {
                    break;
                }

                $current = $methodOrConst;
                $afterMethod = $tokens->getNextMeaningfulToken($current);

                if ($afterMethod !== null && $tokens[$afterMethod]->equals('(')) {
                    $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $afterMethod);
                }

                continue;
            }

            if ($nextToken->equals('[') || $nextToken->isGivenKind(CT::T_ARRAY_INDEX_CURLY_BRACE_OPEN)) {
                $blockType = $nextToken->equals('[')
                    ? Tokens::BLOCK_TYPE_INDEX_SQUARE_BRACE
                    : Tokens::BLOCK_TYPE_ARRAY_INDEX_CURLY_BRACE;
                $current = $tokens->findBlockEnd($blockType, $next);

                continue;
            }

            if ($nextToken->equals('(')) {
                $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $next);

                continue;
            }

            break;
        }

        return $current;
    }

    private function followFunctionCallOrConstant(Tokens $tokens, int $index): int
    {
        $current = $index;

        while (true) {
            $next = $tokens->getNextMeaningfulToken($current);

            if ($next === null) {
                break;
            }

            $nextToken = $tokens[$next];

            if ($nextToken->isGivenKind([T_STRING, T_NS_SEPARATOR])) {
                $current = $next;

                continue;
            }

            if ($nextToken->isGivenKind(T_OBJECT_OPERATOR) || $nextToken->isGivenKind(T_NULLSAFE_OBJECT_OPERATOR)) {
                $propertyOrMethod = $tokens->getNextMeaningfulToken($next);

                if ($propertyOrMethod === null) {
                    break;
                }

                $current = $propertyOrMethod;
                $afterProperty = $tokens->getNextMeaningfulToken($current);

                if ($afterProperty !== null && $tokens[$afterProperty]->equals('(')) {
                    $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $afterProperty);
                }

                continue;
            }

            if ($nextToken->equals('(')) {
                $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $next);

                continue;
            }

            if ($nextToken->isGivenKind(T_DOUBLE_COLON)) {
                $methodOrConst = $tokens->getNextMeaningfulToken($next);

                if ($methodOrConst === null) {
                    break;
                }

                $current = $methodOrConst;

                $afterMethodOrConst = $tokens->getNextMeaningfulToken($current);

                if ($afterMethodOrConst !== null && $tokens[$afterMethodOrConst]->equals('(')) {
                    $current = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $afterMethodOrConst);
                }

                continue;
            }

            if ($nextToken->equals('[') || $nextToken->isGivenKind(CT::T_ARRAY_INDEX_CURLY_BRACE_OPEN)) {
                $blockType = $nextToken->equals('[')
                    ? Tokens::BLOCK_TYPE_INDEX_SQUARE_BRACE
                    : Tokens::BLOCK_TYPE_ARRAY_INDEX_CURLY_BRACE;
                $current = $tokens->findBlockEnd($blockType, $next);

                continue;
            }

            break;
        }

        return $current;
    }

    private function followNewExpression(Tokens $tokens, int $index): int
    {
        $current = $tokens->getNextMeaningfulToken($index);

        if ($current === null) {
            return $index;
        }

        while (true) {
            $next = $tokens->getNextMeaningfulToken($current);

            if ($next === null) {
                break;
            }

            $nextToken = $tokens[$next];

            if ($nextToken->isGivenKind([T_STRING, T_NS_SEPARATOR])) {
                $current = $next;

                continue;
            }

            if ($nextToken->equals('(')) {
                return $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $next);
            }

            break;
        }

        return $current;
    }

    private function extractTokens(Tokens $tokens, int $start, int $end): array
    {
        $extracted = [];

        for ($i = $start; $i <= $end; ++$i) {
            $extracted[] = clone $tokens[$i];
        }

        return $extracted;
    }

    private function getFlippedOperator(Token $token): Token
    {
        $flipped = [
            T_IS_SMALLER_OR_EQUAL => new Token([T_IS_GREATER_OR_EQUAL, '>=']),
            T_IS_GREATER_OR_EQUAL => new Token([T_IS_SMALLER_OR_EQUAL, '<=']),
        ];

        if (isset($flipped[$token->getId()])) {
            return $flipped[$token->getId()];
        }

        if ($token->equals('<')) {
            return new Token('>');
        }

        if ($token->equals('>')) {
            return new Token('<');
        }

        return clone $token;
    }

    private function replaceTokens(
        Tokens $tokens,
        int $start,
        int $end,
        array $newLeftTokens,
        Token $operator,
        array $newRightTokens
    ): void {
        $insertTokens = [];

        foreach ($newLeftTokens as $token) {
            $insertTokens[] = $token;
        }

        $insertTokens[] = new Token([T_WHITESPACE, ' ']);
        $insertTokens[] = $operator;
        $insertTokens[] = new Token([T_WHITESPACE, ' ']);

        foreach ($newRightTokens as $token) {
            $insertTokens[] = $token;
        }

        $tokens->clearRange($start, $end);

        $tokens->insertAt($start, $insertTokens);
    }
}
