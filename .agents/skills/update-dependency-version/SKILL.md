---
name: update-dependency-version
description: Update any dependency version in rapids-cmake/cpm/versions.json and open a PR
---

## What I do

Update any package entry in `rapids-cmake/cpm/versions.json` to a new commit, then create a PR following the established pattern.

## Schemas

Two schemas exist in `versions.json`. Detect which one the target package uses before editing.

**Git mode**:
```json
"<package>": {
  "version": "<version>",
  "git_url": "https://github.com/<org>/<repo>.git",
  "git_tag": "<commit-sha>"
}
```
Update `version` and `git_tag`. Do not touch other fields (`git_shallow`, `always_download`, `source_subdir`, `proprietary_binary*`).

**URL/tarball mode**:
```json
"CCCL": {
  "version": "<version>",
  "url": "https://github.com/<org>/<repo>/archive/<commit-sha>.tar.gz",
  "url_hash": "SHA256=<hex>"
}
```
Update `version`, `url`, and `url_hash`.

## Step-by-step procedure

### 1. Read the current state

```
cat rapids-cmake/cpm/versions.json
```

Identify the target package's schema and record the old commit SHA (from `git_tag` or the commit SHA embedded in `url`) — needed for the PR comparison URL.

### 2. Identify the GitHub repo

Read `git_url` (git mode) or extract the org/repo from `url` (tarball mode).

### 3. Resolve the new commit SHA

**For a tag** (e.g. `v3.4.0`):
```
gh api repos/<org>/<repo>/git/ref/tags/v3.4.0
```
Check `.object.type` in the response:
- If `"commit"`: use `.object.sha` directly.
- If `"tag"`: dereference by calling `gh api repos/<org>/<repo>/git/tags/<sha>` and check `.object.type` again.

Repeat until `.object.type == "commit"`. Tags can be nested multiple levels deep (e.g. a tag pointing to a tag pointing to a commit). Always verify the final SHA exists as a commit:
```
gh api repos/<org>/<repo>/commits/<commit-sha> --jq '.sha'
```
If the API returns a 422 error, the SHA is not a commit — keep dereferencing.

**For a branch** (e.g. `branch/3.3.x` or `main`):
```
gh api repos/<org>/<repo>/commits/<branch> --jq '.sha'
```

### 4. Compute SHA256 (URL/tarball mode only)

Before downloading, confirm the commit SHA resolved in step 3 actually exists:
```
gh api repos/<org>/<repo>/commits/<new-commit-sha> --jq '.sha'
```
If this returns a 422 error, stop and re-examine the tag dereference chain.

```
curl -sL https://github.com/<org>/<repo>/archive/<new-commit-sha>.tar.gz | sha256sum
```

Take the hex string (first field), prefix with `SHA256=`.

### 5. Determine the new `version` string

- For a tagged release: strip the leading `v` (e.g. `v3.4.0` → `"3.4.0"`)
- For a branch tip: check the source repo for the current version. Common locations include the project's top-level `CMakeLists.txt` (look for `project(... VERSION ...)`) or version header files. For example:
  ```
  gh api repos/<org>/<repo>/contents/CMakeLists.txt --jq '.content' | base64 -d | grep -i 'project(' | head -5
  ```
  Do NOT assume the version is unchanged from the previous entry in `versions.json` — the upstream repo may have bumped it. If the version cannot be determined from source files, ask the user.

### 6. Edit `rapids-cmake/cpm/versions.json`

Update only the fields appropriate for the schema (see Schemas section above). Do not change indentation, key order, or any other field.

### 7. Verify the edit

```
rg -n '"<package>"' -A 6 rapids-cmake/cpm/versions.json
```

### 8. Create a branch and commit

Use the following naming conventions for the PR title and commit message. Note: the pinned value in `versions.json` is always a commit hash, regardless of whether the user specified a tag or a branch.
- **User requested a specific tag** (e.g. `v3.4.0`): `"Update <package> to <version>"` (e.g. `"Update CCCL to 3.4.0"`)
- **User requested a branch tip** (e.g. `main`): `"Update <package> to <version> pre-release"` (e.g. `"Update CCCL to 3.4.0 pre-release"`)

```
git checkout -b update-<package-lower>-<version>
git add rapids-cmake/cpm/versions.json
git commit -m "<title>"
```

### 9. Push and open a PR

```
git push -u origin update-<package-lower>-<version>
```

PR body template (use the same `<title>` from step 8):
```
## Description
This PR updates <package> to <title>.

Comparison of <package> commits: https://github.com/<org>/<repo>/compare/<old-sha>...<new-sha>

## Checklist
- [x] I am familiar with the [Contributing Guidelines](https://github.com/rapidsai/rapids-cmake/blob/HEAD/CONTRIBUTING.md).
- [x] New or existing tests cover these changes.
- [x] The documentation is up to date with these changes.
- [x] The `cmake-format.json` is up to date with these changes.
- [ ] I have added new files under rapids-cmake/
   - [ ] I have added include guards (`include_guard(GLOBAL)`)
   - [ ] I have added the associated docs/ rst file and update the api.rst
```

Use `gh pr create` targeting `main`.

### 10. Add labels to the PR

After creating the PR, add labels using `gh pr edit`. Ask the user whether the change is breaking or non-breaking, then apply the appropriate labels:

- **Non-breaking dependency update** (most common): `improvement` + `non-breaking`
- **Breaking dependency update**: `improvement` + `breaking`

```
gh pr edit <pr-number> --repo rapidsai/rapids-cmake --add-label "improvement" --add-label "non-breaking"
```
