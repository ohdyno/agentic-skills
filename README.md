# Agentic Skills

My collection of agentic skills.

## Purpose

Store reusable agent skills.

## Tooling

Run Python commands with `uv`.

## Prerequisite

`mise` manages `uv`, so `mise` is required.

## Install

This repo keeps each skill's `SKILL.md` as the source of truth, then installs it into agent-specific locations with a plain shell script.

List available skills:

```bash
./install.sh list
```

Install one skill for both Codex and Claude:

```bash
./install.sh install git-commit
```

Install every skill:

```bash
./install.sh install --all
```

Install for a single agent:

```bash
./install.sh install --agent codex git-commit
./install.sh install --agent claude git-commit
```

Default install targets:

- Codex: `~/.codex/skills/<skill>/SKILL.md`
- Claude: `~/.claude/agents/<skill>.md`

Use `--force` to overwrite an existing installed skill.

Development tooling still uses `mise` and `uv`; installation does not.

Installer regression test:

```bash
./tests/install_test.sh
```

## Contributing

Commit messages must follow Conventional Commits style.
