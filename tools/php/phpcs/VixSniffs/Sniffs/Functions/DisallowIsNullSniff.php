<?php

declare(strict_types=1);

namespace VixSniffs\Sniffs\Functions;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Disallows usage of is_null() function in favor of === null comparison.
 */
class DisallowIsNullSniff implements Sniff
{
    /**
     * Returns an array of tokens this test wants to listen for.
     *
     * @return array<int|string>
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

        // Check if the string is "is_null"
        if (mb_strtolower((string) $token['content']) !== 'is_null') {
            return;
        }

        // Check if it's not a method call (previous non-whitespace token should not be object operator or double colon)
        $prevToken = $phpcsFile->findPrevious(T_WHITESPACE, $stackPtr - 1, null, true);

        if ($prevToken !== false) {
            $prevTokenCode = $tokens[$prevToken]['code'];

            if (in_array($prevTokenCode, [T_OBJECT_OPERATOR, T_DOUBLE_COLON], true)) {
                // This is a method call like $obj->is_null() or Class::is_null()
                return;
            }

            // Check if this is a method declaration (previous token is "function")
            if ($prevTokenCode === T_FUNCTION) {
                return;
            }
        }

        // Check if this is actually a function call (next non-whitespace token should be opening parenthesis)
        $nextToken = $phpcsFile->findNext(T_WHITESPACE, $stackPtr + 1, null, true);

        if ($nextToken === false || $tokens[$nextToken]['code'] !== T_OPEN_PARENTHESIS) {
            return;
        }

        $warning = 'Usage of is_null() is discouraged; use strict comparison (=== null) instead';
        $phpcsFile->addWarning($warning, $stackPtr, 'Found');
    }
}
