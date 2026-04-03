# Claude Skills

Custom skills for [Claude Code](https://claude.ai/code).

## Skills

### `/tdd` — Test-Driven Development

Spec-driven development workflow. Give it a feature description, it generates a comprehensive test suite, you approve the contract, then it autonomously builds until all tests pass.

**Workflow:**

```
You describe intent --> AI generates tests --> You review & approve --> AI builds until green
```

**Phases:**
1. **Context Gathering** — auto-detects your test framework (Vitest, Jest, pytest, cargo test, Go test)
2. **Test Generation** — generates tests covering happy path, edge cases, errors, boundaries, validation
3. **Human Checkpoint** — you review the test contract before any code is written
4. **Build Loop** — autonomous implementation with a 10-iteration cap, never modifies tests
5. **Completion Report** — summary of what was built, what passed, what needs attention

**Supported frameworks:** Vitest, Jest, pytest, cargo test, go test

## Install

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/cestercian/claude-skills/main/install.sh | bash
```

### Manual

```bash
git clone https://github.com/cestercian/claude-skills.git ~/.claude/skills/claude-skills
ln -sf ~/.claude/skills/claude-skills/tdd ~/.claude/skills/tdd
```

### From release download

1. Download `claude-skills.zip` from the [latest release](https://github.com/cestercian/claude-skills/releases/latest)
2. Unzip and run the install script:

```bash
unzip claude-skills.zip -d /tmp/claude-skills
bash /tmp/claude-skills/install.sh
```

## Usage

In Claude Code:

```
/tdd a function that validates email addresses and returns structured errors
```

```
/tdd ./specs/auth-middleware.md
```

```
/tdd
> (Claude will ask you to describe the feature)
```

## Uninstall

```bash
rm ~/.claude/skills/tdd
rm -rf ~/.claude/skills/claude-skills
```

## License

MIT
