<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\Fixer\ConfigurableFixerInterface;
use PhpCsFixer\Fixer\WhitespacesAwareFixerInterface;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolver;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolverInterface;
use PhpCsFixer\FixerConfiguration\FixerOptionBuilder;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class BlankLineAfterStatementFixer extends AbstractFixer implements ConfigurableFixerInterface, WhitespacesAwareFixerInterface
{
    /**
     * @var array<string, mixed>
     */
    protected array $configuration = [];

    private array $tokenKinds = [];

    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/blank_line_after_statement';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'An empty line feed must follow control structures.',
            [
                new CodeSample(
                    "<?php\nif (\$condition) {\n    echo 'foo';\n}\n\$bar = 'baz';\n"
                ),
            ],
            'Adds blank lines after specified control structures for better readability.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isAnyTokenKindsFound($this->tokenKinds);
    }

    public function configure(array $configuration): void
    {
        if ($configuration === []) {
            $configuration = $this->getConfigurationDefinition()->resolve([]);
        }

        $this->configuration = $configuration;

        $this->tokenKinds = $this->transformStatementsToTokenKinds($this->configuration['statements']);
    }

    public function getConfigurationDefinition(): FixerConfigurationResolverInterface
    {
        return $this->createConfigurationDefinition();
    }

    #[Override]
    public function getPriority(): int
    {
        return -25;
    }

    private function createConfigurationDefinition(): FixerConfigurationResolverInterface
    {
        return new FixerConfigurationResolver([
            (new FixerOptionBuilder('statements', 'List of statements that should be followed by a blank line.'))
                ->setAllowedTypes(['array'])
                ->setAllowedValues([
                    static function (array $value): bool {
                        foreach ($value as $statement) {
                            if (!is_string($statement)) {
                                return false;
                            }
                        }

                        return true;
                    },
                ])
                ->setDefault([
                    'do',
                    'for',
                    'foreach',
                    'if',
                    'switch',
                    'try',
                    'while',
                ])
                ->getOption(),
        ]);
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            $token = $tokens[$index];

            if (!$token->isGivenKind($this->tokenKinds)) {
                continue;
            }

            $endIndex = $this->findStatementEnd($tokens, $index);

            if ($endIndex === null) {
                continue;
            }

            $this->ensureBlankLineAfter($tokens, $endIndex);
        }
    }

    private function findStatementEnd(Tokens $tokens, int $startIndex): ?int
    {
        $token = $tokens[$startIndex];

        if ($token->isGivenKind([T_IF, T_ELSEIF, T_FOR, T_FOREACH, T_WHILE, T_SWITCH, T_TRY])) {
            return $this->findBlockEnd($tokens, $startIndex);
        }

        if ($token->isGivenKind(T_DO)) {
            $blockEnd = $this->findBlockEnd($tokens, $startIndex);

            if ($blockEnd === null) {
                return null;
            }

            $whileIndex = $tokens->getNextMeaningfulToken($blockEnd);

            if ($whileIndex === null || !$tokens[$whileIndex]->isGivenKind(T_WHILE)) {
                return $blockEnd;
            }

            $openParenthesis = $tokens->getNextMeaningfulToken($whileIndex);
            $closeParenthesis = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_PARENTHESIS_BRACE, $openParenthesis);

            return $tokens->getNextTokenOfKind($closeParenthesis, [';']);
        }

        if ($token->isGivenKind([T_BREAK, T_CONTINUE, T_RETURN, T_THROW, T_DECLARE])) {
            return $tokens->getNextTokenOfKind($startIndex, [';']);
        }

        return null;
    }

    private function findBlockEnd(Tokens $tokens, int $startIndex): ?int
    {
        $openBraceIndex = $tokens->getNextTokenOfKind($startIndex, ['{']);

        if ($openBraceIndex === null) {
            return $tokens->getNextTokenOfKind($startIndex, [';']);
        }

        $closeBraceIndex = $tokens->findBlockEnd(Tokens::BLOCK_TYPE_CURLY_BRACE, $openBraceIndex);

        $nextMeaningful = $tokens->getNextMeaningfulToken($closeBraceIndex);

        if ($nextMeaningful !== null) {
            $nextToken = $tokens[$nextMeaningful];

            if ($nextToken->isGivenKind([T_ELSE, T_ELSEIF, T_CATCH, T_FINALLY])) {
                return $this->findBlockEnd($tokens, $nextMeaningful);
            }
        }

        return $closeBraceIndex;
    }

    private function ensureBlankLineAfter(Tokens $tokens, int $index): void
    {
        $nextIndex = $index + 1;

        if (!isset($tokens[$nextIndex])) {
            return;
        }

        $nextToken = $tokens[$nextIndex];

        if ($nextToken->isWhitespace() && str_contains($nextToken->getContent(), "\n\n")) {
            return;
        }

        $nextMeaningfulIndex = $tokens->getNextMeaningfulToken($index);

        if ($nextMeaningfulIndex === null) {
            return;
        }

        if ($tokens[$nextMeaningfulIndex]->isGivenKind(T_CLOSE_TAG)) {
            return;
        }

        if ($tokens[$nextMeaningfulIndex]->equals('}')) {
            return;
        }

        $whitespace = '';

        if ($nextToken->isWhitespace()) {
            $whitespace = $nextToken->getContent();
        }

        $newlineCount = mb_substr_count($whitespace, "\n");

        if ($newlineCount < 2) {
            $newWhitespace = $this->whitespacesConfig->getLineEnding();

            if ($newlineCount === 1) {
                $newWhitespace .= $whitespace;
            } elseif ($newlineCount === 0) {
                $newWhitespace .= $this->whitespacesConfig->getLineEnding() . $whitespace;
            }

            if ($nextToken->isWhitespace()) {
                $tokens[$nextIndex] = new Token([T_WHITESPACE, $newWhitespace]);
            } else {
                $tokens->insertAt($nextIndex, new Token([T_WHITESPACE, $newWhitespace]));
            }
        }
    }

    private function transformStatementsToTokenKinds(array $statements): array
    {
        $tokenKinds = [];

        $map = [
            'break' => T_BREAK,
            'continue' => T_CONTINUE,
            'declare' => T_DECLARE,
            'do' => T_DO,
            'for' => T_FOR,
            'foreach' => T_FOREACH,
            'if' => T_IF,
            'return' => T_RETURN,
            'switch' => T_SWITCH,
            'throw' => T_THROW,
            'try' => T_TRY,
            'while' => T_WHILE,
            'yield' => T_YIELD,
        ];

        foreach ($statements as $statement) {
            if (isset($map[$statement])) {
                $tokenKinds[] = $map[$statement];
            }
        }

        return $tokenKinds;
    }
}
