# Project Control

Project Control is a native macOS management center for this repository. Understand projects, track structured work notes, follow documented changes, and open a folder or chosen application without viewing or editing source code inside the app.

## Current release

The current source release is **v0.5 (build 5)**. Review fixes preserve ASCII-arrow diagrams and current sections under versioned project titles, refresh app metadata without restarting, and detect executable-permission changes. All 57 core checks, 14 store checks, and native type-checking passed. The source will be committed before producing the v0.5 bundle, as required by the repository build-history gate; the delivered app is still v0.4 until that promotion completes.

The app retains Nexus header branding, full-row navigation without search, automatic project-root app detection, separate README content tabs, and connected workflow diagrams. It uses only Apple's frameworks and needs no account, API key, downloaded model, web server, or paid dependency. The v0.4 release passed clean compilation, strict signature/metadata/icon checks, and project-root process launch. Offscreen native rendering covered the Overview layout and branching workflow diagram. Live Dock/window, keyboard, file-picker, and reduced-motion interaction checks remain unconfirmed because macOS denied screen-capture access. No privacy settings were changed.

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
4. **Overview** shows the README's overview or opening description. **Architecture**, **Models**, and **Workflows** have separate tabs. Workflow nodes and arrows show only documented connections. **Project history** and the bottom **Repository history** panel keep the two histories separate.
5. **Open folder** and **Read README** open the item outside the app. **Open App** detects a valid `.app` directly in the project folder, preferring the project-name match, then the folder-name match, then a sole candidate. Multiple unmatched apps appear as choices. If none is available, Open App lets you locate one, opens it, and remembers its path when local storage is writable.

`Command-O` chooses a repository; `Command-R` refreshes it. `Command-N` adds a note while Work notes is visible. The app remembers the last valid repository.

The latest completed application lives directly beside this README as **Project Control.app**, now v0.4/build 4 with Nexus. The previous v0.3/build-3 bundle is preserved in `build/previous.nzRO66/Project Control.app`; its executable, metadata, and icon checksums are unchanged. The superseded v0.2 bundle was moved to macOS Trash under `Project Control - retired v0.2 build.ZoaQv7`, with unchanged executable and metadata checksums. The older v0.1 bundle was retired to Trash during the v0.3 update. Quit the running app before installing an update so reopening starts the new version.

## Versioning and build delivery

- Use `v<major>.<minor>` with a single minor digit from **0 through 9**: `v0.8 → v0.9 → v1.0`, never `v0.10`.
- Every application update advances the release version and increments the integer build number. The next update after v0.5/build 5 is **v0.6/build 6**. A clean recompilation of the same unchanged update does not create a new release.
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

README resolved paths, modification dates, sizes, top-level app-bundle metadata, and executable availability are checked every two seconds while the window is open. Metadata is captured before each read so edits during parsing remain detectable. App validation reads bounded, current `Info.plist` data rather than cached bundle information; executable-permission changes also invalidate the snapshot. Changed documents reload off the interface thread; **Refresh now** forces a read. A repository selection made while loading is queued, with the latest selection taking precedence. A failed repository refresh retains the previous snapshot and shows a warning. **Last read** records a successful snapshot, not a runtime health check. App discovery runs again when Open App is clicked; missing or nonexecutable targets are not launched.

### Extraction rules and limits

