<?php

declare(strict_types=1);

namespace VixSniffs\Sniffs\Functions;

use PHP_CodeSniffer\Files\File;
use PHP_CodeSniffer\Sniffs\Sniff;

/**
 * Disallows usage of empty() function in favor of explicit null/empty checks.
 */
class DisallowEmptySniff implements Sniff
{
    /**
     * Returns an array of tokens this test wants to listen for.
     */
    public function register(): array
    {
        return [T_EMPTY];
    }

    /**
     * Processes this test when one of its tokens is encountered.
     */
    public function process(File $phpcsFile, int $stackPtr): void
    {
        $warning = "Usage of empty() is discouraged; use explicit checks (=== null, === '', === [], etc.) instead. "
            . 'empty() has confusing behavior: empty(0), empty("0"), empty(false) all return true.';

        $phpcsFile->addWarning($warning, $stackPtr, 'Found');
    }
}
