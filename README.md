# Decomperl

Decomperl is an experimental Erlang BEAM decompiler and emulator project developed from MSc thesis work and continued afterward with newer cleanup, decompilation, and obfuscation experiments.

The repository currently contains three historical layers:

- `src/`: the newer working codebase and the best starting point for further development.
- `source/`: the MSc-era source tree, including extra examples, experiments, and the original notes.
- `source/referl_ast/`: a RefactorERL-oriented variant with integration-specific edits and build metadata.

## What is here

- A BEAM decompiler in `src/decomp.erl` with AST output, pretty-printing, statistics generation, and graph export options.
- An emulator in `src/emulator.erl` for experimenting with BEAM-level behavior.
- A large regression and feature test corpus in `src/decomptest.erl`.
- Obfuscation and BEAM assembly experiments in `src/obfuscation.erl`, `src/obfusc.S`, and `src/handasm.S`.
- Thesis-era example modules such as `calcpi`, `trycatch`, `undecidable`, and `recv_eval` under `source/`.

## Repository status

This repository has not yet been normalized into a single publishable source layout. The current recommendation is:

- Treat `src/` as the canonical codebase.
- Keep `source/` as a historical archive of the MSc version.
- Treat `source/referl_ast/` as a derived integration target, not as a second primary source tree.

The detailed audit and merge recommendation are in `docs/repository-audit.md`.

## Compatibility

Historical support baseline:

- `source/` is the MSc-era codebase and should be treated as the OTP 17 baseline.
- `src/` is the later post-MSc codebase and should be treated as the OTP 21 baseline.
- `source/referl_ast/` belongs with the MSc-era integration work and should also be treated as OTP 17-era code.

Current validation on Erlang/OTP 28.5:

- `src/semequiv.erl`, `src/decomp.erl`, `src/decomptest.erl`, `src/dumpbeam.erl`, `src/emulator.erl`, and `src/obfuscation.erl` compile successfully on OTP 28.5, with warnings but no blocking errors.
- `src/compile.erl` also compiles on OTP 28.5, but not as a plain standalone file. It now needs both the stdlib include directory for `erl_compile.hrl` and the compiler source directory for `core_parse.hrl`.
- In `source/`, the previously failing `source/recv_eval.erl` compile blocker has been fixed by updating its legacy `-spec` syntax to the form accepted by modern OTP releases.
- The repository is in better shape for OTP 28.5 compilation than before, but runtime compatibility is still the main unresolved area.

That means the repository is historically documented as OTP 17 and OTP 21 work, but it should not yet be described as fully OTP 28 compatible.

## Quick start

This codebase assumes a local Erlang/OTP installation and some workflows also assume an unpacked OTP source tree for compiler tests.

Typical interactive setup from an Erlang shell:

```erlang
filelib:ensure_dir("ebin/").
filelib:ensure_dir("temp/").

c:c("src/semequiv.erl", [debug_info, {outdir, "ebin"}]).
c:c("src/decomp.erl", [{outdir, "ebin"}]).
c:c("src/decomptest.erl", [debug_info, {outdir, "ebin"}]).
c:c("src/emulator.erl", [{outdir, "ebin"}]).

code:add_path("ebin").
```

`src/compile.erl` needs OTP 28.5 header paths that are no longer in a single compiler include directory. In an Erlang shell, compile it with:

```erlang
StdlibInclude = code:lib_dir(stdlib, include).
CompilerSrc = filename:join(code:lib_dir(compiler), "src").
c:c("src/compile.erl",
    [{i, StdlibInclude}, {i, CompilerSrc}, {outdir, "ebin"}]).
```

Example usage:

```erlang
c:c("source/calcpi.erl", [{outdir, "temp"}]).
emulator:emulate(calcpi, calc_pi, [1, true, 10]).
decomp:decompile("temp/calcpi", "temp/calcpi.erl", []).
decomp:decompile("temp/calcpi", "temp/calcpinew.erl",
                 [optimize, changemodname, compile, writeast, dotfile, progress]).
```

Environment notes:

- `OTPSOURCEPATH` is used by the newer code when traversing OTP sources.
- `OTPCOMPTEST` is used by the RefactorERL-oriented variant.
- `temp/` is used for generated `.erl`, `.ast`, `.stat`, `.err`, and `.dot` artifacts.

## recv_eval.S Status

For the paper workflow, `source/recv_eval.S` is the intended hand-crafted research artifact.
It is a custom experiment derived from Erlang/OTP `prim_eval.S` behavior and remains valid as-is for this repository.

Important distinction:

- `source/recv_eval.erl` is a Dialyzer-oriented stub module.
- the OTP 28 update in this repository only fixed its `-spec` syntax so the stub compiles again.
- that stub compile fix is not a reason to regenerate or replace the hand-crafted `source/recv_eval.S` used for research output.

Automated equivalent generation is already present in code at the end of `source/em.erl`, where `'receive'/1` and `'receive'/3` build and load `recv_eval` through `compile:forms(..., [binary, from_asm])`.

## Public-facing structure

If you publish this repository as-is, present it as a research prototype with preserved historical context, not as a polished library.

Good showcase points:

- decompilation from BEAM to Erlang source and AST
- semantic-equivalence support utilities
- emulator-assisted experimentation
- control-flow visualization and statistics collection
- later obfuscation and assembly manipulation experiments

## Provenance and licensing notes

This repository includes or adapts files derived from Erlang/OTP, including at least:

- `src/compile.erl`
- `source/recv_eval.erl`
- `source/referl_ast/src/recv_eval.erl`

Those files retain their upstream copyright and license notices. Before publishing publicly, add a top-level license decision for your own code and keep upstream notices intact for OTP-derived files.

## Additional documentation

- `docs/repository-audit.md`: recommended repository shape and merge policy.
- `docs/refactorerl-integration.md`: how to maintain the RefactorERL-oriented variant without keeping two primary codebases in sync by hand.
- `docs/otp28-validation.md`: spot-check results for Erlang/OTP 28.5.