- The root README needs a `## Projects` section with a pipe table linking to top-level project folders. Paths must stay within the selected repository, including after resolving symbolic links.
- Table cells preserve escaped pipes and do not require a trailing pipe. Folder aliases share a canonical project identity instead of creating separate note collections.
- Overview uses the README's explicit Overview, About, or What This Does section; otherwise it uses the opening description before second-level sections. It preserves paragraphs and bullet points. Nested architecture, model, workflow, and historical headings belong to their own topics. The root table summary is the fallback when project prose is unavailable. OpenClaw currently has no project README, so that absence is shown explicitly.
- Architecture/model facts come from current architecture, technology, component, or model sections and introductory model mentions. Model facts appear separately, not mixed into Architecture. These are source extracts, not AI-generated interpretations.
- Workflow diagrams use explicit `→` or `->` routes under workflow/request headings, including text-only fenced diagrams. Supported block diagrams use `↓` between stages and same-depth `├─→` / `└─→` branches; a following downward stage joins the completed branch group. Separate routes stay separate. Up to eight graphs with at most 32 nodes each are shown. Malformed, unsupported, or code-like diagram blocks are not interpreted. The app does not infer dependencies from ordinary bullets, interpret Mermaid, or invent missing models/workflows.
- Changelog/version-history tables supply up to thirty source-ordered history entries; headings beginning with a release label such as `v1.0` are the fallback. A version mentioned in a project title or protocol heading does not turn its current child sections into history. Open the README for the complete record. Explicit **current source release** or **current release** statements supply release/build labels; unrelated protocol versions do not.
- Fenced source-code blocks are excluded; only unlabelled, `text`, or `plaintext` blocks can supply supported diagrams. Fence-like lines with trailing text do not close a block. Workflow labels require a colon followed by whitespace before the first arrow, so URL colons and later step labels stay intact. Markdown/HTML presentation becomes inert text. Scripts, commands, links, and embedded remote images are not executed or fetched. Each README read is limited to 2 MB.
- **Document health** checks folder/README availability. **Runtime not checked** is intentional: no project builds, tests, processes, or remote health probes run automatically.

## Local data and launch safety

Notes and application choices are saved atomically in the standard per-user Application Support folder, under `Project Control/workspace.json`, outside the repository. Entries are keyed by canonical project path; moving or renaming a repository does not automatically migrate notes. Keep the old file if recovery is needed.

No README is edited. Automatic app discovery scans only the project folder's immediate visible `.app` children, not nested build/recovery folders. Bundle metadata and an executable entry point must be present and contained in the bundle; automatic candidates cannot escape the project through symlinks. A valid remembered manual location is the fallback when automatic detection is ambiguous or unavailable. Launching uses macOS's application-opening service only after Open App or an explicit app choice, without a shell or arguments. Runtime monitoring and arbitrary script launch are not implemented. Malformed local data disables note editing and preserves the file rather than silently resetting it; restore a known-good copy and relaunch. Opening an app does not require writable note storage, although a manual location cannot then be remembered.

The development app is not sandboxed or notarized. Its scanner is restricted to selected-repository READMEs, app-bundle identity metadata, and filesystem metadata; that is an application-level boundary, not an operating-system sandbox claim. It does not read project source files or executable contents. The app contains no network client.

## Architecture

| Component | Responsibility |
|---|---|
| SwiftUI views | Native register, project surface, disclosures, note editor, restrained motion |
| `ControlStore` | Selection, window lifecycle, background reload, local mutations, native open actions |
| `RepositoryReader` | Bounded reads, canonical path checks, source snapshots, modification fingerprints |
| `ReadmeParser` | Inert sections, tables, prose, explicit routes, and histories |
| `WorkflowParser` / `WorkflowDiagram` | Source-defined graph topology and native, content-sized node/connector rendering |
| `ApplicationLocator` | Top-level bundle discovery, validation, and deterministic app preference |
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

`make test-core` covers README topic ownership, overview formatting, explicit diagram branches/merges, source-code exclusion, histories, release/build parsing, missing documents, refresh fingerprints, app discovery/ambiguity/symlink boundaries, note persistence, and corrupt data. `make test-store` checks queued repository changes, saved selection, note mutations, save failures, and automatic/manual app resolution using isolated storage/preferences; it never launches applications or reads the user's workspace. `make test` runs both focused targets. Disposable app fixtures are never executed and are removed afterward. A read-only smoke check also checks this repository's register and Local Assistant's five request routes plus its RAG diagram. No other subproject's suite runs.

For v0.2, focused packaging checks confirmed all ten icon sizes and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, unchanged v0.1 recovery files, and launch from the root-level v0.2 app. Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead. This does not substitute for actual Dock inspection. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.

For v0.3, clean native compilation, strict signature validation, source/bundle metadata equality, and project-root process launch passed. The packaged Nexus icon is byte-identical to the verified v0.2 icon. The preserved v0.2 bundle retains its valid signature and original executable, metadata, and icon checksums. The user explicitly permitted building v0.3 before committing v0.2. Generated compiler caches and intermediate icon files were removed after verification.

