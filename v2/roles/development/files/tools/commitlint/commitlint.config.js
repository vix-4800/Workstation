/**
 * Commitlint configuration
 * Follows Conventional Commits specification
 * @see https://commitlint.js.org/
 * @see https://www.conventionalcommits.org/
 */

module.exports = {
  extends: ['@commitlint/config-conventional'],

  rules: {
    // Allowed commit types
    'type-enum': [
      2,
      'always',
      [
        'feat', // New feature
        'fix', // Bug fix
        'docs', // Documentation changes
        'style', // Code style changes (formatting, etc.)
        'refactor', // Code refactoring
        'perf', // Performance improvements
        'test', // Adding or updating tests
        'build', // Build system changes
        'ci', // CI/CD changes
        'chore', // Other changes (maintenance, configs, etc.)
        'revert', // Revert previous commit
        'remove', // Remove code or files
        'add', // Add new files or dependencies
      ],
    ],

    // Subject should not be empty
    'subject-empty': [2, 'never'],

    // Subject should not end with period
    'subject-full-stop': [2, 'never', '.'],

    // Max length for header (type + scope + subject)
    'header-max-length': [2, 'always', 100],

    // Disable subject case requirement (allow any case)
    'subject-case': [0],

    // Scope is optional
    'scope-empty': [0],
  },
};
