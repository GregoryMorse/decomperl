%% Supplemental reproducibility examples for "Towards Exact Semantic
%% Equivalence of Erlang BEAM constructs" (Erlang Workshop 2026 draft).
%%
%% The original semantic-equivalence helper corpus lives in src/semequiv.erl.
%% This module loads and validates that corpus, then runs only supplemental
%% examples that were documented for the paper but were not previously encoded
%% as executable checks.
%%
%% Compile and run on an OTP installation with:
%%
%%     erlc src/EW2026Examples.erl
%%     erl -noshell -pa . -pa temp -s EW2026Examples main -s init stop

-module('EW2026Examples').
-export([all/0, main/0, main/1, run/0]).

main() -> main([]).

main(_Args) ->
    Results = run(),
    Passed = [Name || {Name, pass} <- Results],
    Skipped = [{Name, Reason} || {Name, {skip, Reason}} <- Results],
    Failed = [{Name, Reason} || {Name, {fail, Reason}} <- Results],
    io:format("~nSummary: ~B passed, ~B skipped, ~B failed.~n",
              [length(Passed), length(Skipped), length(Failed)]),
    case Skipped of [] -> ok; _ -> io:format("Skipped: ~p~n", [Skipped]) end,
    case Failed of [] -> ok; _ -> erlang:error({ew2026_examples_failed, Failed}) end.

run() -> [run_one(Name, Test) || {Name, Test} <- all()].

all() ->
    [{original_semequiv_regression, fun test_original_semequiv/0},
     {original_utf8_boundary_regression, fun test_original_utf8_boundaries/0},
     {current_branch_binding_eval_and_compile_rejection, fun test_branch_binding/0},
     {compiled_line_metadata_vs_eval_stack, fun test_line_metadata/0},
     {fun_adapters_include_erased_named_fun_variant, fun test_fun_adapters/0},
     {original_fun_arglist_arity_255_one_shot, fun test_original_fun_arglist_arity_255/0},
     {erl_eval_vs_compiled_fun_arity_limit, fun test_eval_vs_compiled_fun_arity/0},
     {catch_try_examples, fun test_catch_try_examples/0},
     {receive_shape_table_is_represented, fun test_receive_shape_table/0},
     {pure_erlang_selective_receive_approximation, fun test_emu_receive/0}].

run_one(Name, Test) ->
    try Test(), io:format("PASS ~p~n", [Name]), {Name, pass}
    catch
        throw:{skip, Reason} ->
            io:format("SKIP ~p: ~p~n", [Name, Reason]),
            {Name, {skip, Reason}};
        Class:Reason:Stacktrace ->
            io:format("FAIL ~p: ~p:~p~nStack: ~p~n", [Name, Class, Reason, Stacktrace]),
            {Name, {fail, {Class, Reason}}}
    end.

assert(true, _Message) -> ok;
assert(false, Message) -> erlang:error({assertion_failed, Message}).

assert_equal(Expected, Actual, _Message) when Expected =:= Actual -> ok;
assert_equal(Expected, Actual, Message) ->
    erlang:error({assert_equal_failed, Message, [{expected, Expected}, {actual, Actual}]}).

%% ------------------------------------------------------------------
%% Original semantic-equivalence corpus.

test_original_semequiv() ->
    ensure_semequiv_loaded(),
    assert_equal(lists:duplicate(15, true), semequiv:test_sem_equiv(), semequiv_test_sem_equiv),
    ok.

