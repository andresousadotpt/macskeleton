# macskeleton

A **starter template** for native macOS apps built with Swift Package Manager. Clone it (or copy the folder), rename the placeholders, implement your app logic, and ship with the same Makefile, CI, and Homebrew release pipeline used by [macdaily](https://github.com/andresousadotpt/macdaily).

## What you get

- **Two-target layout:** `MyAppCore` (testable logic, no UI) + `MyApp` (SwiftUI shell)
- **Makefile:** `build`, `run`, `test`, `app`, `clean`, `bump-version`
- **CI:** build + test on push/PR to `main`
- **Release:** auto patch bump, GitHub Release zip, Homebrew cask update to [homebrew-tap](https://github.com/andresousadotpt/homebrew-tap)
- **Docs:** README, AGENTS.md, CONTRIBUTING, issue templates, and community files

## Quick start (new app from this template)

1. Copy or clone this repo into a new folder / GitHub repo.
2. Follow the **bootstrap checklist** in [AGENTS.md](AGENTS.md) — update `packaging/app.env`, `Package.swift`, `Info.plist`, and rename `Sources/` / `Tests/` directories.
3. Replace the placeholder SwiftUI view with your app.
4. Push to `main` — CI builds and tests; release workflow publishes when CI succeeds.

```bash
git clone https://github.com/andresousadotpt/macskeleton.git my-new-app
cd my-new-app
# Ask an agent to run the AGENTS.md bootstrap checklist, then:
make build
make run
make app
open dist/myapp.app   # path uses APP_BUNDLE_NAME from packaging/app.env
```

Requirements: macOS 14 (Sonoma) or later, Xcode Command Line Tools. Full Xcode is needed for `make test`.

## Install (after you publish your app)

### Option A — Build from source (recommended)

No Gatekeeper warnings when you build locally.

```bash
git clone https://github.com/andresousadotpt/myapp.git
cd myapp
make app
open dist/myapp.app
```

### Option B — Homebrew

```bash
brew tap andresousadotpt/tap
brew install --cask myapp
```

If macOS blocks launch the first time, right-click the app → **Open**, or use System Settings → Privacy & Security → **Open Anyway**.

### Option C — GitHub Release

Download `{app}-{version}.zip` from [Releases](https://github.com/andresousadotpt/myapp/releases), unzip, and open the app.

## Development

```bash
make build    # debug build
make run      # build and launch via swift run
make test     # unit tests (requires full Xcode)
make app      # release .app in ./dist/
make clean    # remove build artifacts
```

## Releasing

Version lives in `packaging/Info.plist` (`CFBundleShortVersionString`). Push to `main` and GitHub Actions will:

1. Auto-bump the patch version if `v{current}` already exists (e.g. `0.1.0` → `0.1.1`)
2. Build the `.app` (ad-hoc signed)
3. Publish a GitHub Release zip
4. Update the Homebrew cask in [homebrew-tap](https://github.com/andresousadotpt/homebrew-tap)

For a **minor** or **major** release, bump locally first:

```bash
make bump-version BUMP=minor   # or BUMP=major
git add packaging/Info.plist && git commit -m "chore: bump version to X.Y.Z"
```

Then merge to `main`. CI will use that version as-is (no tag exists yet) and publish it.

### CI secrets

| Secret | Required | Purpose |
| ------ | -------- | ------- |
| `HOMEBREW_TAP_TOKEN` | For automated tap updates | GitHub PAT with `contents: write` on `homebrew-tap` |

Apple Developer ID / notarization is **not** required. Releases are ad-hoc signed.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). AI agents should read [AGENTS.md](AGENTS.md) first.

| Document | Purpose |
| -------- | ------- |
| [AGENTS.md](AGENTS.md) | Bootstrap checklist, architecture, conventions |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [SUPPORT.md](SUPPORT.md) | Help and FAQs |
| [SECURITY.md](SECURITY.md) | Report vulnerabilities privately |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community standards |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

## License

MIT — see [LICENSE](LICENSE).
