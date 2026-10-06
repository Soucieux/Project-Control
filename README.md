# Project Control

![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![Release](https://img.shields.io/badge/Release-v4.8%20build%2048-brightgreen) ![Reads](https://img.shields.io/badge/Reads-Repository%20READMEs-9f9f9f)

[Overview](#overview) · [Capabilities](#capabilities) · [Quick start](#quick-start) · [Usage](#usage) · [Workflow](#workflow) · [Architecture](#architecture) · [Project structure](#project-structure) · [Current release](#current-release) · [References](#references) · [Contributing](#contributing) · [Change history](#change-history)

<!-- project-control:section=overview -->
## Overview

Project Control is a native macOS management center for this repository.

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

## Usage

### Navigation and work notes

- **Project views:** Overview, Architecture, Models, Workflows, and Project history reflect the selected README.
- **Rail:**
  - Click the repository's name or its icon at the top of the rail to collapse the rail to icons, and the icon again to expand it.
  - The grey line under the name opens the repository's overview, history and commit activity, and the number after the name is how many projects the repository holds.
- **Collapsed rail:** A category icon lists that category's projects beside it; choosing one opens it and keeps the rail collapsed.
- **Notes:** Use **Add note** or `Command-N` while Work notes is visible; save nonblank text with `Command-Return`, or cancel with Escape. Notes accept up to 4,000 characters; saved notes can be edited or deleted.
- **Context:** Drafts remain attached to their selected project. Category expansion and navigation do not change saved notes.
- **Lock this window:** Hides the workspace without adding password protection or changing data.

### Refresh and recovery

- **Automatic refresh:** Active views check the repository's READMEs and project folders about every two seconds. **Refresh now** — the arrow beside the version at the foot of the rail, or `Command-R` — reloads immediately. **Change repository…** in the rail footer, or `Command-O`, chooses another repository.
- **Valid edits:** Replace the displayed content while preserving local notes and an existing selection.
- **Unreadable files:** Keep the last good view with an out-of-date warning. Repair the README to recover on the next check.
- **Last read:** The pill in the top corner of the repository screen reports when documentation was read; on a project's screen it shows the README's state and folder instead. Runtime health remains unchecked.

### Local storage and app opening

- **Work notes and choices:** Stored in `Application Support/Project Control/workspace.json` on this Mac.
- **Project identity:** Saved data follows the canonical project path; moving a repository does not migrate it automatically.
- **Recovery:** Invalid or duplicate note records preserve the file and disable editing. Keep a backup before attempting repair or using an older app with newer data.
- **Older notes:** v2.6 retains legacy note IDs and combines title/context text; retired completion status is not restored.
- **Automatic apps:** Eligible `.app` bundles must be directly inside the project. Selection prefers a project-name match, then a folder-name match, then a sole candidate; unmatched multiple candidates appear as choices.
- **Manual choice:** If no app is detected, **Open App** can open and remember a selected application when local storage is writable.
- **Boundary:** Files and apps open only on your action. This local build has no network client and is neither sandboxed nor notarized. Runtime monitoring, arbitrary script launching, and public distribution are not implemented.

<!-- project-control:section=workflows -->
## Workflow

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

<!-- project-control:section=architecture -->
## Architecture

### Frontend & Presentation

| Technology or concept | Use in this project |
|---|---|
| SwiftUI | Builds the black chassis, the sky-and-cloud detail layer, smoked-glass content, animated hierarchy rail, artwork lock, project screens, work-note editor, expandable History cards, responsive commit-activity grid, native tables, and restrained motion. ReadmeContent and RepositoryScreen render the selected source content. |
| AppKit | Provides macOS icons, application/window integration, file pickers, and explicit open actions. ProjectIcon shows each project folder's own Finder icon, with a neutral fallback, and keeps each icon until its folder or custom icon changes. |

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
├── Sources/App/        # Native state, layered interface, sky backdrop and lock artwork
├── Resources/          # Bundle identity, version, Repository Atlas master, and icon catalog
├── Scripts/            # Version and build pair check run before packaging
├── Tests/              # Focused synthetic, read-only repository and window checks
├── history/            # Archived change-history periods
├── Makefile            # Local build, focused checks, launch
├── CONTRIBUTING.md     # Project-facing contribution and numbering rules
├── Project Control.app # Latest completed app; ignored by Git
└── build/              # Staging and caches; ignored by Git
```

<!-- project-control:section=release -->
## Current release

**v4.8 (build 48)** in source and in the signed local app. [Change and delivery evidence](#v4-8-build-48).

## References

<!-- project-control:section=ignore -->
### README content contract for Project Control

- Repository and project READMEs are the content baseline.
- Project Control reads selected sections locally; it never executes README instructions, scans source code, or uses a model to invent missing facts.
- This section is the single authoring contract for all current and future projects.
- It is referenced by the repository instructions and applies to README inputs, not sibling applications' UI or runtime behavior.

#### Add a new project to Project Control

- A folder directly inside the repository root that holds a `README.md` appears on its own, after the registered projects, under **Uncategorized**; its card notes that it is not in the root register.
- Project Control lists only those top-level folders. It never scans nested or hidden folders, and it lists a folder link only when the register names it.
- Registered projects come first, in the order of the root README's **Projects** table, with their category, technical scope and technology tags; unregistered folders follow in name order, named after the folder.
- Complete every step below so the project appears under its category and every detail tab fills.

1. **Create one top-level project folder.** Put it directly inside the repository root, beside the
   existing project folders. For example, create `Example Project/`, not
   `Some Collection/Example Project/`. Keep the project inside this repository; a symlink to a
   folder outside the repository is rejected.
2. **Create the project's README.**
   - Add `Example Project/README.md` as a regular UTF-8 file smaller than 2 MB.
   - Start with a plain-language overview, then document the architecture, optional models,
     workflows, and history that the app should show.
   - Choose the project's change-history mode — project version and build, version-only component,
     or dated history — and place the required linked declaration beside its current-release or
     history section.
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
4. **Register the project in the root Projects table.**
   - Add one row directly to the table under the `projects` marker.
   - The first cell must link to the new top-level folder.
   - If the folder name contains spaces, encode each space as `%20` in the link.
   - Open the Professional scope cell with the **Updated** date, then **Repository** with the public
     mirror's link or `N/A`, **Category**, **AI** (`N/A` for a project without AI), **Platform** and
     **Technologies**, followed by the useful project summary.

   ```markdown
   | [Example Project](Example%20Project/) | <ul><li><strong>Updated:</strong> 2026-09-04</li><li><strong>Category:</strong> Project Management</li><li><strong>Platform:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; SQLite</li><li><strong>Purpose:</strong> A concise factual summary.</li></ul> |
   ```

   Use real, source-confirmed classifications. Separate technology names with semicolons. The folder
   link, not the display name, identifies the project, so keep the link accurate when renaming it.
5. **Complete the records.** Keep full project descriptions, operating details, and history in the
   project README. Keep the introduction and guide links in the root **Projects** table’s Professional scope cell and a dated
   summary linking to the full project history in the root **Change log**.

   For unique contributor requirements, add scope under root `AGENTS.md` and link a purpose-specific
   reference in `.agents/instructions/`. Keep the README focused on users; never create a nested
   `AGENTS.md` or `CLAUDE.md`.
6. **Check the result in Project Control.**
   - With this repository selected, save both READMEs and wait about two seconds, or use **Refresh
     now**.
   - Confirm that the project appears under the intended category, its scope and technology tags are
     correct, and every documented detail tab opens without a README warning.
   - A macOS `.app` is detected automatically only when it is directly inside the project folder;
     otherwise, **Open App** can remember a manually selected application.

- If the project stays under **Uncategorized** with the unregistered note, check that its row is directly inside the selected Projects table, the link resolves to exactly that top-level folder, and the folder and README names match letter-for-letter.
  - If a tab stays empty, check that every section marker immediately precedes a heading.
- A malformed root register is rejected; an unavailable project README leaves the project visible from its root summary but cannot supply complete detail tabs.

#### Select app-visible sections

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

- The project's title shows the `release` section's version under its name.
  - A version written in bold after a component name, such as `**Observatory v2.7**`, keeps that name, so a component's number is never shown as the whole project's.
  - Without one, the title shows **Dated history** when the numbering declaration beside the release or history section says the project uses dated history, and **Release not specified** otherwise.

In a README containing markers, only marked sections and their descendants are selected. A section ends at the next heading of the same or a higher level.

A child's explicit marker can select a different destination, except inside `ignore` or `history`: those subtrees remain excluded or historical. Unmarked sibling sections stay README-only.

- Multiple sections may target one destination and retain source order.
- Keep markers when renaming or moving headings; do not insert prose between a marker and its heading.
- Unknown identifiers, malformed markers, consecutive markers without headings, and orphan markers are errors.
- Marker-like examples inside fenced code blocks are inert, not configuration.

- The Projects register reads tables directly under its selected heading, not unrelated tables inside descriptive subsections.
- Keep extended project descriptions in the owning project README; the root Projects table contains concise introductions and links in each Professional scope cell.

- The register has two columns: the project folder link and the Professional scope description. The app reads a labelled item wherever it appears in that cell, so the order below is for readers, not for parsing.
- A row whose first-column link points at another repository — a fork or any work kept outside this one — is skipped rather than displayed, because there is no folder here to read; such rows belong in the root README's **Forked projects** section, which is marked `ignore`.
  - A relative link that escapes the repository is still refused as unsafe.
- Every Professional scope cell opens with **Updated**, then **Repository** (`N/A` without a public mirror), and carries these three labelled items, each on a single line:

```html
<ul><li><strong>Category:</strong> Project Management</li><li><strong>Platform:</strong> Native desktop</li><li><strong>Technologies:</strong> SwiftUI; README-driven</li><li><strong>Purpose:</strong> Project-specific summary.</li></ul>
```

- Project Control reads the labels case-insensitively, removes presentation markup, and leaves later project-specific bullets available as the professional summary. The **AI** item after **Category**, `N/A` for a project without AI, is one of those bullets, and so is any sub-bullet list, which the app reads as plain text.
- Categories and their projects retain first-appearance/source order.

- Missing or blank Category values use **Uncategorized**; a missing or blank Platform is omitted from the sidebar row and the project's title, and missing or blank Technologies from the project card.
- Custom category labels are supported without changing code.

- Use short, factual labels: native UI with local logic is **Native desktop**, not a server-based full-stack app; AI educational content is not an AI runtime.
- Calling an external AI API does not make a utility a backend.

- Older registers with separate `Category`, `Technical scope`, and `Technologies` columns remain compatible, and a scope cell still labelled **Technical scope** instead of **Platform** is read the same way.
- When one of those legacy columns is present, its value—including an explicit blank—wins over a same-named scope label.
- Do not duplicate current metadata across both formats.

- Write **Technologies** as semicolon-separated names, for example `SwiftUI; README-driven` or `Next.js; LangGraph; Hosted AI`.
- Each nonempty name becomes its own tag.
- Surrounding whitespace and Markdown formatting are removed; case-insensitive duplicates keep their first spelling and position. Keep punctuation inside names, such as `C++` or `model_name-v1`. Do not use a semicolon inside one name.

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

#### Write readable architecture and workflow content

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

#### Update and recovery behavior

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
| v4.8 / build 48 | 2026-10-05 | <ul><li><strong>Checks:</strong> The live architecture checks expect Career Ledger's four category headings, which its README now groups its table under, so <code>make test</code> passes again.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing checks; installed in place of v4.7.</li></ul> | [Full record](#v4-8-build-48) |
| Documentation | 2026-10-05 | <ul><li><strong>Structure:</strong> Sections follow the order and names every project README now shares, under a contents line; sections were renamed and moved, and no wording was removed.</li></ul> | [Full record](#readme-skeleton) |
| v4.7 / build 47 | 2026-10-05 | <ul><li><strong>Checks:</strong> The live architecture checks expect Meta Search Engine's four category headings, so <code>make test</code> passes again.</li><li><strong>Coverage:</strong> They also name every architecture row and the main technologies of Career Ledger, DayWright and Meta Search Engine.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing checks; installed in place of v4.6 and launched.</li></ul> | [Full record](#v4-7-build-47) |
| Documentation | 2026-10-05 | <ul><li><strong>Readability:</strong> Long paragraphs, bullets and table cells are now short leads with sub-points, one fact each; no detail was removed.</li></ul> | [Full record](#readme-structure) |
| v4.6 / build 46 | 2026-10-01 | <ul><li><strong>Register:</strong> The root register names a project's technical scope Platform, and the app reads it for the sidebar and title; a register still labelled Technical scope shows the same.</li><li><strong>Contract:</strong> The README content contract uses the register's one-word labels and places an AI item after Category.</li></ul> | [Full record](#v4-6-build-46) |
| v4.5 / build 45 | 2026-10-01 | <ul><li><strong>Tabs:</strong> On every screen the content sits 12 points below the tabs, so the two read as one group: half the repository screen's former 24 points, and a project's 8 widened to match.</li><li><strong>Evidence:</strong> Passed the interface, version and signing checks; installed in place of v4.4 and launched.</li></ul> | [Full record](#v4-5-build-45) |
| v4.4 / build 44 | 2026-09-28 | <ul><li><strong>Icons:</strong> Each project folder's icon is fetched once and kept until the folder or its custom icon changes; checking that it is unchanged costs about an eighth of fetching a custom icon again.</li><li><strong>Architecture and Models:</strong> Both tabs come from one reading of a project's architecture sections, so reading them for all eight projects here takes about 10 to 11 ms instead of 16 to 18 ms, with the same content.</li><li><strong>Checks:</strong> <code>make test-ui</code> also checks the icon cache.</li><li><strong>Evidence:</strong> Passed all five check suites and the signing checks; installed in place of v4.3 and launched.</li></ul> | [Full record](#v4-4-build-44) |
| v4.3 / build 43 | 2026-09-27 | <ul><li><strong>Fixes:</strong> Two quick clicks on the rail's toggle or on a history card's chevron now end in the state last asked for, and a closing history card fades its lines out together instead of cutting them off.</li><li><strong>History cards:</strong> An opened card shows each description cell of its README row whole, without the record link's label.</li><li><strong>Commit activity:</strong> The heatmap has one full-size layout, which fills the reading column at every window size.</li><li><strong>Sky:</strong> The clouds keep their pixels while the window is resized, and each resize redraw costs about a tenth of a millisecond.</li><li><strong>Document health:</strong> A missing folder is stated once.</li><li><strong>Checks:</strong> <code>make test-ui</code> checks the rail and history cards in a window of the app's own views, and a failed check no longer leaves its temporary folder behind.</li><li><strong>Evidence:</strong> Passed all five check suites and the signing checks; installed in place of v4.2 and launched.</li></ul> | [Full record](#v4-3-build-43) |
| v4.2 / build 42 | 2026-09-27 | <ul><li><strong>Diagrams:</strong> Every workflow arrow stops a small gap short of the rectangles it joins, and nodes that line up are joined by one straight line instead of one with a slight sideways jog.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing and launch checks.</li></ul> | [Full record](#v4-2-build-42) |
| v4.1 / build 41 | 2026-09-26 | <ul><li><strong>Look:</strong> Content sits on dark smoked glass over a sharp sky with pixel-dithered clouds, in place of the blurred artwork.</li><li><strong>Layout:</strong> Each screen reads in a centered column under a title set on the sky, and a small pill in the top corner shows the read time or README state.</li><li><strong>Details:</strong> The card's summaries read as a small label over a larger value, tags are plain text, history rows open into a panel inside their card, and the rail folds its labels away before it narrows.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing and launch checks.</li></ul> | [Full record](#v4-1-build-41) |
| v4.0 / build 40 | 2026-09-26 | <ul><li><strong>Icon:</strong> Redrew the Repository Atlas icon in the macOS icon shape, so the app and the project folder show one icon at the standard size.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing, drawn-icon, and launch checks.</li></ul> | [Full record](#v4-0-build-40) |
| v3.9 / build 39 | 2026-09-25 | <ul><li><strong>Open App:</strong> A choice from the detected-app menu is refused when that bundle is no longer a current candidate, so a bundle replaced by a link since the last check cannot open an app outside the project.</li><li><strong>Git reads:</strong> Git runs with a fixed environment, without system or personal Git settings, so a personal setting cannot change the activity the app shows.</li><li><strong>Source:</strong> <ul><li>The README parser compiles each pattern once,</li><li>both screens share one tab strip,</li><li>the three test suites share one assertion helper,</li><li>the history list lives beside the other README content views,</li><li>the minimum window height is named beside the width,</li><li>and a test-only Git constant, a redundant container and a no-op modifier are gone.</li></ul></li><li><strong>Documentation:</strong> The project structure lists Scripts, history and the guide, the build folder is described as staging only, and every history record's link target is named after its version and build or its subject.</li></ul> | [Full record](#v3-9-build-39) |
| v3.8 / build 38 | 2026-09-24 | <ul><li><strong>Rail:</strong> The repository row shows how many projects the repository holds.</li><li><strong>Footer:</strong> The version and build, and the refresh cadence, each have one line under the Project Control name.</li></ul> | [Full record](#v3-8-build-38) |
| v3.7 / build 37 | 2026-09-24 | <ul><li><strong>Tests:</strong> The store and notes checks keep their preferences inside their own temporary folder, so a run no longer leaves an empty preferences file behind.</li></ul> | [Full record](#v3-7-build-37) |
| v3.6 / build 36 | 2026-09-24 | <ul><li><strong>Projects:</strong> Every top-level folder with a README appears, registered or not.</li><li><strong>Rail:</strong> The repository's name and icon collapse and expand the rail; the brand moves to the foot with the version; a collapsed category lists its projects.</li><li><strong>Project card:</strong> One layout for every project: the actions sit on the name's row and the summaries fill one full-width strip.</li></ul> | [Full record](#v3-6-build-36) |
| v3.5 / build 35 | 2026-09-23 | <ul><li><strong>Workflows:</strong> One diagram style: titled routes of steps joined by ↓, with branches and merges, several routes per block.</li><li><strong>Parsing:</strong> Parentheses and semicolons in a step read as prose, and up to sixteen routes show instead of eight.</li></ul> | [Full record](#v3-5-build-35) |
| v3.4 / build 34 | 2026-09-23 | <ul><li><strong>Rail:</strong> The Project Control name is a fixed label; the collapse control moved to the end of the repository row, which stays pinned while the projects scroll.</li><li><strong>Project card:</strong> Document Health and Notes sit beside the project name and the version shares a line with the tags, so the card has no empty half.</li><li><strong>Fix:</strong> A workflow diagram with a wrapped node no longer pushes its last node onto the card's edge, and a branch's connectors meet at one height.</li></ul> | [Full record](#v3-4-build-34) |
| v3.3 / build 33 | 2026-09-23 | <ul><li><strong>Rail:</strong> Categories are quiet section headers and each project row is one line, so more of the register fits before scrolling.</li><li><strong>Footer:</strong> Repository README, Change repository…, and Lock are plain buttons; the Repository menu is gone, and Refresh now sits on the status line.</li><li><strong>Detail:</strong> Technology tags moved to the project card, and the header strip repeating the Project Control name was removed.</li></ul> | [Full record](#v3-3-build-33) |
| v3.2 / build 32 | 2026-09-23 | <ul><li><strong>Icons:</strong> Every project row, project header, and activity hover shows the project folder's own Finder icon instead of an app's icon, so projects without an app no longer show a generic symbol.</li><li><strong>Identity:</strong> A missing folder, or an alias that no longer points at the project, still shows the neutral symbol.</li><li><strong>Checks:</strong> The live checks follow the root register, so the full test suite runs again.</li></ul> | [Full record](#v3-2-build-32) |
| v3.1 / build 31 | 2026-09-21 | <ul><li><strong>Identity:</strong> Repository Atlas shows the root README branching to its projects, with one selected project, a work note, and Git activity.</li><li><strong>Packaging:</strong> The build now compiles the checked-in macOS asset catalog with Apple's asset tool.</li></ul> | [Full record](#v3-1-build-31) |
| Documentation | 2026-09-13 | <ul><li><strong>License:</strong> Added the approved Soucieux proprietary-software notice.</li></ul> | [Full record](#soucieux-proprietary-license) |
| v3.0 / build 30 | 2026-09-12 | <ul><li><strong>Register:</strong> A row linking to another repository is skipped instead of making the whole register unreadable.</li></ul> | [Full record](#v3-0-build-30) |
| v2.9 / build 29 | 2026-09-12 | <ul><li><strong>Delivery:</strong> The promotion step deletes the set-aside bundle once the new app is in place, so a build no longer leaves an older release behind.</li></ul> | [Full record](#v2-9-build-29) |
| Documentation | 2026-09-12 | <ul><li><strong>Contributing:</strong> Added a standalone project guide so the source carries its own contribution and numbering rules.</li><li><strong>Links:</strong> Removed the README's dependencies on parent-only repository files.</li></ul> | [Full record](#standalone-contributor-guide) |
| v2.8 / build 28 | 2026-09-11 | <ul><li><strong>Source:</strong> Restored the header icon's alignment with the project name, removed per-render bundle reads and repeated measurement from the interface layer, named the documented parsing limits, and removed unused code.</li><li><strong>Documentation:</strong> Each change-history record now states its change once, and unused link anchors were removed.</li></ul> | [Full record](#v2-8-build-28) |
| Documentation | 2026-09-06 | <ul><li><strong>Structure:</strong> User guide first; one history table.</li><li><strong>Rules:</strong> Scoped contributor guidance under AGENTS.</li></ul> | [Full record](#readme-organization) |
| Maintenance | 2026-09-06 | <ul><li><strong>Change:</strong> Reorganized long paragraphs and table cells without dropping details.</li></ul> | [Full record](#readability-maintenance) |
| Documentation | 2026-09-06 | <ul><li><strong>Change:</strong> Moved complete project descriptions, register details, and repository-origin history into this README.</li></ul> | [Full record](#project-descriptions-moved) |
| Maintenance | 2026-09-06 | <ul><li><strong>Change:</strong> Removed the entire build folder and stale Finder metadata.</li></ul> | [Full record](#build-folder-cleanup) |
| v2.7 / build 27 | 2026-09-05 | <ul><li><strong>Change:</strong> Restores source-derived sidebar tags and notes availability.</li></ul> | [Full record](#v2-7-build-27) |
| Maintenance | 2026-09-04 | <ul><li><strong>Change:</strong> Removed the superseded v2.6 candidates from build/previous.FdBli0, build/previous.GtF7qQ, and build/previous.uqRg60.</li></ul> | [Full record](#superseded-candidates-removed) |
| Maintenance | 2026-09-03 | <ul><li><strong>Change:</strong> Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout.</li></ul> | [Full record](#sidebar-reveal-width) |

<details>
<summary>Full records for this table</summary>

<a id="v4-8-build-48"></a>

### v4.8 / build 48

- **Recorded date:** 2026-10-05.
- **Category check:** The core suite compares each project's architecture category headings with an
  expected list.
  - Career Ledger's README grouped its one architecture table under the shared category headings,
    so its four headings failed the check and `make test` stopped in the core suite.
  - The list now names AI & Intelligence, Frontend & Presentation, Backend & Application Logic, and
    Data & Storage, in that order.
- **Build:** `make app` sets the replaced app aside under its own name, so `FINAL_APP` may name the
  delivered app outside the project folder, as when promoting from a worktree.
- **App:** No source or interface change; the version advances because the checks and the build
  step changed.

**Evidence and delivery status**

- `make test`, built into a temporary folder outside the project, passed 445 core, 41 store, 50
  notes and presentation, and 12 version checks.
- `make app` built and signed v4.8 build 48, which passed strict signature verification and reports
  version 4.8 and build 48; it replaced v4.7 at the project root and launched.
- Delivered uncommitted on 2026-10-05, then committed as `c0963b8`, with this citation after it.

[Back to change history](#change-history)

<a id="readme-skeleton"></a>

### Documentation

- **Recorded date:** 2026-10-05.
- **Why:** project READMEs named and ordered the same kinds of section differently, so setup, workflow and
  architecture sat in a different place in each.
- **Order:** the sections now run Overview, Capabilities, Quick start, Usage, Workflow, Architecture, Project structure, Current release, References, Contributing, Change history.
- **Renamed:** Using Project Control is now Usage, and Workflow and data sources is Workflow.
- **Moved:** Workflow now comes before Architecture, and README content contract for Project Control sits under References, after Current release.
- **Opening:** a contents line under the title links every section.
  - The overview opens with its describing sentence as a plain paragraph, where it was the first list item.
- **Unchanged:** every sentence, table, diagram and Project Control marker inside the sections; whole sections
  moved, and links to a renamed section were updated.
- **Scope:** Documentation only.

[Back to change history](#change-history)

<a id="v4-7-build-47"></a>

### v4.7 / build 47

- **Recorded date:** 2026-10-05.
- **Category check:** The core suite compares each project's architecture category headings with an
  expected list.
  - Meta Search Engine, registered on 2026-10-01, had no entry, so its four headings failed the
    check and `make test` stopped in the core suite.
  - The list now names Frontend & Presentation, Data & Storage, Integrations & Security, and Build &
    Delivery, in that order.
- **Row check:** Career Ledger, DayWright, and Meta Search Engine had no expected architecture rows,
  so the checks passed them without reading their tables.
  - Each now lists every row of its architecture tables, and each listed row must appear exactly
    once.
- **Coverage:** The coverage check looks for each project's main technologies, as it does for the
  earlier projects:
  - Career Ledger: SwiftUI, SQLite, llama.cpp, Qwen, GGUF, and Dictation.
  - DayWright: React, Tauri, FastAPI, PlatformState, SQLite, sqlite-vec, LlamaRuntime, and Whisper.
  - Meta Search Engine: React, React Router, Bootstrap, browser local storage, Tavily, Vite, and
    Vitest.
- **App:** No source or interface change; the version advances because the checks changed.

**Evidence and delivery status**

`make test`, built into a temporary folder outside the project, passed 441 core checks, 59 of them
new, with 41 store, 50 notes and presentation, and 12 version checks.

- `make app` built and signed v4.7 build 47, which passed strict signature verification and reports
  version 4.7 and build 47.
- Installed in place of v4.6 at this project root on 2026-10-05:
  - the installed app passed strict signature verification,
  - reports version 4.7 and build 47,
  - carries the built binary byte for byte,
  - and launched.
- The v4.6 bundle was kept in the ignored `build/` folder until then, then moved to the Trash after
  approval.
- Delivered uncommitted and recorded in `a137dc0`; published to the public repository on
  2026-10-05.

[Back to change history](#change-history)

<a id="readme-structure"></a>

### Documentation

- **Recorded date:** 2026-10-05.
- **Why:** many records and some guidance ran as bullets or paragraphs of 50 to 100 words, which hid
  the separate facts inside them.
- **Layout:** every paragraph, bullet and table cell over 50 words is now a short lead with
  sub-points, one fact each. The wording was moved, not rewritten.
- **Unchanged:** every section, heading, link, anchor, table row, diagram, number and identifier.
- **Evidence:** compared with the previous version, no word is removed, and the headings, anchors,
  links, code spans, numbers and fenced samples are identical. The README layout, link and history
  checks pass.
- **Scope:** Documentation only; no source, version or app changed.

[Back to change history](#change-history)

<a id="v4-6-build-46"></a>

### v4.6 / build 46

- **Recorded date:** 2026-10-01.
- **Register:** The root register now gives every item a one-word label, and a project's technical
  scope is labelled **Platform**. The app reads **Platform** for the sidebar row and the project's
  title, and still reads **Technical scope** from an older label or column, so an older register
  shows the same.
- **Contract:** The README content contract's examples and rules use the new labels — **Updated**,
  **Repository**, **Category**, **Platform**, and **Technologies** — and say that the **AI** item
  after **Category**, `N/A` for a project without AI, reads as part of the project's summary.
- **Checks:** A new core check reads a row still labelled **Technical scope**.

**Evidence and delivery status**

`make test` passed 373 core checks, the new one included, with 41 store, 47 notes and presentation,
and 12 version checks; `make test-core` passed its 373 again once the live register used the new
labels.

- `make app` built and signed v4.6 build 46, which passed strict signature verification.
- Installed in place of v4.5 at this project root on 2026-10-01:
  - the installed app passed strict signature verification,
  - reports version 4.6 and build 46,
  - carries the built binary byte for byte,
  - and launched and quit cleanly, showing each project's platform from the main checkout's
    register, which still used the older label at the time.
- The v4.5 bundle was kept in the ignored `build/` folder until then, then moved to the Trash after
  approval.
- Delivered uncommitted and recorded in `4f40a89`; published to the public repository on 2026-10-01.

[Back to change history](#change-history)

<a id="v4-5-build-45"></a>

### v4.5 / build 45

- **Recorded date:** 2026-10-01.
- **Tabs:**
  - On the repository screen the tab strip and the content below it were 24 points apart, the same
    gap that separates the title from the tabs, so the content read as a block of its own.
  - They now sit 12 points apart, half that gap, so the content reads as the tabs' own.
  - A project's screen held its tabs and content 8 points apart; it now uses the same 12 points, and
    both screens read the gap from one shared theme value, so they cannot drift apart.
- **Scope:** Only that gap changed; the titles, the project card, the tabs and their content are as
  before.

**Evidence and delivery status**

`make app` built and signed v4.5/build 45, which passed the version check and strict signature
verification and carries a bundle plist identical to the source.

- `make test-ui` passed its 27 checks, including the history-card checks, which find the first card
  below the tabs at its new height.
- In captures of the app's views at 1×, the sky between the tab strip and the content below it
  measures 12 pixels on the repository screen and on a project's screen.
- Installed in place of v4.4 at this project root on 2026-10-01; after the project screen's gap was
  matched the same day, the app was rebuilt and installed again in place of the first v4.5 build.
- The installed app passed strict signature verification, reports version 4.5 and build 45, and
  launched without a crash report showing the 12-point gap.
- The v4.4 bundle and the first v4.5 build were each kept in the ignored `build/` folder until their
  replacement passed those checks, then proposed for removal.
- Delivered uncommitted and recorded in `7734cfb`; published to the public repository on 2026-10-01.

[Back to change history](#change-history)

<a id="v4-4-build-44"></a>

### v4.4 / build 44

- **Recorded date:** 2026-09-28.
- **Icons:**
  - The rail, the project title and the activity hover fetched a project folder's Finder icon from
    the system every time they were drawn, about a fifth of a millisecond for each folder with a
    custom icon, as every project folder in this repository has.
  - Each icon is now kept with a stamp of its folder, made of the folder the project resolves to and
    the times the folder's and its custom icon file's metadata last changed, and fetched again only
    when that stamp moves.
  - Setting, replacing or removing a custom icon, rewriting the icon file in place and a folder-only
    change such as a Finder colour label each move it.
  - A kept icon costs about 27 to 29 µs, against 207 to 231 µs to fetch a custom icon again; a
    folder with the plain folder icon costs about 40 µs to look up, so the saving there is smaller.
  - A missing folder, or an alias that no longer points at the project, still shows the neutral
    symbol, checked on every draw as before.
- **Architecture and Models:**
  - The Models tab read a project's architecture sections a second time after the Architecture tab
    had read them.
  - Both tabs now come from one reading, so reading them for the repository's eight projects takes
    about 10 to 11 ms instead of 16 to 18 ms, and both show exactly what they showed before.
- **Checks:**
  - `make test-ui` also sets, replaces and removes a disposable folder's custom icon, changes the
    icon file alone and gives the folder a Finder colour label, and confirms the icon is fetched
    again after each change and reused while nothing changes.
  - The parser checks read both tabs through the one reading.
- **Scope:** No README content the app shows, notes, storage, Git reading or app-opening behaviour
  changed.

**Evidence and delivery status**

`make test` passed: 372 core, 41 store, 47 note/presentation, and 12 version checks.

- `make test-ui` passed its 27 checks, 7 of them on the icon cache; the same checks fail against a
  cache keyed on the folder's modification time alone, which misses a change to the icon file alone,
  and against no cache.
- The Architecture and Models content of all eight projects in this repository, 106 blocks, was
  identical before and after the change.
- `make app` built and signed v4.4/build 44, which passed strict signature verification, reports
  version 4.4 and build 44, and carries a bundle plist identical to the source.
- Installed in place of v4.3 at this project root on 2026-09-28, where it passed strict signature
  verification and launched without a crash report, showing every project's folder icon in the rail;
  - the v4.3 bundle it replaced was kept in the ignored `build/` folder until v4.4 passed those
    checks, then proposed for removal.
- On 2026-09-30, after the last changes, which touched only comments in the app's sources,
  `make app` produced the same executable byte for byte, and the installed app passed the same checks
  again and launched showing every project's folder icon.
- Delivered uncommitted and recorded in `f5c5b4d`, `49c8bc7` and `ab5d55d`; published to the public
  repository on 2026-09-30.

[Back to change history](#change-history)

<a id="v4-3-build-43"></a>

### v4.3 / build 43

- **Recorded date:** 2026-09-27.
- **Rail:**
  - Two clicks on the repository's name or icon in quick succession could leave the rail collapsed,
    because each click scheduled its second step without cancelling the one before.
  - The two steps now run as one sequence that a newer click cancels, so the rail always ends in the
    state last asked for, and the toggle's help text follows that state at once.
- **History cards:**
  - A history card's chevron had the same fault: opening, closing and opening again quickly left the
    card closed, and a quick open and close left its lines showing without their fade the next time
    it opened.
  - Closing now fades the panel and its lines together in about 0.12 seconds before the card
    shrinks; before, each line faded on its slower opening schedule and was cut off when the panel
    went.
- **History card lines:**
  - An opened card lists its README row's description cells one per line.
  - Before, the cells were joined and split again at every ` · `, so a cell whose own text held one
    broke in two, and the record column showed its link's label, "Full record", as a line of its
    own.
  - A cell that is only a link is now left out when another cell describes the row; a row described
    by nothing but a link keeps its label.
- **Commit activity:**
  - The heatmap has one layout, the full-size one, and it fills its column at every window size.
  - Since v4.1 the reading column has given the grid about 770 points, under the old 940-point
    threshold, so it always showed the compact layout's small type in large cells; the smallest
    window leaves the grid wider than the compact layout ever needed, so that layout is gone.
- **Sky:**
  - Each cloud bank's pixels are worked out once and kept, measured from the bank's corner, so
    resizing the window moves them instead of working them out again.
  - A resize redraw costs about 0.1 ms instead of 1.7 to 2.3 ms, and the clouds keep their pixels
    while the window changes size, where before their edges were re-sampled at every step.
  - Opening and closing the rail, changing tabs and opening history cards leave the sky alone apart
    from an occasional single redraw; resizing redraws it at every step.
- **Document health:** A missing project folder is stated once, as the column's value, rather than
  repeated in the line beneath it.
- **Source:**
  - The project card and the heatmap sit on the same glass surface as the prose instead of a second
    copy of it;
    - the rail and the repository title share one project-count label;
    - the glass tint is one colour;
    - the diagram's straight-line tolerance, every history-card timing and the rail rows' disclosure
      stagger are named with the rest of the theme;
    - the lock artwork's parts and the README table view are private to their files, and four
      helpers only their own type calls — the repository reader's file read, the parser's text
      replacement, the app finder's project check and the store's app picker — are private to their
      types;
    - the size limit on an app's bundle metadata has its own name instead of sharing the README
      limit's;
    - descriptions left over from the blurred-artwork design now describe the current views;
    - the descriptions of the repository reader and the note store name every failure they report;
    - and the folder scan lists a top-level folder only when it is known not to be a link, where
      before a folder whose link status could not be read was listed too.
- **Checks:**
  - `make test-ui` opens a window of the app's own views at the smallest size, clicks the rail's
    toggle and a history card in quick succession, and confirms from captures of that window that
    each ends in the state last asked for.
  - It needs a logged-in session with Screen Recording allowed, so it runs apart from `make test`.
  - A new core check covers history cells that contain ` · ` and the record link, and every throwing
    test helper now says which fixture errors it throws.
  - A failed check now removes the run's temporary folder and preference suite before it ends the
    run, as a passing run always did; before, the folder stayed in the temporary directory.
  - Test values used in more than one place — the store checks' five-second wait and polling
    interval, the unusual path names, the app fixture's permissions and the Git fixture's date — are
    named once instead of repeated.
- **Documentation:** The v2.7 and v2.8 records describe their scope and delivery without naming the
  review that produced them. Two passages that a blank line had broken at a semicolon, on finding a
  new project's app and on the Technologies format, read as one sentence again.
- **Scope:** No notes, storage, Git reading or app-opening behaviour changed; README parsing changed
  only in how a history row's cells become lines.

**Evidence and delivery status**

`make test` passed: 372 core, 41 store, 47 note/presentation, and 12 version checks.

- `make test-ui` passed its 20 checks at the 1,120-point minimum width: the rail ended expanded
  after two quick clicks and collapsed after two more, and a history card opened, closed and opened
  again ended open.
- The same suite built against v4.2 stopped at its first rail check.
- Offscreen renders of the sky took 0.12 ms at 1,320 × 760 and 0.09 ms at 2,560 × 1,440, against
  1.70 and 2.25 ms before, and a capture at rest shows the same clouds.
- `make app` built and signed v4.3/build 43, which passed strict signature verification, reports
  version 4.3 and build 43, and carries a bundle plist identical to the source.
- Installed in place of v4.2 at this project root, where it passed strict signature verification and
  launched showing the repository's name and every project's folder icon; the v4.2 bundle was moved
  to the Trash.
- After the last source change, on 2026-09-28, the app was rebuilt from the final sources, passed
  the same signature and identity checks, launched without a crash report, and replaced the
  installed v4.3.
- Delivered uncommitted and recorded in `81ed071`; published to the public repository on 2026-09-30.

[Back to change history](#change-history)

<a id="v4-2-build-42"></a>

### v4.2 / build 42

- **Recorded date:** 2026-09-27.
- **Diagrams:**
  - Every workflow connector and its arrowhead now stop 5 points short of the rectangles they join,
    instead of touching them.
  - Two nodes that line up, with centers within two points, are joined by one straight line.
  - Before, a node whose width left its center half a point off drew a small sideways jog halfway
    down.
  - Branches and merges keep their shared elbow.
- **Scope:** No README parsing or other layout changed.

**Evidence and delivery status**

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks.

- `make app` built and signed v4.2/build 42, which passed strict signature verification and reports
  version 4.2 and build 42.
- Rendered side by side with v4.1, Project Control's and Local Assistant's workflow diagrams show
  the gaps and straight connectors, with the branch and merge elbows unchanged.
- The running v4.1 app was quit, v4.2 was installed at the project root in its place, and it
  relaunched without a crash report.
- Delivered uncommitted and recorded in `15a404d`; published to the public repository on 2026-09-27.

[Back to change history](#change-history)

<a id="v4-1-build-41"></a>

### v4.1 / build 41

- **Recorded date:** 2026-09-26.
- **Surfaces:**
  - Cards, tables, tab strips and prose planes are dark smoked glass with light text, and the system
    controls on them use the dark appearance.
  - Behind them, the blurred fortress artwork gives way to a sharp sky with pixel-dithered cloud
    banks in the lower corners.
  - The sky is fixed to the window, so closing the rail uncovers the clouds beneath it.
  - The lock screen's artwork is unchanged.
  - With Reduce Transparency, the glass and the sky are solid colours.
- **Layout:**
  - Every screen reads in one centered column about 870 points wide, which re-centers rather than
    stretching when the rail opens or closes.
  - Above the tabs, the title sits directly on the sky: the repository's name over its project count
    and summary, or a project's icon and name over its release and technical scope.
  - The project card keeps the tags and actions on one row above its summary strip.
  - The label lines at the top of each screen become one small pill in the top corner — Last read on
    the repository screen, the README state and folder on a project's — and content scrolled up to
    it passes over it.
- **Details:**
  - Document health, Notes and App each show a small label over a larger value, Document health with
    its green check or amber warning.
  - Technology tags are plain monospaced text after a small square mark instead of pills.
  - Repository README in the rail footer ends in an arrow, because it opens another application.
- **History:**
  - Each history row is a card with a round chevron that opens a darker panel inside the same card.
  - The card grows first, then the panel and its lines fade in from the top, in about half a second;
    closing runs in reverse, and Reduce Motion opens and closes it at once.
- **Rail:**
  - Closing the rail fades its labels in about 0.12 seconds before it narrows in about 0.32; opening
    widens it first and then brings the labels back.
  - This replaces the single 0.78-second motion.
  - The expanded rail is 236 points wide instead of 250, and the project rows keep their two lines.
- **Scope:** No README parsing, notes, storage, Git reading or app-opening behaviour changed.

**Evidence and delivery status**

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks.

- `make app` built and signed v4.1/build 41, which passed strict signature verification and reports
  version 4.1 and build 41.
- It was installed at the project root in place of v4.0, launched on the repository screen showing
  the new design, and quit without a crash report.
- Delivered uncommitted and recorded in `c4b44e5`; publication was not requested.

[Back to change history](#change-history)

<a id="v4-0-build-40"></a>

### v4.0 / build 40

- **Recorded date:** 2026-09-26.
- **Icon:**
  - The Repository Atlas master, `Resources/ProjectControl.png`, keeps the same artwork, cropped to
    the inside of its own bordered tile and clipped to the rounded square macOS draws for app icons,
    824 of 1024 pixels.
  - Before, the folder showed the bordered tile at 936 pixels while the app drew it at the standard
    size, so the two did not match.
  - Every asset-catalog size was regenerated from the new master and `make icons` compiled
    `ProjectControl.icns` from them.
- **Folder:** The project folder's Finder icon, which the rail and project card show, was set from
  the same master.
- **Evidence:**
  - `make test` passed all four suites: 371 core, 41 store, 47 notes and presentation, and 12
    version checks.
  - `make app` built, signed, and promoted v4.0/build 40, which passed strict signature
    verification.
  - Rendered through macOS's own icon lookup, the app's outline matches the folder icon to within
    0.2% of pixels.
  - The app launched from the project root, ran without a crash report, and quit.
  - Delivered uncommitted and recorded in `cf6952a`; the public mirror still carries v3.9.

[Back to change history](#change-history)

<a id="v3-9-build-39"></a>

### v3.9 / build 39

- **Recorded date:** 2026-09-25.
- **Open App:**
  - A choice from the detected-app menu is an automatic candidate, so it must still be one when it
    is opened.
  - A bundle that became a link to an app outside the project after the last check is now refused
    with the invalid-application message instead of being opened and remembered.
  - A manually located app is unaffected.
- **Git reads:**
  - Git runs with a fixed environment: no system or personal Git configuration, lazy fetching
    disabled and no transport.
  - A personal setting, such as one that hides the first commit's paths, can no longer change the
    commit activity or the refresh identity the app reads, and a setting that starts a helper
    program cannot slow the two-second check.
- **Source:**
  - The README parser compiles each of its patterns once and reuses it across every line of every
    README;
    - the project and repository screens share one tab strip;
    - the three test suites share one assertion helper, so a failed notes check reports the same
      FAILED prefix as the others;
    - the history list moved from the window shell to the README content views it belongs with;
    - the documented 620-point minimum window height has a name beside the 1,120-point width;
    - the NUL record prefix that only the tests use moved into the test fixtures;
    - the card's action row no longer nests a second container around the launch controls;
    - the rail no longer applies a clear background;
    - a project's introduction fallback is computed once;
    - and the workflow parser's comment states the sixteen-route limit that v3.5 set.
- **Documentation:** The project structure names `Scripts/`, `history/` and `CONTRIBUTING.md`, and
  `build/` is described as staging and caches, which is all that remains there since v2.9 stopped
  keeping recovery copies.
- **Records:** Every history record's link target is now named after its version and build, or
  after its subject for a documentation or maintenance record, in this README and the August
  archive alike; the repository change log's links follow, so nothing that pointed at a record
  stops resolving.
- **Scope:** No README parsing, navigation, notes or storage behaviour changed; commit activity
  differs only where a personal Git setting used to alter it, and the card's action row and tab
  strips lay out as before.

**Evidence and delivery status**

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks, leaving no
preferences file or temporary folder behind.

- The new store check builds a detected app, replaces it with a link to an app outside the project,
  and requires the launch to be refused without opening anything;
  - the Git fixture check now also sets a personal Git configuration that hides the first commit's
    paths and requires the reader to ignore it.
- `make app` passed and promoted the signed v3.9/build 39 app to the project root; the bundle passed
  strict signature verification and reports version 3.9 and build 39.
- Initially delivered uncommitted; publication was not requested.

[Back to change history](#change-history)

<a id="v3-8-build-38"></a>

### v3.8 / build 38

- **Recorded date:** 2026-09-24.
- **Project count:** The repository row at the top of the rail ends in the number of projects the
  repository holds, registered or not, in the same place and style as each category's count; its
  tooltip and accessibility value read, for example, "8 projects". The collapsed rail keeps only its
  icons.
- **Footer lines:** Under the Project Control name, the version and build sit on one line and the
  refresh cadence on the next, each kept to a single line, instead of one status line that wrapped.

**Evidence and delivery status**

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks, leaving no
preferences file or temporary folder behind.

- `make app` passed and promoted the signed v3.8/build 38 app to the project root; the bundle passed
  strict signature verification and reports version 3.8 and build 38.
- An offscreen render against the live repository showed "8" at the end of the repository row, level
  with the category counts, and the footer's three single lines, reading Project Control, v3.8 (38),
  and Auto-refresh every 2 s; the collapsed rail still shows only icons.
- Initially delivered uncommitted, then committed in `f457f7f` and `bf2535d`, followed by this
  record; publication was not requested.

[Back to change history](#change-history)

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
after the run no `ProjectControlTests-` preferences file or temporary folder remained.

- A probe showed a plain suite name leaving its file behind, even when the file was deleted right
  after a forced flush, since macOS wrote it again later; a path inside the run's folder left
  nothing.
- `make app` passed and promoted the signed v3.7/build 37 app to the project root; the bundle passed
  strict signature verification and reports version 3.7 and build 37.
- Initially delivered uncommitted, then committed in `026a119` and followed by this record;
  publication was not requested.

[Back to change history](#change-history)

<a id="v3-6-build-36"></a>

### v3.6 / build 36

- **Recorded date:** 2026-09-24.
- **Every project folder:**
  - A folder directly inside the repository that holds a `README.md` now appears without a register
    row.
  - Registered projects keep their order, category and tags; unregistered folders follow under
    **Uncategorized**, named after the folder, and their card says the root register does not list
    them.
  - Hidden folders, folders without a README, and folder links the register does not name stay out,
    and a new folder appears within the two-second refresh.
- **Rail toggle:** Clicking the repository's name or its icon collapses or expands the rail, and the
  separate toggle icon is gone. The grey line under the name still opens the repository's overview,
  history and commit activity.
- **Brand:**
  - The Project Control icon and name move from the top of the rail to its foot, below the footer
    buttons, with the version and refresh cadence under the name and **Refresh now** beside them, so
    the brand no longer reads as a navigation row.
  - In the collapsed rail its icon stays on the icon column.
- **Collapsed categories:** A category icon in the collapsed rail opens a list of that category's
  projects; choosing one opens it and keeps the rail collapsed, instead of jumping to the first
  project.
- **Project card:**
  - Every project's card has the same layout.
  - The actions sit on the name's row, where a long name wraps rather than moving them, and the
    version and tags run beneath the name across the card's full width.
  - Below a divider, Document Health, Notes, and App share one full-width strip of equal columns, so
    the card has no empty region at any width.
- **Footer:** **Lock** is renamed **Lock this window**, matching the other footer labels in length.
- **Release label:** A component's version keeps its name — Knowledge Transfer shows
  **Observatory v2.7**, not v2.7 — and a project that declares dated history shows **Dated
  history** instead of **Release not specified**.

**Evidence and delivery status**

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks.

- New core checks cover
  - unregistered folders listed after the register in name order with their README content,
  - hidden folders,
  - folders without a README and folder links left out,
  - an unchanged repository keeping its fingerprint,
  - a new folder or a new README noticed on the next check,
  - a component's release name,
  - and a dated-history declaration read only beside the release or history section.
- The live checks now require every top-level folder with a README to be listed and every listed
  project to supply workflows and history.
- `make app` passed and promoted the signed v3.6/build 36 app to the project root; the bundle passed
  strict signature verification and reports version 3.6 and build 36.
- Offscreen renders against the live repository at 1,440 × 900 and at the 1,120 × 720 minimum showed
  one header layout for every project — DayWright's six tags included —
  - with a long name wrapping at the minimum width,
  - the full-width summary strip,
  - and the brand at the foot of the rail in both rail states;
- a disposable repository showed an unregistered folder under Uncategorized with its note.
- A collapsed category's list, opened by a click and captured from its own popover window, reads in
  system label colors in light and dark appearance and opens at the icon's edge.
- Mouse clicks sent to the rail in an offscreen window collapsed it from the name, expanded it from
  the icon, opened the repository screen from the summary line, and opened a collapsed category's
  list without changing the selection; choosing a project there opened it with the rail still
  collapsed.
- Initially delivered uncommitted, then committed in `382e435` through `3f00ea1`, with this record
  in `86f070c`; publication was not requested.

[Back to change history](#change-history)

<a id="v3-5-build-35"></a>

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

`make test` passed: 354 core, 40 store, 47 note/presentation, and 12 version checks.

- Three new core checks cover titled routes sharing a block, parentheses and semicolons read as
  prose, and a ten-route block shown in full; each fails against the v3.4 parser.
- `make app` passed and promoted the signed v3.5/build 35 app to the project root; the bundle passed
  strict signature verification and reports version 3.5 and build 35.
- Offscreen renders against the live register showed 28 titled routes across seven projects,
  including DayWright's and Knowledge Transfer's, which v3.4 could not draw.
- Initially delivered uncommitted, then committed in `e62a2a8`.

[Back to change history](#change-history)

<a id="v3-4-build-34"></a>

### v3.4 / build 34

- **Recorded date:** 2026-09-23.
- **Rail:**
  - The Project Control icon and name at the top of the rail are a fixed label rather than a button.
  - The collapse control moved to the end of the repository row, and that row now stays pinned above
    the scrolling categories, so the control is always in reach.
  - In the collapsed rail the row shows only the control, on the same icon axis, so the rail can
    always be expanded again.
- **Project card:**
  - The card has two columns.
  - On the left are the icon and name, then the version and technology tags on one line, then Open
    folder, Read README, and Open App.
  - On the right, Document Health and Notes sit level with the name instead of beside the buttons,
    so the card's top-right half is no longer empty and the card is two rows shorter.
- **Fix:**
  - A workflow diagram measured each node as if its label fit on one line, while the label wrapped
    when drawn.
  - A diagram with a wrapped node therefore came out one text line short, and its last node sat on
    the card's bottom edge — Local Assistant's *How local RAG works* and two Career Ledger diagrams.
  - Each label is now measured at the width it draws at.
  - In the same diagrams a branch's connectors bent at different heights when its nodes differed in
    height; they now bend at one shared height between the rows.
- **Scope:** No README parsing, selection, notes, activity, storage, or launching behavior changed.

**Evidence and delivery status**

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.

- `make app` passed and promoted the signed v3.4/build 34 app to the project root; the bundle passed
  strict signature verification and reports version 3.4 and build 34.
- Offscreen renders of the real views against the live register showed the fixed brand label and the
  repository-row toggle in both rail states;
  - the two-column card for Local Assistant at the default size and for DayWright and Python
    Accomplishments at the 1,120 × 620 minimum;
  - and every project's Workflows tab, where the Local Assistant and Career Ledger diagrams that had
    lost their bottom padding keep it and Prospect Copilot's five-line nodes fit.
- Initially delivered uncommitted, then committed in `c28aa06`, `3cb7998` and `efab612`, with this
  record in `00f19de`.

[Back to change history](#change-history)

<a id="v3-3-build-33"></a>

### v3.3 / build 33

- **Recorded date:** 2026-09-23.
- **Rail:**
  - Categories are quiet section headers — a disclosure chevron, the category name, and its project
    count — instead of rows with their own icons, so the projects are what stands out.
  - Each project row shows its icon, name, note marker, and technical scope.
  - At the default window size the rail now reaches the third category before scrolling, where it
    previously showed only the first.
  - The collapsed rail keeps its category markers on the same icon axis.
- **Tags:** A project's technology tags moved from its rail row to its detail card, under the
  version. Every tag the root register documents still appears.
- **Footer:**
  - Three plain buttons say what they do: **Repository README**, **Change repository…**, and
    **Lock**.
  - The Repository menu, which looked like a button but opened a two-item menu, is gone.
  - **Refresh now** is the arrow at the end of the status line, which reads *Auto-refresh every 2 s*
    and the running version.
  - `Command-O` and `Command-R` work as before.
- **Detail:** The header strip above every screen, which repeated the Project Control icon and name
  and the repository name, is removed. The brand appears once, at the top of the rail, and the
  repository once, as the rail's first row.
- **Scope:** No README parsing, selection, notes, activity, storage, or launching behavior changed.

**Evidence and delivery status**

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.

- `make app` passed and promoted the signed v3.3/build 33 app to the project root; the bundle passed
  strict signature verification, reports version 3.3 and build 33, and opened its window.
- Offscreen renders of the real `ControlWindow` against the live register showed the expanded rail
  on a project and on the repository screen, the collapsed rail, and the 1,120 × 620 minimum window,
  where every category header stays on one line and the project card's tags fit in one row.
- Initially delivered uncommitted, then committed in `3029a80`.

[Back to change history](#change-history)

<a id="v3-2-build-32"></a>

### v3.2 / build 32

- **Recorded date:** 2026-09-23.
- **Icons:**
  - `ProjectIcon` shows each project folder's own Finder icon in the sidebar row, the project
    header, and the commit-activity hover.
  - Previously a project showed artwork only when it had a project-root app, and that artwork was
    the app's icon; the other five projects showed a neutral symbol.
  - Every registered project now shows its own folder icon.
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
strict signature verification and reports version 3.2 and build 32.

- The later test-only change leaves every app source unchanged, so that bundle still matches.
- An offscreen render of the real `ProjectIcon` against the live register showed all eight projects
  with their folder icons.
- The complete `make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.
- Publication was not requested.

[Back to change history](#change-history)

<a id="v3-1-build-31"></a>

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
strict signature verification.

- Its packaged 256-pixel icon representation matches the catalog pixels.
- The 40 store checks and 12 version checks passed.
- The complete `make test` target remains blocked by pre-existing live-document assertions that
  still expect the older six-project register and earlier prose grouping while the current workspace
  carries unrelated documentation changes.
- Publication was not requested.

[Back to change history](#change-history)

<a id="soucieux-proprietary-license"></a>

### Documentation

- **Recorded date:** 2026-09-13.
- Added the approved Soucieux proprietary-software notice, reserving rights in original project
  materials while retaining third-party license terms.
- Documentation only; application behavior, v3.0/build 30 source, the signed local app, deployment,
  and publication status are unchanged.

[Back to change history](#change-history)

<a id="v3-0-build-30"></a>

### v3.0 / build 30

- **Recorded date:** 2026-09-12.
- **Register:**
  - the root register gained a second table for work carried on top of someone else's project, whose first column links to a public repository rather than a folder here.
  - Every row in the Projects section is read as a register row, and a row whose link is not a direct child folder was refused as unsafe — which made the entire repository unreadable, not just that row.
  - A row whose link carries a URL scheme is now skipped: there is no folder here to open, so it is documentation rather than a project the app can show.
  - A relative link that escapes the repository is still refused, and that protection keeps its check.
- **Scope:** one guard in `RepositoryReader` and one pattern in `ControlConstants`. No interface, storage, or history behavior changed.
- **Checks:**
  - `make check-version` accepts the v3.0/build 30 pair; 434 native checks passed (341 core, 40 store, 41 note/presentation, 12 version), two of them new — an external row is skipped while the folder-based rows around it still load, and an escaping relative link is still refused.
  - The live register, which now carries the forked-project table, parses again; before the fix its read threw and the smoke check failed.

**Evidence and delivery status**

v3.0/build 30 source; `make app` rebuilt and promoted the bundle to the project root, where it reports v3.0 build 30 with a valid strict signature and left no bundle behind; the promoted app launched and quit cleanly; staging removed. Initially delivered uncommitted.

[Back to change history](#change-history)

<a id="v2-9-build-29"></a>

### v2.9 / build 29

- **Recorded date:** 2026-09-12.
- **Promotion:**
  - `make app` moved the installed app into a `build/previous.*` folder before putting the new one in place, and left it there for good.
  - Every release since v0.2 therefore accumulated a copy of the one it replaced.
  - The step is still transactional — the existing app is set aside and put back if the move fails — but the set-aside copy is now deleted as soon as the new bundle is in place.
  - The project keeps one delivered bundle; an earlier version is rebuilt from its commit.
- **Scope:** the build recipe only. No application source changed, so the interface, parsing, storage and launch behavior are those of v2.8.
- **Documentation:** the README, the contributor guide and the scoped instructions no longer describe retained recoveries, and the records that named a `build/previous.*` path as recoverable no longer claim one exists.

**Evidence and delivery status**

- v2.9/build 29 source;
- `make check-version` accepts the pair;
- 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version);
- `make app` rebuilt and promoted the bundle to the project root, where it reports v2.9 build 29, carries a valid strict signature and an arm64 executable, and left no `build/previous.*` folder behind — the behaviour this release changes.
- The promoted app launched and quit cleanly.
- Disposable staging was removed afterwards.
- Initially delivered uncommitted and recorded in `687153d`.

[Back to change history](#change-history)

<a id="standalone-contributor-guide"></a>

### Documentation — 2026-09-12

- **Guide:**
  - `CONTRIBUTING.md` now carries the project-facing rules that used to live only in the private repository instructions: what the app may read and do, the presentation rules for tags and the glass direction, the checks a change must pass, and the version and build policy.
  - The private scoped instructions remain authoritative for repository-wide workflow and automation.
- **Links:**
  - the README's four links into the parent `AGENTS.md` now point at that guide or state the rule directly, so every link resolves from the project folder alone.
  - The one remaining parent path sits inside a fenced example of a registered project's README, where Markdown renders it as literal text rather than a link.
- **Numbering:** the change-history declaration links to the guide's own policy section, matching the two projects already exported this way. The policy itself is unchanged: `v<major>.<minor>`, build `major x 10 + minor`, both advancing for every change except a documentation-only one.
- **Status:** Documentation only. Source, the signed v2.8 build 28 application, and its delivery state are unchanged, and no version or build advances for this change.

[Back to change history](#change-history)

<a id="v2-8-build-28"></a>

### v2.8 / build 28

- **Recorded date:** 2026-09-11; work began 2026-09-10.

- **Scope:** Source, tests, scripts and documentation across all of `Project Control/`.

- **Interface:**
  - Project icons and the project screen no longer read and parse bundle metadata on every view
    update.
  - `ApplicationLocator` now separates the canonical identity recheck from the bounded `Info.plist`
    read, so icon lookup keeps its documented identity check without the file read; the project
    screen resolves its launch target once per update instead of three times.
  - The project header again centers its icon on the project-name line, with the version beneath the
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
- **Change history:**
  - Each record now states its change once.
  - Repeated restatements were merged into one list, v2.7 delivery text was removed from the v2.6
    record, and fifteen duplicated evidence blocks were merged.
  - The v2.6, v2.1 and v0.8 records had retold other releases; they now keep only their own work,
    and details found only in a retelling moved to the record they describe.
  - The out-of-date "Current implementation" snapshot inside the v0.8 record was removed; its facts
    remain in the release records and this guide.
  - Every distinct fact, figure, Git reference, date and delivery status was retained.
- **Links:** The Project Control tag-policy link now resolves to the repository instructions instead
  of an empty legacy anchor. Removed 95 link anchors that nothing pointed to, including eight left
  behind when their sections moved to the contributor instructions. The development-checks anchor
  now leads to the change history.

- **Status:**
  - Source advances to v2.8/build 28 because this batch changes application source.
  - It was initially delivered uncommitted, then committed and landed on `main` on 2026-09-11.
  - The signed local app was rebuilt from `main` at v2.8/build 28, replacing the v2.7/build-27 app.
  - The project keeps one delivered bundle; an earlier build is rebuilt from its commit rather than
    retained.

**Evidence and delivery status**

- v2.8/build 28 source;
- 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version);
- a v2.8/build-28 bundle built from the final source in an isolated worktree passed strict signing, exact source-metadata, arm64 and ten-size icon checks and was then removed with its build folder;
- offscreen renders of all six project headers, with real and fallback icons and wrapped names, confirmed that the icon centers on the project name;
- source commits `44c8690`, `1cd3262`, `973d721`, `863fbb2`, `b6b584f`, `f594b22`, `ad2a9d8`, `befa385`, `8e90c5c`;
- the signed v2.8/build-28 app built from `main` passed strict signing, exact source-metadata, arm64, ten-size icon and project-root launch checks;
- initially delivered uncommitted

[Back to change history](#change-history)

<a id="readme-organization"></a>

### README organization — 2026-09-06

- **Structure:** Put purpose, capabilities, setup, architecture, and workflows before history.
- **History:** Merge matching repository-origin records into the owning change; preserve unique detail, evidence, and older links.
- **Ownership:** Keep user documentation here; route scoped contributor rules through root AGENTS.
- **Status:** Documentation changes only; initially delivered uncommitted and recorded in `3a5bd2c`. Existing application versions, artifacts, and deployment state are unchanged.

[Back to change history](#change-history)

<a id="readability-maintenance"></a>

### Documentation readability

- **Recorded date:** 2026-09-06.

- Reorganized long paragraphs and table cells without dropping details; consolidated imported history tables into indexes linked to complete readable records.
- Preserved existing destinations and README section mappings.
- Documentation only; no application or release artifact changed.

**Evidence and delivery status**

Local documentation changes; initially delivered uncommitted and recorded in this documentation commit.

[Back to change history](#change-history)

<a id="project-descriptions-moved"></a>

### Documentation

- **Recorded date:** 2026-09-06.

- Moved complete project descriptions, register details, and repository-origin history into this README; retained existing content, dates, release/build identifiers, Git evidence, and app-content mappings.
- Project guardrails now load through the root instructions only for this project.
- This is documentation maintenance; no application code, build, release, or deployment changed.

**Evidence and delivery status**

Local documentation update; initially delivered uncommitted and recorded in `3a5bd2c`

[Back to change history](#change-history)

<a id="build-folder-cleanup"></a>

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

<a id="v2-7-build-27"></a>

### v2.7 / build 27

- **Recorded date:** 2026-09-05.

- At delivery, the source and signed local app were **v2.7 (build 27)**; the source corrections below are committed locally, and source and documentation were uncommitted at initial delivery.

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
- Live inspection confirmed wrapping tags at the minimum width, named collapsed navigation, centered workflows, horizontal access to all four branches in a disposable wide-graph fixture, activity distributions and threshold descriptions, and empty/multiline note-editor states with Escape cancellation.
  - The test draft was not saved and the original repository selection was restored.
  - Native button accessibility activation passed; Tab focus traversal was not confirmed under the current macOS keyboard settings.
- The user subsequently authorized removal of all build-folder outputs, including the previously preserved v2.6/build-26 recovery.
  - The signed v2.7 app at the project root retains its exact delivered bytes and valid strict signature, and no build-folder recovery remains; the older binaries were deleted locally, and generated intermediates can be rebuilt.
  - Source code, editable icon masters, and audit evidence were preserved.
- Supplemental checks validated the SVG references, PNG decoding, and all ten packaged icon sizes; the source and packaged artwork were also visually inspected. Historical delivery notes below retain their original evidence.

**Evidence and delivery status**

Source `f953d60`, `6b87a14`, `fbbd132`, `7f62af0`, `56d4463`, `b1ea271`, `cb086d6`, `659d737`, `a15a44c`, `f5071b9`; initially delivered uncommitted; 432 native checks and optimized packaging passed; signed project-root app; live checks and their limits recorded above and in Project details

[Back to change history](#change-history)

<a id="superseded-candidates-removed"></a>

### Maintenance

- **Recorded date:** 2026-09-04.

- Removed the three superseded v2.6/build-26 candidate recoveries from `build/previous.FdBli0`, `build/previous.GtF7qQ`, and `build/previous.uqRg60`.
- At that time, the signed v2.6/build-26 project-root app and ten distinct-version recovery bundles were retained; every build-folder recovery was subsequently removed on September 6.
- Added the root README's exact new-project registration procedure.
- No application source, version, build, or behavior changed.

**Evidence and delivery status**

Local cleanup; registration guide `e9333c24`; this history reconciliation

[Back to change history](#change-history)

<a id="sidebar-reveal-width"></a>

### Maintenance

- **Recorded date:** 2026-09-03.

- Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout, and removed the top-slide transition from project rows.

- Existing category/footer icons retain their leading axis and animate from their current layout; new project rows fade in.
- Sidebar destinations, category disclosure, final expanded/collapsed contents, and Reduce Motion behavior are unchanged.

- The optimized build, strict package checks, minimum-width header, and collapsed sidebar inspection passed.
- Formal verification repeated complete compilation and strict packaging.
- The Mac locked before the corrected expansion path and remaining editor interactions could be checked.

**Evidence and delivery status**

Source `722fe5e`; project record `47b24f4`; signed project-root app; live expansion/editor checks pending

[Back to change history](#change-history)

</details>

### Earlier history

Older records are archived by period, newest first. Each archive keeps the same table
and full records; the count after a link is how many records it holds.

- **Months** — [September 2026](history/2026-09.md) (9) · [August 2026](history/2026-08.md) (13)

---

<!-- project-control:section=ignore -->
## 🔒 License

**PROPRIETARY SOFTWARE — ALL RIGHTS RESERVED**

Copyright © 2024–2026 Soucieux. All rights reserved.

The original source code, documentation, and other original materials in this repository are proprietary and are not open-source software.

Except where applicable law expressly permits otherwise, no permission is granted to copy, modify, publish, distribute, sublicense, sell, deploy, or create derivative works from these materials, in whole or in part, without prior written authorization from the copyright owner.

Access to this repository does not grant a license. Third-party software and materials remain subject to their respective license terms.

*This private project is not open for external contributions.*
