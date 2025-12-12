This folder contains basic Stata test harness for the `pip` package.

How to run (in Windows PowerShell):

1. Open Stata and set the working directory to the package root (where `pip.ado` lives).
2. In Stata's command window run:

```powershell
do tests/run_tests.do
```

What the tests do:
- `run_tests.do` runs each test do-file in `tests/` and reports failures using `capture` and `assert`.

Notes:
- These tests assume you have internet access and that `pip_host` is reachable. For offline or CI running you should mock responses or use a local test server.
