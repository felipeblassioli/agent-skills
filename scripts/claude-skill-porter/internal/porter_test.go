package internal_test

import (
	"archive/zip"
	"bytes"
	"encoding/json"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/archive"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/classify"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/detect"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/doctor"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/install"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/links"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/model"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/normalize"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/report"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func write(t *testing.T, p, s string) {
	t.Helper()
	if e := os.MkdirAll(filepath.Dir(p), 0755); e != nil {
		t.Fatal(e)
	}
	if e := os.WriteFile(p, []byte(s), 0644); e != nil {
		t.Fatal(e)
	}
}
func TestArchiveTraversalRejected(t *testing.T) {
	p := filepath.Join(t.TempDir(), "x.zip")
	f, _ := os.Create(p)
	w := zip.NewWriter(f)
	x, _ := w.Create("../evil")
	x.Write([]byte("x"))
	w.Close()
	f.Close()
	if archive.Extract(p, t.TempDir()) == nil {
		t.Fatal("expected rejection")
	}
}
func TestClassifierOutcomesAndMultipleRoots(t *testing.T) {
	d := t.TempDir()
	write(t, filepath.Join(d, "a", "SKILL.md"), "a")
	write(t, filepath.Join(d, "b", "SKILL.md"), "b")
	c, r, e := classify.Package(d)
	if e != nil || c != model.Scaffolded || len(r) != 2 {
		t.Fatalf("%v %v %v", c, r, e)
	}
	eDir := t.TempDir()
	write(t, filepath.Join(eDir, "package.json"), `{"engines":{"vscode":"*"}}`)
	c, _, _ = classify.Package(eDir)
	if c != model.Incompatible {
		t.Fatal(c)
	}
}
func TestDirectAndInstructionClassification(t *testing.T) {
	d := t.TempDir()
	write(t, filepath.Join(d, "SKILL.md"), "x")
	c, _, _ := classify.Package(d)
	if c != model.Direct {
		t.Fatal(c)
	}
	i := t.TempDir()
	write(t, filepath.Join(i, "CLAUDE.md"), "x")
	c, _, _ = classify.Package(i)
	if c != model.Instructions {
		t.Fatal(c)
	}
}
func TestWrapperAndSlug(t *testing.T) {
	d := t.TempDir()
	os.Mkdir(filepath.Join(d, "wrapper"), 0755)
	r, e := detect.StripWrapper(d)
	if e != nil || filepath.Base(r) != "wrapper" {
		t.Fatal(r, e)
	}
	if got := normalize.Slug("My Cool_skill.V2"); got != "my-cool-skill-v2" {
		t.Fatal(got)
	}
}
func TestCollisionAndDryRun(t *testing.T) {
	src := t.TempDir()
	write(t, filepath.Join(src, "SKILL.md"), "x")
	dst := t.TempDir()
	os.Mkdir(filepath.Join(dst, "x"), 0755)
	if _, _, e := install.Skill(src, ".", dst, "x", "a.zip", model.Direct, install.Options{}); e == nil {
		t.Fatal("collision accepted")
	}
	if _, _, e := install.Skill(src, ".", dst, "dry", "a.zip", model.Direct, install.Options{DryRun: true}); e != nil {
		t.Fatal(e)
	}
	if _, e := os.Stat(filepath.Join(dst, "dry")); !os.IsNotExist(e) {
		t.Fatal("dry run mutated")
	}
}

func TestSafeManagedUpdate(t *testing.T) {
	src := t.TempDir()
	write(t, filepath.Join(src, "SKILL.md"), "old")
	dst := t.TempDir()
	if _, _, err := install.Skill(src, ".", dst, "skill", "old.zip", model.Direct, install.Options{}); err != nil {
		t.Fatal(err)
	}
	write(t, filepath.Join(src, "SKILL.md"), "new")
	path, updated, err := install.Skill(src, ".", dst, "skill", "new.zip", model.Direct, install.Options{Update: true})
	if err != nil || !updated {
		t.Fatalf("path=%s updated=%v err=%v", path, updated, err)
	}
	b, err := os.ReadFile(filepath.Join(path, "SKILL.md"))
	if err != nil || string(b) != "new" {
		t.Fatalf("content=%q err=%v", b, err)
	}
}

func TestManagedUpdateRejectsLocalChangesAndLegacyMetadata(t *testing.T) {
	src := t.TempDir()
	write(t, filepath.Join(src, "SKILL.md"), "old")
	dst := t.TempDir()
	installed, _, err := install.Skill(src, ".", dst, "skill", "old.zip", model.Direct, install.Options{})
	if err != nil {
		t.Fatal(err)
	}
	write(t, filepath.Join(installed, "SKILL.md"), "local edit")
	write(t, filepath.Join(src, "SKILL.md"), "upstream edit")
	if _, _, err := install.Skill(src, ".", dst, "skill", "new.zip", model.Direct, install.Options{Update: true}); err == nil || !strings.Contains(err.Error(), "local changes") {
		t.Fatalf("expected local-change rejection, got %v", err)
	}

	legacy := filepath.Join(dst, "legacy")
	write(t, filepath.Join(legacy, "SKILL.md"), "old")
	write(t, filepath.Join(legacy, "PORT_INFO.json"), `{"sourceRoot":".","normalizedSlug":"legacy","classification":"direct-skill"}`)
	if _, _, err := install.Skill(src, ".", dst, "legacy", "new.zip", model.Direct, install.Options{Update: true}); err == nil || !strings.Contains(err.Error(), "no content digest") {
		t.Fatalf("expected legacy rejection, got %v", err)
	}

	unmanaged := filepath.Join(dst, "unmanaged")
	write(t, filepath.Join(unmanaged, "SKILL.md"), "unmanaged")
	if _, _, err := install.Skill(src, ".", dst, "unmanaged", "new.zip", model.Direct, install.Options{Update: true}); err == nil || !strings.Contains(err.Error(), "not verifiably porter-managed") {
		t.Fatalf("expected unmanaged rejection, got %v", err)
	}
}
func TestJSONShape(t *testing.T) {
	var b bytes.Buffer
	r := model.Result{Command: "scan", Actions: []string{}, Warnings: []string{}, Errors: []string{}}
	if e := report.Render(&b, r, true); e != nil {
		t.Fatal(e)
	}
	var v map[string]any
	if json.Unmarshal(b.Bytes(), &v) != nil {
		t.Fatal("invalid json")
	}
	for _, k := range []string{"command", "dryRun", "actions", "warnings", "errors"} {
		if _, ok := v[k]; !ok {
			t.Fatal("missing " + k)
		}
	}
}
func TestSafeLinksAndBrokenDiagnosis(t *testing.T) {
	base := t.TempDir()
	canonical := filepath.Join(base, "canonical")
	project := filepath.Join(base, "project")
	write(t, filepath.Join(canonical, "skill", "SKILL.md"), "x")
	regular := filepath.Join(project, ".cursor", "skills", "skill")
	write(t, regular, "x")
	if _, e := links.Ensure(project, canonical, "skill", false); e == nil {
		t.Fatal("regular file replaced")
	}
	os.Remove(regular)
	if _, e := links.Ensure(project, canonical, "skill", false); e != nil {
		t.Fatal(e)
	}
	broken := filepath.Join(project, ".cursor", "skills", "broken")
	os.Symlink(filepath.Join(base, "missing"), broken)
	issues, e := doctor.Check(project, canonical)
	if e != nil {
		t.Fatal(e)
	}
	if !strings.Contains(strings.Join(issues, "\n"), "broken symlink") {
		t.Fatal(issues)
	}
}
