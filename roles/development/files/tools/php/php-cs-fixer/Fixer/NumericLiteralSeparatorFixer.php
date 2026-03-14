<?php

declare(strict_types=1);

namespace CustomFixer;

use Override;
use PhpCsFixer\AbstractFixer;
use PhpCsFixer\Fixer\ConfigurableFixerInterface;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolver;
use PhpCsFixer\FixerConfiguration\FixerConfigurationResolverInterface;
use PhpCsFixer\FixerConfiguration\FixerOptionBuilder;
use PhpCsFixer\FixerDefinition\CodeSample;
use PhpCsFixer\FixerDefinition\FixerDefinition;
use PhpCsFixer\FixerDefinition\FixerDefinitionInterface;
use PhpCsFixer\Tokenizer\Token;
use PhpCsFixer\Tokenizer\Tokens;
use SplFileInfo;

final class NumericLiteralSeparatorFixer extends AbstractFixer implements ConfigurableFixerInterface
{
    protected array $configuration = [];

    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/numeric_literal_separator';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Numeric literals should use underscore as thousands separator for better readability.',
            [
                new CodeSample(
                    "<?php\n\$price = 1234567;\n\$count = 1000000;\n"
                ),
            ],
            'Adds underscore separators to numeric literals with configurable minimum digit count.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        if ($tokens->isTokenKindFound(T_LNUMBER)) {
            return true;
        }

        return $tokens->isTokenKindFound(T_DNUMBER);
    }

    public function configure(array $configuration): void
    {
        if ($configuration === []) {
            $configuration = $this->getConfigurationDefinition()->resolve([]);
        }

        $this->configuration = $configuration;
    }

    public function getConfigurationDefinition(): FixerConfigurationResolverInterface
    {
        return $this->createConfigurationDefinition();
    }

    #[Override]
    public function getPriority(): int
    {
        return 0;
    }

    private function createConfigurationDefinition(): FixerConfigurationResolverInterface
    {
        return new FixerConfigurationResolver([
            (new FixerOptionBuilder('min_digits', 'Minimum number of digits before applying separator.'))
                ->setAllowedTypes(['int'])
                ->setDefault(5)
                ->getOption(),
        ]);
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        $minDigits = $this->configuration['min_digits'];

        for ($index = $tokens->count() - 1; $index >= 0; --$index) {
            $token = $tokens[$index];

            if (!$token->isGivenKind([T_LNUMBER, T_DNUMBER])) {
                continue;
            }

            $content = $token->getContent();

            if (str_contains($content, '_')) {
                continue;
            }

            if (preg_match('/^0[xXbBoO]/', $content)) {
                continue;
            }

            if (str_contains($content, '.')) {
                $formatted = $this->formatFloat($content, $minDigits);
            } else {
                $formatted = $this->formatInteger($content, $minDigits);
            }

            if ($formatted !== $content) {
                $tokens[$index] = new Token([$token->getId(), $formatted]);
            }
        }
    }

    private function formatInteger(string $number, int $minDigits): string
    {
        $number = mb_ltrim($number, '0') ?: '0';

        if (mb_strlen($number) < $minDigits) {
            return $number;
        }

        return $this->addSeparators($number);
    }

    private function formatFloat(string $number, int $minDigits): string
    {
        [$intPart, $decimalPart] = explode('.', $number, 2);

        $intPart = mb_ltrim($intPart, '0') ?: '0';

        if (mb_strlen($intPart) >= $minDigits) {
            $intPart = $this->addSeparators($intPart);
        }

        return $intPart . '.' . $decimalPart;
    }

    private function addSeparators(string $number): string
    {
        $reversed = strrev($number);
        $chunks = mb_str_split($reversed, 3);
        $reversed = implode('_', $chunks);

        return strrev($reversed);
    }
}
