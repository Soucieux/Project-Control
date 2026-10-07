# Project Control changelog

Every change to Project Control, newest first, in one shape: the summary from the history table, then what changed, what was checked and how it was delivered. The README's Change history table lists the newest 10 and links here.

<a id="v5-0-build-50"></a>

## v5.0 / build 50 — 2026-10-07

- **History:** The History tab reads the changelog beside each README: every entry is a card with its summary and its subsections, under a history strip drawn natively; the README table stands in for a project without a changelog.
- **Evidence:** Passed the core, store, notes and version suites and the signing checks; installed in place of v4.9.

### Added

- **Changelog entries:** `ChangelogParser` splits `CHANGELOG.md` at its second-level headings outside fenced samples, reading each entry's title, date, summary bullets and the lines of its Added, Changed, Fixed, Removed, Checked and Delivered subsections.
- **History strip:** the tab opens with the strip drawn natively from the entries.
  - A summary of the span, the total, the version range and the release count, then one shaded cell per period, years before the last twelve months and then each month.
  - A release month carries its release count in an amber pill and its latest version beneath.
  - The window counts back from the newest entry, as the repository's generated strip does, so the view and the image agree.
- **Cards:** each entry's card opens to its summary lines and then each subsection's name and lines; a README row's card reads as before.

### Changed

- **Reader:** `RepositoryReader` reads the changelog beside each README and the root one, bounded like a README, and fingerprints them, so an edited changelog refreshes the screens.
- **Screens:** the project and repository History tabs show the changelog's entries when there is one and the README table otherwise.
- **Routes:** the README documents the project-history route, so the live check expects five routes.

### Checked

- `make test`, built into a temporary folder outside the project, passed 459 core, 41 store, 50 notes and presentation, and 12 version checks; the core suite gained the changelog fixture, strip, record and live checks.
- `make test-ui`, run from the owner's Terminal on 2026-10-07, passed 30 interface checks, the history checks now finding the first card below the strip; from the delivery session it could not capture the test window, which lacked Screen Recording.

### Delivered

- `make app` built and signed v5.0 build 50, which passed strict signature verification and reports version 5.0 and build 50; it replaced v4.9 at the project root of the main checkout.

<a id="history-strip"></a>

## History strip — 2026-10-06

- **Changelog:** The README's Change history opens with a history strip, `CHANGELOG.svg`, drawn from the changelog: the entries of every period as shaded cells, release months marked, and the span, total and version range beside them.

### Added

- **Strip:** a light card under the Change history heading shows how the entries spread over time.
  - One cell per period: the years before the last twelve months, then each month, shaded by how many entries it holds; an empty cell is a quiet month.
  - An orange pill under a month with releases carries how many it had, its latest version beneath, and a summary gives the span, the total and the version range.
- **Alternative text:** the image line states the span, the total, the busiest period, the longest quiet stretch and the version range, so the strip reads without the picture.

### Changed

- **Structure:** `CHANGELOG.svg` joins the structure tree.
- **Scope:** Documentation only; the strip and its image line are generated, never edited by hand.

<a id="three-quick-links"></a>

## Three quick links — 2026-10-06

- **Layout:** The line of section links under the title now holds three quick links, Quick start, Architecture and Change history, in place of one for every section; the outline of the whole README is the one GitHub, Obsidian and Project Control provide.

### Changed

- **Why:** the line had grown to as many as fourteen links, drew the eye without saying where each led, and duplicated the outline every reader already has.
- **Line:** `Quick start · Architecture · Change history`, the same three in every project README: get going, see how it is built, see what changed.
- **Scope:** Documentation only.

<a id="v4-9-build-49"></a>

## v4.9 / build 49 — 2026-10-06

- **Checks:** The live architecture checks expect the Build & Delivery category that Local Assistant and Prospect Copilot now carry, so `make test` passes again.
- **Evidence:** Passed all four check suites and the signing checks; installed in place of v4.8.

### Changed

- **Category check:** The core suite compares each project's architecture category headings with an
  expected list per project.
  - Local Assistant and Prospect Copilot gained a Build & Delivery table when their READMEs were
    checked against their source, so their five expected headings became six and `make test` stopped
    in the core suite.
  - Both lists now end with Build & Delivery.
- **App:** No source or interface change; the version advances because the checks changed.

### Checked

- `make test`, built into a temporary folder outside the project, passed the core, store, notes and
  presentation, and version checks.

### Delivered

- `make app` built and signed v4.9 build 49, which passed strict signature verification and reports
  version 4.9 and build 49; it replaced v4.8 at the project root of the main checkout.

<a id="changelog"></a>

## Documentation — 2026-10-06

- **History:** The complete change history now lives in `CHANGELOG.md`, one entry per change with its summary, what changed, what was checked and how it was delivered; the README table keeps the newest ten rows and opens each entry from its Details cell.

### Changed

- **Why:** the README carried every record's details in one collapsed block, with older records in an archive folder, so a reader opened the table and then searched the block, and the details had no fixed shape.
- **Changelog:** `CHANGELOG.md` holds every record this project ever kept, newest first. An entry is its anchor, a dated heading, its summary bullets, then only the subsections it needs: Added, Changed, Fixed, Removed, Checked, Delivered.
- **Migration:** each earlier record's labelled bullets sit under Changed, its evidence under Checked and its status under Delivered; a record over the block limit became a lead with sub-points. Every statement was carried over; none was shortened.
- **Archives:** the two archived period files under `history/` were folded into the changelog in the same shape and the folder was removed.
- **README:** the Change history table keeps the newest ten rows, each Details cell opening its entry; the details block and the earlier-history list are gone, and every link into a record now reaches the changelog.
- **Scope:** Documentation only.

<a id="v4-8-build-48"></a>

## v4.8 / build 48 — 2026-10-05

- **Checks:** The live architecture checks expect Career Ledger's four category headings, which its README now groups its table under, so `make test` passes again.
- **Evidence:** Passed all four check suites and the signing checks; installed in place of v4.7.

### Changed

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

### Checked

- `make test`, built into a temporary folder outside the project, passed 445 core, 41 store, 50
  notes and presentation, and 12 version checks.

### Delivered

- `make app` built and signed v4.8 build 48, which passed strict signature verification and reports
  version 4.8 and build 48; it replaced v4.7 at the project root and launched.
- Delivered uncommitted on 2026-10-05, then committed as `c0963b8`, with this citation after it.

<a id="readme-skeleton"></a>

## Documentation — 2026-10-05

- **Structure:** Sections follow the order and names every project README now shares, under a contents line; sections were renamed and moved, and no wording was removed.

### Changed

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

<a id="v4-7-build-47"></a>

## v4.7 / build 47 — 2026-10-05

- **Checks:** The live architecture checks expect Meta Search Engine's four category headings, so `make test` passes again.
- **Coverage:** They also name every architecture row and the main technologies of Career Ledger, DayWright and Meta Search Engine.
- **Evidence:** Passed all four check suites and the signing checks; installed in place of v4.6 and launched.

### Changed

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

### Checked

`make test`, built into a temporary folder outside the project, passed 441 core checks, 59 of them
new, with 41 store, 50 notes and presentation, and 12 version checks.

- `make app` built and signed v4.7 build 47, which passed strict signature verification and reports
  version 4.7 and build 47.

### Delivered

- Installed in place of v4.6 at this project root on 2026-10-05:
  - the installed app passed strict signature verification,
  - reports version 4.7 and build 47,
  - carries the built binary byte for byte,
  - and launched.
- The v4.6 bundle was kept in the ignored `build/` folder until then, then moved to the Trash after
  approval.
- Delivered uncommitted and recorded in `a137dc0`; published to the public repository on
  2026-10-05.

<a id="readme-structure"></a>

## Documentation — 2026-10-05

- **Readability:** Long paragraphs, bullets and table cells are now short leads with sub-points, one fact each; no detail was removed.

### Changed

- **Why:** many records and some guidance ran as bullets or paragraphs of 50 to 100 words, which hid
  the separate facts inside them.
- **Layout:** every paragraph, bullet and table cell over 50 words is now a short lead with
  sub-points, one fact each. The wording was moved, not rewritten.
- **Unchanged:** every section, heading, link, anchor, table row, diagram, number and identifier.
- **Scope:** Documentation only; no source, version or app changed.

### Checked

- **Evidence:** compared with the previous version, no word is removed, and the headings, anchors,
  links, code spans, numbers and fenced samples are identical. The README layout, link and history
  checks pass.

<a id="v4-6-build-46"></a>

## v4.6 / build 46 — 2026-10-01

- **Register:** The root register names a project's technical scope Platform, and the app reads it for the sidebar and title; a register still labelled Technical scope shows the same.
- **Contract:** The README content contract uses the register's one-word labels and places an AI item after Category.

### Changed

- **Register:** The root register now gives every item a one-word label, and a project's technical
  scope is labelled **Platform**. The app reads **Platform** for the sidebar row and the project's
  title, and still reads **Technical scope** from an older label or column, so an older register
  shows the same.
- **Contract:** The README content contract's examples and rules use the new labels — **Updated**,
  **Repository**, **Category**, **Platform**, and **Technologies** — and say that the **AI** item
  after **Category**, `N/A` for a project without AI, reads as part of the project's summary.

