# Scripts

Automated checks that produce compact JSON output for agent consumption.

## Usage

```bash
bash scripts/audit-test-doubles.sh [PROJECT_ROOT]
```

Defaults `PROJECT_ROOT` to the current working directory.

## Output Contract

All scripts write:
- **Status messages** to stderr
- **Machine-readable JSON** to stdout

### audit-test-doubles.sh

Scans test files for mock/spy/fake usage patterns and reports counts per file.

**Output schema:**

```json
{
  "total_files_scanned": 42,
  "files_with_mocks": 5,
  "summary": [
    {
      "file": "src/order/order.test.ts",
      "vi_fn": 3,
      "vi_spyOn": 1,
      "vi_mock": 0,
      "jest_fn": 0,
      "jest_spyOn": 0,
      "jest_mock": 0,
      "total_doubles": 4,
      "flag": "review"
    }
  ]
}
```

**Flag values:**
- `"ok"` — 0–2 doubles per file (normal)
- `"review"` — 3–5 doubles per file (worth checking)
- `"warning"` — 6+ doubles per file (likely mock overuse)
