# Project Control

![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![Release](https://img.shields.io/badge/Release-v3.7%20build%2037-brightgreen) ![Reads](https://img.shields.io/badge/Reads-Repository%20READMEs-9f9f9f)

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

**Success:** Every project folder with a README appears; its documented content opens without a README warning.

### Build from source

Requires macOS 14 or later and Xcode with its command-line tools selected. The local build targets the current Mac’s architecture.

From the repository root:

```sh
cd "Project Control"
make app
open "Project Control.app"
```

## Using Project Control

### Navigation and work notes

- **Project views:** Overview, Architecture, Models, Workflows, and Project history reflect the selected README.
- **Rail:** Click the repository's name or its icon at the top of the rail to collapse the rail to icons, and the icon again to expand it. The grey line under the name opens the repository's overview, history and commit activity.
- **Collapsed rail:** A category icon lists that category's projects beside it; choosing one opens it and keeps the rail collapsed.
- **Notes:** Use **Add note** or `Command-N` while Work notes is visible; save nonblank text with `Command-Return`, or cancel with Escape. Notes accept up to 4,000 characters; saved notes can be edited or deleted.
- **Context:** Drafts remain attached to their selected project. Category expansion and navigation do not change saved notes.
- **Lock this window:** Hides the workspace without adding password protection or changing data.

### Refresh and recovery

- **Automatic refresh:** Active views check the repository's READMEs and project folders about every two seconds. **Refresh now** — the arrow beside the version at the foot of the rail, or `Command-R` — reloads immediately. **Change repository…** in the rail footer, or `Command-O`, chooses another repository.
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
- **Boundary:** Files and apps open only on your action. This local build has no network client and is neither sandboxed nor notarized. Runtime monitoring, arbitrary script launching, and public distribution are not implemented.

<!-- project-control:section=architecture -->
## Architecture

### Frontend & Presentation

| Technology or concept | Use in this project |
|---|---|
| SwiftUI | Builds the black chassis, shared-artwork detail layer, animated hierarchy rail, artwork lock, project screens, work-note editor, History, responsive commit-activity grid, native tables, and restrained motion. ReadmeContent and RepositoryScreen render the selected source content. |
| AppKit | Provides macOS icons, application/window integration, file pickers, and explicit open actions. ProjectIcon shows each project folder's own Finder icon, with a neutral fallback. |

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
| Git metadata | Complete local reachable-commit timestamps supply monthly activity; changed paths map commits to listed projects for hover details; ref object identities trigger refresh without reading messages, authors, or file contents. |
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
├── Resources/          # Bundle identity, version, Repository Atlas master, and icon catalog
├── Tests/              # Focused synthetic and read-only repository checks
├── Makefile            # Local build, focused checks, launch
├── Project Control.app # Latest completed app; ignored by Git
└── build/              # Staging, caches, recovery copies; ignored by Git
```

<!-- project-control:section=workflows -->
## Workflow and data sources

```text
README change
README saved
  ↓
background content check
  ↓
mapped section parsing
  ↓
native screen update

Project register
Projects table and top-level project folders
  ↓
project READMEs
  ↓
project navigation and content

Commit activity
Local Git refs
  ↓
timestamps plus project-folder paths
  ↓
monthly totals and hover distributions

Work notes
Local work notes
  ↓
notes available / no notes summary
```

<!-- project-control:section=ignore -->
## README content contract for Project Control

- Repository and project READMEs are the content baseline.
- Project Control reads selected sections locally; it never executes README instructions, scans source code, or uses a model to invent missing facts.
- This section is the single authoring contract for all current and future projects.
- It is referenced by the repository instructions and applies to README inputs, not sibling applications' UI or runtime behavior.

### Add a new project to Project Control

- A folder directly inside the repository root that holds a `README.md` appears on its own, after the registered projects, under **Uncategorized**; its card notes that it is not in the root register.
- Project Control lists only those top-level folders. It never scans nested or hidden folders, and it lists a folder link only when the register names it.
- Registered projects come first, in the order of the root README's **Projects** table, with their category, technical scope and technology tags; unregistered folders follow in name order, named after the folder.
- Complete every step below so the project appears under its category and every detail tab fills.

1. **Create one top-level project folder.** Put it directly inside the repository root, beside the
   existing project folders. For example, create `Example Project/`, not
   `Some Collection/Example Project/`. Keep the project inside this repository; a symlink to a
   folder outside the repository is rejected.
2. **Create the project's README.** Add `Example Project/README.md` as a regular UTF-8 file smaller
   than 2 MB. Start with a plain-language overview, then document the architecture, optional models,
   workflows, and history that the app should show. Choose the project's change-history mode — project
   version and build, version-only component, or dated history — and place the required linked
   declaration beside its current-release or history section.
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
   contains spaces, encode each space as `%20` in the link. Open the Professional scope cell with
   the latest update date, add a public-repository link when the project has a public mirror, then
   Category, Technical scope and Technologies, followed by the useful project summary.

   ```markdown
   | [Example Project](Example%20Project/) | <ul><li><strong>Latest update:</strong> 2026-09-04</li><li><strong>Category:</strong> Project Management</li><li><strong>Technical scope:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; SQLite</li><li><strong>Product:</strong> A concise factual summary.</li></ul> |
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

- If the project stays under **Uncategorized** with the unregistered note, check that its row is directly inside the selected Projects table, the link resolves to exactly that top-level folder, and the folder and README names match letter-for-letter. If a tab stays empty, check that every section marker immediately precedes a heading.
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

- The project card shows the `release` section's version. A version written in bold after a component name, such as `**Observatory v2.7**`, keeps that name, so a component's number is never shown as the whole project's. Without one, the card shows **Dated history** when the numbering declaration beside the release or history section says the project uses dated history, and **Release not specified** otherwise.

In a README containing markers, only marked sections and their descendants are selected. A section ends at the next heading of the same or a higher level.

A child's explicit marker can select a different destination, except inside `ignore` or `history`: those subtrees remain excluded or historical. Unmarked sibling sections stay README-only.

- Multiple sections may target one destination and retain source order.
- Keep markers when renaming or moving headings; do not insert prose between a marker and its heading.
- Unknown identifiers, malformed markers, consecutive markers without headings, and orphan markers are errors.
- Marker-like examples inside fenced code blocks are inert, not configuration.

- The Projects register reads tables directly under its selected heading, not unrelated tables inside descriptive subsections.
- Keep extended project descriptions in the owning project README; the root Projects table contains concise introductions and links in each Professional scope cell.

- The register has two columns: the project folder link and the Professional scope description. The app reads a labelled item wherever it appears in that cell, so the order below is for readers, not for parsing.
- A row whose first-column link points at another repository — a fork or any work kept outside this one — is skipped rather than displayed, because there is no folder here to read; such rows belong in the root README's **Forked projects** section, which is marked `ignore`. A relative link that escapes the repository is still refused as unsafe.
- Every Professional scope cell opens with **Latest update**, then **Public repository** for a project with a public mirror, and carries these three labelled items:

```html
<ul><li><strong>Category:</strong> Project Management</li><li><strong>Technical scope:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; README-driven</li><li><strong>Product:</strong> Project-specific summary.</li></ul>
```

- Project Control reads the labels case-insensitively, removes presentation markup, and leaves later project-specific bullets available as the professional summary.
- Categories and their projects retain first-appearance/source order.

- Missing or blank Category values use **Uncategorized**; a missing or blank Technical scope is omitted from the sidebar row, and missing or blank Technologies from the project card.
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

- Follow the [tag rules](CONTRIBUTING.md#presentation-rules) when choosing factual technologies/approaches; they apply to this app's presentation only.
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
- Write every workflow diagram in one style, in a fenced `text` block inside a mapped workflow
  section. The renderer shows documented branches and merges, never invented connections or
  executable code.

  ````markdown
  ```text
  Route title
  First step
    ↓
  Next step
    ├─→ One branch
    └─→ Another branch
    ↓
  Step where the branches meet

  Next route title
  First step
    ↓
  Last step
  ```
  ````

  - Start each route with a short title line, then its first step on the next line.
  - Join steps with a `↓` line. List branches from the step above with `├─→`, the last one with
    `└─→`, all at one indent; a `↓` after them merges the branches into the next step.
  - Separate routes with a blank line; one block may hold several.
  - Write steps in plain language. Parentheses, commas, and semicolons are fine; code, commands,
    links, and backticks are not, and a route containing them stays in the README only.
  - Put notes and exceptions in prose outside the block.
  - Up to sixteen routes per project are shown, each with up to 32 steps. Older one-line routes
    (`A → B → C`) still display, but new and edited routes use this style.
- Put setup commands, operating instructions, and detailed maintenance outside mapped sections, or
  mark their subtree `ignore`. Read README remains the route to the complete document.

### Update and recovery behavior

- While the app view is active, background checks run approximately every two seconds over the root README, every listed project README, the list of top-level folders, and app metadata.
- Bounded content digests detect edits even when file size and timestamps are unchanged.

- A successful root register edit regroups sidebar projects; adding or removing a top-level folder with a README adds or removes its project.
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

**v3.7 (build 37)** in source and in the signed local app. [Change and delivery evidence](#v3-7-build-37).

<!-- project-control:section=ignore -->
## Contributing

For source changes, follow the [contribution guide](CONTRIBUTING.md).

<!-- project-control:section=history -->
## Change history

**Change-history numbering:** This project uses marketing versions and integer build numbers.
Follow the [version and build policy](CONTRIBUTING.md#version-and-build-policy).

One record per change; complete details and evidence are below. Older work dates and Git checkpoints remain labelled when they differ.

**Historical status:** Each record describes its own delivery checkpoint. Later records supersede older pending work or recovery locations; historical checks are not new validation.

| Record | Date | Highlights | Details |
|---|---|---|---|
| v3.7 / build 37 | 2026-09-24 | <ul><li><strong>Tests:</strong> The store and notes checks keep their preferences inside their own temporary folder, so a run no longer leaves an empty preferences file behind.</li></ul> | [Full record](#v3-7-build-37) |
| v3.6 / build 36 | 2026-09-24 | <ul><li><strong>Projects:</strong> Every top-level folder with a README appears, registered or not.</li><li><strong>Rail:</strong> The repository's name and icon collapse and expand the rail; the brand moves to the foot with the version; a collapsed category lists its projects.</li><li><strong>Project card:</strong> One layout for every project: the actions sit on the name's row and the summaries fill one full-width strip.</li></ul> | [Full record](#v3-6-build-36) |
| v3.5 / build 35 | 2026-09-23 | <ul><li><strong>Workflows:</strong> One diagram style: titled routes of steps joined by ↓, with branches and merges, several routes per block.</li><li><strong>Parsing:</strong> Parentheses and semicolons in a step read as prose, and up to sixteen routes show instead of eight.</li></ul> | [Full record](#one-workflow-style) |
| v3.4 / build 34 | 2026-09-23 | <ul><li><strong>Rail:</strong> The Project Control name is a fixed label; the collapse control moved to the end of the repository row, which stays pinned while the projects scroll.</li><li><strong>Project card:</strong> Document Health and Notes sit beside the project name and the version shares a line with the tags, so the card has no empty half.</li><li><strong>Fix:</strong> A workflow diagram with a wrapped node no longer pushes its last node onto the card's edge, and a branch's connectors meet at one height.</li></ul> | [Full record](#rail-toggle-and-project-card) |
| v3.3 / build 33 | 2026-09-23 | <ul><li><strong>Rail:</strong> Categories are quiet section headers and each project row is one line, so more of the register fits before scrolling.</li><li><strong>Footer:</strong> Repository README, Change repository…, and Lock are plain buttons; the Repository menu is gone, and Refresh now sits on the status line.</li><li><strong>Detail:</strong> Technology tags moved to the project card, and the header strip repeating the Project Control name was removed.</li></ul> | [Full record](#navigation-rail-layout) |
| v3.2 / build 32 | 2026-09-23 | <ul><li><strong>Icons:</strong> Every project row, project header, and activity hover shows the project folder's own Finder icon instead of an app's icon, so projects without an app no longer show a generic symbol.</li><li><strong>Identity:</strong> A missing folder, or an alias that no longer points at the project, still shows the neutral symbol.</li><li><strong>Checks:</strong> The live checks follow the root register, so the full test suite runs again.</li></ul> | [Full record](#folder-icons) |
| v3.1 / build 31 | 2026-09-21 | <ul><li><strong>Identity:</strong> Repository Atlas shows the root README branching to its projects, with one selected project, a work note, and Git activity.</li><li><strong>Packaging:</strong> The build now compiles the checked-in macOS asset catalog with Apple's asset tool.</li></ul> | [Full record](#repository-atlas-icon) |
| Documentation | 2026-09-13 | <ul><li><strong>License:</strong> Added the approved Soucieux proprietary-software notice.</li></ul> | [Full record](#soucieux-proprietary-license) |
| v3.0 / build 30 | 2026-09-12 | <ul><li><strong>Register:</strong> A row linking to another repository is skipped instead of making the whole register unreadable.</li></ul> | [Full record](#external-register-rows) |
| v2.9 / build 29 | 2026-09-12 | <ul><li><strong>Delivery:</strong> The promotion step deletes the set-aside bundle once the new app is in place, so a build no longer leaves an older release behind.</li></ul> | [Full record](#single-delivered-bundle) |
| Documentation | 2026-09-12 | <ul><li><strong>Contributing:</strong> Added a standalone project guide so the source carries its own contribution and numbering rules.</li><li><strong>Links:</strong> Removed the README's dependencies on parent-only repository files.</li></ul> | [Full record](#standalone-contributor-guide) |
| v2.8 / build 28 | 2026-09-11 | <ul><li><strong>Source:</strong> Restored the header icon's alignment with the project name, removed per-render bundle reads and repeated measurement from the interface layer, named the documented parsing limits, and removed unused code.</li><li><strong>Documentation:</strong> Each change-history record now states its change once, and unused link anchors were removed.</li></ul> | [Full record](#v2-8-build-28) |
| Documentation | 2026-09-06 | <ul><li><strong>Structure:</strong> User guide first; one history table.</li><li><strong>Rules:</strong> Scoped contributor guidance under AGENTS.</li></ul> | [Full record](#readme-organization) |
| Maintenance | 2026-09-06 | <ul><li><strong>Change:</strong> Reorganized long paragraphs and table cells without dropping details.</li></ul> | [Full record](#change-1) |
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

<details>
<summary>Full records for this table</summary>

<a id="v3-7-build-37"></a>

### v3.7 / build 37

- **Recorded date:** 2026-09-24.
- **Test preferences:** `make test-store` and `make test-notes` name their preferences by a path
  inside the temporary folder each run deletes, rather than by a name macOS keeps in the user's
  Preferences folder. A named suite left an empty preferences file there after every run, even
  once its settings were cleared.
- **Scope:** Tests and version only; the app behaves as v3.6 did.

**Evidence and delivery status**

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks, and six seconds
after the run no `ProjectControlTests-` preferences file or temporary folder remained. A probe
showed a plain suite name leaving its file behind, even when the file was deleted right after a
forced flush, since macOS wrote it again later; a path inside the run's folder left nothing. `make app` passed and promoted the signed v3.7/build 37 app to the project
root; the bundle passed strict signature verification and reports version 3.7 and build 37.
Initially delivered uncommitted, then committed in `c8d471c` and followed by this record;
publication was not requested.

[Back to change history](#change-history)

<a id="v3-6-build-36"></a>

### v3.6 / build 36

- **Recorded date:** 2026-09-24.
- **Every project folder:** A folder directly inside the repository that holds a `README.md` now
  appears without a register row. Registered projects keep their order, category and tags;
  unregistered folders follow under **Uncategorized**, named after the folder, and their card says
  the root register does not list them. Hidden folders, folders without a README, and folder links
  the register does not name stay out, and a new folder appears within the two-second refresh.
- **Rail toggle:** Clicking the repository's name or its icon collapses or expands the rail, and the
  separate toggle icon is gone. The grey line under the name still opens the repository's overview,
  history and commit activity.
- **Brand:** The Project Control icon and name move from the top of the rail to its foot, below the
  footer buttons, with the version and refresh cadence under the name and **Refresh now** beside
  them, so the brand no longer reads as a navigation row. In the collapsed rail its icon stays on the
  icon column.
- **Collapsed categories:** A category icon in the collapsed rail opens a list of that category's
  projects; choosing one opens it and keeps the rail collapsed, instead of jumping to the first
  project.
- **Project card:** Every project's card has the same layout. The actions sit on the name's row,
  where a long name wraps rather than moving them, and the version and tags run beneath the name
  across the card's full width. Below a divider, Document Health, Notes, and App share one
  full-width strip of equal columns, so the card has no empty region at any width.
- **Footer:** **Lock** is renamed **Lock this window**, matching the other footer labels in length.
- **Release label:** A component's version keeps its name — Knowledge Transfer shows
  **Observatory v2.7**, not v2.7 — and a project that declares dated history shows **Dated
  history** instead of **Release not specified**.

**Evidence and delivery status**

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks. New core checks
cover unregistered folders listed after the register in name order with their README content,
hidden folders, folders without a README and folder links left out, an unchanged repository keeping
its fingerprint, a new folder or a new README noticed on the next check, a component's release
name, and a dated-history declaration read only beside the release or history section. The live
checks now require every top-level folder with a README to be listed and every listed project to
supply workflows and history. `make app` passed and promoted the signed v3.6/build 36 app to the
project root; the bundle passed strict signature verification and reports version 3.6 and build 36.
Offscreen renders against the live repository at 1,440 × 900 and at the 1,120 × 720 minimum showed
one header layout for every project — DayWright's six tags included — with a long name wrapping
at the minimum width, the full-width summary strip, and the brand at the foot of the rail in both
rail states; a disposable repository showed an unregistered folder under Uncategorized with its
note. A collapsed category's list, opened by a
click and captured from its own popover window, reads in system label colors in light and dark
appearance and opens at the icon's edge.
Mouse clicks sent to the rail in an offscreen window collapsed it from the name, expanded it from
the icon, opened the repository screen from the summary line, and opened a collapsed category's
list without changing the selection; choosing a project there opened it with the rail still
collapsed. Initially delivered uncommitted, then committed in `f04b15b` through `a44cd88`, with this
record in `fb893ca`; publication was not requested.

[Back to change history](#change-history)

<a id="one-workflow-style"></a>

### v3.5 / build 35

- **Recorded date:** 2026-09-23.
- **One style:** The README contract now defines a single way to write a workflow diagram: a fenced
  `text` block of routes separated by blank lines, each a title line followed by steps joined by
  `↓`, with `├─→` and `└─→` branches and a `↓` merge. This README's own workflow section uses it.
- **Titles:** A route's first line names its diagram, so a block of several routes shows each under
  its own title instead of repeating the section heading.
- **Prose, not code:** A step may contain parentheses, commas, and semicolons. Braces, backticks,
  angle brackets, or a word directly followed by `(` still mark a route as code, which stays in the
  README; a code-like route no longer hides the other routes in its block.
- **Limit:** Up to sixteen routes per project are shown instead of eight.
- **Compatibility:** Single-line `A → B → C` routes and untitled stacked diagrams still display.

**Evidence and delivery status**

`make test` passed: 354 core, 40 store, 47 note/presentation, and 12 version checks. Three new core
checks cover titled routes sharing a block, parentheses and semicolons read as prose, and a ten-route
block shown in full; each fails against the v3.4 parser. `make app` passed and promoted the signed
v3.5/build 35 app to the project root; the bundle passed strict signature verification and reports
version 3.5 and build 35. Offscreen renders against the live register showed 28 titled routes across
seven projects, including DayWright's and Knowledge Transfer's, which v3.4 could not draw. Initially
delivered uncommitted, then committed in `5cd854f`.

[Back to change history](#change-history)

<a id="rail-toggle-and-project-card"></a>

### v3.4 / build 34

- **Recorded date:** 2026-09-23.
- **Rail:** The Project Control icon and name at the top of the rail are a fixed label rather than a
  button. The collapse control moved to the end of the repository row, and that row now stays
  pinned above the scrolling categories, so the control is always in reach. In the collapsed rail
  the row shows only the control, on the same icon axis, so the rail can always be expanded again.
- **Project card:** The card has two columns. On the left are the icon and name, then the version
  and technology tags on one line, then Open folder, Read README, and Open App. On the right,
  Document Health and Notes sit level with the name instead of beside the buttons, so the card's
  top-right half is no longer empty and the card is two rows shorter.
- **Fix:** A workflow diagram measured each node as if its label fit on one line, while the label
  wrapped when drawn. A diagram with a wrapped node therefore came out one text line short, and its
  last node sat on the card's bottom edge — Local Assistant's *How local RAG works* and two Career
  Ledger diagrams. Each label is now measured at the width it draws at. In the same diagrams a
  branch's connectors bent at different heights when its nodes differed in height; they now bend at
  one shared height between the rows.
- **Scope:** No README parsing, selection, notes, activity, storage, or launching behavior changed.

**Evidence and delivery status**

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks. `make app`
passed and promoted the signed v3.4/build 34 app to the project root; the bundle passed strict
signature verification and reports version 3.4 and build 34. Offscreen renders of the real views
against the live register showed the fixed brand label and the repository-row toggle in both rail
states; the two-column card for Local Assistant at the default size and for DayWright and Python
Accomplishments at the 1,120 × 620 minimum; and every project's Workflows tab, where the Local
Assistant and Career Ledger diagrams that had lost their bottom padding keep it and Prospect
Copilot's five-line nodes fit. Initially delivered uncommitted, then committed in `987e9a0`,
`f939ab9` and `9d8c5ac`, with this record in `deda6fe`.

[Back to change history](#change-history)

<a id="navigation-rail-layout"></a>

### v3.3 / build 33

- **Recorded date:** 2026-09-23.
- **Rail:** Categories are quiet section headers — a disclosure chevron, the category name, and its
  project count — instead of rows with their own icons, so the projects are what stands out. Each
  project row shows its icon, name, note marker, and technical scope. At the default window size the
  rail now reaches the third category before scrolling, where it previously showed only the first.
  The collapsed rail keeps its category markers on the same icon axis.
- **Tags:** A project's technology tags moved from its rail row to its detail card, under the
  version. Every tag the root register documents still appears.
- **Footer:** Three plain buttons say what they do: **Repository README**, **Change repository…**,
  and **Lock**. The Repository menu, which looked like a button but opened a two-item menu, is gone.
  **Refresh now** is the arrow at the end of the status line, which reads *Auto-refresh every 2 s*
  and the running version. `Command-O` and `Command-R` work as before.
- **Detail:** The header strip above every screen, which repeated the Project Control icon and name
  and the repository name, is removed. The brand appears once, at the top of the rail, and the
  repository once, as the rail's first row.
- **Scope:** No README parsing, selection, notes, activity, storage, or launching behavior changed.

**Evidence and delivery status**

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks. `make app`
passed and promoted the signed v3.3/build 33 app to the project root; the bundle passed strict
signature verification, reports version 3.3 and build 33, and opened its window. Offscreen renders of
the real `ControlWindow` against the live register showed the expanded rail on a project and on the
repository screen, the collapsed rail, and the 1,120 × 620 minimum window, where every category
header stays on one line and the project card's tags fit in one row. Initially delivered
uncommitted, then committed in `d220b09`.

[Back to change history](#change-history)

<a id="folder-icons"></a>

### v3.2 / build 32

- **Recorded date:** 2026-09-23.
- **Icons:** `ProjectIcon` shows each project folder's own Finder icon in the sidebar row, the
  project header, and the commit-activity hover. Previously a project showed artwork only when it
  had a project-root app, and that artwork was the app's icon; the other five projects showed a
  neutral symbol. Every registered project now shows its own folder icon.
- **Identity:** The folder icon appears only while the folder is available and still resolves to
  the identity captured with the snapshot; otherwise the neutral symbol remains.
  `ProjectRecord.hasCurrentIdentity` holds that check, and the app rechecks share it.
- **Checks:** The live-repository checks now read the project names, categories, and technologies
  from the root register itself instead of a six-project copy of it, so adding a project no longer
  stops `make test`. The setup guide's success line no longer counts projects either.
- **Scope:** Open App still discovers and prefers project-root apps as before. No README parsing,
  navigation, notes, activity, storage, or launching behavior changed.

**Evidence and delivery status**

`make app` passed and promoted the signed v3.2/build 32 app to the project root; the bundle passed
strict signature verification and reports version 3.2 and build 32. The later test-only change
leaves every app source unchanged, so that bundle still matches. An offscreen render of the real
`ProjectIcon` against the live register showed all eight projects with their folder icons. The
complete `make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.
Publication was not requested.

[Back to change history](#change-history)

<a id="repository-atlas-icon"></a>

### v3.1 / build 31

- **Recorded date:** 2026-09-21.
- **Identity:** Repository Atlas replaces the generic Nexus mark. Its root document branches to
  project folders; one selected project carries a work note, and the activity grid below represents
  the local Git history Project Control displays.
- **Source:** `Resources/ProjectControl.png` is the canonical transparent 1024-pixel master. The
  checked-in asset catalog carries every standard and Retina representation from 16 through 1024
  pixels. The obsolete Nexus SVG was removed so it cannot be mistaken for the editable source of
  the selected raster artwork.
- **Packaging:** `make icons` now compiles that catalog with Apple's asset-catalog tool. The previous
  `iconutil` route rejects even an icon set extracted from the previously shipped app on the current
  macOS toolchain.
- **Scope:** No README parsing, navigation, notes, activity, storage, or opening behavior changed.

**Evidence and delivery status**

`make app` passed, promoted the signed v3.1/build 31 app to the project root, and the bundle passed
strict signature verification. Its packaged 256-pixel icon representation matches the catalog
pixels. The 40 store checks and 12 version checks passed. The complete `make test` target remains
blocked by pre-existing live-document assertions that still expect the older six-project register
and earlier prose grouping while the current workspace carries unrelated documentation changes.
Publication was not requested.

[Back to change history](#change-history)

<a id="soucieux-proprietary-license"></a>

### Documentation

- **Recorded date:** 2026-09-13.
- Added the approved Soucieux proprietary-software notice, reserving rights in original project
  materials while retaining third-party license terms.
- Documentation only; application behavior, v3.0/build 30 source, the signed local app, deployment,
  and publication status are unchanged.

[Back to change history](#change-history)

<a id="external-register-rows"></a>

### v3.0 / build 30

- **Recorded date:** 2026-09-12.
- **Register:** the root register gained a second table for work carried on top of someone else's project, whose first column links to a public repository rather than a folder here. Every row in the Projects section is read as a register row, and a row whose link is not a direct child folder was refused as unsafe — which made the entire repository unreadable, not just that row. A row whose link carries a URL scheme is now skipped: there is no folder here to open, so it is documentation rather than a project the app can show. A relative link that escapes the repository is still refused, and that protection keeps its check.
- **Scope:** one guard in `RepositoryReader` and one pattern in `ControlConstants`. No interface, storage, or history behavior changed.
- **Checks:** `make check-version` accepts the v3.0/build 30 pair; 434 native checks passed (341 core, 40 store, 41 note/presentation, 12 version), two of them new — an external row is skipped while the folder-based rows around it still load, and an escaping relative link is still refused. The live register, which now carries the forked-project table, parses again; before the fix its read threw and the smoke check failed.

**Evidence and delivery status**

v3.0/build 30 source; `make app` rebuilt and promoted the bundle to the project root, where it reports v3.0 build 30 with a valid strict signature and left no bundle behind; the promoted app launched and quit cleanly; staging removed. Initially delivered uncommitted.

[Back to change history](#change-history)

<a id="single-delivered-bundle"></a>

### v2.9 / build 29

- **Recorded date:** 2026-09-12.
- **Promotion:** `make app` moved the installed app into a `build/previous.*` folder before putting the new one in place, and left it there for good. Every release since v0.2 therefore accumulated a copy of the one it replaced. The step is still transactional — the existing app is set aside and put back if the move fails — but the set-aside copy is now deleted as soon as the new bundle is in place. The project keeps one delivered bundle; an earlier version is rebuilt from its commit.
- **Scope:** the build recipe only. No application source changed, so the interface, parsing, storage and launch behavior are those of v2.8.
- **Documentation:** the README, the contributor guide and the scoped instructions no longer describe retained recoveries, and the records that named a `build/previous.*` path as recoverable no longer claim one exists.

**Evidence and delivery status**

v2.9/build 29 source; `make check-version` accepts the pair; 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version); `make app` rebuilt and promoted the bundle to the project root, where it reports v2.9 build 29, carries a valid strict signature and an arm64 executable, and left no `build/previous.*` folder behind — the behaviour this release changes. The promoted app launched and quit cleanly. Disposable staging was removed afterwards. Initially delivered uncommitted and recorded in `75c1cf2`.

[Back to change history](#change-history)

<a id="standalone-contributor-guide"></a>

### Documentation — 2026-09-12

- **Guide:** `CONTRIBUTING.md` now carries the project-facing rules that used to live only in the private repository instructions: what the app may read and do, the presentation rules for tags and the glass direction, the checks a change must pass, and the version and build policy. The private scoped instructions remain authoritative for repository-wide workflow and automation.
- **Links:** the README's four links into the parent `AGENTS.md` now point at that guide or state the rule directly, so every link resolves from the project folder alone. The one remaining parent path sits inside a fenced example of a registered project's README, where Markdown renders it as literal text rather than a link.
- **Numbering:** the change-history declaration links to the guide's own policy section, matching the two projects already exported this way. The policy itself is unchanged: `v<major>.<minor>`, build `major x 10 + minor`, both advancing for every change except a documentation-only one.
- **Status:** Documentation only. Source, the signed v2.8 build 28 application, and its delivery state are unchanged, and no version or build advances for this change.

[Back to change history](#change-history)

<a id="v2-8-build-28"></a>

### v2.8 / build 28

- **Recorded date:** 2026-09-11; work began 2026-09-10.

- **Scope:** Exhaustive pass over every file under `Project Control/`, requested as a full sweep.

- **Interface:** Project icons and the project screen no longer read and parse bundle metadata on
  every view update. `ApplicationLocator` now separates the canonical identity recheck from the
  bounded `Info.plist` read, so icon lookup keeps its documented identity check without the file
  read; the project screen resolves its launch target once per update instead of three times.
  The project header again centers its icon on the project-name line, with the version beneath the
  name, restoring the v0.7 alignment that the v2.5 header merge had moved onto the combined
  name-and-version stack.
- **Layout and drawing:** The technology-tag layout reuses one measured arrangement per width, the
  workflow parser builds each linear route once, and the halftone artwork computes its per-column
  wave once per column.
- **Clarity:** The repository-open action no longer performs its side effect inside a guard
  condition, and the workflow preference key holds its default immutably.
- **Constants:** The documented eight-route and thirty-entry parsing limits and the two raw Git
  output bytes now have names; the work-note limit message derives its number from the limit itself.
- **Documentation comments:** 61 callables across the sources and tests now use the nested Swift
  parameter list rather than a single flattened line.
- **Unused code:** Removed `CommitActivityCalculator.summarize(_ timestamps:calendar:)`, which only the
  tests called; the core tests now build their timestamp records directly. The never-referenced
  `technicalScope` and `expandSidebarIcon` constants were also removed.
- **Version checks:** `Tests/VersionChecks.sh` reports the number of cases it actually ran. The
  expectation stays the function's last statement so a wrong result still stops the run.
- **Change history:** Each record now states its change once. Repeated restatements were merged into
  one list, v2.7 delivery text was removed from the v2.6 record, and fifteen duplicated evidence
  blocks were merged. The v2.6, v2.1 and v0.8 records had retold other releases; they now keep only
  their own work, and details found only in a retelling moved to the record they describe. The
  out-of-date "Current implementation" snapshot inside the v0.8 record was removed; its facts remain
  in the release records and this guide. Every distinct fact, figure, Git reference, date and
  delivery status was retained.
- **Links:** The Project Control tag-policy link now resolves to the repository instructions instead
  of an empty legacy anchor. Removed 95 link anchors that nothing pointed to, including eight left
  behind when their sections moved to the contributor instructions. The development-checks anchor
  now leads to the change history.

- **Status:** Source advances to v2.8/build 28 because this batch changes application source. It was
  initially delivered uncommitted, then committed and landed on `main` on 2026-09-11. The signed local
  app was rebuilt from `main` at v2.8/build 28, replacing the v2.7/build-27 app. The project keeps
  one delivered bundle; an earlier build is rebuilt from its commit rather than retained.

**Evidence and delivery status**

v2.8/build 28 source; 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version); a v2.8/build-28 bundle built from the final source in an isolated worktree passed strict signing, exact source-metadata, arm64 and ten-size icon checks and was then removed with its build folder; offscreen renders of all six project headers, with real and fallback icons and wrapped names, confirmed that the icon centers on the project name; source commits `de37545`, `878d273`, `4f80801`, `96879e6`, `fecbb6a`, `f5d0219`, `cfe44ab`, `1e377a5`, `0c3836a`; the signed v2.8/build-28 app built from `main` passed strict signing, exact source-metadata, arm64, ten-size icon and project-root launch checks; initially delivered uncommitted

[Back to change history](#change-history)

<a id="readme-organization"></a>

### README organization — 2026-09-06

- **Structure:** Put purpose, capabilities, setup, architecture, and workflows before history.
- **History:** Merge matching repository-origin records into the owning change; preserve unique detail, evidence, and older links.
- **Ownership:** Keep user documentation here; route scoped contributor rules through root AGENTS.
- **Status:** Documentation changes only; initially delivered uncommitted and recorded in `07fa894`. Existing application versions, artifacts, and deployment state are unchanged.

[Back to change history](#change-history)

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

Local documentation update; initially delivered uncommitted and recorded in `07fa894`

[Back to change history](#change-history)

<a id="change-3"></a>

### Maintenance

- **Recorded date:** 2026-09-06.

- Explicitly authorized cleanup removed the entire `build/` folder and stale Finder metadata: 231 obsolete generated files (179.7 MB), including compiler caches, test executables, icon intermediates, eleven older-version recovery bundles, and one superseded v2.7 candidate.

- Preserved the exact signed v2.7/build-27 app at the project root, source, editable icon masters, and audit evidence; no build-folder recovery remains.
- SVG references, PNG decoding, all ten packaged icon sizes, and source/packaged artwork inspection passed.
- Updated both current recovery records while preserving historical delivery evidence.
- No application code, version, build, or behavior changed.

**Evidence and delivery status**

User-authorized complete build-folder cleanup; package and asset checks passed; this documentation checkpoint; initially delivered uncommitted

[Back to change history](#change-history)

<a id="change-4"></a>

### v2.7 / build 27

- **Recorded date:** 2026-09-05.

- Exhaustive-pass source v2.7/build 27. At delivery, the source and signed local app were **v2.7 (build 27)**; the audit source corrections are committed locally, and source and documentation were uncommitted at initial delivery.

- Sidebar rows again show README-derived technology tags and notes availability.
- Collapsed navigation has accessible names and category counts.
- Activity cells support native button activation, describe all five intensity thresholds, use correct singular/plural count labels, and refresh future-month visibility each minute.
- Workflow nodes fit their content, narrow diagrams are centered, and parser guidance no longer appears as a route.

- Git activity preserves unusual filename bytes and attributes merge changes against the first parent.
- Lazy fetching and transports are disabled.
- Register tables retain their own headers and blank-column precedence.
- Automatic app discovery rechecks the project boundary, duplicate note identities preserve storage and disable editing, and version validation avoids integer overflow.
- Native regressions, callable documentation, and private implementation boundaries were strengthened.

- The documented native tests passed 339 core, 40 store, 41 note/presentation, and 12 version checks (432 in all). The final optimized app compiled, passed strict signing and exact source-metadata/icon checks, and launched from the project root.
- Live inspection confirmed wrapping tags at the minimum width, named collapsed navigation, centered workflows, horizontal access to all four branches in a disposable wide-graph fixture, activity distributions and threshold descriptions, and empty/multiline note-editor states with Escape cancellation. The test draft was not saved and the original repository selection was restored. Native button accessibility activation passed; Tab focus traversal was not confirmed under the current macOS keyboard settings.
- The user subsequently authorized removal of all build-folder outputs, including the previously preserved v2.6/build-26 recovery. The signed v2.7 app at the project root retains its exact audited bytes and valid strict signature, and no build-folder recovery remains; the older binaries were deleted locally, and generated intermediates can be rebuilt. Source code, editable icon masters, and audit evidence were preserved.
- Supplemental checks validated the SVG references, PNG decoding, and all ten packaged icon sizes; the source and packaged artwork were also visually inspected. Historical delivery notes below retain their original evidence.

**Evidence and delivery status**

Source `f8a858a`, `9590feb`, `561878c`, `cf12d65`, `b6ada81`, `81f0824`, `17184b5`, `468e2a0`, `311c87b`, `3bfa43d`; initially delivered uncommitted; 432 native checks and optimized packaging passed; signed project-root app; live checks and their limits recorded above and in Project details

[Back to change history](#change-history)

<a id="change-5"></a>

### Maintenance

- **Recorded date:** 2026-09-04.

- Removed the three superseded v2.6/build-26 candidate recoveries from `build/previous.FdBli0`, `build/previous.GtF7qQ`, and `build/previous.uqRg60`.
- At that time, the signed v2.6/build-26 project-root app and ten distinct-version recovery bundles were retained; every build-folder recovery was subsequently removed on September 6.
- Added the root README's exact new-project registration procedure.
- No application source, version, build, or behavior changed.

**Evidence and delivery status**

Local cleanup; registration guide `ceb01aeb`; this history reconciliation

[Back to change history](#change-history)

<a id="change-6"></a>

### Maintenance

- **Recorded date:** 2026-09-03.

- Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout, and removed the top-slide transition from project rows.

- Existing category/footer icons retain their leading axis and animate from their current layout; new project rows fade in.
- Sidebar destinations, category disclosure, final expanded/collapsed contents, and Reduce Motion behavior are unchanged.

- The optimized build, strict package checks, minimum-width header, and collapsed sidebar inspection passed.
- Formal verification repeated complete compilation and strict packaging.
- The Mac locked before the corrected expansion path and remaining editor interactions could be checked.

**Evidence and delivery status**

Source `330cb4b`; project record `265e76c`; signed project-root app; live expansion/editor checks pending

[Back to change history](#change-history)

<a id="change-7"></a>

### Maintenance

- **Recorded date:** 2026-09-03.

Raised the minimum window width from 980 to 1,120 points and removed the header's stacked action/status layout after the user identified it during live delivery checks.

- Document Health and Notes stay beside the buttons; the app-detection caption can wrap.
- Review found no production issue, centralized the minimum-window value, and corrected a malformed-note fixture that could pass for the wrong reason.
- Verification passed 20 affected core and five affected store checks in addition to the note and numbering checks, complete compilation, a cache-free optimized rebuild, strict signing, exact metadata, and arm64/icon checks.
- Live checks confirmed the minimum width and single-row header before the final equivalent build.

**Evidence and delivery status**

Source `e44c740`; project record `265e76c`; signed project-root app; expansion/editor recheck pending

[Back to change history](#change-history)

<a id="change-8"></a>

### v2.6 / build 26

- **Recorded date:** 2026-09-02.

- Replaced the 112-point notes progress ring with a content-sized **Notes available / No notes** summary beside Document Health; the header shows no progress or note counters.
- Tightened the project header: identity uses a 48-point icon and 32-point name, the card has a 16-point outer inset, and the tab-to-content gap is eight points.
- A 1,120-point minimum window width, raised during the pending delivery checks on September 3, keeps actions, Document Health, and Notes in one horizontal row with the sidebar expanded; app-detection captions can wrap without moving the summaries below the controls.
- The same delivery correction keeps sidebar content at its expanded layout width behind the changing rail boundary, retains eager category layout, and fades newly revealed project rows instead of sliding them from the top; existing icon columns, footer actions, category behavior, and Reduce Motion remain.
- **Work notes** owns an integrated Add note toolbar, an inline single-text-field editor with Save and Cancel, and saved-note edit/delete controls. There are no title, context, or status fields; the draft stays in the selected project view across tab changes, and a failed save does not discard it.
- Note IDs and all legacy title/context text are retained on read, with title and context combined by a blank line; files are not rewritten merely by loading them, only an explicit mutation writes the new format, and status tracking is retired. Edits, deletion, atomic saves, and read-only recovery for malformed storage remain supported.
- Every prose/list group below the tabs uses the established translucent content surface, even when the same tab also contains headings or tables; source headings and bold-only titles stay outside it, and tables, workflow diagrams, and history rows keep their existing surfaces. Empty states and workflow guidance are also surfaced.
- Packaging now enforces the corrected version/build mapping and rejects mismatched pairs under the repository policy.
- The authorized code review found no production-code correctness, security, performance, or maintainability defect. It corrected a malformed-note fixture that could previously pass for the wrong reason, so the failure is attributable to note content rather than a missing top-level field, and gave the 1,120-point minimum one named source of truth.
- Checks: 40 focused note/presentation assertions (legacy migration without a read-time write, round trips, limits, save/edit/delete and failure preservation, mixed heading/prose/table order, bold-only titles, and prose coverage across all six registered projects); nine disposable-metadata numbering checks (valid pairs, rollover, and malformed/mismatched values); and 20 affected classification/parser core checks and five classification/store checks for the affected README and state paths.
- Complete native compilation, a cache-free optimized build, and strict signature/metadata/arm64/icon checks passed. The signed project-root app matches the source plist at v2.6/build 26, contains the exact generated icon, and has an arm64 executable with a valid strict ad-hoc signature.
- Formal verification then repeated the affected tests, complete compilation, cache-free optimized packaging, and strict package checks. Native icon packaging required its normal macOS access outside the command sandbox; the unchanged rule then succeeded.
- On September 3, live checks of an initial candidate confirmed prose wrapping, compact headers, an inline single-field editor, disabled empty Save, and enabled Save for a multiline draft; no saved notes were changed. Live inspection after the width correction confirmed the 1,120-point minimum, the single-row header, and the collapsed sidebar endpoint. The Mac was locked before the corrected expansion animation and remaining editor interactions could be reinspected.
- On September 4, the three superseded v2.6 candidates were removed while the signed app and ten distinct-version recoveries were retained; full core/store suites were not rerun for that cleanup. The September 6 cleanup later removed every build-folder recovery.
- Implementation is committed in `e44c740` and `330cb4b`, with project documentation in `265e76c`; this documentation checkpoint records the result.

**Evidence and delivery status**

Source `e44c740`; navigation `330cb4b`; project record `265e76c`; this documentation checkpoint; signed project-root app

[Back to change history](#change-history)

<a id="change-9"></a>

### v2.5 / build 16

- **Recorded date:** 2026-09-02.

- Combined project identity, actions, and Document Health in one compact pre-tab glass card.
- The icon, name, and version are top-aligned beside the notes gauge; folder, README, app, optional app-menu, application-detection message, document availability, and runtime disclaimer form a compact, adaptive lower grouping.
- The card alone reduces its content inset to 16 points, trimming its top and side space, and uses a 14-point internal row gap, leaving other glass-card styling unchanged; the action/status row drops its title-column offset or stacks when needed to preserve narrow-window readability, and the tab-to-content gap was reduced to eight points.
- No action, launch-selection, warning, note, README-parsing, or repository-data behavior changed; existing warnings, below-tab content styling, notes, history, repository activity, navigation, artwork, and lock behavior are unchanged.
- Complete native type-checking, a cache-free optimized build, strict signing, and exact v2.5/build-16 metadata checks passed; source and bundle metadata both identify v2.5/build 16, the executable is arm64, and the bundled icon is present.
- Live app inspection covered Local Assistant and the longer Python Accomplishments title at regular and minimum window sizes, confirming visible actions, detection text, integrated health, the notes gauge, and unclipped tab/content layout.
- Core/store logic was unchanged, so those suites were not rerun.
- The subsequent authorized review found no actionable issues; verification repeated a cache-free optimized build, strict signature/metadata/arm64/icon checks, and live narrow-window Local Assistant and Python Accomplishments header inspection.
- The initial delivery preceded that review and was uncommitted. Superseded same-version candidates and generated intermediates were removed after the final package checks.

**Evidence and delivery status**

Source `9c6756a`; this documentation checkpoint; signed project-root app

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

### v2.4 / build 15

- **Recorded date:** 2026-09-02.

- Removed only the competing whole-shell SwiftUI clip and outline, so the native macOS window owns the outer corners without light wedges while the full black chassis and independently rounded detail surface remain.
- Kept the three-point black detail reveal and visually tuned the detail layer to an 18-point radius, so all four rendered detail curves follow the native window instead of deriving the radius from an assumed outer value.
- Removed the lock artwork's custom outer mask and outline; lock and unlock now crossfade edge-to-edge with an opacity-only transition and no shell scaling.
- `ReadmeContent` wraps only untitled below-tab paragraph/bullet views in the established rounded translucent plane; heading-led content, native tables, Workflow titles and diagrams, history disclosure rows, work-note rows, and every area above the tabs keep their existing presentation.
- Added a lower-third sage halftone, fading upward, to the shared active/lock artwork and repeated it crisply above the normal detail blur, so its dots remain visible in the same lower position; a denser full-frame matrix of dots and short marks is added only to the clear lock view.
- Moved repository README, repository actions, and Lock into matching full-width pinned footer rows beneath a hierarchy separator, with one fixed book, adjustment, and lock icon axis and longer balanced Open README file, Repository menu, and Lock application labels. The menu's visible row uses the same fixed leading layout as the plain buttons instead of the borderless menu's intrinsic alignment.
- Compact workspace/sync status and the live bundle version follow a second separator, aligned to the visible icon column rather than the rail edge. Duplicate header/detail controls remain removed, all compact icons stay centered on one axis in the collapsed rail, and the detail header keeps identity and context without duplicated actions.
- Passed 332 core checks, 39 store checks, optimized arm64 compilation, strict signing, exact source/bundle v2.4/build-15 metadata, icon checks, root-bundle promotion, and live inspection of repository/project Overview, Architecture, and Workflows, expanded/collapsed footer and rails, lock artwork, halftone density, and the native/detail corners.
- The complete code review found no actionable source findings. Formal verification repeated a clean optimized rebuild, strict signing and package-identity checks, arm64/icon checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection.

**Evidence and delivery status**

Source `d26cb65`; project documentation `12fe707`; this documentation checkpoint; signed project-root app

[Back to change history](#change-history)

<a id="change-12"></a>

### v2.3 / build 14

- **Recorded date:** 2026-09-01.

- Added repository Commit activity: newest-first distinct years, twelve responsive month cells, fixed absolute intensities, dimmed future cells that conceal their counts, and a complete unique-commit total kept independent from valid monthly buckets.
- Hovering a populated cell lists each affected current project's icon (the real project icon when available), name, and participation count.
- Activity invokes the fixed system Git executable directly with read-only arguments and loads every unique reachable commit. Changed paths are read solely to map registered top-level project folders; commit messages, authors, and file contents remain unread.
- Reworked the shell into two explicit layers: one full-window rounded black chassis and one inset four-corner light-artwork detail panel above it in the right-hand detail region. The chassis is visible as the left rail and the narrow perimeter around all four detail corners; the detail panel blurs the same artwork that the lock screen shows clearly.
- Removed rail/detail overlap and visible scrollbars. The reference-style brand control stays visible in both rail states; the expanded brand row and collapsed 40-point icon column share one leading axis, and every rail icon keeps that fixed axis while labels animate. Top navigation, scrolling project groups, and the pinned local-only status remain structurally separate.
- Reduce Motion suppresses transitions, while Reduce Transparency retains the solid detail fallback.
- Passed 8 focused activity core checks, 1 store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata, arm64 executable/icon checks, and live expanded/collapsed/lock and activity inspection. Optional code review and formal verification did not run.
- The activity implementation is committed in `b5358ab` and the shell implementation in `dc612a8`; this documentation checkpoint records their delivered state.

**Evidence and delivery status**

Activity `b5358ab`; shell `dc612a8`; project documentation `920a9bb`; this documentation checkpoint; signed project-root app

[Back to change history](#change-history)

<a id="change-13"></a>

### v2.2 / build 13

- **Recorded date:** 2026-09-01.

Moved Category, Technical scope, and Technologies into the first three labelled list items of every root-register Professional scope cell, so the human-facing Projects register can use three readable columns without losing its complete project descriptions.

- The parser reads those labels case-insensitively, strips display markup, and handles blank labelled values explicitly.
- Older separate classification columns remain compatible and take precedence over same-named scope labels when present, including explicit blanks; the retired AI-usage column remains ignored.
- The existing v2.1 glass UI, project content, notes, launch behavior, synchronization paths, and all other project-management behavior are unchanged.
- All 20 focused core checks and 5 isolated store checks passed, including the new labelled-scope, blank-value, compatibility, and precedence regressions.
- Complete native type-checking, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, arm64 executable/icon checks, bundle promotion, and a separate-instance project-root launch passed.
- Source is committed in `5ab1b93`. Generated compiler/icon intermediates and the smoke process were removed.
- Optional code review and formal verification did not run.

**Evidence and delivery status**

Source `5ab1b93`; this project documentation and delivery checkpoint

[Back to change history](#change-history)

<a id="change-14"></a>

### v2.1 / build 12

- **Recorded date:** 2026-09-01.

- Delivered the approved edge-to-edge glass correction: removed all four outer shell insets, moved title-bar clearance inside the hierarchy rail, placed a full-window local sky/cloud/texture scene across the whole window, and replaced desktop-only sampling with `withinWindow` native material so the scene remains visible beneath the content plane.
- Normal appearance adds no opaque tint above the material; Reduce Transparency alone uses the existing strong surface as a solid fallback. The lock artwork shares the same scene and also fills the window.
- README parsing, classifications, notes, app discovery, tabs, native tables, diagrams, and all README-driven data and interaction paths are unchanged.
- Added the Project Control-specific rendered acceptance rule to root AGENTS.md without changing sibling-project policy.
- Complete native type-checking passed. A controlled 1320×760 render confirmed shell coverage at every edge midpoint and visible scene variation across the glass content plane, followed by visual inspection of the zero-gap boundary, shared backdrop, and content readability.
- After the source and dual-README checkpoints were committed, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, bundle promotion, and a separate-instance project-root launch passed.
- Generated intermediates and the smoke process were removed.
- Core/store behavior was unchanged, so those suites were not rerun; optional code review and formal verification did not run.

**Evidence and delivery status**

Source `f4fca5b`; project source record `ad48ff1`; root source record `41593c8`; project delivery `ee58c92`; this delivery checkpoint

[Back to change history](#change-history)

<a id="change-15"></a>

### v2.0 / build 11

- **Recorded date:** 2026-09-01.

- Delivered the complete cinematic glass redesign, replacing the earlier angular navy interface: a transparent native window and real behind-window desktop blur inside one outlined rounded shell, an aligned expanding/collapsing black hierarchy rail, staggered per-project disclosure transitions, bounded internal scrolling with hidden indicators, rounded content cards, and a no-password artwork lock that replaces the whole interface with local artwork and a centered Unlock control.
- The user's screenshot rejected the first signed candidate because it showed an internal green field; source `c4ef97a` provides the transparent-window and real behind-window material correction.
- Offscreen inspection removed a redundant lock caption that crossed the fortress silhouette. Offscreen repository/project renders confirmed the outlined shell, rounded hierarchy, real app icons, fixed-height content, and centered lock control; behind-window sampling itself requires the live window.
- README-derived data and parsing, classifications, notes, project icons, application discovery, content tabs, tables, diagrams, workflow data, and background README synchronization are unchanged.
- All **323 core checks** and **39 store checks** passed, followed by complete native type-checking, before distributable compilation. After the source and dual-README checkpoints were committed, a clean optimized build passed strict signing, exact source/bundle metadata equality, and separate-instance project-root launch.
- ScreenCaptureKit access remained denied, so final live capture and interaction are not claimed; optional code review and formal verification did not run.
- The superseded v2.0 bundle and generated intermediates were removed. Superseded Vector/Lens design and reference files remain in Git history.

**Evidence and delivery status**

Initial source `f317ff0`; desktop glass `c4ef97a`; project records `13e395f`, `039702e`, `98dad53`; root records `afd56a7`, `4e9319c`; this delivery checkpoint

[Back to change history](#change-history)

<a id="change-16"></a>

### v1.0 / build 10

- **Recorded date:** 2026-08-31.

- Replaced mandatory AI-usage badges with optional, individually wrapping root-README Technologies tags, keeping technical scope as a separate line. The root register supplies the tags for all six projects.
- Added per-tag wrapping, case-insensitive deduplication, explicit empty and retired-column behavior, and focused parser/store regressions; updated the parser, sidebar, all six root register entries, both README records, and the Project Control-only tag rule in root AGENTS.md.
- Passed **19 focused parser/register checks**, **5 store checks**, native type-checking, and **24 native tag-layout cases** at 64-, 148-, and 320-point widths, including empty and long labels.
- Offscreen views at 900×660 and 1160×840 and a six-project tag panel were inspected. The isolated render needed normal macOS icon-service access outside the agent sandbox; it captured only its own never-shown views, not desktop pixels, and no screen-recording permission was changed or retried. These checks do not establish live scrolling, keyboard interaction, or installed-app behavior.
- Source was committed separately, with the user's authorization, in `dc45f88` (metadata/sync), `36c21c4` (header), and `a427582` (sidebar), with root metadata/policy in `45ccc3d` and release records in `7f5b5ee` / `11896bf`, before the build; no build-gate exception was used.
- A cache-free optimized arm64 build was promoted to the project root. Strict signing, exact source/bundle metadata equality, v1.0/build-10 identity, unchanged Nexus icon bytes, and a fresh root-level process launch passed. The smoke-test process remained running for at least 47 seconds and was then closed; no existing Project Control process was present before the check. This confirms launch, not live interaction.
- Generated compiler caches and intermediate icon files were removed and can be regenerated. No desktop capture or privacy-setting change was attempted.
- No live-interaction, code-review, or formal-verification claim is made.

Run only the classification regressions from this project folder:

```sh
make test-core test-store TEST_ARGS=--classification
```

- These exercise optional/reordered columns, literal technology names, empty/duplicate tags, retired AI metadata, tag edits/removals, the actual six-project register, and stale-project refresh while preserving selection and notes.
- Omitting `TEST_ARGS` retains the existing test targets' complete behavior.

**Evidence and delivery status**

`dc45f88`, `36c21c4`, `a427582`; root metadata/policy `45ccc3d`; pre-build release records `7f5b5ee`, `11896bf`

[Back to change history](#change-history)

<a id="change-17"></a>

### v0.9 / build 9

- **Recorded date:** 2026-08-31.

- Corrected the header: a 36-point Nexus icon, an 18-point title, symmetric spacing and left alignment, and a separate ellipsis menu without the redundant triangle, so the ellipsis no longer overlaps the disclosure control.
- Added five collapsible, source-ordered README-driven categories with counts and independently wrapping technical-scope/AI-usage badges from optional root-register columns. Missing metadata remains unspecified and backward-compatible; root classification changes still apply when a project README is stale, preserving project identity, selection, and work notes.
- The focused checks cover case-insensitive and reordered optional metadata columns, custom category names, missing/blank/short rows, duplicate projects, source ordering, README-triggered regrouping, and preservation of selection/notes while project content is stale. The new source fixtures and the live six-project register passed **312 core checks and 38 store checks**.
- Native type-checking and a cache-free optimized build passed. Four isolated, never-shown native views were rendered: at 900×660 and 1160×840, a tall register showing all five categories, and a minimum-width long-repository-name case. The header icon/title alignment, separate ellipsis, wrapping badges, counts, selection highlight, and real app/fallback icons were inspected. The design pass retains the navy/icy-blue palette and uses informational badges, not health scores. These renders do not establish live scrolling, collapsing, keyboard, menu, or window-chrome behavior.
- macOS denied live window capture; no capture permission or privacy setting was changed or retried. The render probe and icon packager needed normal macOS icon-service access outside the agent sandbox; neither captured the desktop.
- The app was delivered directly in the project folder. Clean compilation, strict bundle identity/signature checks, matching source/bundle metadata, unchanged Nexus icon bytes, and project-root launch passed. Only the newly started background smoke-test instance was closed; the existing app session was preserved.
- The preceding v0.8 source/build work was already committed before this build; Temporary render sources/images, test binaries, compiler caches, and intermediate icons were removed.
- Source was uncommitted at delivery; the retained header/category implementation is now captured with v1.0 in `dc45f88`, `36c21c4`, and `a427582`, not in a separate v0.9 release commit. Live interaction, optional code review, and formal verification were not confirmed or run for this batch.

**Evidence and delivery status**

Retained implementation captured with v1.0 in `dc45f88`, `36c21c4`, `a427582`; no separate v0.9 release commit

[Back to change history](#change-history)

</details>

### Earlier history

Older records are archived by period, newest first. Each archive keeps the same table
and full records; the count after a link is how many records it holds.

- **Months** — [August 2026](history/2026-08.md) (11)

---

<!-- project-control:section=ignore -->
## 🔒 License

**PROPRIETARY SOFTWARE — ALL RIGHTS RESERVED**

Copyright © 2024–2026 Soucieux. All rights reserved.

The original source code, documentation, and other original materials in this repository are proprietary and are not open-source software.

Except where applicable law expressly permits otherwise, no permission is granted to copy, modify, publish, distribute, sublicense, sell, deploy, or create derivative works from these materials, in whole or in part, without prior written authorization from the copyright owner.

Access to this repository does not grant a license. Third-party software and materials remain subject to their respective license terms.

*This private project is not open for external contributions.*
