# OTP 28.5 Validation Record (Archived)

This file is kept as a historical validation log. The primary status now lives in [README.md](../README.md).

## Final status

The OTP 28.5 validation pass on Windows is clean for the currently maintained workflows:

- audited `src/` and `source/` modules compile
- `source/recv_eval.erl` compiles after modernizing legacy spec syntax
- runtime smoke test for `calcpi` passes in both emulator and decompiler

## Notable compatibility fixes captured in this pass

- Added OTP 28 float `bif` compatibility in emulator/decompiler for:
	- `fadd`
	- `fsub`
	- `fmul`
	- `fdiv`
	- `fnegate`
- Added unwrapping support for typed register operands in `tr` form.

## Remaining setup caveat

`src/compile.erl` requires explicit include paths when compiled standalone:

- `code:lib_dir(stdlib, include)`
- `filename:join(code:lib_dir(compiler), "src")`

This is an environment/setup requirement, not an unresolved runtime blocker.
