# AGENTS.md

Instructions for AI coding agents working on a **macOS Swift app** bootstrapped from **macskeleton**.

## Project overview

- **What this is:** A native macOS app template. The default placeholder app shows a single SwiftUI window. Replace it with your product logic.
- **Platform:** macOS 14 (Sonoma) or later. Swift Package Manager project; no Xcode project file.
- **License:** MIT
- **Template repo:** https://github.com/andresousadotpt/macskeleton

## Bootstrap checklist (new app from skeleton)

When creating a new app, update **all** of the following. Keep names consistent across files.

| Step | File / path | What to change |
| ---- | ----------- | -------------- |
| 1 | `packaging/app.env` | All identity variables (primary config for CI + packaging) |
| 2 | `packaging/Info.plist` | `CFBundleName`, `CFBundleDisplayName`, `CFBundleExecutable`, `CFBundleIdentifier`, copyright |
| 3 | `Package.swift` | Package name, product name, target names |
| 4 | `Sources/MyApp/` → `Sources/{AppName}/` | Rename directory and `@main` app file |
| 5 | `Sources/MyAppCore/` → `Sources/{AppName}Core/` | Rename directory |
| 6 | `Tests/MyAppCoreTests/` → `Tests/{AppName}CoreTests/` | Rename directory and imports |
| 7 | `README.md` | App name, description, install URLs |
| 8 | `CHANGELOG.md` | App name and initial release notes |
| 9 | `.github/ISSUE_TEMPLATE/config.yml` | Support/security URLs (if repo URL changed) |
| 10 | GitHub repo | Create new repo; add `HOMEBREW_TAP_TOKEN` secret for releases |

### `packaging/app.env` reference

```bash
APP_BUNDLE_NAME=myapp          # dist/myapp.app (lowercase bundle folder)
APP_EXECUTABLE=MyApp           # SPM executable target; also CFBundleExecutable
APP_PACKAGE=MyApp              # Package.swift name
APP_CORE=MyAppCore             # Core target name
APP_DISPLAY_NAME=MyApp         # Human-readable name (Homebrew cask)
APP_BUNDLE_ID=com.example.myapp
APP_SUPPORT_DIR=MyApp          # ~/Library/Application Support/MyApp
GITHUB_OWNER=andresousadotpt
GITHUB_REPO=myapp              # GitHub repo name (not full URL)
CASK_NAME=myapp                # Homebrew cask name
HOMEBREW_TAP=andresousadotpt/homebrew-tap
```

**Do not rename** `Makefile`, `packaging/build-app.sh`, `packaging/bump-version.sh`, or workflow files — they read from `app.env`.

After bootstrap:

```bash
make build && make test && make app
```

## Architecture

Two Swift targets with strict separation of concerns:

| Target | Role | Depends on |
|--------|------|------------|
| **MyAppCore** | Models, persistence, pure logic (no UI) | Foundation only |
| **MyApp** | SwiftUI views, AppKit bridges, app shell | MyAppCore |

```
Sources/
├── MyAppCore/          # Testable, UI-free core
│   ├── Models/
│   ├── Services/
│   └── Utilities/
└── MyApp/              # macOS app shell
    ├── MyAppApp.swift  # @main entry
    ├── ViewModels/
    ├── Views/
    ├── Support/        # AppKit bridges
    └── Resources/      # Logo.png (optional; auto-generates icon if missing)
```

### Key design choices

- **View models** should use `@MainActor @Observable` (Observation framework, not Combine).
- **Persistence** should use `actor` types for thread-safe file I/O when you add storage.
- **File writes** should go through atomic write helpers — never write user data files directly in place.
- **App config** typically lives at `~/Library/Application Support/{APP_SUPPORT_DIR}/`.

### UI stack

- **SwiftUI** for windows and settings.
- **AppKit** only where SwiftUI is insufficient (`NSViewRepresentable`, menu bar, custom text views).

## Build and run

All commands run from the repo root:

```bash
make build    # swift build (debug)
make run      # build + swift run (uses APP_EXECUTABLE from app.env)
make test     # swift test — requires full Xcode, not Command Line Tools alone
make app      # release .app bundle in ./dist/
make clean    # remove .build/ and dist/
```

