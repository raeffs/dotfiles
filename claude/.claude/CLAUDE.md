## Writing Guidelines

- Use the orwell-writing skill for all answers and generated content.

## Coding Guidelines

- Don't add comments that explain what the code does. The code should explain itself.

## Git Workflow

- Assume the default branch is protected, unless explicitly specified.
- Don't commit, unless the user asks you to do so.
- When committing, don't add a commit body. Use a commit subject only.
- Use conventional commit messages.
- Don't create pull requests, unless the user asks you to do so.

## Data Hygiene

- Never put data with real identifying information in commits, fixtures, tests, docs or issue trackers. Replace them with made-up placeholders.

## Plan Execution

When a superpowers plan is complete and the skill asks which execution approach I prefer, offer these four options instead of the default two:

1. **Subagent-driven with manual review** - The standard subagent-driven flow. After the task reviewer passes a task, stop and let me review that task's commits before the next task starts. If I ask for changes, apply them and amend the task's commit.
2. **Subagent-driven** - The standard subagent-driven flow with no pause between tasks.
3. **Native with manual review** - The standard inline flow. After each task's commit, stop and let me review it before the next task starts. If I ask for changes, apply them and amend the task's commit.
4. **Native** - The standard inline flow with no pause between tasks.

Choosing any of these options is my permission to commit during that execution.

@os.md
