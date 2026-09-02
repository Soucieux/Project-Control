# Project Control

<!-- project-control:section=overview -->
## Overview

Project Control is a native macOS management center for this repository. Understand projects, track structured work notes, follow documented changes, and open a folder or chosen application without viewing or editing source code inside the app.

<!-- project-control:section=release -->
## Current release

The current source and signed local release are **v2.5 (build 16)**. Each project detail screen now
uses one compact glass card above its tabs instead of separate identity, action, and Document Health
cards. The icon, project name, and version are top-aligned beside the notes gauge. **Open folder**,
**Read README**, **Open App**, its optional application menu, and the detection message share a lower
row with document availability and the explicit **Runtime not checked** status. The card uses a
16-point content inset and adapts its action/status grouping to the available width. An eight-point
gap brings the tabs closer to their content. Existing warning messages, below-tab content styling,
notes, history, repository activity, navigation, artwork, and lock behavior are unchanged.

Complete native type-checking, a cache-free optimized build, strict signature and bundle-identity
checks, and live regular/minimum-window inspection passed. The subsequent authorized code review
found no actionable issues; verification repeated a cache-free optimized build, strict package checks,
and live narrow-window header inspection. The initial delivery was uncommitted; this checkpoint
records the reviewed source and documentation before the next implementation.

## Quick start

Requirements: macOS 14 or later, and Xcode with its command-line tools selected. The build targets the current Mac's architecture. This is a local development application, not a notarized public installer.

From the repository root:

```sh
cd "Project Control"
make app
open "Project Control.app"
```

1. Choose **Choose repository…** and select the `Professional Quality` folder, not this subfolder.
2. Use the brand row at the top of the rail to expand or collapse navigation. Select the repository parent for its README **Overview**, **Repository history**, **Commit activity**, and **Last read** timestamp. The pinned rail footer opens the repository README, provides repository actions, and locks the display; its status block shows the installed version/build. Commit activity reads local Git timestamps, changed paths solely for project mapping, and ref identities; hover a populated month for the project distribution. Its project hierarchy comes from the root README's **Projects** table; each project's `README.md` supplies its details when available. Full padded rows are selectable, and every collapsed icon—including the footer actions—shares one centerline.
3. Open **Work notes → Add note**. Save a title, optional context, and status: **Next**, **In progress**, or **Done**. The ring counts completed notes, not overall project completion.
4. **Overview** shows the README's overview or opening description. Untitled paragraph-and-bullet content below the tabs uses one rounded translucent surface; source headings remain outside their existing table or content box. **Architecture**, **Models**, and **Workflows** have separate tabs. Tables use native columns, wrapping cells, and source headers; wider tables scroll horizontally. Workflow nodes and arrows show only documented connections. **Project history** stays with its project; repository content no longer occupies the footer.
5. The project identity card also contains **Open folder**, **Read README**, **Open App**, and compact **Document Health** information. Its action/status row adapts at narrower widths. Document Health reports folder/README availability, not runtime health. Open folder and Read README open the item outside the app. Open App detects a valid `.app` directly in the project folder, preferring the project-name match, then the folder-name match, then a sole candidate. Multiple unmatched apps appear as choices. If none is available, Open App lets you locate one, opens it, and remembers its path when local storage is writable.
6. Use **Lock** in the rail footer to temporarily replace all project content with the local artwork view. It requires no password, changes no files, has no footer strip, and restores the interface from the centered **Unlock** button.

`Command-O` chooses a repository; `Command-R` refreshes it. `Command-N` adds a note while Work notes is visible. The app remembers the last valid repository.

Project rows and detail titles use the preferred top-level app's macOS icon. Local Assistant and Project Control currently have matching app bundles. Projects with no unambiguous app use a neutral project symbol; no remote logo is fetched and no companion app is arbitrarily chosen for branding.

The signed **Project Control.app** beside this README is v2.5/build 16. The replaced v2.4/build-15
bundle is preserved under `build/previous.6HZ7jk`; v2.3/build 14 remains under
`build/previous.bIh8aG`, and older documented recovery bundles remain unchanged.

## Sidebar classification

The repository's [README content contract](../README.md#readme-content-contract-for-project-control)
owns the first three labelled items in every **Professional scope** cell: **Category**,
**Technical scope**, and **Technologies**. Categories appear in first-appearance order, with projects
retaining their register order. They are collapsible and show counts. Each project row retains its
icon and note progress. Technical scope is a quiet text line; each documented technology or approach
is a separate content-sized tag, wrapping as needed.
The current groups are **AI Applications**, **Agent Workspaces**, **Project Management**,
**Knowledge & Learning**, and **Utility Collections**. Names and memberships are not hard-coded;
the compact rail assigns neutral position markers without inferring a category's capabilities.