test_original_utf8_boundaries() ->
    ensure_semequiv_loaded(),
    Valid = [0, $A, 16#80, 16#7ff, 16#20ac, 16#f800, 16#1f600, 16#10ffff],
    lists:foreach(fun(Codepoint) ->
        Binary = <<Codepoint/utf8>>,
        <<Native/utf8, _/bitstring>> = Binary,
        assert(semequiv:has_utf8(Binary), {has_utf8, Codepoint}),
        assert_equal(byte_size(Binary), semequiv:get_utf8_size(Binary), {utf8_size, Codepoint}),
        assert_equal(Native, semequiv:get_utf8(Binary), {utf8_decode, Codepoint})
    end, Valid),
    Invalid = [<<16#80>>, <<16#c0, 16#80>>, <<16#ed, 16#a0, 16#80>>,
               <<16#f4, 16#90, 16#80, 16#80>>],
    lists:foreach(fun(Binary) ->
        assert(not semequiv:has_utf8(Binary), {invalid_utf8, Binary})
    end, Invalid),
    ok.

test_original_fun_arglist_arity_255() ->
    ensure_semequiv_loaded(),
    Fun = semequiv:fun_arglist(fun(Args) -> length(Args) end, 255),
    Args = lists:seq(1, 255),
    assert_equal(255, apply(Fun, Args), semequiv_fun_arglist_255_first_call),
    assert(is_badfun_exit(catch apply(Fun, Args)), semequiv_fun_arglist_255_second_call_fails),
    ok.

ensure_semequiv_loaded() ->
    case code:is_loaded(semequiv) of
        false -> load_semequiv_from_source();
        _ -> ok
    end.

load_semequiv_from_source() ->
    ensure_otp_compiler(),
    case compile:file("src/semequiv.erl", [binary, debug_info, return_errors, return_warnings]) of
        {ok, semequiv, Binary} ->
            load_semequiv_binary(Binary);
        {ok, semequiv, Binary, []} ->
            load_semequiv_binary(Binary);
        {ok, semequiv, _Binary, Warnings} ->
            erlang:error({semequiv_compile_warnings, Warnings});
        Error ->
            erlang:error({semequiv_compile_failed, Error})
    end.

load_semequiv_binary(Binary) ->
    code:purge(semequiv),
    code:delete(semequiv),
    {module, semequiv} = code:load_binary(semequiv, "src/semequiv.erl", Binary),
    ok.

ensure_otp_compiler() ->
    Cwd = filename:absname("."),
    lists:foreach(fun(Path) ->
        case filename:absname(Path) of
            Cwd -> code:del_path(Path);
            _ -> ok
        end
    end, code:get_path()),
    code:purge(compile),
    code:delete(compile),
    {module, compile} = code:ensure_loaded(compile),
    ok.

%% ------------------------------------------------------------------
%% Stack trace and line metadata.

test_line_metadata() ->
    assert(getlinenumber(), compiled_beam_line_metadata_matches_source_line),
    EvalStacktrace = eval_expr("try error(undef) catch _:_:Stacktrace -> Stacktrace end"),
    assert(stack_has_module(erl_eval, EvalStacktrace), eval_stack_contains_erl_eval_frames),
    ok.

getlinenumber() ->
    ?LINE =:= try error(undef)
    catch _:_:Stacktrace ->
        {_Module, _Function, _Arity, Info} = hd(Stacktrace),
        proplists:get_value(line, Info)
    end.

stack_has_module(Module, Stacktrace) ->
    lists:any(fun
        ({FrameModule, _Function, _ArityOrArgs, _Info}) when FrameModule =:= Module -> true;
        (_) -> false
    end, Stacktrace).

eval_expr(Source) ->
    {ok, Tokens, _EndLine} = erl_scan:string(Source ++ "."),
    {ok, Expressions} = erl_parse:parse_exprs(Tokens),
    {value, Value, _Bindings} = erl_eval:exprs(Expressions, []),
    Value.

parse_form(Source) ->
    {ok, Tokens, _EndLine} = erl_scan:string(Source),
    {ok, Form} = erl_parse:parse_form(Tokens),
    Form.

compile_forms_to_binary(Forms) ->
    ensure_otp_compiler(),
    case compile:forms(Forms, [binary, return_errors, return_warnings]) of
        {ok, Module, Binary} -> {ok, Module, Binary};
        {ok, Module, Binary, []} -> {ok, Module, Binary};
        {ok, _Module, _Binary, Warnings} -> erlang:error({compile_forms_warnings, Warnings});
        Error -> erlang:error({compile_forms_failed, Error})
    end.

%% ------------------------------------------------------------------
%% Branch binding safety.

test_branch_binding() ->
    Source = "fun(A, B) -> if A -> R = 0; B -> R = 1; true -> error({A, B}), R end end",
    EvalResult = catch eval_expr(Source),
    assert(match_exit_reason({unbound_var, 'R'}, EvalResult),
           current_erl_eval_rejects_unsafe_branch_binding),
    FunctionForm = parse_form("branch_binding_fun() -> " ++ Source ++ "."),
    CompileForms = [{attribute, 1, module, ew2026_branch_binding},
                    {attribute, 1, export, [{branch_binding_fun, 0}]},
                    FunctionForm],
    ensure_otp_compiler(),
    CompileResult = compile:forms(CompileForms, [binary, return_errors, return_warnings]),
    assert(is_compile_error(CompileResult), compiler_rejects_unsafe_branch_binding),
    ok.

is_compile_error({error, _Errors, _Warnings}) -> true;
is_compile_error(error) -> true;
is_compile_error(_Other) -> false.

%% ------------------------------------------------------------------
%% Fun adapter examples. The erase(NamedFun) variant is one-shot.

test_fun_adapters() ->
    Ordinary = ordinary_adapter(fun erlang:tuple_size/1),
    assert_equal(3, Ordinary(a, b, c), ordinary_adapter_first_call),
    assert_equal(3, Ordinary(d, e, f), ordinary_adapter_second_call),
    Reusable = named_fun_adapter_reusable(fun erlang:tuple_size/1),
    assert_equal(3, Reusable(a, b, c), reusable_named_fun_first_call),
    assert_equal(3, Reusable(d, e, f), reusable_named_fun_second_call),
    cleanup_named_fun_adapter(Reusable),
    OneShot = named_fun_adapter_one_shot(fun erlang:tuple_size/1),
    assert_equal(3, OneShot(a, b, c), erased_named_fun_first_call),
    assert(is_badfun_exit(catch OneShot(d, e, f)), erased_named_fun_second_call_fails),
    ok.

ordinary_adapter(Fun) -> fun(Arg1, Arg2, Arg3) -> Fun({Arg1, Arg2, Arg3}) end.

named_fun_adapter_reusable(Fun) ->
    NewFun = fun NamedFun(Arg1, Arg2, Arg3) ->
        StoredFun = get(NamedFun),
        StoredFun({Arg1, Arg2, Arg3})
    end,
    put(NewFun, Fun),
    NewFun.

named_fun_adapter_one_shot(Fun) ->
    NewFun = fun NamedFun(Arg1, Arg2, Arg3) ->
        StoredFun = get(NamedFun),
        erase(NamedFun),
        StoredFun({Arg1, Arg2, Arg3})
    end,
    put(NewFun, Fun),
    NewFun.

cleanup_named_fun_adapter(Fun) -> erase(Fun), ok.

is_badfun_exit({'EXIT', {{badfun, _}, _Stacktrace}}) -> true;
is_badfun_exit({'EXIT', {badfun, _Stacktrace}}) -> true;
is_badfun_exit(_Other) -> false.

%% ------------------------------------------------------------------
%% erl_eval and compiled BEAM arity limits.

test_eval_vs_compiled_fun_arity() ->
    Eval20 = make_eval_tuple_size_fun(20),
    assert_equal(20, apply(Eval20, lists:seq(1, 20)), eval_accepts_arity_20_fun),
    assert(is_argument_limit_exit(catch make_eval_tuple_size_fun(21)),
           eval_rejects_arity_21_fun),
    Module = ew2026_compiled_arity_255,
    Args255 = lists:seq(1, 255),
    try
        compile_tuple_size_module(Module, 255),
        assert_equal(255, apply(Module, tuple_size_255, Args255),
                     compiled_beam_accepts_arity_255_fun)
    after
        code:purge(Module),
        code:delete(Module)
    end,
    ok.

make_eval_tuple_size_fun(Arity) ->
    Args = arity_args(Arity),
    eval_expr("fun(" ++ Args ++ ") -> tuple_size({" ++ Args ++ "}) end").

compile_tuple_size_module(Module, Arity) ->
    Args = arity_args(Arity),
    Function = list_to_atom("tuple_size_" ++ integer_to_list(Arity)),
    FunctionForm = parse_form(atom_to_list(Function) ++ "(" ++ Args ++ ") -> "
                              "tuple_size({" ++ Args ++ "})."),
    Forms = [{attribute, 1, module, Module},
             {attribute, 1, export, [{Function, Arity}]},
             FunctionForm],
    {ok, Module, Binary} = compile_forms_to_binary(Forms),
    code:purge(Module),
    code:delete(Module),
    {module, Module} = code:load_binary(Module, atom_to_list(Module), Binary),
    ok.

arity_args(Arity) ->
    string:join(["X" ++ integer_to_list(Index) || Index <- lists:seq(1, Arity)], ",").

is_argument_limit_exit({'EXIT', {{argument_limit, _Term}, _Stacktrace}}) -> true;
is_argument_limit_exit(_Other) -> false.

%% ------------------------------------------------------------------
%% Catch/try examples.

test_catch_try_examples() ->
    assert_equal(value, catch throw(value), catch_turns_throw_into_success),
    assert(match_exit_reason(problem, catch error(problem)), catch_wraps_error_as_exit_tuple),
    assert_equal({success, value}, trytocatch(fun() -> value end,
                                             fun(Value) -> {success, Value} end,
                                             fun(Class, Reason, _Stacktrace) -> {caught, Class, Reason} end),
                 trytocatch_normal_path),
    assert_equal({success, thrown}, trytocatch(fun() -> throw(thrown) end,
                                              fun(Value) -> {success, Value} end,
                                              fun(Class, Reason, _Stacktrace) -> {caught, Class, Reason} end),
                 trytocatch_throw_path),
    assert_equal({caught, error, problem}, trytocatch(fun() -> error(problem) end,
                                                     fun(Value) -> {success, Value} end,
                                                     fun(Class, Reason, _Stacktrace) -> {caught, Class, Reason} end),
                 trytocatch_error_path),
    assert_equal({caught, exit, goodbye}, trytocatch(fun() -> exit(goodbye) end,
                                                    fun(Value) -> {success, Value} end,
                                                    fun(Class, Reason, _Stacktrace) -> {caught, Class, Reason} end),
                 trytocatch_exit_path),
    assert_equal(2, length(catch_structural_table()), catch_table_rows),
    assert_equal(6, length(try_structural_table()), try_table_rows),
    ok.

match_exit_reason(Reason, {'EXIT', {Reason, _Stacktrace}}) -> true;
match_exit_reason(Reason, {'EXIT', Reason}) -> true;
match_exit_reason(_Reason, _Other) -> false.

trytocatch(TryFun, TryCaseFun, CatchCaseFun) ->
    try TryFun() of Success -> TryCaseFun(Success)
    catch
        throw:Term -> TryCaseFun(Term);
        error:Reason:Stacktrace -> CatchCaseFun(error, Reason, Stacktrace);
        exit:Term:Stacktrace -> CatchCaseFun(exit, Term, Stacktrace)
    end.

catch_structural_table() -> [{catch_expression, single_path}, {catch_then_exit, no_path}].

try_structural_table() ->
    [{try_exit_catch, no_tcb, catch_path},
     {try_exit_catch_exit, no_tcb, no_path},
     {try_exprs_catch, tcb, merge},
     {try_exprs_of_exit_catch, tcb, catch_path},
     {try_exprs_catch_exit, tcb, try_case},
     {try_exprs_of_exit_catch_exit, tcb, no_path}].

%% ------------------------------------------------------------------
%% Selective receive examples.

test_receive_shape_table() ->
    Table = receive_structural_table(),
    assert_equal(25, length(Table), receive_table_row_count),
    assert(lists:member({halt_receive_after_infinity, false, infinity, no_path}, Table),
           receive_after_infinity_row),
    assert(lists:member({receive_selective_after_n, true, n, merge}, Table),
           selective_after_n_row),
    ok.

receive_structural_table() ->
    [{yield_receive_after_0, false, 0, after_only},
     {yield_receive_after_0_exit, false, 0, no_path},
     {sleep_receive_after_n, false, n, after_only},
     {sleep_receive_after_n_exit, false, n, no_path},
     {halt_receive_after_infinity, false, infinity, no_path},
     {receive_any_after_0, false, 0, merge},
     {receive_any_after_0_exit, false, 0, message_only},
     {receive_any_exit_after_0, false, 0, after_only},
     {receive_any_exit_after_0_exit, false, 0, no_path},
     {receive_any_after_n, false, n, merge},
     {receive_any_after_n_exit, false, n, message_only},
     {receive_any_exit_after_n, false, n, after_only},
     {receive_any_exit_after_n_exit, false, n, no_path},
     {receive_any, false, infinity, message_only},
     {receive_any_exit, false, infinity, no_path},
     {receive_selective_after_0, true, 0, merge},
     {receive_selective_after_0_exit, true, 0, message_only},
     {receive_selective_exit_after_0, true, 0, after_only},
     {receive_selective_exit_after_0_exit, true, 0, no_path},
     {receive_selective_after_n, true, n, merge},
     {receive_selective_after_n_exit, true, n, message_only},
     {receive_selective_exit_after_n, true, n, after_only},
     {receive_selective_exit_after_n_exit, true, n, no_path},
     {receive_selective, true, infinity, message_only},
     {receive_selective_exit, true, infinity, no_path}].

test_emu_receive() ->
    flush_mailbox(),
    self() ! skip,
    self() ! wanted,
    Start = erlang:monotonic_time(millisecond),
    {Result, Buffered} = emu_receive(fun(Message) ->
        case Message of wanted -> {true, found}; _ -> false end
    end, 1000, fun() -> timeout end, Start, []),
    assert_equal(found, Result, emu_receive_finds_second_message),
    assert_equal([skip], Buffered, emu_receive_buffers_unmatched_message),
    assert_equal({message_queue_len, 0}, process_info(self(), message_queue_len),
                 emu_receive_consumed_real_mailbox),
    TimeoutStart = erlang:monotonic_time(millisecond),
    assert_equal({timeout, []}, emu_receive(fun(_Message) -> false end, 0,
                                            fun() -> timeout end, TimeoutStart, []),
                 emu_receive_after_zero_timeout),
    ok.

emu_receive(Fr, infinity, _Fa, _Start, Mailbox) ->
    receive Message ->
        case Fr(Message) of
            {true, Result} -> {Result, Mailbox};
            _ -> emu_receive(Fr, infinity, ignored, ignored, Mailbox ++ [Message])
        end
    end;
emu_receive(Fr, Timeout, Fa, Start, Mailbox) ->
    Now = erlang:monotonic_time(millisecond),
    Elapsed = Now - Start,
    case Timeout =< Elapsed of
        true -> {Fa(), Mailbox};
        false ->
            receive Message ->
                case Fr(Message) of
                    {true, Result} -> {Result, Mailbox};
                    _ -> emu_receive(Fr, Timeout, Fa, Start, Mailbox ++ [Message])
                end
            after Timeout - Elapsed -> {Fa(), Mailbox}
            end
    end.

flush_mailbox() -> receive _Any -> flush_mailbox() after 0 -> ok end.
