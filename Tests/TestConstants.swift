import Foundation

/// Synthetic, credential-free fixtures for the README and persistence boundary.
internal enum TestConstants {
    internal static let classifiedRoot = """
    # Classified repository
    ## Projects
    | Project | Scope |
    |---|---|
    | [Example](Example/) | <ul><li><strong>cAtEgOrY:</strong> Management</li><li><strong>Technical scope:</strong> **Native desktop**</li><li><strong>Technologies:</strong> **SwiftUI**; ; README-driven; swiftui;</li><li><strong>Product:</strong> Primary tool.</li></ul> |
    | [Missing](Missing/) | <ul><li><strong>Category:</strong> AI Applications</li><li><strong>Technical scope:</strong> Full-stack web</li><li><strong>Technologies:</strong> Next.js; LangGraph; Hosted AI</li><li><strong>Product:</strong> Hosted service.</li></ul> |
    | [Another](Another/) | <ul><li><strong>Category:</strong> AI Applications</li><li><strong>Technical scope:</strong> Native desktop</li><li><strong>Technologies:</strong> Local AI; RAG; C++; model_name-v1</li><li><strong>Product:</strong> Local assistant.</li></ul> |
    | [Blank](Blank/) | <ul><li><strong>Category:</strong></li><li><strong>Technical scope:</strong></li><li><strong>Technologies:</strong> ; ;</li><li><strong>Product:</strong> Metadata not yet documented.</li></ul> |
    | [Short](Short/) | Legacy short row. |
    | [Example](Example/) | <ul><li><strong>Category:</strong> Wrong</li><li><strong>Technical scope:</strong> Wrong</li><li><strong>Technologies:</strong> Wrong</li><li><strong>Product:</strong> Duplicate row.</li></ul> |
    """
    internal static let legacyClassifiedRoot = """
    # Legacy classified repository
    ## Projects
    | Project | Scope | tEcHnOlOgIeS | cAtEgOrY | Technical scope | AI usage |
    |---|---|---|---|---|---|
    | [Example](Example/) | Primary tool. | **SwiftUI**; ; README-driven; swiftui; | Management | **Native desktop** | No AI |
    | [Missing](Missing/) | Hosted service. | Next.js; LangGraph; Hosted AI | AI Applications | Full-stack web | Hosted AI |
    | [Another](Another/) | Local assistant. | Local AI; RAG; C++; model_name-v1 | AI Applications | Native desktop | Local AI |
    | [Blank](Blank/) | Metadata not yet documented. | ; ; | | | Not documented |
    | [Short](Short/) | Legacy short row. |
    """
    internal static let classificationDirectory = "Classification"
    internal static let managementCategory = "Management"
    internal static let aiCategory = "AI Applications"
    internal static let renamedCategory = "Custom category"
    internal static let desktopScope = "Native desktop"
    internal static let fullStackScope = "Full-stack web"
    internal static let swiftUI = "SwiftUI"
    internal static let readmeDriven = "README-driven"
    internal static let hostedAI = "Hosted AI"
    internal static let legacyScope = "Primary tool."
    internal static let conflictingLegacyScope = "<strong>Category:</strong> Wrong<br><strong>Technical scope:</strong> Wrong<br><strong>Technologies:</strong> Wrong<br>Primary tool."
    internal static let classifiedTagsCell = "<strong>Technologies:</strong> **SwiftUI**; ; README-driven; swiftui;"
    internal static let emptyClassifiedTagsCell = "<strong>Technologies:</strong>"
    internal static let tagsHeader = "tEcHnOlOgIeS"
    internal static let ignoredTagsHeader = "Legacy technologies"
    internal static let classificationOnly = "--classification"
    internal static let activityOnly = "--activity"
    internal static let activityTimestamps = ["1705276800", "1705708800", "1714521600", "1796083200", "invalid"]
    internal static let activityNow = "2026-09-01T00:00:00Z"
    internal static let hostedTechnologyTags = ["Next.js", "LangGraph", "Hosted AI"]
    internal static let literalTechnologyTags = ["Local AI", "RAG", "C++", "model_name-v1"]
    internal static let registerRowPrefix = "| ["
    internal static let registerLinkSeparator = "]("
    internal static let externalLinkMarker = "://"
    internal static let registerCategoryLabel = "<strong>Category:</strong>"
    internal static let registerTechnologiesLabel = "<strong>Technologies:</strong>"
    internal static let registerItemEnd = "</li>"
    internal static let checkClassification = "scope labels are read case-insensitively and rendered as plain text"
    internal static let checkClassificationCompatibility = "legacy classification columns remain supported and override conflicting scope labels"
    internal static let checkClassificationGroups = "categories and members retain first appearance without duplicating projects"
    internal static let checkClassificationUnknown = "absent, blank, and short metadata creates no technology or absence tags"
    internal static let checkTechnologyTags = "technology tags preserve literal names and first order while trimming blanks and case-insensitive duplicates"
    internal static let checkLegacyAI = "the retired AI usage column never creates tags or overrides an explicit empty technology list"
    internal static let checkTechnologyRemoval = "technology tags clear independently without losing the category or technical scope"
    internal static let checkLiveTechnologyTags = "registered projects show only their documented technologies and approaches: "
    internal static let checkClassificationRefresh = "root metadata edits regroup existing path identities without a rebuild"
    internal static let checkClassificationStale = "root classification refreshes and clears while project details remain stale"
    internal static let checkLiveCategories = "registered projects group into their register categories in first-appearance order"
    internal static let checkActivityTotal = "activity total includes every loaded timestamp record"
    internal static let checkActivityYears = "activity uses newest-first distinct valid years with twelve months each"
    internal static let checkActivityMonths = "valid timestamps increment their exact calendar months"
    internal static let checkActivityIntensity = "activity intensity uses fixed absolute thresholds"
    internal static let checkActivityFuture = "only months strictly later than the current month are future"
    internal static let checkActivityUnavailable = "non-Git folders expose activity as unavailable"
    internal static let checkActivityLive = "the selected Git repository exposes reachable commit timestamps and ref identity"
    internal static let checkActivityDistribution = "changed paths map each commit once to every affected registered project"
    internal static let checkActivityStore = "the store publishes loaded commit activity without recalculating it"
    internal static let technologyNames = [
        "Local Assistant": ["Retrieval-Augmented Generation (RAG)", "Embeddings", "Qwen3-4B Q4_K_M", "Qwen3-Embedding-0.6B Q8_0", "llama.cpp", "GGUF", "Whisper Small", "WhisperKit", "Core ML", "Optical character recognition (OCR)", "Apple Vision", "SwiftUI", "AppKit", "Swift", "Foundation", "Indexing", "CoreServices", "PDFKit", "ZIPFoundation", "SQLite", "SQLite FTS5", "sqlite-vec", "Security-scoped bookmarks", "App Sandbox", "Agent-to-Agent (A2A)", "SSH"],
        "Prospect Copilot": ["LangGraph", "LangChain", "DeepSeek deepseek-chat", "BANT", "MEDDIC", "React", "React DOM", "Next.js", "TypeScript", "react-markdown", "remark-gfm", "Node.js", "Zod", "Cheerio", "Bounded concurrency", "Composite scoring", "IndexedDB", "idb-keyval", "localStorage", "Server-sent events (SSE)", "OpenAI-compatible API", "ipaddr.js", "Server-side request forgery (SSRF) protection"],
        "OpenClaw": ["OpenClaw runtime", "Embeddings", "Ollama", "nomic-embed-text", "Python", "Bash", "cron", "Markdown", "Builtin SQLite memory", "Tencent CloudBase", "iCloud Calendar", "Agent-to-Agent (A2A)", "Feishu", "Reusable skills"],
        "Python Accomplishments": ["Amazon Polly", "IBM Watson Speech to Text", "Tkinter", "Python", "Selenium", "Beautiful Soup", "Playwright", "tenacity", "openpyxl", "python-docx", "pathlib", "natsort", "CSV", "boto3", "ibm-watson", "ibm-cloud-sdk-core", "SMTP", "python-dotenv", "pip", "PyInstaller"],
        "Knowledge Transfer": ["React", "React DOM", "TypeScript", "react-markdown", "remark-gfm", "rehype-raw", "rehype-sanitize", "prism-react-renderer", "Three.js", "React Router", "mdast-util-from-markdown", "mdast-util-to-string", "Text search", "Source-derived graph", "Markdown", "Obsidian Canvas", "JSON", "Vite", "JavaScript", "Node.js", "HTML", "Vitest"],
        "Project Control": ["SwiftUI", "AppKit", "Swift", "Swift concurrency", "Foundation", "Directed graphs", "Markdown", "JSON", "UserDefaults", "CryptoKit", "Uniform Type Identifiers", "Canonical path validation"]
    ]
    internal static let mappedReadme = """
    # Example
    Unselected opening text.
    <!-- project-control:section=overview -->
    ## Introduction with a different name
    A quiet project management tool.
    <!-- project-control:section=architecture -->
    ## Technical design
    ### Frontend & Presentation
    | Technology or concept | Use in this project |
    |---|---|
    | React | Interactive interface. |
    | TypeScript | Typed application code. |
    <!-- project-control:section=ignore -->
    ### Private maintenance
    secretCode
    <!-- project-control:section=models -->
    #### Hidden nested model
    secretCode
    ## Architecture outside mapping
    secretCode
    <!-- project-control:section=models -->
    ## Model inventory
    | Model | Use |
    |---|---|
    | Example-model | Local answering. |
    <!-- project-control:section=release -->
    ## Shipped identity
    Current release: v0.8 (build 8).
    <!-- project-control:section=workflows -->
    ## Processing stages
    Input → Output
    <!-- project-control:section=history -->
    ## Previous changes
    | Version | Date | Changes |
    |---|---|---|
    | v0.1 | 2026-08-30 | Initial implementation |
    <!-- project-control:section=architecture -->
    ### Historical implementation
    secretCode
    ```markdown
    <!-- project-control:section=unknown -->
    ## Inert example
    ```
    """
    internal static let mappedRoot = """
    # Example repository
    <!-- project-control:section=overview -->
    ## Repository introduction
    Repository overview from its README.
    <!-- project-control:section=projects -->
    ## Managed applications
    | Project | Scope |
    |---|---|
    | [Example](Example/) | Sample scope. |
    <!-- project-control:section=history -->
    ## Recorded changes
    | Project | Date | Updates |
    |---|---|---|
    | Example | 2026-08-30 | Initial implementation |
    """
    internal static let mappedWithoutArchitecture = """
    # Example
    <!-- project-control:section=overview -->
    ## Overview
    A changed introduction.
    ## Architecture
    This unmarked section must not appear.
    """
    internal static let invalidMappings = [
        "<!-- project-control:section=unknown -->\n## Unknown",
        "<!-- project-control:section=architecture -->",
        "<!-- project-control:section=architecture -->\nProse before heading.\n## Design",
        "<!-- project-control:section=architecture -->\n<!-- project-control:section=models -->\n## Design",
        "<!-- project-control:section=architecture-->\n## Design"
    ]
    internal static let mappedTechnologyNames = ["React", "TypeScript"]
    internal static let mappedVersion = "v0.8 (build 8)"
    internal static let mappedHeading = "Technical design"
    internal static let renamedMappedHeading = "Renamed technology inventory"
    internal static let modelName = "Example-model"
    internal static let mappedProjectRow = "| [Example](Example/) | Sample scope. |\n"
    internal static let mappedSecondRow = "| [Missing](Missing/) | Another project. |\n"
    internal static let digestBefore = "A quiet project management tool."
    internal static let digestAfter = "A quiet project management test."
    internal static let checkMapping = "stable mapping survives renamed headings and excludes unmapped/ignored content"
    internal static let checkMappingFailure = "invalid mappings are rejected rather than silently routed"
    internal static let checkMappedRelease = "mapped release wins without leaking historical version numbers"
    internal static let checkMappedRoot = "renamed root sections populate navigation, overview, and history"
    internal static let checkDigest = "content fingerprints detect equal-length edits with preserved timestamps"
    internal static let checkEmptyRegister = "a valid empty register removes every project"
    internal static let checkTechnologyRows = "each technology has exactly one individually named architecture row: "
    internal static let checkStaleProject = "invalid or missing project README retains visibly stale last-good content"
    internal static let checkProjectRecovery = "valid recovery clears warnings and applies section deletions"
    internal static let checkStaleRoot = "root failures retain the last snapshot with persistent stale state"
    internal static let checkSyncNotes = "refresh preserves project selection and private work notes"
    internal static let checkIndependentSync = "one broken project does not prevent other README updates"
    internal static let checkInitialRecovery = "automatic observation recovers from a failed initial root read"
    internal static let checkSourceMapping = "registered README has valid explicit content mappings: "
    internal static let registerChildTable = """
    ### Extended description
    | Reference | Description |
    |---|---|
    | [Outside](../Outside/) | Not a project registration. |

    """
    internal static let mappedHistoryMarker = "<!-- project-control:section=history -->"
    internal static let checkRegisterChildren = "descriptive child tables cannot become project registrations"
    internal static let registerHeader = "| Project | Scope |\n"
    internal static let raceDirectory = "PollingRace"
    internal static let checkPollingRace = "a completed old-root poll cannot queue over an active repository switch"
    internal static let checkWrongRootWarning = "a failed different-root selection does not mark current content stale"
    internal static let checkRegisterHeader = "a register without a table header is not a valid empty register"
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
    internal static let checkAppFolderMatch = "Open App selection falls back to the matching folder-name app"
    internal static let checkAppFallback = "a project without an app has no invented Open App target"
    internal static let checkIconIdentity = "a project folder that still resolves to its identity shows its own icon"
    internal static let checkIconRetarget = "a retargeted project alias never lends another folder's icon"
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
        "OpenClaw": ["OpenClaw runtime", "Ollama", "Builtin SQLite memory", "CloudBase", "iCloud", "A2A"],
        "Knowledge Transfer": ["Markdown", "Canvas", "React", "TypeScript", "Vite", "Three.js", "Search"],
        "Python Accomplishments": ["Python", "Polly", "Watson", "Tkinter", "Playwright", "Selenium", "PyInstaller"],
        "Project Control": ["SwiftUI", "ControlStore", "RepositoryReader", "ReadmeParser", "WorkspaceStorage", "History"]
    ]
}
