%cd("d:/source/repos/refactorerl/branches/morse/master/tool/lib/referl_ast").
%c("emulator.erl", [{outdir, "temp"}]).
%c("calcpi.erl").
%code:purge(calcpi).
%emulator:emulate(calcpi, calc_pi, [1, true, 10]).
%emulator:emulate(undecidable, simple_undecidable, []).
%emulator:emulate(emulator, emulate, [calcpi, calc_pi, [1, true, 10]]).
%emulator:emulate(emulator, emulate, [emulator, emulate, [calcpi, calc_pi, [1, true, 10]]]).
%emulator:emulate(emulator, emulate, [undecidable, simple_undecidable, []]).
%emulator:emulate(emulator, emulate, [emulator, emulate, [undecidable, simple_undecidable, []]]).

%spawn(emulator, testreceive, [1, 2]).
%spawn(emulator, emulate, [emulator, testreceive, [1, 2]]).

%https://github.com/erlang/otp/blob/master/erts/preloaded/src/prim_eval.S
%prim_eval:'receive'(fun((term()) -> nomatch | T), timeout()) -> T

-module(emulator).
-export([pd_emu_receive/3, pd_emu_receive/1, emulate/3, emulate/4, getmem/2]).
-import(semequiv, [has_float/3, get_float/3, has_utf8/1, get_utf8_size/1, get_utf16_size/2, fun_arglist/2,
	get_utf8/1, has_utf16/2, get_utf16/2, has_utf32/2, get_utf32/2, skip_bits/2, get_bits/2, get_integer/4, 'receive'/1, 'receive'/3]).
%-compile([debug_info]).

%% setnth(Index, List, NewElement) -> List.
setnth(1, [_|Rest], New) -> [New|Rest];
setnth(I, [E|Rest], New) -> [E|setnth(I-1, Rest, New)].

%compile:forms({emu,[{select_receive,1},{module_info,0},{module_info,1}],[],[{function,select_receive,1,2,[{label,1},{line,[{location,[],1}]},{func_info,{atom,emu},{atom,select_receive},1},{label,2},remove_message,return]},{function,module_info,0,4,[{label,3},{line,[]},{func_info,{atom,emu},{atom,module_info},0},{label,4},{move,{atom,emu},{x,0}},{line,[]},{call_ext_only,1,{extfunc,erlang,get_module_info,1}}]},{function,module_info,1,6,[{label,5},{line,[]},{func_info,{atom,emu},{atom,module_info},1},{label,6},{move,{x,0},{x,1}},{move,{atom,emu},{x,0}},{line,[]},{call_ext_only,2,{extfunc,erlang,get_module_info,2}}]}],7}, [binary, from_asm]),
%compile:forms({emu,[{select_receive,1}],[],[{function,select_receive,1,2,[{label,1},{line,[{location,[],1}]},{func_info,{atom,emu},{atom,select_receive},1},{label,2},remove_message,return]}],3}, [binary, from_asm]),

pd_emu_receive(Fr) -> Msgs = get(messages),
	{Result, MQ} = emu_receive(Fr, if Msgs =:= undefined -> []; true -> Msgs end),
	put(messages, MQ), Result.
	
pd_emu_receive(Fr, A, Fa) -> Msgs = get(messages),
	{Result, MQ} = emu_receive(Fr, A, Fa, if Msgs =:= undefined -> []; true -> Msgs end),
	put(messages, MQ), Result.

emu_receive_msg(_, _, []) -> false;
emu_receive_msg(Fr, Pre, [H|T]) ->
	Y = Fr(H),
	if is_tuple(Y) andalso element(1, Y) =:= true -> {element(2, Y), Pre ++ T};
		true -> emu_receive_msg(Fr, Pre ++ H, T)
	end.

%fun returns {true, Value} or false depending if it processed in receive
%A is after timeout, Fa is fun for after predicate
emu_receive(Fr, MQ) -> emu_receive(Fr, infinity, [], MQ).
emu_receive(Fr, infinity, _, MQ) ->
	Y = emu_receive_msg(Fr, [], MQ),
	if is_tuple(Y) -> Y;
		true -> emu_receive(Fr, infinity, [], 0, MQ) end;
emu_receive(Fr, A, Fa, MQ) ->
	Start = os:system_time(millisecond),
	Y = emu_receive_msg(Fr, [], MQ),
	if is_tuple(Y) -> Y;
		true -> emu_receive(Fr, A, Fa, Start, MQ) end.

emu_receive(Fr, infinity, _, _, MQ) ->
	receive X ->
		Y = Fr(X),
		if is_tuple(Y) andalso element(1, Y) =:= true -> {element(2, Y), MQ};
			true -> emu_receive(Fr, infinity, [], 0, MQ ++ [X]) end
	end;
emu_receive(Fr, A, Fa, Start, MQ) ->
	Now = os:system_time(millisecond),
	if A =< (Now - Start) -> Fa();
	true ->
		receive X ->
			Y = Fr(X),
			if is_tuple(Y) andalso element(1, Y) =:= true -> {element(2, Y), MQ};
				true -> emu_receive(Fr, A, Fa, Start, MQ ++ [X]) end
		after A - (Now - Start) -> {Fa(), MQ}
		end
	end.
	
%emu_c_flush() -> . %not necessary as is implemented via receive calls
%emu_process_info(Pid) -> .
%emu_process_info(Pid, message_queue_len) -> .
%emu_process_info(Pid, messages) -> .

choose_dest(Val, List, Def) ->
	erlang:display({Val, List, Def}),
	if
		List =:= [] -> Def;
		hd(List) =:= Val orelse %for tuple sizes
		element(2, hd(List)) =:= Val -> hd(tl(List)); %should use the getmem type wrapper
		true -> choose_dest(Val, tl(tl(List)), Def)
	end
.

