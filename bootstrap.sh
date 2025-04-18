#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Project documentation scaffold
# -----------------------------------------------------------------------------
# Creates the directory layout, stub files, Makefile and an AI agent prompt.
# -----------------------------------------------------------------------------

# ------------------------ paths ---------------------------------------------
mkdir -p docs/{adr,stories,architecture/components,templates}
touch docs/architecture/components/.gitkeep
adr init docs/adr

# ------------------------ vision --------------------------------------------
cat > docs/vision.md <<'EOF'
# Vision

Describe the problem, target users, and success criteria here.
EOF

# ------------------------ story template ------------------------------------
cat > docs/templates/story.md <<'EOF'
---
id: S{{DATE}}-slug          # replace {{DATE}} and slug
type: user_story
status: draft
related_diagrams: []
---

**When** ...  
**I want** ...  
**So I can** ...
EOF

# ------------------------ C4 diagram stubs ----------------------------------
cat > docs/architecture/L1-context.mmd <<'EOF'
%% System Context Diagram (add Mermaid flowchart here)
EOF

cat > docs/architecture/L2-containers.mmd <<'EOF'
%% Container Diagram (add Mermaid flowchart here)
EOF

# ------------------------ agent prompt --------------------------------------
cat > agent.md <<'EOF'
# Solo‑Project Design Agent – System Prompt

You collaborate with a single developer who maintains this repository. Every action you take must be traceable in Git and must pass the project's automated checks.

## Directory structure
```
docs/
  vision.md
  adr/
  stories/
  architecture/
    L1-context.mmd
    L2-containers.mmd
    components/
templates/
  story.md
scripts/
  check_frontmatter.py
Makefile
```

## Allowed commands
* `make story name=<slug>` – create a new story from the template.
* `make adr msg="<Title>"` – create an Architecture Decision Record.
* `make diagrams` – render & validate all Mermaid diagrams.
* `make lint` – run full lint suite (must succeed before commit).
* `make docs` – serve documentation locally.

## Workflow
1. **Vision** – consult `docs/vision.md` for overall goals.
2. **Stories** – create with `make story`; fill *When / I want / So I can* and YAML front‑matter (`id`, `type`, `status`, `related_diagrams`).
3. **C4 diagrams** – edit `L1-context.mmd`, `L2-containers.mmd`, or add `components/<name>-L3.mmd`; use Mermaid flowchart syntax; run `make diagrams` after edits.
4. **Architecture decisions** – use `make adr` for irreversible choices; reference affected stories/diagrams in the ADR front‑matter.
5. **Validation** – run `make lint`; ensure it passes before committing.

## Definition of done
* All relevant files created or modified.
* `make diagrams` and `make lint` succeed locally.
* YAML front‑matter present and complete.
* Traceability links kept consistent.

If requirements conflict or are unclear, ask for clarification before acting.
EOF

# ------------------------ Makefile ------------------------------------------
cat > Makefile <<'EOF'
mmdc  = mmdc --quiet
src   = $(shell find docs/architecture -name '*.mmd')

.PHONY: diagrams lint docs story adr

diagrams:
	@for f in $(src); do \
	  $(mmdc) -i $$f -o $${f%.mmd}.svg; \
	done

lint: diagrams
	markdownlint-cli2 **/*.md
	python scripts/check_frontmatter.py

docs: diagrams
	mkdocs serve   # or: grip

story:
	cp docs/templates/story.md docs/stories/S$$(date +%F)-$(name).md

adr:
	adr new "$(msg)"
EOF

# ------------------------ front-matter lint helper --------------------------
mkdir -p scripts
cat > scripts/check_frontmatter.py <<'PY'
#!/usr/bin/env python
import sys, re, pathlib, yaml

required = {"id", "type", "status"}
for md in pathlib.Path('docs').rglob('*.md'):
    text = md.read_text()
    if text.startswith('---'):
        parts = re.split(r'^---\s*$', text, 2, flags=re.M)
        if len(parts) < 3:
            print(f"{md}: malformed front‑matter")
            sys.exit(1)
        meta = yaml.safe_load(parts[1]) or {}
        missing = required - meta.keys()
        if missing:
            print(f"{md}: missing {missing}")
            sys.exit(1)
print("front‑matter OK")
PY
chmod +x scripts/check_frontmatter.py

# ------------------------ done ----------------------------------------------
echo "Documentation scaffold created."