A missing or blank category uses **Uncategorized**. Missing scope and technology values are omitted.
Older separate classification columns remain compatible and override same-named scope labels when
present, including explicit blanks; current READMEs must not duplicate both formats. The former
**AI usage** column is ignored and never converted into tags. Authors keep actual technologies in
**Technologies**, following the root contract and the Project Control-only [tag policy](../AGENTS.md#project-control).
Root README edits regroup projects and refresh tags through the existing background check, without
a rebuild or changes to notes. Collapse state is local to the open window and resets on repository
changes. A selected project that changes category is revealed in its destination group. A stale
project README does not block valid root metadata.

## Build delivery

**Change-history numbering:** Project Control uses marketing versions and integer build numbers.
Follow the repository-wide [version and build-number policy](../README.md#version-and-build-number-policy).

- Prepare the bundle under ignored `build/`, then check its signature before moving the complete bundle to **Project Control.app** at this project root. `make app` performs this promotion; `make run` opens that root-level app. Never leave the only finished app several folders deep.
- Preserve a replaced root-level bundle in an ignored `build/previous.*` directory. If promotion fails, restore it. These recovery copies can be removed during an explicitly scoped cleanup.

<!-- project-control:section=workflows -->
## How information stays current

The repository [README content contract](../README.md#readme-content-contract-for-project-control)
is the single authoring reference for supported section markers, category tables, exclusions,
legacy headings, and recovery. Keep markers with their owning headings when reorganizing a README.

```text
README saved → background content check → mapped section parsing → native screen update
Repository Projects table → registered project READMEs → project navigation and content
Local Git refs → timestamps plus project-folder paths → monthly totals and hover distributions
Local work notes → completed-note count and progress ring
```

### Synchronization implementation

RepositoryReader reads only bounded repository/project READMEs, read-only Git timestamps/ref
identities, and app identity metadata. GitActivityReader invokes `/usr/bin/git` directly without a
shell, using fixed `log --all --format=%ct` and `show-ref --head --hash` arguments.
A background check runs approximately every two seconds while the app view is active. It compares
fresh metadata, Git refs, and CryptoKit SHA-256 content digests, so same-size README edits and ref
changes are detected. It captures identities before parsing so a concurrent edit triggers a later
refresh. ControlStore publishes a complete snapshot on the main actor and preserves existing
selection and notes.

An unreadable or invalid project README keeps that project's last good content visibly stale;
other projects still update. A valid removal of a mapped section clears the old section. An invalid
root register/read keeps the last good repository snapshot with a warning. Repairs recover on the
next check, including a failed initial restoration; Refresh now forces a read. Last read reports
the snapshot read time, not an assertion that stale project content or runtime health is current.

### Extraction rules and limits

- Section markers are allowlisted, inert metadata. Marked documents are opt-in; unmarked
  documents retain legacy heading recognition. This app does not interpret arbitrary README instructions.
- Tables preserve source headers, rows, escaped pipes, literal model/path identifiers, and order.
  Wider native tables scroll horizontally. Models remains a secondary view without removing
  model facts from Architecture.
- Workflow diagrams use explicit `→` or `->` routes and supported unlabelled/`text`/`plaintext`
  fenced diagrams. Downward stages and same-depth branches retain documented merges.
  At most eight graphs with 32 nodes each are displayed; ordinary bullets do not invent connections.
  Unsupported Mermaid or code-like blocks remain README-only.
- History tables supply the latest thirty source-ordered entries. Standalone dates appear beside
  the project/version title; the detail body does not repeat them. Mapped release text supplies
  the header's version/build label, not arbitrary historical or protocol versions.
- Commit activity uses the complete unfiltered `git log --all` record list. Valid years render newest
  first. Changed paths are mapped only to current registered top-level project folders and never opened.
  A multi-project commit contributes once to the cell total and once to each affected project's hover
  count; records with no mapped project path appear as Repository-level. Invalid timestamps
  contribute to the total but not monthly buckets; future-dated records contribute to the total and
  their year while future cells remain dimmed and conceal counts. Distinct valid years are not treated
  as a continuous range. No README filter, project classification, history limit, or pagination applies.
- Each README read is limited to 2 MB and constrained to canonical paths within the repository.
  Fenced source code is excluded; Markdown/HTML is inert. No scripts, commands, remote images,
  model downloads, or source-code scans run.
- App discovery validates bounded current Info.plist metadata and executable availability;
  discovery never launches apps. Missing or nonexecutable targets are not launched.
- Document warnings describe source availability, not runtime health. No project build/test/process
  or remote health check is triggered automatically.

## Local data and launch safety

Notes and application choices are saved atomically in the standard per-user Application Support folder, under `Project Control/workspace.json`, outside the repository. Entries are keyed by canonical project path; moving or renaming a repository does not automatically migrate notes. Keep the old file if recovery is needed.

No README is edited. Automatic app discovery scans only the project folder's immediate visible `.app` children, not nested build/recovery folders. Bundle metadata and an executable entry point must be present and contained in the bundle; automatic candidates cannot escape the project through symlinks. A valid remembered manual location is the fallback when automatic detection is ambiguous or unavailable. Launching uses macOS's application-opening service only after Open App or an explicit app choice, without a shell or arguments. Runtime monitoring and arbitrary script launch are not implemented. Malformed local data disables note editing and preserves the file rather than silently resetting it; restore a known-good copy and relaunch. Opening an app does not require writable note storage, although a manual location cannot then be remembered.

The development app is not sandboxed or notarized. Its scanner is restricted to selected-repository
READMEs, Git commit timestamps/changed paths/ref identities, app-bundle identity metadata, and filesystem metadata;
the UI also asks macOS for discovered apps' icons. That is an application-level boundary, not an
operating-system sandbox claim. It does not read commit content, project source files, or executable
contents. The app contains no network client.

<!-- project-control:section=architecture -->
## Architecture

### Frontend & Presentation

| Technology or concept | Use in this project |
|---|---|
| SwiftUI | Builds the black chassis, shared-artwork detail layer, animated hierarchy rail, artwork lock, project screens, work-note editor, History, responsive commit-activity grid, native tables, and restrained motion. ReadmeContent and RepositoryScreen render the selected source content. |
| AppKit | Provides macOS icons, application/window integration, file pickers, and explicit open actions; ProjectIcon keeps app and fallback artwork consistent. |

### Backend & Application Logic

| Technology or concept | Use in this project |
|---|---|
| Swift | Native application language. ControlStore owns selection and background reloads; RepositoryReader reads bounded source documents and activity snapshots; ReadmeParser handles sections, tables, and history. |
| Swift concurrency | Runs README reads and change detection off the interface thread; updates the observable store on the main actor. |
| Foundation | Provides bounded file reads, canonical paths, Git process execution, calendar grouping, dates, regular expressions, and structured-data encoding. |
| Directed graphs | WorkflowParser and WorkflowDiagram render documented nodes, arrows, branches, and merges without inventing relationships. |

### Data & Storage

| Technology or concept | Use in this project |
|---|---|
| Markdown | Repository/project README files are the content baseline. Stable section markers select the app-visible subset. |
| Git metadata | Complete local reachable-commit timestamps supply monthly activity; changed paths map commits to registered projects for hover details; ref object identities trigger refresh without reading messages, authors, or file contents. |
| JSON | WorkspaceStorage atomically saves local work notes and app choices outside the repository; malformed data is never reset automatically. |
| UserDefaults | Remembers the last successfully selected repository separately from work-note storage. |

### Integrations & Security

| Technology or concept | Use in this project |
|---|---|
| CryptoKit | Computes bounded README and Git-ref content digests for refresh detection. |
| Uniform Type Identifiers | Constrains the native application picker to application bundles. |
| Canonical path validation | Keeps README reads inside the selected repository. ApplicationLocator validates top-level app identity; discovery never launches apps. |

No LLM, embedding service, RAG index, network client, or automatic project execution is included. The app displays documented facts rather than inspecting project code.

## Project structure

```text
Project Control/
├── Sources/Core/       # README extraction, models, constants, local storage
├── Sources/App/        # Native state, layered interface, shared detail/lock artwork
├── Resources/          # Bundle identity, version, and editable Nexus icon
├── Tests/              # Focused synthetic and read-only repository checks
├── Makefile            # Local build, focused checks, launch
├── Project Control.app # Latest completed app; ignored by Git
└── build/              # Staging, caches, recovery copies; ignored by Git
```

## Design reference

The SwiftUI source is the canonical implementation of the approved cinematic direction.
`CinematicBackground.swift` owns the transparent-window bridge and the one local artwork source
shared by the detail and lock presentations; `DesignSystem.swift` owns the sage/lime/ink palette,
rounded cards, black-chassis geometry, and 0.62–0.78 second motion; `ControlWindow.swift` lets the
native window own the outer corners while it composes the chassis, inset artwork surface,
reference-style rail, hierarchy, and lock state.
The superseded Vector/Lens HTML and JavaScript preview is retained in Git history rather than as
an active project file, preventing a stale reference from being mistaken for the current interface.

**A · Nexus** is selected. Its [editable vector master](Resources/ProjectControl.svg) and [transparent 1024-pixel PNG master](Resources/ProjectControl.png) preserve the approved geometry and palette. The superseded three-choice comparison was moved to macOS Trash under `Project Control - retired icon study 2026-08-30`, with its checksum unchanged. `make icons` uses macOS `sips` and `iconutil` to package standard/Retina representations from 16 through 1024 pixels into `ProjectControl.icns`. `make app` includes that icon automatically; no extra build dependency is required. When changing the vector, export its matching 1024×1024 RGBA PNG as well; the build uses the checked-in PNG because the native SVG decoder could not read this artwork reliably.

Native controls use state-driven SwiftUI transitions with Reduce Motion and Reduce Transparency
support. There is no perpetual scanning, spinning, fabricated activity, remote artwork, WebView,
or runtime network dependency.

The 33 rejected visual studies and screenshots were removed from the working project and preserved in macOS Trash, in the folder named `Project Control - retired designs 2026-08-30`. All 33 file checksums matched after the move. Their obsolete conversation-preview links were removed; the three selected-reference links remain intact.

## Development and focused checks

### v2.5 delivery evidence

The v2.5/build-16 source combines project identity, actions, and Document Health in one pre-tab card.
The identity is top-aligned with the notes gauge; the action controls, application-detection message,
document availability, and runtime disclaimer form a compact lower grouping. The card alone uses a
16-point inset, leaving other glass-card styling unchanged. The action/status row drops its title-column
offset or stacks when needed, and the tab-to-content gap is eight points. No action, launch-selection,
warning, note, README-parsing, or repository-data behavior changes.

Complete native type-checking passed, followed by a cache-free optimized build and strict signed-bundle
checks. Source and bundle metadata both identify v2.5/build 16; the executable is arm64 and the bundled
icon is present. Live app inspection covered Local Assistant and the longer Python Accomplishments
title at regular and minimum window sizes, confirming visible actions, detection text, integrated health,
notes gauge, and unclipped tab/content layout. Core/store logic was unchanged, so those suites were not
rerun. The subsequent authorized review found no actionable issues. Verification repeated a cache-free
optimized build, strict signature/metadata/arm64/icon checks, and live narrow-window Local Assistant and
Python Accomplishments header inspection. The initial delivery preceded that review and was uncommitted.
The prior v2.4/build-15 bundle remains
recoverable under `build/previous.6HZ7jk`; superseded same-version candidates and generated intermediates
were removed after the final package checks.

### v2.4 delivery evidence

The v2.4/build-15 source removes only the artificial whole-shell SwiftUI clip and outline; the native
window owns the outside corners while the full black chassis and independently rounded detail surface
remain. The three-point reveal and visually tuned 18-point detail radius align all four rendered detail
corners with the native window instead of deriving the radius from an assumed outer value. Lock and
unlock use an opacity-only transition, and the lock artwork has no competing outer mask or outline.
`ReadmeContent` detects views made only of paragraph/bullet prose and encloses those untitled areas in
the established rounded translucent plane. Heading-led content, native tables, Workflow titles and
diagrams, history disclosure rows, work-note rows, and every area above the tabs retain their existing
presentation. A lower-third sage halftone is drawn inside the shared active/lock artwork and repeated
above the normal detail blur so its dots remain visible in the same lower position. The clear lock
view also places a denser full-frame matrix of dots and short marks over the artwork. Repository
README, repository actions, and Lock controls use matching book, adjustment, and lock rows with longer
balanced Open README file, Repository menu, and Lock application labels beneath a hierarchy separator;
compact workspace/sync status and the live bundle version follow a second separator and align to the
visible icon column rather than the rail edge.
All footer icons remain centered in the collapsed rail,
and the detail header keeps identity/context without duplicated actions. All 332 core checks and 39
store checks passed. Optimized arm64 compilation, strict signing, exact source/bundle v2.4/build-15
metadata, icon checks, root-bundle promotion, and live inspection of repository/project Overviews,
Architecture, Workflows, expanded/collapsed rails, lock artwork, halftone density, and the native/detail
curves passed. The complete code review found no actionable source findings. Formal verification
repeated a clean optimized rebuild, strict signing, source/bundle identity, arm64/icon checks, and live
expanded/collapsed, Overview, Workflows, and lock-state inspection. The replaced v2.3/build-14 bundle
is preserved at `build/previous.bIh8aG`.

### v2.3 delivery evidence

The v2.3/build-14 source adds the read-only repository Commit activity tab and its project-aware
hover distributions. The completed visual correction uses one rounded black chassis as the full
window base, exposes that chassis as the left rail and detail perimeter, and places one rounded
light-artwork detail panel above it. The active detail view blurs the same artwork that the lock view
shows clearly. The expanded brand row and collapsed 40-point icon column share one leading axis;
top navigation, scrolling project groups, and the pinned local-only status remain structurally
separate. Reduce Motion suppresses transitions, while Reduce Transparency retains the solid detail
fallback. Eight focused activity core checks, one store check, native type-checking, optimized
compilation, strict signing, metadata, executable, icon, and live expanded/collapsed/lock checks
passed. Optional code review and formal verification did not run. The activity implementation is
committed in `bb0689e`, the shell implementation is committed in `a01102b`, and this documentation
checkpoint records their delivered state.

### v2.2 delivery evidence

The v2.2/build-13 source moves Category, Technical scope, and Technologies into the first three
labelled list items of every root-register Professional scope cell, allowing the human-facing table
to use three readable columns. The parser reads those labels case-insensitively and strips display
markup. Older separate columns remain compatible and override same-named scope labels when present,
including explicit blanks; the retired AI-usage column remains ignored. Existing glass UI, project
content, notes, launch behavior, and synchronization paths are unchanged. All 20 focused core checks
and 5 isolated store checks passed, including the new labelled-scope, blank-value, compatibility,
and precedence regressions. Complete native type-checking, cache-free optimized compilation, strict
signing, exact source/bundle metadata equality, arm64 executable and icon checks, bundle promotion,
and a separate-instance project-root launch passed. Source is committed in `ad84aa7`. The v2.1 bundle
is preserved at `build/previous.ftKKT9`; generated compiler/icon intermediates and the smoke process
were removed. Optional code review and formal verification did not run.

### v2.1 delivery evidence

The v2.1/build-12 source removes every outer shell inset, keeps title-bar clearance inside the
navigation rail, and replaces desktop-only sampling with a full-window local scene and
`withinWindow` native material. Normal appearance adds no opaque tint above the material; Reduce
Transparency alone uses the existing strong surface. The lock artwork shares the same scene and
also fills the window. README parsing, classifications, notes, app discovery, tabs, native tables,
and diagrams are unchanged. Complete native type-checking and a controlled 1320×760 render passed;
the render confirmed full edge coverage and visible scene variation across the content plane and was
inspected for boundary, backdrop, and readability. After the source and dual-README checkpoints were
committed, cache-free optimized compilation, strict signing, source/bundle metadata equality,
icon/executable checks, bundle promotion, and a separate-instance root launch passed. The v2.0 bundle
is preserved at `build/previous.Yj7LyM`; generated intermediates and the smoke process were removed.
Core/store behavior was unchanged and those suites were not rerun. Optional code review and formal
verification did not run.

### v2.0 source checkpoint

The v2.0/build-11 source implements the outlined rounded shell, transparent native window, real desktop blur,
aligned collapsible rail, staggered project-row disclosures, hidden scroll indicators, and centered
artwork unlock. Offscreen inspection removed a redundant lock caption that crossed the fortress
silhouette. README parsing, classifications, notes, application discovery, content tabs,
tables, and workflow data paths remain unchanged. All **323 core checks** and **39 store checks**
passed, followed by complete native type-checking. The first signed candidate was rejected after
the user's screenshot exposed its internal green field; `0e07484` provides the transparent-window
and behind-window correction. After the source and dual-README checkpoints were committed, a clean
optimized build passed strict signing, source/bundle metadata equality, and separate-instance launch.
Offscreen repository/project renders confirmed the outlined shell, rounded hierarchy, real app icons,
fixed-height content, and centered lock control; behind-window sampling itself requires the live window.
ScreenCaptureKit remained denied, so final live interaction is not claimed. Optional code review and
formal verification have not run. The superseded v2.0 bundle and generated intermediates were removed;
the v1.0 recovery remains unchanged.

### v1.0 delivery evidence

The parser, sidebar, scoped tag policy, and root register are updated in source. Passed **19
focused parser/register checks**, **5 store checks**, native type-checking, and **24 native
tag-layout cases** at 64-, 148-, and 320-point widths, including empty and long labels. Offscreen
views at 900×660 and 1160×840 and a six-project tag panel were inspected. An isolated render
needed normal macOS icon-service access outside the agent sandbox; it captured only its own
never-shown views, not desktop pixels. No screen-recording permission was changed or retried.
These checks do not establish live scrolling, keyboard interaction, or installed-app behavior.
After the user-authorized source and release-record commits, a cache-free optimized arm64
build was promoted to the project root. Strict signing, exact source/bundle metadata equality,
v1.0/build-10 identity, unchanged Nexus icon bytes, and a fresh root-level process launch passed.
The smoke-test process remained running for at least 47 seconds and was then closed; no existing
Project Control process was present before the check. This confirms launch, not live interaction.
The preserved v0.9 bundle at `build/previous.6S5wt3/Project Control.app` retains its valid signature
and exact pre-build executable, metadata, and icon checksums. The documented v0.8/v0.7 recoveries
are retained. Generated compiler caches and intermediate icon files were removed; these can be
regenerated. No desktop capture or privacy-setting change was attempted.

Run only the classification regressions from this project folder:

```sh
make test-core test-store TEST_ARGS=--classification
```

These exercise optional/reordered columns, literal technology names, empty/duplicate tags,
retired AI metadata, tag edits/removals, the actual six-project register, and stale-project
refresh while preserving selection and notes. Omitting `TEST_ARGS` retains the existing test
targets' complete behavior.

### v0.9 delivery evidence

The focused checks cover case-insensitive and reordered optional metadata columns, custom
category names, missing/blank/short rows, duplicate projects, source ordering, README-triggered
regrouping, and preservation of selection/notes while project content is stale. The new source
fixtures and the live six-project register passed: **312 core checks and 38 store checks**.

Native type-checking and a cache-free optimized build passed. Isolated, never-shown views were
rendered at 900×660 and 1160×840, plus a tall register showing all five categories and a
minimum-width long-repository-name case. The header icon/title alignment, separate ellipsis,
wrapping badges, counts, selection highlight, and real app/fallback icons were inspected.
The design pass retains the navy/icy-blue palette and uses informational badges, not health scores.
These renders do not establish live scrolling, collapsing, keyboard, menu, or window-chrome behavior.

macOS denied live window capture; no capture permission or privacy setting was changed or retried.
The render probe and icon packager needed normal macOS icon-service access outside the agent
sandbox; neither captured the desktop. Strict signing, matching source/bundle metadata,
unchanged Nexus icon bytes, and root-level launch passed. Only the newly started background
smoke-test instance was closed; the existing app session was preserved.

The preceding v0.8 source/build work was already committed before this build. Its replaced
bundle retains its original executable, metadata, icon checksums, and valid signature under
`build/previous.JxnKxh/Project Control.app`. Temporary render sources/images, test binaries,
compiler caches, and intermediate icons were removed. This v0.9 batch was uncommitted at
delivery; its retained header/category implementation is now captured with v1.0 in `9f3e399`,
`eb643cb`, and `2a512b8`, not in a separate v0.9 release commit. Optional code review and
formal verification have not run for that batch.

### v0.8 delivery evidence

The **v0.8 (build 8)** release was delivered as **Project Control.app** beside this
README. It adds explicit README section routing, background content-digest checks, visible
stale-source recovery, and 117 individually named architecture technologies/concepts across
all six projects. The selected design, Nexus icon, navigation, notes, diagrams, and app discovery remain.

Review corrected an old-repository polling race during repository switches, required a real
register-table header, and kept a failed different-root choice from falsely marking the current
repository stale. Final verification passed **303 core checks and 34 store checks**, native
type-checking, clean compilation, strict signing and source/bundle metadata checks. A disposable
copy without the polling guard failed the new repository-switch regression at the expected assertion.
No actionable findings remain in this reviewed scope.

Native offscreen rendering produced all six architecture views at 583- and 843-point content
widths; minimum-width views, a regular-width representative, and the stale warning were inspected.
This is layout evidence, not live window/keyboard/file-picker verification. An existing app process
was left untouched; quit and reopen the root-level app to load the new binary. No privacy setting
or capture permission was changed.

The previous v0.7 source was committed before this update, and its unchanged bundle remains
recoverable under `build/previous.sH4KB5/Project Control.app`. The obsolete v0.6 recovery and
superseded pre-review v0.8 candidate were moved to macOS Trash under
`Project Control - retired bundles 2026-08-31-sync`. Temporary test, mutation, rendering, and
compiler/icon artifacts were removed. The separate Observatory v2.2 snapshot was rebuilt with
permission to leave its pending Atlas/release work uncommitted.


From this project folder:

```sh
make test
make app
```

`make test-core` covers README topic ownership, structured tables and literal identifiers, overview formatting, explicit diagram branches/merges, source-code exclusion, histories, release/build parsing, missing documents, refresh fingerprints, commit totals/months/intensities/future states, app discovery/ambiguity/symlink boundaries, note persistence, and corrupt data. `make test-store` checks queued repository changes, parent/child selection across refreshes, commit-activity publication, note mutations, save failures, and automatic/manual app resolution using isolated storage/preferences; it never launches applications or reads the user's workspace. `make test` runs both focused targets. Disposable app fixtures are never executed and are removed afterward. Read-only smoke checks also cover the live repository register, Git timestamp/ref access, and Local Assistant's model tables, five request routes, and RAG diagram. No other subproject's suite runs.

For v0.2, focused packaging checks confirmed all ten icon sizes and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, unchanged v0.1 recovery files, and launch from the root-level v0.2 app. Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead. This does not substitute for actual Dock inspection. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.

For v0.3, clean native compilation, strict signature validation, source/bundle metadata equality, and project-root process launch passed. The packaged Nexus icon is byte-identical to the verified v0.2 icon. The preserved v0.2 bundle retains its valid signature and original executable, metadata, and icon checksums. The user explicitly permitted building v0.3 before committing v0.2. Generated compiler caches and intermediate icon files were removed after verification.

For v0.4, all 62 focused checks and native type-checking passed, followed by a cache-free native build, strict signature and source/bundle metadata checks, unchanged Nexus icon payload, project-root launch, and checksum-matched v0.3 recovery checks. An offscreen `NSHostingView` rendered the real Overview and workflow components without capturing any screen; this checked layout, not live interaction. A test-fixture comparison was corrected to use canonical macOS paths. Temporary render sources/images, test executables, the failed fixture/report, compiler caches, and intermediate icons were removed. The v0.3 source/build work was already committed before this build began.

The subsequent v0.5 review reproduced four defects using disposable fixtures: ASCII arrows inside text fences were rejected, a versioned project title incorrectly owned all current sections as history, cached bundle metadata survived executable changes, and permission-only executable changes did not trigger refresh. All four are fixed. Nine added core assertions cover these regressions plus binary/malformed/oversized metadata and executable-directory rejection. All 71 focused checks and native type-checking passed. No synthetic app was launched. The reviewed source was committed in separate parser, app-discovery, UI, and documentation groups before clean distributable compilation. Strict root-bundle signature checks, source/bundle metadata equality, unchanged Nexus icon, and project-root process launch passed; the preserved v0.4 bundle retains its original executable/metadata/icon checksums and valid signature. The superseded v0.3 bundle was moved to Trash and disposable probes, test binaries, compiler caches, and intermediate icons were removed. No build-rule exception was needed. Live UI interaction remains unconfirmed; the unchanged view layout has the earlier v0.4 offscreen evidence only.

For v0.6, all 71 core checks and 18 isolated store checks passed, as did native type-checking. Added regressions cover leading blank lines, adjacent prose/tables, escaped pipes, distinct source headers, literal model/path identifiers, root overview refresh, parent/child selection, and app preference for icons. Offscreen native rendering checked repository/project layouts at 900×660 and 1160×840, the real Local Assistant table component at both content widths, a three-column scrolling table, real app icons, and neutral fallback symbols. Native icon-service access required the render probe outside the agent sandbox; it rendered only its own never-shown views and captured no desktop pixels. A cache-free build passed strict signature checks, source/bundle metadata equality, unchanged Nexus icon checks, and launch from the project-root v0.6 bundle. The previous v0.5 bundle retained its signature and executable/metadata/icon checksums. The superseded v0.4 bundle was moved to Trash, and temporary render sources/images, test executables, compiler caches, and intermediate icons were removed. Live UI interaction remains unconfirmed; optional code review and formal verification have not run for this batch.

For v0.7, all 128 core checks and 18 isolated store checks passed, along with native type-checking. Added cases cover complete architecture tables across all six projects, mixed architecture/workflow headings, source ordering, and dated/undated histories; an empty-date separator regression found during testing was corrected. Offscreen native rendering checked all six project headers at minimum and regular content widths, title-line icon alignment, dated history headings, and Local Assistant's complete 15-row architecture table. Wrapped cells exposed uneven per-cell dividers; full-width grid dividers corrected the layout and were checked at both widths. These probes rendered only their own never-shown views, without capturing desktop pixels. A cache-free native build passed strict signature, source/bundle metadata, unchanged Nexus icon, project-root launch, and checksum-matched v0.6 recovery checks. Cleanup left only the required v0.6 recovery bundle under `build/`; v0.5 was retired to Trash, though a final Trash inventory was denied by macOS and was not retried. The user explicitly permitted this build before committing v0.6. Live UI interaction, optional code review, and formal verification had not run at delivery; no commit was made at that point. The later category-grouping review and verification are recorded under v0.8 delivery evidence.

Generated staging files and recovery copies stay under ignored `build/`; the final `.app` stays at the project root and is also ignored. The next application build must satisfy the versioning and previous-build gate above. Changing the delivery recipe or preparing icon concepts does not imply that a new binary was built.

## Working rules

- Follow repository [AGENTS.md](../AGENTS.md), [CLAUDE.md](../CLAUDE.md), and configured global instructions; this README does not override them.
- Keep editable project files here. Framecraft remains separately installed, not copied into the app.
- Keep this README and the repository [README](../README.md) synchronized in the same batch: Projects row, latest-update date, and changelog.
- Preserve the selected design. Distinguish implemented behavior, source-reported information, and unavailable data. No inferred milestones, fake telemetry, or in-app code viewer.
- Keep generated output and local notes out of Git. Do not commit or publish without authorization.

### UI acceptance rules

- Keep exactly two visible shell layers: one black chassis covering the complete native window, and one light-artwork surface covering only the detail region. Let the native window own the outer curve; use a three-point detail inset and tune the detail radius so one thin black perimeter follows all four corners. The rendered native-window comparison is authoritative: all four detail corners must visually follow the native window, and a radius is not acceptable merely because it was derived from the inset. Do not add a competing whole-shell clip or widen the reveal. Do not place a desktop-blur or artwork layer under the chassis. Keep long content inside the bounded detail surface and hide its scrollbar indicator.
- Use the same local artwork source for the active detail panel and the lock screen: blur it behind normal content and show it clearly while locked. Keep the denser sage halftone confined to the lower artwork and fade it upward; repeat that pattern as a crisp overlay above the normal detail blur so the dots remain visibly anchored at the same lower position. Do not replace the active detail's lower pattern with a uniform full-screen layer. Add the reference-style denser full-frame dot-and-short-mark matrix only to the clear lock artwork. Expand or collapse the rail over approximately 0.78 seconds, fade labels without re-centering icons, keep every compact icon on one fixed axis, and make the brand control visible in both states.
- Animate each disclosed project row into or out of its category over approximately 0.62 seconds with a small stagger; do not animate only the category container. Respect Reduce Motion.
- Show the Nexus app icon beside the Project Control title inside the detail header. Reserve native title-bar safe space separately; repository text must truncate safely. Do not duplicate lock, repository README, or repository-menu controls in this header.
- Pin repository README, repository actions, and Lock as three identically styled, full-width leading footer rows below a separator from the scrolling hierarchy. Use the book, horizontal-adjustment, and lock symbols with longer balanced Open README file, Repository menu, and Lock application labels; retain the full action names in help and accessibility text. Render the menu's visible row through the same fixed leading footer layout as the plain buttons rather than accepting the borderless menu's intrinsic alignment. Add a second separator before compact workspace/sync status and the live bundle version, and align that metadata with the visible icon column instead of the raw rail edge. In compact mode, hide labels/status/version and center every action icon on the same axis as navigation icons.
- The footer lock control hides the complete rail and content surface without authentication, black footer, or status row. Show only the shared local artwork and place Unlock at the geometric center of the application. Enter and leave this state with an edge-to-edge opacity transition only: do not scale the shell or artwork, add a custom outer lock mask, or expose a temporary top gap. Respect Reduce Transparency.
- Keep a dedicated, accessible repository-actions menu without a redundant disclosure indicator. It belongs in the rail footer, not the detail header, and its label must use the same typography, color, spacing, and full-row target as the neighboring footer actions.
- Group projects by the explicit Category column, with counts and keyboard-focusable full-row disclosure buttons. Keep scope and tags separate, following the root [Project Control tag policy](../AGENTS.md#project-control) and [README contract](../README.md#readme-content-contract-for-project-control). Preserve source order, project identity, selection, and notes; check wrapping tags at the minimum supported width.
- Keep the project register search-free; the full padded row is the selection target and remains a native keyboard-focusable button.
- Keep a selectable repository parent above its indented projects. Repository Overview, Repository history, Commit activity, and Last read belong on that parent's screen. The repository README action belongs in the pinned rail footer and must not be duplicated on the detail screen.
- Keep Commit activity on the repository parent only. Show newest years first, one year label and twelve equal month cells, fixed absolute intensity thresholds, concealed future values, an accessible five-level legend, the complete loaded commit total, and distinct valid-year count. At widths up to 940 points, use the compact metrics without horizontal clipping. Hovering a populated cell shows each affected registered project's icon, name, and participation count; disclose that multi-project totals can overlap.
- Show the same project icon in its sidebar row and detail header when an unambiguous project-root app exists; otherwise use a neutral symbol.
- Size detail icons consistently with the repository reference and align their center with the project-name line, not the combined title/version stack. Check real and fallback icons with short and wrapped names.
- Keep Open App beside Read README. Discover project-root apps first; use manual location only as the fallback, and never launch during scanning.
- Keep README Overview content in Overview, with separate Architecture, Models, Workflows, Work notes, and Project history tabs.
- Wrap a below-tab README view made only of paragraphs or bullets in the established rounded translucent plane. Do not invent a heading. Preserve heading-above-box sections, Workflow diagrams, tables, history rows, work-note rows, and every area above the tabs without adding another wrapper.
- Render README tables as native headers and cells, never as a raw or duplicated Markdown paragraph. Preserve model identifiers and paths. Keep regressions for leading blank lines, adjacent prose, escaped pipes, and underscore-containing identifiers.
- Keep every documented architecture-table row visible, including models, embeddings, RAG, orchestration, retrieval, and storage. Models is a secondary view, not a reason to remove documented technologies or concepts. Check coverage for every registered project and never label an absent framework as installed.
- Follow the repository README's single content contract: category-grouped tables, one named technology/concept per row, plain-language use descriptions, stable section markers, and explicit exclusions. Do not bundle languages, frameworks, models, or protocols into a responsibility row.
- Show a history row's standalone date beside its project/version title; the expanded body contains the change description without a duplicate date.
- Render workflows as connected diagrams, not numbered lists. Preserve explicit branches and independent routes; never invent relationships to fill a diagram.
- Keep rounded cards and content-sized diagram nodes, center narrower diagrams within their available space, preserve horizontal scrolling for wide graphs/tabs, and retain accessible connection descriptions.

<!-- project-control:section=history -->
## Change log

The v0.8 implementation and release records are committed through `6232bf9`. Earlier entries
retain the status at delivery; later source commits are identified below. A retrospective
record does not assert that each intermediate build had its own Git commit. This documentation
reconciliation is not a new app build and does not rerun the historical verification.

| Version | Date | Updates | Git evidence |
|---|---|---|---|
| v2.5 / build 16 | 2026-09-02 | Combined project identity, actions, and Document Health in one compact pre-tab glass card. Top-aligned the icon/name/version beside the notes gauge; grouped folder, README, app, optional app-menu, detection, document availability, and runtime-status information below. Reduced this card's content inset to 16 points and its internal row gap to 14 points; adaptive action/status layouts preserve narrow-window readability. Reduced the tab-to-content gap to eight points. Existing warnings, below-tab content styling, notes, history, repository activity, navigation, artwork, and lock behavior are unchanged. Passed complete native type-checking, a cache-free optimized build, strict signing, exact v2.5/build-16 metadata, arm64/icon checks, and live regular/minimum-window checks with Local Assistant and Python Accomplishments. Core/store suites were unchanged and not rerun. The subsequent authorized review found no actionable issues; verification repeated a cache-free optimized build, strict package checks, and live narrow-window header inspection. Preserved v2.4/build 15 under `build/previous.6HZ7jk`; removed superseded same-version candidates and generated intermediates. | Source `52cbaf7`; this documentation checkpoint; signed project-root app |
| Documentation policy · no new app build | 2026-09-02 | Moved generic version and build-number rules to the repository README, retained Project Control's bundle-delivery procedure here, and added the required linked project declaration. Application source, metadata, signed bundle, and v2.4/build 15 are unchanged. | This documentation commit |
| v2.4 / build 15 | 2026-09-02 | Removed the competing whole-shell SwiftUI clip and outline so the native macOS window owns the outer corners without light wedges. Kept the full black chassis and three-point detail reveal, then visually tuned the detail layer to an 18-point radius so all four rendered curves follow the native window. Removed the lock artwork's custom outer mask and changed lock/unlock to an edge-to-edge opacity transition without shell scaling. Wrapped only untitled below-tab paragraph/bullet README views in the established rounded translucent plane; heading-led content, tables, Workflows, history, notes, and content above the tabs remain unchanged. Added a lower-third sage halftone to the shared active/lock artwork, repeated it crisply above the normal detail blur, and added a denser full-frame dot-and-short-mark matrix only to the clear lock view. Moved repository README, repository actions, and Lock into consistently styled full-width pinned footer rows with aligned book, adjustment, and lock symbols and longer balanced Open README file, Repository menu, and Lock application labels. The menu's visible row now uses the same fixed leading layout as the plain buttons instead of the borderless menu's intrinsic alignment. Compact workspace/sync status and the live bundle version follow below on the visible icon-column inset; duplicate header/detail controls remain removed and the compact icon axis is retained. Passed 332 core checks, 39 store checks, optimized compilation, strict signing, exact v2.4/build-15 metadata, arm64/icon checks, and live repository/project Overview, Architecture, Workflows, expanded/collapsed footer, lock-artwork, halftone, and corner inspection. The complete code review found no actionable source findings. Formal verification repeated a clean optimized rebuild, strict package-identity checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection. Preserved v2.3/build 14 under `build/previous.bIh8aG`. | Source `014523d`; this project documentation checkpoint; signed project-root app |
| v2.3 / build 14 | 2026-09-01 | Added repository Commit activity with newest-first years, twelve responsive month cells, fixed absolute intensities, concealed future values, complete unique-commit totals, and per-project hover distributions with real project icons when available. Read-only Git access now includes changed paths solely to map registered top-level folders; messages, authors, and file contents remain unread. Reworked the shell into a full-window rounded black chassis plus an inset four-corner light-artwork detail layer, reused the same artwork clearly for the lock screen and blurred behind normal content, removed rail/detail overlap and visible scrollbars, adopted the reference-style brand control, and kept every rail icon on one fixed animation axis. Passed 8 focused core checks, 1 store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata checks, arm64/icon checks, and live expanded/collapsed/lock inspection. Optional code review and formal verification did not run. Preserved v2.2/build 13 under `build/previous.IqYCW4`. | Activity `bb0689e`; shell `a01102b`; this documentation checkpoint; signed project-root app |
| v2.2 / build 13 | 2026-09-01 | Moved Category, Technical scope, and Technologies into the first three labelled Professional scope bullets so the root register can use three readable columns without losing project detail. Added case-insensitive labelled-scope parsing, explicit blank behavior, and backward-compatible separate-column precedence; the retired AI-usage column remains ignored. Existing glass UI and all project-management behavior are unchanged. Passed 20 focused core checks, 5 isolated store checks, complete native type-checking, cache-free optimized compilation, strict signing, exact metadata equality, arm64 executable/icon checks, promotion, and separate-instance root launch. Preserved v2.1/build 12 under `build/previous.ftKKT9`; removed generated intermediates and the smoke process. Optional review and formal verification did not run. | Source `ad84aa7`; this project documentation and delivery checkpoint |
| v2.1 / build 12 | 2026-09-01 | Delivered the approved edge-to-edge glass correction: removed all four outer shell insets, moved title-bar clearance inside the rail, added a full-window local sky/cloud/texture scene, switched native material to in-window sampling, and removed the normal opaque tint. Reduce Transparency retains a solid fallback; existing data and interaction paths are unchanged. Complete native type-checking passed. A controlled 1320×760 render confirmed shell coverage at every edge midpoint and visible scene variation across the glass plane, followed by visual inspection of the zero-gap boundary, shared backdrop, and content readability. Cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, promotion, and separate-instance launch passed. Core/store suites were unchanged and not rerun; optional review and formal verification did not run. Preserved v2.0/build 11 under `build/previous.Yj7LyM`; removed generated intermediates and the smoke process. | Source `8c7981c`; source record `0c57d69`; root source record `9738555`; this delivery checkpoint |
| v2.0 / build 11 | 2026-09-01 | Delivered the complete cinematic glass redesign: a transparent native window, real behind-window desktop blur, one outlined rounded shell, aligned expanding/collapsing hierarchy rail, staggered per-project disclosure motion, bounded internal scrolling with hidden indicators, rounded content cards, and a no-password artwork lock with centered Unlock. The user's screenshot rejected the first signed candidate because it showed an internal green field; `0e07484` replaced it with actual behind-window material. Offscreen inspection also removed a redundant lock caption that crossed the fortress silhouette. Preserved README-derived data, notes, classifications, icons, app discovery, tables, tabs, diagrams, and background synchronization. Passed 323 core checks, 39 store checks, native type-checking, optimized compilation, strict signing, exact source/bundle metadata equality, and separate-instance root launch. Final live capture remained unavailable because ScreenCaptureKit access was denied; optional review and formal verification did not run. Removed the superseded v2.0 bundle and generated intermediates; preserved v1.0 and documented older recoveries. Superseded Vector/Lens design files remain in Git history. | Initial source `32f2df4`; desktop glass `0e07484`; source records `2f44ecd`, `92c5186`; root records `92491bd`, `a1edc1d`; this delivery checkpoint |
| v1.0 / build 10 | 2026-08-31 | Replaced mandatory AI-usage badges with optional root-README Technologies tags, keeping technical scope separate. Added per-tag wrapping, case-insensitive deduplication, explicit empty/legacy behavior, and focused parser/store regressions. Updated all six register entries and the Project Control-only tag rule. Passed 19 parser/register checks, 5 store checks, native type-checking, and 24 tag-layout cases; inspected isolated native renders. No live-interaction, code-review, or formal-verification claim. User-authorized source/release commits preceded a cache-free optimized build. Strict signing, matching source/bundle metadata, unchanged Nexus icon, and project-root launch passed. Preserved v0.9 with unchanged executable/metadata/icon checksums and retained documented older recoveries. Removed generated compiler/icon intermediates and closed the new smoke-test process; no existing Project Control process was present. No build-gate exception was used. | `9f3e399`, `eb643cb`, `2a512b8`; root metadata/policy `b43b9fd`; pre-build release records `19ac73f`, `6d6e110` |
| v0.9 / build 9 | 2026-08-31 | Corrected header icon/title proportions, left alignment, and the ellipsis/disclosure overlap. Added collapsible source-ordered categories, counts, and independently wrapping technical-scope/AI-usage badges from optional root-register columns. Missing metadata remains unspecified; root classification changes still apply when a project README is stale. Existing notes and selection are preserved. Passed 312 core checks, 38 store checks, native type-checking, offscreen layouts, clean compilation, strict bundle identity/signature checks, and project-root launch. Preserved v0.8 unchanged; removed temporary/generated intermediates. Live UI interaction, optional review, and formal verification remain unconfirmed or not run. Source was uncommitted at delivery. | Retained implementation captured with v1.0 in `9f3e399`, `eb643cb`, `2a512b8`; no separate v0.9 release commit |
| Documentation reconciliation · no new app build | 2026-08-31 | Matched all retained release records to Git evidence, clarified releases committed together, and adopted the root-only instruction/history rules. At reconciliation, diagram work was paused and v0.8/build 8 was unchanged. The records are included with the v1.0 release documentation. | Prior release references below; no separate app build |
| v0.8 / build 8 | 2026-08-31 | Added stable README mappings, content-digest refresh, source warnings/recovery, and one technology/concept per architecture row. Review fixed the polling/switch race, malformed empty-register acceptance, and misleading different-root stale state. Passed 303 core and 34 store checks, a focused mutation check, native type-checking, clean compilation, native offscreen layouts, and signed-bundle metadata/identity checks. Preserved v0.7; retired v0.6 and the superseded candidate to Trash; removed temporary/generated artifacts. The existing app process was not restarted; live UI interaction remains unverified. | `a6266cf`, `6402aba`, `26f4fdf`, `c323a23`, `6232bf9` |
| README grouping · no new app build | 2026-08-31 | Grouped all six projects' architecture components into relevant category tables using existing native headings and tables. Preserved every source row and documented the category convention. The v0.7/build-7 application is unchanged; Observatory's embedded README advances separately to v2.1. Passed 162 core checks, 18 store checks, native type-checking, exact row/group checks, README links, native offscreen layouts, and unchanged-bundle identity/signature checks. Review found no actionable defects; live interaction remains unverified. | `0a17adc`, `8cf8850` |
| v0.7 / build 7 | 2026-08-31 | Delivered larger title-aligned project icons, dates beside history headings, and complete architecture tables with full-width row dividers. Added source-backed tables to all six project READMEs and retained mixed architecture/workflow sections. Passed 128 core checks, 18 store checks, native type-checking, offscreen header/history/table layouts, clean compilation, strict bundle checks, and root-level launch. Preserved v0.6 unchanged, retired v0.5 to Trash, and removed temporary/generated artifacts. The user permitted building before committing v0.6; source was uncommitted at build time. Live interaction remains unconfirmed. | `0125869`, `70321c5`, `0a17adc`, `8cf8850` |
| v0.6 / build 6 | 2026-08-30 | Added structured native README tables, preserved model/path identifiers, preferred project icons, and a selectable repository-parent screen replacing footer content. Added table/navigation acceptance rules and focused regressions. Passed 71 core checks, 18 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/metadata/icon checks, and root-level launch. Preserved v0.5 unchanged, retired v0.4 to Trash, and removed temporary/generated artifacts. Live UI interaction remains unconfirmed; source was uncommitted at delivery. | Retrospective record in `0a17adc`; implemented source committed with v0.7 |
| v0.5 / build 5 | 2026-08-30 | Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh. Added nine core regression assertions; passed 57 core checks, 14 store checks, native type-checking, clean compilation, strict signature/metadata/icon checks, and root-level launch. Committed reviewed source before building, preserved v0.4 unchanged, retired v0.3 to Trash, and removed temporary/generated artifacts. Live UI interaction remains unconfirmed. | `aa794c4`, `1f2e7ae`, `d0b9426`, `9f086e9`, `74ccd1a` |
| v0.4 / build 4 | 2026-08-30 | Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs, and native node-and-arrow diagrams with explicit branch/merge support. Recorded UI acceptance rules. Passed 48 core checks, 14 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/bundle checks, and project-root launch. Preserved v0.3 unchanged, moved v0.2 to Trash, and removed temporary/generated artifacts. Live interaction checks remain unconfirmed. | Retrospective record in `9f086e9`; implemented source committed with v0.5 |
| v0.3 / build 3 | 2026-08-30 | Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows. Capture metadata before reads, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening. Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean compilation, strict signature checks, bundle metadata/icon checks, and project-root launch. Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash and removed generated artifacts. The user explicitly authorized building before committing v0.2. Native visual inspection remains unconfirmed. | `07f72b4`, `1f1dfad`, `352ad0b`, `6c8dd32` |
| v0.2 / build 2 | 2026-08-30 | Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle. Advanced both version and build. Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch; preserved v0.1 with matching executable/metadata checksums. Native Dock/window inspection remains unconfirmed. The user explicitly authorized this build without committing v0.1; no commit was created. | Retrospective record in `6c8dd32`; source committed with v0.3 |
| Delivery/design preparation · no new app build | 2026-08-30 | Relocated the unchanged v0.1/build-1 application beside this README. Configured signature-checked root-level delivery with recoverable prior bundles, and recorded the single-digit minor/version-and-build increment policy. Added three icon choices; selection and the next-build authorization were pending at this stage. | Retrospective record in `6c8dd32` |
| v0.1 / build 1 | 2026-08-30 | Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress, and explicit folder/README/app actions. Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch. Fixed stale metadata caching found by the refresh test. Retired 33 rejected design artifacts recoverably and removed their obsolete links. Native visual/keyboard inspection remains blocked by macOS capture permission. | Retrospective record in `6c8dd32`; source committed with v0.3 |
