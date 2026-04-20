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

/**
 * Splits PHPDoc @throws union types into separate @throws tags.
 */
final class PhpDocSeparateThrowsFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/phpdoc_separate_throws';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'PHPDoc @throws tags must list one exception type per tag.',
            [
                new CodeSample(
                    "<?php\n/**\n * @throws RuntimeException|LogicException\n */\nfunction foo(): void {}\n"
                ),
            ],
            'Splits `@throws A|B` into two consecutive `@throws` tags.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_DOC_COMMENT);
    }

    #[Override]
    public function getPriority(): int
    {
        // Run before phpdoc_align/phpdoc_order so built-in fixers normalize result.
        return 9;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind(T_DOC_COMMENT)) {
                continue;
            }

            $original = $tokens[$index]->getContent();
            $fixed = $this->separateThrowsTags($original);

            if ($fixed !== $original) {
                $tokens[$index] = new Token([T_DOC_COMMENT, $fixed]);
            }
        }
    }

    private function separateThrowsTags(string $docComment): string
    {
        $lines = explode("\n", $docComment);
        $result = [];

        foreach ($lines as $line) {
            $splitLines = $this->splitThrowsLine($line);

            foreach ($splitLines as $splitLine) {
                $result[] = $splitLine;
            }
        }

        return implode("\n", $result);
    }

    /**
     * @param string $line
     *
     * @return list<string>
     */
    private function splitThrowsLine(string $line): array
    {
        if (preg_match('/^([ \t]*\*[ \t]*@throws[ \t]+)(\S+)(.*)$/', mb_ltrim($line, " \t")) !== 1) {
            return [$line];
        }

        preg_match('/^([ \t]*)(\*[ \t]*@throws[ \t]+)(\S+)(.*)$/', $line, $matches);

        if ($matches === []) {
            return [$line];
        }

        $indent = $matches[1];
        $tagPrefix = $matches[2];
        $type = $matches[3];
        $description = $matches[4];
        $types = $this->splitUnionType($type);

        if (count($types) < 2) {
            return [$line];
        }

        return array_map(
            static fn(string $singleType): string => $indent . $tagPrefix . $singleType . $description,
            $types
        );
    }

    /**
     * @param string $type
     *
     * @return list<string>
     */
    private function splitUnionType(string $type): array
    {
        $parts = [];
        $current = '';
        $depth = 0;
        $length = mb_strlen($type);

        for ($index = 0; $index < $length; ++$index) {
            $char = mb_substr($type, $index, 1);

            if ($char === '<' || $char === '(' || $char === '[' || $char === '{') {
                ++$depth;
            } elseif ($char === '>' || $char === ')' || $char === ']' || $char === '}') {
                $depth = max(0, $depth - 1);
            }

            if ($char === '|' && $depth === 0) {
                $part = mb_trim($current);

                if ($part !== '') {
                    $parts[] = $part;
                }

                $current = '';

                continue;
            }

            $current .= $char;
        }

        $part = mb_trim($current);

        if ($part !== '') {
            $parts[] = $part;
        }

        return $parts;
    }
}
