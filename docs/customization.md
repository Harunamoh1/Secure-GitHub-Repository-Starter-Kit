# Customization and day-to-day use

## Secret scanning

### What gets scanned

| Event | Commits scanned |
| --- | --- |
| Pull request | Commits in the PR (`base..head`) |
| Push to an existing branch | Commits in the push (`before..after`) |
| Push of a new branch, or a force push | Commits not already on the default branch |
| First push of the default branch | Its whole history |
| Weekly schedule, manual run | All history on all branches |

Scanning only new commits keeps pull requests fast and avoids failing every PR
over an old leak. The weekly full scan catches anything that slipped past, and
picks up new detection rules as Gitleaks adds them.

To run a full scan now: **Actions > Security > Run workflow**.

### When Gitleaks finds a secret

1. **Assume the secret is compromised and rotate it first.** Revoke the key or
   change the password at the provider. Deleting it from the code does not
   remove it from git history, forks, clones or CI logs.
2. Remove it from the code and load it from the environment or a secret
   manager instead (for CI, use **Settings > Secrets and variables > Actions**).
3. If the commit has not been merged, you can rewrite the branch to drop it
   (`git rebase -i`, `git commit --amend`) and force-push the branch.
   Rewriting already-merged history needs `git filter-repo` and coordination
   with everyone who has cloned the repository, and it still does not
   un-leak the secret, which is why rotating comes first.

### False positives

Pick the narrowest option that works:

- **One finding**: add its fingerprint to a `.gitleaksignore` file at the
  repository root. The fingerprint looks like
  `<commit>:<file>:<rule-id>:<line>`; run Gitleaks locally with
  `--report-format json` to get it.
- **Inline**: put `gitleaks:allow` in a comment on the same line.
- **A placeholder used in many places**: add a regex under `[[allowlists]]` in
  `.gitleaks.toml`.
- **A rule that is consistently wrong for the project**: add its ID to
  `disabledRules` in `.gitleaks.toml`.

### Run Gitleaks locally

Install it from <https://github.com/gitleaks/gitleaks#installing>, then:

```bash
gitleaks git --config .gitleaks.toml --redact -v
```

To scan staged changes before every commit, add a
[pre-commit](https://pre-commit.com/) hook:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks
```

### Upgrading Gitleaks

Gitleaks is installed from its release archive, not through a marketplace
action, so Dependabot does not update it. To upgrade, change `GITLEAKS_VERSION`
at the top of `security.yml` and replace both `GITLEAKS_SHA256_*` values with
the ones in that release's `gitleaks_<version>_checksums.txt`.

The official `gitleaks/gitleaks-action` was not used because it needs a paid
licence key for repositories owned by organizations.

## CodeQL

### Languages

The `Detect CodeQL languages` job reads the repository's languages from the
GitHub API and runs one CodeQL job per supported language:

| Repository language | CodeQL language | Build mode |
| --- | --- | --- |
| C, C++, Objective-C | `c-cpp` | `autobuild` |
| C# | `csharp` | `none` |
| Go | `go` | `autobuild` |
| Java, Kotlin | `java-kotlin` | `none` |
| JavaScript, TypeScript | `javascript-typescript` | `none` |
| Python | `python` | `none` |
| Ruby | `ruby` | `none` |
| Rust | `rust` | `none` |
| Swift | `swift` | `autobuild` (macOS runner) |
| GitHub Actions workflows | `actions` | `none` (always included) |

To choose the languages yourself, create a repository variable
**`CODEQL_LANGUAGES`** (**Settings > Secrets and variables > Actions >
Variables**). List languages separated by commas, optionally with a build
mode after a colon:

```text
python,javascript-typescript,actions
java-kotlin:autobuild,actions
c-cpp:manual
```

With `manual`, edit the `Build (manual mode)` step in `security.yml` to run
your build commands, for example `make` or `./gradlew assemble`.

### Queries and paths

`.github/codeql/codeql-config.yml` selects the `security-extended` query suite
and excludes vendored and generated code. Switch to `security-and-quality` for
code-quality findings too, or add `paths-ignore` entries for directories that
produce noise.

### Blocking pull requests on findings

The CodeQL jobs succeed as long as the analysis runs; findings are uploaded,
not turned into job failures. GitHub then adds a **Code scanning results**
check to each pull request. To block merges on new alerts, add the **Require
code scanning results** rule to your branch ruleset and choose the severity
threshold (see the setup checklist, step 4).

### Triage

Alerts appear under **Security > Code scanning** and as annotations on pull
requests. Fix the issue, or dismiss the alert with a reason (*false positive*,
*used in tests*, *won't fix*) so the decision is recorded.

## Dependency review

Settings live in `.github/dependency-review-config.yml`:

- `fail-on-severity`: lowest severity that fails the check (default `moderate`).
- `fail-on-scopes`: which dependency scopes can fail it (default runtime and
  unknown; development dependencies are reported but do not fail).
- `allow-ghsas`: advisories you have reviewed and accepted.
- `license-check` with `allow-licenses` or `deny-licenses`: licence policy.

When the check fails on a pull request from the same repository, it posts a
summary comment. Pull requests from forks get the summary in the job log only,
because their token cannot write comments.

## Dependabot

`.github/dependabot.yml` updates the GitHub Actions used by the workflows on a
weekly schedule, grouped into one PR. Uncomment your package ecosystems; see
the [options reference](https://docs.github.com/code-security/dependabot/working-with-dependabot/dependabot-options-reference)
for private registries, ignore rules and more.

The `cooldown` setting waits five days after a release before proposing it,
which gives the community time to notice a malicious or broken release.
Security updates are not delayed.

## Workflow triggers

The workflow runs on every push, every pull request, weekly, and on demand.
CodeQL runs on pull requests, pushes to the default branch, the schedule and
manual runs; on pushes to other branches it is skipped to save minutes, since
those changes are analysed once a pull request is opened.

To limit pushes to some branches, change the trigger:

```yaml
on:
  push:
    branches: [main, "release/**"]
```

## Keeping the kit up to date

Files installed in your repository are copies. Dependabot keeps the action
versions current; for other improvements, compare your files with a newer
version of the kit and merge what you want, or re-run `scripts/install.sh
--force` (it backs up each replaced file as `<file>.bak`).
