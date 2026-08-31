# Project Control

Project Control is a native macOS management center for this repository. Understand projects, track structured work notes, follow documented changes, and open a folder or chosen application without viewing or editing source code inside the app.

## Current release

The current release is **v0.7 (build 7)**, delivered as the root-level app. It enlarges project icons and aligns them with the title line, places history dates beside entry titles, and preserves complete architecture tables including models and RAG. Source-backed architecture tables are documented for all six projects. All 128 core checks and 18 store checks passed, followed by clean compilation, bundle checks, and launch. The user authorized building this update without first committing v0.6; source was uncommitted at build time.

The app retains Nexus header branding, full-row navigation without search, automatic project-root app detection, separate README content tabs, and connected workflow diagrams. It uses only Apple's frameworks and needs no account, API key, downloaded model, web server, or paid dependency. Offscreen native rendering checked the new hierarchy, project icons, and tables at regular and minimum window sizes. Live Dock/window, keyboard, file-picker, and reduced-motion interaction checks remain unconfirmed because macOS previously denied screen-capture access. No privacy settings were changed or screen-capture permission retried.

The 2026-08-31 README grouping update presents each project's architecture as category-specific
tables using the existing native renderer. All component rows remain intact. This source-content
refresh does not change the v0.7/build-7 executable.

The subsequent review found no actionable implementation defects. The grouping update passed
162 core checks and 18 store checks, including category-order and native-table regressions.
All 66 component rows were retained exactly once across 28 groups. Native type-checking,
118 README file targets, and offscreen category layouts passed; all six projects were rendered
at both content widths. The existing v0.7 bundle retained its executable/metadata hashes and
passed strict signature and source-metadata checks. Live interaction remains unverified;
process inspection was unavailable. Temporary probe files and compiler/test artifacts are
removed before committing, while the v0.6 recovery bundle is retained.

## Quick start

Requirements: macOS 14 or later, and Xcode with its command-line tools selected. The build targets the current Mac's architecture. This is a local development application, not a notarized public installer.

From the repository root:

```sh
cd "Project Control"
make app
open "Project Control.app"
```

1. Choose **Choose repository…** and select the `Professional Quality` folder, not this subfolder.
2. Select the repository parent for its README **Overview**, **Repository history**, **Read README** action, and **Last read** timestamp. Its indented project children come from the root README's **Projects** table; each project's `README.md` supplies its details when available. Full padded rows are selectable.
3. Open **Work notes → Add note**. Save a title, optional context, and status: **Next**, **In progress**, or **Done**. The ring counts completed notes, not overall project completion.
4. **Overview** shows the README's overview or opening description. **Architecture**, **Models**, and **Workflows** have separate tabs. Tables use native columns, wrapping cells, and source headers; wider tables scroll horizontally. Workflow nodes and arrows show only documented connections. **Project history** stays with its project; repository content no longer occupies the footer.
5. **Open folder** and **Read README** open the item outside the app. **Open App** detects a valid `.app` directly in the project folder, preferring the project-name match, then the folder-name match, then a sole candidate. Multiple unmatched apps appear as choices. If none is available, Open App lets you locate one, opens it, and remembers its path when local storage is writable.

`Command-O` chooses a repository; `Command-R` refreshes it. `Command-N` adds a note while Work notes is visible. The app remembers the last valid repository.

Project rows and detail titles use the preferred top-level app's macOS icon. Local Assistant and Project Control currently have matching app bundles. Projects with no unambiguous app use a neutral project symbol; no remote logo is fetched and no companion app is arbitrarily chosen for branding.

The latest completed application lives directly beside this README as **Project Control.app**, now v0.7/build 7 with Nexus. The previous v0.6/build-6 bundle is preserved in `build/previous.4H03H1/Project Control.app`; its signature and executable, metadata, and icon checksums are unchanged. The superseded v0.5 bundle was retired to macOS Trash, as were older bundles during earlier updates. Temporary render files, test executables, compiler caches, and intermediate icons were removed. Quit the running app before installing an update so reopening starts the new version.

## Versioning and build delivery