### Checked

- **Checks:** A new core check reads a row still labelled **Technical scope**.

`make test` passed 373 core checks, the new one included, with 41 store, 47 notes and presentation,
and 12 version checks; `make test-core` passed its 373 again once the live register used the new
labels.

- `make app` built and signed v4.6 build 46, which passed strict signature verification.

### Delivered

- Installed in place of v4.5 at this project root on 2026-10-01:
  - the installed app passed strict signature verification,
  - reports version 4.6 and build 46,
  - carries the built binary byte for byte,
  - and launched and quit cleanly, showing each project's platform from the main checkout's
    register, which still used the older label at the time.
- The v4.5 bundle was kept in the ignored `build/` folder until then, then moved to the Trash after
  approval.
- Delivered uncommitted and recorded in `4f40a89`; published to the public repository on 2026-10-01.

<a id="v4-5-build-45"></a>

## v4.5 / build 45 — 2026-10-01

- **Tabs:** On every screen the content sits 12 points below the tabs, so the two read as one group: half the repository screen's former 24 points, and a project's 8 widened to match.
- **Evidence:** Passed the interface, version and signing checks; installed in place of v4.4 and launched.

### Changed

- **Tabs:**
  - On the repository screen the tab strip and the content below it were 24 points apart, the same
    gap that separates the title from the tabs, so the content read as a block of its own.
  - They now sit 12 points apart, half that gap, so the content reads as the tabs' own.
  - A project's screen held its tabs and content 8 points apart; it now uses the same 12 points, and
    both screens read the gap from one shared theme value, so they cannot drift apart.
- **Scope:** Only that gap changed; the titles, the project card, the tabs and their content are as
  before.

### Checked

`make app` built and signed v4.5/build 45, which passed the version check and strict signature
verification and carries a bundle plist identical to the source.

- `make test-ui` passed its 27 checks, including the history-card checks, which find the first card
  below the tabs at its new height.
- In captures of the app's views at 1×, the sky between the tab strip and the content below it
  measures 12 pixels on the repository screen and on a project's screen.
- The v4.4 bundle and the first v4.5 build were each kept in the ignored `build/` folder until their
  replacement passed those checks, then proposed for removal.

### Delivered

- Installed in place of v4.4 at this project root on 2026-10-01; after the project screen's gap was
  matched the same day, the app was rebuilt and installed again in place of the first v4.5 build.
- The installed app passed strict signature verification, reports version 4.5 and build 45, and
  launched without a crash report showing the 12-point gap.
- Delivered uncommitted and recorded in `7734cfb`; published to the public repository on 2026-10-01.

<a id="v4-4-build-44"></a>

## v4.4 / build 44 — 2026-09-28

- **Icons:** Each project folder's icon is fetched once and kept until the folder or its custom icon changes; checking that it is unchanged costs about an eighth of fetching a custom icon again.
- **Architecture and Models:** Both tabs come from one reading of a project's architecture sections, so reading them for all eight projects here takes about 10 to 11 ms instead of 16 to 18 ms, with the same content.
- **Checks:** `make test-ui` also checks the icon cache.
- **Evidence:** Passed all five check suites and the signing checks; installed in place of v4.3 and launched.

### Changed

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
- **Scope:** No README content the app shows, notes, storage, Git reading or app-opening behaviour
  changed.

### Checked

- **Checks:**
  - `make test-ui` also sets, replaces and removes a disposable folder's custom icon, changes the
    icon file alone and gives the folder a Finder colour label, and confirms the icon is fetched
    again after each change and reused while nothing changes.
  - The parser checks read both tabs through the one reading.

`make test` passed: 372 core, 41 store, 47 note/presentation, and 12 version checks.

- `make test-ui` passed its 27 checks, 7 of them on the icon cache; the same checks fail against a
  cache keyed on the folder's modification time alone, which misses a change to the icon file alone,
  and against no cache.
- The Architecture and Models content of all eight projects in this repository, 106 blocks, was
  identical before and after the change.
- `make app` built and signed v4.4/build 44, which passed strict signature verification, reports
  version 4.4 and build 44, and carries a bundle plist identical to the source.

### Delivered

- Installed in place of v4.3 at this project root on 2026-09-28, where it passed strict signature
  verification and launched without a crash report, showing every project's folder icon in the rail;
  - the v4.3 bundle it replaced was kept in the ignored `build/` folder until v4.4 passed those
    checks, then proposed for removal.
- On 2026-09-30, after the last changes, which touched only comments in the app's sources,
  `make app` produced the same executable byte for byte, and the installed app passed the same checks
  again and launched showing every project's folder icon.
- Delivered uncommitted and recorded in `f5c5b4d`, `49c8bc7` and `ab5d55d`; published to the public
  repository on 2026-09-30.

<a id="v4-3-build-43"></a>

## v4.3 / build 43 — 2026-09-27

- **Fixes:** Two quick clicks on the rail's toggle or on a history card's chevron now end in the state last asked for, and a closing history card fades its lines out together instead of cutting them off.
- **History cards:** An opened card shows each description cell of its README row whole, without the record link's label.
- **Commit activity:** The heatmap has one full-size layout, which fills the reading column at every window size.
- **Sky:** The clouds keep their pixels while the window is resized, and each resize redraw costs about a tenth of a millisecond.
- **Document health:** A missing folder is stated once.
- **Checks:** `make test-ui` checks the rail and history cards in a window of the app's own views, and a failed check no longer leaves its temporary folder behind.
- **Evidence:** Passed all five check suites and the signing checks; installed in place of v4.2 and launched.

### Changed

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
- **Documentation:** The v2.7 and v2.8 records describe their scope and delivery without naming the
  review that produced them. Two passages that a blank line had broken at a semicolon, on finding a
  new project's app and on the Technologies format, read as one sentence again.
- **Scope:** No notes, storage, Git reading or app-opening behaviour changed; README parsing changed
  only in how a history row's cells become lines.

### Checked

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

`make test` passed: 372 core, 41 store, 47 note/presentation, and 12 version checks.

- `make test-ui` passed its 20 checks at the 1,120-point minimum width: the rail ended expanded
  after two quick clicks and collapsed after two more, and a history card opened, closed and opened
  again ended open.
- The same suite built against v4.2 stopped at its first rail check.
- Offscreen renders of the sky took 0.12 ms at 1,320 × 760 and 0.09 ms at 2,560 × 1,440, against
  1.70 and 2.25 ms before, and a capture at rest shows the same clouds.
- `make app` built and signed v4.3/build 43, which passed strict signature verification, reports
  version 4.3 and build 43, and carries a bundle plist identical to the source.

### Delivered

- Installed in place of v4.2 at this project root, where it passed strict signature verification and
  launched showing the repository's name and every project's folder icon; the v4.2 bundle was moved
  to the Trash.
- After the last source change, on 2026-09-28, the app was rebuilt from the final sources, passed
  the same signature and identity checks, launched without a crash report, and replaced the
  installed v4.3.
- Delivered uncommitted and recorded in `81ed071`; published to the public repository on 2026-09-30.

<a id="v4-2-build-42"></a>

## v4.2 / build 42 — 2026-09-27

- **Diagrams:** Every workflow arrow stops a small gap short of the rectangles it joins, and nodes that line up are joined by one straight line instead of one with a slight sideways jog.
- **Evidence:** Passed all four check suites and the signing and launch checks.

### Changed

- **Diagrams:**
  - Every workflow connector and its arrowhead now stop 5 points short of the rectangles they join,
    instead of touching them.
  - Two nodes that line up, with centers within two points, are joined by one straight line.
  - Before, a node whose width left its center half a point off drew a small sideways jog halfway
    down.
  - Branches and merges keep their shared elbow.
- **Scope:** No README parsing or other layout changed.

### Checked

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks.

- `make app` built and signed v4.2/build 42, which passed strict signature verification and reports
  version 4.2 and build 42.
- Rendered side by side with v4.1, Project Control's and Local Assistant's workflow diagrams show
  the gaps and straight connectors, with the branch and merge elbows unchanged.

### Delivered

- The running v4.1 app was quit, v4.2 was installed at the project root in its place, and it
  relaunched without a crash report.
- Delivered uncommitted and recorded in `15a404d`; published to the public repository on 2026-09-27.

<a id="v4-1-build-41"></a>

## v4.1 / build 41 — 2026-09-26

- **Look:** Content sits on dark smoked glass over a sharp sky with pixel-dithered clouds, in place of the blurred artwork.
- **Layout:** Each screen reads in a centered column under a title set on the sky, and a small pill in the top corner shows the read time or README state.
- **Details:** The card's summaries read as a small label over a larger value, tags are plain text, history rows open into a panel inside their card, and the rail folds its labels away before it narrows.
- **Evidence:** Passed all four check suites and the signing and launch checks.

### Changed

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

### Checked

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks.

- `make app` built and signed v4.1/build 41, which passed strict signature verification and reports
  version 4.1 and build 41.

### Delivered

- It was installed at the project root in place of v4.0, launched on the repository screen showing
  the new design, and quit without a crash report.
