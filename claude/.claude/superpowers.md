## Superpowers

### Plan Execution

When a superpowers plan is complete and the skill asks which execution approach I prefer, offer these four options instead of the default two:

1. **Subagent-driven with manual review** - The standard subagent-driven flow. After the task reviewer passes a task, stop and let me review that task's commits before the next task starts. If I ask for changes, apply them and amend the task's commit.
2. **Subagent-driven** - The standard subagent-driven flow with no pause between tasks.
3. **Native with manual review** - The standard inline flow. After each task's commit, stop and let me review it before the next task starts. If I ask for changes, apply them and amend the task's commit.
4. **Native** - The standard inline flow with no pause between tasks.

Choosing any of these options is my permission to commit during that execution.

### Finishing a Development Branch

When the finishing-a-development-branch skill presents its options, keep the other options and replace the pull request option:

- In the standard menu, replace "Push and create a Pull Request" with "Push the branch and give me a PR subject".
- In the detached HEAD menu, replace "Push as new branch and create a Pull Request" with "Push as new branch and give me a PR subject".

If I choose this option, push the branch and give me a subject for the pull request. Do not create the pull request. I create it myself.
