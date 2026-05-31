# Agent instructions

## Cursor Cloud specific instructions

### Repository layout

- **`main`** currently contains only `README.md` (project stub).
- **Runnable UX deliverables** live on `cursor/nurture-assistant-ux-464d`: `docs/nurture-assistant-ux.md` and `prototype/index.html` (self-contained static HTML/CSS; no build step or package manager).

Check out that branch (or merge it) before working on the prototype or UX spec.

### Services

| Service | Required? | Notes |
|--------|-----------|--------|
| Static HTTP server for `prototype/` | Optional | README documents opening `prototype/index.html` directly; a local server avoids `file://` quirks in some browsers. |
| Backend, database, auth, AI | N/A | Not implemented in this repo yet (spec only). |

### Lint, test, build

No `package.json`, `Makefile`, or CI config is present. There are no lint, test, or build commands until application code and tooling are added.

### Run the prototype (development)

From the repo root, with the UX branch checked out:

```bash
cd prototype && python3 -m http.server 8080
```

Then open `http://127.0.0.1:8080/` in a browser. The page title should be **Nurture Assistant UX Prototype**.

Use **tmux** for long-running servers in Cloud Agent VMs (see portal tmux config under `/exec-daemon/tmux.portal.conf`).

### Hello-world verification

Confirm the prototype loads and scroll through the mobile mockups: Home dashboard (assistant input, Quick Add, status cards), AI logging / medicine confirmation flow, Timeline, Medicine, and Supplies screens. These are static layouts (no JavaScript); validation is visual/UI review in the browser.