For v0.4, all 62 focused checks and native type-checking passed, followed by a cache-free native build, strict signature and source/bundle metadata checks, unchanged Nexus icon payload, project-root launch, and checksum-matched v0.3 recovery checks. An offscreen `NSHostingView` rendered the real Overview and workflow components without capturing any screen; this checked layout, not live interaction. A test-fixture comparison was corrected to use canonical macOS paths. Temporary render sources/images, test executables, the failed fixture/report, compiler caches, and intermediate icons were removed. The v0.3 source/build work was already committed before this build began.

The subsequent v0.5 review reproduced four defects using disposable fixtures: ASCII arrows inside text fences were rejected, a versioned project title incorrectly owned all current sections as history, cached bundle metadata survived executable changes, and permission-only executable changes did not trigger refresh. All four are fixed. Nine added core assertions cover these regressions plus binary/malformed/oversized metadata and executable-directory rejection. All 71 focused checks and native type-checking passed. No synthetic app was launched. Clean distributable compilation and delivery checks will follow the source commits; no build-rule exception is required.

Generated staging files and recovery copies stay under ignored `build/`; the final `.app` stays at the project root and is also ignored. The next application build must satisfy the versioning and previous-build gate above. Changing the delivery recipe or preparing icon concepts does not imply that a new binary was built.

## Working rules

- Follow repository [AGENTS.md](../AGENTS.md), [CLAUDE.md](../CLAUDE.md), and configured global instructions; this README does not override them.
- Keep editable project files here. Framecraft remains separately installed, not copied into the app.
- Keep this README and the repository [README](../README.md) synchronized in the same batch: Projects row, latest-update date, and changelog.
- Preserve the selected design. Distinguish implemented behavior, source-reported information, and unavailable data. No inferred milestones, fake telemetry, or in-app code viewer.
- Keep generated output and local notes out of Git. Do not commit or publish without authorization.

### UI acceptance rules

- Show the selected Nexus app icon beside Project Control in the header.
- Keep the project register search-free; the full padded row is the selection target and remains a native keyboard-focusable button.
- Keep Open App beside Read README. Discover project-root apps first; use manual location only as the fallback, and never launch during scanning.
- Keep README Overview content in Overview, with separate Architecture, Models, Workflows, Work notes, and Project history tabs.
- Render workflows as connected diagrams, not numbered lists. Preserve explicit branches and independent routes; never invent relationships to fill a diagram.
- Keep the selected visual language, content-sized diagram nodes, horizontal scrolling for wide graphs/tabs, accessible connection descriptions, and reduced-motion behavior.

## Change log

| Version | Date | Updates |
|---|---|---|
| v0.5 / build 5 | 2026-08-30 | Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh. Added nine core regression assertions; passed 57 core checks, 14 store checks, and native type-checking. The reviewed source precedes the new distributable build under the repository build-history rule. |
| v0.4 / build 4 | 2026-08-30 | Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs, and native node-and-arrow diagrams with explicit branch/merge support. Recorded UI acceptance rules. Passed 48 core checks, 14 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/bundle checks, and project-root launch. Preserved v0.3 unchanged, moved v0.2 to Trash, and removed temporary/generated artifacts. Live interaction checks remain unconfirmed. |
| v0.3 / build 3 | 2026-08-30 | Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows. Capture metadata before reads, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening. Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean compilation, strict signature checks, bundle metadata/icon checks, and project-root launch. Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash and removed generated artifacts. The user explicitly authorized building before committing v0.2. Native visual inspection remains unconfirmed. |
| v0.2 / build 2 | 2026-08-30 | Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle. Advanced both version and build. Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch; preserved v0.1 with matching executable/metadata checksums. Native Dock/window inspection remains unconfirmed. The user explicitly authorized this build without committing v0.1; no commit was created. |
| Delivery/design preparation · no new app build | 2026-08-30 | Relocated the unchanged v0.1/build-1 application beside this README. Configured signature-checked root-level delivery with recoverable prior bundles, and recorded the single-digit minor/version-and-build increment policy. Added three icon choices; selection and the next-build authorization were pending at this stage. |
| v0.1 / build 1 | 2026-08-30 | Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress, and explicit folder/README/app actions. Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch. Fixed stale metadata caching found by the refresh test. Retired 33 rejected design artifacts recoverably and removed their obsolete links. Native visual/keyboard inspection remains blocked by macOS capture permission. |
