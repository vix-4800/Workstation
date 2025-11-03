/**
 * Commitlint configuration
 * Follows Conventional Commits specification
 * @see https://commitlint.js.org/
 * @see https://www.conventionalcommits.org/
 */

module.exports = {
  extends: ['@commitlint/config-conventional'],

  rules: {
    // Type enum - allowed commit types
    'type-enum': [
      2,
      'always',
      [
        'feat', // New feature
        'fix', // Bug fix
        'docs', // Documentation only changes
        'style', // Changes that don't affect code meaning (formatting, whitespace, etc.)
        'refactor', // Code change that neither fixes a bug nor adds a feature
        'perf', // Performance improvement
        'test', // Adding missing tests or correcting existing tests
        'build', // Changes that affect the build system or external dependencies
        'ci', // Changes to CI configuration files and scripts
        'chore', // Other changes that don't modify src or test files
        'revert', // Reverts a previous commit
        'wip', // Work in progress (use sparingly)
      ],
    ],

    // Type case - must be lowercase
    'type-case': [2, 'always', 'lower-case'],

    // Type empty - type is required
    'type-empty': [2, 'never'],

    // Scope case - must be lowercase
    'scope-case': [2, 'always', 'lower-case'],

    // Scope empty - scope is optional but recommended
    'scope-empty': [1, 'never'],

    // Subject case - subject should start with lowercase
    'subject-case': [2, 'always', 'lower-case'],

    // Subject empty - subject is required
    'subject-empty': [2, 'never'],

    // Subject full stop - no period at the end
    'subject-full-stop': [2, 'never', '.'],

    // Subject min/max length
    'subject-min-length': [2, 'always', 3],
    'subject-max-length': [2, 'always', 72],

    // Header max length - entire first line
    'header-max-length': [2, 'always', 100],

    // Body leading blank - require blank line before body
    'body-leading-blank': [2, 'always'],

    // Body max line length
    'body-max-line-length': [2, 'always', 100],

    // Footer leading blank - require blank line before footer
    'footer-leading-blank': [2, 'always'],

    // Footer max line length
    'footer-max-line-length': [2, 'always', 100],
  },

  /*
   * Custom prompt configuration (optional, for commitizen)
   */
  prompt: {
    questions: {
      type: {
        description: "Select the type of change that you're committing",
        enum: {
          feat: {
            description: 'A new feature',
            title: 'Features',
            emoji: '✨',
          },
          fix: {
            description: 'A bug fix',
            title: 'Bug Fixes',
            emoji: '🐛',
          },
          docs: {
            description: 'Documentation only changes',
            title: 'Documentation',
            emoji: '📚',
          },
          style: {
            description: 'Changes that do not affect the meaning of the code',
            title: 'Styles',
            emoji: '💎',
          },
          refactor: {
            description: 'A code change that neither fixes a bug nor adds a feature',
            title: 'Code Refactoring',
            emoji: '📦',
          },
          perf: {
            description: 'A code change that improves performance',
            title: 'Performance Improvements',
            emoji: '🚀',
          },
          test: {
            description: 'Adding missing tests or correcting existing tests',
            title: 'Tests',
            emoji: '🚨',
          },
          build: {
            description: 'Changes that affect the build system or external dependencies',
            title: 'Builds',
            emoji: '🛠',
          },
          ci: {
            description: 'Changes to CI configuration files and scripts',
            title: 'Continuous Integrations',
            emoji: '⚙️',
          },
          chore: {
            description: "Other changes that don't modify src or test files",
            title: 'Chores',
            emoji: '♻️',
          },
          revert: {
            description: 'Reverts a previous commit',
            title: 'Reverts',
            emoji: '🗑',
          },
        },
      },
      scope: {
        description: 'What is the scope of this change (e.g. component, file name, module)',
      },
      subject: {
        description: 'Write a short, imperative tense description of the change',
      },
      body: {
        description: 'Provide a longer description of the change',
      },
      isBreaking: {
        description: 'Are there any breaking changes?',
      },
      breakingBody: {
        description:
          'A BREAKING CHANGE commit requires a body. Please enter a longer description of the commit itself',
      },
      breaking: {
        description: 'Describe the breaking changes',
      },
      isIssueAffected: {
        description: 'Does this change affect any open issues?',
      },
      issuesBody: {
        description:
          'If issues are closed, the commit requires a body. Please enter a longer description of the commit itself',
      },
      issues: {
        description: 'Add issue references (e.g. "fix #123", "re #123")',
      },
    },
  },
};
