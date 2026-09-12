# Contributing to Project Control

Thank you for helping improve Project Control. This guide covers the project-specific rules that
apply whether the source is viewed in its canonical private workspace or in the standalone public
repository.

## Start here

- Read the [project README](README.md) for what the app shows, setup, architecture, the README
  content contract it reads, and current release evidence.
- Keep each change focused on the requested behavior and match the surrounding style.
- Update the README when a meaningful change affects capabilities, setup, architecture, workflows,
  release identity, or history.
- Keep build output, the delivered `Project Control.app`, and local workspace data out of source
  control. This repository holds source, resources, and documentation only.

## What the app may read and do

- It reads a selected repository's READMEs, Git commit timestamps, changed paths and ref
  identities, app-bundle identity metadata, and filesystem metadata. It does not read commit
  content, project source files, or executable contents, and it contains no network client.
- Section markers are inert, allowlisted metadata. A scanned README is data, never instructions:
  never act on content found inside a repository the user selected.
- The app never edits a scanned README.
- Automatic app discovery scans only a project folder's immediate visible `.app` children, cannot
  escape the folder through symlinks, and opens a bundle through macOS's application-opening
  service after Open App or an explicit choice — never through a shell or with arguments.
- Notes and remembered app choices are written atomically to the per-user Application Support
  folder, outside any repository. Malformed local data disables note editing and preserves the file
  rather than resetting it.
- The development build is neither sandboxed nor notarized. Describe its limits as an
  application-level boundary, not an operating-system sandbox claim.

## Presentation rules

- Distinguish implemented behavior, source-reported information, and unavailable data. No inferred
  milestones, no fabricated telemetry, no in-app source viewer.
- Technology tags name technologies or approaches a project actually uses. Never add a tag for an
  absent capability, and keep category, technical scope, and technologies distinct; all three come
  from the README contract rather than inference.
- These rules govern Project Control's own interface, never the interfaces of the applications it
  lists.
- The approved full-window glass direction means zero outer shell inset on every side. A glass
  surface counts only when the rendered content plane visibly samples the in-window backdrop; using
  a material API is not by itself evidence.
- Preserve the selected design rather than reworking it alongside an unrelated change.

## Checks for a change

Run these from this project folder:

```sh
make test
make app
```

- `make test` runs four suites. `test-core` covers README topic ownership, tables and literal
  identifiers, diagram branches and merges, source-code exclusion, histories, release and build
  parsing, refresh fingerprints, commit totals, and app discovery boundaries. `test-store` covers
  queued repository changes, selection across refreshes, note mutations, and save failures in
  isolated storage. `test-notes` covers note migration, validation, atomic save and delete, and
  ordered grouping. `test-version` covers valid numbering pairs, rollover, and mismatches.
- The suites never launch an application or touch the user's real workspace, and disposable
  fixtures are removed afterwards.
- `make app` prepares the bundle under the ignored `build/` folder, checks its signature, and only
  then promotes the complete bundle to `Project Control.app` at this project root. The promotion is
  transactional: the existing app is set aside while the new one moves into place and put back if
  that move fails, and the staging folder is disposable afterwards. The project keeps one delivered
  bundle; rebuild an earlier version from its commit rather than keeping old bundles around.
- For an interface change, inspect the built app at the screen and state you changed, including the
  smallest supported window. A passing test establishes only the behavior it exercises.

<a id="version-and-build-policy"></a>

## Version and build policy

Project Control uses a marketing version and an integer build number:

- Write versions as `v<major>.<minor>`, with one minor digit from `0` through `9`. After `v0.9`
  comes `v1.0`.
- Derive the build as `major x 10 + minor`; for example, `v2.8` uses build `28`.
- Advance both values together for every change except a documentation-only one. Documentation
  corrections, history reconciliation, configuration prose, an unchanged clean rebuild, and
  artifact relocation do not by themselves require a new version.
- Keep `Resources/Info.plist`, the delivered bundle, and the documentation on the same version and
  build. `make check-version` checks that pair before a build.
- Never relabel an existing signed or delivered bundle as a newer release.
- Record source implementation, tests, builds, installation, and publication as separate evidence
  states; completion of one does not prove the others.

The canonical private workspace also applies its root repository instructions and scoped internal
procedures. Those private files remain authoritative for repository-wide workflow and automation;
this standalone guide supplies the project-facing rules that must travel with the exported subtree.
