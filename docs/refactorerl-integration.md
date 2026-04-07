# RefactorERL Integration Procedure

## Goal

Maintain one primary implementation tree and regenerate the RefactorERL-oriented variant intentionally, instead of hand-maintaining two diverging copies.

## Recommended source of truth

Use `src/` as the source of truth for the decompiler and emulator code.

The existing `source/referl_ast/` tree should be treated as a historical integration snapshot that documents what was needed for RefactorERL at the time.

## Inputs to preserve from the historical variant

Keep these files as integration metadata or references:

- `source/referl_ast/build.rules`
- `source/referl_ast/src/referl_ast.appspec`
- `source/referl_ast/src/selfmod.erl`
- `source/referl_ast/readme.txt`

Use these files as references for integration-specific edits:

- `source/referl_ast/src/decomp.erl`
- `source/referl_ast/src/semequiv.erl`
- `source/referl_ast/src/em.erl`
- `source/referl_ast/src/recv_eval.erl`

## Reconstruction procedure

1. Start from the current core modules in `src/`.
2. Copy only the modules required for RefactorERL integration into a fresh integration working tree.
3. Reapply the historical RefactorERL-specific edits selectively.
4. Keep the integration metadata local to the RefactorERL tree rather than back-porting it into the main repository.

## Known RefactorERL-specific concerns

### 1. AST access hook

The RefactorERL variant exposes `get_ast_self/0` in `semequiv.erl` and imports it in `decomp.erl` so the decompiler can work with AST forms loaded from the integration environment.

### 2. Directory-level decompilation

The RefactorERL variant includes `decomp_dir/4` and related convenience flows for processing directory trees.

### 3. Environment-path differences

The historical variant switched from hard-coded Windows paths to environment-driven paths such as `OTPCOMPTEST` and `code:root_dir()`.

### 4. RefactorERL build metadata

`build.rules` and `referl_ast.appspec` are integration packaging files, not general Decomperl source files.

## Minimal practical approach

If you want a low-maintenance setup, do this:

1. Keep the main repository focused on `src/` and thesis/archive material.
2. Keep `source/referl_ast/` as documentation of the old integration shape.
3. When you need to revive the RefactorERL integration, create a fresh branch or working copy and replay only the necessary integration edits.

## Optional future improvement

If you expect to maintain the integration actively, replace the duplicated directory with one of these approaches:

- a small patch set against the canonical `src/` modules
- a scripted export step that assembles the RefactorERL variant
- a dedicated integration branch with narrowly scoped commits

Any of those is easier to maintain than two full source trees that drift independently.