// Package install safely installs and updates canonical skill directories.
package install

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"time"

	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/content"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/model"
)

type Options struct {
	DryRun bool
	Update bool
}

// Skill installs src or, with Update, replaces an unchanged porter-managed
// destination. It returns the destination and whether the action is an update.
func Skill(src, sourceRoot, canonical, slug, archive string, class model.Classification, opts Options) (string, bool, error) {
	dst := filepath.Join(canonical, slug)
	newDigest, err := content.Digest(src)
	if err != nil {
		return "", false, err
	}

	updating := false
	if info, statErr := os.Lstat(dst); statErr == nil {
		if !opts.Update {
			return "", false, fmt.Errorf("destination collision: %s (use --update only for an unchanged porter-managed skill)", dst)
		}
		if !info.IsDir() || info.Mode()&os.ModeSymlink != 0 {
			return "", false, fmt.Errorf("refusing to update non-directory destination: %s", dst)
		}
		if err := validateManagedDestination(dst, sourceRoot, slug, class); err != nil {
			return "", false, err
		}
		updating = true
	} else if !os.IsNotExist(statErr) {
		return "", false, statErr
	}

	if opts.DryRun {
		return dst, updating, nil
	}
	if err := os.MkdirAll(canonical, 0755); err != nil {
		return "", false, err
	}
	stage, err := os.MkdirTemp(canonical, ".claude-skill-porter-stage-")
	if err != nil {
		return "", false, err
	}
	defer os.RemoveAll(stage)
	if err := copyTree(src, stage); err != nil {
		return "", false, err
	}
	portInfo := model.PortInfo{SourceArchive: archive, SourceRoot: sourceRoot, NormalizedSlug: slug, Classification: class, ImportedAt: time.Now().UTC(), Warnings: []string{}, ToolVersion: model.Version, ContentDigest: newDigest}
	if err := writePortInfo(stage, portInfo); err != nil {
		return "", false, err
	}
	if !updating {
		if err := os.Rename(stage, dst); err != nil {
			return "", false, err
		}
		return dst, false, nil
	}
	backup := dst + ".claude-skill-porter-backup"
	if _, err := os.Lstat(backup); err == nil {
		return "", false, fmt.Errorf("refusing update because temporary backup exists: %s", backup)
	} else if !os.IsNotExist(err) {
		return "", false, err
	}
	if err := os.Rename(dst, backup); err != nil {
		return "", false, err
	}
	if err := os.Rename(stage, dst); err != nil {
		if rollbackErr := os.Rename(backup, dst); rollbackErr != nil {
			return "", false, fmt.Errorf("install update failed: %v; rollback failed: %v", err, rollbackErr)
		}
		return "", false, err
	}
	if err := os.RemoveAll(backup); err != nil {
		return "", false, fmt.Errorf("update succeeded but backup cleanup failed: %w", err)
	}
	return dst, true, nil
}

func validateManagedDestination(dst, sourceRoot, slug string, class model.Classification) error {
	b, err := os.ReadFile(filepath.Join(dst, "PORT_INFO.json"))
	if err != nil {
		return fmt.Errorf("destination is not verifiably porter-managed: %w", err)
	}
	var info model.PortInfo
	if err := json.Unmarshal(b, &info); err != nil {
		return fmt.Errorf("invalid PORT_INFO.json: %w", err)
	}
	if info.NormalizedSlug != slug || info.SourceRoot != sourceRoot || info.Classification != class {
		return fmt.Errorf("PORT_INFO.json identity does not match incoming skill")
	}
	if info.ContentDigest == "" {
		return fmt.Errorf("PORT_INFO.json has no content digest; this legacy import cannot be safely updated")
	}
	actual, err := content.Digest(dst)
	if err != nil {
		return err
	}
	if actual != info.ContentDigest {
		return fmt.Errorf("porter-managed destination has local changes; refusing update")
	}
	return nil
}

func writePortInfo(dst string, info model.PortInfo) error {
	b, err := json.MarshalIndent(info, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(dst, "PORT_INFO.json"), append(b, '\n'), 0644)
}

func copyTree(src, dst string) error {
	return filepath.WalkDir(src, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		rel, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}
		out := filepath.Join(dst, rel)
		if entry.Type()&os.ModeSymlink != 0 {
			return fmt.Errorf("source symlink refused: %s", path)
		}
		if entry.IsDir() {
			return os.MkdirAll(out, 0755)
		}
		if !entry.Type().IsRegular() {
			return fmt.Errorf("unsupported source entry: %s", path)
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		return os.WriteFile(out, data, 0644)
	})
}
