package classify

import (
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/detect"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/model"
	"os"
	"path/filepath"
	"strings"
)

func Package(root string) (model.Classification, []string, error) {
	if extension(root) {
		return model.Incompatible, nil, nil
	}
	roots, err := detect.SkillRoots(root)
	if err != nil {
		return model.Unknown, nil, err
	}
	if len(roots) > 0 {
		if len(roots) == 1 && same(roots[0], root) {
			return model.Direct, roots, nil
		}
		return model.Scaffolded, roots, nil
	}
	for _, n := range []string{"CLAUDE.md", "AGENTS.md", ".cursorrules"} {
		if _, err := os.Stat(filepath.Join(root, n)); err == nil {
			return model.Instructions, nil, nil
		}
	}
	return model.Unknown, nil, nil
}
func same(a, b string) bool { aa, _ := filepath.Abs(a); bb, _ := filepath.Abs(b); return aa == bb }
func extension(root string) bool {
	if _, err := os.Stat(filepath.Join(root, "extension.vsixmanifest")); err == nil {
		return true
	}
	if _, err := os.Stat(filepath.Join(root, "package.json")); err == nil {
		b, _ := os.ReadFile(filepath.Join(root, "package.json"))
		s := string(b)
		return strings.Contains(s, `"engines"`) && strings.Contains(s, `"vscode"`)
	}
	return false
}
