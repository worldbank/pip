---
date: 2026-03-19
title: "GitHub API: Use /releases/latest Instead of /releases for Version Checks"
category: "performance-issues"
language: "Stata"
tags: [github-api, fileread, json-parsing, mata, performance, pip_githubquery]
root-cause: "Using /releases endpoint fetches all releases (~100 KB) and required a fragile Mata+getmata+split pipeline; /releases/latest returns a single object (~2 KB) parseable with one regexm"
severity: "P1"
---

# GitHub API: Use /releases/latest Instead of /releases for Version Checks

## Problem

The original `_pip_githubquery` program queried the `/releases` endpoint:

```stata
local page "https://api.github.com/repos/`repo'/releases"
scalar _pip_gh_page = fileread(`"`page'"')
mata {
    lines = st_strscalar("_pip_gh_page")
    lines = ustrsplit(lines, ",")'   // split ALL json by comma
    lines = strtrim(lines)
    ...
}
getmata lines, replace
split lines, parse("->")
rename lines? (code url)            // fails if split > 9 or > 2 columns
keep if regexm(url, "releases/tag")
gen tag = regexs(2) if regexm(url, "(releases/tag)/(.*)") 
local latestversion = tag[1]
```

**Problems with this approach**:
1. **Payload**: `/releases` returns ALL releases (30 per page by default), each with full changelog markdown — ~50–100 KB for an active repo vs ~2 KB for `/releases/latest`.
2. **Comma-split is semantically wrong**: Changelog bodies contain commas, producing hundreds of spurious rows. The `keep if regexm(url, "releases/tag")` filter only works by accident.
3. **`rename lines? (code url)` is fragile**: The `?` wildcard matches only single-character suffixes (`lines1`–`lines9`). With 10+ split columns (`lines10`) or 3+ `->` tokens per row, the rename errors silently inside `capture`.
4. **`preserve`/`restore` serializes user data**: With a large dataset loaded, `preserve` writes the entire dataset to disk before `drop _all` — pure overhead for a version check.
5. **`scalar drop` outside `capture`**: If `fileread` fails, the scalar is never created, but `scalar drop` runs unconditionally → user-visible error on every offline `pip` call.
6. **Naming**: Leading underscore `_pip_githubquery` breaks the `pip_*` prefix convention used everywhere in the package.

## Root Cause

The endpoint choice (`/releases` vs `/releases/latest`) drove all the downstream complexity. Once you fetch the full list, you need Mata to handle the large payload, which requires a dataset pipeline, which requires `preserve`/`restore`, which causes the scalar-drop bug.

## Solution

Replace the entire program with a 5-line version using `/releases/latest`:

```stata
program define pip_githubquery, rclass
version 16.1
syntax anything(name=repo)

local latestversion ""
capture {
    local page `"https://api.github.com/repos/`repo'/releases/latest"'
    scalar _pip_gh_json = fileread(`"`page'"')
    if regexm(scalar(_pip_gh_json), `""tag_name": *\"([^\"]+)\""') {
        local latestversion = regexs(1)
    }
}
capture scalar drop _pip_gh_json

* Strip leading 'v' prefix from tag if present (e.g. "v0.11.0" -> "0.11.0")
if regexm("`latestversion'", "^v(.+)") local latestversion = regexs(1)

return local latestversion `latestversion'

end
```

**What this eliminates vs the original**:

| Removed | Why |
|---------|-----|
| `preserve` / `restore` | No dataset operations needed |
| `drop _all` | No dataset operations needed |
| Mata block | Single `regexm` on scalar suffices |
| `getmata` | No dataset operations needed |
| `split` / `rename` / `keep` / `gen` | No dataset operations needed |
| `scalar drop` outside `capture` | Moved inside `capture scalar drop` |
| `_pip_githubquery` name | Renamed to `pip_githubquery` |

**Additional fixes bundled**:
- `capture scalar drop _pip_gh_json` (not plain `scalar drop`) — safe even if scalar was never created (network failed before `fileread`)
- `v` prefix stripped from tag with `regexm("^v(.+)")` — handles tags like `v0.11.0`

## Prevention

- When choosing a REST endpoint for a single value, always prefer the most specific endpoint (e.g., `/releases/latest` over `/releases`).
- Avoid loading API responses into Stata datasets when a single `regexm` or `mata` scalar parse would suffice.
- When using `scalar` inside `capture`, always use `capture scalar drop` (not plain `scalar drop`) to clean up — the scalar may not have been created if the capture block errored early.
- Name auxiliary programs with the package prefix (`pip_githubquery`, not `_pip_githubquery`) to remain consistent and to allow Stata autoload if ever split into a separate file.

## Related

- `.cg-docs/solutions/bugs/2026-03-19-stata-scalar-drop-outside-capture.md` — the `scalar drop` gotcha surfaced by this refactor
- `.cg-docs/solutions/bugs/2026-03-19-stata-semantic-version-comparison.md` — the version comparison bug fixed in the same session
- `.cg-docs/solutions/bugs/2026-03-19-github-api-tag-name-regex-space.md` — the regex introduced here had a bug: `"tag_name":"` must be `"tag_name": *"` to match real API responses (space after colon)
- `.cg-docs/solutions/bugs/2026-03-19-stata-exit-vs-exit1-stale-rclass.md` — the silent-skip exits in `pip_githubquery`'s caller masked the regex failure entirely
