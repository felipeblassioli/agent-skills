package install

import (
	"encoding/json"
	"fmt"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/model"
	"io/fs"
	"os"
	"path/filepath"
	"time"
)

func Skill(src, sourceRoot, canonical, slug, archive string, class model.Classification, dry bool) (string, error) {
	dst := filepath.Join(canonical, slug)
	if _, err := os.Lstat(dst); err == nil {
		return "", fmt.Errorf("destination collision: %s", dst)
	} else if !os.IsNotExist(err) {
		return "", err
	}
	if dry {
		return dst, nil
	}
	if err := os.MkdirAll(canonical, 0755); err != nil {
		return "", err
	}
	if err := copyTree(src, dst); err != nil {
		return "", err
	}
	info := model.PortInfo{SourceArchive: archive, SourceRoot: sourceRoot, NormalizedSlug: slug, Classification: class, ImportedAt: time.Now().UTC(), Warnings: []string{}, ToolVersion: model.Version}
	b, err := json.MarshalIndent(info, "", "  ")
	if err != nil {
		return "", err
	}
	b = append(b, '\n')
	if err := os.WriteFile(filepath.Join(dst, "PORT_INFO.json"), b, 0644); err != nil {
		return "", err
	}
	return dst, nil
}
func copyTree(src, dst string) error {
	return filepath.WalkDir(src, func(p string, d fs.DirEntry, e error) error {
		if e != nil {
			return e
		}
		rel, _ := filepath.Rel(src, p)
		out := filepath.Join(dst, rel)
		if d.Type()&os.ModeSymlink != 0 {
			return fmt.Errorf("source symlink refused: %s", p)
		}
		if d.IsDir() {
			return os.MkdirAll(out, 0755)
		}
		if !d.Type().IsRegular() {
			return fmt.Errorf("unsupported source entry: %s", p)
		}
		data, e := os.ReadFile(p)
		if e != nil {
			return e
		}
		return os.WriteFile(out, data, 0644)
	})
}
