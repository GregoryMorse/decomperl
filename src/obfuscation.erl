%code:unstick_mod(compile).
%c("src/compile.erl", [debug_info,{outdir, "ebin"},{i,os:getenv("USERPROFILE") ++ "/Desktop/Apps/otp-OTP-23.0/lib/compiler/src"},{i,os:getenv("USERPROFILE") ++ "/Desktop/Apps/otp-OTP-23.0/lib/stdlib/include"}]).
%c("src/obfuscation.erl", [debug_info,{outdir, "ebin"}]).
%c("src/obfuscation.erl", [debug_info,{outdir, "temp"}, 'S']).
%c("ebin/obfuscation", [from_beam,{outdir, "temp"},'S']).
%decomp:disassemble("temp/obfuscation.beamasm", "ebin/obfuscation").
%c("temp/obfuscation", [from_asm,{outdir,"ebin"}]).
%decomp:getabstractsyntax("ebin/obfuscation", "temp/obfuscation.S").

-module(obfuscation).
-export([multi_catch/2,sum_to_n/1,sum_to_n_loop/1,clear_uid_mailbox/2,compile_beamasm/1,s_to_beamasm/1,
  binary_obfuscation/4,merge_sort/1,merge_sort/4,merge_sort_asm/1,
  top_down_merge_sort/1,top_down_merge_split/5,
  test_random_read_write/2, list_random_reads/2, list_random_writes/2,
  tuple_random_reads/2, tuple_random_writes/2, tuple_opt_random_writes/3,
  array_random_reads/2, array_random_writes/2,
  maps_random_reads/2, maps_random_writes/2,
  receive_obfuscation/0]).

multi_catch(A, B) ->
  F = fun(C) -> C end, G = fun(C) -> C + 1 end,
  if A -> catch if B -> F(1); true -> G(1) end;
  true -> catch if B -> G(2); true -> F(2) end end.

disasm_to_s(Fname) ->
  Path = os:getenv("USERPROFILE") ++ "/Desktop/Apps/otp-OTP-23.0",
  %c(Path ++ "/scripts/diffable", [debug_info,{outdir, "ebin"}])
  %first line of file must be deleted as its meant to be a compiled perl script
  {ok, Forms} = epp:parse_file(Path ++ "/scripts/diffable", [{includes,["."]},{source_name, "diffable"},{default_encoding,utf8}]),
  compile:forms(Forms, [binary]).

erl_to_forms(Fname) ->
  {ok, Forms} = epp:parse_file(Fname), compile:forms(Forms).

-record(asm_module, {module,
		     exports,
		     labels,
		     functions=[],
		     attributes=[]}).

