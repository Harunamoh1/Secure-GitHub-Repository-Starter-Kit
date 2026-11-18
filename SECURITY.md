<!--
  SECURITY.md TEMPLATE
  Replace every [BRACKETED] value, delete sections that do not apply, and
  remove this comment. GitHub shows this file on the repository's Security tab
  and links to it when someone opens a new issue.
-->

# Security Policy

Thank you for helping keep [PROJECT NAME] and its users safe.

## Supported versions

Security fixes are released for the versions below. Please check that you can
reproduce the issue on a supported version before reporting it.

| Version | Supported |
| ------- | --------- |
| [2.x]   | Yes       |
| [1.x]   | Security fixes until [YYYY-MM-DD] |
| < [1.0] | No        |

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues,
discussions or pull requests.**

Report privately instead, using either:

1. **GitHub private vulnerability reporting (preferred):**
   [Report a vulnerability](https://github.com/[OWNER]/[REPOSITORY]/security/advisories/new)
   (Security tab > *Report a vulnerability*).
2. **Email:** [security@example.com]
   [Optional: encrypt with our PGP key, fingerprint `[FINGERPRINT]`, available at [URL].]

Please include as much of the following as you can:

- The type of issue (for example SQL injection, cross-site scripting, authentication bypass)
- The affected component, file path, version, branch or commit
- Step-by-step instructions to reproduce, and any special configuration needed
- Proof-of-concept or exploit code, if available
- The impact you expect, and how an attacker could use the issue

You do not need to have a fix. Incomplete reports are welcome; we will ask
for what we need.

## What to expect

| Step | Target time |
| ---- | ----------- |
| Acknowledge your report | [3] business days |
| Initial assessment and severity | [10] business days |
| Status updates | At least every [14] days until resolved |
| Fix released for critical and high severity | [90] days or sooner |

We will:

- Confirm the issue and work out its severity (we use [CVSS v4.0]).
- Keep you informed as we work on a fix.
- Agree a disclosure date with you, normally when the fix is released.
- Publish a GitHub Security Advisory and request a CVE where appropriate.
- Credit you in the advisory, unless you would rather stay anonymous.

If we decide the report is not a vulnerability, we will explain why.

## Safe harbor

We will not take legal action against anyone who, in good faith:

- Makes a reasonable effort to avoid privacy violations, data destruction and
  service disruption;
- Tests only against their own accounts and installations, not other users' data;
- Gives us reasonable time to fix the issue before disclosing it publicly; and
- Does not exploit the issue beyond what is needed to demonstrate it.

## Out of scope

[Edit to suit your project. Examples:]

- Vulnerabilities in third-party dependencies that are already publicly known
  (Dependabot tracks these; a pull request that upgrades the dependency is welcome)
- Findings from automated scanners without a demonstrated impact
- Denial of service through excessive traffic
- Social engineering of maintainers or contributors
- Issues that require physical access to a user's device

## Security measures in this repository

This repository uses an automated security baseline on every push and pull request:

- Secret scanning with [Gitleaks](https://github.com/gitleaks/gitleaks)
- Static analysis with [GitHub CodeQL](https://codeql.github.com/)
- Dependency review on pull requests
- Automated dependency updates with Dependabot

## Contact

[Maintainer or security team name] — [security@example.com]
