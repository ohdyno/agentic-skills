# Agentic Skills

This repository contains reusable skills for coding agents.

Each skill lives in its own directory and is authored as a `SKILL.md`. That file is the source of truth and should follow the guidance from the skill.md standard site at `agentskills.io`.

## Purpose

Treat skills as small, portable building blocks for agent behavior. This repo is where they are developed and from which they are installed into local agent-specific directories such as Codex and Claude.

## Tooling

For development, Python commands are run with `uv`.

## Prerequisite

`mise` manages `uv` in this repo, so `mise` is part of the development setup.

Installation is intentionally separate from the development toolchain. You do not need `mise`, `uv`, or Python just to install skills.

## Install

The shell installer copies each skill into the locations expected by supported agents. For directory-based targets such as Codex and Claude, it installs the full skill directory so assets such as `agents/`, templates, or references can come along with it.

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
./install.sh install --agent codex git-commit
./install.sh install --agent claude git-commit
```

```bash
./install.sh uninstall git-commit
```

```bash
./install.sh uninstall --all --agent codex
```

Default install targets:

- Codex: `~/.codex/skills/<skill>/SKILL.md`
- Claude: `~/.claude/skills/<skill>/SKILL.md`

For both Codex and Claude, the installed path is a full directory under each tool's `skills/` folder.

Use `--force` to overwrite an existing installed skill. Use `--codex-home` and `--claude-home` to target custom install locations.

Uninstall only works for skills that are present in this repository. During uninstall, the script warns before removing the installed skill directory because any local modifications to installed copies will be lost.

Development tooling still uses `mise` and `uv`. Installation does not.

## Testing

The installer has a regression test covering discovery, directory-based installs for both agents, overwrite protection, uninstall behavior, and agent-specific installs.

```bash
./tests/install_test.sh
```

## Contributing

- Skills should remain readable and portable.
- `SKILL.md` should stay the canonical source for a skill.
- Commit messages should follow Conventional Commits style.
