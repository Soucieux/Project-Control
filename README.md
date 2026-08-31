# Project Control

Project Control is a native macOS management center for this repository. Understand projects, track structured work notes, follow documented changes, and open a folder or chosen application without viewing or editing source code inside the app.

## Current release

The current source release is **v0.3 (build 3)**, retaining the selected **A · Nexus** icon and correcting review findings in README parsing, refresh tracking, repository switching, and path checks. It uses only Apple's frameworks and needs no account, API key, downloaded model, web server, or paid dependency. All 27 core checks, 10 isolated store checks, and native application type-checking passed. The clean-built v0.3 app passed signature, metadata, icon, recovery-copy, and project-root launch checks. Actual Dock/window, keyboard, and reduced-motion inspection remain unconfirmed because macOS denied screen-capture access. No privacy settings were changed.

## Quick start

Requirements: macOS 14 or later, and Xcode with its command-line tools selected. The build targets the current Mac's architecture. This is a local development application, not a notarized public installer.

From the repository root:

```sh
cd "Project Control"
make app
open "Project Control.app"
```

1. Choose **Choose repository…** and select the `Professional Quality` folder, not this subfolder.
2. Pick a project in the register. The root README's **Projects** table defines the register; each project's `README.md` supplies its details when available.
3. Open **Work notes → Add note**. Save a title, optional context, and status: **Next**, **In progress**, or **Done**. The ring counts completed notes, not overall project completion.
4. Use **Overview** for documented workflows and **Architecture & models**. **Project history** and the bottom **Repository history** panel keep the two histories separate.
5. **Open folder** and **Read README** open the item outside the app. The project action menu lets you choose a `.app`. Selection only saves the choice; **Launch app** starts it.

`Command-O` chooses a repository; `Command-R` refreshes it. `Command-N` adds a note while Work notes is visible. The app remembers the last valid repository.

The latest completed application lives directly beside this README as **Project Control.app**, now v0.3/build 3 with Nexus. The previous v0.2/build-2 bundle is preserved in `build/previous.QQ6ChE/Project Control.app`; its executable, metadata, and icon checksums are unchanged. The superseded v0.1 bundle was moved to macOS Trash under `Project Control - retired v0.1 build.vmunHZ`, with unchanged executable and metadata checksums. Quit the running app before installing an update so reopening starts the new version.

## Versioning and build delivery

- Use `v<major>.<minor>` with a single minor digit from **0 through 9**: `v0.8 → v0.9 → v1.0`, never `v0.10`.
- Every application update advances the release version and increments the integer build number. The next update after v0.3/build 3 is **v0.4/build 4**. A clean recompilation of the same unchanged update does not create a new release.
- Keep `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`, the release description here, the project changelog, and the repository README's project row/date/changelog aligned in the same batch. Do not relabel an existing signed bundle as a newer build.
- Prepare the bundle under ignored `build/`, then check its signature before moving the complete bundle to **Project Control.app** at this project root. `make app` performs this promotion; `make run` opens that root-level app. Never leave the only finished app several folders deep.
- Preserve a replaced root-level bundle in an ignored `build/previous.*` directory. If promotion fails, restore it. These recovery copies can be removed during an explicitly scoped cleanup.
- Before creating a new versioned/distributable build, obey the root build-history gate: commit previous-build changes only with explicit authorization, or obtain explicit permission to proceed without a commit. Icon/design studies and relocating an unchanged bundle are not new application releases.

## How information stays current

```text
Repository README → project register and repository history
Project README    → introduction, architecture, explicit workflows, project history
Local work notes  → completed-note count and progress ring
```

README resolved paths, modification dates, and sizes are checked every two seconds while the window is open. Metadata is captured before each read so edits during parsing remain detectable. Changed documents reload off the interface thread; **Refresh now** forces a read. A repository selection made while loading is queued, with the latest selection taking precedence. A failed repository refresh retains the previous snapshot and shows a warning. **Last read** records a successful snapshot, not a runtime health check.

