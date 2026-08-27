# Erlang Workshop 2026 Code Supplement

This archive is the code supplement for the Erlang Workshop 2026 paper:

**Towards Exact Semantic Equivalence of Erlang BEAM Constructs: Lessons from
Advanced Emulation and Decompilation**

The public development repository is:

<https://github.com/GregoryMorse/decomperl>

This supplement is intentionally small. It contains the original
semantic-equivalence helper corpus used by the paper and a supplemental module
with executable validation examples for the workshop version.

## Contents

- `src/semequiv.erl`: original semantic-equivalence helper corpus used in the
  paper and appendix.
- `src/EW2026Examples.erl`: supplemental executable checks for the Erlang
  Workshop 2026 artifact.
- `docs/ew2026-validation.md`: validation record, command transcript, and
  coverage notes.
- `REPOSITORY_README.md`: contextual README from the full Decomperl repository.
- `scripts/build_ew2026_supplement.py`: packaging script used to create the
  supplement zip.
- `MANIFEST.txt`: generated file list with SHA-256 hashes.

## Requirements

- Erlang/OTP 29.0.5 or later is recommended for reproducing the reported
  validation run.
- Python 3 is required only if rebuilding the supplement zip from the repository.

The validation was performed on Windows with Erlang/OTP 29.0.5 and ERTS 17.0.5.
The commands below use generic executable names; on Windows, replace `erlc` and
`erl` with the full path to the Erlang installation if they are not on `PATH`.

## Quick Validation

From the root of the extracted supplement:

```sh
mkdir -p temp
mkdir -p ebin
erlc +debug_info -o temp src/semequiv.erl
erlc -o ebin src/EW2026Examples.erl
erl -noshell -pz ebin -pz temp -s EW2026Examples main -s init stop
```

Expected result:

```text
PASS original_semequiv_regression
PASS original_utf8_boundary_regression
PASS current_branch_binding_eval_and_compile_rejection
PASS compiled_line_metadata_vs_eval_stack
PASS fun_adapters_include_erased_named_fun_variant
PASS original_fun_arglist_arity_255_one_shot
PASS erl_eval_vs_compiled_fun_arity_limit
PASS catch_try_examples
PASS receive_shape_table_is_represented
PASS pure_erlang_selective_receive_approximation

Summary: 10 passed, 0 skipped, 0 failed.
```

The original corpus can also be checked directly after compiling
`src/semequiv.erl`:

```sh
erl -noshell -pz temp -eval "Result = semequiv:test_sem_equiv(), io:format('~p~n', [Result]), halt()."
```

Expected result:

```text
[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
```

## What Is Covered

The supplement validates:

- the original `src/semequiv.erl` regression corpus;
- UTF-8 boundary behavior for the helper functions used in the paper;
- current OTP branch-binding behavior for the representative unsafe `R`
  binding example;
- compiled line metadata versus `erl_eval` stack frames;
- ordinary, named, and erased one-shot fun adapters;
- the original arity-255 `erase(NamedFun)` adapter path;
- the current `erl_eval` fun-expression arity limit observed at arity 21;
- catch/try structural examples;
- receive shape table examples;
- a pure Erlang selective receive approximation.

The hand-written BEAM selective-receive adapter in the paper is treated as a
BEAM-specific witness rather than a portable pure Erlang regression test on
current OTP. The executable supplement validates the receive shape table and
the portable approximation.

## Rebuilding the Archive

From the full Decomperl repository:

```sh
python scripts/build_ew2026_supplement.py
```

By default this writes:

```text
dist/ew2026-code-supplement.zip
```

The script maps this file to `README.md` at the archive root so that submission
systems expecting that exact file name can consume the supplement without
renaming the repository README.

## Provenance and Licensing

This supplement is derived from the Decomperl research repository. The
repository includes or adapts files derived from Erlang/OTP; upstream copyright
and license notices for OTP-derived files are preserved in the repository.
