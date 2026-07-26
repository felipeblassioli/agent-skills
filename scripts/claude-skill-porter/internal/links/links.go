package links

import (
	"fmt"
	"os"
	"path/filepath"
)

func Ensure(project, canonical, slug string, dry bool) ([]string, error) {
	target, err := filepath.Abs(filepath.Join(canonical, slug))
	if err != nil {
		return nil, err
	}
	var actions []string
	for _, agent := range []string{".cursor", ".claude"} {
		dir := filepath.Join(project, agent, "skills")
		link := filepath.Join(dir, slug)
		if fi, e := os.Lstat(link); e == nil {
			if fi.Mode()&os.ModeSymlink == 0 {
				return nil, fmt.Errorf("refusing unrelated entry %s", link)
			}
			old, e := os.Readlink(link)
			if e != nil {
				return nil, e
			}
			oldAbs := old
			if !filepath.IsAbs(old) {
				oldAbs = filepath.Join(dir, old)
			}
			if filepath.Clean(oldAbs) == target {
				continue
			}
			if !dry {
				if e = os.Remove(link); e != nil {
					return nil, e
				}
			}
		} else if !os.IsNotExist(e) {
			return nil, e
		}
		actions = append(actions, link+" -> "+target)
		if !dry {
			if e := os.MkdirAll(dir, 0755); e != nil {
				return nil, e
			}
			if e := os.Symlink(target, link); e != nil {
				return nil, e
			}
		}
	}
	return actions, nil
}
