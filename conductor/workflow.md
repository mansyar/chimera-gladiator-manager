# Project Workflow

## Guiding Principles

1. **The Plan is the Source of Truth:** All work must be tracked in `plan.md`
2. **The Tech Stack is Deliberate:** Changes to the tech stack must be documented in `tech-stack.md` *before* implementation
3. **Test-Driven Development:** Write unit tests before implementing functionality. TDD applies to source code with testable logic/flow only — config files (`.json`, `.cfg`, `.tres`), data resources, and documentation (`.md`) are exempt.
4. **High Code Coverage:** Aim for >80% code coverage for all source code modules with testable logic
5. **User Experience First:** Every decision should prioritize user experience
6. **Non-Interactive & CI-Aware:** Prefer non-interactive commands. Use `CI=true` for watch-mode tools (tests, linters) to ensure single execution.

## Task Workflow

All tasks follow a strict lifecycle:

### Standard Task Workflow

1. **Select Task:** Choose the next available task from `plan.md` in sequential order

2. **Mark In Progress:** Before beginning work, edit `plan.md` and change the task from `[ ]` to `[~]`

3. **Write Failing Tests (Red Phase):**
   - **Scope:** This step applies to `.gd` source files with testable logic/flow. Skip for config files, data resources (`.tres`, `.json`), and documentation.
   - Create a new test file for the feature or bug fix.
   - Write one or more unit tests that clearly define the expected behavior and acceptance criteria for the task.
   - **CRITICAL:** Run the tests and confirm that they fail as expected. This is the "Red" phase of TDD. Do not proceed until you have failing tests.

4. **Implement to Pass Tests (Green Phase):**
   - Write the minimum amount of application code necessary to make the failing tests pass.
   - Run the test suite again and confirm that all tests now pass. This is the "Green" phase.

5. **Refactor (Optional but Recommended):**
   - With the safety of passing tests, refactor the implementation code and the test code to improve clarity, remove duplication, and enhance performance without changing the external behavior.
   - Rerun tests to ensure they still pass after refactoring.

6. **Verify Coverage:** Run coverage reports using gd-tools:
   ```bash
   gd-tools test --coverage --min 80
   ```
   Target: >80% coverage for new source code with testable logic.

7. **Document Deviations:** If implementation differs from tech stack:
   - **STOP** implementation
   - Update `tech-stack.md` with new design
   - Add dated note explaining the change
   - Resume implementation

8. **Commit Code Changes:**
   - Stage all code changes related to the task.
   - Propose a clear, concise commit message e.g, `feat(combat): Implement berserk state trigger`.
   - Perform the commit.

9. **Attach Task Summary with Git Notes:**
   - **Step 9.1: Get Commit Hash:** Obtain the hash of the *just-completed commit* (`git log -1 --format="%H"`).
   - **Step 9.2: Draft Note Content:** Create a detailed summary for the completed task. This should include the task name, a summary of changes, a list of all created/modified files, and the core "why" for the change.
   - **Step 9.3: Attach Note:** Use the `git notes` command to attach the summary to the commit.
     ```bash
     # The note content from the previous step is passed via the -m flag.
     git notes add -m "<note content>" <commit_hash>
     ```

10. **Get and Record Task Commit SHA:**
    - **Step 10.1: Update Plan:** Read `plan.md`, find the line for the completed task, update its status from `[~]` to `[x]`, and append the first 7 characters of the *just-completed commit's* commit hash.
    - **Step 10.2: Write Plan:** Write the updated content back to `plan.md`.

11. **Commit Plan Update:**
    - **Action:** Stage the modified `plan.md` file.
    - **Action:** Commit this change with a descriptive message (e.g., `conductor(plan): Mark task 'Create ChimeraData resource' as complete`).

### Phase Completion Verification and Checkpointing Protocol

**Trigger:** This protocol is executed immediately after a task is completed that also concludes a phase in `plan.md`.

1.  **Announce Protocol Start:** Inform the user that the phase is complete and the verification and checkpointing protocol has begun.

2.  **Ensure Test Coverage for Phase Changes:**
    -   **Step 2.1: Determine Phase Scope:** To identify the files changed in this phase, you must first find the starting point. Read `plan.md` to find the Git commit SHA of the *previous* phase's checkpoint. If no previous checkpoint exists, the scope is all changes since the first commit.
    -   **Step 2.2: List Changed Files:** Execute `git diff --name-only <previous_checkpoint_sha> HEAD` to get a precise list of all files modified during this phase.
    -   **Step 2.3: Verify and Create Tests:** For each file in the list:
        -   **CRITICAL:** First, check its extension. Exclude non-code files (e.g., `.json`, `.md`, `.yaml`, `.tres`, `.cfg`, `.import`).
        -   Additionally, source files without testable logic (e.g., pure enum definitions, data resource classes with only `@export` variables) do not require test files.
        -   For each remaining code file with testable logic, verify a corresponding test file exists.
        -   If a test file is missing, you **must** create one. Before writing the test, **first, analyze other test files in the repository to determine the correct naming convention and testing style.** The new tests **must** validate the functionality described in this phase's tasks (`plan.md`).

