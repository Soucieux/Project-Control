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
    internal static let checkLiveFlows = "Local Assistant has five documented request routes"
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
}