- Use `v<major>.<minor>` with a single minor digit from **0 through 9**: `v0.8 → v0.9 → v1.0`, never `v0.10`.
- Every application update advances the release version and increments the integer build number. The next update after v0.7/build 7 is **v0.8/build 8**. A clean recompilation of the same unchanged update does not create a new release.
- Keep `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`, the release description here, the project changelog, and the repository README's project row/date/changelog aligned in the same batch. Do not relabel an existing signed bundle as a newer build.
- Prepare the bundle under ignored `build/`, then check its signature before moving the complete bundle to **Project Control.app** at this project root. `make app` performs this promotion; `make run` opens that root-level app. Never leave the only finished app several folders deep.
- Preserve a replaced root-level bundle in an ignored `build/previous.*` directory. If promotion fails, restore it. These recovery copies can be removed during an explicitly scoped cleanup.
- Before creating a new versioned/distributable build, obey the root build-history gate: commit previous-build changes only with explicit authorization, or obtain explicit permission to proceed without a commit. Icon/design studies and relocating an unchanged bundle are not new application releases.

## How information stays current

```text
Repository README → repository overview, project register, and repository history
Project README    → introduction, architecture, explicit workflows, project history
Local work notes  → completed-note count and progress ring
```

README resolved paths, modification dates, sizes, top-level app-bundle metadata, and executable availability are checked every two seconds while the window is open. Metadata is captured before each read so edits during parsing remain detectable. App validation reads bounded, current `Info.plist` data rather than cached bundle information; executable-permission changes also invalidate the snapshot. Changed documents reload off the interface thread; **Refresh now** forces a read. A repository selection made while loading is queued, with the latest selection taking precedence. A failed repository refresh retains the previous snapshot and shows a warning. **Last read** records a successful snapshot, not a runtime health check. App discovery runs again when Open App is clicked; missing or nonexecutable targets are not launched.

### Extraction rules and limits

- The root README needs a `## Projects` section with a pipe table linking to top-level project folders. Paths must stay within the selected repository, including after resolving symbolic links.
- Table cells preserve escaped pipes and do not require a trailing pipe. Folder aliases share a canonical project identity instead of creating separate note collections.
- Overview uses the README's explicit Overview, About, or What This Does section; otherwise it uses the opening description before second-level sections. It preserves paragraphs and bullet points. Nested architecture, model, workflow, and historical headings belong to their own topics. The root table summary is the fallback when project prose is unavailable. All six registered projects now have project READMEs.
- Architecture preserves the complete current component tables, including model, embedding, RAG, orchestration, and storage roles. An explicit architecture heading takes precedence over a mixed label such as Workflow architecture; its explicit diagrams still remain available in Workflows. Models provides a secondary model-focused extract without subtracting rows from Architecture. Dedicated Models sections remain separate. One block parser keeps tables out of prose, retains source headers and section labels, and preserves the order of prose, bullets, and tables. Inline-code identifiers and paths retain literal underscores. These are source extracts, not AI-generated interpretations; no project architecture is hard-coded in the app.
- Workflow diagrams use explicit `→` or `->` routes under workflow/request headings, including text-only fenced diagrams. Supported block diagrams use `↓` between stages and same-depth `├─→` / `└─→` branches; a following downward stage joins the completed branch group. Separate routes stay separate. Up to eight graphs with at most 32 nodes each are shown. Malformed, unsupported, or code-like diagram blocks are not interpreted. The app does not infer dependencies from ordinary bullets, interpret Mermaid, or invent missing models/workflows.
- Changelog/version-history tables supply up to thirty source-ordered history entries; headings beginning with a release label such as `v1.0` are the fallback. A version mentioned in a project title or protocol heading does not turn its current child sections into history. Open the README for the complete record. Explicit **current source release** or **current release** statements supply release/build labels; unrelated protocol versions do not.
- Fenced source-code blocks are excluded; only unlabelled, `text`, or `plaintext` blocks can supply supported diagrams. Fence-like lines with trailing text do not close a block. Workflow labels require a colon followed by whitespace before the first arrow, so URL colons and later step labels stay intact. Markdown/HTML presentation becomes inert text. Scripts, commands, links, and embedded remote images are not executed or fetched. Each README read is limited to 2 MB.
- **Document health** checks folder/README availability. **Runtime not checked** is intentional: no project builds, tests, processes, or remote health probes run automatically.

## Local data and launch safety

