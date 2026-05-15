<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\Fixer\WhitespacesAwareFixerInterface;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class FluentChainLineBreaksFixer extends AbstractFixer implements WhitespacesAwareFixerInterface
{
    /**
     * Returns fixer name used in php-cs-fixer config.
     */
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/fluent_chain_line_breaks';
    }

    /**
     * Describes fixer purpose and provides a representative sample.
     */
    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Splits multiline fluent chains so each chained method call starts on its own line.',
            [
                new CodeSample(
                    "<?php\n\nLinkHelpDeskCategoryResponsibles::find()->where(\n    ['category_id' => \$this->category_id, 'responsible_id' => Yii::\$app->user->id],\n)->exists();\n"
                ),
            ],
            'When a fluent chain already spans multiple lines, each chained call is moved to its own line. '
                . 'Single-line chains are left untouched.'
        );
    }

    /**
     * Performs a cheap pre-check before the fixer runs.
     */
    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAnyTokenKindsFound([T_OBJECT_OPERATOR, T_NULLSAFE_OBJECT_OPERATOR]);
    }

    /**
     * Runs before built-in whitespace fixers so they can polish the final layout.
     */
    #[Override]
    public function getPriority(): int
    {
        return 10;
    }

    /**
     * Splits multiline fluent chains and compacts argument wrappers when that is safe.
     */
    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        $collector = new FluentChainCollector($tokens);
        $formatter = new FluentChainWhitespaceFormatter(
            $tokens,
            $this->whitespacesConfig->getLineEnding(),
            $this->whitespacesConfig->getIndent()
        );

        do {
            $chains = $collector->collectChains();
            $hasChanges = false;

            for ($chainIndex = count($chains) - 1; $chainIndex >= 0; --$chainIndex) {
                $chain = $chains[$chainIndex];

                if (!$collector->shouldFormatChain($chain['start'], $chain['end'])) {
                    continue;
                }

                $targetWhitespace = $collector->detectChainIndentation($chain['start'])
                    . $this->whitespacesConfig->getIndent();

                for ($callIndex = count($chain['calls']) - 1; $callIndex >= 0; --$callIndex) {
                    $call = $chain['calls'][$callIndex];

                    $hasChanges = $formatter->compactArgumentsIfPossible($call['open'], $call['close']) || $hasChanges;
                    $hasChanges = $formatter->ensureLineBreakBeforeOperator($call['operator'], $targetWhitespace) || $hasChanges;
                }

                if ($hasChanges) {
                    break;
                }
            }
        } while ($hasChanges);
    }
}
