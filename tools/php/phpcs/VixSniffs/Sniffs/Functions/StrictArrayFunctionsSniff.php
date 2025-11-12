<?php

declare(strict_types=1);

namespace VixSniffs\Sniffs\Functions;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Requires strict comparison parameter in array functions.
 */
class StrictArrayFunctionsSniff implements Sniff
{
    /**
     * Array functions that should use strict comparison.
     */
    private const FUNCTIONS = [
        'in_array' => 3,        // 3rd parameter
        'array_search' => 3,    // 3rd parameter
        'array_keys' => 3,      // 3rd parameter (for filtering)
    ];

    /**
     * Returns an array of tokens this test wants to listen for.
     */
    public function register(): array
    {
        return [T_STRING];
    }

    /**
     * Processes this test when one of its tokens is encountered.
     */
    public function process(File $phpcsFile, int $stackPtr): void
    {
        $tokens = $phpcsFile->getTokens();
        $token = $tokens[$stackPtr];
        $functionName = strtolower($token['content']);

        // Check if this is one of the functions we care about
        if (!isset(self::FUNCTIONS[$functionName])) {
            return;
        }

        // Check if this is actually a function call
        $nextToken = $phpcsFile->findNext(T_WHITESPACE, $stackPtr + 1, null, true);

        if ($nextToken === false || $tokens[$nextToken]['code'] !== T_OPEN_PARENTHESIS) {
            return;
        }

        // Check if it's not a method call
        $prevToken = $phpcsFile->findPrevious(T_WHITESPACE, $stackPtr - 1, null, true);

        if ($prevToken !== false) {
            $prevTokenCode = $tokens[$prevToken]['code'];

            if ($prevTokenCode === T_OBJECT_OPERATOR || $prevTokenCode === T_DOUBLE_COLON) {
                return;
            }
        }

        // Find the closing parenthesis
        $openParen = $nextToken;
        $closeParen = $tokens[$openParen]['parenthesis_closer'];

        // Count the number of parameters
        $paramCount = $this->countParameters($phpcsFile, $openParen, $closeParen);
        $requiredParamPosition = self::FUNCTIONS[$functionName];

        // Check if the strict parameter is missing
        if ($paramCount < $requiredParamPosition) {
            $warning = sprintf(
                'Function %s() should use strict comparison. Add true as the %s parameter.',
                $functionName,
                $this->getOrdinal($requiredParamPosition),
            );

            $phpcsFile->addWarning($warning, $stackPtr, 'MissingStrict');

            return;
        }

        // Check if the strict parameter is explicitly false
        $strictParamToken = $this->findNthParameter($phpcsFile, $openParen, $closeParen, $requiredParamPosition);

        if ($strictParamToken !== null) {
            $strictValue = strtolower($tokens[$strictParamToken]['content']);

            if ($strictValue === 'false') {
                $warning = sprintf(
                    'Function %s() uses non-strict comparison (false). Use true for strict comparison.',
                    $functionName,
                );

                $phpcsFile->addWarning($warning, $strictParamToken, 'ExplicitNonStrict');
            }
        }
    }

    /**
     * Count the number of parameters in a function call.
     */
    private function countParameters(File $phpcsFile, int $openParen, int $closeParen): int
    {
        $tokens = $phpcsFile->getTokens();
        $paramCount = 0;
        $inParameter = false;
        $depth = 0;

        for ($i = $openParen + 1; $i < $closeParen; $i++) {
            $code = $tokens[$i]['code'];

            if ($code === T_OPEN_PARENTHESIS || $code === T_OPEN_SQUARE_BRACKET) {
                $depth++;
                $inParameter = true;

                continue;
            }

            if ($code === T_CLOSE_PARENTHESIS || $code === T_CLOSE_SQUARE_BRACKET) {
                $depth--;

                continue;
            }

            if ($depth === 0 && $code === T_COMMA) {
                $paramCount++;
                $inParameter = false;

                continue;
            }

            if ($depth === 0 && !$inParameter && $code !== T_WHITESPACE && $code !== T_COMMENT) {
                $inParameter = true;
            }
        }

        // Count the last parameter if we were in one
        if ($inParameter) {
            $paramCount++;
        }

        return $paramCount;
    }

    /**
     * Find the token position of the Nth parameter.
     */
    private function findNthParameter(File $phpcsFile, int $openParen, int $closeParen, int $n): ?int
    {
        $tokens = $phpcsFile->getTokens();
        $currentParam = 1;
        $paramStart = null;
        $depth = 0;

        for ($i = $openParen + 1; $i < $closeParen; $i++) {
            $code = $tokens[$i]['code'];

            if ($code === T_OPEN_PARENTHESIS || $code === T_OPEN_SQUARE_BRACKET) {
                $depth++;

                continue;
            }

            if ($code === T_CLOSE_PARENTHESIS || $code === T_CLOSE_SQUARE_BRACKET) {
                $depth--;

                continue;
            }

            if ($depth === 0 && $code === T_COMMA) {
                $currentParam++;
                $paramStart = null;

                continue;
            }

            if ($depth === 0 && $paramStart === null && $code !== T_WHITESPACE && $code !== T_COMMENT) {
                $paramStart = $i;

                if ($currentParam === $n) {
                    return $i;
                }
            }
        }

        return null;
    }

    /**
     * Convert number to ordinal (1st, 2nd, 3rd, etc.).
     */
    private function getOrdinal(int $number): string
    {
        $suffix = 'th';

        if ($number % 100 < 11 || $number % 100 > 13) {
            switch ($number % 10) {
                case 1:
                    $suffix = 'st';

                    break;
                case 2:
                    $suffix = 'nd';

                    break;
                case 3:
                    $suffix = 'rd';

                    break;
            }
        }

        return $number . $suffix;
    }
}
