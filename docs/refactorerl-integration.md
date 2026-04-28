# RefactorERL Integration Notes

This document summarizes how RefactorERL-related support appears in this repository and how the historical integration tree relates to the main codebase.

## Current model

- `src/` is the canonical implementation for decompiler and emulator work.
- `source/referl_ast/` is a historical integration snapshot preserved for reference.

The repository keeps one primary implementation tree and retains the RefactorERL variant as historical context rather than a second actively synchronized codebase.

## Historical integration assets

Integration metadata and packaging references:

- `source/referl_ast/build.rules`
- `source/referl_ast/src/referl_ast.appspec`
- `source/referl_ast/src/selfmod.erl`
- `source/referl_ast/readme.txt`

Integration-delta reference modules:

- `source/referl_ast/src/decomp.erl`
- `source/referl_ast/src/semequiv.erl`
- `source/referl_ast/src/em.erl`
- `source/referl_ast/src/recv_eval.erl`

## RefactorERL-specific deltas

### AST access hook

The RefactorERL variant exposes `get_ast_self/0` in `semequiv.erl` and imports it in `decomp.erl`, enabling decompiler flows over AST forms provided by the integration environment.

### Directory-level decompilation helpers

The historical variant includes `decomp_dir/4` and related helpers for directory-oriented processing.

### Environment and path handling

The integration path moved away from hard-coded paths toward environment-driven values such as `OTPCOMPTEST` and `code:root_dir()`.

### Packaging metadata

`build.rules` and `referl_ast.appspec` are integration packaging assets and are not part of the general Decomperl source surface.

## Regeneration outline

When integration refresh is needed, the observed workflow is:

1. Start from modules in `src/`.
2. Select only modules required for integration.
3. Reapply the minimal RefactorERL-specific deltas.
4. Keep integration packaging metadata local to the integration tree.

## Maintenance direction

For active long-term maintenance, one of these approaches reduces drift more effectively than two fully duplicated trees:

- A small patch stack over canonical `src/` modules.
- A scripted export step that assembles the integration variant.
- A dedicated integration branch with narrowly scoped commits.