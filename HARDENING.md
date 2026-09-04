<!-- markdownlint-disable -->

# Hardening Report: anishathalye--proof-html/v2.2.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **anishathalye--proof-html/v2.2.5** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

action.yml uses a mutable Docker image tag instead of a SHA digest: `image: docker://anishathalye/proof-html:2.2.5`. This is vulnerable to supply-chain attacks if the image tag is overwritten. It should be pinned to a SHA digest (e.g. `docker://anishathalye/proof-html@sha256:<64-hex-char-digest>`).

ci.yml uses unpinned action refs: `actions/checkout@v6` and `ruby/setup-ruby@v1` — both are mutable tags, not full 40-character commit SHAs.

docker.yml uses an unpinned action ref: `actions/checkout@v6` — a mutable tag, not a full 40-character commit SHA.

Locations:

- `action.yml:57`
- `.github/workflows/ci.yml:11`
- `.github/workflows/ci.yml:12`
- `.github/workflows/docker.yml:10`

### permissions (severity: medium)

missing-permissions: .github/workflows/ci.yml has no top-level `permissions:` key and no job-level `permissions:` key on any job. This means the workflow runs with the default (potentially broad) token permissions.

Locations:

- `.github/workflows/ci.yml:1`

### permissions (severity: medium)

missing-permissions: .github/workflows/docker.yml has no top-level `permissions:` key and no job-level `permissions:` key on any job. This means the workflow runs with the default (potentially broad) token permissions.

Locations:

- `.github/workflows/docker.yml:1`

### script-injection (severity: high)

Rule (a) violation: `${{ steps.tag.outputs.TAG }}` is interpolated directly inside two `run:` shell command strings in docker.yml. The `steps.*.outputs.*` context is workflow-controllable and flows through YAML template substitution before the shell sees it, enabling command injection.

Offending lines:
- `run: docker build . -t ${{ steps.tag.outputs.TAG }}`
- `run: docker push ${{ steps.tag.outputs.TAG }}`

Fix: move the value into an `env:` variable and double-quote it in the shell script, e.g.:
```yaml
env:
  IMAGE_TAG: ${{ steps.tag.outputs.TAG }}
run: docker build . -t "$IMAGE_TAG"
```

Locations:

- `.github/workflows/docker.yml:18`
- `.github/workflows/docker.yml:20`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection

**Notes:**

Fixed all four findings: (1) Pinned Docker image in action.yml from `docker://anishathalye/proof-html:2.2.5` to `docker://anishathalye/proof-html:2.2.5@sha256:4659086c07e94aaa9e93d7793fed323ffb575839db37b5bff3e8a59b2ec83c97`. (2) Pinned `actions/checkout@v6` to full SHA `d23441a48e516b6c34aea4fa41551a30e30af803` in both ci.yml and docker.yml. (3) Pinned `ruby/setup-ruby@v1` to full SHA `95ef2b042f9d7a56d8268cba8559e2842e2ad01b` in ci.yml. (4) Added `permissions: {}` top-level block to both ci.yml and docker.yml. (5) Fixed script injection in docker.yml by moving `${{ steps.tag.outputs.TAG }}` into `env: IMAGE_TAG:` blocks and referencing as `"$IMAGE_TAG"` in the shell commands.

