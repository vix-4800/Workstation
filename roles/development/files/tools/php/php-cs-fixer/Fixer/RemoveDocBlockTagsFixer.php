<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\Fixer\ConfigurableFixerInterface;
use PhpCsFixer\Fixer\ConfigurableFixerTrait;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolver;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolverInterface;
use PhpCsFixer\FixerConfiguration\FixerOptionBuilder;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

/**
 * Removes configurable unwanted tags from PHPDoc blocks.
 */
final class RemoveDocBlockTagsFixer extends AbstractFixer implements ConfigurableFixerInterface
{
    /** @use ConfigurableFixerTrait<array{tags: list<string>}, array{tags: list<string>}> */
    use ConfigurableFixerTrait;

    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/remove_doc_block_tags';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Removes configurable unwanted tags from PHPDoc blocks.',
            [
                new CodeSample(
                    "<?php\n/**\n * My class.\n *\n * @category  Class\n * @package   Crm\n * @author    User <user@example.com>\n * @copyright 2024 Crm\n * @license   MIT License\n * @link      http://example.com/\n */\nclass Foo {}\n"
                ),
            ],
            'Removes unwanted PHPDoc tags such as @category, @author, @copyright, etc. '
            . 'After removal, empty doc blocks are cleaned up by the no_empty_phpdoc fixer.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_DOC_COMMENT);
    }

    #[Override]
    public function getPriority(): int
    {
        // Must run before:
        //   phpdoc_separation    (priority  3) — re-groups tags with blank lines between groups
        //   phpdoc_trim          (priority  0) — trims leading/trailing blank lines in doc block
        //   phpdoc_no_package    (priority  0) — built-in @package remover (avoid overlap)
        //   no_empty_phpdoc      (priority -10) — removes fully-emptied doc blocks
        return 10;
    }

    protected function createConfigurationDefinition(): FixerConfigurationResolverInterface
    {
        return new FixerConfigurationResolver([
            (new FixerOptionBuilder(
                'tags',
                'List of PHPDoc tag names to remove (without the "@" prefix).'
            ))
                ->setAllowedTypes(['array'])
                ->setDefault([
                    'category',
                    'package',
                    'subpackage',
                    'author',
                    'copyright',
                    'license',
                    'link',
                    'version',
                ])
                ->getOption(),
        ]);
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        $tags = $this->configuration['tags'];

        if ($tags === []) {
            return;
        }

        $tagPattern = implode('|', array_map(
            static fn (string $tag): string => preg_quote($tag, '/'),
            $tags
        ));

        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            if (!$tokens[$index]->isGivenKind(T_DOC_COMMENT)) {
                continue;
            }

            $original = $tokens[$index]->getContent();
            $fixed = $this->stripUnwantedTags($original, $tagPattern);

            if ($fixed !== $original) {
                $tokens[$index] = new Token([T_DOC_COMMENT, $fixed]);
            }
        }
    }

    /**
     * Removes lines belonging to unwanted tags, including any continuation lines.
     *
     * A continuation line is a doc-comment line that does NOT start with "@" and
     * follows directly after a tag line (used for multi-line tag values).
     *
     * @param string $docComment
     * @param string $tagPattern
     */
    private function stripUnwantedTags(string $docComment, string $tagPattern): string
    {
        $lines = explode("\n", $docComment);
        $result = [];
        $skipping = false;

        foreach ($lines as $line) {
            $trimmed = mb_ltrim($line, " \t");

            // Detect a doc-comment body line: starts with "* " or is just "*"
            $isDocLine = str_starts_with($trimmed, '*') && !str_starts_with($trimmed, '*/');

            if ($isDocLine) {
                $afterStar = mb_ltrim(mb_substr($trimmed, 1), " \t");

                if (preg_match('/^@(?:' . $tagPattern . ')(?:\s|$)/i', $afterStar)) {
                    // This line opens an unwanted tag — skip it and any continuation lines
                    $skipping = true;

                    continue;
                }

                // A new "@tag" resets skipping; plain text lines stop continuation too
                if ($skipping) {
                    if (str_starts_with($afterStar, '@')) {
                        // New tag starts — stop skipping and keep this line
                        $skipping = false;
                    } elseif ($afterStar !== '' && $afterStar !== '/') {
                        // Non-empty continuation line belonging to the removed tag
                        continue;
                    } else {
                        // Blank doc line (only " * ") — stop skipping but drop the blank line;
                        // phpdoc_trim will handle any leftover blanks
                        $skipping = false;

                        continue;
                    }
                }
            } else {
                $skipping = false;
            }

            $result[] = $line;
        }

        // Collapse multiple consecutive blank doc lines (" *") into one
        $joined = implode("\n", $result);
        $joined = (string) preg_replace('/(\n[ \t]*\*[ \t]*)(\n[ \t]*\*[ \t]*(?=\n|$))+/', '$1', $joined);

        // Remove a leading blank line right after "/**"
        return (string) preg_replace('/^(\/\*\*)(\n[ \t]*\*[ \t]*\n)/', "$1\n", $joined);
    }
}
