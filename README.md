# Solo‑Project Docs Bootstrap

A **one‑shot scaffold** for solo developers who want a lint‑clean, AI‑friendly documentation stack—vision → stories → C4 diagrams → ADRs—ready in seconds.

## 1  What the script does

```bash
bash bootstrap.sh
```

* Creates the `docs/` hierarchy (vision, stories, C4 diagrams, ADRs).
* Drops a reusable **story template**.
* Generates empty **L1 / L2 Mermaid stubs** and a Makefile that:
  * renders/validates all `.mmd` diagrams (`make diagrams`)
  * lints Markdown & YAML front‑matter (`make lint`)
  * serves live docs locally (`make docs`)
* Adds `scripts/check_frontmatter.py` (stub) for custom metadata checks.
* Writes `agent.md`—a concise system prompt for any background AI agent.

## 2  Prerequisites

* **adr‑tools** – create Architecture Decision Records  
* **mermaid‑cli** – render `.mmd` → `.svg`  
* **markdownlint‑cli2** – style lint  
* **MkDocs + Material** *or* **Grip** – local docs preview  
* Python 3 (for the YAML front‑matter checker)

<details>
<summary>macOS (Homebrew) quick install</summary>

```bash
brew install adr-tools
npm i -g @mermaid-js/mermaid-cli markdownlint-cli2
pip install mkdocs-material grip pyyaml
```
</details>

## 3 Commands

| Action | Command |
|--------|---------|
| New user story | `make story name=my-feature` |
| New ADR        | `make adr msg="Choose Rust"` |
| Render & lint diagrams | `make diagrams` |
| Full lint suite        | `make lint` |
| Live docs preview      | `make docs` |

All CI or pre‑commit hooks should at least run `make lint`.


## 4 Structure 

```
docs/
  vision.md
  stories/
  adr/
  architecture/
    L1-context.mmd
    L2-containers.mmd
    components/
templates/story.md
scripts/check_frontmatter.py
Makefile
agent.md
```

Start by editing **`docs/vision.md`**, adding your first story with `make story`, then modelling `L1-context.mmd`. The rest of the workflow is codified in `agent.md` and enforced by the Makefile targets.

Happy building!