get_binary_puts(State, Bin, Items, Count) ->
	if
		Items =:= 0 -> {Bin, Count};
		true -> Val = hd(element(1, State)),
		  erlang:display({Val, Items}),
		  if element(1, Val) =:= bs_put_string -> X = list_to_binary(element(2, element(3, Val))), B = <<Bin/bitstring, X/binary>>, %B = make_binary_new(Bin, X, 0, binary, element(2, element(3, Val)), 0),
		  	get_binary_puts(setelement(1, State, tl(element(1, State))), B, Items - element(2, Val) * 8, Count + 1);
			element(1, Val) =:= bs_put_utf8 ->
				X = getmem(State, element(4, Val)), Size = byte_size(BB = <<X/utf8>>) * 8, B = <<Bin/bitstring, BB/binary>>, %B = make_binary_new(Bin, X, 0, utf8, element(2, element(3, Val)), 0),
			  get_binary_puts(setelement(1, State, tl(element(1, State))), B, Items - Size, Count +  1);
			element(1, Val) =:= bs_put_utf16 ->
				X = getmem(State, element(4, Val)), Size = byte_size(BB = case (element(2, element(3, Val)) band 2) =:= 2 orelse (element(2, element(3, Val)) band 16) =:= 16 andalso erlang:system_info(endian) =:= little of true -> <<X/utf16-little>>; _ -> <<X/utf16>> end) * 8, B = <<Bin/bitstring, BB/binary>>, %B = make_binary_new(Bin, X, 0, utf16, element(2, element(3, Val)), 0),
			  get_binary_puts(setelement(1, State, tl(element(1, State))), B, Items - Size, Count +  1);
			element(1, Val) =:= bs_put_utf32 -> X = getmem(State, element(4, Val)), BB = case (element(2, element(3, Val)) band 2) =:= 2 orelse (element(2, element(3, Val)) band 16) =:= 16 andalso erlang:system_info(endian) =:= little of true -> <<X/utf32-little>>; _ -> <<X/utf32>> end, B = <<Bin/bitstring, BB/binary>>, %B = make_binary_new(Bin, X, 0, utf32, element(2, element(3, Val)), 0),
			  get_binary_puts(setelement(1, State, tl(element(1, State))), B, Items - 8 * 4, Count +  1);
		  true -> X = getmem(State, element(6, Val)),
		  get_binary_puts(setelement(1, State, tl(element(1, State))), case element(1, Val) of
				bs_put_integer -> case (element(2, element(5, Val)) band 2) =:= 2 orelse (element(2, element(5, Val)) band 16) =:= 16 andalso erlang:system_info(endian) =:= little of true -> <<Bin/bitstring, X:(getmem(State, element(3, Val)) * element(4, Val))/integer-little>>; _ -> <<Bin/bitstring, X:(getmem(State, element(3, Val)) * element(4, Val))/integer>> end; %make_binary_new(Bin, X, getmem(State, element(3, Val)), integer, element(2, element(5, Val)), element(4, Val));
				bs_put_binary -> case element(3, Val) of {atom, all} -> <<Bin/bitstring, X/bitstring>>; _ -> <<Bin/bitstring, X:(getmem(State, element(3, Val)) * element(4, Val))/bitstring>> end; %make_binary_new(Bin, X, case element(3, Val) of {atom, all} -> 0; _ -> getmem(State, element(3, Val)) end, if is_binary(X) -> binary; true -> bitstring end, element(2, element(5, Val)), 0);
				bs_put_float -> case (element(2, element(5, Val)) band 2) =:= 2 orelse (element(2, element(5, Val)) band 16) =:= 16 andalso erlang:system_info(endian) =:= little of true -> <<Bin/bitstring, X:(getmem(State, element(3, Val)) * element(4, Val))/float-little>>; _ -> <<Bin/bitstring, X:(getmem(State, element(3, Val)) * element(4, Val))/float>> end %make_binary_new(Bin, X, getmem(State, element(3, Val)), float, element(2, element(5, Val)), element(4, Val))
				end, Items - case element(3, Val) of {atom, all} -> bit_size(getmem(State, element(6, Val))); _ -> getmem(State, element(3, Val)) * element(4, Val) end, Count +  1)
			end
	end
.

getmem(State, Where) ->
	if
		Where =:= nil -> [];
		true -> case element(1, Where) of
			integer -> element(2, Where);
			atom -> element(2, Where);
			float -> element(2, Where);
			list -> element(2, Where);
			literal -> element(2, Where);
			x -> lists:nth(element(2, Where) + 1, element(2, State));
			y -> lists:nth(element(2, Where) + 1, element(3, State));
			fr -> lists:nth(element(2, Where) + 1, element(4, State));
			f -> lists:dropwhile(fun(Elem) -> is_atom(Elem) orelse element(1, Elem) =/= label orelse element(2, Elem) =/= element(2, Where) end, element(1, State))
		end
	end
.

setmem(State, Where, Val) ->
	case element(1, Where) of
		x -> setelement(2, State, setnth(element(2, Where) + 1, element(2, State), Val));
		y -> setelement(3, State, setnth(element(2, Where) + 1, element(3, State), Val));
		fr -> setelement(4, State, setnth(element(2, Where) + 1, element(4, State), Val))
	end
.

get_tuple_puts(State, Count) ->
	if
		Count =:= 0 -> [];
		true -> Val = hd(element(1, State)),
		  erlang:display(Val),
			case element(1, Val) of
				put -> [getmem(State, element(2, Val))|get_tuple_puts(setelement(1, State, tl(element(1, State))), Count - 1)]
			end
	end
.

%make_binary_new(Init, Value, Units, Type, Flags, Size) ->
%	Str = "<<" ++ if Init =:= [] -> ""; true -> "Init\/bitstring, " end
%	 ++ "Value" ++ if Units =/= 0 -> ":" ++ integer_to_list(Units); true -> "" end ++ if (is_binary(Value) orelse is_bitstring(Value) orelse Units =/= 0 orelse Units =/= 1) andalso Type =:= bitstring -> ""; true -> "\/" ++ atom_to_list(Type) end ++ lists:append(lists:map(fun(A) -> [$-|atom_to_list(A)] end, get_binary_flags(Flags))) ++ if Size =/= 0 andalso Size =/= 1 -> "-unit:" ++ integer_to_list(Size); true -> "" end ++ ">>.",
%	%erlang:display(Str),
%	{ok, Tokens, _} = erl_scan:string(Str),
%	FirstBind = erl_eval:add_binding('Value', Value, erl_eval:new_bindings()),
%	Binding = if Init =:= [] -> FirstBind; true -> erl_eval:add_binding('Init', Init, FirstBind) end,
%	{ok, Parsed} = erl_parse:parse_exprs(Tokens), {value, Result, _} = erl_eval:exprs(Parsed, Binding, none), Result
%.

%make_binary(Value, Units, Type, Flags, Size, IsTail) ->
%	Str = "<<" ++ if IsTail -> "_"; true -> "Val" end ++ if Units =/= 0 -> ":" ++ integer_to_list(Units); true -> "" end ++ if Type =:= binary andalso Units =/= 0 -> ""; true -> "\/" ++ atom_to_list(Type) ++ lists:append(lists:map(fun(A) -> [$-|atom_to_list(A)] end, get_binary_flags(Flags))) ++ if Size =/= 0 andalso Size =/= 1 -> "-unit:" ++ integer_to_list(Size); true -> "" end end ++
%		if Type =:= binary andalso Size =:= 0 -> ""; true -> ", " ++ if IsTail -> "Val"; true -> "Rest" end ++ "\/bitstring" end ++ ">> = Value, " ++ if IsTail -> "Val"; true -> "{Val, " ++ if Type =:= binary andalso Size =:= 0 -> "<<>>"; true -> "Rest" end ++ "}" end ++ ".",
%	%erlang:display(Str),
%	{ok, Tokens, _} = erl_scan:string(Str),
%	Binding = erl_eval:add_binding('Value', Value, erl_eval:new_bindings()),
%	{ok, Parsed} = erl_parse:parse_exprs(Tokens), {value, Result, _} = erl_eval:exprs(Parsed, Binding, none), Result
%.

