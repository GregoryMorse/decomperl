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

Current validation on Erlang/OTP 28.4.1:

- `src/semequiv.erl`, `src/decomp.erl`, `src/decomptest.erl`, `src/dumpbeam.erl`, `src/emulator.erl`, and `src/obfuscation.erl` compile successfully.
- `src/compile.erl` also compiles on OTP 28 when built with the OTP compiler include directory available; its failure in a plain compile is a setup issue, not the main compatibility blocker.
- In `source/`, all audited modules compiled on OTP 28 except `source/recv_eval.erl`, which fails because of old spec syntax.
- Runtime compatibility is not yet fully restored on OTP 28: the old `calcpi` emulator example crashes in `emulator:emulate/3`, and decompiling the same module currently fails on opcode handling for `fdiv`.

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
- `docs/otp28-validation.md`: spot-check results for Erlang/OTP 28.4.1.