- Delivered uncommitted and recorded in `c4b44e5`; publication was not requested.

<a id="v4-0-build-40"></a>

## v4.0 / build 40 — 2026-09-26

- **Icon:** Redrew the Repository Atlas icon in the macOS icon shape, so the app and the project folder show one icon at the standard size.
- **Evidence:** Passed all four check suites and the signing, drawn-icon, and launch checks.

### Changed

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

### Checked

- **Evidence:**
  - `make test` passed all four suites: 371 core, 41 store, 47 notes and presentation, and 12
    version checks.
  - `make app` built, signed, and promoted v4.0/build 40, which passed strict signature
    verification.
  - Rendered through macOS's own icon lookup, the app's outline matches the folder icon to within
    0.2% of pixels.
  - The app launched from the project root, ran without a crash report, and quit.
  - Delivered uncommitted and recorded in `cf6952a`; the public mirror still carries v3.9.

<a id="v3-9-build-39"></a>

## v3.9 / build 39 — 2026-09-25

- **Open App:** A choice from the detected-app menu is refused when that bundle is no longer a current candidate, so a bundle replaced by a link since the last check cannot open an app outside the project.
- **Git reads:** Git runs with a fixed environment, without system or personal Git settings, so a personal setting cannot change the activity the app shows.
  - The README parser compiles each pattern once,
  - both screens share one tab strip,
  - the three test suites share one assertion helper,
  - the history list lives beside the other README content views,
  - the minimum window height is named beside the width,
  - and a test-only Git constant, a redundant container and a no-op modifier are gone.
- **Documentation:** The project structure lists Scripts, history and the guide, the build folder is described as staging only, and every history record's link target is named after its version and build or its subject.

### Changed

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

### Checked

`make test` passed: 371 core, 41 store, 47 note/presentation, and 12 version checks, leaving no
preferences file or temporary folder behind.

### Delivered

- The new store check builds a detected app, replaces it with a link to an app outside the project,
  and requires the launch to be refused without opening anything;
  - the Git fixture check now also sets a personal Git configuration that hides the first commit's
    paths and requires the reader to ignore it.
- `make app` passed and promoted the signed v3.9/build 39 app to the project root; the bundle passed
  strict signature verification and reports version 3.9 and build 39.
- Initially delivered uncommitted; publication was not requested.

<a id="v3-8-build-38"></a>

## v3.8 / build 38 — 2026-09-24

- **Rail:** The repository row shows how many projects the repository holds.
- **Footer:** The version and build, and the refresh cadence, each have one line under the Project Control name.

### Changed

- **Project count:** The repository row at the top of the rail ends in the number of projects the
  repository holds, registered or not, in the same place and style as each category's count; its
  tooltip and accessibility value read, for example, "8 projects". The collapsed rail keeps only its
  icons.
- **Footer lines:** Under the Project Control name, the version and build sit on one line and the
  refresh cadence on the next, each kept to a single line, instead of one status line that wrapped.

### Checked

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks, leaving no
preferences file or temporary folder behind.

- An offscreen render against the live repository showed "8" at the end of the repository row, level
  with the category counts, and the footer's three single lines, reading Project Control, v3.8 (38),
  and Auto-refresh every 2 s; the collapsed rail still shows only icons.

### Delivered

- `make app` passed and promoted the signed v3.8/build 38 app to the project root; the bundle passed
  strict signature verification and reports version 3.8 and build 38.
- Initially delivered uncommitted, then committed in `f457f7f` and `bf2535d`, followed by this
  record; publication was not requested.

<a id="v3-7-build-37"></a>

## v3.7 / build 37 — 2026-09-24

- **Tests:** The store and notes checks keep their preferences inside their own temporary folder, so a run no longer leaves an empty preferences file behind.

### Changed

- **Test preferences:** `make test-store` and `make test-notes` name their preferences by a path
  inside the temporary folder each run deletes, rather than by a name macOS keeps in the user's
  Preferences folder. A named suite left an empty preferences file there after every run, even
  once its settings were cleared.
- **Scope:** Tests and version only; the app behaves as v3.6 did.

### Checked

`make test` passed: 371 core, 40 store, 47 note/presentation, and 12 version checks, and six seconds
after the run no `ProjectControlTests-` preferences file or temporary folder remained.

- A probe showed a plain suite name leaving its file behind, even when the file was deleted right
  after a forced flush, since macOS wrote it again later; a path inside the run's folder left
  nothing.

### Delivered

- `make app` passed and promoted the signed v3.7/build 37 app to the project root; the bundle passed
  strict signature verification and reports version 3.7 and build 37.
- Initially delivered uncommitted, then committed in `026a119` and followed by this record;
  publication was not requested.

<a id="v3-6-build-36"></a>

## v3.6 / build 36 — 2026-09-24

- **Projects:** Every top-level folder with a README appears, registered or not.
- **Rail:** The repository's name and icon collapse and expand the rail; the brand moves to the foot with the version; a collapsed category lists its projects.
- **Project card:** One layout for every project: the actions sit on the name's row and the summaries fill one full-width strip.

### Changed

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

### Checked

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

### Delivered

- `make app` passed and promoted the signed v3.6/build 36 app to the project root; the bundle passed
  strict signature verification and reports version 3.6 and build 36.
- Initially delivered uncommitted, then committed in `382e435` through `3f00ea1`, with this record
  in `86f070c`; publication was not requested.

<a id="v3-5-build-35"></a>

## v3.5 / build 35 — 2026-09-23

- **Workflows:** One diagram style: titled routes of steps joined by ↓, with branches and merges, several routes per block.
- **Parsing:** Parentheses and semicolons in a step read as prose, and up to sixteen routes show instead of eight.

### Changed

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

### Checked

`make test` passed: 354 core, 40 store, 47 note/presentation, and 12 version checks.

- Three new core checks cover titled routes sharing a block, parentheses and semicolons read as
  prose, and a ten-route block shown in full; each fails against the v3.4 parser.
- Offscreen renders against the live register showed 28 titled routes across seven projects,
  including DayWright's and Knowledge Transfer's, which v3.4 could not draw.

### Delivered

- `make app` passed and promoted the signed v3.5/build 35 app to the project root; the bundle passed
  strict signature verification and reports version 3.5 and build 35.
- Initially delivered uncommitted, then committed in `e62a2a8`.

<a id="v3-4-build-34"></a>

## v3.4 / build 34 — 2026-09-23

- **Rail:** The Project Control name is a fixed label; the collapse control moved to the end of the repository row, which stays pinned while the projects scroll.
- **Project card:** Document Health and Notes sit beside the project name and the version shares a line with the tags, so the card has no empty half.
- **Fix:** A workflow diagram with a wrapped node no longer pushes its last node onto the card's edge, and a branch's connectors meet at one height.

### Changed

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

### Checked

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.

- Offscreen renders of the real views against the live register showed the fixed brand label and the
  repository-row toggle in both rail states;
  - the two-column card for Local Assistant at the default size and for DayWright and Python
    Accomplishments at the 1,120 × 620 minimum;
  - and every project's Workflows tab, where the Local Assistant and Career Ledger diagrams that had
    lost their bottom padding keep it and Prospect Copilot's five-line nodes fit.

### Delivered

- `make app` passed and promoted the signed v3.4/build 34 app to the project root; the bundle passed
  strict signature verification and reports version 3.4 and build 34.
- Initially delivered uncommitted, then committed in `c28aa06`, `3cb7998` and `efab612`, with this
  record in `00f19de`.

<a id="v3-3-build-33"></a>

## v3.3 / build 33 — 2026-09-23

- **Rail:** Categories are quiet section headers and each project row is one line, so more of the register fits before scrolling.
- **Footer:** Repository README, Change repository…, and Lock are plain buttons; the Repository menu is gone, and Refresh now sits on the status line.
- **Detail:** Technology tags moved to the project card, and the header strip repeating the Project Control name was removed.

### Changed

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

### Checked

