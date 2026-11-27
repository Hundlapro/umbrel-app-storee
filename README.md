# Hundlapro Umbrel community app store

Add this repo's URL in umbrelOS under App Store → ⋯ → Community App Stores.

- `homelab-gods-eye-view` — [God's Eye View](https://github.com/bilawalsidhu/gods-eye-view),
  built from a pinned upstream commit by `.github/workflows/build.yml` and pushed to GHCR.
- `homelab-mornye-python` — [Mornye Python](https://github.com/mornyeapp/Mornye-Python) in `--web` mode,
  using the project's own published image (pinned by digest).

## Mornye extension registry

`mornye/registry.json` is the official Mornye registry filtered to the IDs in
`mornye/allowlist.txt`. `.github/workflows/sync-mornye-registry.yml` refreshes it
hourly. Add this URL in Mornye under Settings → Extension Registries:
`https://raw.githubusercontent.com/Hundlapro/umbrel-app-storee/main/mornye/registry.json`