### Extraction rules and limits

- The root README needs a `## Projects` section with a pipe table linking to top-level project folders. Paths must stay within the selected repository, including after resolving symbolic links.
- Table cells preserve escaped pipes and do not require a trailing pipe. Folder aliases share a canonical project identity instead of creating separate note collections.
- The first introductory project paragraph supplies the introduction; the root table summary is the fallback. OpenClaw currently has no project README, so that absence is shown explicitly.
- Architecture/model facts come from architecture, technology, component, or model sections and introductory model mentions. They are bounded extracts, not AI-generated interpretations.
- Workflow maps use explicit `→` or `->` routes under workflow/request headings. Separate routes stay separate. The app does not infer dependencies from ordinary bullets, interpret Mermaid, or invent missing models/workflows.
- Changelog/version-history tables supply up to thirty source-ordered history entries; version-labelled headings are the fallback. Open the README for the complete record. Explicit **current source release** or **current release** statements supply release/build labels; unrelated protocol versions do not.
- Fenced code blocks are excluded; fence-like lines with trailing text do not close them. Workflow labels require a colon followed by whitespace before the first arrow, so URL colons and later step labels stay intact. Markdown/HTML presentation becomes inert text. Scripts, commands, links, and embedded remote images are not executed or fetched. Each README read is limited to 2 MB.
- **Document health** checks folder/README availability. **Runtime not checked** is intentional: no project builds, tests, processes, or remote health probes run automatically.

## Local data and launch safety

Notes and application choices are saved atomically in the standard per-user Application Support folder, under `Project Control/workspace.json`, outside the repository. Entries are keyed by canonical project path; moving or renaming a repository does not automatically migrate notes. Keep the old file if recovery is needed.

No README is edited. Launching uses macOS's application-opening service with the explicitly selected `.app`, without a shell or arguments. Runtime monitoring and arbitrary script launch are not implemented. Malformed local data disables note editing and preserves the file rather than silently resetting it; restore a known-good copy and relaunch.

The development app is not sandboxed or notarized. Its scanner is restricted to selected-repository READMEs and path metadata; that is an application-level boundary, not an operating-system sandbox claim. The app contains no network client.

## Architecture

| Component | Responsibility |
|---|---|
| SwiftUI views | Native register, project surface, disclosures, note editor, restrained motion |
| `ControlStore` | Selection, window lifecycle, background reload, local mutations, native open actions |
| `RepositoryReader` | Bounded reads, canonical path checks, source snapshots, modification fingerprints |
| `ReadmeParser` | Inert sections, tables, prose, explicit routes, and histories |
| `WorkspaceStorage` | Atomic JSON persistence; malformed data is never reset automatically |

## Project structure

```text
Project Control/
├── Sources/Core/       # README extraction, models, constants, local storage
├── Sources/App/        # Native application, state, interface
├── Resources/          # Bundle identity, version, and editable Nexus icon
├── Tests/              # Focused synthetic and read-only repository checks
├── Design/             # Selected animated reference and motion sources
├── Makefile            # Local build, focused checks, launch
├── Project Control.app # Latest completed app; ignored by Git
└── build/              # Staging, caches, recovery copies; ignored by Git
```

## Design reference

The [selected animated preview](Design/framecraft-vector-lens.html) is a design reference, not the running app. It combines Vector's angular frames with Lens's navy/icy-blue palette; its static notes and older project count remain illustrative.

**A · Nexus** is selected. Its [editable vector master](Resources/ProjectControl.svg) and [transparent 1024-pixel PNG master](Resources/ProjectControl.png) preserve the approved geometry and palette. The superseded three-choice comparison was moved to macOS Trash under `Project Control - retired icon study 2026-08-30`, with its checksum unchanged. `make icons` uses macOS `sips` and `iconutil` to package standard/Retina representations from 16 through 1024 pixels into `ProjectControl.icns`. `make app` includes that icon automatically; no extra build dependency is required. When changing the vector, export its matching 1024×1024 RGBA PNG as well; the build uses the checked-in PNG because the native SVG decoder could not read this artwork reliably.