3.  **Execute Automated Tests with Proactive Debugging:**
    -   Before execution, you **must** announce the exact shell command you will use to run the tests.
    -   **Example Announcement:** "I will now run the automated test suite to verify the phase. **Command:** `gd-tools test --coverage --min 80`"
    -   Execute the announced command.
    -   If tests fail, you **must** inform the user and begin debugging. You may attempt to propose a fix a **maximum of two times**. If the tests still fail after your second proposed fix, you **must stop**, report the persistent failure, and ask the user for guidance.

4.  **Propose a Detailed, Actionable Manual Verification Plan:**
    -   **CRITICAL:** To generate the plan, first analyze `product.md`, `product-guidelines.md`, and `plan.md` to determine the user-facing goals of the completed phase.
    -   You **must** generate a step-by-step plan that walks the user through the verification process, including any necessary commands and specific, expected outcomes.
    -   The plan you present to the user **must** follow this format:

        **For a Game Logic Change:**
        ```
        The automated tests have passed. For manual verification, please follow these steps:

        **Manual Verification Steps:**
        1.  **Open the project in Godot 4.5+:** `godot --editor`
        2.  **Run the relevant scene:** Open `<scene_path>` and press F6
        3.  **Confirm that you see:** The chimera renders with correct part sprites and strain colors.
        ```

        **For a System/Manager Change:**
        ```
        The automated tests have passed. For manual verification, please follow these steps:

        **Manual Verification Steps:**
        1.  **Run the GUT test suite:** `gd-tools test`
        2.  **Confirm that you see:** All tests passing with no failures.
        3.  **Open the project in Godot:** Verify the singleton autoloads load in the correct order (EventBus -> GameState -> SaveManager -> CombatManager).
        ```

5.  **Await Explicit User Feedback:**
    -   After presenting the detailed plan, ask the user for confirmation: "**Does this meet your expectations? Please confirm with yes or provide feedback on what needs to be changed.**"
    -   **PAUSE** and await the user's response. Do not proceed without an explicit yes or confirmation.

6.  **Create Checkpoint Commit:**
    -   Stage all changes. If no changes occurred in this step, proceed with an empty commit.
    -   Perform the commit with a clear and concise message (e.g., `conductor(checkpoint): Checkpoint end of Phase X`).

7.  **Attach Auditable Verification Report using Git Notes:**
    -   **Step 7.1: Draft Note Content:** Create a detailed verification report including the automated test command, the manual verification steps, and the user's confirmation.
    -   **Step 7.2: Attach Note:** Use the `git notes` command and the full commit hash from the previous step to attach the full report to the checkpoint commit.

8.  **Get and Record Phase Checkpoint SHA:**
    -   **Step 8.1: Get Commit Hash:** Obtain the hash of the *just-created checkpoint commit* (`git log -1 --format="%H"`).
    -   **Step 8.2: Update Plan:** Read `plan.md`, find the heading for the completed phase, and append the first 7 characters of the commit hash in the format `[checkpoint: <sha>]`.
    -   **Step 8.3: Write Plan:** Write the updated content back to `plan.md`.

9. **Commit Plan Update:**
    - **Action:** Stage the modified `plan.md` file.
    - **Action:** Commit this change with a descriptive message following the format `conductor(plan): Mark phase '<PHASE NAME>' as complete`.

10.  **Announce Completion:** Inform the user that the phase is complete and the checkpoint has been created, with the detailed verification report attached as a git note.

### Quality Gates

Before marking any task complete, verify:

- [ ] All tests pass
- [ ] Code coverage meets requirements (>80% for source code with testable logic)
- [ ] Code follows project's code style guidelines (as defined in `code_styleguides/`)
- [ ] All public functions/methods are documented (GDScript `##` doc comments)
- [ ] Type safety is enforced (GDScript typed variables and return types)
- [ ] No linting or static analysis errors (`gd-tools lint`)
- [ ] Code is properly formatted (`gd-tools format --check`)
- [ ] Documentation updated if needed
- [ ] No security vulnerabilities introduced

## Development Commands

### Setup
```bash
# One-time setup (TRACK-001): installs GUT, coverage addon, generates configs
gd-tools init

# Verify environment (9 checks, must exit 0)
gd-tools doctor
```

### Daily Development
```bash
# Lint all .gd files
gd-tools lint

# Verify gdformat compliance (does NOT modify files)
gd-tools format --check

# Run GUT tests with 80% coverage gate
gd-tools test --coverage --min 80
```

