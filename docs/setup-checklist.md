# Setup checklist

Copying the files is half the job. Several checks depend on GitHub features
that are turned on per repository, and the workflow cannot turn them on for
you. Work through this list once for each repository.

Menu names below match GitHub's current UI. In older UIs, **Advanced Security**
was called **Code security** or **Code security and analysis**.

## 1. Check what your plan includes

| Feature | Public repositories | Private repositories |
| --- | --- | --- |
| Gitleaks secret scan | Yes | Yes |
| Dependabot alerts, security and version updates | Yes | Yes |
| Dependency graph | Yes (on by default) | Yes |
| CodeQL code scanning | Yes | Needs GitHub Code Security |
| Dependency review action | Yes | Needs GitHub Code Security |
| GitHub secret scanning and push protection | Yes | Needs GitHub Secret Protection |

On a private repository without GitHub Code Security:

- The **CodeQL** jobs fail when uploading results. Remove the `codeql-languages`
  and `codeql` jobs from `security.yml` (and from the `needs:` list of
  `security-gate`), or get the licence.
- The **Dependency review** job fails. Remove it the same way.
- **Gitleaks** still runs and still fails the build on a leak. Only its upload
  to the Security tab is skipped; the findings stay in the job summary.

## 2. Turn on repository features

**Settings > Advanced Security**:

- [ ] **Private vulnerability reporting**: *Enable*. This gives `SECURITY.md`'s
      "Report a vulnerability" link somewhere to go.
- [ ] **Dependency graph**: *Enable* (needed by dependency review and Dependabot).
- [ ] **Dependabot alerts**: *Enable*.
- [ ] **Dependabot security updates**: *Enable*, so Dependabot opens fix PRs for
      vulnerable dependencies as soon as an advisory is published.
- [ ] **Grouped security updates**: optional, fewer PRs.
- [ ] **Code scanning > CodeQL analysis**: leave **default setup off**. This kit is
      an *advanced setup*; if default setup is on, GitHub rejects the
      workflow's CodeQL results. If it is already on, open its menu and choose
      *Disable CodeQL*, or *Switch to advanced* and discard the generated file.
- [ ] **Secret Protection > Secret scanning** and **Push protection**: enable when
      available. GitHub's scanner blocks known token formats at push time,
      before they reach history; Gitleaks complements it with more rules and
      runs on every plan.

## 3. Restrict the default workflow token

**Settings > Actions > General > Workflow permissions**:

- [ ] Choose **Read repository contents and packages permissions**.
- [ ] Leave **Allow GitHub Actions to create and approve pull requests** unchecked
      unless something else needs it.

`security.yml` asks for each permission it needs explicitly, so it does not
depend on a broad default.

Optional but recommended, in **Settings > Actions > General > Actions permissions**:
choose **Allow enterprise, and select non-enterprise, actions and reusable
workflows** and tick **Allow actions created by GitHub**. Every action this kit
uses is published by GitHub; Gitleaks is downloaded from its release page and
checked against a pinned SHA-256, so it needs no extra entry.

## 4. Make the checks required

**Settings > Rules > Rulesets > New branch ruleset** (or **Branches > Add
branch protection rule** on older setups), targeting your default branch:

- [ ] **Require a pull request before merging**.
- [ ] **Require status checks to pass**, and add **`Security gate`**.
      It appears in the search box after the workflow has run once.
- [ ] **Require code scanning results**: add the tools **CodeQL** and **gitleaks**,
      with *Security alerts* set to **High or higher** (or stricter) and
      *Alerts* to **Errors**. The CodeQL jobs upload findings but do not fail on
      them; this rule is what blocks a pull request that introduces a new alert.
- [ ] **Block force pushes**.

Require only `Security gate`, not the individual jobs. CodeQL job names
depend on the languages detected (`CodeQL (python)`, `CodeQL (actions)` and so
on), and `Dependency review` only runs on pull requests. The gate fails if any
of them fails and passes when a job was not needed.

## 5. Fill in the templates

- [ ] `SECURITY.md`: replace every `[BRACKETED]` value: owner and repository in
      the advisory link, contact address, supported versions, response times.
- [ ] `.github/dependabot.yml`: uncomment the ecosystems you use and set the
      directories that contain their manifests.

## 6. Verify

- [ ] Push a commit. On the **Actions** tab, the *Security* workflow runs
      `Secret scan (Gitleaks)`, `Detect CodeQL languages`, one `CodeQL` job per
      language and `Security gate`.
- [ ] Open a pull request. `Dependency review` runs as well.
- [ ] **Security > Code scanning** lists the `gitleaks` and CodeQL tools after
      the first run on the default branch.
- [ ] **Insights > Dependency graph > Dependabot** shows your manifests and
      their last update check.
- [ ] **Security > Policy** shows your `SECURITY.md`, and the **Report a
      vulnerability** button appears on the Security tab.

Optional smoke test for secret scanning, on a throwaway branch: commit a fake
token in the format of a real provider (for example `ghp_` followed by 36
random letters and digits), push, and watch the secret scan fail. Then delete
the branch. Never use a real credential for this.
