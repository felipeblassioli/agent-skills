## Agentic Artifact Discovery Report

**Target paths**: `tmp/BMAD-METHOD`  
**System shape**: `mixed-agentic-system`  
**Primary question**: How does BMAD-METHOD fit together as an agentic system,
and what are its main flows and use cases?

### Artifact inventory
| Category | Path | Role |
|----------|------|------|
| docs | `tmp/BMAD-METHOD/README.md` | Public overview, installation, module framing |
| support | `tmp/BMAD-METHOD/package.json` | CLI entrypoints, npm install surface, validation scripts |
| support | `tmp/BMAD-METHOD/src/core-skills/module.yaml` | Core module configuration and paths |
| support | `tmp/BMAD-METHOD/src/bmm-skills/module.yaml` | BMM module configuration and artifact locations |
| workflow | `tmp/BMAD-METHOD/src/bmm-skills/module-help.csv` | Canonical BMM workflow catalog by phase, code, command, and agent |
| workflow | `tmp/BMAD-METHOD/src/core-skills/module-help.csv` | Core anytime workflow catalog |
| skills | `tmp/BMAD-METHOD/src/core-skills/bmad-help/SKILL.md` | Runtime routing surface for what to do next |
| skills | `tmp/BMAD-METHOD/src/core-skills/bmad-init/SKILL.md` | Shared initialization and config load protocol |
| skills | `tmp/BMAD-METHOD/src/bmm-skills/2-plan-workflows/bmad-agent-pm/SKILL.md` | Persona-style PM agent entry surface |
| skills | `tmp/BMAD-METHOD/src/bmm-skills/2-plan-workflows/bmad-create-prd/SKILL.md` | Thin PRD entry surface |
| workflow | `tmp/BMAD-METHOD/src/bmm-skills/2-plan-workflows/bmad-create-prd/workflow.md` | Step-file execution contract for PRD creation |
| support | `tmp/BMAD-METHOD/tools/cli/installers/lib/core/installer.js` | Install-time catalog merge and runtime materialization logic |

### Actor and role map
- `npx bmad-method install` -> primary onboarding and project wiring surface
- `bmad-help` -> runtime router for phase-aware recommendations
- `bmad-init` -> shared config bootstrap used by persona and workflow skills
- `bmad-agent-pm` -> user-facing PM persona that exposes planning capabilities
- `bmad-create-prd` -> task-focused PRD workflow entry point
- `module-help.csv` catalogs -> canonical mapping between phases, workflow codes,
  skills, commands, and agents
- installer logic -> builds the generated runtime catalog that `bmad-help`
  depends on after installation

### Trigger and invocation matrix
| Surface | Trigger or invocation | Evidence |
|---------|-----------------------|----------|
| npm CLI | `npx bmad-method install` or `bmad-method` binary | `package.json`, `README.md` |
| Help routing | user asks what to do next or how to proceed in BMad | `src/core-skills/bmad-help/SKILL.md` |
| PM persona | user asks to talk to John or requests the product manager | `src/bmm-skills/2-plan-workflows/bmad-agent-pm/SKILL.md` |
| PRD workflow | capability code `CP` or `bmad-bmm-create-prd` | `src/bmm-skills/module-help.csv`, `src/bmm-skills/2-plan-workflows/bmad-create-prd/workflow.md` |
| Agent-first workflow | load agent skill, then invoke by code or name | `src/core-skills/bmad-help/SKILL.md` |

### Flow narrative
1. User installs BMAD with `npx bmad-method install`, which wires project-local
   artifacts and catalogs.
2. User enters through a help surface or a persona such as `bmad-agent-pm`.
3. The persona loads `bmad-init` to resolve config, language, and project
   context.
4. The capability table exposes codes such as `CP` for Create PRD.
5. The PRD entry skill routes into `workflow.md`, which enforces just-in-time
   step loading and sequential execution through micro-step files.
6. Runtime guidance is phase-aware because `bmad-help` reads the generated help
   catalog and uses output locations and completion state to recommend what
   comes next.

### Use cases
- product discovery and planning -> `bmad-agent-pm`, `bmad-create-prd`,
  `module-help.csv`
- architecture and implementation readiness -> architect workflows in
  `module-help.csv`
- sprint execution and story cycle -> implementation-phase rows in
  `module-help.csv`
- anytime support such as brainstorming or documentation -> core skills and core
  help catalog

### Ambiguities or overloaded surfaces
- BMAD is easy to misread as a pure skill tree, but installer logic and runtime
  catalog generation are part of the real system behavior.
- The repository mixes source-of-truth inputs and support collateral such as
  docs site code and IDE templates, which can distract discovery.
- Some runtime artifacts appear only after install-time generation, so a source
  checkout does not show the full live shape directly.
- Catalog-driven routing means file-tree intuition alone is insufficient; the
  CSV catalogs and help skill matter more than folder names.

### Recommended next step
- deeper discovery on the generated post-install runtime shape, especially the
  catalog files consumed under `_bmad/_config/`
