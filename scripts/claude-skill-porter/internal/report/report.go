package report

import (
	"encoding/json"
	"fmt"
	"github.com/felipeblassioli/agent-skills/scripts/claude-skill-porter/internal/model"
	"io"
)

func Render(w io.Writer, r model.Result, asJSON bool) error {
	if asJSON {
		b, e := json.MarshalIndent(r, "", "  ")
		if e != nil {
			return e
		}
		_, e = fmt.Fprintln(w, string(b))
		return e
	}
	for _, a := range r.Actions {
		fmt.Fprintln(w, a)
	}
	for _, x := range r.Warnings {
		fmt.Fprintln(w, "warning:", x)
	}
	for _, x := range r.Errors {
		fmt.Fprintln(w, "error:", x)
	}
	return nil
}
