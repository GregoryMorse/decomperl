# EW2026 Reproducibility Validation

This record covers `src/EW2026Examples.erl`, the supplemental executable
artifact for the Erlang Workshop 2026 draft examples. The original
semantic-equivalence helper corpus remains in `src/semequiv.erl`.

## Environment

- Validated on Windows with Erlang/OTP 28, ERTS 16.4.
- `src/semequiv.erl` compiles warning-clean on this OTP after the UTF-8 helper
  fix and scoped historical-helper warning attributes.
- The repository root contains historical `compile.beam` artifacts. The example
  module removes the current directory from the Erlang code path before dynamic
  compiler calls so the installed OTP compiler is used.

## Commands

From the repository root:

```powershell
& 'C:\Program Files\Erlang OTP\bin\erlc.exe' +debug_info -o temp src\semequiv.erl
& 'C:\Program Files\Erlang OTP\bin\erlc.exe' src\EW2026Examples.erl
& 'C:\Program Files\Erlang OTP\bin\erl.exe' -noshell -pa . -pa temp -s EW2026Examples main -s init stop
```

The `-s EW2026Examples main` form avoids shell quoting issues around the quoted
module atom.

## Current Result

The validation run completed with:

```text
Summary: 10 passed, 0 skipped, 0 failed.
```

The direct `semequiv:test_sem_equiv/0` run also completed with 15 `true`
results.

## Coverage

- Original `src/semequiv.erl` regression via `test_sem_equiv/0`.
- UTF-8 boundary regression for the original `has_utf8/1`, `get_utf8_size/1`,
  and `get_utf8/1` helpers.
- Current OTP branch-binding behavior: both `erl_eval` and the compiler reject
  the unsafe `R` binding example.
- Compiled line metadata versus `erl_eval` stack traces.
- Ordinary, named, and erased one-shot fun adapters.
- Original `semequiv:fun_arglist/2` arity-255 `erase(NamedFun)` adapter path.
- `erl_eval` fun-expression arity limit: arity 20 is accepted, arity 21 fails
  with `argument_limit`, while ordinary compiled module functions run at arity
  255.
- `catch`/`try` structural examples.
- Receive structural table examples.
- Pure Erlang selective receive approximation.

The hand-written BEAM selective-receive adapter in the paper is intentionally
treated as a BEAM-specific witness rather than a pure Erlang regression test on
current OTP. The executable supplement validates the receive shape table and the
pure Erlang approximation, which is the portable part of that argument.
