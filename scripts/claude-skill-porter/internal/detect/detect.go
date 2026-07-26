package detect

import (
	"io/fs"
	"os"
	"path/filepath"
	"sort"
)

func SkillRoots(root string) ([]string, error) {
	var roots []string
	err := filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.Type()&os.ModeSymlink != 0 {
			if d.IsDir() {
				return fs.SkipDir
			}
			return nil
		}
		if !d.IsDir() && d.Name() == "SKILL.md" {
			roots = append(roots, filepath.Dir(path))
		}
		return nil
	})
	sort.Strings(roots)
	return roots, err
}

func StripWrapper(root string) (string, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return "", err
	}
	if len(entries) == 1 && entries[0].IsDir() {
		return filepath.Join(root, entries[0].Name()), nil
	}
	return root, nil
}
