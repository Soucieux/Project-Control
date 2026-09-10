# Project Control

<a id="repository-description-archive"></a>

<a id="repository-register-detail"></a>

<!-- project-control:section=overview -->
## Overview

- Project Control is a native macOS management center for this repository.
- Understand projects, save plain-text work notes, follow documented changes, and open a folder or chosen application without viewing or editing source code inside the app.

<!-- project-control:section=overview -->
## Capabilities

- **Browse:** Read project introductions, architecture, models, workflows, and documented history in native views.
- **Track work:** Create, edit, and delete private plain-text project notes.
- **See activity:** Explore local Git commit totals by year and month, with project participation on hover.
- **Open:** Reveal folders, read a README, or launch a detected or selected Mac application.
- **Stay current:** Refresh README-derived views automatically while the app is active.
- **Privacy:** Work stays local. The app does not display source code or claim to measure runtime health.

## Quick start

1. Open the delivered **Project Control.app** beside this README.
2. Choose **Choose repository…** and select the `Professional Quality` root folder.
3. Select a project in the sidebar, then open its detail tabs.
4. Use **Work notes → Add note** to save a private note, or **Open folder**, **Read README**, and **Open App** to open the selected item.

**Success:** The six registered projects appear; their documented content opens without a README warning.

### Build from source

Requires macOS 14 or later and Xcode with its command-line tools selected. The local build targets the current Mac’s architecture.

From the repository root:

```sh
cd "Project Control"
make app
open "Project Control.app"
```

<a id="local-data-and-launch-safety"></a>

## Using Project Control

### Navigation and work notes

- **Project views:** Overview, Architecture, Models, Workflows, and Project history reflect the selected README.
- **Notes:** Use **Add note** or `Command-N` while Work notes is visible; save nonblank text with `Command-Return`, or cancel with Escape. Notes accept up to 4,000 characters; saved notes can be edited or deleted.
- **Context:** Drafts remain attached to their selected project. Category expansion and navigation do not change saved notes.
- **Lock:** Hides the workspace without adding password protection or changing data.

### Refresh and recovery

- **Automatic refresh:** Active views check the registered READMEs about every two seconds. **Refresh now** (`Command-R`) reloads immediately; `Command-O` chooses a repository.
- **Valid edits:** Replace the displayed content while preserving local notes and an existing selection.
- **Unreadable files:** Keep the last good view with an out-of-date warning. Repair the README to recover on the next check.
- **Last read:** Reports when documentation was read; runtime health remains unchecked.

### Local storage and app opening

- **Work notes and choices:** Stored in `Application Support/Project Control/workspace.json` on this Mac.
- **Project identity:** Saved data follows the canonical project path; moving a repository does not migrate it automatically.
- **Recovery:** Invalid or duplicate note records preserve the file and disable editing. Keep a backup before attempting repair or using an older app with newer data.
- **Older notes:** v2.6 retains legacy note IDs and combines title/context text; retired completion status is not restored.
- **Automatic apps:** Eligible `.app` bundles must be directly inside the project. Selection prefers a project-name match, then a folder-name match, then a sole candidate; unmatched multiple candidates appear as choices.
- **Manual choice:** If no app is detected, **Open App** can open and remember a selected application when local storage is writable.
- **Boundary:** Files and apps open only on your action. This local build has no network client and is neither sandboxed nor notarized.

<!-- project-control:section=architecture -->
## Architecture

### Frontend & Presentation

| Technology or concept | Use in this project |
|---|---|
| SwiftUI | Builds the black chassis, shared-artwork detail layer, animated hierarchy rail, artwork lock, project screens, work-note editor, History, responsive commit-activity grid, native tables, and restrained motion. ReadmeContent and RepositoryScreen render the selected source content. |
| AppKit | Provides macOS icons, application/window integration, file pickers, and explicit open actions. ProjectIcon keeps app and fallback artwork consistent. |

### Backend & Application Logic

| Technology or concept | Use in this project |
|---|---|
| Swift | Native application language. ControlStore owns selection and background reloads. RepositoryReader reads bounded source documents and activity snapshots. ReadmeParser handles sections, tables, and history. |
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

<a id="how-information-stays-current"></a>

<!-- project-control:section=workflows -->
## Workflow and data sources

```text
README saved → background content check → mapped section parsing → native screen update
Repository Projects table → registered project READMEs → project navigation and content
Local Git refs → timestamps plus project-folder paths → monthly totals and hover distributions
Local work notes → notes available / no notes summary
```

<!-- project-control:section=ignore -->
## README content contract for Project Control

- Repository and project READMEs are the content baseline.
- Project Control reads selected sections locally; it never executes README instructions, scans source code, or uses a model to invent missing facts.
- This section is the single authoring contract for all current and future projects.
- It is referenced by the repository instructions and applies to README inputs, not sibling applications' UI or runtime behavior.

### Add a new project to Project Control

- Putting a folder in the repository is only the first step.
- Project Control does not scan arbitrary folders.
- It displays the top-level folders registered in the repository root README's **Projects** table, then reads each registered folder's `README.md`.
- Complete every step below so the project and its details appear.

1. **Create one top-level project folder.** Put it directly inside the repository root, beside the
   existing project folders. For example, create `Example Project/`, not
   `Some Collection/Example Project/`. Keep the project inside this repository; a symlink to a
   folder outside the repository is rejected.
