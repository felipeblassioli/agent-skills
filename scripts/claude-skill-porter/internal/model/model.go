package model

import "time"

const Version = "0.1.0"

type Classification string

const (
	Direct       Classification = "direct-skill"
	Scaffolded   Classification = "scaffolded-skill"
	Instructions Classification = "instruction-only"
	Incompatible Classification = "incompatible-extension"
	Unknown      Classification = "unknown"
)

type PortInfo struct {
	SourceArchive  string         `json:"sourceArchive"`
	SourceRoot     string         `json:"sourceRoot"`
	NormalizedSlug string         `json:"normalizedSlug"`
	Classification Classification `json:"classification"`
	ImportedAt     time.Time      `json:"importedAt"`
	Warnings       []string       `json:"warnings"`
	ToolVersion    string         `json:"toolVersion"`
}

type Result struct {
	Command  string   `json:"command"`
	DryRun   bool     `json:"dryRun"`
	Actions  []string `json:"actions"`
	Warnings []string `json:"warnings"`
	Errors   []string `json:"errors"`
}
