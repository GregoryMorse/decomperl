# OTP 28.4.1 Validation Notes

## Summary

This repository was spot-checked against Erlang/OTP 28.4.1 on Windows.

The result is encouraging but not fully green:

- most audited modules still compile
- one thesis-era file has syntax drift
- the decompiler and emulator still have runtime incompatibilities on at least one legacy example

## Historical baseline

- `source/` and `source/referl_ast/` should be treated as OTP 17-era work
- `src/` should be treated as OTP 21-era work

## Compile results

### Newer tree: `src/`

Compiled successfully on OTP 28.4.1:

- `src/semequiv.erl`
- `src/decomp.erl`
- `src/decomptest.erl`
- `src/dumpbeam.erl`
- `src/emulator.erl`
- `src/obfuscation.erl`

Additional note:

- `src/compile.erl` compiles when built with OTP compiler include paths available
- without those include paths, it fails as a setup issue rather than a language-compatibility issue

### Thesis-era tree: `source/`

Compiled successfully on OTP 28.4.1:

- `source/calcpi.erl`
- `source/decomp.erl`
- `source/decomptest.erl`
- `source/dumpbeam.erl`
- `source/emulator.erl`
- `source/parcomp.erl`
- `source/semequiv.erl`
- `source/trycatch.erl`
- `source/undecidable.erl`

Failed:

- `source/recv_eval.erl`

Failure reason:

- old `-spec` syntax is rejected by OTP 28

## Runtime smoke tests

### Emulator

The historical example

```erlang
emulator:emulate(calcpi, calc_pi, [1, true, 10]).
```

currently crashes on OTP 28 through a path that reaches `hd([])` in `emulator:emulate/4`.

### Decompiler

The decompiler currently fails on OTP 28 when attempting to decompile the compiled `calcpi` example:

- failure site: `decomp:decompile_step/2`
- observed issue: `case_clause` on opcode `fdiv`

This indicates opcode handling drift between the original target OTP level and OTP 28.

## Conclusion

The codebase is still a good historical and research artifact, and much of it remains buildable on OTP 28.4.1, but it is not yet fully modernized for OTP 28 runtime behavior.
