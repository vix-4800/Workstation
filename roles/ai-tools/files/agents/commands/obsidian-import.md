---
allowed-tools: Read, Write, Edit, Glob, Grep
description: Analyse a raw Obsidian note and distribute its content into structured, interlinked vault notes
---

# Obsidian Note Import

Use the `obsidian` skill throughout this task for all note formatting, frontmatter, wikilinks, callouts, and tags.

**Source note:** $ARGUMENTS

## Step 1: Read the source note

Read `$ARGUMENTS.md`. If not found at that exact path, search the vault for a file matching that name and read it from wherever it is.

## Step 2: Analyse the content

- Identify all distinct topics, concepts, and subject areas in the note.
- Extract key points, arguments, and conclusions for each topic.
- Group related points together.
- Note which topics belong to different domains and must not be merged.

## Step 3: Plan target notes

For each identified topic:

1. Search the vault for existing notes that already cover this topic or closely related material.
2. If an existing note covers the topic — plan to extend it, not replace it.
3. If the topic extends an existing area but goes beyond a single existing note — plan to create a new note with links to and from the existing one.
4. If the topic has no coverage in the vault — plan a new standalone note.

Do not put all extracted content into one note. Topics from different domains must become separate notes.

## Step 4: Create or update notes

For each topic, write or extend the target note using the `obsidian` skill:

- Add frontmatter: `tags`, `aliases` (if the note may be referenced by alternative names).
- Use headings for structure. No walls of text.
- Use bullet points and numbered lists for enumerations and steps.
- Use callouts (`> [!note]`, `> [!important]`, `> [!warning]`) for key conclusions and critical caveats.
- Use wikilinks `[[Note Name]]` for cross-references within the vault.
- When updating an existing note: preserve its existing structure and content; append or insert only what is new.

## Step 5: Wire the new notes into the vault

After all notes are written or updated:

1. **Search for existing mentions without links** — grep the vault for plain-text mentions of the new topic names. Wherever a mention exists without a wikilink, add `[[Note Name]]`.
2. **Identify thematically adjacent notes** — search for notes covering related domains. Add bidirectional wikilinks where the connection is logical and meaningful.
   - Example: a new Git note connects to CI/CD, GitFlow, branching strategies — not to PHP or OOP.
   - Example: a new note on caching connects to Redis, performance, database optimisation — not to front-end frameworks.
3. **Only add links that make logical sense in context.** Do not link every mention. Do not link to notes where the topic is only tangentially related.

## Completion

State which notes were created, which were updated, and which existing notes received new links. One sentence per item.
