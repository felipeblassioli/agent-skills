package archive

import (
	"archive/zip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

func Extract(zipPath, dst string) error {
	r, err := zip.OpenReader(zipPath)
	if err != nil {
		return err
	}
	defer r.Close()
	root, err := filepath.Abs(dst)
	if err != nil {
		return err
	}
	for _, f := range r.File {
		slashName := strings.ReplaceAll(f.Name, `\`, "/")
		name := filepath.FromSlash(slashName)
		if filepath.IsAbs(name) || strings.HasPrefix(slashName, "/") || (len(slashName) >= 3 && slashName[1] == ':' && slashName[2] == '/') || f.Name == "" {
			return fmt.Errorf("unsafe archive path %q", f.Name)
		}
		clean := filepath.Clean(name)
		if clean == ".." || strings.HasPrefix(clean, ".."+string(filepath.Separator)) {
			return fmt.Errorf("archive traversal %q", f.Name)
		}
		if f.Mode()&os.ModeSymlink != 0 {
			return fmt.Errorf("unsafe symlink entry %q", f.Name)
		}
		target := filepath.Join(root, clean)
		rel, err := filepath.Rel(root, target)
		if err != nil || rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator)) {
			return fmt.Errorf("entry escapes extraction root %q", f.Name)
		}
		if f.FileInfo().IsDir() {
			if err := os.MkdirAll(target, 0755); err != nil {
				return err
			}
			continue
		}
		if !f.Mode().IsRegular() {
			return fmt.Errorf("unsupported archive entry %q", f.Name)
		}
		if err := os.MkdirAll(filepath.Dir(target), 0755); err != nil {
			return err
		}
		rc, err := f.Open()
		if err != nil {
			return err
		}
		out, err := os.OpenFile(target, os.O_CREATE|os.O_WRONLY|os.O_EXCL, f.Mode().Perm())
		if err != nil {
			rc.Close()
			return err
		}
		_, cpErr := io.Copy(out, rc)
		closeErr := out.Close()
		rc.Close()
		if cpErr != nil {
			return cpErr
		}
		if closeErr != nil {
			return closeErr
		}
	}
	return nil
}
