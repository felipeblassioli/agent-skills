package doctor

import (
	"fmt"
	"os"
	"path/filepath"
)

func Check(project, canonical string) ([]string, error) {
	var issues []string
	canonical, err := filepath.Abs(canonical)
	if err != nil {
		return nil, err
	}
	if fi, e := os.Stat(canonical); e != nil || !fi.IsDir() {
		issues = append(issues, "missing canonical directory: "+canonical)
	}
	for _, agent := range []string{".cursor", ".claude"} {
		dir := filepath.Join(project, agent, "skills")
		entries, e := os.ReadDir(dir)
		if os.IsNotExist(e) {
			continue
		}
		if e != nil {
			return nil, e
		}
		for _, entry := range entries {
			p := filepath.Join(dir, entry.Name())
			fi, e := os.Lstat(p)
			if e != nil {
				return nil, e
			}
			if fi.Mode()&os.ModeSymlink == 0 {
				issues = append(issues, "incompatible filesystem entry: "+p)
				continue
			}
			resolved, e := filepath.EvalSymlinks(p)
			if e != nil {
				issues = append(issues, "broken symlink: "+p)
				continue
			}
			rel, e := filepath.Rel(canonical, resolved)
			if e != nil || rel == ".." || filepath.IsAbs(rel) || len(rel) >= 3 && rel[:3] == ".."+string(filepath.Separator) {
				issues = append(issues, fmt.Sprintf("unexpected link target: %s -> %s", p, resolved))
			}
		}
	}
	return issues, nil
}
