# Agentic Skills

This repository contains reusable skills for coding agents, including tools that support agent-compatible skill directories such as Codex and OpenCode.

Each skill lives in its own directory and is authored as a `SKILL.md`. That file is the source of truth and should follow the guidance from the skill.md standard site at `agentskills.io`.

## Purpose

Treat skills as small, portable building blocks for agent behavior. This repo is where they are developed and from which they are installed into agent-compatible skill directories plus Claude Code's tool-specific directory.

## Tooling

For development, Python commands are run with `uv`.

## Prerequisite

`mise` manages `uv` in this repo, so `mise` is part of the development setup.

Installation is intentionally separate from the development toolchain. You do not need `mise`, `uv`, or Python just to install skills.

## Install

The shell installer copies each skill into the locations expected by supported agents. It installs the full skill directory so assets such as `agents/`, templates, or references can come along with it.

```bash
./install.sh list
```

```bash
./install.sh install git-commit
```

```bash
./install.sh install --all
```

```bash
./install.sh install --agent agents git-commit
./install.sh install --agent claude git-commit
```

```bash
./install.sh uninstall git-commit
```

```bash
./install.sh uninstall --all --agent agents
```

Default install targets:

- Agent-compatible tools such as Codex and OpenCode: `~/.agents/skills/<skill>/SKILL.md`
- Claude: `~/.claude/skills/<skill>/SKILL.md`

For both targets, the installed path is a full directory under a `skills/` folder.

If install finds an existing installed copy of the same skill, it prompts before overwriting. After a successful install, if the skill has been renamed, install separately prompts before removing any previously installed renamed copies for that same target. Use `--force` to skip both prompts, overwrite the existing installed skill, and automatically remove any previously installed renamed copies for the same skill. Use `--agents-home` and `--claude-home` to target custom install locations.

When install output is connected to a color-capable terminal, it highlights action tags and skill names in status messages. Use `--no-color` to disable that formatting.

Uninstall only works for skills that are present in this repository. During uninstall, the script warns before removing the installed skill directory because any local modifications to installed copies will be lost.

When a skill has been renamed, install checks `skill-renames.txt` for old-to-new mappings after each successful per-target install. If an old installed directory is still present for that target, the script prompts to remove that old installed copy.

Development tooling still uses `mise` and `uv`. Installation does not.

## Repo-local OpenAI system skills

For work in this repository, you can make Codex's upstream system skills available to agent-compatible tools via a repo-local `.agents/skills` directory.

```bash
./scripts/update-openai-skills.sh
```

The script:

- initializes or updates the tracked `vendor/openai-skills` submodule from `https://github.com/openai/skills.git`
- symlinks the upstream system skills into `.agents/skills`
- currently links `openai-docs`, `skill-creator`, and `skill-installer`

This setup is repo-local. `.agents/` is committed, and `vendor/openai-skills/` is tracked as a git submodule. After clone, run `git submodule update --init` or `./scripts/update-openai-skills.sh` to populate the linked skill source.

## Testing

The installer has a regression test covering discovery, directory-based installs for all supported targets, overwrite protection, uninstall behavior, and target-specific installs.

```bash
./tests/install_test.sh
```

## Contributing

- Skills should remain readable and portable.
- `SKILL.md` should stay the canonical source for a skill.
- Commit messages should follow Conventional Commits style.
- Treat `SKILL.md` instruction changes as behavior changes to the skill, not
  documentation-only edits. Prefer types such as `feat`, `fix`, or `refactor`
  over `docs` when the skill's behavior changes.
