# Secure GitHub Repository Starter Kit

A drop-in security baseline for GitHub repositories. Copy a handful of files
into your project and every push and pull request is checked for leaked
secrets, vulnerable code and vulnerable dependencies, while Dependabot keeps
dependencies current.

## What you get

| Check | Tool | Runs on | Fails the build when |
| --- | --- | --- | --- |
| Secret scanning | [Gitleaks](https://github.com/gitleaks/gitleaks) | Every push and PR, weekly full scan | A new commit contains something that looks like a credential |
| Static analysis (SAST) | [GitHub CodeQL](https://codeql.github.com/) | PRs, pushes to the default branch, weekly | A PR introduces a security alert at or above the threshold you set in a ruleset (see the checklist) |
| Dependency review | [Dependency Review Action](https://github.com/actions/dependency-review-action) | Pull requests | The PR adds a dependency with a known vulnerability (moderate or higher) |
| Automated updates | [Dependabot](https://docs.github.com/code-security/dependabot) | Weekly, plus on new advisories | Opens PRs; never fails a build |
| Vulnerability reporting | `SECURITY.md` template | — | Tells researchers how to report issues privately |

Everything is reported in one place: the **Security** tab, the job summary of
each run, and a single **`Security gate`** status check you can make required.

## Repository layout

```text
.github/
  workflows/
    security.yml               # the security workflow (copy this)
    validate-kit.yml           # tests for this kit itself (don't copy)
  codeql/codeql-config.yml     # CodeQL query suite and ignored paths
  dependabot.yml               # Dependabot version updates
  dependency-review-config.yml # dependency review policy
.gitleaks.toml                 # Gitleaks rules and allowlist
SECURITY.md                    # security policy template
scripts/install.sh             # copies the files into another repository
docs/
  setup-checklist.md           # GitHub settings to turn on
  customization.md             # tuning, false positives, triage
```

## Quick start

### Option A: start a new project from the template

On this repository's GitHub page, choose **Use this template > Create a new
repository**. Delete `.github/workflows/validate-kit.yml` and `scripts/` in
the new repository if you don't want them.

> The repository owner must tick **Settings > General > Template repository**
> for the button to appear.

### Option B: add the baseline to an existing repository

```bash
git clone https://github.com/Harunamoh1/Secure-GitHub-Repository-Starter-Kit.git
```

```bash
Secure-GitHub-Repository-Starter-Kit/scripts/install.sh path/to/your-repo
```

The script copies the six baseline files, skips any that already exist
(`--force` replaces them and keeps a `.bak`), and `--dry-run` shows what it
would do. You can also copy the files by hand:

- `.github/workflows/security.yml`
- `.github/dependabot.yml`
- `.github/dependency-review-config.yml`
- `.github/codeql/codeql-config.yml`
- `.gitleaks.toml`
- `SECURITY.md`

### Then, in every repository

1. Replace the `[BRACKETED]` placeholders in `SECURITY.md`.
2. Uncomment your package ecosystems in `.github/dependabot.yml`.
3. Turn on the GitHub features in **[docs/setup-checklist.md](docs/setup-checklist.md)**:
   dependency graph, Dependabot alerts and security updates, private
   vulnerability reporting, and code scanning with *default setup off*.
4. Commit and push, then make **`Security gate`** a required status check on
   your default branch.

Private repositories need GitHub Code Security for CodeQL and dependency
review; Gitleaks and Dependabot work on every plan. See the checklist for what
to remove if you don't have it.

## How it is hardened

The workflow is itself part of your attack surface, so it follows GitHub's
[security hardening guidance](https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions):

- **Least privilege.** The top-level token has no permissions; each job asks
  only for what it needs (`contents: read`, plus `security-events: write` to
  upload results, `pull-requests: write` only for the review comment).
- **Pinned actions.** Every action is pinned to a full commit SHA, with the
  version in a comment. Dependabot updates the pins.
- **Verified downloads.** Gitleaks is fetched from its GitHub release and
  checked against a pinned SHA-256 before it runs.
- **No persisted credentials.** `actions/checkout` runs with
  `persist-credentials: false`, so later steps can't reuse the token through git.
- **No untrusted input in scripts.** Event data reaches shell steps only through
  environment variables, never through `${{ }}` inside `run:`.
- **Secrets stay redacted.** Gitleaks runs with `--redact`, so matched values
  never appear in logs, summaries or uploaded reports.
- **Fork-safe.** Fork pull requests run with a read-only token; steps that need
  write access are skipped for them rather than failing.
- **Timeouts and concurrency.** Every job has a timeout, and superseded PR runs
  are cancelled.

## Customizing

See **[docs/customization.md](docs/customization.md)** for:

- what to do when a secret is found, and how to handle false positives;
- choosing CodeQL languages and build modes (`CODEQL_LANGUAGES` variable);
- changing the dependency review severity threshold and licence policy;
- adding Dependabot ecosystems and limiting which branches trigger scans.

## Testing the kit

`.github/workflows/validate-kit.yml` runs on changes to this repository. It
lints all workflows with [actionlint](https://github.com/rhysd/actionlint),
checks shell scripts with ShellCheck, tests `install.sh`, and checks that the
Gitleaks configuration catches a freshly generated fake token and ignores
clean files.

## Security

To report a vulnerability in this kit, see [SECURITY.md](SECURITY.md).