### Important runtime gotchas

1. **Features that require a `.app` bundle** (notifications, some entitlements) only work after `make app`, not `make run` / `swift run`.
2. **Version source of truth:** `packaging/Info.plist` (`CFBundleShortVersionString`).

## Testing

Tests live in `Tests/MyAppCoreTests/` and target **MyAppCore only**. UI and AppKit code is not unit-tested.

```bash
make test
swift test --filter MyAppCoreTests.testMarketingVersionIsNonEmpty
```

Use temporary directories for file I/O tests and clean up in `defer`. Prefer deterministic dates over `Date()` when testing time-based logic.

## Code style and conventions

### Swift language

- **Swift tools version:** 6.0 (`Package.swift`).
- **Minimum deployment:** macOS 14.
- Prefer `Sendable`, `Codable`, and `Equatable` on models in MyAppCore.
- Use `public` on MyAppCore types consumed by the app target.
- Mark UI-only types `internal` (default) in MyApp.

### Naming and organization

- New **models/settings** → `Sources/MyAppCore/Models/`
- New **file I/O or config logic** → `Sources/MyAppCore/Services/` or `Utilities/`
- New **screens** → `Sources/MyApp/Views/`
- New **AppKit bridges** → `Sources/MyApp/Support/`

### Patterns to avoid

- Do not add UI imports (`SwiftUI`, `AppKit`) to MyAppCore.
- Do not add heavy dependencies without strong justification.
- Minimize scope: match existing style, don't refactor unrelated code.

## Packaging and release

| File | Purpose |
|------|---------|
| `packaging/app.env` | App identity — CI and build scripts source this |
| `packaging/build-app.sh` | Assembles `dist/{APP_BUNDLE_NAME}.app` |
| `packaging/Info.plist` | Bundle metadata; version source of truth |
| `packaging/App.entitlements` | Sandbox/entitlements for the bundle |
| `packaging/bump-version.sh` | Bumps patch/minor/major in Info.plist |
| `packaging/cask.rb.template` | Homebrew cask template (CI fills version/sha256) |
| `packaging/generate-icon.swift` | Generates AppIcon when Logo.png is missing |
| `.github/workflows/ci.yml` | Build + test on push/PR |
| `.github/workflows/release.yml` | Version bump, build, GitHub Release, Homebrew tap |

### Release flow

1. **Patch releases:** merge to `main`; CI auto-bumps if tag `v{version}` already exists.
2. **Minor/major:** run `make bump-version BUMP=minor` (or `major`), commit `packaging/Info.plist`, then merge to `main`.
3. CI skips release on commits whose message starts with `chore: bump version`.
4. Releases are **ad-hoc signed** — no Apple Developer ID or notarization required.
5. `HOMEBREW_TAP_TOKEN` secret updates the separate `homebrew-tap` repo.

## Git and PR guidelines

- **Do not commit** unless explicitly asked.
- **Do not push** unless explicitly asked.
- Keep changes focused; avoid drive-by refactors.
- Do not commit `.build/`, `dist/`, `.DS_Store`, or release zips.
- Do not commit secrets (`HOMEBREW_TAP_TOKEN`, signing certificates, `.env`).
- Prefer conventional commit prefixes: `feat:`, `fix:`, `chore:`, `docs:`.
- Version bumps: `chore: bump version to X.Y.Z`.

### Before finishing a change

1. Run `make build` for compile errors.
2. Run `make test` when MyAppCore logic changed.
3. For UI changes, note that manual verification requires `make app`.

## Security and privacy

- Keep user data **local** unless the product explicitly needs network access.
- Do not commit secrets or tokens.
- CI uses repository secrets only for automated Homebrew tap updates.

## Human-facing docs

- **README.md** — install, usage, release overview (keep in sync when changing user-visible behavior).
- **AGENTS.md** (this file) — agent-oriented bootstrap, architecture, and conventions.

When user-visible behavior changes, update README.md. When agent-relevant workflows change, update this file.