Notes and application choices are saved atomically in the standard per-user Application Support folder, under `Project Control/workspace.json`, outside the repository. Entries are keyed by canonical project path; moving or renaming a repository does not automatically migrate notes. Keep the old file if recovery is needed.

No README is edited. Automatic app discovery scans only the project folder's immediate visible `.app` children, not nested build/recovery folders. Bundle metadata and an executable entry point must be present and contained in the bundle; automatic candidates cannot escape the project through symlinks. A valid remembered manual location is the fallback when automatic detection is ambiguous or unavailable. Launching uses macOS's application-opening service only after Open App or an explicit app choice, without a shell or arguments. Runtime monitoring and arbitrary script launch are not implemented. Malformed local data disables note editing and preserves the file rather than silently resetting it; restore a known-good copy and relaunch. Opening an app does not require writable note storage, although a manual location cannot then be remembered.

The development app is not sandboxed or notarized. Its scanner is restricted to selected-repository READMEs, app-bundle identity metadata, and filesystem metadata; the UI also asks macOS for discovered apps' icons. That is an application-level boundary, not an operating-system sandbox claim. It does not read project source files or executable contents. The app contains no network client.

## Architecture

### Frontend & Presentation

| Component | Responsibility |
|---|---|
| SwiftUI views | Native register, project surface, disclosures, note editor, restrained motion |
| `ReadmeContent` / `RepositoryScreen` | Shared native table/prose rendering and the repository parent's overview/history surface |
| `ProjectIcon` | Preferred project-root app icons and a neutral non-app fallback |
| `WorkflowParser` / `WorkflowDiagram` | Source-defined graph topology and native, content-sized node/connector rendering |
| History presentation | Source project/version titles and standalone ISO date cells appear together in disclosure headings; dates are not repeated in their detail body |

### Backend & Application Logic

| Component | Responsibility |
|---|---|
| `ControlStore` | Selection, window lifecycle, background reload, local mutations, native open actions |
| `RepositoryReader` | Bounded reads, canonical path checks, source snapshots, modification fingerprints |
| `ReadmeParser` | Inert sections, tables, prose, explicit routes, and histories |

### Data & Storage

| Component | Responsibility |
|---|---|
| `WorkspaceStorage` | Atomic JSON persistence; malformed data is never reset automatically |

### Integrations & Security

| Component | Responsibility |
|---|---|
| `ApplicationLocator` | Top-level bundle discovery, validation, and deterministic app preference |
| AI/runtime boundary | No LLM, embedding service, RAG index, network client, or automatic project execution; the app displays README-defined architecture rather than inferring it |

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

`make test-core` covers README topic ownership, structured tables and literal identifiers, overview formatting, explicit diagram branches/merges, source-code exclusion, histories, release/build parsing, missing documents, refresh fingerprints, app discovery/ambiguity/symlink boundaries, note persistence, and corrupt data. `make test-store` checks queued repository changes, parent/child selection across refreshes, note mutations, save failures, and automatic/manual app resolution using isolated storage/preferences; it never launches applications or reads the user's workspace. `make test` runs both focused targets. Disposable app fixtures are never executed and are removed afterward. A read-only smoke check also checks this repository's register and Local Assistant's model tables, five request routes, and RAG diagram. No other subproject's suite runs.

For v0.2, focused packaging checks confirmed all ten icon sizes and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, unchanged v0.1 recovery files, and launch from the root-level v0.2 app. Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead. This does not substitute for actual Dock inspection. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.

For v0.3, clean native compilation, strict signature validation, source/bundle metadata equality, and project-root process launch passed. The packaged Nexus icon is byte-identical to the verified v0.2 icon. The preserved v0.2 bundle retains its valid signature and original executable, metadata, and icon checksums. The user explicitly permitted building v0.3 before committing v0.2. Generated compiler caches and intermediate icon files were removed after verification.

For v0.4, all 62 focused checks and native type-checking passed, followed by a cache-free native build, strict signature and source/bundle metadata checks, unchanged Nexus icon payload, project-root launch, and checksum-matched v0.3 recovery checks. An offscreen `NSHostingView` rendered the real Overview and workflow components without capturing any screen; this checked layout, not live interaction. A test-fixture comparison was corrected to use canonical macOS paths. Temporary render sources/images, test executables, the failed fixture/report, compiler caches, and intermediate icons were removed. The v0.3 source/build work was already committed before this build began.

