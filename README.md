# Project Control

![Platform](https://img.shields.io/badge/Platform-macOS%2014%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5-orange) ![Release](https://img.shields.io/badge/Release-v4.9%20build%2049-brightgreen) ![Reads](https://img.shields.io/badge/Reads-Repository%20READMEs-9f9f9f)

[Quick start](#quick-start) · [Architecture](#architecture) · [Change history](#change-history)

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
├── CHANGELOG.md        # Complete change history
├── Makefile            # Local build, focused checks, launch
├── CONTRIBUTING.md     # Project-facing contribution and numbering rules
├── Project Control.app # Latest completed app; ignored by Git
└── build/              # Staging and caches; ignored by Git
```

<!-- project-control:section=release -->
## Current release

**v4.9 (build 49)** in source and in the signed local app. [Change and delivery evidence](CHANGELOG.md#v4-9-build-49).

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

One record per change; complete details and evidence are in [CHANGELOG.md](CHANGELOG.md). Older work dates and Git checkpoints remain labelled when they differ.

**Historical status:** Each record describes its own delivery checkpoint. Later records supersede older pending work or recovery locations; historical checks are not new validation.

| Record | Date | Highlights | Details |
|---|---|---|---|
| Documentation | 2026-10-06 | <ul><li><strong>Layout:</strong> The line of section links under the title now holds three quick links, Quick start, Architecture and Change history, in place of one for every section; the outline of the whole README is the one GitHub, Obsidian and Project Control provide.</li></ul> | [Full record](CHANGELOG.md#three-quick-links) |
| v4.9 / build 49 | 2026-10-06 | <ul><li><strong>Checks:</strong> The live architecture checks expect the Build & Delivery category that Local Assistant and Prospect Copilot now carry, so <code>make test</code> passes again.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing checks; installed in place of v4.8.</li></ul> | [Full record](CHANGELOG.md#v4-9-build-49) |
| Documentation | 2026-10-06 | <ul><li><strong>History:</strong> The complete change history now lives in <code>CHANGELOG.md</code>, one entry per change with its summary, what changed, what was checked and how it was delivered; the README table keeps the newest ten rows and opens each entry from its Details cell.</li></ul> | [Full record](CHANGELOG.md#changelog) |
| v4.8 / build 48 | 2026-10-05 | <ul><li><strong>Checks:</strong> The live architecture checks expect Career Ledger's four category headings, which its README now groups its table under, so <code>make test</code> passes again.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing checks; installed in place of v4.7.</li></ul> | [Full record](CHANGELOG.md#v4-8-build-48) |
| Documentation | 2026-10-05 | <ul><li><strong>Structure:</strong> Sections follow the order and names every project README now shares, under a contents line; sections were renamed and moved, and no wording was removed.</li></ul> | [Full record](CHANGELOG.md#readme-skeleton) |
| v4.7 / build 47 | 2026-10-05 | <ul><li><strong>Checks:</strong> The live architecture checks expect Meta Search Engine's four category headings, so <code>make test</code> passes again.</li><li><strong>Coverage:</strong> They also name every architecture row and the main technologies of Career Ledger, DayWright and Meta Search Engine.</li><li><strong>Evidence:</strong> Passed all four check suites and the signing checks; installed in place of v4.6 and launched.</li></ul> | [Full record](CHANGELOG.md#v4-7-build-47) |
| Documentation | 2026-10-05 | <ul><li><strong>Readability:</strong> Long paragraphs, bullets and table cells are now short leads with sub-points, one fact each; no detail was removed.</li></ul> | [Full record](CHANGELOG.md#readme-structure) |
| v4.6 / build 46 | 2026-10-01 | <ul><li><strong>Register:</strong> The root register names a project's technical scope Platform, and the app reads it for the sidebar and title; a register still labelled Technical scope shows the same.</li><li><strong>Contract:</strong> The README content contract uses the register's one-word labels and places an AI item after Category.</li></ul> | [Full record](CHANGELOG.md#v4-6-build-46) |
| v4.5 / build 45 | 2026-10-01 | <ul><li><strong>Tabs:</strong> On every screen the content sits 12 points below the tabs, so the two read as one group: half the repository screen's former 24 points, and a project's 8 widened to match.</li><li><strong>Evidence:</strong> Passed the interface, version and signing checks; installed in place of v4.4 and launched.</li></ul> | [Full record](CHANGELOG.md#v4-5-build-45) |
| v4.4 / build 44 | 2026-09-28 | <ul><li><strong>Icons:</strong> Each project folder's icon is fetched once and kept until the folder or its custom icon changes; checking that it is unchanged costs about an eighth of fetching a custom icon again.</li><li><strong>Architecture and Models:</strong> Both tabs come from one reading of a project's architecture sections, so reading them for all eight projects here takes about 10 to 11 ms instead of 16 to 18 ms, with the same content.</li><li><strong>Checks:</strong> <code>make test-ui</code> also checks the icon cache.</li><li><strong>Evidence:</strong> Passed all five check suites and the signing checks; installed in place of v4.3 and launched.</li></ul> | [Full record](CHANGELOG.md#v4-4-build-44) |
---

<!-- project-control:section=ignore -->
## 🔒 License

**PROPRIETARY SOFTWARE — ALL RIGHTS RESERVED**

Copyright © 2024–2026 Soucieux. All rights reserved.

The original source code, documentation, and other original materials in this repository are proprietary and are not open-source software.

Except where applicable law expressly permits otherwise, no permission is granted to copy, modify, publish, distribute, sublicense, sell, deploy, or create derivative works from these materials, in whole or in part, without prior written authorization from the copyright owner.

Access to this repository does not grant a license. Third-party software and materials remain subject to their respective license terms.

*This private project is not open for external contributions.*