### Before Committing
```bash
# Full pre-commit verification (order matters: lint -> format -> test)
gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80
```

## Testing Requirements

### TDD Scope

TDD applies to `.gd` source files containing testable logic or flow. The following are **exempt** from TDD and testing requirements:

- **Config files:** `.json`, `.cfg`, `.tres`, `.import`
- **Documentation:** `.md` files
- **Pure data/enum definitions:** Files containing only enum declarations or `@export` variable definitions without logic (e.g., `GameEnums.gd`, pure `Resource` subclasses with only exported properties)

### Unit Testing
- Every source code module with testable logic must have corresponding tests.
- Test files live in `res://tests/`, mirroring `scripts/` structure.
- Use GUT (Godot Unit Test) framework with `describe`/`it` or `assert_eq` patterns.
- Mock external dependencies (autoload singletons, file I/O, network).
- Test both success and failure cases.
- Test edge cases (boundary values, empty inputs, maximum values).

### Integration Testing
- Test complete system flows (e.g., economy transactions, combat resolution)
- Verify singleton autoload interaction (EventBus -> GameState -> SaveManager -> CombatManager)
- Test save/load cycles with JSON serialization
- Verify signal emissions and handler responses

## Code Review Process

### Self-Review Checklist
Before requesting review:

1. **Functionality**
   - Feature works as specified in `plan.md`
   - Edge cases handled
   - Error messages are user-friendly

2. **Code Quality**
   - Follows style guide (`code_styleguides/general.md`)
   - DRY principle applied
   - Clear variable/function names (snake_case per GDScript convention)
   - Appropriate `##` doc comments on public functions

3. **Testing**
   - Unit tests comprehensive for testable logic
   - Integration tests pass for system flows
   - Coverage adequate (>80% for source code with logic)

4. **Architecture Compliance**
   - ChimeraData (persistent Resource) vs CombatState (transient RefCounted) separation maintained
   - Part slots use 4 separate `@export var` (not typed Dictionary)
   - PartData references abilities by `ability_id: String` (not embedded AbilityData)
   - Movement uses `velocity = direction * speed` then `move_and_slide()` (no delta multiplication)
   - Autoload order: EventBus -> GameState -> SaveManager -> CombatManager
   - System scripts are static utility classes (pure functions, no state)
   - EventBus for global signals, direct signals for local parent-child

5. **Performance**
   - No unnecessary node instantiation in `_process` or `_physics_process`
   - Particle VFX use strain-themed mapping correctly
   - Save files use reference-based storage (shape_id + strain + rarity, not full data)

## Commit Guidelines

### Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Maintenance tasks

### Examples
```bash
git commit -m "feat(combat): Implement berserk state trigger"
git commit -m "fix(economy): Correct part decay calculation for rare rarity"
git commit -m "test(chimera): Add tests for genetic instability purebred bonus"
git commit -m "style(ui): Fix panel margin alignment"
```

## Definition of Done

A task is complete when:

1. All code implemented to specification
2. Unit tests written and passing (for source code with testable logic)
3. Code coverage meets project requirements (>80% for testable source code)
4. Documentation complete (if applicable)
5. Code passes all configured linting and static analysis checks (`gd-tools lint`)
6. Code is properly formatted (`gd-tools format --check`)
7. Implementation notes added to `plan.md`
8. Changes committed with proper message
9. Git note with task summary attached to the commit

## Emergency Procedures

### Critical Bug in Released Build
1. Create hotfix branch from main
2. Write failing test for bug
3. Implement minimal fix
4. Test thoroughly
5. Re-export build
6. Document in plan.md

### Save Data Corruption
1. Stop all write operations to `user://saves/`
2. Restore from latest backup
3. Verify save data integrity (JSON schema validation)
4. Document incident
5. Update save/load procedures

### Security Breach
1. Rotate all secrets immediately
2. Review access logs
3. Patch vulnerability
4. Document and update security procedures

## Export Workflow

### Pre-Export Checklist
- [ ] All tests passing (`gd-tools test`)
- [ ] Coverage >80% (`gd-tools test --coverage --min 80`)
- [ ] No linting errors (`gd-tools lint`)
- [ ] Format check passes (`gd-tools format --check`)
- [ ] Godot project settings configured (window size, renderer, icon)
- [ ] Export presets configured for target platforms

### Export Steps
1. Merge feature branch to main
2. Tag release with version
3. Configure Godot export presets for target platform(s)
4. Run Godot export (`godot --export-release "preset_name"`)
5. Verify exported build runs correctly
6. Test critical game paths (new game, combat, save/load)
7. Distribute build

### Post-Export
1. Gather user feedback
2. Check for crash reports
3. Plan next iteration

## Continuous Improvement

- Review workflow weekly
- Update based on pain points
- Document lessons learned
- Optimize for user happiness
- Keep things simple and maintainable