The subsequent v0.5 review reproduced four defects using disposable fixtures: ASCII arrows inside text fences were rejected, a versioned project title incorrectly owned all current sections as history, cached bundle metadata survived executable changes, and permission-only executable changes did not trigger refresh. All four are fixed. Nine added core assertions cover these regressions plus binary/malformed/oversized metadata and executable-directory rejection. All 71 focused checks and native type-checking passed. No synthetic app was launched. The reviewed source was committed in separate parser, app-discovery, UI, and documentation groups before clean distributable compilation. Strict root-bundle signature checks, source/bundle metadata equality, unchanged Nexus icon, and project-root process launch passed; the preserved v0.4 bundle retains its original executable/metadata/icon checksums and valid signature. The superseded v0.3 bundle was moved to Trash and disposable probes, test binaries, compiler caches, and intermediate icons were removed. No build-rule exception was needed. Live UI interaction remains unconfirmed; the unchanged view layout has the earlier v0.4 offscreen evidence only.

For v0.6, all 71 core checks and 18 isolated store checks passed, as did native type-checking. Added regressions cover leading blank lines, adjacent prose/tables, escaped pipes, distinct source headers, literal model/path identifiers, root overview refresh, parent/child selection, and app preference for icons. Offscreen native rendering checked repository/project layouts at 900×660 and 1160×840, the real Local Assistant table component at both content widths, a three-column scrolling table, real app icons, and neutral fallback symbols. Native icon-service access required the render probe outside the agent sandbox; it rendered only its own never-shown views and captured no desktop pixels. A cache-free build passed strict signature checks, source/bundle metadata equality, unchanged Nexus icon checks, and launch from the project-root v0.6 bundle. The previous v0.5 bundle retained its signature and executable/metadata/icon checksums. The superseded v0.4 bundle was moved to Trash, and temporary render sources/images, test executables, compiler caches, and intermediate icons were removed. Live UI interaction remains unconfirmed; optional code review and formal verification have not run for this batch.

For v0.7, all 128 core checks and 18 isolated store checks passed, along with native type-checking. Added cases cover complete architecture tables across all six projects, mixed architecture/workflow headings, source ordering, and dated/undated histories; an empty-date separator regression found during testing was corrected. Offscreen native rendering checked all six project headers at minimum and regular content widths, title-line icon alignment, dated history headings, and Local Assistant's complete 15-row architecture table. Wrapped cells exposed uneven per-cell dividers; full-width grid dividers corrected the layout and were checked at both widths. These probes rendered only their own never-shown views, without capturing desktop pixels. A cache-free native build passed strict signature, source/bundle metadata, unchanged Nexus icon, project-root launch, and checksum-matched v0.6 recovery checks. Cleanup left only the required v0.6 recovery bundle under `build/`; v0.5 was retired to Trash, though a final Trash inventory was denied by macOS and was not retried. The user explicitly permitted this build before committing v0.6. Live UI interaction, optional code review, and formal verification had not run at delivery; no commit was made at that point. The later category-grouping review and verification are recorded under Current release.

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
- Keep a selectable repository parent above its indented projects. Repository overview/history, Read README, and Last read belong on that parent's screen, not in a footer.
- Show the same project icon in its sidebar row and detail header when an unambiguous project-root app exists; otherwise use a neutral symbol.
- Size detail icons consistently with the repository reference and align their center with the project-name line, not the combined title/version stack. Check real and fallback icons with short and wrapped names.
- Keep Open App beside Read README. Discover project-root apps first; use manual location only as the fallback, and never launch during scanning.
- Keep README Overview content in Overview, with separate Architecture, Models, Workflows, Work notes, and Project history tabs.
- Render README tables as native headers and cells, never as a raw or duplicated Markdown paragraph. Preserve model identifiers and paths. Keep regressions for leading blank lines, adjacent prose, escaped pipes, and underscore-containing identifiers.
- Keep every documented architecture-table row visible, including models, embeddings, RAG, orchestration, retrieval, and storage. Models is a secondary view, not a reason to remove architecture responsibilities. Check coverage for every registered project and never label an absent framework as installed.
- Group architecture components under relevant child headings: AI & Intelligence, Frontend & Presentation, Backend & Application Logic, Data & Storage, Integrations & Security, and Build & Delivery. Give each group its own native table, retain every component once under its primary responsibility, and omit empty groups. Backend & Application Logic includes on-device/browser logic and does not imply a network server. Keep category headings in the README so later edits update the app automatically.
- Show a history row's standalone date beside its project/version title; the expanded body contains the change description without a duplicate date.
- Render workflows as connected diagrams, not numbered lists. Preserve explicit branches and independent routes; never invent relationships to fill a diagram.
- Keep the selected visual language, content-sized diagram nodes, horizontal scrolling for wide graphs/tabs, accessible connection descriptions, and reduced-motion behavior.

