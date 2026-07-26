package main

import (
	"flag"
	"fmt"
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
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}
	var err error
	switch os.Args[1] {
	case "scan":
		err = scan(os.Args[2:])
	case "import":
		err = importCmd(os.Args[2:])
	case "link":
		err = linkCmd(os.Args[2:])
	case "doctor":
		err = doctorCmd(os.Args[2:])
	case "help", "--help", "-h":
		usage()
		return
	default:
		err = fmt.Errorf("unknown command %q", os.Args[1])
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}
func usage() {
	fmt.Print(`claude-skill-porter safely imports archived Agent Skills

Usage: claude-skill-porter <scan|import|link|doctor> [flags]
  scan ARCHIVE [--json]
  import ARCHIVE --canonical DIR [--dry-run] [--json]
  link --canonical DIR --project-root DIR --skill SLUG [--dry-run] [--json]
  doctor --canonical DIR --project-root DIR [--json]
`)
}
func common(name string) (*flag.FlagSet, *bool, *bool) {
	f := flag.NewFlagSet(name, flag.ContinueOnError)
	dry := f.Bool("dry-run", false, "report without mutation")
	js := f.Bool("json", false, "emit JSON")
	return f, dry, js
}
func unpack(path string) (string, func(), error) {
	tmp, e := os.MkdirTemp("", "claude-skill-porter-")
	if e != nil {
		return "", nil, e
	}
	clean := func() { os.RemoveAll(tmp) }
	if e = archive.Extract(path, tmp); e != nil {
		clean()
		return "", nil, e
	}
	root, e := detect.StripWrapper(tmp)
	if e != nil {
		clean()
		return "", nil, e
	}
	return root, clean, nil
}
func archiveArgs(f *flag.FlagSet, args []string) (string, error) {
	if len(args) > 0 && args[0] != "" && args[0][0] != '-' {
		archive := args[0]
		if e := f.Parse(args[1:]); e != nil {
			return "", e
		}
		if f.NArg() != 0 {
			return "", fmt.Errorf("unexpected arguments: %v", f.Args())
		}
		return archive, nil
	}
	if e := f.Parse(args); e != nil {
		return "", e
	}
	if f.NArg() != 1 {
		return "", fmt.Errorf("exactly one archive is required")
	}
	return f.Arg(0), nil
}
func scan(args []string) error {
	f, _, js := common("scan")
	archiveName, e := archiveArgs(f, args)
	if e != nil {
		return e
	}
	root, clean, e := unpack(archiveName)
	if e != nil {
		return e
	}
	defer clean()
	class, roots, e := classify.Package(root)
	if e != nil {
		return e
	}
	r := model.Result{Command: "scan", Actions: []string{fmt.Sprintf("classification: %s", class)}, Warnings: []string{}, Errors: []string{}}
	for _, x := range roots {
		rel, _ := filepath.Rel(root, x)
		r.Actions = append(r.Actions, "skill-root: "+filepath.ToSlash(rel))
	}
	return report.Render(os.Stdout, r, *js)
}
func importCmd(args []string) error {
	f, dry, js := common("import")
	canonical := f.String("canonical", "", "canonical skills directory")
	archiveName, e := archiveArgs(f, args)
	if e != nil {
		return e
	}
	if *canonical == "" {
		return fmt.Errorf("import requires --canonical")
	}
	archivePath, _ := filepath.Abs(archiveName)
	root, clean, e := unpack(archivePath)
	if e != nil {
		return e
	}
	defer clean()
	class, roots, e := classify.Package(root)
	if e != nil {
		return e
	}
	if class == model.Incompatible {
		return fmt.Errorf("compiled VS Code/Cursor extension is incompatible")
	}
	if len(roots) == 0 {
		return fmt.Errorf("archive contains no SKILL.md roots (classification %s)", class)
	}
	r := model.Result{Command: "import", DryRun: *dry, Actions: []string{}, Warnings: []string{}, Errors: []string{}}
	for _, src := range roots {
		slug := normalize.Slug(filepath.Base(src))
		if slug == "" {
			return fmt.Errorf("cannot normalize skill name %q", filepath.Base(src))
		}
		sourceRoot, e := filepath.Rel(root, src)
		if e != nil {
			return e
		}
		dst, e := install.Skill(src, filepath.ToSlash(sourceRoot), *canonical, slug, archivePath, class, *dry)
		if e != nil {
			return e
		}
		r.Actions = append(r.Actions, "install: "+dst)
	}
	return report.Render(os.Stdout, r, *js)
}
func linkCmd(args []string) error {
	f, dry, js := common("link")
	canonical := f.String("canonical", "", "canonical skills directory")
	project := f.String("project-root", "", "project root")
	skill := f.String("skill", "", "skill slug")
	if e := f.Parse(args); e != nil {
		return e
	}
	if *canonical == "" || *project == "" || *skill == "" {
		return fmt.Errorf("link requires --canonical, --project-root, and --skill")
	}
	slug := normalize.Slug(*skill)
	if slug != *skill {
		return fmt.Errorf("--skill must already be a normalized slug")
	}
	if _, e := os.Stat(filepath.Join(*canonical, slug, "SKILL.md")); e != nil {
		return fmt.Errorf("canonical skill invalid: %w", e)
	}
	a, e := links.Ensure(*project, *canonical, slug, *dry)
	if e != nil {
		return e
	}
	return report.Render(os.Stdout, model.Result{Command: "link", DryRun: *dry, Actions: a, Warnings: []string{}, Errors: []string{}}, *js)
}
func doctorCmd(args []string) error {
	f, _, js := common("doctor")
	canonical := f.String("canonical", "", "canonical skills directory")
	project := f.String("project-root", "", "project root")
	if e := f.Parse(args); e != nil {
		return e
	}
	if *canonical == "" || *project == "" {
		return fmt.Errorf("doctor requires --canonical and --project-root")
	}
	issues, e := doctor.Check(*project, *canonical)
	if e != nil {
		return e
	}
	r := model.Result{Command: "doctor", Actions: []string{}, Warnings: issues, Errors: []string{}}
	if len(issues) == 0 {
		r.Actions = []string{"healthy"}
	}
	if e = report.Render(os.Stdout, r, *js); e != nil {
		return e
	}
	if len(issues) > 0 {
		return fmt.Errorf("doctor found %d issue(s)", len(issues))
	}
	return nil
}
