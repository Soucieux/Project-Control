import Foundation

/// Synthetic, credential-free fixtures for the README and persistence boundary.
internal enum TestConstants {
    internal static let project = "Example"
    internal static let rootName = "ProjectControlTests-"
    internal static let failed = "FAILED: "
    internal static let passed = "Core checks passed: "
    internal static let corrupt = "not JSON"
    internal static let title = "Add a useful introduction"
    internal static let detail = "Explain the workflow without showing source code."
    internal static let external = "Outside"
    internal static let rootReadme = """
    # Sample repository
    ## Overview
    Repository overview from its README.
    ## Projects
    | Project | Scope | Updated |
    |---|---|---|
    | [Example](Example/) | Current source release: v0.1 (build 1). Sample scope. | 2026-08-30 |
    | [Missing](Missing/) | An unavailable project. | 2026-08-30 |
    ## Change log
    | Project | Date | Updates |
    |---|---|---|
    | Example | 2026-08-30 | <ul><li>Added notes.</li><li>Added history.</li></ul> |
    """
    internal static let projectReadme = """
    # Example
    A quiet project management tool.
    ## Local architecture
    | Responsibility | Component |
    |---|---|
    | Interface | SwiftUI |
    | Storage | Local JSON |
    ## Request flow
    - **Read:** Choose repository → Read README → Show summary.
    - **Write:** Add note → Save local state.
    ```swift
    secretCode() -> forbiddenSource
    ## Fake heading
    ```
    ## Version index
    | Version | What changed |
    |---|---|
    | v0.1 | [Initial implementation](#initial) |
    """
    internal static let updatedReadme = """
    # Example
    A changed introduction.
    ## Request flow
    - **Read:** Select folder → Read README.
    """
    internal static let escapedRoot = """
    # Sample repository
    ## Projects
    | Project | Scope |
    |---|---|
    | [Escape](../Outside/) | Unsafe. |
    """
    internal static let symlinkRoot = """
    # Sample repository
    ## Projects
    | Project | Scope |
    |---|---|
    | [Example](Example/) | Symlink test. |
    """
    internal static let tildeCode = """
    # Example
    ~~~~swift
    secretCode()
    ~~~
    stillSecret()
    ~~~~
    ## Request flow
    - Visible → Result
    """
    internal static let introduction = "A quiet project management tool."
    internal static let updatedIntroduction = "A changed introduction."
    internal static let version = "v0.1 (build 1)"
    internal static let architecture = "Interface · SwiftUI"
    internal static let history = "Initial implementation"
    internal static let forbidden = "secretCode"
    internal static let checkRegister = "root Projects table discovers two rows"
    internal static let checkIntro = "project introduction is extracted"
    internal static let checkVersion = "source release and build are scoped"
    internal static let checkArchitecture = "architecture table becomes labelled facts"
    internal static let checkRoutes = "branches remain two independent routes"
    internal static let checkCode = "fenced source never enters sections or flows"
    internal static let checkHistory = "project version table loses link markup"
    internal static let checkRootHistory = "repository history is separate"
    internal static let checkMissing = "missing project and README remain explicit"
    internal static let checkChange = "README edit changes the fingerprint"
    internal static let checkReload = "reload adopts updated README content"
    internal static let checkEmpty = "first-use storage is empty"
    internal static let checkNotes = "notes and status survive atomic persistence"
    internal static let checkCorrupt = "malformed state is not silently reset"
    internal static let checkEscape = "traversal links cannot leave the repository"
    internal static let checkSymlink = "README symlinks cannot leave the repository"
    internal static let checkTilde = "shorter fences do not terminate a code block"
    internal static let checkLive = "live repository exposes its current register"
    internal static let checkLiveFlows = "Local Assistant retains five request routes plus its branching RAG diagram"
    internal static let liveRoot = ".."
    internal static let liveProject = "Local Assistant"
    internal static let misleadingFence = """
    # Example
    ```text
    ```swift
    secretCode()
    ```
    ## Visible
    """
    internal static let pipeRows = [#"| Field | Value"#, #"|---|---"#, #"| Name | Left \| right"#]
    internal static let pipeValue = "Left | right"
    internal static let colonFlows = """
    ## Request flow
    - Fetch https://example.test → Display: result
    - Read: Source → Result
    """
    internal static let urlStep = "Fetch https://example.test"
    internal static let resultStep = "Display: result"
    internal static let flowLabel = "Read"
    internal static let alias = "Alias"
    internal static let aliasRoot = """
    ## Projects
    | Project | Scope |
    |---|---|
    | [Example](Example/) | Original. |
    | [Alias](Alias/) | Same folder. |
    """
    internal static let checkFenceSuffix = "fence-like code with an info string cannot close the block"
    internal static let checkPipes = "escaped pipes and optional trailing delimiters preserve cells"
    internal static let checkColons = "URLs and step colons do not become workflow labels"
    internal static let checkLabel = "explicit workflow labels remain supported"
    internal static let checkCaptured = "snapshot metadata predates later README edits"
    internal static let checkAlias = "aliases share one canonical project identity"
    internal static let checkAliasChange = "retargeted folder aliases change metadata identity"
    internal static let checkRootSymlink = "root README open boundary rejects outside symlinks"
    internal static let secondRepository = "Second"
    internal static let blockedFile = "blocked"
    internal static let checkStoreQueue = "latest repository selection is not dropped while loading"
    internal static let checkStoreLoading = "queued reload completes and clears loading state"
    internal static let checkStorePreference = "only the final repository remains selected in preferences"
    internal static let checkStoreSave = "store persists notes before publishing them"
    internal static let checkStoreEdit = "editing a note preserves its identity"
    internal static let checkStoreDelete = "confirmed note deletion persists"
    internal static let checkStoreCorrupt = "corrupt storage locks editing without overwriting the file"
    internal static let checkStoreFailedSave = "failed saves do not mutate visible notes"
    internal static let checkReaderStarted = "controlled background reader starts within its deadline"
    internal static let storePassed = "Store checks passed: "
    internal static let checkConcurrentRefresh = "an edit made before the reader returns is detected by polling"
    internal static let overviewText = "The actual project overview."
    internal static let overviewBullet = "A documented capability."
    internal static let overviewOrder = """
    ## Overview
    Before.

    | Role | Component |
    |---|---|
    | Interface | SwiftUI |

    - A wrapped
      capability.

    After.
    """
    internal static let overviewOrderExpected = ["Before.", "Interface · SwiftUI", "A wrapped capability.", "After."]
    internal static let checkOverviewOrder = "overview preserves table position and continued bullet paragraphs"
    internal static let topicReadme = """
    # Example
    Opening fallback.
    ## Overview
    The actual project overview.

    - A documented capability.
    ### Details
    More overview context.
    ### Architecture
    | Role | Component |
    |---|---|
    | Interface | SwiftUI |
    | Chat | Qwen local model |
    #### Models
    Uses a documented embedding model.
    ### Workflows
    ```text
    Question
       ├─→ Keyword search
       └─→ Vector search
                 ↓
            Combined evidence
                 ↓
            Answer
    ```
    ## Release notes
    ### v0.1
    #### Architecture
    Obsolete architecture.
    """
    internal static let modelFact = "Chat · Qwen local model"
    internal static let obsoleteArchitecture = "Obsolete architecture."
    internal static let textFlows = """
    ## Workflows
    ```text
    Read: Source → Summary
    Write: Note → Local storage
    ```
    ```swift
    secretCode() -> forbiddenSource
    ```
    """
    internal static let malformedDiagram = ["Question", "   ├─→ First", "      └─→ Nested", "↓", "Answer"]
    internal static let codeLikeDiagram = ["secretCode() -> forbiddenSource"]
    internal static let incompleteDiagram = ["Question", "↓"]
    internal static let incompleteRoute = "Source → "
    internal static let checkOverview = "Overview prefers its actual README section and preserves bullets"
    internal static let checkOverviewOwnership = "architecture and workflows are excluded from Overview even when nested"
    internal static let checkOverviewFallback = "opening prose supplies Overview when the heading is absent"
    internal static let checkArchitectureOwnership = "Architecture keeps model responsibilities and excludes historical architecture"
    internal static let checkModels = "Models receives documented model facts separately"
    internal static let checkDiagramBranches = "text diagram retains parallel search nodes at one depth"
    internal static let checkDiagramMerge = "both branches connect to the documented merge node"
    internal static let checkDiagramLinear = "text-block arrow routes remain separate connected graphs"
    internal static let checkDiagramCode = "text diagrams never admit executable-looking statements"
    internal static let checkDiagramMalformed = "unsupported nested branch indentation is not guessed"
    internal static let checkDiagramIncomplete = "dangling connectors do not produce partial diagrams"
    internal static let executableName = "TestEntry"
    internal static let identifierKey = "CFBundleIdentifier"
    internal static let testBundlePrefix = "local.projectcontrol.fixture."
    internal static let fixtureExecutable = "#!/bin/sh\nexit 0\n"
    internal static let companion = "Companion"
    internal static let nestedBuild = "build"
    internal static let incompleteApp = "Incomplete"
    internal static let linkedApp = "Linked.app"
    internal static let appSuffix = ".app"
    internal static let checkAppDetection = "only complete top-level contained app bundles are detected"
    internal static let checkAppPreference = "the project-name app wins over its companion"
    internal static let checkAppSingle = "a sole app is an unambiguous automatic target"
    internal static let checkAppAmbiguous = "multiple unmatched apps never cause an arbitrary launch choice"
    internal static let checkAppFingerprint = "app additions and metadata repairs change the snapshot fingerprint"
    internal static let checkAppEscape = "app symlinks and Info.plist links cannot escape the project boundary"
    internal static let checkAppMissing = "removed or nonexecutable apps fail click-time validation"
    internal static let checkManualApp = "a valid manually located app is restored when no automatic app exists"
    internal static let checkAutomaticApp = "a newly discovered project app takes priority over a manual fallback"
    internal static let checkStaleApp = "stale remembered apps are not returned as launch targets"
    internal static let checkClearApp = "forgetting a manually located app preserves the app itself"
    internal static let asciiDiagram = ["Read: Source -> Summary", "Write: Note -> Local storage"]
    internal static let versionedOverview = """
    # Example v1.0
    Opening fallback.
    ## Overview
    The actual project overview.
    ## Architecture
    | Role | Component |
    |---|---|
    | Interface | SwiftUI |
    ## Workflows
    Source → Summary
    """
    internal static let replacementExecutable = "ReplacementEntry"
    internal static let checkAsciiDiagram = "ASCII arrow diagrams remain supported inside text fences"
    internal static let checkVersionedTitle = "a versioned project title does not hide current topic sections"
    internal static let checkAppMetadataReload = "bundle validation reads changed executable metadata without a process restart"
    internal static let checkAppExecutableRefresh = "executable availability and permission changes trigger refresh"
    internal static let checkAppExecutableFile = "an executable directory cannot impersonate an application entry point"
    internal static let checkAppMetadataBound = "oversized bundle metadata is rejected before parsing"
    internal static let repositoryOverview = "Repository overview from its README."
    internal static let updatedRepositoryOverview = "An updated repository overview."
    internal static let checkRepositoryOverview = "repository content comes from the root README overview"
    internal static let checkRepositoryOverviewRefresh = "root README edits update the repository screen content"
    internal static let modelTables = """
    ## Local architecture

    | Responsibility | Embedded component |
    |---|---|
    | Interface | SwiftUI |
    | Chat | Qwen3-4B Q4_K_M GGUF |
    | Speech | Whisper Small |

    | Model | Path |
    |---|---|
    | Qwen3-4B | `gguf/Qwen3-4B-Q4_K_M.gguf` |
    """
    internal static let modelHeaders = ["Responsibility", "Embedded component"]
    internal static let pathHeaders = ["Model", "Path"]
    internal static let modelPath = "gguf/Qwen3-4B-Q4_K_M.gguf"
    internal static let inlineIdentifiers = "__Models__: `Q4_K_M` and `whisper/openai_whisper-small/` and `_private_`"
    internal static let expectedIdentifiers = "Models: Q4_K_M and whisper/openai_whisper-small/ and _private_"
    internal static let rawTableSeparator = "|---|"
    internal static let adjacentTable = """
    ## Models
    Before.
    | Model | Path |
    |---|---|
    | Qwen | local_model.gguf |
    After.
    """
    internal static let adjacentProse = ["Before.", "After."]
    internal static let escapedTable = """
    ## Overview

    | Field | Value
    |---|---
    | Name | Left \\| right
    """
    internal static let checkStructuredTables = "tables retain headers and separate native column data"
    internal static let checkModelTableRows = "model tables contain model rows without unrelated architecture or duplicated headers"
    internal static let checkTableProseLeak = "a leading blank line cannot turn a Markdown table into prose"
    internal static let checkModelIdentifiers = "model names and code-span paths retain literal underscores"
    internal static let checkAdjacentTable = "prose directly beside a table stays separate and is not lost"
    internal static let checkOverviewTable = "Overview retains the source order of paragraphs, native tables, and bullets"
    internal static let checkLiveTables = "Local Assistant models contain native tables and no raw Markdown table paragraph"
    internal static let checkIconFolderMatch = "project icon selection falls back to the matching folder-name app"
    internal static let checkIconFallback = "a project without an app has no invented brand icon"
    internal static let checkRepositorySelection = "the repository parent is selectable and survives refresh"
    internal static let checkProjectSelection = "a selected project survives refresh under its repository parent"
    internal static let checkSelectionFallback = "a removed selection returns to the repository parent"
    internal static let historyDate = "2026-08-30"
    internal static let datedRootHeading = "Example · 2026-08-30"
    internal static let datedVersionHeading = "v0.1 · 2026-08-30"
    internal static let rootHistoryDetail = "Added notes. Added history."
    internal static let datedHistory = """
    ## Change log
    | Version | Date | Updates |
    |---|---|---|
    | v0.1 | 2026-08-30 | Initial implementation |
    | v0.0 | | Initial implementation |
    """
    internal static let mixedArchitecture = """
    ## Workflow architecture and retries
    | Model | Path |
    |---|---|
    | Orchestration | LangGraph |
    | Chat | Qwen3 |
    | Retrieval | RAG and vectors |
    - Input → Output
    ## Workflows
    - Another → Route
    ## Release history
    ### Architecture
    | Old | Component |
    |---|---|
    | Obsolete | Missing |
    """
    internal static let mixedSteps = ["Input", "Output"]
    internal static let checkCompleteArchitecture = "Architecture retains every source table row and header, including models and RAG"
    internal static let checkMixedArchitecture = "mixed architecture/workflow headings preserve architecture content and explicit diagrams"
    internal static let checkModelSecondary = "Models is a secondary extract without removing architecture rows"
    internal static let checkHistoryHeading = "history date appears next to the project or version title"
    internal static let checkHistoryDateBody = "history description no longer repeats its standalone date"
    internal static let checkUndatedHistory = "undated and two-column history retains its original content"
    internal static let checkAllArchitecture = "architecture table is present for "
    internal static let checkArchitectureCoverage = "architecture table includes "
    internal static let checkArchitectureGroups = "architecture categories remain ordered for "
    internal static let checkArchitectureGroupTable = "architecture category owns a nonempty native table: "
    internal static let architectureGroupTitles = [
        "AI & Intelligence", "Frontend & Presentation", "Backend & Application Logic",
        "Data & Storage", "Integrations & Security", "Build & Delivery"
    ]
    internal static let architectureGroupOrder = [
        "Local Assistant": [0, 1, 2, 3, 4],
        "Prospect Copilot": [0, 1, 2, 3, 4],
        "OpenClaw": [0, 2, 3, 4],
        "Python Accomplishments": [0, 1, 2, 3, 4, 5],
        "Knowledge Transfer": [1, 2, 3, 5],
        "Project Control": [1, 2, 3, 4]
    ]
    internal static let architectureCoverage = [
        "Local Assistant": ["Native Swift", "Qwen3-4B", "Qwen3-Embedding", "llama.cpp", "RAG", "IndexingService", "SQLite", "FTS5", "sqlite-vec", "WhisperKit", "Connector"],
        "Prospect Copilot": ["Next.js", "LangGraph", "LangChain", "DeepSeek", "scoring", "IndexedDB"],
        "OpenClaw": ["OpenClaw runtime", "Ollama", "ChromaDB", "CloudBase", "iCloud", "A2A"],
        "Knowledge Transfer": ["Markdown", "Canvas", "React", "TypeScript", "Vite", "Three.js", "Search"],
        "Python Accomplishments": ["Python", "Polly", "Watson", "Tkinter", "Playwright", "Selenium", "PyInstaller"],
        "Project Control": ["SwiftUI", "ControlStore", "RepositoryReader", "ReadmeParser", "WorkspaceStorage", "History"]
    ]
}
