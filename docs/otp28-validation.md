# OTP 28.5 Validation Notes

## Summary

This repository was spot-checked again against Erlang/OTP 28.5 on Windows.

The compile picture is better than in the earlier OTP 28.4.1 pass, but the repository is still not fully green:

- the main audited modules in `src/` still compile
- the old `source/recv_eval.erl` spec-syntax blocker is now fixed
- `src/compile.erl` still needs explicit OTP include paths when compiled standalone
- runtime behavior on legacy examples is still the main unresolved compatibility surface

Environment note:

- on this Windows installation, the top-level `bin/erl.exe` and `bin/erlc.exe` wrappers crashed, so the compile checks were run through the working `erts-16.4/bin/erl.exe` runtime instead

## Historical baseline

- `source/` and `source/referl_ast/` should be treated as OTP 17-era work
- `src/` should be treated as OTP 21-era work

## Compile results

### Newer tree: `src/`

Compiled successfully on OTP 28.5:

- `src/semequiv.erl`
- `src/decomp.erl`
- `src/decomptest.erl`
- `src/dumpbeam.erl`
- `src/emulator.erl`
- `src/obfuscation.erl`

Additional note:

- `src/compile.erl` compiles on OTP 28.5 when built with both of these include paths available:
- `code:lib_dir(stdlib, include)` for `erl_compile.hrl`
- `filename:join(code:lib_dir(compiler), "src")` for `core_parse.hrl`
- without those paths, it still fails as a setup issue rather than a language-compatibility issue

### Thesis-era tree: `source/`

Compiled successfully on OTP 28.5:

- `source/calcpi.erl`
- `source/decomp.erl`
- `source/decomptest.erl`
- `source/dumpbeam.erl`
- `source/emulator.erl`
- `source/parcomp.erl`
- `source/recv_eval.erl`
- `source/semequiv.erl`
- `source/trycatch.erl`
- `source/undecidable.erl`

Compatibility fix applied in this pass:

- `source/recv_eval.erl` used legacy `fun(term(), ...)` spec syntax that OTP 28 rejects
- updating those specs to the modern `fun((term(), ...)) -> ...` form clears the only audited compile blocker in `source/`

recv_eval research note:

- `source/recv_eval.S` remains the hand-crafted research assembly artifact in this repository
- the OTP 28 compatibility change was only for the Dialyzer stub in `source/recv_eval.erl`
- automated equivalent generation remains available in `source/em.erl` via `compile:forms(..., [binary, from_asm])` in the final `'receive'/1` and `'receive'/3` helpers

## Runtime smoke tests

### Emulator

The historical example

```erlang
emulator:emulate(calcpi, calc_pi, [1, true, 10]).
```

was not cleanly re-captured in this pass because the Windows terminal harness could not return the full smoke-test output, but the last documented OTP 28 failure is still a crash through a path that reaches `hd([])` in `emulator:emulate/4`.

### Decompiler

The decompiler smoke test was also not cleanly re-captured in this pass for the same terminal-output reason. The last documented OTP 28 failure when attempting to decompile the compiled `calcpi` example was:

- failure site: `decomp:decompile_step/2`
- observed issue: `case_clause` on opcode `fdiv`

This still points to opcode handling drift between the original target OTP level and OTP 28.

## Conclusion

The codebase is still a good historical and research artifact, and much more of it now compiles cleanly on OTP 28.5 than before, but it is not yet fully modernized for OTP 28 runtime behavior.