The preview embeds its [motion constants](Design/framecraft-vector-lens.motion.constants.js) and [motion behavior](Design/framecraft-vector-lens.motion.js). Keep the sources and embedded block aligned when editing that reference. Native controls use SwiftUI instead, with short interaction-driven motion and Reduce Motion support. There is no perpetual scanning, spinning, or fabricated activity.

The 33 rejected visual studies and screenshots were removed from the working project and preserved in macOS Trash, in the folder named `Project Control - retired designs 2026-08-30`. All 33 file checksums matched after the move. Their obsolete conversation-preview links were removed; the three selected-reference links remain intact.

## Development and focused checks

From this project folder:

```sh
make test
make app
```

`make test-core` covers README extraction, separate histories, explicit branches, release/build parsing, missing documents, pre-read fingerprints, note persistence, corrupt data, and traversal/symlink boundaries. `make test-store` checks queued repository changes, saved selection, note mutations, and save failures using isolated storage/preferences; it never launches applications or reads the user's workspace. `make test` runs both focused targets. Disposable fixtures are removed afterward. A read-only smoke check also checks this repository's register and Local Assistant's documented routes. No other subproject's suite runs.

For v0.2, focused packaging checks confirmed all ten icon sizes and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, unchanged v0.1 recovery files, and launch from the root-level v0.2 app. Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead. This does not substitute for actual Dock inspection. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.

For v0.3, clean native compilation, strict signature validation, source/bundle metadata equality, and project-root process launch passed. The packaged Nexus icon is byte-identical to the verified v0.2 icon. The preserved v0.2 bundle retains its valid signature and original executable, metadata, and icon checksums. The user explicitly permitted building v0.3 before committing v0.2. Generated compiler caches and intermediate icon files were removed after verification.

Generated staging files and recovery copies stay under ignored `build/`; the final `.app` stays at the project root and is also ignored. The next application build must satisfy the versioning and previous-build gate above. Changing the delivery recipe or preparing icon concepts does not imply that a new binary was built.

## Working rules

- Follow repository [AGENTS.md](../AGENTS.md), [CLAUDE.md](../CLAUDE.md), and configured global instructions; this README does not override them.
- Keep editable project files here. Framecraft remains separately installed, not copied into the app.
- Keep this README and the repository [README](../README.md) synchronized in the same batch: Projects row, latest-update date, and changelog.
- Preserve the selected design. Distinguish implemented behavior, source-reported information, and unavailable data. No inferred milestones, fake telemetry, or in-app code viewer.
- Keep generated output and local notes out of Git. Do not commit or publish without authorization.

## Change log

| Version | Date | Updates |
|---|---|---|
| v0.3 / build 3 | 2026-08-30 | Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows. Capture metadata before reads, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening. Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean compilation, strict signature checks, bundle metadata/icon checks, and project-root launch. Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash and removed generated artifacts. The user explicitly authorized building before committing v0.2. Native visual inspection remains unconfirmed. |
| v0.2 / build 2 | 2026-08-30 | Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle. Advanced both version and build. Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch; preserved v0.1 with matching executable/metadata checksums. Native Dock/window inspection remains unconfirmed. The user explicitly authorized this build without committing v0.1; no commit was created. |
| Delivery/design preparation · no new app build | 2026-08-30 | Relocated the unchanged v0.1/build-1 application beside this README. Configured signature-checked root-level delivery with recoverable prior bundles, and recorded the single-digit minor/version-and-build increment policy. Added three icon choices; selection and the next-build authorization were pending at this stage. |
| v0.1 / build 1 | 2026-08-30 | Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress, and explicit folder/README/app actions. Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch. Fixed stale metadata caching found by the refresh test. Retired 33 rejected design artifacts recoverably and removed their obsolete links. Native visual/keyboard inspection remains blocked by macOS capture permission. |
