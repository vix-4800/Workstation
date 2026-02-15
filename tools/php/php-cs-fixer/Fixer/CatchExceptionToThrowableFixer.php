<?php

declare(strict_types=1);

namespace CustomFixer;

use PhpCsFixer\AbstractFixer;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class CatchExceptionToThrowableFixer extends AbstractFixer
{
    /**
     * @var array<string, true>
     */
    private array $exceptionAliases = [];

    public function getName(): string
    {
        return 'CustomFixer/catch_exception_to_throwable';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Replaces Exception with Throwable in catch blocks, including imported aliases to Exception.',
            [
                new CodeSample(
                    "<?php\nuse Exception as E;\n\ntry {\n    doWork();\n} catch (Exception|E $e) {\n    report($e);\n}\n"
                ),
            ],
            'Prefers Throwable catches instead of Exception for broader and consistent handling.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAnyTokenKindsFound([T_CATCH, T_USE]);
    }

    public function getPriority(): int
    {
        return 0;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        $this->exceptionAliases = $this->collectExceptionAliases($tokens);

        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind(T_CATCH)) {
                continue;
            }

            $this->fixCatchTypes($tokens, $index);
        }
    }

    /**
     * @return array<string, true>
     */
    private function collectExceptionAliases(Tokens $tokens): array
    {
        $aliases = [];
        $curlyDepth = 0;

        for ($index = 0; $index < $tokens->count(); ++$index) {
            $token = $tokens[$index];

            if ($token->equals('{')) {
                ++$curlyDepth;
                continue;
            }

            if ($token->equals('}')) {
                $curlyDepth = max(0, $curlyDepth - 1);
                continue;
            }

            if ($curlyDepth > 0 || !$token->isGivenKind(T_USE)) {
                continue;
            }

            $statementEnd = $tokens->getNextTokenOfKind($index, [';']);

            if (null === $statementEnd) {
                continue;
            }

            $segmentStart = $tokens->getNextMeaningfulToken($index);

            if (null === $segmentStart || $segmentStart >= $statementEnd) {
                $index = $statementEnd;
                continue;
            }

            if ($tokens[$segmentStart]->isGivenKind([T_FUNCTION, T_CONST])) {
                $index = $statementEnd;
                continue;
            }

            if ($this->hasGroupUseSyntax($tokens, $segmentStart, $statementEnd)) {
                $index = $statementEnd;
                continue;
            }

            $currentStart = $segmentStart;
            for ($i = $segmentStart; $i < $statementEnd; ++$i) {
                if (!$tokens[$i]->equals(',')) {
                    continue;
                }

                $this->collectAliasFromUseSegment($tokens, $currentStart, $i - 1, $aliases);
                $currentStart = $i + 1;
            }

            $this->collectAliasFromUseSegment($tokens, $currentStart, $statementEnd - 1, $aliases);
            $index = $statementEnd;
        }

        return $aliases;
    }

    private function hasGroupUseSyntax(Tokens $tokens, int $start, int $end): bool
    {
        for ($i = $start; $i < $end; ++$i) {
            if ($tokens[$i]->equals('{')) {
                return true;
            }
        }

        return false;
    }

    /**
     * @param array<string, true> $aliases
     */
    private function collectAliasFromUseSegment(Tokens $tokens, int $start, int $end, array &$aliases): void
    {
        $firstMeaningful = $this->findNextMeaningfulInRange($tokens, $start, $end);

        if (null === $firstMeaningful) {
            return;
        }

        $asIndex = null;
        for ($i = $firstMeaningful; $i <= $end; ++$i) {
            if ($tokens[$i]->isGivenKind(T_AS)) {
                $asIndex = $i;
                break;
            }
        }

        $nameEnd = null !== $asIndex
            ? $this->findPrevMeaningfulInRange($tokens, $asIndex - 1, $firstMeaningful)
            : $this->findPrevMeaningfulInRange($tokens, $end, $firstMeaningful);

        if (null === $nameEnd) {
            return;
        }

        $importedName = $this->readTypeName($tokens, $firstMeaningful, $nameEnd);

        if (!$this->isStandardExceptionType($importedName)) {
            return;
        }

        $alias = null;
        if (null !== $asIndex) {
            $aliasIndex = $this->findNextMeaningfulInRange($tokens, $asIndex + 1, $end);

            if (null !== $aliasIndex) {
                $alias = $tokens[$aliasIndex]->getContent();
            }
        }

        if (null === $alias || '' === $alias) {
            $alias = $this->extractShortName($importedName);
        }

        if ('' === $alias) {
            return;
        }

        $aliases[strtolower($alias)] = true;
    }

    private function fixCatchTypes(Tokens $tokens, int $catchIndex): void
    {
        $openParenthesis = $tokens->getNextMeaningfulToken($catchIndex);

        if (null === $openParenthesis || !$tokens[$openParenthesis]->equals('(')) {
            return;
        }

        $closeParenthesis = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $openParenthesis);
        $firstMeaningful = $tokens->getNextMeaningfulToken($openParenthesis);

        if (null === $firstMeaningful || $firstMeaningful >= $closeParenthesis) {
            return;
        }

        $variableIndex = null;
        for ($i = $firstMeaningful; $i < $closeParenthesis; ++$i) {
            if ($tokens[$i]->isGivenKind(T_VARIABLE)) {
                $variableIndex = $i;
                break;
            }
        }

        $typeEnd = null !== $variableIndex
            ? $this->findPrevMeaningfulInRange($tokens, $variableIndex - 1, $firstMeaningful)
            : $this->findPrevMeaningfulInRange($tokens, $closeParenthesis - 1, $firstMeaningful);

        if (null === $typeEnd || $typeEnd < $firstMeaningful) {
            return;
        }

        $atoms = $this->collectTypeAtoms($tokens, $firstMeaningful, $typeEnd);

        if ([] === $atoms) {
            return;
        }

        $replacement = [];
        $seen = [];
        $changed = false;

        foreach ($atoms as $atom) {
            $atomText = $this->readTypeName($tokens, $atom['start'], $atom['end']);
            $normalizedAtom = $this->normalizeTypeName($atomText);

            if ('throwable' !== $normalizedAtom && $this->isExceptionReference($atomText)) {
                $atomTokens = [new Token([T_STRING, 'Throwable'])];
                $normalizedAtom = 'throwable';
                $changed = true;
            } else {
                $atomTokens = $this->cloneTokenRange($tokens, $atom['start'], $atom['end']);
            }

            if (isset($seen[$normalizedAtom])) {
                $changed = true;
                continue;
            }

            $seen[$normalizedAtom] = true;
            $replacement[] = $atomTokens;
        }

        if (!$changed) {
            return;
        }

        $flattened = [];
        foreach ($replacement as $index => $atomTokens) {
            if ($index > 0) {
                $flattened[] = new Token('|');
            }

            foreach ($atomTokens as $atomToken) {
                $flattened[] = $atomToken;
            }
        }

        $tokens->clearRange($firstMeaningful, $typeEnd);
        $tokens->insertAt($firstMeaningful, $flattened);
    }

    /**
     * @return list<array{start: int, end: int}>
     */
    private function collectTypeAtoms(Tokens $tokens, int $start, int $end): array
    {
        $atoms = [];
        $atomStart = null;
        $atomEnd = null;

        for ($i = $start; $i <= $end; ++$i) {
            $token = $tokens[$i];

            if ($token->isWhitespace() || $token->isComment()) {
                continue;
            }

            if ($token->equals('|')) {
                if (null !== $atomStart && null !== $atomEnd) {
                    $atoms[] = ['start' => $atomStart, 'end' => $atomEnd];
                }

                $atomStart = null;
                $atomEnd = null;
                continue;
            }

            if (null === $atomStart) {
                $atomStart = $i;
            }

            $atomEnd = $i;
        }

        if (null !== $atomStart && null !== $atomEnd) {
            $atoms[] = ['start' => $atomStart, 'end' => $atomEnd];
        }

        return $atoms;
    }

    private function isExceptionReference(string $typeName): bool
    {
        $normalized = $this->normalizeTypeName($typeName);

        if ('exception' === $normalized) {
            return true;
        }

        if (str_contains($normalized, '\\')) {
            return false;
        }

        return isset($this->exceptionAliases[$normalized]);
    }

    private function isStandardExceptionType(string $typeName): bool
    {
        return 'exception' === $this->normalizeTypeName($typeName);
    }

    private function normalizeTypeName(string $typeName): string
    {
        $name = trim($typeName);
        $name = ltrim($name, '\\');

        return strtolower($name);
    }

    private function extractShortName(string $name): string
    {
        $trimmed = ltrim(trim($name), '\\');

        if ('' === $trimmed) {
            return '';
        }

        $parts = explode('\\', $trimmed);

        return (string) end($parts);
    }

    private function readTypeName(Tokens $tokens, int $start, int $end): string
    {
        $content = '';

        for ($i = $start; $i <= $end; ++$i) {
            $token = $tokens[$i];

            if ($token->isWhitespace() || $token->isComment()) {
                continue;
            }

            $content .= $token->getContent();
        }

        return $content;
    }

    /**
     * @return list<Token>
     */
    private function cloneTokenRange(Tokens $tokens, int $start, int $end): array
    {
        $cloned = [];

        for ($i = $start; $i <= $end; ++$i) {
            $token = $tokens[$i];

            if ($token->isWhitespace() || $token->isComment()) {
                continue;
            }

            $cloned[] = clone $token;
        }

        return $cloned;
    }

    private function findNextMeaningfulInRange(Tokens $tokens, int $start, int $end): ?int
    {
        for ($i = $start; $i <= $end; ++$i) {
            if (!$tokens[$i]->isWhitespace() && !$tokens[$i]->isComment()) {
                return $i;
            }
        }

        return null;
    }

    private function findPrevMeaningfulInRange(Tokens $tokens, int $start, int $lowerBound): ?int
    {
        for ($i = $start; $i >= $lowerBound; --$i) {
            if (!$tokens[$i]->isWhitespace() && !$tokens[$i]->isComment()) {
                return $i;
            }
        }

        return null;
    }
}