preprocess_asm_forms(Forms) ->
    R = #asm_module{},
    R1 = collect_asm(Forms, R),
    {R1#asm_module.module,
     {R1#asm_module.module,
      R1#asm_module.exports,
      R1#asm_module.attributes,
      lists:reverse(R1#asm_module.functions),
      R1#asm_module.labels}}.

collect_asm([{module,M} | Rest], R) ->
    collect_asm(Rest, R#asm_module{module=M});
collect_asm([{exports,M} | Rest], R) ->
    collect_asm(Rest, R#asm_module{exports=M});
collect_asm([{labels,M} | Rest], R) ->
    collect_asm(Rest, R#asm_module{labels=M});
collect_asm([{function,A,B,C} | Rest0], R0) ->
    {Code,Rest} = collect_asm_function(Rest0, []),
    Func = {function,A,B,C,Code},
    R = R0#asm_module{functions=[Func | R0#asm_module.functions]},
    collect_asm(Rest, R);
collect_asm([{attributes, Attr} | Rest], R) ->
    collect_asm(Rest, R#asm_module{attributes=Attr});
collect_asm([], R) -> R.

collect_asm_function([{function,_,_,_}|_]=Is, Acc) ->
    {lists:reverse(Acc),Is};
collect_asm_function([I|Is], Acc) ->
    collect_asm_function(Is, [I|Acc]);
collect_asm_function([], Acc) ->
    {lists:reverse(Acc),[]}.

s_to_beamasm(Fname) ->
  {ok,Forms0} = file:consult(Fname),
  preprocess_asm_forms(Forms0).
compile_beamasm(Fname) ->
  {ok, _, CplBin} = compile:forms(element(2, s_to_beamasm(Fname)), [binary, from_asm, [outdir, "ebin"]]).

get_size() -> U = erlang:unique_integer(), self() ! {U, 4}, receive {U, A} -> A end.
binary_obfuscation(A, B, C, D) ->
  Size = get_size(),
  <<A, B, C, D>>.

sum_to_n(0) -> 0;
sum_to_n(N) -> N + sum_to_n(N - 1).

clear_uid_mailbox(_U, 0) -> ok;
clear_uid_mailbox(U, N) -> receive {U, _Any} -> clear_uid_mailbox(U, N-1) end.

sum_to_n_loop(N) ->
  U = erlang:unique_integer(), S = self(),
  Counter = 0, Sum = 0, S ! {U, N =:= 0},
  fun SumReceive(C, M, Sm) ->
	receive {U, X} ->
		if X -> Sm;
		  true -> P = M - 1, S ! {U, P =:= 0}, SumReceive(Counter+1, P, Sm+M)
		end
	  end
	end(Counter, N, Sum).

receive_obfuscation() ->
  0.
try_catch_obfuscation() ->
  0.

%L = [rand:uniform() || X <- lists:seq(1, 100000)].
%timer:tc(lists, sort, [L]).
%timer:tc(obfuscation, merge_sort, [erlang:list_to_tuple(L)]).
%timer:tc(obfuscation, merge_sort_asm, [erlang:list_to_tuple(L)]).
%lists:sort(L) =:= erlang:tuple_to_list(obfuscation:merge_sort(erlang:list_to_tuple(L))).
beam_put_tuple_element(T, Asm) ->
  {ok, put_tuple_elem, CplBin} = compile:forms(
    {put_tuple_elem,[{do,1},{module_info,0},{module_info,1}],[],[
      {function,do,1,2,[{label,1},{func_info,{atom,put_tuple_elem},
        {atom,do},1},{label,2}|Asm] ++ [return]},
      {function,module_info,0,4,[{label,3},{func_info,{atom,put_tuple_elem},
        {atom,module_info},0},{label,4},{move,{atom,put_tuple_elem},{x,0}},
        {call_ext_only,1,{extfunc,erlang,get_module_info,1}}]},
      {function,module_info,1,6,[{label,5},{func_info,{atom,put_tuple_elem},
        {atom,module_info},1},{label,6},{move,{x,0},{x,1}},
        {move,{atom,put_tuple_elem},{x,0}},
        {call_ext_only,2,{extfunc,erlang,get_module_info,2}}]}],7}, [binary, from_asm]),
  code:load_binary(put_tuple_elem, [], CplBin),
  Result = put_tuple_elem:do(T),
  code:purge(put_tuple_elem),
  code:delete(put_tuple_elem), Result.
do_merge(Arr, I, J, K, N1, N2, Left, Right, Names) ->
  CanLeft = I =< N1, CanRight = J =< N2,
  %SureLeft = not CanRight orelse (CanLeft andalso CanRight andalso element(I, Left) =< element(J, Right)),
  %if CanLeft andalso SureLeft -> do_merge(setelement(K, Arr, element(I, Left)), I + 1, J, K + 1, N1, N2, Left, Right);
  %CanRight -> do_merge(setelement(K, Arr, element(J, Right)), I, J + 1, K + 1, N1, N2, Left, Right);
  SureLeft = not CanRight orelse (CanLeft andalso CanRight andalso hd(Left) =< hd(Right)),
  %if CanLeft andalso SureLeft -> do_merge(setelement(K, Arr, hd(Left)), I + 1, J, K + 1, N1, N2, tl(Left), Right);
  %CanRight -> do_merge(setelement(K, Arr, hd(Right)), I, J + 1, K + 1, N1, N2, Left, tl(Right));
  if CanLeft andalso SureLeft -> FuncName = element(K, Names),
	do_merge(put_tuple_elem:FuncName(Arr, hd(Left)), I + 1, J, K + 1, N1, N2, tl(Left), Right, Names);
  CanRight -> FuncName = element(K, Names),
	do_merge(put_tuple_elem:FuncName(Arr, hd(Right)), I, J + 1, K + 1, N1, N2, Left, tl(Right), Names);
  true -> Arr end.
do_merge_asm(I, J, K, N1, N2, Left, Right) ->
  CanLeft = I =< N1, CanRight = J =< N2,
  SureLeft = not CanRight orelse (CanLeft andalso CanRight andalso hd(Left) =< hd(Right)),
  if CanLeft andalso SureLeft -> [{set_tuple_element,{literal,hd(Left)},{x,0},K-1}|do_merge_asm(I + 1, J, K + 1, N1, N2, tl(Left), Right)];
  CanRight -> [{set_tuple_element,{literal,hd(Right)},{x,0},K-1}|do_merge_asm(I, J + 1, K + 1, N1, N2, Left, tl(Right))];
  true -> [] end.
%make_subtuple(S, L, N) -> subtuple(erlang:make_tuple(N, []), S, L, 1, N).
%subtuple(T, _S, _L, _C, 0) -> T;
%subtuple(T, S, L, C, N) -> subtuple(setelement(C, T, element(L, S)), S, L + 1, C + 1, N - 1).
make_sublist(_S, _L, 0) -> [];
make_sublist(S, L, N) -> [element(L, S)|make_sublist(S, L + 1, N - 1)].
merge(T, L, M, R, Names) ->
  N1 = M - L + 1,
  N2 = R - M,
  %{IL, IR} = lists:split(N1, lists:sublist(erlang:tuple_to_list(T), L, R - L + 1)),
  %Left = erlang:make_tuple(N1, [], lists:zip(lists:seq(1, N1), IL)),
  %Right = erlang:make_tuple(N2, [], lists:zip(lists:seq(1, N2), IR)),
  %Left = make_subtuple(T, L, N1), Right = make_subtuple(T, M, N2),
  Left = make_sublist(T, L, N1), Right = make_sublist(T, M+1, N2),
  do_merge(T, 1, 1, L, N1, N2, Left, Right, Names).
  %beam_put_tuple_element(T, do_merge_asm(1, 1, L, N1, N2, Left, Right)).
gen_put_asm(N) ->
  Names = list_to_tuple([list_to_atom("do" ++ integer_to_list(X)) || X <- lists:seq(1, N)]),
  {ok, put_tuple_elem, CplBin} = compile:forms(
    {put_tuple_elem,[{element(X, Names), 2} || X <- lists:seq(1, N)] ++ [{module_info,0},{module_info,1}],[],
      [{function,element(X, Names),2,X*2,[{label,X*2-1},{func_info,{atom,put_tuple_elem},
        {atom,element(X, Names)},2},{label,X*2},{set_tuple_element,{x,1},{x,0},X-1},return]} || X <- lists:seq(1, N)] ++
      [{function,module_info,0,N*2+2,[{label,N*2+1},{func_info,{atom,put_tuple_elem},
        {atom,module_info},0},{label,N*2+2},{move,{atom,put_tuple_elem},{x,0}},
        {call_ext_only,1,{extfunc,erlang,get_module_info,1}}]},
      {function,module_info,1,N*2+4,[{label,N*2+3},{func_info,{atom,put_tuple_elem},
        {atom,module_info},1},{label,N*2+4},{move,{x,0},{x,1}},
        {move,{atom,put_tuple_elem},{x,0}},
        {call_ext_only,2,{extfunc,erlang,get_module_info,2}}]}],7}, [binary, from_asm]),
  code:load_binary(put_tuple_elem, [], CplBin), Names.
merge_sort_asm(T) -> N = erlang:tuple_size(T), Names = gen_put_asm(N),
  Result = timer:tc(obfuscation, merge_sort, [T, 1, N, Names]),
  code:purge(put_tuple_elem),
  code:delete(put_tuple_elem), Result.
merge_sort(T) -> merge_sort(T, 1, erlang:tuple_size(T), []).
merge_sort(T, L, R, Names) ->
  if L < R ->
    M = (L + (R - 1)) bsr 1,
	merge(merge_sort(merge_sort(T, L, M, Names), M + 1, R, Names), L, M, R, Names);
  true -> T end.
top_down_merge_sort(T) ->
  N = erlang:tuple_size(T), Names = gen_put_asm(N),
  B = setelement(1, T, element(1, T)), %list_to_tuple(tuple_to_list(T)),
  %Result = element(1, top_down_merge_split(B, 1, erlang:tuple_size(T), T, Names)),
  Result = timer:tc(obfuscation, top_down_merge_split, [B, 1, erlang:tuple_size(T), T, Names]),
  code:purge(put_tuple_elem),
  code:delete(put_tuple_elem), Result.
top_down_merge_split(B, Begin, End, A, Names) ->
  if End - Begin < 1 -> {A, B};
  true -> Middle = (End + Begin) bsr 1,
    {BL, AL} = top_down_merge_split(A, Begin, Middle, B, Names),
    {BR, AR} = top_down_merge_split(AL, Middle+1, End, BL, Names),
    {BF, AF} = top_down_merge(BR, Middle, End, AR, Begin, Middle+1, Begin, Names), {AF, BF} end.
top_down_merge(A, Middle, End, B, I, J, K, Names) ->
  if K =< End ->
    if I =< Middle andalso (J > End orelse element(I, A) =< element(J, A)) ->
  	  %top_down_merge(A, Middle, End, setelement(K, B, element(I, A)), I + 1, J, K + 1, Names);
	  FuncName = element(K, Names),
	  top_down_merge(A, Middle, End, put_tuple_elem:FuncName(B, element(I, A)), I + 1, J, K + 1, Names);
    true -> %top_down_merge(A, Middle, End, setelement(K, B, element(J, A)), I, J + 1, K + 1, Names) end;
	  FuncName = element(K, Names),
	  top_down_merge(A, Middle, End, put_tuple_elem:FuncName(B, element(J, A)), I, J + 1, K + 1, Names) end;
  true -> {A, B} end.

test_random_read_write(ArrSize, Size) ->
  L = [rand:uniform() || X <- lists:seq(1, ArrSize)],
  T = list_to_tuple(L),
  Names = gen_put_asm(ArrSize),
  A = array:fix(array:from_list(L)),
  M = maps:from_list(lists:zip(lists:seq(1, ArrSize), L)),
  RR = random_reads(ArrSize, Size),
  RW = random_writes(ArrSize, Size),
  Result = {timer:tc(obfuscation, list_random_reads, [L, RR]),
    timer:tc(obfuscation, list_random_writes, [L, RW]),
    timer:tc(obfuscation, tuple_random_reads, [T, RR]),
    timer:tc(obfuscation, tuple_random_writes, [T, RW]),
	timer:tc(obfuscation, tuple_opt_random_writes, [T, RW, Names]),
    timer:tc(obfuscation, array_random_reads, [A, RR]),
    timer:tc(obfuscation, array_random_writes, [A, RW]),
	timer:tc(obfuscation, maps_random_reads, [M, RR]),
    timer:tc(obfuscation, maps_random_writes, [M, RW])},
  code:purge(put_tuple_elem),
  code:delete(put_tuple_elem), Result.
random_reads(ArrSize, Size) -> [rand:uniform(ArrSize) || X <- lists:seq(1, Size)].
lists_setnth(1, [_|Rest], New) -> [New|Rest];
lists_setnth(I, [E|Rest], New) -> [E|lists_setnth(I-1, Rest, New)].
random_writes(ArrSize, Size) -> [{rand:uniform(ArrSize), rand:uniform()} || X <- lists:seq(1, Size)].
list_random_reads(L, RR) -> [lists:nth(X, L) || X <- RR], true.
list_random_writes(L, RW) -> [lists_setnth(X, L, Y) || {X, Y} <- RW], true.
tuple_random_reads(L, RR) -> [element(X, L) || X <- RR], true.
tuple_random_writes(L, RW) -> [setelement(X, L, Y) || {X, Y} <- RW], true.
array_random_reads(L, RR) -> [array:get(X-1, L) || X <- RR], true.
array_random_writes(L, RW) -> [array:set(X-1, Y, L) || {X, Y} <- RW], true.
maps_random_reads(L, RR) -> [begin #{X := Y} = L, Y end || X <- RR], true.
maps_random_writes(L, RW) -> [L#{X => Y} || {X, Y} <- RW], true.
tuple_opt_random_writes(L, RW, Names) ->
  [put_tuple_elem:X(L, Y) || {X, Y} <- lists:map(fun({X, Y}) -> {element(X, Names), Y} end, RW)], true.
  