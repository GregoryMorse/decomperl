# Decomperl

Decomperl is a research-oriented Erlang/BEAM decompiler and emulator project originating from MSc thesis work and extended with later experimentation.

## Highlights

- Decompilation from BEAM bytecode to Erlang source.
- AST generation and pretty-printing workflows.
- Semantic-equivalence support utilities.
- Emulator-assisted BEAM experimentation.
- Control-flow visualization and statistics collection.
- Obfuscation and assembly manipulation experiments.

## Repository layout

- `src/`: actively maintained implementation and primary entry point.
- `source/`: historical MSc-era tree with additional examples and artifacts.
- `source/referl_ast/`: RefactorERL-oriented variant with integration-specific changes.

Key modules:

- `src/decomp.erl`: decompiler core.
- `src/emulator.erl`: emulator runtime.
- `src/decomptest.erl`: regression and feature test corpus.
- `src/obfuscation.erl`, `src/obfusc.S`, `src/handasm.S`: obfuscation and BEAM assembly experiments.

## Compatibility

Historical baselines:

- `source/` and `source/referl_ast/`: OTP 17 era.
- `src/`: OTP 21 era.

Recent validation (Erlang/OTP 28.5):

- `src/semequiv.erl`, `src/decomp.erl`, `src/decomptest.erl`, `src/dumpbeam.erl`, `src/emulator.erl`, and `src/obfuscation.erl` compile successfully (warnings only).
- `src/compile.erl` also compiles on OTP 28.5 when both stdlib and compiler source include paths are provided.
- `source/recv_eval.erl` was updated to modern `-spec` syntax and now compiles on current OTP.
- Historical `calcpi` smoke runs pass for both emulator and decompiler after OTP 28 compatibility handling for float `bif` forms (`fadd`, `fsub`, `fmul`, `fdiv`, `fnegate`) and typed register wrappers (`tr`).

## Quick start

From an Erlang shell:

```erlang
filelib:ensure_dir("ebin/").
filelib:ensure_dir("temp/").

c:c("src/semequiv.erl", [debug_info, {outdir, "ebin"}]).
c:c("src/decomp.erl", [{outdir, "ebin"}]).
c:c("src/decomptest.erl", [debug_info, {outdir, "ebin"}]).
c:c("src/emulator.erl", [{outdir, "ebin"}]).

code:add_path("ebin").
```

Compile `src/compile.erl` on OTP 28.5:

```erlang
StdlibInclude = code:lib_dir(stdlib, include).
CompilerSrc = filename:join(code:lib_dir(compiler), "src").
c:c("src/compile.erl",
    [{i, StdlibInclude}, {i, CompilerSrc}, {outdir, "ebin"}]).
```

Example workflow:

```erlang
c:c("source/calcpi.erl", [{outdir, "temp"}]).
emulator:emulate(calcpi, calc_pi, [1, true, 10]).
decomp:decompile("temp/calcpi", "temp/calcpi.erl", []).
decomp:decompile("temp/calcpi", "temp/calcpinew.erl",
                 [optimize, changemodname, compile, writeast, dotfile, progress]).
```

Environment notes:

- `OTPSOURCEPATH`: used by newer code when traversing OTP sources.
- `OTPCOMPTEST`: used by the RefactorERL-oriented variant.
- `temp/`: output directory for generated `.erl`, `.ast`, `.stat`, `.err`, and `.dot` artifacts.

## Research artifact note: recv_eval.S

`source/recv_eval.S` is a hand-crafted artifact used in the paper workflow, derived from Erlang/OTP `prim_eval.S` behavior.

- `source/recv_eval.erl` is a Dialyzer-oriented stub module.
- The OTP 28 update in this repository only modernized that stub's `-spec` syntax for compilation compatibility.
- That compatibility update does not replace the role of the hand-crafted `source/recv_eval.S` artifact.

Automated equivalent generation is present at the end of `source/em.erl`, where `'receive'/1` and `'receive'/3` construct and load `recv_eval` via `compile:forms(..., [binary, from_asm])`.

## Documentation

- `docs/refactorerl-integration.md`: maintenance model for the RefactorERL variant.
- `docs/otp28-validation.md`: detailed OTP 28.5 validation notes.
- `docs/ew2026-validation.md`: reproducibility validation for `src/EW2026Examples.erl`.

## Erlang Workshop 2026 supplement

- `README_EW2026.md`: code-supplement README packaged as `README.md` inside
  the submission archive.
- `scripts/build_ew2026_supplement.py`: builds `dist/ew2026-code-supplement.zip`
  containing the EW2026 reproducibility files.

## Provenance and licensing

This repository includes or adapts files derived from Erlang/OTP, including:

- `src/compile.erl`
- `source/recv_eval.erl`
- `source/referl_ast/src/recv_eval.erl`

Upstream copyright and license notices for OTP-derived files are preserved.