2. **Create the project's README.** Add `Example Project/README.md` as a regular UTF-8 file smaller
   than 2 MB. Start with a plain-language overview, then document the architecture, optional models,
   workflows, and history that the app should show. Choose the project's change-history mode from
   the [version and build-number policy](../AGENTS.md#version-and-build-number-policy), and place
   the required linked declaration beside its current-release or history section.
3. **Mark the app-visible README sections.** Put one supported
   `<!-- project-control:section=... -->` marker immediately before each heading that Project Control
   should read. Use `overview`, `architecture`, `models`, `workflows`, `release`, or `history` as
   appropriate. The [section table below](#select-app-visible-sections) explains each destination.
   Sections that do not exist are left empty; Project Control does not invent missing content.

   This starter uses dated history. If the project uses versions and builds, follow the numbering
   policy and add a marked `release` section instead.

   ```markdown
   # Example Project

   <!-- project-control:section=overview -->
   ## Overview

   Explain what the project does and who it helps.

   <!-- project-control:section=architecture -->
   ## Architecture

   | Technology or concept | Use in this project |
   |---|---|
   | SwiftUI | Builds the native interface. |

   <!-- project-control:section=history -->
   ## Change log

   **Change-history numbering:** This project uses dated history and does not assign project-level
   version or build numbers. Follow the repository-wide
   [version and build-number policy](../AGENTS.md#version-and-build-number-policy).

   | Date | Update |
   |---|---|
   | 2026-09-04 | Added the project to the repository. |
   ```
4. **Register the project in the root Projects table.** Add one row directly to the table under the
   `projects` marker. The first cell must link to the new top-level folder. If the folder name
   contains spaces, encode each space as `%20` in the link. Begin the Professional scope cell with
   Category, Technical scope, and Technologies in exactly that order, followed by the useful project
   summary.

   ```markdown
   | [Example Project](Example%20Project/) | <ul><li><strong>Category:</strong> Project Management</li><li><strong>Technical scope:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; SQLite</li><li><strong>Product:</strong> A concise factual summary.</li></ul> | 2026-09-04 |
   ```

   Use real, source-confirmed classifications. Separate technology names with semicolons. The folder
   link, not the display name, identifies the project, so keep the link accurate when renaming it.
5. **Complete the records.** Keep full project descriptions, operating details, and history in the
   project README. Keep the introduction and guide links in the root **Projects** table’s Professional scope cell and a dated
   summary linking to the full project history in the root **Change log**.

   For unique contributor requirements, add scope under root `AGENTS.md` and link a purpose-specific
   reference in `.agents/instructions/`. Keep the README focused on users; never create a nested
   `AGENTS.md` or `CLAUDE.md`.
6. **Check the result in Project Control.** With this repository selected, save both READMEs and
   wait about two seconds, or use **Refresh now**. Confirm that the project appears under the
   intended category, its scope and technology tags are correct, and every documented detail tab
   opens without a README warning. A macOS `.app` is detected automatically only when it is directly
   inside the project folder;

   otherwise, **Open App** can remember a manually selected application.

- If the project does not appear, check that its row is directly inside the selected Projects table, the link resolves to exactly one top-level folder, the folder and README names match letter-for-letter, and every section marker immediately precedes a heading.
- A malformed root register is rejected; an unavailable project README leaves the project visible from its root summary but cannot supply complete detail tabs.

### Select app-visible sections

Place a standalone marker immediately before the heading that owns the content; blank lines between them are allowed. The comment is invisible in normal Markdown readers.

```markdown
<!-- project-control:section=architecture -->
## Technical design

### Frontend & Presentation

| Technology or concept | Use in this project |
|---|---|
| React | Builds interactive interface components. |
| TypeScript | Adds type checking to application code. |
```

| Marker identifier | Repository README destination | Project README destination |
|---|---|---|
| `overview` | Repository Overview | Project Overview |
| `projects` | Sidebar register, from a table of relative top-level folder links | Not displayed |
| `architecture` | Not displayed | Architecture tables and prose |
| `models` | Not displayed | Models; model-related architecture rows remain visible in Architecture |
| `workflows` | Not displayed | Source-defined workflow diagrams |
| `history` | Repository history | Project history |
| `release` | Not displayed | Current release/build label |
| `ignore` | Excluded section and descendants | Excluded section and descendants |

In a README containing markers, only marked sections and their descendants are selected. A section ends at the next heading of the same or a higher level.

A child's explicit marker can select a different destination, except inside `ignore` or `history`: those subtrees remain excluded or historical. Unmarked sibling sections stay README-only.

- Multiple sections may target one destination and retain source order.
- Keep markers when renaming or moving headings; do not insert prose between a marker and its heading.
- Unknown identifiers, malformed markers, consecutive markers without headings, and orphan markers are errors.
- Marker-like examples inside fenced code blocks are inert, not configuration.

- The Projects register reads tables directly under its selected heading, not unrelated tables inside descriptive subsections.
- Keep extended project descriptions in the owning project README; the root Projects table contains concise introductions and links in each Professional scope cell.

- The first two register columns remain the project folder link and Professional scope description; the current register keeps **Latest update** as its third human-readable column.
- Start every Professional scope cell with these three labelled list items, in this order:

```html
<ul><li><strong>Category:</strong> Project Management</li><li><strong>Technical scope:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; README-driven</li><li><strong>Product:</strong> Project-specific summary.</li></ul>
```

- Project Control reads the labels case-insensitively, removes presentation markup, and leaves later project-specific bullets available as the professional summary.
- Categories and their projects retain first-appearance/source order.

- Missing or blank Category values use **Uncategorized**; missing or blank Technical scope/Technologies values are omitted from the sidebar.
- Custom category labels are supported without changing code.

- Use short, factual labels: native UI with local logic is **Native desktop**, not a server-based full-stack app; AI educational content is not an AI runtime.
- Calling an external AI API does not make a utility a backend.

- Older registers with separate `Category`, `Technical scope`, and `Technologies` columns remain compatible.
- When one of those legacy columns is present, its value—including an explicit blank—wins over a same-named scope label.
- Do not duplicate current metadata across both formats.

- Write **Technologies** as semicolon-separated names, for example `SwiftUI; README-driven` or `Next.js; LangGraph; Hosted AI`.
- Each nonempty name becomes its own tag.
- Surrounding whitespace and Markdown formatting are removed;

case-insensitive duplicates keep their first spelling and position. Keep punctuation inside names, such as `C++` or `model_name-v1`. Do not use a semicolon inside one name.

- Follow the [Project Control-only tag policy](#project-guardrails) when choosing factual technologies/approaches.
- The app displays this metadata; it does not verify runtime use or infer tags from architecture tables, categories, or scope descriptions.

The former **AI usage** column is ignored, even when Technologies is absent or blank; there is no fallback that creates an AI or absence badge.

- Older registers still load their projects, categories, and scope.
- Migrate desired, evidenced tags into Technologies explicitly.
- The labelled-scope format requires the delivered v2.2 app.
- The v2.1 bundle and earlier releases require the separate classification columns.
- Subsequent scope-label edits need no additional rebuild.

- Category headers show project counts and collapse without changing selection or notes.
- The root register owns these classifications; project README content still owns the detail tabs.
- A valid root edit refreshes category membership, scope, and tags, including for a project whose own README is temporarily stale.
- This metadata is inert text, not AI-inferred classification.

- Unmarked READMEs retain legacy heading matching: Overview/About/What This Does; Architecture/ Technology/Tech Stack/Components/Project Structure; Models/LLM; Workflows/How It Works/Request; and Change Log/Version History.
- The root register uses Projects.

- Existing compatibility does not make arbitrary unrecognized headings visible.
- Current release sections supply a `v<major>.<minor>` label with an optional `(build N)`; legacy root summaries are a fallback only for unmarked project READMEs.
- Optional absent sections stay empty rather than being fabricated.

### Write readable architecture and workflow content

- Keep category headings such as AI & Intelligence, Frontend & Presentation, Backend & Application
  Logic, Data & Storage, Integrations & Security, and Build & Delivery; omit empty categories.
- Give every language, framework, library, runtime, protocol, model, or architectural concept its
  own row. The first column names one item; the second explains its actual use in this project. Do
  not combine React, Next.js, and TypeScript into a single Interface/Responsibility row.
- List only source-confirmed technologies. Distinguish a concrete model from embeddings or RAG as
  concepts; distinguish source defaults from a verified running deployment. State absent
  technologies and runtime boundaries in prose, not as fake installed components.
- Backend & Application Logic may describe on-device/browser logic; it does not assert a server.
- Keep supported arrow-based workflow diagrams in mapped workflow sections. The renderer shows
  documented branches/merges, not invented connections or arbitrary executable code.
- Put setup commands, operating instructions, and detailed maintenance outside mapped sections, or
  mark their subtree `ignore`. Read README remains the route to the complete document.

### Update and recovery behavior

- While the app view is active, background checks run approximately every two seconds over the root README, registered project READMEs, and app metadata.
- Bounded content digests detect edits even when file size and timestamps are unchanged.

- A successful root register edit adds/removes sidebar projects and updates the monitored README set.
- Parsing and digest work run off the interface thread; complete presentation data is published on the main actor.

- A valid edit, including removal of a mapped section, replaces the old content.
- Local work notes and the selected existing project are preserved.
- An invalid/unreadable project README retains its last good content with an out-of-date warning, while other projects can update.

- Without a prior successful read, it displays availability/mapping warnings and no invented content.
- A root read/register failure keeps the last good repository snapshot visibly stale.
- Repairing the README lets the next check recover; Refresh now forces an immediate reload.
- Last read is a snapshot-read time, not a runtime-health claim.

- Ordinary mapped content changes require no Project Control rebuild.
- Changing the supported mapping/rendering behavior does require an app update and its usual build/version checks.
- Observatory is separate: its offline HTML embeds vault content and must be rebuilt when that content changes, following its own versioning and previous-build rules.

<!-- project-control:section=release -->
## Current release

**v2.7 (build 27)**. [Change and delivery evidence](#change-4).

<a id="project-guardrails"></a>
<a id="project-control-1"></a>
<a id="working-rules"></a>
<a id="ui-acceptance-rules"></a>
<a id="design-reference"></a>
<a id="build-delivery"></a>
<a id="synchronization-implementation"></a>
<a id="extraction-rules-and-limits"></a>
<a id="sidebar-classification"></a>

<a id="development-and-focused-checks"></a>

<a id="project-control-2"></a>

<a id="references"></a>

<!-- project-control:section=ignore -->
## Contributing

For source changes, follow the [repository instructions](../AGENTS.md#project-control).

<a id="repository-history-records"></a>
<a id="change-log"></a>

<a id="history-index-1"></a>

<a id="history-index-22"></a>

<!-- project-control:section=history -->
## Change history

**Change-history numbering:** Version and build numbers. Follow the repository [version and build-number policy](../AGENTS.md#version-and-build-number-policy).

One record per change; complete details and evidence are below. Older work dates and Git checkpoints remain labelled when they differ.

**Historical status:** Each record describes its own delivery checkpoint. Later records supersede older pending work or recovery locations; historical checks are not new validation.

| Record | Date | Highlights | Details |
|---|---|---|---|
| README organization | 2026-09-06 | <ul><li><strong>Structure:</strong> User guide first; one history table.</li><li><strong>Rules:</strong> Scoped contributor guidance under AGENTS.</li></ul> | [Full record](#readme-organization) |
| Documentation readability | 2026-09-06 | <ul><li><strong>Change:</strong> Reorganized long paragraphs and table cells without dropping details.</li></ul> | [Full record](#change-1) |
| Documentation | 2026-09-06 | <ul><li><strong>Change:</strong> Moved complete project descriptions, register details, and repository-origin history into this README.</li></ul> | [Full record](#change-2) |
| Maintenance | 2026-09-06 | <ul><li><strong>Change:</strong> Removed the entire build folder and stale Finder metadata.</li></ul> | [Full record](#change-3) |
| v2.7 / build 27 | 2026-09-05 | <ul><li><strong>Change:</strong> Restores source-derived sidebar tags and notes availability.</li></ul> | [Full record](#change-4) |
| Maintenance | 2026-09-04 | <ul><li><strong>Change:</strong> Removed the superseded v2.6 candidates from build/previous.FdBli0, build/previous.GtF7qQ, and build/previous.uqRg60.</li></ul> | [Full record](#change-5) |
| Maintenance | 2026-09-03 | <ul><li><strong>Change:</strong> Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout.</li></ul> | [Full record](#change-6) |
| Maintenance | 2026-09-03 | <ul><li><strong>Change:</strong> Raised the minimum window width from 980 to 1,120 points and removed the header's stacked action/status layout after the user identified it during live delivery checks.</li></ul> | [Full record](#change-7) |
| v2.6 / build 26 | 2026-09-02 | <ul><li><strong>Change:</strong> Implemented v2.6/build 26.</li></ul> | [Full record](#change-8) |
| v2.5 / build 16 | 2026-09-02 | <ul><li><strong>Change:</strong> Combined project identity, actions, and Document Health in one compact pre-tab glass card.</li></ul> | [Full record](#change-9) |
| Documentation | 2026-09-02 | <ul><li><strong>Change:</strong> Moved generic version and build-number rules to the repository README, retained Project Control's bundle-delivery procedure here.</li></ul> | [Full record](#change-10) |
| v2.4 / build 15 | 2026-09-02 | <ul><li><strong>Change:</strong> Removed the competing whole-shell SwiftUI clip and outline so the native macOS window owns the outer corners without light wedges.</li></ul> | [Full record](#change-11) |
| v2.3 / build 14 | 2026-09-01 | <ul><li><strong>Change:</strong> Added repository Commit activity with newest-first years, twelve responsive month cells, fixed absolute intensities, concealed future values, complete unique-commit totals.</li></ul> | [Full record](#change-12) |
| v2.2 / build 13 | 2026-09-01 | <ul><li><strong>Change:</strong> Moved Category, Technical scope.</li></ul> | [Full record](#change-13) |
| v2.1 / build 12 | 2026-09-01 | <ul><li><strong>Change:</strong> Delivered the approved edge-to-edge glass correction.</li></ul> | [Full record](#change-14) |
| v2.0 / build 11 | 2026-09-01 | <ul><li><strong>Change:</strong> Delivered the complete cinematic glass redesign.</li></ul> | [Full record](#change-15) |
| v1.0 / build 10 | 2026-08-31 | <ul><li><strong>Change:</strong> Replaced mandatory AI-usage badges with optional root-README Technologies tags, keeping technical scope separate.</li></ul> | [Full record](#change-16) |
| v0.9 / build 9 | 2026-08-31 | <ul><li><strong>Change:</strong> Corrected header icon/title proportions, left alignment, and the ellipsis/disclosure overlap.</li></ul> | [Full record](#change-17) |
| Documentation | 2026-08-31 | <ul><li><strong>Change:</strong> Matched all retained release records to Git evidence, clarified releases committed together, and adopted the root-only instruction/history rules.</li></ul> | [Full record](#change-18) |
| v0.8 / build 8 | 2026-08-31 | <ul><li><strong>Change:</strong> Added stable README mappings, content-digest refresh, source warnings/recovery, and one technology/concept per architecture row.</li></ul> | [Full record](#change-19) |
| Documentation | 2026-08-31 | <ul><li><strong>Change:</strong> Grouped all six projects' architecture components into relevant category tables using existing native headings and tables.</li></ul> | [Full record](#change-20) |
| v0.7 / build 7 | 2026-08-31 | <ul><li><strong>Change:</strong> Delivered larger title-aligned project icons, dates beside history headings, and complete architecture tables with full-width row dividers.</li></ul> | [Full record](#change-21) |
| v0.6 / build 6 | 2026-08-30 | <ul><li><strong>Change:</strong> Added structured native README tables, preserved model/path identifiers, preferred project icons.</li></ul> | [Full record](#change-22) |
| v0.5 / build 5 | 2026-08-30 | <ul><li><strong>Change:</strong> Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh.</li></ul> | [Full record](#change-23) |
| v0.4 / build 4 | 2026-08-30 | <ul><li><strong>Change:</strong> Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs.</li></ul> | [Full record](#change-24) |
| v0.3 / build 3 | 2026-08-30 | <ul><li><strong>Change:</strong> Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows.</li></ul> | [Full record](#change-25) |
| v0.2 / build 2 | 2026-08-30 | <ul><li><strong>Change:</strong> Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle.</li></ul> | [Full record](#change-26) |
| Maintenance | 2026-08-30 | <ul><li><strong>Change:</strong> Relocated the unchanged v0.1/build-1 application beside this README.</li></ul> | [Full record](#change-27) |
| v0.1 / build 1 | 2026-08-30 | <ul><li><strong>Change:</strong> Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress.</li></ul> | [Full record](#change-28) |

<details>
<summary>Full records for this table</summary>

<a id="readme-organization"></a>

### README organization — 2026-09-06

- **Structure:** Put purpose, capabilities, setup, architecture, and workflows before history.
- **History:** Merge matching repository-origin records into the owning change; preserve unique detail, evidence, and older links.
- **Ownership:** Keep user documentation here; route scoped contributor rules through root AGENTS.
- **Status:** Documentation changes only; uncommitted. Existing application versions, artifacts, and deployment state are unchanged.

<a id="change-1"></a>
<a id="readability-maintenance"></a>

### Documentation readability

- **Recorded date:** 2026-09-06.

- Reorganized long paragraphs and table cells without dropping details; consolidated imported history tables into indexes linked to complete readable records.
- Preserved existing destinations and README section mappings.
- Documentation only; no application or release artifact changed.

**Evidence and delivery status**

Local documentation changes; initially delivered uncommitted and recorded in this documentation commit.

[Back to change history](#change-history)

<a id="change-2"></a>

### Documentation

- **Recorded date:** 2026-09-06.

- Moved complete project descriptions, register details, and repository-origin history into this README; retained existing content, dates, release/build identifiers, Git evidence, and app-content mappings.
- Project guardrails now load through the root instructions only for this project.
- This is documentation maintenance; no application code, build, release, or deployment changed.

**Evidence and delivery status**

Local documentation update; uncommitted

[Back to change history](#change-history)

<a id="change-3"></a>
<a id="readme-detail-1"></a>
<a id="readme-detail-22"></a>
<a id="repository-record-1"></a>

### Maintenance

- **Recorded date:** 2026-09-06.

- Removed the entire build folder and stale Finder metadata: 231 obsolete generated files (179.7 MB), including compiler/test/icon intermediates, eleven older-version recoveries, and one superseded v2.7 candidate.

- Preserved the exact signed v2.7/build-27 app at the project root, source, editable icon masters, and audit evidence; no build-folder recovery remains.
- SVG references, PNG decoding, all ten packaged icon sizes, and source/packaged artwork inspection passed.
- Updated both current recovery records while preserving historical delivery evidence.
- No application code, version, build, or behavior changed.

- On September 6, explicitly authorized cleanup removed the entire `build/` folder and stale Finder metadata: 231 obsolete generated files (179.7 MB), including compiler caches, test executables, icon intermediates, eleven older-version recovery bundles, and one superseded v2.7 candidate.

**Evidence and delivery status**

User-authorized complete build-folder cleanup; package and asset checks passed; this documentation checkpoint; initially delivered uncommitted

[Back to change history](#change-history)

<a id="change-4"></a>
<a id="readme-detail-2"></a>
<a id="readme-detail-23"></a>
<a id="repository-record-2"></a>

### v2.7 / build 27

- **Recorded date:** 2026-09-05.

This release:

- refreshes future-month visibility each minute;
- centers content-sized workflow nodes;
- excludes parser guidance from displayed routes;
- preserves unusual Git filename bytes and merge attribution while disabling lazy fetch and transports;
- retains per-table register headers and blank-column precedence;
- rechecks automatic app boundaries;
- rejects duplicate note identities without rewriting storage;
- prevents version arithmetic overflow; and
- strengthens native regression coverage and private implementation boundaries.

- Exhaustive-pass source v2.7/build 27.
- Restores source-derived sidebar tags and notes availability; names collapsed navigation while retaining category counts; exposes activity distributions through native buttons and describes intensity thresholds with correct singular/plural count labels;

The current source and signed local app are **v2.7 (build 27)**. The audit source corrections are committed locally; source and documentation were uncommitted at initial delivery.

- Sidebar rows again show README-derived technology tags and notes availability.
- Collapsed navigation has accessible names and category counts.
- Activity cells support native button activation, describe all five intensity thresholds, use correct singular/plural count labels, and refresh future-month visibility each minute.
- Workflow nodes fit their content, narrow diagrams are centered, and parser guidance no longer appears as a route.

- Git activity preserves unusual filename bytes and attributes merge changes against the first parent.
- Lazy fetching and transports are disabled.
- Register tables retain their own headers and blank-column precedence.
- Automatic app discovery rechecks the project boundary, duplicate note identities preserve storage and disable editing, and version validation avoids integer overflow.
- Native regressions, callable documentation, and private implementation boundaries were strengthened.

- **Status:** Audit source corrections are committed locally; they were uncommitted at initial
  delivery; 432 native checks, optimized packaging, strict signatures, metadata/icon checks, and
  live checks passed within their recorded limits.

Project Control is a native macOS management center that summarizes the repository's subprojects without exposing their code or raw file contents.

- The documented native tests passed 339 core, 40 store, 41 note/presentation, and 12 version checks.
- The final optimized app compiled, passed strict signing and exact source-metadata/icon checks, and launched from the project root.
- The user subsequently authorized removal of all build-folder outputs, including the previously preserved v2.6/build-26 recovery.

The signed v2.7 app at the project root retains its exact audited bytes and valid strict signature. No build-folder recovery remains. The older binaries were deleted locally; generated intermediates can be rebuilt.
- Source code, editable icon masters, and audit evidence were preserved.
- Supplemental checks validated the SVG references, PNG decoding, and all ten packaged icon sizes; the source and packaged artwork were also visually inspected.

Historical delivery notes below retain their original evidence; all build-folder recoveries were removed in this cleanup.

- Live inspection confirmed wrapping tags at the minimum width, named collapsed navigation, centered workflows, horizontal access to all four branches in a disposable wide-graph fixture, activity distributions and threshold descriptions, and empty/multiline note-editor states with Escape cancellation.

- The test draft was not saved and the original repository selection was restored.
- Native button accessibility activation passed; Tab focus traversal was not confirmed under the current macOS keyboard settings.

**Evidence and delivery status**

Source `0e7bd25`, `d826029`, `4dacb60`, `01030c2`, `ffb1804`, `f7d769a`, `7966c13`, `b26a07c`, `c44dc8d`, `535f42f`; initially delivered uncommitted; 432 native checks and optimized packaging passed; signed project-root app; live checks and their limits recorded above and in Project details

[Back to change history](#change-history)

<a id="change-5"></a>
<a id="repository-record-3"></a>

### Maintenance

- **Recorded date:** 2026-09-04.

- Removed the superseded v2.6 candidates from `build/previous.FdBli0`, `build/previous.GtF7qQ`, and `build/previous.uqRg60`.
- At that time, retained the signed project-root app and ten distinct-version recovery bundles; all build-folder recoveries were subsequently removed on September 6.
- Added the root README's exact new-project registration procedure.
- No source, version, build, or application behavior changed.

- Removed the three superseded v2.6/build-26 candidate recoveries from `build/previous.FdBli0`, `build/previous.GtF7qQ`, and `build/previous.uqRg60`.
- At that time, the signed v2.6/build-26 project-root app and ten distinct-version recovery bundles were retained; every build-folder recovery was subsequently removed on September 6.
- No application source, version, build, or behavior changed.

**Evidence and delivery status**

Local cleanup; registration guide `fdecb4ab`; this history reconciliation

Local cleanup; this history reconciliation

[Back to change history](#change-history)

<a id="change-6"></a>
<a id="readme-detail-24"></a>
<a id="readme-detail-3"></a>
<a id="repository-record-4"></a>

### Maintenance

- **Recorded date:** 2026-09-03.

- Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout, and removed the top-slide transition from project rows.

- Existing category/footer icons retain their leading axis and animate from their current layout; new project rows fade in.
- Sidebar destinations, category disclosure, final expanded/collapsed contents, and Reduce Motion behavior are unchanged.

- The optimized build, strict package checks, minimum-width header, and collapsed sidebar inspection passed.
- Formal verification repeated complete compilation and strict packaging.
- The Mac locked before the corrected expansion path and remaining editor interactions could be checked.

**Evidence and delivery status**

Source `262e934`; signed project-root app; live expansion/editor checks pending

Source `262e934`; project record `71d43d3`; signed project-root app; live expansion/editor checks pending

[Back to change history](#change-history)

<a id="change-7"></a>
<a id="readme-detail-25"></a>
<a id="readme-detail-4"></a>
<a id="repository-record-5"></a>

### Maintenance

- **Recorded date:** 2026-09-03.

Raised the minimum window width from 980 to 1,120 points and removed the header's stacked action/status layout after the user identified it during live delivery checks.

- Document Health and Notes stay beside the buttons; the app-detection caption can wrap.
- The review centralized the minimum-window value and found no production issue.
- Native compilation, a cache-free optimized rebuild, strict signing, exact metadata, and arm64/icon checks passed.
- Live checks confirmed the minimum width and single-row header before the final equivalent build.

- Document Health and Notes stay beside the buttons; the app-detection caption can wrap.
- Review found no production issue, centralized the minimum-window value, and corrected a malformed-note fixture that could pass for the wrong reason.

- Verification passed 20 affected core and five affected store checks in addition to the note and numbering checks, complete compilation, a cache-free optimized rebuild, strict signing, exact metadata, and arm64/icon checks.

**Evidence and delivery status**

Source `bfa6c70`; signed project-root app; expansion/editor recheck pending

Source `bfa6c70`; project record `71d43d3`; signed project-root app

[Back to change history](#change-history)

<a id="change-8"></a>
<a id="readme-detail-26"></a>
<a id="readme-detail-5"></a>
<a id="repository-record-6"></a>
<a id="v26-delivery-evidence"></a>

### v2.6 / build 26

- **Recorded date:** 2026-09-02.

- Implemented v2.6/build 26: replaced the notes gauge with availability status, tightened the project header, integrated Add note and a plain-text inline editor, retained legacy note text and identities, and wrapped each below-tab prose group and empty state while preserving existing headings, tables, and diagrams.

- Enforced the corrected version/build mapping before packaging.
- Review found no production issue and corrected a misleading malformed-note fixture.
- Formal verification passed 40 note/presentation, nine numbering, 20 affected core, and five affected store checks, plus complete compilation, cache-free optimized packaging, and strict signature/metadata/arm64/icon checks.
- Signed app is v2.6/build 26; v2.5/build 16 is recoverable under `build/previous.g6aJIt`.

- Enforced the corrected version/build mapping before packaging.
- Review found no production issue.
- Formal verification passed 40 note/presentation, nine numbering, 20 affected core, and five affected store checks, plus complete compilation, cache-free optimized packaging, and strict signature/metadata/arm64/icon checks.
- Signed app is v2.6/build 26; v2.5/build 16 is recoverable under `build/previous.g6aJIt`.

The header replaces the 112-point progress ring with content-sized Notes availability beside Document Health. Identity uses a 48-point icon and 32-point name, with a 16-point outer inset.

- A 1,120-point minimum window width keeps the actions and summaries in one row; detection captions can wrap without moving the summaries below the controls.
- The tab-to-content gap remains eight points.

- Work notes owns its Add note toolbar, inline text-only editor, Save/Cancel, and saved-note edit/delete controls.
- The draft stays in the selected project view across tab changes, and a failed save does not discard it.

- Note IDs and all legacy title/context text are retained on read; only an explicit mutation writes the new format.
- Source headings and bold-only titles remain outside the grouped prose surfaces; tables, workflow diagrams, and history rows retain their existing surfaces.
- Empty states and workflow guidance now receive the shared content surface.

- Passed 40 focused note/presentation assertions, including legacy migration without a read-time write, round trips, limits, save/edit/delete and failure preservation, mixed heading/prose/table order, bold-only titles, and prose coverage across all six registered projects.

- Nine disposable-metadata checks cover valid pairs, rollover, and malformed/mismatched values.
- Twenty classification/parser checks and five classification/store checks passed for the affected README and state paths.

- Complete native compilation and a cache-free optimized build passed.
- The signed project-root app matches the source plist at v2.6/build 26, contains the exact generated icon, and has an arm64 executable with a valid strict ad-hoc signature.

- At that delivery, v2.5/build 16 was recoverable under `build/previous.g6aJIt`.
- On September 4, the three superseded v2.6 candidates were removed; the signed app and ten distinct-version recoveries were retained at that time.
- The September 6 cleanup later removed every build-folder recovery.
- Full core/store suites were not rerun for the September 4 cleanup.

On September 3, live checks of an initial candidate confirmed prose wrapping, compact headers, an inline single-field editor, disabled empty Save, and enabled Save for a multiline draft.

- No saved notes were changed.
- Live inspection after the width correction confirmed the 1,120-point minimum, the single-row header, and the collapsed sidebar endpoint.
- The final review found no production-code issue.

It fixed the malformed-note regression fixture so the failure is attributable to note content rather than a missing top-level field, and centralized the minimum-window value.

- Formal verification then repeated the affected tests, complete compilation, cache-free optimized packaging, and strict package checks.
- Native icon packaging required its normal macOS access outside the command sandbox;

- the unchanged rule then succeeded.
- The Mac was locked before the corrected expansion animation and remaining editor interactions could be reinspected.
- Source is committed in `bfa6c70` and `262e934`.

- The documented native tests passed 339 core, 40 store, 41 note/presentation, and 12 version checks.
- The final optimized app compiled, passed strict signing and exact source-metadata/icon checks, and launched from the project root.
- The user subsequently authorized removal of all build-folder outputs, including the previously preserved v2.6/build-26 recovery.

- On September 6, explicitly authorized cleanup removed the entire `build/` folder and stale Finder metadata: 231 obsolete generated files (179.7 MB), including compiler caches, test executables, icon intermediates, eleven older-version recovery bundles, and one superseded v2.7 candidate.

The signed v2.7 app at the project root retains its exact audited bytes and valid strict signature. No build-folder recovery remains. The older binaries were deleted locally; generated intermediates can be rebuilt.
- Source code, editable icon masters, and audit evidence were preserved.
- Supplemental checks validated the SVG references, PNG decoding, and all ten packaged icon sizes; the source and packaged artwork were also visually inspected.

- Live inspection confirmed wrapping tags at the minimum width, named collapsed navigation, centered workflows, horizontal access to all four branches in a disposable wide-graph fixture, activity distributions and threshold descriptions, and empty/multiline note-editor states with Escape cancellation.

- The test draft was not saved and the original repository selection was restored.
- Native button accessibility activation passed; Tab focus traversal was not confirmed under the current macOS keyboard settings.

- The **v2.6 (build 26) baseline** established the following behavior and prior delivery evidence.
- The compact project header groups identity and actions with Document Health and a simple **Notes available / No notes** summary;

- it no longer shows progress or note counters.
- The 16-point card inset and eight-point tab/content gap remain.
- During the pending v2.6 delivery checks on September 3, the minimum window width was raised to 1,120 points so actions, Document Health, and Notes retain one horizontal row with the sidebar expanded.

- The detection caption can wrap.
- The same delivery correction keeps sidebar content at its expanded layout width behind the changing rail boundary, retains eager category layout, and fades newly revealed project rows instead of sliding them from the top.
- Existing icon columns, footer actions, category behavior, and Reduce Motion remain.

- **Work notes** has an integrated Add note toolbar and an inline, single-text-field editor with Save and Cancel.
- There are no title, context, or status fields.
- Existing title and context text are combined with a blank line, retaining note identities; files are not rewritten merely by loading them.
- Edits, deletion, atomic saves, and read-only recovery for malformed storage remain supported.

- Every prose/list group below the tabs now uses the established translucent content surface, even when the same tab also contains headings or tables.
- Standalone headings, already surfaced tables, workflow diagrams, and history rows keep their existing presentation.
- Empty states and workflow guidance are also surfaced.
- Packaging now rejects mismatched version/build pairs under the repository policy.

- The authorized code review found no production-code correctness, security, performance, or maintainability defect.
- It corrected a malformed-note fixture that could previously pass for the wrong reason and gave the 1,120-point minimum one named source of truth.

- Verification passed 40 focused note/presentation assertions, nine version checks, 20 affected core checks, five affected store checks, complete native compilation, a cache-free optimized build, and strict signature, metadata, arm64, and icon checks.

- Earlier live inspection confirmed the minimum-width header and collapsed sidebar endpoint.
- The Mac remained locked for the corrected expansion-path and remaining editor interaction checks.
- Implementation is committed in `bfa6c70` and `262e934`; this documentation checkpoint records the result.

- The prior **v2.6/build-26 local app** replaced the notes gauge with a compact availability summary beside Document Health, tightened the header, and introduced an inline plain-text Work notes editor.

The September 3 v2.6 delivery correction sets a 1,120-point minimum width and keeps both summaries beside the actions with expanded navigation; app-detection captions can wrap.

- Sidebar content also keeps its expanded layout width behind the changing rail boundary; eager category layout and opacity-only project-row reveals replace the top-slide insertion.
- Legacy title/context text and note IDs are retained on read;

- status tracking is retired.
- Prose/list groups, empty states, and workflow guidance below the tabs receive the established translucent surface, while headings and existing tables/diagrams keep their presentation.
- Packaging rejects mismatched version/build pairs.

- The authorized review found no production-code issue.
- It corrected a malformed-note fixture that could pass for the wrong reason and centralized the 1,120-point minimum.
- Formal verification passed 40 focused note/presentation assertions, nine numbering checks, 20 affected core checks, five affected store checks, complete native compilation, a cache-free optimized build, and strict signature, metadata, arm64, and icon checks.

- Earlier live inspection confirmed the minimum-width header and collapsed sidebar endpoint; the Mac remained locked for the corrected expansion path and remaining editor interactions.
- Source is committed in `bfa6c70` and `262e934`, with project documentation in `71d43d3`.
- The v2.5 app remains recoverable under `build/previous.g6aJIt`.

- The **v2.5/build-16 local release** combines project identity, actions, and Document Health in one compact glass card above the tabs.
- The icon, name, and version are top-aligned beside the notes gauge;

- folder, README, app, optional app-menu, detection, document availability, and runtime-status information form an adaptive lower grouping.
- A 16-point card inset reduces the top/side space, and an eight-point gap connects the tabs to their content.

- Existing warnings, below-tab content styling, notes, history, repository activity, navigation, artwork, and lock behavior are unchanged.
- Native type-checking, a cache-free optimized build, strict package checks, and live regular/minimum-window inspection passed.

- The signed project-root app is v2.5/build 16.
- The subsequent authorized review found no actionable issues; verification repeated the cache-free build, strict package checks, and live narrow-window header inspection.
- The initially uncommitted delivery is recorded in this checkpoint.
- The prior v2.4/build-15 bundle remains recoverable under `build/previous.6HZ7jk`.

The **v2.4/build-15 local release** lets the native macOS window own the outside curve, removes the competing whole-shell mask, and reduces the black detail reveal to three points.

- Its independently tuned 18-point detail radius visually follows the native window at all four corners.
- Untitled paragraph/bullet README views below the tabs use the established rounded translucent plane, while heading-led boxes, tables, Workflows, history, notes, and content above the tabs keep their existing structure.

- The shared active/lock artwork now has a denser sage halftone fading upward from its lower region.
- The active detail repeats it crisply above the background blur, while the clear lock view adds a denser full-frame field of dots and short matrix marks.

- Repository README, repository actions, and Lock use matching full-width book, adjustment, and lock rows with longer balanced Open README file, Repository menu, and Lock application labels in the separated rail footer, followed by compact workspace/sync status and the live bundle version.

- The detail header no longer duplicates footer actions, and all compact action/navigation icons remain on one axis.
- Lock and unlock crossfade edge-to-edge without scaling or a competing artwork mask.

- All 332 core checks and 39 store checks passed, followed by optimized compilation, strict signing, exact v2.4/build-15 metadata, arm64/icon checks, and live Overview, Architecture, Workflows, expanded/collapsed footer, lock-artwork, halftone, and corner inspection.

- The complete code review found no actionable source findings.
- Formal verification repeated a clean optimized rebuild, strict package-identity checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection. v2.3/build 14 is preserved under `Project Control/build/previous.bIh8aG`.

**Evidence and delivery status**

Source `bfa6c70`; this project documentation checkpoint; signed project-root app

Source `bfa6c70`; navigation `262e934`; project record `71d43d3`; signed project-root app

[Back to change history](#change-history)

<a id="change-9"></a>
<a id="readme-detail-27"></a>
<a id="readme-detail-6"></a>
<a id="repository-record-7"></a>
<a id="v25-delivery-evidence"></a>

### v2.5 / build 16

- **Recorded date:** 2026-09-02.

- Combined project identity, actions, and Document Health in one compact pre-tab glass card.
- Top-aligned the icon/name/version beside the notes gauge; grouped folder, README, app, optional app-menu, detection, document availability, and runtime-status information below.

- Reduced this card's content inset to 16 points and its internal row gap to 14 points; adaptive action/status layouts preserve narrow-window readability.
- Reduced the tab-to-content gap to eight points.

- Existing warnings, below-tab content styling, notes, history, repository activity, navigation, artwork, and lock behavior are unchanged.
- Passed complete native type-checking, a cache-free optimized build, strict signing, exact v2.5/build-16 metadata, arm64/icon checks, and live regular/minimum-window checks with Local Assistant and Python Accomplishments.

- Core/store suites were unchanged and not rerun.
- The subsequent authorized review found no actionable issues; verification repeated a cache-free optimized build, strict package checks, and live narrow-window header inspection.
- Preserved v2.4/build 15 under `build/previous.6HZ7jk`; removed superseded same-version candidates and generated intermediates.

- Delivered v2.5/build 16 with project identity, actions, and Document Health in one compact pre-tab glass card.
- Top-aligned the icon/name/version beside the notes gauge; grouped folder, README, app, optional app-menu, detection, document availability, and runtime-status information below.

- The v2.5/build-16 source combines project identity, actions, and Document Health in one pre-tab card.
- The identity is top-aligned with the notes gauge; the action controls, application-detection message, document availability, and runtime disclaimer form a compact lower grouping.

- The card alone uses a 16-point inset, leaving other glass-card styling unchanged.
- The action/status row drops its title-column offset or stacks when needed, and the tab-to-content gap is eight points.
- No action, launch-selection, warning, note, README-parsing, or repository-data behavior changes.

- Complete native type-checking passed, followed by a cache-free optimized build and strict signed-bundle checks.
- Source and bundle metadata both identify v2.5/build 16; the executable is arm64 and the bundled icon is present.

- Live app inspection covered Local Assistant and the longer Python Accomplishments title at regular and minimum window sizes, confirming visible actions, detection text, integrated health, notes gauge, and unclipped tab/content layout.

- Core/store logic was unchanged, so those suites were not rerun.
- The subsequent authorized review found no actionable issues.
- Verification repeated a cache-free optimized build, strict signature/metadata/arm64/icon checks, and live narrow-window Local Assistant and Python Accomplishments header inspection.

- The initial delivery preceded that review and was uncommitted.
- The prior v2.4/build-15 bundle remains recoverable under `build/previous.6HZ7jk`; superseded same-version candidates and generated intermediates were removed after the final package checks.

**Evidence and delivery status**

Source `52cbaf7`; this documentation checkpoint; signed project-root app

[Back to change history](#change-history)

<a id="change-10"></a>

### Documentation

- **Recorded date:** 2026-09-02.

- Moved generic version and build-number rules to the repository README, retained Project Control's bundle-delivery procedure here, and added the required linked project declaration.
- Application source, metadata, signed bundle, and v2.4/build 15 are unchanged.

**Evidence and delivery status**

This documentation commit

[Back to change history](#change-history)

<a id="change-11"></a>
<a id="readme-detail-28"></a>
<a id="readme-detail-7"></a>
<a id="repository-record-8"></a>
<a id="v24-delivery-evidence"></a>

### v2.4 / build 15

- **Recorded date:** 2026-09-02.

- Removed the competing whole-shell SwiftUI clip and outline so the native macOS window owns the outer corners without light wedges.
- Kept the full black chassis and three-point detail reveal, then visually tuned the detail layer to an 18-point radius so all four rendered curves follow the native window.

- Removed the lock artwork's custom outer mask and changed lock/unlock to an edge-to-edge opacity transition without shell scaling.
- Wrapped only untitled below-tab paragraph/bullet README views in the established rounded translucent plane;

- heading-led content, tables, Workflows, history, notes, and content above the tabs remain unchanged.
- Added a lower-third sage halftone to the shared active/lock artwork, repeated it crisply above the normal detail blur, and added a denser full-frame dot-and-short-mark matrix only to the clear lock view.

- Moved repository README, repository actions, and Lock into consistently styled full-width pinned footer rows with aligned book, adjustment, and lock symbols and longer balanced Open README file, Repository menu, and Lock application labels.

- The menu's visible row now uses the same fixed leading layout as the plain buttons instead of the borderless menu's intrinsic alignment.
- Compact workspace/sync status and the live bundle version follow below on the visible icon-column inset;

- duplicate header/detail controls remain removed and the compact icon axis is retained.
- Passed 332 core checks, 39 store checks, optimized compilation, strict signing, exact v2.4/build-15 metadata, arm64/icon checks, and live repository/project Overview, Architecture, Workflows, expanded/collapsed footer, lock-artwork, halftone, and corner inspection.

- The complete code review found no actionable source findings.
- Formal verification repeated a clean optimized rebuild, strict package-identity checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection.
- Preserved v2.3/build 14 under `build/previous.bIh8aG`.

- Delivered v2.4/build 15 with native-owned outer corners, a three-point black detail reveal, and an independently tuned 18-point detail radius whose four rendered curves visually follow the window.

- Preserved heading-led content, tables, Workflows, history, notes, and above-tab presentation.
- Added a lower sage halftone to shared active/lock artwork, repeated it crisply above the normal detail blur, and added a denser full-frame dot-and-short-mark matrix only to the clear lock view.

- Moved repository README, repository actions, and Lock into matching full-width pinned footer rows with one fixed icon axis and longer balanced Open README file, Repository menu, and Lock application labels.

- The menu's visible row uses the same leading layout as the plain buttons instead of its intrinsic borderless alignment.
- Compact workspace/sync status and the live bundle version follow below on the visible icon-column inset;

- duplicate detail controls remain removed and compact icons remain centered.
- Passed 332 core checks, 39 store checks, optimized compilation, strict signing, exact v2.4/build-15 metadata, arm64/icon checks, and live Overview, Architecture, Workflows, expanded/collapsed footer, lock-artwork, halftone, and corner inspection.

- The v2.4/build-15 source removes only the artificial whole-shell SwiftUI clip and outline; the native window owns the outside corners while the full black chassis and independently rounded detail surface remain.

The three-point reveal and visually tuned 18-point detail radius align all four rendered detail corners with the native window instead of deriving the radius from an assumed outer value.

- Lock and unlock use an opacity-only transition, and the lock artwork has no competing outer mask or outline. `ReadmeContent` detects views made only of paragraph/bullet prose and encloses those untitled areas in the established rounded translucent plane.

- Heading-led content, native tables, Workflow titles and diagrams, history disclosure rows, work-note rows, and every area above the tabs retain their existing presentation.
- A lower-third sage halftone is drawn inside the shared active/lock artwork and repeated above the normal detail blur so its dots remain visible in the same lower position.

- The clear lock view also places a denser full-frame matrix of dots and short marks over the artwork.
- Repository README, repository actions, and Lock controls use matching book, adjustment, and lock rows with longer balanced Open README file, Repository menu, and Lock application labels beneath a hierarchy separator;

- compact workspace/sync status and the live bundle version follow a second separator and align to the visible icon column rather than the rail edge.
- All footer icons remain centered in the collapsed rail, and the detail header keeps identity/context without duplicated actions.

- All 332 core checks and 39 store checks passed.
- Optimized arm64 compilation, strict signing, exact source/bundle v2.4/build-15 metadata, icon checks, root-bundle promotion, and live inspection of repository/project Overviews, Architecture, Workflows, expanded/collapsed rails, lock artwork, halftone density, and the native/detail curves passed.

- The complete code review found no actionable source findings.
- Formal verification repeated a clean optimized rebuild, strict signing, source/bundle identity, arm64/icon checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection.
- The replaced v2.3/build-14 bundle is preserved at `build/previous.bIh8aG`.

**Evidence and delivery status**

Source `014523d`; this project documentation checkpoint; signed project-root app

Source `014523d`; project documentation `ceb9c78`; this root checkpoint; signed project-root app

[Back to change history](#change-history)

<a id="change-12"></a>
<a id="readme-detail-29"></a>
<a id="readme-detail-8"></a>
<a id="repository-record-9"></a>
<a id="v23-delivery-evidence"></a>

### v2.3 / build 14

- **Recorded date:** 2026-09-01.

- Added repository Commit activity with newest-first years, twelve responsive month cells, fixed absolute intensities, concealed future values, complete unique-commit totals, and per-project hover distributions with real project icons when available.

- Read-only Git access now includes changed paths solely to map registered top-level folders; messages, authors, and file contents remain unread.
- Reworked the shell into a full-window rounded black chassis plus an inset four-corner light-artwork detail layer, reused the same artwork clearly for the lock screen and blurred behind normal content, removed rail/detail overlap and visible scrollbars, adopted the reference-style brand control, and kept every rail icon on one fixed animation axis.

- Passed 8 focused core checks, 1 store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata checks, arm64/icon checks, and live expanded/collapsed/lock inspection.
- Optional code review and formal verification did not run.
- Preserved v2.2/build 13 under `build/previous.IqYCW4`.

- Delivered v2.3/build 14 with repository Commit activity: newest-first years, twelve responsive month cells, fixed absolute intensities, concealed future values, unique-commit totals, and hover cards listing affected project icons, names, and counts.

- Read-only Git access includes changed paths solely for registered-project mapping; messages, authors, and file contents remain unread.
- Rebuilt the shell as a full-window rounded black chassis with an inset four-corner light-artwork detail layer above it, reused the same artwork clearly for the lock screen and blurred behind normal content, removed rail/detail overlap and visible scrollbars, adopted the reference-style brand control, and kept rail icons on one animation axis.

- Passed 8 focused core checks, 1 store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata, arm64/icon checks, and live expanded/collapsed/lock inspection.
- Optional code review and formal verification did not run.
- Preserved v2.2/build 13 under `build/previous.IqYCW4`.

- The v2.3/build-14 source adds the read-only repository Commit activity tab and its project-aware hover distributions.
- The completed visual correction uses one rounded black chassis as the full window base, exposes that chassis as the left rail and detail perimeter, and places one rounded light-artwork detail panel above it.

The active detail view blurs the same artwork that the lock view shows clearly. The expanded brand row and collapsed 40-point icon column share one leading axis; top navigation, scrolling project groups, and the pinned local-only status remain structurally separate.
- Reduce Motion suppresses transitions, while Reduce Transparency retains the solid detail fallback.

- Eight focused activity core checks, one store check, native type-checking, optimized compilation, strict signing, metadata, executable, icon, and live expanded/collapsed/lock checks passed.
- Optional code review and formal verification did not run.
- The activity implementation is committed in `bb0689e`, the shell implementation is committed in `a01102b`, and this documentation checkpoint records their delivered state.

- The earlier **v2.3/build-14 local release** adds Commit activity to the repository parent.
- It invokes the fixed system Git executable directly with read-only arguments, loads every unique reachable commit, and groups valid timestamps into newest-first distinct years and twelve months with fixed absolute activity levels.

- Future cells are dimmed and conceal counts; the footer keeps the complete loaded total independent from valid monthly buckets.
- Hovering a populated cell shows each affected current project's icon, name, and participation count.
- Changed paths are read only to map top-level registered project folders; commit messages, authors, and file contents remain unread.

The shell now has two explicit layers: one rounded black chassis covers the complete app, and one inset light-artwork panel sits above it in the right-hand detail region.

The chassis is visible as the left rail and the narrow perimeter around all four detail corners. The normal panel blurs the same artwork that the lock screen shows clearly.

- The reference-style brand control remains visible in both rail states, and every icon keeps one fixed axis while labels animate.
- Eight focused core checks, one store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata, arm64/icon checks, and live expanded/collapsed activity inspection passed.
- Optional code review and formal verification did not run.

The replaced v2.2/build-13 app is preserved for recovery.

**Evidence and delivery status**

Activity `bb0689e`; shell `a01102b`; this documentation checkpoint; signed project-root app

Activity `bb0689e`; shell `a01102b`; project documentation `78bbbab`; this root checkpoint

[Back to change history](#change-history)

<a id="change-13"></a>
<a id="readme-detail-30"></a>
<a id="readme-detail-9"></a>
<a id="repository-record-10"></a>
<a id="v22-delivery-evidence"></a>

### v2.2 / build 13

- **Recorded date:** 2026-09-01.

Moved Category, Technical scope, and Technologies into the first three labelled Professional scope bullets so the root register can use three readable columns without losing project detail.

- Added case-insensitive labelled-scope parsing, explicit blank behavior, and backward-compatible separate-column precedence; the retired AI-usage column remains ignored.
- Existing glass UI and all project-management behavior are unchanged.

- Passed 20 focused core checks, 5 isolated store checks, complete native type-checking, cache-free optimized compilation, strict signing, exact metadata equality, arm64 executable/icon checks, promotion, and separate-instance root launch.
- Preserved v2.1/build 12 under `build/previous.ftKKT9`; removed generated intermediates and the smoke process.
- Optional review and formal verification did not run.

- Delivered v2.2/build 13 with Category, Technical scope, and Technologies as the first three labelled bullets in every Professional scope cell, reducing the Projects register to three readable columns while preserving its complete descriptions.

- Added case-insensitive labelled-scope parsing, explicit blank handling, and compatibility precedence for older separate columns; the retired AI-usage column remains ignored.
- Existing glass UI and project-management behavior are unchanged.

- Passed 20 focused core checks, 5 isolated store checks, complete native type-checking, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, arm64 executable/icon checks, promotion, and separate-instance root launch.
- Preserved v2.1/build 12 under `build/previous.ftKKT9`; removed generated intermediates and the smoke process.
- Optional review and formal verification did not run.

- The v2.2/build-13 source moves Category, Technical scope, and Technologies into the first three labelled list items of every root-register Professional scope cell, allowing the human-facing table to use three readable columns.

- The parser reads those labels case-insensitively and strips display markup.
- Older separate columns remain compatible and override same-named scope labels when present, including explicit blanks;

- the retired AI-usage column remains ignored.
- Existing glass UI, project content, notes, launch behavior, and synchronization paths are unchanged.
- All 20 focused core checks and 5 isolated store checks passed, including the new labelled-scope, blank-value, compatibility, and precedence regressions.

- Complete native type-checking, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, arm64 executable and icon checks, bundle promotion, and a separate-instance project-root launch passed.

- Source is committed in `ad84aa7`.
- The v2.1 bundle is preserved at `build/previous.ftKKT9`; generated compiler/icon intermediates and the smoke process were removed.
- Optional code review and formal verification did not run.

- The earlier **v2.2/build-13 local release** reads Category, Technical scope, and Technologies from the first three labelled bullets in each Professional scope cell, allowing the root Projects register to use three readable columns without losing the full project descriptions.

- Older separate classification columns remain compatible and take precedence when present, including explicit blanks.
- The v2.1 glass interface and all existing project-management behavior are unchanged.

- All 20 focused core checks, 5 isolated store checks, and complete native type-checking passed.
- Cache-free optimized compilation, strict signing, exact source/bundle metadata equality, arm64 executable/icon checks, promotion, and a separate-instance root launch also passed.
- Optional review and formal verification did not run. v2.1/build 12 is preserved as the newest recovery bundle.

**Evidence and delivery status**

Source `ad84aa7`; this project documentation and delivery checkpoint

Source `ad84aa7`; project delivery record and this root documentation checkpoint

[Back to change history](#change-history)

<a id="change-14"></a>
<a id="readme-detail-10"></a>
<a id="readme-detail-31"></a>
<a id="repository-record-11"></a>
<a id="v21-delivery-evidence"></a>

### v2.1 / build 12

- **Recorded date:** 2026-09-01.

- Delivered the approved edge-to-edge glass correction: removed all four outer shell insets, moved title-bar clearance inside the rail, added a full-window local sky/cloud/texture scene, switched native material to in-window sampling, and removed the normal opaque tint.

- Reduce Transparency retains a solid fallback; existing data and interaction paths are unchanged.
- Complete native type-checking passed.
- A controlled 1320×760 render confirmed shell coverage at every edge midpoint and visible scene variation across the glass plane, followed by visual inspection of the zero-gap boundary, shared backdrop, and content readability.

- Cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, promotion, and separate-instance launch passed.
- Core/store suites were unchanged and not rerun; optional review and formal verification did not run.
- Preserved v2.0/build 11 under `build/previous.Yj7LyM`; removed generated intermediates and the smoke process.

- Delivered v2.1/build 12 as the approved edge-to-edge glass correction.
- Removed the shell's four outer insets, moved title-bar clearance inside the hierarchy rail, added a full-window local sky/cloud/texture scene, switched native material to in-window sampling, and removed the normal opaque tint.

- Reduce Transparency retains a solid fallback.
- Added the Project Control-specific rendered acceptance rule to root AGENTS.md without changing sibling-project policy.
- Existing README-driven data and interaction paths are unchanged.

- Cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, promotion, and separate-instance root launch passed.
- Core/store suites were unchanged and not rerun; optional review and formal verification did not run.
- Preserved v2.0/build 11 under `build/previous.Yj7LyM`; removed generated intermediates and the smoke process.

- The v2.1/build-12 source removes every outer shell inset, keeps title-bar clearance inside the navigation rail, and replaces desktop-only sampling with a full-window local scene and `withinWindow` native material.

Normal appearance adds no opaque tint above the material; Reduce Transparency alone uses the existing strong surface. The lock artwork shares the same scene and also fills the window.

- README parsing, classifications, notes, app discovery, tabs, native tables, and diagrams are unchanged.
- Complete native type-checking and a controlled 1320×760 render passed; the render confirmed full edge coverage and visible scene variation across the content plane and was inspected for boundary, backdrop, and readability.

- After the source and dual-README checkpoints were committed, cache-free optimized compilation, strict signing, source/bundle metadata equality, icon/executable checks, bundle promotion, and a separate-instance root launch passed.

- The v2.0 bundle is preserved at `build/previous.Yj7LyM`; generated intermediates and the smoke process were removed.
- Core/store behavior was unchanged and those suites were not rerun.
- Optional code review and formal verification did not run.

- The earlier **v2.1/build-12 local release** corrects the approved cinematic glass direction.
- It removes the shell's four outer insets, moves title-bar clearance inside the hierarchy rail, places a local sky/cloud/texture scene across the whole window, and uses native in-window sampling so that scene remains visible beneath the content plane.

- Normal appearance adds no opaque content tint; Reduce Transparency retains a solid fallback.
- The data and interaction paths are unchanged.
- Complete native type-checking passed, and a controlled 1320×760 render confirmed full edge coverage plus visible scene variation across the content plane.

- Cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, promotion, and a separate-instance root launch also passed.
- Core/store suites were unchanged and not rerun; optional review and formal verification did not run. v2.0/build 11 is preserved as the newest recovery bundle.

- The **v2.0/build-11 source release** replaces the earlier angular navy interface with the approved cinematic glass direction.
- A transparent native window and real behind-window desktop blur sit inside one outlined rounded shell;

- the black hierarchy rail expands and collapses with aligned icons, project disclosure rows animate individually, long content scrolls within the bounded window without visible indicators, and a no-password lock replaces the whole interface with local artwork and a centered Unlock control.

- Offscreen inspection removed a redundant lock caption that crossed the artwork silhouette.
- The data, note, project-icon, app-discovery, table, tab, diagram, and README-refresh paths remain.
- All 323 core checks, 39 store checks, and native type-checking passed before distributable compilation.

- The first signed v2.0 candidate was superseded after the user's screenshot showed its internal green field; `0e07484` provides the real desktop-glass correction.
- The corrected build passed strict signing, exact source/bundle metadata equality, and separate-instance root launch.
- ScreenCaptureKit denied final live capture; optional review and formal verification did not run.

- The **v1.0/build-10 local release** replaces mandatory AI-usage badges with optional, individually wrapping technology/approach tags and a separate technical-scope line.
- The root register supplies the tags for all six projects.

- Passed 19 parser/register checks, 5 store checks, native type-checking, and 24 tag-layout cases; isolated native renders were inspected.
- Source was committed separately in `9f3e399` (metadata/sync), `eb643cb` (header), and `2a512b8` (sidebar), with root metadata/policy in `b43b9fd` and release records in `19ac73f` / `6d6e110`, before building.

- A cache-free optimized arm64 build passed strict signature/metadata/icon checks and project-root process launch.
- The unchanged v0.9 bundle is preserved for recovery.
- Live interaction, optional code review, and formal verification are not claimed.

**Evidence and delivery status**

Source `8c7981c`; source record `0c57d69`; root source record `9738555`; this delivery checkpoint

Source `8c7981c`; project source record `0c57d69`; root source record `9738555`; project delivery `efe483d`; this delivery checkpoint

[Back to change history](#change-history)

<a id="change-15"></a>
<a id="readme-detail-11"></a>
<a id="readme-detail-32"></a>
<a id="repository-record-12"></a>
<a id="v20-source-checkpoint"></a>

### v2.0 / build 11

- **Recorded date:** 2026-09-01.

- Delivered the complete cinematic glass redesign: a transparent native window, real behind-window desktop blur, one outlined rounded shell, aligned expanding/collapsing hierarchy rail, staggered per-project disclosure motion, bounded internal scrolling with hidden indicators, rounded content cards, and a no-password artwork lock with centered Unlock.

- The user's screenshot rejected the first signed candidate because it showed an internal green field; `0e07484` replaced it with actual behind-window material.
- Offscreen inspection also removed a redundant lock caption that crossed the fortress silhouette.

- Preserved README-derived data, notes, classifications, icons, app discovery, tables, tabs, diagrams, and background synchronization.
- Passed 323 core checks, 39 store checks, native type-checking, optimized compilation, strict signing, exact source/bundle metadata equality, and separate-instance root launch.

- Final live capture remained unavailable because ScreenCaptureKit access was denied; optional review and formal verification did not run.
- Removed the superseded v2.0 bundle and generated intermediates; preserved v1.0 and documented older recoveries.
- Superseded Vector/Lens design files remain in Git history.

- Delivered v2.0/build 11 as a complete cinematic glass redesign.
- Added a transparent native window, real behind-window desktop blur, one outlined rounded shell, an aligned expanding/collapsing hierarchy rail, staggered per-project disclosure transitions, bounded internal scrolling with hidden indicators, rounded content cards, and a no-password artwork lock with centered Unlock.

- The user's screenshot rejected the first signed candidate because it showed an internal green field; source `0e07484` replaced it with real behind-window material.
- Offscreen inspection also removed a redundant lock caption that crossed the fortress silhouette.

- Preserved README-derived content, classifications, notes, icons, app discovery, tables, tabs, diagrams, and source synchronization.
- Passed 323 core checks, 39 store checks, native type-checking, optimized compilation, strict signing, exact source/bundle metadata equality, and separate-instance root launch.

- Final live capture remained unavailable because ScreenCaptureKit access was denied; optional review and formal verification did not run.
- Removed the superseded v2.0 bundle and generated intermediates; preserved v1.0 and documented older recoveries.
- Superseded Vector/Lens reference files remain in Git history.

- The v2.0/build-11 source implements the outlined rounded shell, transparent native window, real desktop blur, aligned collapsible rail, staggered project-row disclosures, hidden scroll indicators, and centered artwork unlock.

- Offscreen inspection removed a redundant lock caption that crossed the fortress silhouette.
- README parsing, classifications, notes, application discovery, content tabs, tables, and workflow data paths remain unchanged.

- All **323 core checks** and **39 store checks** passed, followed by complete native type-checking.
- The first signed candidate was rejected after the user's screenshot exposed its internal green field;

- `0e07484` provides the transparent-window and behind-window correction.
- After the source and dual-README checkpoints were committed, a clean optimized build passed strict signing, source/bundle metadata equality, and separate-instance launch.

- Offscreen repository/project renders confirmed the outlined shell, rounded hierarchy, real app icons, fixed-height content, and centered lock control; behind-window sampling itself requires the live window.

- ScreenCaptureKit remained denied, so final live interaction is not claimed.
- Optional code review and formal verification have not run.
- The superseded v2.0 bundle and generated intermediates were removed; the v1.0 recovery remains unchanged.

**Evidence and delivery status**

Initial source `32f2df4`; desktop glass `0e07484`; source records `2f44ecd`, `92c5186`; root records `92491bd`, `a1edc1d`; this delivery checkpoint

Initial source `32f2df4`; desktop glass `0e07484`; project records `2f44ecd`, `92c5186`, `9de1a2a`; root records `92491bd`, `a1edc1d`; this root delivery checkpoint

[Back to change history](#change-history)

<a id="change-16"></a>
<a id="readme-detail-12"></a>
<a id="readme-detail-33"></a>
<a id="repository-record-13"></a>
<a id="v10-delivery-evidence"></a>

### v1.0 / build 10

- **Recorded date:** 2026-08-31.

- Replaced mandatory AI-usage badges with optional root-README Technologies tags, keeping technical scope separate.
- Added per-tag wrapping, case-insensitive deduplication, explicit empty/legacy behavior, and focused parser/store regressions.

- Updated all six register entries and the Project Control-only tag rule.
- Passed 19 parser/register checks, 5 store checks, native type-checking, and 24 tag-layout cases; inspected isolated native renders.

- No live-interaction, code-review, or formal-verification claim.
- User-authorized source/release commits preceded a cache-free optimized build.
- Strict signing, matching source/bundle metadata, unchanged Nexus icon, and project-root launch passed.

- Preserved v0.9 with unchanged executable/metadata/icon checksums and retained documented older recoveries.
- Removed generated compiler/icon intermediates and closed the new smoke-test process; no existing Project Control process was present.
- No build-gate exception was used.

- Delivered v1.0/build 10 with optional README Technologies tags, per-tag wrapping, deduplication, and explicit empty/retired-column behavior, with technical scope kept separate.
- Updated the six-project root register, focused parser/store regressions, both README records, and the Project Control-only rule in root AGENTS.md.

- Passed 19 parser/register checks, 5 store checks, native type-checking, and 24 tag-layout cases; inspected isolated native renders without screen capture.
- No live-interaction, code-review, or formal-verification claim.

- Separate user-authorized source/release commits preceded the cache-free optimized build, without a build-gate exception.
- Strict signing, matching source/bundle metadata, unchanged Nexus icon, and root-level launch passed.

- Preserved v0.9 with all three payload checksums unchanged; retained documented older recoveries.
- Removed generated compiler/icon intermediates.
- Closed only the new smoke-test instance; no existing Project Control process was present.

- The parser, sidebar, scoped tag policy, and root register are updated in source.
- Passed **19 focused parser/register checks**, **5 store checks**, native type-checking, and **24 native tag-layout cases** at 64-, 148-, and 320-point widths, including empty and long labels.

Offscreen views at 900×660 and 1160×840 and a six-project tag panel were inspected. An isolated render needed normal macOS icon-service access outside the agent sandbox; it captured only its own never-shown views, not desktop pixels.
- No screen-recording permission was changed or retried.
- These checks do not establish live scrolling, keyboard interaction, or installed-app behavior.

- After the user-authorized source and release-record commits, a cache-free optimized arm64 build was promoted to the project root.
- Strict signing, exact source/bundle metadata equality, v1.0/build-10 identity, unchanged Nexus icon bytes, and a fresh root-level process launch passed.

- The smoke-test process remained running for at least 47 seconds and was then closed; no existing Project Control process was present before the check.
- This confirms launch, not live interaction.

- The preserved v0.9 bundle at `build/previous.6S5wt3/Project Control.app` retains its valid signature and exact pre-build executable, metadata, and icon checksums.
- The documented v0.8/v0.7 recoveries are retained.
- Generated compiler caches and intermediate icon files were removed; these can be regenerated.
- No desktop capture or privacy-setting change was attempted.

Run only the classification regressions from this project folder:

```sh
make test-core test-store TEST_ARGS=--classification
```

- These exercise optional/reordered columns, literal technology names, empty/duplicate tags, retired AI metadata, tag edits/removals, the actual six-project register, and stale-project refresh while preserving selection and notes.
- Omitting `TEST_ARGS` retains the existing test targets' complete behavior.

**Evidence and delivery status**

`9f3e399`, `eb643cb`, `2a512b8`; root metadata/policy `b43b9fd`; pre-build release records `19ac73f`, `6d6e110`

[Back to change history](#change-history)

<a id="change-17"></a>
<a id="readme-detail-13"></a>
<a id="readme-detail-34"></a>
<a id="repository-record-14"></a>
<a id="v09-delivery-evidence"></a>

### v0.9 / build 9

- **Recorded date:** 2026-08-31.

- Corrected header icon/title proportions, left alignment, and the ellipsis/disclosure overlap.
- Added collapsible source-ordered categories, counts, and independently wrapping technical-scope/AI-usage badges from optional root-register columns.
- Missing metadata remains unspecified;

- root classification changes still apply when a project README is stale.
- Existing notes and selection are preserved.
- Passed 312 core checks, 38 store checks, native type-checking, offscreen layouts, clean compilation, strict bundle identity/signature checks, and project-root launch.
- Preserved v0.8 unchanged; removed temporary/generated intermediates.
- Live UI interaction, optional review, and formal verification remain unconfirmed or not run.

Source was uncommitted at delivery.

- Implemented v0.9/build 9 header sizing, a non-overlapping ellipsis menu, and five collapsible README-driven categories with independent technical-scope/AI badges.
- Optional metadata remains backward-compatible; classification updates preserve project identity and work notes.

- Passed 312 core checks, 38 store checks, native type-checking, offscreen layouts, clean compilation, strict bundle identity/signature checks, and project-root launch.
- Preserved v0.8 unchanged and removed temporary/generated intermediates.
- Live interaction remains unconfirmed after capture denial; optional review and formal verification have not run.
- Source was uncommitted at delivery.

- The focused checks cover case-insensitive and reordered optional metadata columns, custom category names, missing/blank/short rows, duplicate projects, source ordering, README-triggered regrouping, and preservation of selection/notes while project content is stale.
- The new source fixtures and the live six-project register passed: **312 core checks and 38 store checks**.

- Native type-checking and a cache-free optimized build passed.
- Isolated, never-shown views were rendered at 900×660 and 1160×840, plus a tall register showing all five categories and a minimum-width long-repository-name case.

- The header icon/title alignment, separate ellipsis, wrapping badges, counts, selection highlight, and real app/fallback icons were inspected.
- The design pass retains the navy/icy-blue palette and uses informational badges, not health scores.
- These renders do not establish live scrolling, collapsing, keyboard, menu, or window-chrome behavior.

- macOS denied live window capture; no capture permission or privacy setting was changed or retried.
- The render probe and icon packager needed normal macOS icon-service access outside the agent sandbox; neither captured the desktop.
- Strict signing, matching source/bundle metadata, unchanged Nexus icon bytes, and root-level launch passed.
- Only the newly started background smoke-test instance was closed; the existing app session was preserved.

- The preceding v0.8 source/build work was already committed before this build.
- Its replaced bundle retains its original executable, metadata, icon checksums, and valid signature under `build/previous.JxnKxh/Project Control.app`.

- Temporary render sources/images, test binaries, compiler caches, and intermediate icons were removed.
- This v0.9 batch was uncommitted at delivery; its retained header/category implementation is now captured with v1.0 in `9f3e399`, `eb643cb`, and `2a512b8`, not in a separate v0.9 release commit.
- Optional code review and formal verification have not run for that batch.

- The earlier **v0.9/build-9** app was delivered directly in the project folder.
- Its corrected header uses a 36-point Nexus icon, an 18-point title, symmetric spacing, and a separate ellipsis menu without the redundant triangle.

- Five collapsible categories and independent technical-scope/AI-usage badges come from optional root-register columns; missing values remain unspecified.
- Passed 312 core checks, 38 store checks, native type-checking, four native offscreen layouts, clean compilation, strict bundle checks, and root-level launch.

- The unchanged v0.8 bundle is recoverable.
- Live capture was denied; interaction, optional review, and formal verification are not confirmed for this batch.
- Source was uncommitted at delivery; the retained implementation is now captured with v1.0 in `9f3e399`, `eb643cb`, and `2a512b8`, not as a separate v0.9 release commit.

**Evidence and delivery status**

Retained implementation captured with v1.0 in `9f3e399`, `eb643cb`, `2a512b8`; no separate v0.9 release commit

[Back to change history](#change-history)

<a id="change-18"></a>
<a id="repository-record-15"></a>

### Documentation

- **Recorded date:** 2026-08-31.

- Matched all retained release records to Git evidence, clarified releases committed together, and adopted the root-only instruction/history rules.
- At reconciliation, diagram work was paused and v0.8/build 8 was unchanged.
- The records are included with the v1.0 release documentation.

- Reconciled all retained v0.1–v0.8 history with the source commits that recorded it, including intermediate builds committed together. v0.8/build 8 source is committed through 6232bf9.
- At reconciliation, diagram work was paused and the app was unchanged; these records are included with the v1.0 release documentation.

**Evidence and delivery status**

Prior release references below; no separate app build

[Back to change history](#change-history)

<a id="change-19"></a>
<a id="readme-detail-14"></a>
<a id="readme-detail-35"></a>
<a id="repository-record-16"></a>
<a id="v08-delivery-evidence"></a>

### v0.8 / build 8

- **Recorded date:** 2026-08-31.

- Added stable README mappings, content-digest refresh, source warnings/recovery, and one technology/concept per architecture row.
- Review fixed the polling/switch race, malformed empty-register acceptance, and misleading different-root stale state.

- Passed 303 core and 34 store checks, a focused mutation check, native type-checking, clean compilation, native offscreen layouts, and signed-bundle metadata/identity checks.
- Preserved v0.7; retired v0.6 and the superseded candidate to Trash; removed temporary/generated artifacts.
- The existing app process was not restarted; live UI interaction remains unverified.

- Delivered v0.8/build 8 with stable README routing, background content-digest refresh, stale-source recovery, and 117 individually named architecture technologies/concepts across six projects.
- Review fixed polling/switch ordering, register-header validation, and unrelated-root warning state.

- Passed 303 core and 34 store checks, a targeted mutation check, native type-checking, clean compilation, offscreen layouts, and strict signature/metadata checks.
- Preserved v0.7, retired obsolete bundles to Trash, and removed temporary artifacts.
- Live UI interaction remains unverified; the existing app process was not restarted.

- The **v0.8 (build 8)** release was delivered as **Project Control.app** beside this README.
- It adds explicit README section routing, background content-digest checks, visible stale-source recovery, and 117 individually named architecture technologies/concepts across all six projects.
- The selected design, Nexus icon, navigation, notes, diagrams, and app discovery remain.

- Review corrected an old-repository polling race during repository switches, required a real register-table header, and kept a failed different-root choice from falsely marking the current repository stale.

- Final verification passed **303 core checks and 34 store checks**, native type-checking, clean compilation, strict signing and source/bundle metadata checks.
- A disposable copy without the polling guard failed the new repository-switch regression at the expected assertion.
- No actionable findings remain in this reviewed scope.

- Native offscreen rendering produced all six architecture views at 583- and 843-point content widths; minimum-width views, a regular-width representative, and the stale warning were inspected.
- This is layout evidence, not live window/keyboard/file-picker verification.
- An existing app process was left untouched; quit and reopen the root-level app to load the new binary.
- No privacy setting or capture permission was changed.

- The previous v0.7 source was committed before this update, and its unchanged bundle remains recoverable under `build/previous.sH4KB5/Project Control.app`.
- The obsolete v0.6 recovery and superseded pre-review v0.8 candidate were moved to macOS Trash under `Project Control - retired bundles 2026-08-31-sync`.
- Temporary test, mutation, rendering, and compiler/icon artifacts were removed.
- The separate Observatory v2.2 snapshot was rebuilt with permission to leave its pending Atlas/release work uncommitted.

- The earlier v0.8/build-8 app was delivered directly in the project folder, with the unchanged v0.7 preserved for recovery.
- It maps stable README section identifiers, refreshes bounded content digests in the background, and labels stale source content.

- All six project inventories now use one technology/concept per category-table row.
- Final checks passed: 303 core, 34 store, native type-checking, clean compilation, offscreen layouts, and signed bundle identity/metadata.
- The review's polling-race regression also rejected a deliberately reverted guard.

- The v0.5/build-5 source fixes four review findings and passed 57 core checks, 14 store checks, native type-checking, clean compilation, and bundle/launch checks.
- The reviewed source was committed before the distributable build; no build-history exception was needed.

- The v0.6/build-6 update adds native README tables, project icons, and a repository-parent navigation screen.
- It passed 71 core checks, 18 store checks, native type-checking, offscreen layouts, clean compilation, and bundle/launch checks.
- The previous v0.5 work was already committed; its source was uncommitted at delivery.

The v0.7/build-7 update aligns larger project icons with their title line, moves history dates into entry headings, and retains complete architecture tables with full-width row dividers.

- Source-backed table coverage is updated in all six project READMEs.
- All 128 core checks and 18 store checks passed, followed by native type-checking, offscreen header/history/table layouts, clean compilation, strict bundle checks, and project-root launch.
- The user authorized the required builds without first committing Project Control v0.6 or Observatory v1.9; source was uncommitted at delivery.

- The category-grouping update uses the existing v0.7 renderer to display a separate table per relevant architecture category across all six projects.
- It preserves every component and does not rebuild Project Control.
- Observatory advances to v2.1 to refresh its embedded README; the user explicitly permitted that build without first committing v2.0.

#### Current implementation

- The v2.4 shell lets the native window own the outside corners, uses one black chassis across the
  complete window, and places an independently tuned 18-point light-artwork detail layer three
  points above it so all four rendered curves visually align.

The chassis remains visible as the left hierarchy rail and thin black detail perimeter. Normal
  content blurs the same artwork that the lock screen shows clearly;

its lower sage halftone is repeated crisply above the active blur, while the clear lock view adds
  a denser full-frame field of dots and short matrix marks.

Reduce Transparency keeps its solid detail fallback. Lock/unlock uses an edge-to-edge opacity
  transition without shell scaling, while navigation and disclosure motion runs for approximately
  0.62–0.78 seconds and respects Reduce Motion.
- Reads the root Projects table and project READMEs, refreshing changed documents while the window
  is open; missing sources stay explicitly unavailable. In v2.2, the first Category, Technical
  scope, and Technologies items inside Professional scope drive collapsible groups, a scope line,
  and individual wrapping tags without code-based inference.

Older separate columns remain compatible and take precedence when present. Missing scope/tags are
  omitted; the former AI usage column is ignored. Metadata changes retain project identity, notes,
  and selected content, including while project details are stale.
- Combines project identity, actions, Document Health, and notes availability in one compact pre-tab
  card in v2.6. The content-sized summaries replace the progress gauge; the 1,120-point minimum
  keeps them beside the actions. The card uses a 16-point inset and 14-point row spacing, with an
  eight-point tab-to-content gap.
- Gives Overview, Architecture, Models, and Workflows their own project tabs. Each prose/bullet
  group and empty state uses a translucent surface, including text beside headings/tables.
  Standalone headings and existing tables/diagrams/history retain their own presentation.

A selectable repository parent owns root Overview, Repository history, Commit activity, and Last
  read. Commit activity renders newest years first, reads timestamps/changed paths/ref identities,
  refreshes when refs change, and shows project icon/name/count distributions on hover without
  reading commit messages or file contents. Projects appear as indented children with app icons or
  neutral symbols.
- Saves plain-text work notes locally through an inline Add note editor with Save/Cancel and
  retained edit/delete actions. Notes indicate availability only. Legacy note IDs and title/context
  text remain readable; the next explicit mutation atomically writes the new text-only format.
- Shows Nexus and repository context in the content header, makes the full hierarchy row selectable,
  and keeps navigation search-free. The reference-style brand row expands or collapses around one
  fixed 40-point icon axis, labels fade without shifting that axis, and project rows animate
  individually.

A separator divides the hierarchy from matching full-width Open README file, Repository menu, and
  Lock application rows using one fixed book, adjustment, and lock icon axis;

the menu's visible row uses the same leading layout as the plain buttons. A second separator
  introduces compact workspace/sync status and the live bundle version, aligned to the visible icon
  column rather than the rail edge.

Compact footer icons retain the navigation axis. Open App detects a valid top-level project
  application, offers ambiguous candidates, or lets the user locate a missing app; scanning never
  launches anything.
- Provides a no-password local artwork lock from the rail footer that hides the full content and
  rail, draws no black footer, and centers Unlock in the whole application. The superseded
  Vector/Lens reference remains available through Git history rather than as a stale active file.
- Retains the earlier parser, pre-read metadata, canonical-identity, queued-selection, README-path,
  fresh app-metadata, and executable-availability fixes. v0.6 adds table/identifier and parent/child
  navigation regressions, passing 71 core checks, 18 store checks, native type-checking, clean
  compilation, signed-bundle checks, and project-root launch.

Offscreen rendering checked repository/project layouts at minimum and regular sizes, model tables,
  and app/fallback icons. Live interaction remains unconfirmed; no screen-capture permission was
  retried or privacy setting changed. Runtime monitoring, arbitrary script launching, and public
  distribution are not implemented.
- Keeps the signed v2.7/build-27 `Project Control.app` directly inside its project folder after 432
  native checks, optimized packaging, strict identity checks, and live layout/interaction
  inspection. The complete current-delivery evidence and keyboard-traversal limit appear above.

The entire `Project Control/build/` folder, including every recovery bundle and generated
  test/compiler/icon intermediate, was removed on September 6 at the user's request. Only the
  current app at the project root remains; historical delivery records describe the copies retained
  at that time. Each application update advances both release and build, with minor versions from
  0–9.

- [README](README.md) — native setup, extraction rules, local data, limitations, and
  repository-local working rules.

**Evidence and delivery status**

`a6266cf`, `6402aba`, `26f4fdf`, `c323a23`, `6232bf9`

[Back to change history](#change-history)

<a id="change-20"></a>
<a id="readme-detail-15"></a>
<a id="repository-record-17"></a>

### Documentation

- **Recorded date:** 2026-08-31.

Grouped all six projects' architecture components into relevant category tables using existing native headings and tables. Preserved every source row and documented the category convention.

- The v0.7/build-7 application is unchanged; Observatory's embedded README advances separately to v2.1.
- Passed 162 core checks, 18 store checks, native type-checking, exact row/group checks, README links, native offscreen layouts, and unchanged-bundle identity/signature checks.
- Review found no actionable defects; live interaction remains unverified.

- Grouped all six projects' architecture tables by primary responsibility and documented the category convention.
- Uses the unchanged v0.7/build-7 renderer.
- Passed 162 core checks, 18 store checks, native type-checking, all 66 row/28 category checks, README links, offscreen category layouts, and unchanged-bundle identity/signature checks.
- Review found no actionable implementation defects; live interaction remains unverified.

**Evidence and delivery status**

`0a17adc`, `8cf8850`

Historical work record

[Back to change history](#change-history)

<a id="change-21"></a>
<a id="readme-detail-16"></a>
<a id="readme-detail-36"></a>
<a id="repository-record-18"></a>

### v0.7 / build 7

- **Recorded date:** 2026-08-31.

- Delivered larger title-aligned project icons, dates beside history headings, and complete architecture tables with full-width row dividers.
- Added source-backed tables to all six project READMEs and retained mixed architecture/workflow sections.

- Passed 128 core checks, 18 store checks, native type-checking, offscreen header/history/table layouts, clean compilation, strict bundle checks, and root-level launch.
- Preserved v0.6 unchanged, retired v0.5 to Trash, and removed temporary/generated artifacts.
- The user permitted building before committing v0.6; source was uncommitted at build time.
- Live interaction remains unconfirmed.

- Delivered v0.7/build 7 with larger title-aligned project icons, dates beside history titles, and
  architecture tables that retain model/RAG responsibilities with full-width row dividers.

- Added source-backed architecture coverage for all six projects and focused regressions; passed 128
  core checks, 18 store checks, native type-checking, offscreen layouts, clean compilation, strict
  bundle checks, and root-level launch.

- Preserved v0.6 unchanged, retired v0.5 to Trash, and removed temporary/generated artifacts. The
  user permitted building before committing v0.6; source was uncommitted at delivery. Live UI
  interaction remains unconfirmed.

- For v0.7, all 128 core checks and 18 isolated store checks passed, along with native type-checking.
- Added cases cover complete architecture tables across all six projects, mixed architecture/workflow headings, source ordering, and dated/undated histories;

- an empty-date separator regression found during testing was corrected.
- Offscreen native rendering checked all six project headers at minimum and regular content widths, title-line icon alignment, dated history headings, and Local Assistant's complete 15-row architecture table.

- Wrapped cells exposed uneven per-cell dividers; full-width grid dividers corrected the layout and were checked at both widths.
- These probes rendered only their own never-shown views, without capturing desktop pixels.

- A cache-free native build passed strict signature, source/bundle metadata, unchanged Nexus icon, project-root launch, and checksum-matched v0.6 recovery checks.
- Cleanup left only the required v0.6 recovery bundle under `build/`;

v0.5 was retired to Trash, though a final Trash inventory was denied by macOS and was not retried. The user explicitly permitted this build before committing v0.6.

- Live UI interaction, optional code review, and formal verification had not run at delivery; no commit was made at that point.
- The later category-grouping review and verification are recorded under v0.8 delivery evidence.

**Evidence and delivery status**

`0125869`, `70321c5`, `0a17adc`, `8cf8850`

[Back to change history](#change-history)

<a id="change-22"></a>
<a id="readme-detail-17"></a>
<a id="readme-detail-37"></a>
<a id="repository-record-19"></a>

### v0.6 / build 6

- **Recorded date:** 2026-08-30.

- Added structured native README tables, preserved model/path identifiers, preferred project icons, and a selectable repository-parent screen replacing footer content.
- Added table/navigation acceptance rules and focused regressions.

- Passed 71 core checks, 18 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/metadata/icon checks, and root-level launch.
- Preserved v0.5 unchanged, retired v0.4 to Trash, and removed temporary/generated artifacts.
- Live UI interaction remains unconfirmed; source was uncommitted at delivery.

- Delivered v0.6/build 6 with structured native README tables, literal model/path identifiers,
  project icons, and repository-parent navigation replacing footer content.

- Added table-rendering and hierarchy acceptance rules, plus focused table and selection
  regressions.

- Preserved v0.5 unchanged, retired v0.4 to Trash with matching checksums, and removed
  temporary/generated artifacts. Live UI interaction remains unconfirmed; source was uncommitted at
  delivery.

- For v0.6, all 71 core checks and 18 isolated store checks passed, as did native type-checking.
- Added regressions cover leading blank lines, adjacent prose/tables, escaped pipes, distinct source headers, literal model/path identifiers, root overview refresh, parent/child selection, and app preference for icons.

- Offscreen native rendering checked repository/project layouts at 900×660 and 1160×840, the real Local Assistant table component at both content widths, a three-column scrolling table, real app icons, and neutral fallback symbols.

- Native icon-service access required the render probe outside the agent sandbox; it rendered only its own never-shown views and captured no desktop pixels.
- A cache-free build passed strict signature checks, source/bundle metadata equality, unchanged Nexus icon checks, and launch from the project-root v0.6 bundle.

- The previous v0.5 bundle retained its signature and executable/metadata/icon checksums.
- The superseded v0.4 bundle was moved to Trash, and temporary render sources/images, test executables, compiler caches, and intermediate icons were removed.
- Live UI interaction remains unconfirmed; optional code review and formal verification have not run for this batch.

**Evidence and delivery status**

Retrospective record in `0a17adc`; implemented source committed with v0.7

Retrospective build record in `0a17adc`

[Back to change history](#change-history)

<a id="change-23"></a>
<a id="readme-detail-38"></a>
<a id="repository-record-20"></a>

### v0.5 / build 5

- **Recorded date:** 2026-08-30.

- Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh.
- Added nine core regression assertions; passed 57 core checks, 14 store checks, native type-checking, clean compilation, strict signature/metadata/icon checks, and root-level launch.
- Committed reviewed source before building, preserved v0.4 unchanged, retired v0.3 to Trash, and removed temporary/generated artifacts.
- Live UI interaction remains unconfirmed.

- Delivered v0.5/build 5 after reviewing the complete UI/content update.

- Fixed ASCII-arrow diagrams, current sections under versioned titles, cached app metadata, and
  executable-permission refresh.

- Passed 57 core checks, 14 store checks, native type-checking, clean compilation, strict
  signature/metadata/icon checks, and root-level launch; reviewed source commits preceded the build.

- Preserved v0.4 unchanged, retired v0.3 to Trash with matching checksums, and removed
  temporary/generated artifacts. Live UI interaction remains unconfirmed.

- The subsequent v0.5 review reproduced four defects using disposable fixtures: ASCII arrows inside text fences were rejected, a versioned project title incorrectly owned all current sections as history, cached bundle metadata survived executable changes, and permission-only executable changes did not trigger refresh.

- All four are fixed.
- Nine added core assertions cover these regressions plus binary/malformed/oversized metadata and executable-directory rejection.
- All 71 focused checks and native type-checking passed.

- No synthetic app was launched.
- The reviewed source was committed in separate parser, app-discovery, UI, and documentation groups before clean distributable compilation.
- Strict root-bundle signature checks, source/bundle metadata equality, unchanged Nexus icon, and project-root process launch passed;

- the preserved v0.4 bundle retains its original executable/metadata/icon checksums and valid signature.
- The superseded v0.3 bundle was moved to Trash and disposable probes, test binaries, compiler caches, and intermediate icons were removed.
- No build-rule exception was needed.
- Live UI interaction remains unconfirmed; the unchanged view layout has the earlier v0.4 offscreen evidence only.

**Evidence and delivery status**

`aa794c4`, `1f2e7ae`, `d0b9426`, `9f086e9`, `74ccd1a`

[Back to change history](#change-history)

<a id="change-24"></a>
<a id="readme-detail-18"></a>
<a id="readme-detail-39"></a>
<a id="repository-record-21"></a>

### v0.4 / build 4

- **Recorded date:** 2026-08-30.

- Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs, and native node-and-arrow diagrams with explicit branch/merge support.

- Recorded UI acceptance rules.
- Passed 48 core checks, 14 store checks, native type-checking, offscreen layout checks, clean compilation, strict signature/bundle checks, and project-root launch.
- Preserved v0.3 unchanged, moved v0.2 to Trash, and removed temporary/generated artifacts.
- Live interaction checks remain unconfirmed.

- Delivered v0.4/build 4 with the Nexus header icon, full-row sidebar navigation, automatic app
  detection with manual fallback, separate README content tabs, and connected workflow diagrams with
  explicit branches and merges.

- Recorded project-level UI acceptance rules and passed 48 core checks, 14 store checks, native
  type-checking, offscreen layout checks, clean compilation, strict signature/bundle checks, and
  project-root launch.

- Preserved v0.3 unchanged, moved v0.2 to Trash with matching checksums, and removed temporary
  test/render files and generated artifacts. Live interaction checks remain unconfirmed.

- For v0.4, all 62 focused checks and native type-checking passed, followed by a cache-free native build, strict signature and source/bundle metadata checks, unchanged Nexus icon payload, project-root launch, and checksum-matched v0.3 recovery checks.

- An offscreen `NSHostingView` rendered the real Overview and workflow components without capturing any screen; this checked layout, not live interaction.
- A test-fixture comparison was corrected to use canonical macOS paths.

- Temporary render sources/images, test executables, the failed fixture/report, compiler caches, and intermediate icons were removed.
- The v0.3 source/build work was already committed before this build began.

**Evidence and delivery status**

Retrospective record in `9f086e9`; implemented source committed with v0.5

Retrospective build record in `9f086e9`

[Back to change history](#change-history)

<a id="change-25"></a>
<a id="readme-detail-19"></a>
<a id="readme-detail-40"></a>
<a id="repository-record-22"></a>

### v0.3 / build 3

- **Recorded date:** 2026-08-30.

- Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows.
- Capture metadata before reads, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening.

- Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean compilation, strict signature checks, bundle metadata/icon checks, and project-root launch.

- Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash and removed generated artifacts.
- The user explicitly authorized building before committing v0.2.
- Native visual inspection remains unconfirmed.

- Delivered v0.3 build 3 with review fixes for code-fence boundaries, table delimiters, workflow
  colons, refresh identities, folder aliases, queued repository changes, and README open-path
  checks.

- Passed 27 core checks, 10 isolated store checks, native application type-checking, clean
  compilation, strict signatures, bundle metadata/icon checks, and project-root process launch.

- Preserved v0.2 unchanged; moved the superseded icon comparison and v0.1 bundle to Trash with
  matching checksums and removed generated artifacts.

- The user explicitly permitted building before committing v0.2; native visual inspection remains
  unconfirmed.

- For v0.3, clean native compilation, strict signature validation, source/bundle metadata equality, and project-root process launch passed.
- The packaged Nexus icon is byte-identical to the verified v0.2 icon.
- The preserved v0.2 bundle retains its valid signature and original executable, metadata, and icon checksums.
- The user explicitly permitted building v0.3 before committing v0.2.
- Generated compiler caches and intermediate icon files were removed after verification.

**Evidence and delivery status**

`07f72b4`, `1f1dfad`, `352ad0b`, `6c8dd32`

[Back to change history](#change-history)

<a id="change-26"></a>
<a id="readme-detail-20"></a>
<a id="repository-record-23"></a>

### v0.2 / build 2

- **Recorded date:** 2026-08-30.

- Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle.
- Advanced both version and build.
- Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch; preserved v0.1 with matching executable/metadata checksums.
- Native Dock/window inspection remains unconfirmed.
- The user explicitly authorized this build without committing v0.1; no commit was created.

<ul><li>Advanced to v0.2 build 2 with the selected Nexus app icon.</li><li>Added editable SVG/PNG masters and macOS-native packaging of standard/Retina icon sizes.</li><li>Passed ten-size icon-payload checks, clean native compilation, signed root-level delivery, metadata checks, and process launch.</li><li>Preserved v0.1 with unchanged executable/metadata checksums; native Dock/window inspection remains unconfirmed.</li><li>The user permitted this build without committing v0.1; no commit was created.</li></ul>

- For v0.2, focused packaging checks confirmed all ten icon sizes and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, unchanged v0.1 recovery files, and launch from the root-level v0.2 app.

- Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead.

This does not substitute for actual Dock inspection. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.

**Evidence and delivery status**

Retrospective record in `6c8dd32`; source committed with v0.3

Retrospective build record in `6c8dd32`

[Back to change history](#change-history)

<a id="change-27"></a>
<a id="readme-detail-41"></a>
<a id="repository-record-24"></a>

### Maintenance

- **Recorded date:** 2026-08-30.

- Relocated the unchanged v0.1/build-1 application beside this README.
- Configured signature-checked root-level delivery with recoverable prior bundles, and recorded the single-digit minor/version-and-build increment policy.
- Added three icon choices; selection and the next-build authorization were pending at this stage.

- Moved the unchanged v0.1/build-1 app to the project root for direct opening.

- Configured signature-checked delivery of completed builds beside the project README, preserving
  prior bundles for recovery.

- Recorded release/build increments and the 0–9 minor-version rollover policy.

- Added three original icon concepts with large and Dock-size comparisons; no icon had been selected
  and no new app build was produced at this stage.

**Evidence and delivery status**

Retrospective record in `6c8dd32`

Retrospective build record in `6c8dd32`

[Back to change history](#change-history)

<a id="change-28"></a>
<a id="readme-detail-21"></a>
<a id="readme-detail-42"></a>
<a id="repository-record-25"></a>

### v0.1 / build 1

- **Recorded date:** 2026-08-30.

- Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress, and explicit folder/README/app actions.
- Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch.

- Fixed stale metadata caching found by the refresh test.
- Retired 33 rejected design artifacts recoverably and removed their obsolete links.
- Native visual/keyboard inspection remains blocked by macOS capture permission.

- Implemented v0.1 build 1 as a native SwiftUI README-driven management center.

- Added project discovery/refresh, source introductions, architecture and explicit workflow maps,
  and separate project/repository histories.

- Added atomic work-note persistence, completed-note progress, explicit folder/README opening, and
  user-configured application launching without shell execution.

- Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks,
  and clean-built process launch; corrected stale metadata caching found during testing.

- Retired 33 rejected visual artifacts recoverably and removed their old links while preserving the
  selected sci-fi reference.

- Kept runtime health explicitly unchecked; native visual/keyboard inspection remains blocked by
  macOS capture permission.

**Evidence and delivery status**

Retrospective record in `6c8dd32`; source committed with v0.3

Retrospective build record in `6c8dd32`

[Back to change history](#change-history)

</details>