`make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.

- Offscreen renders of the real `ControlWindow` against the live register showed the expanded rail
  on a project and on the repository screen, the collapsed rail, and the 1,120 × 620 minimum window,
  where every category header stays on one line and the project card's tags fit in one row.

### Delivered

- `make app` passed and promoted the signed v3.3/build 33 app to the project root; the bundle passed
  strict signature verification, reports version 3.3 and build 33, and opened its window.
- Initially delivered uncommitted, then committed in `3029a80`.

<a id="v3-2-build-32"></a>

## v3.2 / build 32 — 2026-09-23

- **Icons:** Every project row, project header, and activity hover shows the project folder's own Finder icon instead of an app's icon, so projects without an app no longer show a generic symbol.
- **Identity:** A missing folder, or an alias that no longer points at the project, still shows the neutral symbol.
- **Checks:** The live checks follow the root register, so the full test suite runs again.

### Changed

- **Icons:**
  - `ProjectIcon` shows each project folder's own Finder icon in the sidebar row, the project
    header, and the commit-activity hover.
  - Previously a project showed artwork only when it had a project-root app, and that artwork was
    the app's icon; the other five projects showed a neutral symbol.
  - Every registered project now shows its own folder icon.
- **Identity:** The folder icon appears only while the folder is available and still resolves to
  the identity captured with the snapshot; otherwise the neutral symbol remains.
  `ProjectRecord.hasCurrentIdentity` holds that check, and the app rechecks share it.
- **Scope:** Open App still discovers and prefers project-root apps as before. No README parsing,
  navigation, notes, activity, storage, or launching behavior changed.

### Checked

- **Checks:** The live-repository checks now read the project names, categories, and technologies
  from the root register itself instead of a six-project copy of it, so adding a project no longer
  stops `make test`. The setup guide's success line no longer counts projects either.
- The later test-only change leaves every app source unchanged, so that bundle still matches.
- An offscreen render of the real `ProjectIcon` against the live register showed all eight projects
  with their folder icons.
- The complete `make test` passed: 351 core, 40 store, 47 note/presentation, and 12 version checks.

### Delivered

`make app` passed and promoted the signed v3.2/build 32 app to the project root; the bundle passed
strict signature verification and reports version 3.2 and build 32.

- Publication was not requested.

<a id="v3-1-build-31"></a>

## v3.1 / build 31 — 2026-09-21

- **Identity:** Repository Atlas shows the root README branching to its projects, with one selected project, a work note, and Git activity.
- **Packaging:** The build now compiles the checked-in macOS asset catalog with Apple's asset tool.

### Changed

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

### Checked

- Its packaged 256-pixel icon representation matches the catalog pixels.
- The 40 store checks and 12 version checks passed.
- The complete `make test` target remains blocked by pre-existing live-document assertions that
  still expect the older six-project register and earlier prose grouping while the current workspace
  carries unrelated documentation changes.

### Delivered

`make app` passed, promoted the signed v3.1/build 31 app to the project root, and the bundle passed
strict signature verification.

- Publication was not requested.

<a id="soucieux-proprietary-license"></a>

## Documentation — 2026-09-13

- **License:** Added the approved Soucieux proprietary-software notice.

### Changed

- Added the approved Soucieux proprietary-software notice, reserving rights in original project
  materials while retaining third-party license terms.
- Documentation only; application behavior, v3.0/build 30 source, the signed local app, deployment,
  and publication status are unchanged.

<a id="v3-0-build-30"></a>

## v3.0 / build 30 — 2026-09-12

- **Register:** A row linking to another repository is skipped instead of making the whole register unreadable.

### Changed

- **Register:**
  - the root register gained a second table for work carried on top of someone else's project, whose first column links to a public repository rather than a folder here.
  - Every row in the Projects section is read as a register row, and a row whose link is not a direct child folder was refused as unsafe — which made the entire repository unreadable, not just that row.
  - A row whose link carries a URL scheme is now skipped: there is no folder here to open, so it is documentation rather than a project the app can show.
  - A relative link that escapes the repository is still refused, and that protection keeps its check.
- **Scope:** one guard in `RepositoryReader` and one pattern in `ControlConstants`. No interface, storage, or history behavior changed.

### Checked

- **Checks:**
  - `make check-version` accepts the v3.0/build 30 pair; 434 native checks passed (341 core, 40 store, 41 note/presentation, 12 version), two of them new — an external row is skipped while the folder-based rows around it still load, and an escaping relative link is still refused.
  - The live register, which now carries the forked-project table, parses again; before the fix its read threw and the smoke check failed.

### Delivered

v3.0/build 30 source; `make app` rebuilt and promoted the bundle to the project root, where it reports v3.0 build 30 with a valid strict signature and left no bundle behind; the promoted app launched and quit cleanly; staging removed. Initially delivered uncommitted.

<a id="v2-9-build-29"></a>

## v2.9 / build 29 — 2026-09-12

- **Delivery:** The promotion step deletes the set-aside bundle once the new app is in place, so a build no longer leaves an older release behind.

### Changed

- **Promotion:**
  - `make app` moved the installed app into a `build/previous.*` folder before putting the new one in place, and left it there for good.
  - Every release since v0.2 therefore accumulated a copy of the one it replaced.
  - The step is still transactional — the existing app is set aside and put back if the move fails — but the set-aside copy is now deleted as soon as the new bundle is in place.
  - The project keeps one delivered bundle; an earlier version is rebuilt from its commit.
- **Scope:** the build recipe only. No application source changed, so the interface, parsing, storage and launch behavior are those of v2.8.
- **Documentation:** the README, the contributor guide and the scoped instructions no longer describe retained recoveries, and the records that named a `build/previous.*` path as recoverable no longer claim one exists.

### Checked

- v2.9/build 29 source;
- `make check-version` accepts the pair;
- 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version);
- Disposable staging was removed afterwards.

### Delivered

- `make app` rebuilt and promoted the bundle to the project root, where it reports v2.9 build 29, carries a valid strict signature and an arm64 executable, and left no `build/previous.*` folder behind — the behaviour this release changes.
- The promoted app launched and quit cleanly.
- Initially delivered uncommitted and recorded in `687153d`.

<a id="standalone-contributor-guide"></a>

## Documentation — 2026-09-12

- **Contributing:** Added a standalone project guide so the source carries its own contribution and numbering rules.
- **Links:** Removed the README's dependencies on parent-only repository files.

### Changed

- **Guide:**
  - `CONTRIBUTING.md` now carries the project-facing rules that used to live only in the private repository instructions: what the app may read and do, the presentation rules for tags and the glass direction, the checks a change must pass, and the version and build policy.
  - The private scoped instructions remain authoritative for repository-wide workflow and automation.
- **Links:**
  - the README's four links into the parent `AGENTS.md` now point at that guide or state the rule directly, so every link resolves from the project folder alone.
  - The one remaining parent path sits inside a fenced example of a registered project's README, where Markdown renders it as literal text rather than a link.
- **Numbering:** the change-history declaration links to the guide's own policy section, matching the two projects already exported this way. The policy itself is unchanged: `v<major>.<minor>`, build `major x 10 + minor`, both advancing for every change except a documentation-only one.

### Delivered

- **Status:** Documentation only. Source, the signed v2.8 build 28 application, and its delivery state are unchanged, and no version or build advances for this change.

<a id="v2-8-build-28"></a>

## v2.8 / build 28 — 2026-09-11

- **Source:** Restored the header icon's alignment with the project name, removed per-render bundle reads and repeated measurement from the interface layer, named the documented parsing limits, and removed unused code.
- **Documentation:** Each change-history record now states its change once, and unused link anchors were removed.

### Changed

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

### Checked

- v2.8/build 28 source;
- 432 native checks passed (339 core, 40 store, 41 note/presentation, 12 version);
- a v2.8/build-28 bundle built from the final source in an isolated worktree passed strict signing, exact source-metadata, arm64 and ten-size icon checks and was then removed with its build folder;
- offscreen renders of all six project headers, with real and fallback icons and wrapped names, confirmed that the icon centers on the project name;
- the signed v2.8/build-28 app built from `main` passed strict signing, exact source-metadata, arm64, ten-size icon and project-root launch checks;

### Delivered

- **Status:**
  - Source advances to v2.8/build 28 because this batch changes application source.
  - It was initially delivered uncommitted, then committed and landed on `main` on 2026-09-11.
  - The signed local app was rebuilt from `main` at v2.8/build 28, replacing the v2.7/build-27 app.
  - The project keeps one delivered bundle; an earlier build is rebuilt from its commit rather than
    retained.
- source commits `44c8690`, `1cd3262`, `973d721`, `863fbb2`, `b6b584f`, `f594b22`, `ad2a9d8`, `befa385`, `8e90c5c`;
- initially delivered uncommitted

<a id="readme-organization"></a>

## README organization — 2026-09-06

- **Structure:** User guide first; one history table.
- **Rules:** Scoped contributor guidance under AGENTS.

### Changed

- **Structure:** Put purpose, capabilities, setup, architecture, and workflows before history.
- **History:** Merge matching repository-origin records into the owning change; preserve unique detail, evidence, and older links.
- **Ownership:** Keep user documentation here; route scoped contributor rules through root AGENTS.

### Delivered

- **Status:** Documentation changes only; initially delivered uncommitted and recorded in `3a5bd2c`. Existing application versions, artifacts, and deployment state are unchanged.

<a id="readability-maintenance"></a>

## Documentation readability — 2026-09-06

- **Change:** Reorganized long paragraphs and table cells without dropping details.

### Changed

- Reorganized long paragraphs and table cells without dropping details; consolidated imported history tables into indexes linked to complete readable records.
- Preserved existing destinations and README section mappings.
- Documentation only; no application or release artifact changed.

### Delivered

Local documentation changes; initially delivered uncommitted and recorded in this documentation commit.

<a id="project-descriptions-moved"></a>

## Documentation — 2026-09-06

- **Change:** Moved complete project descriptions, register details, and repository-origin history into this README.

### Changed

- Moved complete project descriptions, register details, and repository-origin history into this README; retained existing content, dates, release/build identifiers, Git evidence, and app-content mappings.
- Project guardrails now load through the root instructions only for this project.
- This is documentation maintenance; no application code, build, release, or deployment changed.

### Delivered

Local documentation update; initially delivered uncommitted and recorded in `3a5bd2c`

<a id="build-folder-cleanup"></a>

## Maintenance — 2026-09-06

- **Change:** Removed the entire build folder and stale Finder metadata.

### Changed

- Explicitly authorized cleanup removed the entire `build/` folder and stale Finder metadata: 231 obsolete generated files (179.7 MB), including compiler caches, test executables, icon intermediates, eleven older-version recovery bundles, and one superseded v2.7 candidate.
- Preserved the exact signed v2.7/build-27 app at the project root, source, editable icon masters, and audit evidence; no build-folder recovery remains.
- SVG references, PNG decoding, all ten packaged icon sizes, and source/packaged artwork inspection passed.
- Updated both current recovery records while preserving historical delivery evidence.
- No application code, version, build, or behavior changed.

### Delivered

User-authorized complete build-folder cleanup; package and asset checks passed; this documentation checkpoint; initially delivered uncommitted

<a id="v2-7-build-27"></a>

## v2.7 / build 27 — 2026-09-05

- **Change:** Restores source-derived sidebar tags and notes availability.

### Changed

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

### Delivered

Source `f953d60`, `6b87a14`, `fbbd132`, `7f62af0`, `56d4463`, `b1ea271`, `cb086d6`, `659d737`, `a15a44c`, `f5071b9`; initially delivered uncommitted; 432 native checks and optimized packaging passed; signed project-root app; live checks and their limits recorded above and in Project details

<a id="superseded-candidates-removed"></a>

## Maintenance — 2026-09-04

- **Change:** Removed the superseded v2.6 candidates from build/previous.FdBli0, build/previous.GtF7qQ, and build/previous.uqRg60.

### Changed

- Removed the three superseded v2.6/build-26 candidate recoveries from `build/previous.FdBli0`, `build/previous.GtF7qQ`, and `build/previous.uqRg60`.
- At that time, the signed v2.6/build-26 project-root app and ten distinct-version recovery bundles were retained; every build-folder recovery was subsequently removed on September 6.
- Added the root README's exact new-project registration procedure.
- No application source, version, build, or behavior changed.

### Delivered

Local cleanup; registration guide `e9333c24`; this history reconciliation

<a id="sidebar-reveal-width"></a>

## Maintenance — 2026-09-03

- **Change:** Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout.

### Changed

- Kept sidebar content at its expanded layout width while the outer rail reveals it, replaced lazy category layout with stable eager layout, and removed the top-slide transition from project rows.
- Existing category/footer icons retain their leading axis and animate from their current layout; new project rows fade in.
- Sidebar destinations, category disclosure, final expanded/collapsed contents, and Reduce Motion behavior are unchanged.
- The optimized build, strict package checks, minimum-width header, and collapsed sidebar inspection passed.
- Formal verification repeated complete compilation and strict packaging.
- The Mac locked before the corrected expansion path and remaining editor interactions could be checked.

### Delivered

Source `722fe5e`; project record `47b24f4`; signed project-root app; live expansion/editor checks pending

<a id="minimum-window-width"></a>

## Maintenance — 2026-09-03

- **Change:** Raised the minimum window width from 980 to 1,120 points and removed the header's stacked action/status layout after the user identified it during live delivery checks.

### Changed

Raised the minimum window width from 980 to 1,120 points and removed the header's stacked action/status layout after the user identified it during live delivery checks.

- Document Health and Notes stay beside the buttons; the app-detection caption can wrap.
- Review found no production issue, centralized the minimum-window value, and corrected a malformed-note fixture that could pass for the wrong reason.
- Verification passed 20 affected core and five affected store checks in addition to the note and numbering checks, complete compilation, a cache-free optimized rebuild, strict signing, exact metadata, and arm64/icon checks.
- Live checks confirmed the minimum width and single-row header before the final equivalent build.

### Delivered

Source `2a5a372`; project record `47b24f4`; signed project-root app; expansion/editor recheck pending

<a id="v2-6-build-26"></a>

## v2.6 / build 26 — 2026-09-02

- **Change:** Implemented v2.6/build 26.

### Changed

- Replaced the 112-point notes progress ring with a content-sized **Notes available / No notes** summary beside Document Health; the header shows no progress or note counters.
- Tightened the project header: identity uses a 48-point icon and 32-point name, the card has a 16-point outer inset, and the tab-to-content gap is eight points.
- A 1,120-point minimum window width, raised during the pending delivery checks on September 3, keeps actions, Document Health, and Notes in one horizontal row with the sidebar expanded; app-detection captions can wrap without moving the summaries below the controls.
- The same delivery correction keeps sidebar content at its expanded layout width behind the changing rail boundary, retains eager category layout, and fades newly revealed project rows instead of sliding them from the top; existing icon columns, footer actions, category behavior, and Reduce Motion remain.
- **Work notes** owns an integrated Add note toolbar, an inline single-text-field editor with Save and Cancel, and saved-note edit/delete controls. There are no title, context, or status fields; the draft stays in the selected project view across tab changes, and a failed save does not discard it.
- Note IDs and all legacy title/context text are retained on read, with title and context combined by a blank line; files are not rewritten merely by loading them, only an explicit mutation writes the new format, and status tracking is retired.
  - Edits, deletion, atomic saves, and read-only recovery for malformed storage remain supported.
- Every prose/list group below the tabs uses the established translucent content surface, even when the same tab also contains headings or tables; source headings and bold-only titles stay outside it, and tables, workflow diagrams, and history rows keep their existing surfaces. Empty states and workflow guidance are also surfaced.
- Packaging now enforces the corrected version/build mapping and rejects mismatched pairs under the repository policy.
- The authorized code review found no production-code correctness, security, performance, or maintainability defect. It corrected a malformed-note fixture that could previously pass for the wrong reason, so the failure is attributable to note content rather than a missing top-level field, and gave the 1,120-point minimum one named source of truth.
- Checks:
  - 40 focused note/presentation assertions (legacy migration without a read-time write, round trips, limits, save/edit/delete and failure preservation, mixed heading/prose/table order, bold-only titles, and prose coverage across all six registered projects);
  - nine disposable-metadata numbering checks (valid pairs, rollover, and malformed/mismatched values);
  - and 20 affected classification/parser core checks and five classification/store checks for the affected README and state paths.
- Complete native compilation, a cache-free optimized build, and strict signature/metadata/arm64/icon checks passed. The signed project-root app matches the source plist at v2.6/build 26, contains the exact generated icon, and has an arm64 executable with a valid strict ad-hoc signature.
- Formal verification then repeated the affected tests, complete compilation, cache-free optimized packaging, and strict package checks. Native icon packaging required its normal macOS access outside the command sandbox; the unchanged rule then succeeded.
- On September 3, live checks of an initial candidate confirmed prose wrapping, compact headers, an inline single-field editor, disabled empty Save, and enabled Save for a multiline draft; no saved notes were changed.
  - Live inspection after the width correction confirmed the 1,120-point minimum, the single-row header, and the collapsed sidebar endpoint.
  - The Mac was locked before the corrected expansion animation and remaining editor interactions could be reinspected.
- On September 4, the three superseded v2.6 candidates were removed while the signed app and ten distinct-version recoveries were retained; full core/store suites were not rerun for that cleanup. The September 6 cleanup later removed every build-folder recovery.
- Implementation is committed in `2a5a372` and `722fe5e`, with project documentation in `47b24f4`; this documentation checkpoint records the result.

### Delivered

Source `2a5a372`; navigation `722fe5e`; project record `47b24f4`; this documentation checkpoint; signed project-root app

<a id="v2-5-build-16"></a>

## v2.5 / build 16 — 2026-09-02

- **Change:** Combined project identity, actions, and Document Health in one compact pre-tab glass card.

### Changed

- Combined project identity, actions, and Document Health in one compact pre-tab glass card.
- The icon, name, and version are top-aligned beside the notes gauge; folder, README, app, optional app-menu, application-detection message, document availability, and runtime disclaimer form a compact, adaptive lower grouping.
- The card alone reduces its content inset to 16 points, trimming its top and side space, and uses a 14-point internal row gap, leaving other glass-card styling unchanged;
  - the action/status row drops its title-column offset or stacks when needed to preserve narrow-window readability, and the tab-to-content gap was reduced to eight points.
- No action, launch-selection, warning, note, README-parsing, or repository-data behavior changed; existing warnings, below-tab content styling, notes, history, repository activity, navigation, artwork, and lock behavior are unchanged.
- Complete native type-checking, a cache-free optimized build, strict signing, and exact v2.5/build-16 metadata checks passed; source and bundle metadata both identify v2.5/build 16, the executable is arm64, and the bundled icon is present.
- Live app inspection covered Local Assistant and the longer Python Accomplishments title at regular and minimum window sizes, confirming visible actions, detection text, integrated health, the notes gauge, and unclipped tab/content layout.
- Core/store logic was unchanged, so those suites were not rerun.
- The subsequent authorized review found no actionable issues; verification repeated a cache-free optimized build, strict signature/metadata/arm64/icon checks, and live narrow-window Local Assistant and Python Accomplishments header inspection.
- The initial delivery preceded that review and was uncommitted. Superseded same-version candidates and generated intermediates were removed after the final package checks.

### Delivered

Source `cb93da7`; this documentation checkpoint; signed project-root app

<a id="numbering-rules-moved"></a>

## Documentation — 2026-09-02

- **Change:** Moved generic version and build-number rules to the repository README, retained Project Control's bundle-delivery procedure here.

### Changed

- Moved generic version and build-number rules to the repository README, retained Project Control's bundle-delivery procedure here, and added the required linked project declaration.
- Application source, metadata, signed bundle, and v2.4/build 15 are unchanged.

### Delivered

This documentation commit

<a id="v2-4-build-15"></a>

## v2.4 / build 15 — 2026-09-02

- **Change:** Removed the competing whole-shell SwiftUI clip and outline so the native macOS window owns the outer corners without light wedges.

### Changed

- Removed only the competing whole-shell SwiftUI clip and outline, so the native macOS window owns the outer corners without light wedges while the full black chassis and independently rounded detail surface remain.
- Kept the three-point black detail reveal and visually tuned the detail layer to an 18-point radius, so all four rendered detail curves follow the native window instead of deriving the radius from an assumed outer value.
- Removed the lock artwork's custom outer mask and outline; lock and unlock now crossfade edge-to-edge with an opacity-only transition and no shell scaling.
- `ReadmeContent` wraps only untitled below-tab paragraph/bullet views in the established rounded translucent plane; heading-led content, native tables, Workflow titles and diagrams, history disclosure rows, work-note rows, and every area above the tabs keep their existing presentation.
- Added a lower-third sage halftone, fading upward, to the shared active/lock artwork and repeated it crisply above the normal detail blur, so its dots remain visible in the same lower position; a denser full-frame matrix of dots and short marks is added only to the clear lock view.
- Moved repository README, repository actions, and Lock into matching full-width pinned footer rows beneath a hierarchy separator, with one fixed book, adjustment, and lock icon axis and longer balanced Open README file, Repository menu, and Lock application labels.
  - The menu's visible row uses the same fixed leading layout as the plain buttons instead of the borderless menu's intrinsic alignment.
- Compact workspace/sync status and the live bundle version follow a second separator, aligned to the visible icon column rather than the rail edge.
  - Duplicate header/detail controls remain removed, all compact icons stay centered on one axis in the collapsed rail, and the detail header keeps identity and context without duplicated actions.
- Passed 332 core checks, 39 store checks, optimized arm64 compilation, strict signing, exact source/bundle v2.4/build-15 metadata, icon checks, root-bundle promotion, and live inspection of repository/project Overview, Architecture, and Workflows, expanded/collapsed footer and rails, lock artwork, halftone density, and the native/detail corners.
- The complete code review found no actionable source findings. Formal verification repeated a clean optimized rebuild, strict signing and package-identity checks, arm64/icon checks, and live expanded/collapsed, Overview, Workflows, and lock-state inspection.

### Delivered

Source `196b8b3`; project documentation `bf4b33b`; this documentation checkpoint; signed project-root app

<a id="v2-3-build-14"></a>

## v2.3 / build 14 — 2026-09-01

- **Change:** Added repository Commit activity with newest-first years, twelve responsive month cells, fixed absolute intensities, concealed future values, complete unique-commit totals.

### Changed

- Added repository Commit activity: newest-first distinct years, twelve responsive month cells, fixed absolute intensities, dimmed future cells that conceal their counts, and a complete unique-commit total kept independent from valid monthly buckets.
- Hovering a populated cell lists each affected current project's icon (the real project icon when available), name, and participation count.
- Activity invokes the fixed system Git executable directly with read-only arguments and loads every unique reachable commit. Changed paths are read solely to map registered top-level project folders; commit messages, authors, and file contents remain unread.
- Reworked the shell into two explicit layers: one full-window rounded black chassis and one inset four-corner light-artwork detail panel above it in the right-hand detail region.
  - The chassis is visible as the left rail and the narrow perimeter around all four detail corners; the detail panel blurs the same artwork that the lock screen shows clearly.
- Removed rail/detail overlap and visible scrollbars.
  - The reference-style brand control stays visible in both rail states; the expanded brand row and collapsed 40-point icon column share one leading axis, and every rail icon keeps that fixed axis while labels animate.
  - Top navigation, scrolling project groups, and the pinned local-only status remain structurally separate.
- Reduce Motion suppresses transitions, while Reduce Transparency retains the solid detail fallback.
- Passed 8 focused activity core checks, 1 store check, complete native type-checking, optimized compilation, strict signing, exact v2.3/build-14 metadata, arm64 executable/icon checks, and live expanded/collapsed/lock and activity inspection. Optional code review and formal verification did not run.
- The activity implementation is committed in `b5358ab` and the shell implementation in `dc612a8`; this documentation checkpoint records their delivered state.

### Delivered

Activity `b5358ab`; shell `dc612a8`; project documentation `920a9bb`; this documentation checkpoint; signed project-root app

<a id="v2-2-build-13"></a>

## v2.2 / build 13 — 2026-09-01

- **Change:** Moved Category, Technical scope.

### Changed

Moved Category, Technical scope, and Technologies into the first three labelled list items of every root-register Professional scope cell, so the human-facing Projects register can use three readable columns without losing its complete project descriptions.

- The parser reads those labels case-insensitively, strips display markup, and handles blank labelled values explicitly.
- Older separate classification columns remain compatible and take precedence over same-named scope labels when present, including explicit blanks; the retired AI-usage column remains ignored.
- The existing v2.1 glass UI, project content, notes, launch behavior, synchronization paths, and all other project-management behavior are unchanged.
- All 20 focused core checks and 5 isolated store checks passed, including the new labelled-scope, blank-value, compatibility, and precedence regressions.
- Complete native type-checking, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, arm64 executable/icon checks, bundle promotion, and a separate-instance project-root launch passed.
- Source is committed in `5ab1b93`. Generated compiler/icon intermediates and the smoke process were removed.
- Optional code review and formal verification did not run.

### Delivered

Source `5ab1b93`; this project documentation and delivery checkpoint

<a id="v2-1-build-12"></a>

## v2.1 / build 12 — 2026-09-01

- **Change:** Delivered the approved edge-to-edge glass correction.

### Changed

- Delivered the approved edge-to-edge glass correction: removed all four outer shell insets, moved title-bar clearance inside the hierarchy rail, placed a full-window local sky/cloud/texture scene across the whole window, and replaced desktop-only sampling with `withinWindow` native material so the scene remains visible beneath the content plane.
- Normal appearance adds no opaque tint above the material; Reduce Transparency alone uses the existing strong surface as a solid fallback. The lock artwork shares the same scene and also fills the window.
- README parsing, classifications, notes, app discovery, tabs, native tables, diagrams, and all README-driven data and interaction paths are unchanged.
- Added the Project Control-specific rendered acceptance rule to root AGENTS.md without changing sibling-project policy.
- Complete native type-checking passed. A controlled 1320×760 render confirmed shell coverage at every edge midpoint and visible scene variation across the glass content plane, followed by visual inspection of the zero-gap boundary, shared backdrop, and content readability.
- After the source and dual-README checkpoints were committed, cache-free optimized compilation, strict signing, exact source/bundle metadata equality, icon/executable checks, bundle promotion, and a separate-instance project-root launch passed.
- Generated intermediates and the smoke process were removed.
- Core/store behavior was unchanged, so those suites were not rerun; optional code review and formal verification did not run.

### Delivered

Source `f4fca5b`; project source record `ad48ff1`; root source record `e261f5d`; project delivery `ee58c92`; this delivery checkpoint

<a id="v2-0-build-11"></a>

## v2.0 / build 11 — 2026-09-01

- **Change:** Delivered the complete cinematic glass redesign.

### Changed

- Delivered the complete cinematic glass redesign, replacing the earlier angular navy interface:
  - a transparent native window and real behind-window desktop blur inside one outlined rounded shell,
  - an aligned expanding/collapsing black hierarchy rail,
  - staggered per-project disclosure transitions,
  - bounded internal scrolling with hidden indicators,
  - rounded content cards,
  - and a no-password artwork lock that replaces the whole interface with local artwork and a centered Unlock control.
- The user's screenshot rejected the first signed candidate because it showed an internal green field; source `c4ef97a` provides the transparent-window and real behind-window material correction.
- Offscreen inspection removed a redundant lock caption that crossed the fortress silhouette. Offscreen repository/project renders confirmed the outlined shell, rounded hierarchy, real app icons, fixed-height content, and centered lock control; behind-window sampling itself requires the live window.
- README-derived data and parsing, classifications, notes, project icons, application discovery, content tabs, tables, diagrams, workflow data, and background README synchronization are unchanged.
- All **323 core checks** and **39 store checks** passed, followed by complete native type-checking, before distributable compilation. After the source and dual-README checkpoints were committed, a clean optimized build passed strict signing, exact source/bundle metadata equality, and separate-instance project-root launch.
- ScreenCaptureKit access remained denied, so final live capture and interaction are not claimed; optional code review and formal verification did not run.
- The superseded v2.0 bundle and generated intermediates were removed. Superseded Vector/Lens design and reference files remain in Git history.

### Delivered

Initial source `f317ff0`; desktop glass `c4ef97a`; project records `13e395f`, `039702e`, `98dad53`; root records `5f816cc`, `7ca6e6c`; this delivery checkpoint

<a id="v1-0-build-10"></a>

## v1.0 / build 10 — 2026-08-31

- **Change:** Replaced mandatory AI-usage badges with optional root-README Technologies tags, keeping technical scope separate.

### Changed

- Replaced mandatory AI-usage badges with optional, individually wrapping root-README Technologies tags, keeping technical scope as a separate line. The root register supplies the tags for all six projects.
- Added per-tag wrapping, case-insensitive deduplication, explicit empty and retired-column behavior, and focused parser/store regressions; updated the parser, sidebar, all six root register entries, both README records, and the Project Control-only tag rule in root AGENTS.md.
- Passed **19 focused parser/register checks**, **5 store checks**, native type-checking, and **24 native tag-layout cases** at 64-, 148-, and 320-point widths, including empty and long labels.
- Offscreen views at 900×660 and 1160×840 and a six-project tag panel were inspected.
  - The isolated render needed normal macOS icon-service access outside the agent sandbox; it captured only its own never-shown views, not desktop pixels, and no screen-recording permission was changed or retried.
  - These checks do not establish live scrolling, keyboard interaction, or installed-app behavior.
- Source was committed separately, with the user's authorization, in `dc45f88` (metadata/sync), `36c21c4` (header), and `a427582` (sidebar), with root metadata/policy in `82e51d0` and release records in `7f5b5ee` / `d8d07e8`, before the build; no build-gate exception was used.
- A cache-free optimized arm64 build was promoted to the project root.
  - Strict signing, exact source/bundle metadata equality, v1.0/build-10 identity, unchanged Nexus icon bytes, and a fresh root-level process launch passed.
  - The smoke-test process remained running for at least 47 seconds and was then closed; no existing Project Control process was present before the check.
  - This confirms launch, not live interaction.
- Generated compiler caches and intermediate icon files were removed and can be regenerated. No desktop capture or privacy-setting change was attempted.
- No live-interaction, code-review, or formal-verification claim is made.

Run only the classification regressions from this project folder:

```sh
make test-core test-store TEST_ARGS=--classification
```

- These exercise optional/reordered columns, literal technology names, empty/duplicate tags, retired AI metadata, tag edits/removals, the actual six-project register, and stale-project refresh while preserving selection and notes.
- Omitting `TEST_ARGS` retains the existing test targets' complete behavior.

### Delivered

`dc45f88`, `36c21c4`, `a427582`; root metadata/policy `82e51d0`; pre-build release records `7f5b5ee`, `d8d07e8`

<a id="v0-9-build-9"></a>

## v0.9 / build 9 — 2026-08-31

- **Change:** Corrected header icon/title proportions, left alignment, and the ellipsis/disclosure overlap.

### Changed

- Corrected the header: a 36-point Nexus icon, an 18-point title, symmetric spacing and left alignment, and a separate ellipsis menu without the redundant triangle, so the ellipsis no longer overlaps the disclosure control.
- Added five collapsible, source-ordered README-driven categories with counts and independently wrapping technical-scope/AI-usage badges from optional root-register columns. Missing metadata remains unspecified and backward-compatible; root classification changes still apply when a project README is stale, preserving project identity, selection, and work notes.
- The focused checks cover case-insensitive and reordered optional metadata columns, custom category names, missing/blank/short rows, duplicate projects, source ordering, README-triggered regrouping, and preservation of selection/notes while project content is stale. The new source fixtures and the live six-project register passed **312 core checks and 38 store checks**.
- Native type-checking and a cache-free optimized build passed.
  - Four isolated, never-shown native views were rendered: at 900×660 and 1160×840, a tall register showing all five categories, and a minimum-width long-repository-name case.
  - The header icon/title alignment, separate ellipsis, wrapping badges, counts, selection highlight, and real app/fallback icons were inspected.
  - The design pass retains the navy/icy-blue palette and uses informational badges, not health scores.
  - These renders do not establish live scrolling, collapsing, keyboard, menu, or window-chrome behavior.
- macOS denied live window capture; no capture permission or privacy setting was changed or retried. The render probe and icon packager needed normal macOS icon-service access outside the agent sandbox; neither captured the desktop.
- The app was delivered directly in the project folder. Clean compilation, strict bundle identity/signature checks, matching source/bundle metadata, unchanged Nexus icon bytes, and project-root launch passed. Only the newly started background smoke-test instance was closed; the existing app session was preserved.
- The preceding v0.8 source/build work was already committed before this build; Temporary render sources/images, test binaries, compiler caches, and intermediate icons were removed.
- Source was uncommitted at delivery; the retained header/category implementation is now captured with v1.0 in `dc45f88`, `36c21c4`, and `a427582`, not in a separate v0.9 release commit. Live interaction, optional code review, and formal verification were not confirmed or run for this batch.

### Delivered

Retained implementation captured with v1.0 in `dc45f88`, `36c21c4`, `a427582`; no separate v0.9 release commit

<a id="history-reconciled"></a>

## Documentation — 2026-08-31

- **Change:** Matched all retained release records to Git evidence, clarified releases committed together, and adopted the root-only instruction/history rules.

### Changed

- Reconciled all retained v0.1–v0.8 history with the source commits that recorded it, including intermediate builds committed together, and adopted the root-only instruction/history rules. v0.8/build 8 source is committed through 5dee069.
- At reconciliation, diagram work was paused and v0.8/build 8 was unchanged; these records are included with the v1.0 release documentation.

### Checked

Prior release references below; no separate app build

<a id="v0-8-build-8"></a>

## v0.8 / build 8 — 2026-08-31

- **Change:** Added stable README mappings, content-digest refresh, source warnings/recovery, and one technology/concept per architecture row.

### Changed

- Added stable README section routing through mapped section identifiers, background content-digest refresh, visible stale-source warnings and recovery, and one technology/concept per architecture row: 117 individually named architecture technologies/concepts across all six projects, each in its own category-table row. The selected design, Nexus icon, navigation, notes, diagrams, and app discovery remain.
- Review corrected an old-repository polling race during repository switches, required a real register-table header so a malformed empty register is rejected, and kept a failed different-root choice from falsely marking the current repository stale.
  - A disposable copy without the polling guard failed the new repository-switch regression at the expected assertion; no actionable findings remain in this reviewed scope.
- Final verification passed **303 core checks and 34 store checks**, a targeted mutation check, native type-checking, clean compilation, strict signing, and source/bundle metadata and identity checks.
- Native offscreen rendering produced all six architecture views at 583- and 843-point content widths; minimum-width views, a regular-width representative, and the stale warning were inspected. This is layout evidence, not live window/keyboard/file-picker verification. No privacy setting or capture permission was changed.
- The existing app process was left untouched and not restarted; quit and reopen the root-level app to load the new binary. Live UI interaction remains unverified.
- The release was delivered as **Project Control.app** beside this README. The previous v0.7 source was committed before this update. The obsolete v0.6 recovery and the superseded pre-review v0.8 candidate were moved to macOS Trash under `Project Control - retired bundles 2026-08-31-sync`; temporary test, mutation, rendering, and compiler/icon artifacts were removed.
- The separate Observatory v2.2 snapshot was rebuilt with permission to leave its pending Atlas/release work uncommitted.

### Delivered

`bf86701`, `0fdba44`, `384149c`, `b8c2f83`, `5dee069`

<a id="architecture-category-tables"></a>

## Documentation — 2026-08-31

- **Change:** Grouped all six projects' architecture components into relevant category tables using existing native headings and tables.

### Changed

Grouped all six projects' architecture components into relevant category tables by primary responsibility, using existing native headings and tables. Preserved every source row and documented the category convention.

- The unchanged v0.7/build-7 renderer displays a separate table per relevant architecture category; Project Control was not rebuilt. Observatory's embedded README advanced separately to v2.1, and the user explicitly permitted that Observatory build without first committing v2.0.
- Passed 162 core checks, 18 store checks, native type-checking, all 66 row and 28 category checks, README links, native offscreen category layouts, and unchanged-bundle identity/signature checks.
- Review found no actionable implementation defects; live interaction remains unverified.

### Delivered

`359f658`, `db469c4`; historical work record

<a id="v0-7-build-7"></a>

## v0.7 / build 7 — 2026-08-31

- **Change:** Delivered larger title-aligned project icons, dates beside history headings, and complete architecture tables with full-width row dividers.

### Changed

- Delivered larger project icons aligned with their title line, dates beside history headings, and complete architecture tables that retain model/RAG responsibilities with full-width row dividers; mixed architecture/workflow sections are retained.
- Added source-backed architecture tables to all six project READMEs, with focused regressions for complete architecture tables, mixed architecture/workflow headings, source ordering, and dated/undated histories; an empty-date separator regression found during testing was corrected.
- All 128 core checks and 18 isolated store checks passed, along with native type-checking, offscreen header/history/table layouts, clean compilation, strict bundle checks, and root-level launch.
- Offscreen native rendering checked all six project headers at minimum and regular content widths, title-line icon alignment, dated history headings, and Local Assistant's complete 15-row architecture table.
  - Wrapped cells exposed uneven per-cell dividers; full-width grid dividers corrected the layout and were checked at both widths.
  - These probes rendered only their own never-shown views, without capturing desktop pixels.
- A cache-free native build passed strict signature, source/bundle metadata, unchanged Nexus icon, project-root launch, and checksum-matched v0.6 recovery checks.
- Removed temporary/generated artifacts. v0.5 was retired to Trash, though a final Trash inventory was denied by macOS and was not retried.
- The user explicitly permitted the required builds before committing Project Control v0.6 or Observatory v1.9; source was uncommitted at delivery and no commit was made at that point.
- Live UI interaction, optional code review, and formal verification had not run at delivery; the later category-grouping review and verification are recorded under v0.8 delivery evidence.

### Delivered

`15a15c1`, `40196c9`, `359f658`, `db469c4`

<a id="v0-6-build-6"></a>

## v0.6 / build 6 — 2026-08-30

- **Change:** Added structured native README tables, preserved model/path identifiers, preferred project icons.

### Changed

- Added structured native README tables with literal model/path identifiers, preferred project icons, and a selectable repository-parent navigation screen replacing footer content.
- Recorded table-rendering and hierarchy acceptance rules, with focused regressions for leading blank lines, adjacent prose/tables, escaped pipes, distinct source headers, literal model/path identifiers, root overview refresh, parent/child selection, and app preference for icons.
- All 71 core checks and 18 isolated store checks passed, as did native type-checking and clean compilation.
- Offscreen native rendering checked repository/project layouts at 900×660 and 1160×840, the real Local Assistant table component at both content widths, a three-column scrolling table, real app icons, and neutral fallback symbols.
  - The render probe needed native icon-service access outside the agent sandbox; it rendered only its own never-shown views and captured no desktop pixels.
  - No screen-capture permission was retried and no privacy setting was changed.
- A cache-free build passed strict signature/metadata/icon checks, source/bundle metadata equality, unchanged Nexus icon checks, and root-level launch from the project-root v0.6 bundle.
- The previous v0.5 bundle was preserved unchanged, retaining its signature and executable/metadata/icon checksums. The superseded v0.4 bundle was moved to Trash with matching checksums, and temporary render sources/images, test executables, compiler caches, and intermediate icons were removed.
- The previous v0.5 work was already committed; this batch's source was uncommitted at delivery. Live UI interaction remains unconfirmed; optional code review and formal verification have not run for this batch.

### Delivered

Retrospective record in `359f658`; implemented source committed with v0.7

<a id="v0-5-build-5"></a>

## v0.5 / build 5 — 2026-08-30

- **Change:** Fixed four review findings in workflow parsing, versioned-title ownership, fresh app metadata validation, and executable-availability refresh.

### Changed

- Delivered v0.5/build 5 after reviewing the complete UI/content update.
  - The review reproduced four defects using disposable fixtures, all now fixed: ASCII arrows inside text fences were rejected; a versioned project title incorrectly owned all current sections as history; cached bundle metadata survived executable changes; and permission-only executable changes did not trigger refresh.
- Nine added core assertions cover these regressions plus binary/malformed/oversized metadata and executable-directory rejection. All 71 focused checks (57 core and 14 store) passed with native type-checking, clean compilation, and strict signature/metadata/icon checks; no synthetic app was launched.
- The reviewed source was committed in separate parser, app-discovery, UI, and documentation groups before clean distributable compilation; no build-rule exception was needed.
- Strict root-bundle signature checks, source/bundle metadata equality, unchanged Nexus icon, and project-root process launch passed.
- The superseded v0.3 bundle was moved to Trash with matching checksums, and disposable probes, test binaries, compiler caches, and intermediate icons were removed.
- Live UI interaction remains unconfirmed; the unchanged view layout has the earlier v0.4 offscreen evidence only.

### Delivered

`e62041e`, `7dc76ae`, `105d1a0`, `81f601c`, `492dbb3`

<a id="v0-4-build-4"></a>

## v0.4 / build 4 — 2026-08-30

- **Change:** Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection and manual fallback, separate README Overview/Architecture/Models/Workflows tabs.

### Changed

- Added the Nexus header icon, full-row sidebar navigation without search, automatic project-root app detection with manual fallback, separate README Overview/Architecture/Models/Workflows tabs, and native connected node-and-arrow workflow diagrams with explicit branch/merge support.
- Recorded project-level UI acceptance rules.
- All 62 focused checks (48 core and 14 store) and native type-checking passed, followed by offscreen layout checks, a cache-free clean native build, strict signature and source/bundle metadata checks, unchanged Nexus icon payload, project-root launch, and checksum-matched v0.3 recovery checks.
- An offscreen `NSHostingView` rendered the real Overview and workflow components without capturing any screen; this checked layout, not live interaction. A test-fixture comparison was corrected to use canonical macOS paths.
- Preserved v0.3 unchanged and moved v0.2 to Trash with matching checksums. Temporary render sources/images and test/render files, test executables, the failed fixture/report, compiler caches, intermediate icons, and other generated artifacts were removed.
- The v0.3 source/build work was already committed before this build began. Live interaction checks remain unconfirmed.

### Delivered

Retrospective record in `81f601c`; implemented source committed with v0.5

<a id="v0-3-build-3"></a>

## v0.3 / build 3 — 2026-08-30

- **Change:** Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows.

### Changed

- Review fixes preserve fenced-code boundaries, escaped table pipes, optional trailing delimiters, and URL/step colons in workflows.
- Capture metadata before reads for refresh identities, share canonical identities for folder aliases, queue the latest repository selection while loading, and apply the same path boundary to root/project README opening.
- Passed 27 core checks, 10 isolated store checks (including a concurrent-edit/polling regression), native application type-checking, clean native compilation, strict signature validation, source/bundle metadata equality, bundle metadata/icon checks, and project-root process launch.
- The packaged Nexus icon is byte-identical to the verified v0.2 icon.
- Moved the superseded icon comparison and v0.1 bundle to Trash with matching checksums; generated compiler caches and intermediate icon files were removed after verification.
- The user explicitly permitted building v0.3 before committing v0.2. Native visual inspection remains unconfirmed.

### Delivered

`5b0b224`, `188ddbd`, `7627e26`, `d3c00a5`

<a id="v0-2-build-2"></a>

## v0.2 / build 2 — 2026-08-30

- **Change:** Selected A · Nexus, added editable SVG and PNG masters plus native icon packaging, and wired the icon into the bundle.

### Changed

- Selected A · Nexus as the app icon, added editable SVG/PNG masters and macOS-native packaging of standard/Retina icon sizes, and wired the icon into the bundle; advanced both version and build.
- Focused packaging checks confirmed all ten icon sizes (ten-size icon-payload checks) and their stored source pixels, matching source/bundled metadata and icon files, valid signatures, clean native compilation, signed root-level delivery, unchanged v0.1 recovery files, and process launch from the root-level v0.2 app. v0.1 was preserved with unchanged executable/metadata checksums.
- Eight PNG icon representations round-tripped exactly. macOS `iconutil` changes translucent RGB values when exporting the 16/32-pixel ARGB representations, so those were checked against the packed channel data instead.
- This does not substitute for actual Dock/window inspection, which remains unconfirmed. Icon packaging required running the native tool outside the agent sandbox; no app permission or privacy setting was changed.
- The user explicitly authorized this build without committing v0.1; no commit was created.

### Delivered

Retrospective record in `d3c00a5`; source committed with v0.3

<a id="root-level-app-delivery"></a>

## Maintenance — 2026-08-30

- **Change:** Relocated the unchanged v0.1/build-1 application beside this README.

### Changed

- Moved the unchanged v0.1/build-1 application to the project root, beside this README, for direct opening.
- Configured signature-checked root-level delivery of completed builds beside the project README, preserving prior bundles for recovery.
- Recorded release/build increments and the single-digit 0–9 minor-version rollover policy.
- Added three original icon concepts with large and Dock-size comparisons; no icon had been selected, the next-build authorization was pending, and no new app build was produced at this stage.

### Delivered

Retrospective record in `d3c00a5`

<a id="v0-1-build-1"></a>

## v0.1 / build 1 — 2026-08-30

- **Change:** Implemented native README discovery/refresh, introductions, architecture and explicit workflow maps, separate histories, atomic structured notes, note-based progress.

### Changed

- Implemented v0.1 build 1 as a native SwiftUI README-driven management center: project discovery/refresh, source introductions, architecture and explicit workflow maps, separate project/repository histories, atomic structured work-note persistence with note-based (completed-note) progress, explicit folder/README opening, and user-configured application launching without shell execution.
- Passed 19 focused checks, native compilation, clean rebuild, bundle checks, README-link checks, and clean-built process launch; corrected stale metadata caching found by the refresh test.
- Retired 33 rejected design artifacts recoverably and removed their obsolete links while preserving the selected sci-fi reference.
- Kept runtime health explicitly unchecked; native visual/keyboard inspection remains blocked by macOS capture permission.

### Delivered

Retrospective record in `d3c00a5`; source committed with v0.3