%https://github.com/erlang/otp/blob/maint/erts/emulator/beam/beam_emu.c
%remove error, raise and apply to emulation calls...
exec_step(State) ->
	{RemainingCode, XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode} = State,
	Val = hd(RemainingCode),
	erlang:display(Val),
	case Val of
		return -> {[], XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode};
		on_load -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
		fclearerror -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
		remove_message -> {true, exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode})};
		send -> exec_step({tl(RemainingCode), [hd(XVars) ! hd(tl(XVars))|tl(XVars)], YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
		bs_init_writable -> _Size = getmem(State, {x, 0}), exec_step({tl(RemainingCode), [<<>>|tl(XVars)], YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
		timeout -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
		if_end -> emulate(erlang, error, [if_clause], State);
		_ ->
			case element(1, Val) of
			label -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			line -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, [element(2, Val)|tl(LineNo)], LastErrClass, StackTrace, OrigCode});
			func_info -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			fcheckerror -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			test_heap -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			badmatch -> emulate(erlang, error, [{badmatch,getmem(State, element(2, Val))}], State);
			case_end -> emulate(erlang, error, [{case_clause,getmem(State, element(2, Val))}], State);
			'catch' -> try exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode}) of NextState -> exec_step(setelement(1, NextState, tl(element(1, NextState)))) catch Class:Reason -> exec_step(setelement(1, setmem(setelement(6, State, [Class|element(6, State)]), {x, 0}, if Class =:= error orelse Class =:= exit -> {'EXIT', if Class =:= exit -> Reason; true -> {Reason, getmem(emulate(erlang, get_stacktrace, [], State), {x, 0})} end}; true -> Reason end), getmem(State, element(3, Val)))) end;
			catch_end -> State;
			'try' -> try exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode}) of NextState -> exec_step(setelement(1, NextState, tl(element(1, NextState)))) catch Class:Reason -> exec_step(setelement(1, setmem(setmem(setmem(setelement(6, State, [Class|element(6, State)]), {x, 0}, Class), {x, 1}, Reason), {x, 2}, getmem(emulate(erlang, get_stacktrace, [], State), {x, 0})), getmem(State, element(3, Val)))) end;
			try_end -> setelement(State, 6, tl(LastErrClass));
		    try_case -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			try_case_end -> emulate(erlang, error, [{try_clause,getmem(State, element(2, Val))}], State);
			raise -> emulate(erlang, raise, [hd(LastErrClass), getmem(State, lists:nth(2, element(3, Val))), getmem(State, lists:nth(1, element(3, Val)))], State); % how to determine throw, error, exit and what to assign argument when its assigned at catch handler anyway...like a hidden restore to {x, 0} of this value...
			loop_rec -> exec_step({getmem(State, element(2, Val)), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			wait -> pd_emu_receive(fun (ChkMsg) -> InstList = getmem({OrigCode}, element(2, Val)), exec_step({tl(tl(InstList)), [ChkMsg|tl(XVars)], YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode}) end);
			wait_timeout -> pd_emu_receive(fun (ChkMsg) -> _InstList = getmem({OrigCode}, element(2, Val)), exec_step({getmem({OrigCode}, element(2, Val)), [ChkMsg|tl(XVars)], YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode}) end, getmem(State, element(3, Val)), fun () -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode}) end);
			loop_rec_end -> false;
			recv_mark -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
			recv_set -> exec_step({tl(RemainingCode), XVars, YVars, FrVars, LineNo, LastErrClass, StackTrace, OrigCode});

			select_val -> InstList = getmem(State, choose_dest(getmem(State, element(2, Val)), getmem(State, element(4, Val)), element(3, Val))), if InstList =:= [] -> emulate(erlang, error, [function_clause], State); true -> exec_step(setelement(1, State, InstList)) end;
			select_tuple_arity -> InstList = getmem(State, choose_dest(tuple_size(getmem(State, element(2, Val))), getmem(State, element(4, Val)), element(3, Val))), if InstList =:= [] -> emulate(erlang, error, [function_clause], State); true -> exec_step(setelement(1, State, InstList)) end;
			test -> case case element(2, Val) of
					is_lt -> NewState = State, getmem(State, hd(element(4, Val))) < getmem(State, lists:nth(2, element(4, Val)));
					is_ge -> NewState = State, getmem(State, hd(element(4, Val))) >= getmem(State, lists:nth(2, element(4, Val)));
					is_eq -> NewState = State, getmem(State, hd(element(4, Val))) == getmem(State, lists:nth(2, element(4, Val)));
					is_ne -> NewState = State, getmem(State, hd(element(4, Val))) /= getmem(State, lists:nth(2, element(4, Val)));
					is_eq_exact -> NewState = State, getmem(State, hd(element(4, Val))) =:= getmem(State, lists:nth(2, element(4, Val)));
					is_ne_exact -> NewState = State, getmem(State, hd(element(4, Val))) =/= getmem(State, lists:nth(2, element(4, Val)));
					is_integer -> NewState = State, is_integer(getmem(State, hd(element(4, Val))));
					is_float -> NewState = State, is_float(getmem(State, hd(element(4, Val))));
					is_number -> NewState = State, is_number(getmem(State, hd(element(4, Val))));
					is_atom -> NewState = State, is_atom(getmem(State, hd(element(4, Val))));
					is_pid -> NewState = State, is_pid(getmem(State, hd(element(4, Val))));
					is_reference -> NewState = State, is_reference(getmem(State, hd(element(4, Val))));
					is_port -> NewState = State, is_port(getmem(State, hd(element(4, Val))));
					is_nil -> NewState = State, getmem(State, hd(element(4, Val))) =:= [];
					is_boolean -> NewState = State, is_boolean(getmem(State, hd(element(4, Val))));
					is_binary -> NewState = State, is_binary(getmem(State, hd(element(4, Val))));
					is_bitstr -> NewState = State, is_bitstring(getmem(State, hd(element(4, Val))));
					is_list -> NewState = State, is_list(getmem(State, hd(element(4, Val))));
					is_nonempty_list -> NewState = State, is_list(getmem(State, hd(element(4, Val)))) andalso getmem(State, hd(element(4, Val))) =/= [];
					is_tuple -> NewState = State, is_tuple(getmem(State, hd(element(4, Val))));
					is_function -> NewState = State, is_function(getmem(State, hd(element(4, Val))));
					is_function2 -> NewState = State, is_function(getmem(State, hd(element(4, Val))), getmem(State, lists:nth(2, element(4, Val))));
					is_map -> NewState = State, is_map(getmem(State, hd(element(4, Val))));
					has_map_fields -> NewState = State, lists:foldl(fun(El, Acc) -> Next = maps:is_key(getmem(State, El), getmem(State, element(4, Val))), if Acc =:= [] -> Next; true -> Next andalso Acc end end, [], getmem(State, element(5, Val)));
					is_tagged_tuple -> NewState = State, is_tuple(getmem(State, hd(element(4, Val)))) andalso tuple_size(getmem(State, hd(element(4, Val)))) =:= lists:nth(2, element(4, Val)) andalso element(1, getmem(State, hd(element(4, Val)))) =:= element(2, lists:nth(3, element(4, Val)));
					test_arity -> NewState = State, tuple_size(getmem(State, hd(element(4, Val)))) =:= lists:nth(2, element(4, Val));
					bs_test_unit -> NewState = State, bit_size(element(1, getmem(State, hd(element(4, Val))))) rem lists:nth(2, element(4, Val)) =:= 0;
					bs_test_tail2 -> NewState = State, bit_size(element(1, getmem(State, hd(element(4, Val))))) =:= lists:nth(2, element(4, Val));
					bs_start_match2 -> X = getmem(State, hd(element(4, Val))), Cond = case is_tuple(X) of true -> is_bitstring(element(1, X)) andalso is_bitstring(element(2, X)); _ -> is_bitstring(X) end,
						if Cond -> NewState = setmem(State, lists:nth(4, element(4, Val)), case is_tuple(getmem(State, hd(element(4, Val)))) of true -> getmem(State, hd(element(4, Val))); _ -> {getmem(State, hd(element(4, Val))),getmem(State, hd(element(4, Val)))} end); true -> NewState = State end, Cond;
					bs_skip_bits2 -> {Y, Z} = getmem(State, hd(element(4, Val))), Cond = case getmem(State, lists:nth(2, element(4, Val))) =:= all of true -> (bit_size(Y) rem lists:nth(3, element(4, Val))) =:= 0;
							_ -> getmem(State, lists:nth(2, element(4, Val))) >= 0 andalso bit_size(Y) >= getmem(State, lists:nth(2, element(4, Val))) * lists:nth(3, element(4, Val)) end,%{atom, all} needs test case
						if Cond -> X = case getmem(State, lists:nth(2, element(4, Val))) =:= all of true -> <<>>; _ -> skip_bits(Y, getmem(State, lists:nth(2, element(4, Val))) * lists:nth(3, element(4, Val))) end,%make_binary(Y, getmem(State, lists:nth(2, element(4, Val))) * lists:nth(3, element(4, Val)), bitstring, 0, 0, true),
						NewState = setmem(State, hd(element(4, Val)), {X, Z}); true -> NewState = State end, Cond;
					bs_skip_utf8 -> {Y, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf8(Y),
						if Cond -> X = skip_bits(Y, get_utf8_size(Y) * 8),%make_binary(Y, 0, utf8, element(2, lists:nth(3, element(4, Val))), 0, true),
						NewState = setmem(State, hd(element(4, Val)), {X, Z}); true -> NewState = State end, Cond;
					bs_skip_utf16 -> {Y, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf16(Y, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)),
						if Cond -> X = skip_bits(Y, get_utf16_size(Y, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)) * 8),%make_binary(Y, 0, utf16, element(2, lists:nth(3, element(4, Val))), 0, true),
						NewState = setmem(State, hd(element(4, Val)), {X, Z}); true -> NewState = State end, Cond;
					bs_skip_utf32 -> {Y, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf32(Y, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)),
						if Cond -> X = skip_bits(Y, 4 * 8),%make_binary(Y, 0, utf32, element(2, lists:nth(3, element(4, Val))), 0, true),
						NewState = setmem(State, hd(element(4, Val)), {X, Z}); true -> NewState = State end, Cond;
					bs_get_integer2 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = bit_size(Q) >= lists:nth(4, element(4, Val)) * getmem(State, lists:nth(3, element(4, Val))),
						if Cond -> X = get_integer(Q, lists:nth(4, element(4, Val)) * element(2, lists:nth(3, element(4, Val))), (element(2, lists:nth(5, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian), (element(2, lists:nth(5, element(4, Val))) band 4) =:= 4), Y = skip_bits(Q, lists:nth(4, element(4, Val)) * element(2, lists:nth(3, element(4, Val)))), %{X, Y} = make_binary(Q, lists:nth(4, element(4, Val)), integer, element(2, lists:nth(5, element(4, Val))), getmem(State, lists:nth(3, element(4, Val))), false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(6, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_get_float2 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = has_float(Q, lists:nth(4, element(4, Val)) * getmem(State, lists:nth(3, element(4, Val))), (element(2, lists:nth(5, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)),
						if Cond -> X = get_float(Q, lists:nth(4, element(4, Val)) * getmem(State, lists:nth(3, element(4, Val))), (element(2, lists:nth(5, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)), Y = skip_bits(Q, lists:nth(4, element(4, Val)) * getmem(State, lists:nth(3, element(4, Val)))),%{X, Y} = make_binary(Q, lists:nth(4, element(4, Val)), float, element(2, lists:nth(5, element(4, Val))), getmem(State, lists:nth(3, element(4, Val))), false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(6, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_get_utf8 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf8(Q),
						if Cond -> X = get_utf8(Q), Y = skip_bits(Q, get_utf8_size(Q) * 8),%{X, Y} = make_binary(Q, 0, utf8, element(2, lists:nth(3, element(4, Val))), 0, false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(4, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_get_utf16 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf16(Q, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)),
						if Cond -> X = get_utf16(Q, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)), Y = skip_bits(Q, get_utf16_size(Q, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)) * 8),%{X, Y} = make_binary(Q, 0, utf16, element(2, lists:nth(3, element(4, Val))), 0, false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(4, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_get_utf32 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = has_utf32(Q, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)),
						if Cond -> X = get_utf32(Q, (element(2, lists:nth(3, element(4, Val))) band 2) =:= 2 orelse (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 andalso little =:= erlang:system_info(endian)), Y = skip_bits(Q, 4 * 8),%{X, Y} = make_binary(Q, 0, utf32, element(2, lists:nth(3, element(4, Val))), 0, false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(4, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_get_binary2 -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = case getmem(State, lists:nth(3, element(4, Val))) =:= all of true -> (bit_size(Q) rem lists:nth(4, element(4, Val))) =:= 0;
							_ -> getmem(State, lists:nth(3, element(4, Val))) >= 0 andalso bit_size(Q) >= getmem(State, lists:nth(3, element(4, Val))) * lists:nth(4, element(4, Val)) end, 
						if Cond -> X = case getmem(State, lists:nth(3, element(4, Val))) =:= all of true -> Q; _ -> get_bits(Q, getmem(State, lists:nth(3, element(4, Val))) * lists:nth(4, element(4, Val))) end, Y = case getmem(State, lists:nth(3, element(4, Val))) =:= all of true -> <<>>; _ -> skip_bits(Q, getmem(State, lists:nth(3, element(4, Val))) * lists:nth(4, element(4, Val))) end, %{X, Y} = make_binary(Q, case getmem(State, lists:nth(3, element(4, Val))) =:= all of true -> 0; _ -> getmem(State, lists:nth(3, element(4, Val))) end, binary, element(2, lists:nth(5, element(4, Val))), case getmem(State, lists:nth(3, element(4, Val))) =:= all of true -> 0; _ -> lists:nth(4, element(4, Val)) end, false),
						NewState = setmem(setmem(State, hd(element(4, Val)), {Y, Z}), lists:nth(6, element(4, Val)), X); true -> NewState = State end, Cond;
					bs_match_string -> {Q, Z} = getmem(State, hd(element(4, Val))), Cond = bit_size(Q) >= lists:nth(2, element(4, Val)) andalso get_bits(Q, lists:nth(2, element(4, Val))) =:= lists:nth(3, element(4, Val)),
						if Cond -> Y = skip_bits(Q, lists:nth(2, element(4, Val))),%{X, Y} = make_binary(Q, lists:nth(2, element(4, Val)), bitstring, 0, bit_size(lists:nth(3, element(4, Val))) div lists:nth(2, element(4, Val)), false),
						NewState = setmem(State, hd(element(4, Val)), {Y, Z}); true -> NewState = State end, Cond
					end of
				true -> exec_step(setelement(1, NewState, tl(RemainingCode)));
				_ -> InstList = getmem(State, element(3, Val)), if InstList =:= [] -> emulate(erlang, error, [function_clause], State); true -> exec_step(setelement(1, NewState, InstList)) end
			  end;
			move -> exec_step(setelement(1, setmem(State, element(3, Val), getmem(State, element(2, Val))), tl(RemainingCode)));
			fmove -> exec_step(setelement(1, setmem(State, element(3, Val), getmem(State, element(2, Val))), tl(RemainingCode)));
			fconv -> exec_step(setelement(1, setmem(State, element(3, Val), getmem(State, element(2, Val))), tl(RemainingCode)));
			get_tuple_element -> exec_step(setelement(1, setmem(State, element(4, Val), element(element(3, Val) + 1, getmem(State, element(2, Val)))), tl(RemainingCode)));
			set_tuple_element -> exec_step(setelement(1, setmem(State, element(3, Val), setelement(element(4, Val) + 1, getmem(State, element(3, Val)), getmem(State, element(2, Val)))), tl(RemainingCode)));
			put_tuple -> exec_step(setelement(1, setmem(State, element(3, Val), list_to_tuple(get_tuple_puts(setelement(1, State, tl(RemainingCode)), element(2, Val)))), lists:sublist(element(1, State), 2 + element(2, Val), length(RemainingCode))));
			get_list -> exec_step(setelement(1, setmem(setmem(State, element(3, Val), hd(getmem(State, element(2, Val)))), element(4, Val), tl(getmem(State, element(2, Val)))), tl(RemainingCode)));
			put_list -> exec_step(setelement(1, setmem(State, element(4, Val), [getmem(State, element(2, Val))|getmem(State, element(3, Val))]), tl(RemainingCode)));
			bs_init2 -> {Bin, InstCount} = get_binary_puts(setelement(1, State, tl(RemainingCode)), <<>>, if is_tuple(element(3, Val)) -> getmem(State, element(3, Val)); true -> element(3, Val) end * 8, 0),
					exec_step(setelement(1, setmem(State, element(7, Val), Bin), lists:sublist(element(1, State), 2 + InstCount, length(RemainingCode))));
			bs_init_bits -> {Bin, InstCount} = get_binary_puts(setelement(1, State, tl(RemainingCode)), <<>>, if is_tuple(element(3, Val)) -> getmem(State, element(3, Val)); true -> element(3, Val) end, 0),
					exec_step(setelement(1, setmem(State, element(7, Val), Bin), lists:sublist(element(1, State), 2 + InstCount, length(RemainingCode))));
			bs_append -> {Bin, InstCount} = get_binary_puts(setelement(1, State, tl(RemainingCode)), getmem(State, element(7, Val)), getmem(State, element(3, Val)), 0),
					exec_step(setelement(1, setmem(State, element(9, Val), Bin), lists:sublist(element(1, State), 2 + InstCount, length(RemainingCode))));
			bs_private_append -> {Bin, InstCount} = get_binary_puts(setelement(1, State, tl(RemainingCode)), getmem(State, element(5, Val)), getmem(State, element(3, Val)), 0),
					exec_step(setelement(1, setmem(State, element(7, Val), Bin), lists:sublist(element(1, State), 2 + InstCount, length(RemainingCode))));
			bs_add -> exec_step(setelement(1, setmem(State, element(4, Val), getmem(State, hd(element(3, Val))) + getmem(State, lists:nth(2, element(3, Val))) * lists:nth(3, element(3, Val))), tl(RemainingCode)));
			bs_utf8_size -> X = getmem(State, element(3, Val)), exec_step(setelement(1, setmem(State, element(4, Val), if X < 16#80 -> 1; X < 16#800 -> 2; X < 16#10000 -> 3; true -> 4 end), tl(RemainingCode)));
			bs_utf16_size -> X = getmem(State, element(3, Val)), exec_step(setelement(1, setmem(State, element(4, Val), if X >= 16#10000 -> 4; true -> 2 end), tl(RemainingCode)));
			bs_save2 -> {X, _} = getmem(State, element(2, Val)), exec_step(setelement(1, setmem(State, element(2, Val), {X, case getmem(State, element(3, Val)) of start -> X; _ -> X end}), tl(RemainingCode)));
			bs_restore2 -> {_, X} = getmem(State, element(2, Val)), exec_step(setelement(1, setmem(State, element(2, Val), {case getmem(State, element(3, Val)) of start -> X; _ -> X end, X}), tl(RemainingCode)));
			bs_context_to_binary -> exec_step(setelement(1, case getmem(State, element(2, Val)) of {X, _} -> setmem(State, element(2, Val), X); _ -> State end, tl(RemainingCode)));
			get_map_elements -> exec_step(setelement(1, element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmem(State, El)]}; true -> {setmem(Acc, El, maps:get(hd(Next),getmem(State, element(3, Val)))), []} end end, {State, []}, getmem(State, element(4, Val)))), tl(RemainingCode)));
			put_map_exact -> exec_step(setelement(1, element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmem(State, El)]}; true -> {setmem(Acc, element(4, Val), maps:update(hd(Next),getmem(Acc, El),getmem(Acc, element(4, Val)))), []} end end, {setmem(State, element(4, Val), getmem(State, element(3, Val))), []}, getmem(State, element(6, Val)))), tl(RemainingCode)));
			put_map_assoc -> exec_step(setelement(1, element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmem(State, El)]}; true -> {setmem(Acc, element(4, Val), maps:put(hd(Next),getmem(Acc, El),getmem(Acc, element(4, Val)))), []} end end, {setmem(State, element(4, Val), getmem(State, element(3, Val))), []}, getmem(State, element(6, Val)))), tl(RemainingCode)));
			
			arithfbif -> case element(2, Val) of
				fadd -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) + getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				fsub -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) - getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				fmul -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) * getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				fdiv -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) / getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				fnegate -> exec_step(setelement(1, setmem(State, element(5, Val), -(getmem(State, hd(element(4, Val))))), tl(RemainingCode)))
			end;
			bif -> case element(2, Val) of
				'==' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) == getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'<' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) < getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'=<' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) =< getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'>' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) > getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'>=' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) >= getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'=:=' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) =:= getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'/=' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) /= getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'=/=' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) =/= getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'not' -> exec_step(setelement(1, setmem(State, element(5, Val), not(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'and' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) and getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'or' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) or getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'xor' -> exec_step(setelement(1, setmem(State, element(5, Val), getmem(State, hd(element(4, Val))) xor getmem(State, lists:nth(2, element(4, Val)))), tl(RemainingCode)));
				'is_integer' -> exec_step(setelement(1, setmem(State, element(5, Val), is_integer(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_float' -> exec_step(setelement(1, setmem(State, element(5, Val), is_float(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_number' -> exec_step(setelement(1, setmem(State, element(5, Val), is_number(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_pid' -> exec_step(setelement(1, setmem(State, element(5, Val), is_pid(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_reference' -> exec_step(setelement(1, setmem(State, element(5, Val), is_reference(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_port' -> exec_step(setelement(1, setmem(State, element(5, Val), is_port(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_boolean' -> exec_step(setelement(1, setmem(State, element(5, Val), is_boolean(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_binary' -> exec_step(setelement(1, setmem(State, element(5, Val), is_binary(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_bitstring' -> exec_step(setelement(1, setmem(State, element(5, Val), is_bitstring(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_list' -> exec_step(setelement(1, setmem(State, element(5, Val), is_list(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_atom' -> exec_step(setelement(1, setmem(State, element(5, Val), is_atom(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_tuple' -> exec_step(setelement(1, setmem(State, element(5, Val), is_tuple(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_function' -> exec_step(setelement(1, setmem(State, element(5, Val), if length(element(4, Val)) =:= 2 -> is_function(getmem(State, hd(element(4, Val))), getmem(State, lists:nth(2, element(4, Val)))); true -> is_function(getmem(State, hd(element(4, Val)))) end), tl(RemainingCode)));
				'is_map' -> exec_step(setelement(1, setmem(State, element(5, Val), is_map(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'is_record' -> exec_step(setelement(1, setmem(State, element(5, Val), if length(element(4, Val)) =:= 2 -> is_record(getmem(State, hd(element(4, Val))), getmem(State, lists:nth(2, element(4, Val)))); true -> is_record(getmem(State, hd(element(4, Val))), getmem(State, lists:nth(2, element(4, Val))), getmem(State, lists:nth(3, element(4, Val)))) end), tl(RemainingCode)));
				'get' -> exec_step(setelement(1, setmem(State, element(5, Val), get(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				'node' -> exec_step(setelement(1, setmem(State, element(5, Val), node()), tl(RemainingCode)));
				'tuple_size' -> exec_step(setelement(1, setmem(State, element(5, Val), tuple_size(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				element -> exec_step(setelement(1, setmem(State, element(5, Val), element(getmem(State, hd(element(4, Val))), getmem(State, lists:nth(2, element(4, Val))))), tl(RemainingCode)));
				hd -> exec_step(setelement(1, setmem(State, element(5, Val), hd(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				tl -> exec_step(setelement(1, setmem(State, element(5, Val), tl(getmem(State, hd(element(4, Val))))), tl(RemainingCode)));
				self -> exec_step(setelement(1, setmem(State, element(5, Val), self()), tl(RemainingCode)))
			end;
			gc_bif -> case element(2, Val) of
				'+' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) + if length(element(5, Val)) =:= 1 -> 0; true -> getmem(State, lists:nth(2, element(5, Val))) end), tl(RemainingCode)));
				'-' -> exec_step(setelement(1, setmem(State, element(6, Val), if length(element(5, Val)) =:= 1 -> -getmem(State, hd(element(5, Val))); true -> getmem(State, hd(element(5, Val))) - getmem(State, lists:nth(2, element(5, Val))) end), tl(RemainingCode)));
				'*' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) * getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'/' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) / getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				length -> exec_step(setelement(1, setmem(State, element(6, Val), length(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				'size' -> exec_step(setelement(1, setmem(State, element(6, Val), size(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				'map_size' -> exec_step(setelement(1, setmem(State, element(6, Val), map_size(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				'bit_size' -> exec_step(setelement(1, setmem(State, element(6, Val), bit_size(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				'byte_size' -> exec_step(setelement(1, setmem(State, element(6, Val), byte_size(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				abs -> exec_step(setelement(1, setmem(State, element(6, Val), abs(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				trunc -> exec_step(setelement(1, setmem(State, element(6, Val), trunc(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				round -> exec_step(setelement(1, setmem(State, element(6, Val), round(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				float -> exec_step(setelement(1, setmem(State, element(6, Val), float(getmem(State, hd(element(5, Val))))), tl(RemainingCode)));
				binary_part -> exec_step(setelement(1, setmem(State, element(6, Val), if length(element(5, Val)) =:= 3 -> binary_part(getmem(State, hd(element(5, Val))), getmem(State, lists:nth(2, element(5, Val))), getmem(State, lists:nth(3, element(5, Val)))); true -> binary_part(getmem(State, hd(element(5, Val))), getmem(State, lists:nth(2, element(5, Val)))) end), tl(RemainingCode)));
				'div' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) div getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'rem' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) rem getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'band' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) band getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'bor' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) bor getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'bxor' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) bxor getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'bsl' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) bsl getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'bsr' -> exec_step(setelement(1, setmem(State, element(6, Val), getmem(State, hd(element(5, Val))) bsr getmem(State, lists:nth(2, element(5, Val)))), tl(RemainingCode)));
				'bnot' -> exec_step(setelement(1, setmem(State, element(6, Val), bnot(getmem(State, hd(element(5, Val))))), tl(RemainingCode)))
			end;

			init -> exec_step(setelement(1, setmem(State, element(2, Val), []), tl(RemainingCode)));
			trim -> exec_step(setelement(1, setelement(3, State, lists:sublist(element(3, State), element(2, Val) + 1, length(element(3, State)))), tl(RemainingCode)));
			allocate_zero -> exec_step(setelement(1, setelement(3, State, lists:duplicate(element(2, Val), []) ++ element(3, State)), tl(RemainingCode)));
			allocate_heap -> exec_step(setelement(1, setelement(3, State, lists:duplicate(element(2, Val), undefined) ++ element(3, State)), tl(RemainingCode)));
			allocate_heap_zero -> exec_step(setelement(1, setelement(3, State, lists:duplicate(element(2, Val), []) ++ element(3, State)), tl(RemainingCode)));
			allocate -> exec_step(setelement(1, setelement(3, State, lists:duplicate(element(2, Val), undefined) ++ element(3, State)), tl(RemainingCode)));
			deallocate -> exec_step(setelement(1, setelement(3, State, lists:sublist(element(3, State), element(2, Val) + 1, length(element(3, State)))), tl(RemainingCode)));

			jump -> InstList = getmem(State, element(2, Val)), if InstList =:= [] -> emulate(erlang, error, [function_clause], State); true -> exec_step(setelement(1, State, InstList)) end;
			apply -> exec_step(setelement(1, emulate(getmem(State, {x, element(2, Val)}), getmem(State, {x, element(2, Val) + 1}), lists:sublist(element(2, State), element(2, Val)), State), tl(RemainingCode)));
			apply_last -> emulate(getmem(State, {x, element(2, Val)}), getmem(State, {x, element(2, Val) + 1}), lists:sublist(element(2, State), element(2, Val)), setelement(3, State, lists:sublist(element(3, State), element(3, Val) + 1, length(element(3, State)))));
			call -> exec_step(setelement(1, emulate(element(1, element(3, Val)), element(2, element(3, Val)), lists:sublist(element(2, State), element(3, element(3, Val))), State), tl(RemainingCode)));
			call_only -> emulate(element(1, element(3, Val)), element(2, element(3, Val)), lists:sublist(element(2, State), element(3, element(3, Val))), State);
			call_last -> emulate(element(1, element(3, Val)), element(2, element(3, Val)), lists:sublist(element(2, State), element(3, element(3, Val))), setelement(3, State, lists:sublist(element(3, State), element(4, Val) + 1, length(element(3, State)))));
			call_ext -> exec_step(setelement(1, emulate(element(2, element(3, Val)), element(3, element(3, Val)), lists:sublist(element(2, State), element(4, element(3, Val))), State), tl(RemainingCode)));
			call_ext_only -> emulate(element(2, element(3, Val)), element(3, element(3, Val)), lists:sublist(element(2, State), element(4, element(3, Val))), State);
			call_ext_last -> emulate(element(2, element(3, Val)), element(3, element(3, Val)), lists:sublist(element(2, State), element(4, element(3, Val))), setelement(3, State, emulate(element(3, State), element(4, Val) + 1, length(element(3, State)))));
			call_fun -> exec_step(setelement(1, %term_to_binary(Fun), erlang:fun_info(Fun) - not enough info
				case element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), module)) =:= ?MODULE andalso lists:prefix("-fun_arglist\/", atom_to_list(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), name)))) of true ->
					setmem(State, {x, 0}, apply(getmem(State, {x, element(2, Val)}), lists:sublist(element(2, State), 1, element(2, Val)))); %should get state back out of shared memory instead
					_ -> case element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), type)) =:= external orelse
					element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), module)) =/= erl_eval of true ->
				  emulate(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), module)), element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), name)), lists:sublist(element(2, State), 1, element(2, Val)) ++ element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), env)));
				_ -> %local erl_eval - env has [capturelist, {value, #Fun<>}, {eval, #Fun<>}, [{clause, 1, [args], [guards], [expressions]}]]
					%case hd(element(5, hd(element(4, hd(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), env))))))) of
					%	{call,1,{remote,1,{atom,1,emulator},{atom,1,getmem}},[{call,1,{remote,1,{atom,1,emulator},{atom,1,emulate}}, _}, _]} ->
					%		setmem(State, {x, 0}, apply(getmem(State, {x, element(2, Val)}), lists:sublist(element(2, State), 1, element(2, Val)))); %should get state back out of shared memory instead
					%	_ ->
					UI = erlang:unique_integer(), Name = list_to_atom(StrName = "emu" ++ string:strip(integer_to_list(UI), left, $-)),
					{ok, MTs, _} = erl_scan:string("-module(" ++ StrName ++ ")."),
					{ok, ETs, _} = erl_scan:string("-export([f/" ++ integer_to_list(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), arity))) ++ "])."),
					%erlang:display(erlang:fun_info(getmem(State, {x, element(2, Val)}))),
					%erlang:display("f" ++ erl_prettypr:format(erl_syntax:form_list(element(4, hd(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), env)))))) ++ "."),
					{ok, FTs, _} = erl_scan:string("f" ++ erl_prettypr:format(erl_syntax:form_list(element(4, hd(element(2, erlang:fun_info(getmem(State, {x, element(2, Val)}), env)))))) ++ "."),
					{ok, MF} = erl_parse:parse_form(MTs),
					{ok, EF} = erl_parse:parse_form(ETs),
					{ok, FF} = erl_parse:parse_form(FTs),
					{ok, Name, Bin} = compile:forms([MF, EF, FF], [binary]),
					emulate(beam_disasm:file(Bin), Name, f, lists:sublist(element(2, State), 1, element(2, Val)), State) end end %end
					, tl(RemainingCode)));
			make_fun2 -> exec_step(setelement(1, setmem(State, {x, 0}, %must hook for funs not call_fun'ed such as via apply, but must avoid recursive emulation in call_fun case
				%state should come from shared memory and not be captured as this is not realistic for emulation
				fun_arglist(fun(Args) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), Args ++ lists:sublist(element(2, State), 1, element(5, Val)), State), {x, 0}) end, element(3, element(2, Val)) - element(5, Val))
				%case element(3, element(2, Val)) - element(5, Val) of
					%0 -> fun() -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), lists:sublist(element(2, State), 1, element(5, Val)), State), {x, 0}) end;
					%1 -> fun(X1) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | lists:sublist(element(2, State), 1, element(5, Val))], State), {x, 0}) end;
					%2 -> fun(X1, X2) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | [X2 | lists:sublist(element(2, State), 1, element(5, Val))]], State), {x, 0}) end;
					%3 -> fun(X1, X2, X3) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | [X2 | [X3 | lists:sublist(element(2, State), 1, element(5, Val))]]], State), {x, 0}) end;
					%4 -> fun(X1, X2, X3, X4) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | [X2 | [X3 | [X4 | lists:sublist(element(2, State), 1, element(5, Val))]]]], State), {x, 0}) end;
					%5 -> fun(X1, X2, X3, X4, X5) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | [X2 | [X3 | [X4 | [X5 | lists:sublist(element(2, State), 1, element(5, Val))]]]]], State), {x, 0}) end;
					%6 -> fun(X1, X2, X3, X4, X5, X6) -> getmem(emulate(element(1, element(2, Val)), element(2, element(2, Val)), [X1 | [X2 | [X3 | [X4 | [X5 | [X6 | lists:sublist(element(2, State), 1, element(5, Val))]]]]]], State), {x, 0}) end;
					%N -> Args = lists:append(lists:join(",",["X" ++ integer_to_list(A) || A <- lists:seq(1, N)])), %must export emulate/4 and getmem/2
					%	Str = "fun(" ++ Args ++ ") -> " ?MODULE_STRING ":getmem(" ?MODULE_STRING ":emulate(Filename, Funcname, [" ++ Args ++ "|Capture], State), {x, 0}) end.",
					%	erlang:display(lists:flatten(Str)),
					%	{ok, Tokens, _} = erl_scan:string(lists:flatten(Str)),
					%	{ok, Parsed} = erl_parse:parse_exprs(Tokens),
					%	Binding = erl_eval:add_binding('State', State, erl_eval:add_binding('Capture', lists:sublist(element(2, State), 1, element(5, Val)), erl_eval:add_binding('Funcname', element(2, element(2, Val)), erl_eval:add_binding('Filename', element(1, element(2, Val)), erl_eval:new_bindings())))),
					%	{value, Result, _} = erl_eval:exprs(Parsed, Binding, none), Result
					%arity defined as 0 through 255
				%end
			), tl(RemainingCode)))
		end
	end
.
emulate(Beam, Filename, Funcname, Params, State) ->
	erlang:display([Filename, Funcname, length(Params)]),%, element(5, State), element(7, State)]),%, Params]),
	%erlang:display(element(6, Beam)),
	Func = hd(lists:dropwhile(fun(Elem) -> element(2, Elem) =/= Funcname orelse element(3, Elem) =/= length(Params) end, element(6, Beam))),
	InstList = lists:dropwhile(fun(Elem) -> is_atom(Elem) orelse element(1, Elem) =/= label orelse element(2, Elem) =/= element(4, Func) end, element(5, Func)),
	setelement(7, setelement(5, exec_step(setelement(8, setelement(7, setelement(5, setelement(1, setelement(2, State, Params ++ lists:sublist(element(2, State), length(Params) + 1, 1024)), InstList), [-1|element(5, State)]), [{Filename, Funcname, length(Params), if length(element(5, State)) =:= 0 -> []; true -> [{file, atom_to_list(Filename) ++ ".erl"},{line,hd(element(5, State))}] end}|element(7, State)]), InstList)), element(5, State)), element(7, State))
.
emulate(Filename, Funcname, Params, State) ->
	%erl_ddll:loaded_drivers().
	%https://github.com/erlang/otp/blob/master/erts/preloaded/src/init.erl - snifs undocumented feature
	%https://github.com/erlang/otp/blob/09bd72adbb5f5751995cfce9c02fb812da97f558/erts/emulator/beam/erl_bif_info.c
	%erlang:system_info(taints). erlang:trace(all, true, [call]), erlang:trace_pattern({Filename, Funcname, length(Params)}, true, [local]), erlang:trace_info({zlib, open, 0}, all), erlang:trace(all, false, [call]).
	%HasNif = lists:any(fun ({M, F, A}) -> M =:= Filename andalso F =:= Funcname andalso A =:= length(Params) end, erlang:system_info(snifs)), equal to is_builtin
	%Module:module_info(nifs), Module:module_info(native)
	case erlang:is_builtin(Filename, Funcname, length(Params)) of true -> %orelse HasNif of true ->
		%if Filename =:= erlang andalso Funcname =:= process_info andalso length(Params) =:= 2 andalso lists:nth(2, Params) =:= messages -> 
		%if Filename =:= erlang andalso Funcname =:= process_info andalso length(Params) =:= 2 andalso lists:nth(2, Params) =:= message_queue_len ->
		if Filename =:= erlang andalso Funcname =:= get_stacktrace andalso length(Params) =:= 0 -> setmem(State, {x, 0}, element(7, State) ++ lists:foldl(fun(Elem, Acc) -> if Elem =:= {?MODULE,emulate,3,[{file,?MODULE_STRING ".erl"},{line,?LINE+23}]} -> []; true -> Acc ++ [Elem] end end, [], erlang:apply(Filename, Funcname, Params)));
		%Filename =:= erlang andalso Funcname =:= load_nif andalso length(Params) =:= 2 ->
		%Filename =:= erlang andalso Funcname =:= apply andalso length(Params) =:= 2 ->
		%Filename =:= erlang andalso Funcname =:= apply andalso length(Params) =:= 3 ->
		%Filename =:= erlang andalso Funcname =:= spawn andalso length(Params) =:= 1 ->
		%Filename =:= erlang andalso Funcname =:= spawn andalso length(Params) =:= 2 ->
		Filename =:= erlang andalso Funcname =:= spawn andalso length(Params) =:= 3 -> setmem(State, {x, 0}, spawn(?MODULE, emulate, Params ++ [State]));
		Filename =:= erlang andalso Funcname =:= spawn andalso length(Params) =:= 4 -> setmem(State, {x, 0}, spawn(hd(Params), ?MODULE, emulate, tl(Params) ++ [State]));
		%Filename =:= erlang andalso Funcname =:= spawn_link andalso length(Params) =:= 1 ->
		%Filename =:= erlang andalso Funcname =:= spawn_link andalso length(Params) =:= 2 ->
		Filename =:= erlang andalso Funcname =:= spawn_link andalso length(Params) =:= 3 -> setmem(State, {x, 0}, spawn_link(?MODULE, emulate, Params ++ [State]));
		Filename =:= erlang andalso Funcname =:= spawn_link andalso length(Params) =:= 4 -> setmem(State, {x, 0}, spawn_link(hd(Params), ?MODULE, emulate, tl(Params) ++ [State]));
		%Filename =:= erlang andalso Funcname =:= spawn_monitor andalso length(Params) =:= 1 ->
		Filename =:= erlang andalso Funcname =:= spawn_monitor andalso length(Params) =:= 3 -> setmem(State, {x, 0}, spawn_monitor(?MODULE, emulate, Params ++ [State]));
		%Filename =:= erlang andalso Funcname =:= spawn_opt andalso length(Params) =:= 2 ->
		%Filename =:= erlang andalso Funcname =:= spawn_opt andalso length(Params) =:= 3 ->
		Filename =:= erlang andalso Funcname =:= spawn_opt andalso length(Params) =:= 4 -> setmem(State, {x, 0}, spawn_opt(?MODULE, emulate, lists:droplast(Params) ++ [State], lists:last(Params)));
		Filename =:= erlang andalso Funcname =:= spawn_opt andalso length(Params) =:= 5 -> setmem(State, {x, 0}, spawn_opt(hd(Params), ?MODULE, emulate, lists:droplast(tl(Params)) ++ [State], lists:last(Params)));
		true -> setmem(State, {x, 0}, erlang:apply(Filename, Funcname, Params)) end; %NIFs shadowing must forward to apply
	_ ->
	Path = hd(lists:dropwhile(fun (Elem) -> case beam_disasm:file(Elem ++ "\/" ++ atom_to_list(Filename)) of {error, beam_lib, {file_error, _, enoent}} -> true; _ -> false end end, code:get_path())),
	emulate(beam_disasm:file(Path ++ "\/" ++ atom_to_list(Filename)), Filename, Funcname, Params, State) end
.
emulate(Filename, Funcname, Params) ->
	%remainingcode, x[1024], y[], fr[16], linenum, lasterrclass, stacktrace, originalinstructionlist
	getmem(emulate(Filename, Funcname, Params, {[], lists:duplicate(1024, []), [], lists:duplicate(16, []), [], [], [], []}), {x, 0})
.