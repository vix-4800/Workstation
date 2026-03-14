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
 * Replaces the class name with `self` in PHPDoc type annotations
 * (var, param, return, property, property-read, property-write, throws, type)
 * whenever the annotation is inside the definition of that very class.
 *
 * Only exact short-name matches are replaced (word-boundary check).
 * Fully-qualified names (e.g. \Foo\Bar) are intentionally left alone.
 */
final class PhpDocSelfReferenceFixer extends AbstractFixer
{
    #[Override]
    public function getName(): string
    {
        return 'CustomFixer/phpdoc_self_reference';
    }

    public function getDefinition(): FixerDefinitionInterface
    {
        return new FixerDefinition(
            'Inside a class, replaces the class name with `self` in PHPDoc type annotations.',
            [
                new CodeSample(
                    "<?php\nclass Foo {\n    /** @var Foo */\n    private Foo \$instance;\n}\n"
                ),
            ],
            'Only unqualified short names are replaced. FQCNs (\Foo\Bar) are kept as-is.'
        );
    }

    public function isCandidate(Tokens $tokens): bool
    {
        return $tokens->isTokenKindFound(T_DOC_COMMENT)
            && $tokens->isTokenKindFound(T_CLASS);
    }

    #[Override]
    public function getPriority(): int
    {
        return 0;
    }

    protected function applyFix(SplFileInfo $file, Tokens $tokens): void
    {
        // Build a map of: doc-comment token index → class short name
        // by tracking class context as we walk the token stream.
        $classStack = []; // stack of ['name' => string, 'braceDepth' => int]
        $braceDepth = 0;

        for ($i = 0, $count = $tokens->count(); $i < $count; ++$i) {
            $token = $tokens[$i];

            if ($token->equals('{')) {
                ++$braceDepth;

                continue;
            }

            if ($token->equals('}')) {
                --$braceDepth;

                // Pop any class whose body just closed
                if ($classStack !== [] && end($classStack)['braceDepth'] === $braceDepth) {
                    array_pop($classStack);
                }

                continue;
            }

            // Track class / interface / trait / enum entering
            if ($token->isGivenKind([T_CLASS, T_INTERFACE, T_TRAIT, T_ENUM])) {
                $nameIndex = $tokens->getNextMeaningfulToken($i);

                if ($nameIndex !== null && $tokens[$nameIndex]->isGivenKind(T_STRING)) {
                    $classStack[] = [
                        'name' => $tokens[$nameIndex]->getContent(),
                        'braceDepth' => $braceDepth, // depth at which the '{' will settle
                    ];
                }

                continue;
            }

            // Process doc comments only when we're inside a class body
            if (!$token->isGivenKind(T_DOC_COMMENT)) {
                continue;
            }

            if ($classStack === []) {
                continue;
            }

            $className = end($classStack)['name'];
            $fixed = $this->replaceClassNameInDocComment($token->getContent(), $className);

            if ($fixed !== $token->getContent()) {
                $tokens[$i] = new Token([T_DOC_COMMENT, $fixed]);
            }
        }
    }

    private function replaceClassNameInDocComment(string $docComment, string $className): string
    {
        // Match PHPDoc tag lines that contain a type:
        //   @var, @param, @return, @property(-read|-write), @throws, @type
        //
        // The type field may be a union (Foo|null), intersection (Foo&Bar),
        // or generic (list<Foo>). We replace whole-word occurrences of $className
        // that are NOT preceded by a backslash (to leave FQCNs alone).
        return preg_replace_callback(
            '/(@(?:var|param|return|property(?:-read|-write)?|throws|type))\s+([^\s*]+)/i',
            static function (array $m) use ($className): string {
                $tag = $m[1];
                $type = $m[2];

                // Word-boundary replacement that skips FQCN tokens (preceded by \)
                $replaced = preg_replace(
                    '/(?<![\\\\\w])' . preg_quote($className, '/') . '(?![\w\\\])/i',
                    'self',
                    $type
                );

                return $tag . ' ' . $replaced;
            },
            $docComment
        ) ?? $docComment;
    }
}