## Change log

| Version | Date | Updates |
|---|---|---|
| README grouping · no new app build | 2026-08-31 | Grouped all six projects' architecture components into relevant category tables using existing native headings and tables. Preserved every source row and documented the category convention. The v0.7/build-7 application is unchanged; Observatory's embedded README advances separately to v2.1. Passed 162 core checks, 18 store checks, native type-checking, exact row/group checks, README links, native offscreen layouts, and unchanged-bundle identity/signature checks. Review found no actionable defects; live interaction remains unverified. |
| v0.7 / build 7 | 2026-08-31 | Delivered larger title-aligned project icons, dates beside history headings, and complete architecture tables with full-width row dividers. Added source-backed tables to all six project READMEs and retained mixed architecture/workflow sections. Passed 128 core checks, 18 store checks, native type-checking, offscreen header/history/table layouts, clean compilation, strict bundle checks, and root-level launch. Preserved v0.6 unchanged, retired v0.5 to Trash, and removed temporary/generated artifacts. The user permitted building before committing v0.6; source was uncommitted at build time. Live interaction remains unconfirmed. |
| v0.6 / build 6 | 2026-08-30 | Added structured native README tables, preserved model/path identifiers, preferred project icons, and a selectable repository-parent screen replacing footer content. Added table/navigation acceptance rules and focused regressions. Passed 71 core checks, 18 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/metadata/icon checks, and root-level launch. Preserved v0.5 unchanged, retired v0.4 to Trash, and removed temporary/generated artifacts. Live UI interaction remains unconfirmed; source was uncommitted at delivery. |
| v0.5 / build 5 | 2026-08-30 | Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh. Added nine core regression assertions; passed 57 core checks, 14 store checks, native type-checking, clean compilation, strict signature/metadata/icon checks, and root-level launch. Committed reviewed source before building, preserved v0.4 unchanged, retired v0.3 to Trash, and removed temporary/generated artifacts. Live UI interaction remains unconfirmed. |
| v0.4 / build 4 | 2026-08-30 | Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs, and native node-and-arrow diagrams with explicit branch/merge support. Recorded UI acceptance rules. Passed 48 core checks, 14 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/bundle checks, and project-root launch. Preserved v0.3 unchanged, moved v0.2 to Trash, and removed temporary/generated artifacts. Live interaction checks remain unconfirmed. |
| v0.3 / build 3 | 2026-08-30 | Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows. Capture metadata before reads, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening. Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean compilation, strict signature checks, bundle metadata/icon checks, and project-root launch. Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash and removed generated artifacts. The user explicitly authorized building before committing v0.2. Native visual inspection remains unconfirmed. |
| v0.2 / build 2 | 2026-08-30 | Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle. Advanced both version and build. Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch; preserved v0.1 with matching executable/metadata checksums. Native Dock/window inspection remains unconfirmed. The user explicitly authorized this build without committing v0.1; no commit was created. |
| Delivery/design preparation · no new app build | 2026-08-30 | Relocated the unchanged v0.1/build-1 application beside this README. Configured signature-checked root-level delivery with recoverable prior bundles, and recorded the single-digit minor/version-and-build increment policy. Added three icon choices; selection and the next-build authorization were pending at this stage. |
| v0.1 / build 1 | 2026-08-30 | Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress, and explicit folder/README/app actions. Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch. Fixed stale metadata caching found by the refresh test. Retired 33 rejected design artifacts recoverably and removed their obsolete links. Native visual/keyboard inspection remains blocked by macOS capture permission. |
