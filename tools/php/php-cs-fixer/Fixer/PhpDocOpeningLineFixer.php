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
 * Ensures multi-line PHPDoc blocks start with /** on its own line.
 */
final class PhpDocOpeningLineFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/phpdoc_opening_line';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Multi-line PHPDoc comments must have `/**` on its own line.',
            [
                new CodeSample(
                    "<?php\n/** Hello\n * World!\n */\nfunction foo(): void {}\n"
                ),
            ],
            'When a PHPDoc block spans multiple lines, the opening `/**` must be on its own line. '
                . 'Single-line `/** ... */` blocks are not affected.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_DOC_COMMENT);
    }

    #[Override]
    public function getPriority(): int
    {
        // Run before phpdoc_trim so its output is already clean.
        return 5;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        foreach ($tokens as $index => $token) {
            if (!$token->isGivenKind(T_DOC_COMMENT)) {
                continue;
            }

            $fixed = $this->fixDocComment($token->getContent());

            if ($fixed !== $token->getContent()) {
                $tokens[$index] = new Token([T_DOC_COMMENT, $fixed]);
            }
        }
    }

    private function fixDocComment(string $content): string
    {
        // Only act on multi-line doc comments that have non-whitespace content
        // on the same line as the opening /**.
        //
        // Single-line:  /** description */  → untouched
        // Already good: /**\n * desc\n */   → untouched
        // Needs fix:    /** desc\n * ...\n */ → /**\n * desc\n * ...\n */

        $firstNewline = mb_strpos($content, "\n");

        // No newline → single-line comment, skip.
        if ($firstNewline === false) {
            return $content;
        }

        // Extract the part of the opening line after /**.
        $openingLineContent = mb_substr($content, 3, $firstNewline - 3);

        // If there is no non-whitespace character on the opening line, it's
        // already correctly formatted (/** is alone on its line).
        if (preg_match('/\S/', $openingLineContent) !== 1) {
            return $content;
        }

        $rest = mb_substr($content, $firstNewline);

        // Detect indentation from the first continuation line (e.g. "    * ...")
        // so the new line matches the indentation of the whole block.
        $indent = preg_match('/\n([ \t]*)\*/', $rest, $m) === 1 ? $m[1] : ' ';

        return '/**' . "\n" . $indent . '*' . $openingLineContent . $rest;
    }
}
