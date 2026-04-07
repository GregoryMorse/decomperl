-module(parcomp).

-compile(export_all).

emu_receive_msg(_, _, []) -> false;
emu_receive_msg(Fr, Pre, [H|T]) ->
	Y = Fr(H),
	if element(1, Y) =:= true -> put(messages, Pre ++ T), Y;
		true -> emu_receive_msg(Fr, Pre ++ H, T)
	end.

%fun returns {true, Value} or {false} depending if it processed in receive
%A is after timeout, Fa is fun for after predicate
emu_receive(Fr) -> emu_receive(Fr, infinity, []).
emu_receive(Fr, infinity, _) ->
	Msgs = get(messages),
	if Msgs =:= undefined -> put(messages, []), emu_receive(Fr, infinity, [], 0);
		true -> Y = emu_receive_msg(Fr, [], Msgs),
			if element(1, Y) =:= true -> element(2, Y);
				true -> emu_receive(Fr, infinity, [], 0) end
	end;
emu_receive(Fr, A, Fa) ->
	Start = os:system_time(millisecond), Msgs = get(messages),
	if Msgs =:= undefined -> put(messages, []), emu_receive(Fr, A, Fa, Start);
		true -> Y = emu_receive_msg(Fr, [], Msgs),
			if element(1, Y) =:= true -> element(2, Y);
				true -> emu_receive(Fr, A, Fa, Start) end
	end.

emu_receive(Fr, infinity, _, _) ->
	receive X ->
		Y = Fr(X),
		if element(1, Y) =:= true -> element(2, Y);
			true -> put(messages, get(messages) ++ [X]), 
				emu_receive(Fr, infinity, [], 0) end
	end;
emu_receive(Fr, A, Fa, Start) ->
	Now = os:system_time(millisecond),
	if A =< (Now - Start) -> Fa();
	true ->
		receive X ->
			Y = Fr(X),
			if element(1, Y) =:= true -> element(2, Y);
				true -> put(messages, get(messages) ++ [X]), 
					emu_receive(Fr, A, Fa, Start) end
		after A - (Now - Start) -> Fa()
		end
	end.

smap(F, L) ->
    [F(H) || H <- L].
    %%[apply(F, [H]) || H <- L].

pmap(F, L) ->
    Parent = self(),
    [spawn(fun() ->  Parent ! F(H) end) || H <- L],
    [emu_receive(fun (M) -> {true, M} end)
    %receive Res -> Res end
     || _ <- L].

pmap2(F, L) ->
    Parent = self(),
    [emu_receive(fun (M) -> {true, M} end)
    %receive Res -> Res end
     || _ <- [spawn(fun() ->  Parent ! F(H) end) || H <- L]].

opmap1(F, L) ->
    Parent = self(),
    Index = lists:seq(1, length(L)),
    NewList = lists:zip(Index, L),
    io:format("NewList: ~p~n", [NewList]),
    [spawn(fun() ->  Parent ! {I, F(H)} end) || {I, H} <- NewList],
    [emu_receive(fun (M) -> case M of {I, Res} -> {true, Res}; _ -> false end end)
    %receive {I, Res} -> Res end
     || I <- Index].

opmap2(F, L) ->
    Parent = self(),
    [spawn(fun() ->  Parent ! {H, F(H)} end) || H <- L],
    [emu_receive(fun (M) -> case M of {I, Res} -> {true, Res}; _ -> false end end)
    %receive {I, Res} -> Res end
     || I <- L].

opmap3(F, L) ->
    Parent = self(),
    Pids = [spawn(fun() ->  Parent ! {self(), F(H)} end) || H <- L],
    [emu_receive(fun (M) -> case M of {I, Res} -> {true, Res}; _ -> false end end)
    %receive {I, Res} -> Res end
     || I <- Pids].

sfib(0) ->
    1;
sfib(1) ->
    1;
sfib(N) when N > 1->
    sfib(N-1) + sfib(N-2).

dcfib(N) ->
    case is_basefib(N) of
	true ->
	    basefib(N);  
	false ->
	    SubProblems = dividefib(N),
	    SubSolutions = smap(fun dcfib/1, SubProblems),
	    combinefib(SubSolutions)
    end.

is_basefib(X) ->
    (X == 1) orelse (X == 0).

basefib(_) ->
    1.

dividefib(X) -> 
    [X-1, X-2].

combinefib(X) -> %% [X1, X2] 
    lists:sum(X). %% X1 + X2

dcfib2(N) ->
    dc({fun is_basefib/1, 
	fun basefib/1, 
	fun dividefib/1,
	fun combinefib/1,
        N}).
qs([])->
    [];
qs([H | T])->
    {SP1, SP2} = lists:partition(fun(X) -> X < H end, T),
    qs(SP1) ++ [H] ++ qs(SP2).

dc({IsBase, Base, Divide, Combine, Problem}) ->
    case IsBase(Problem) of
	true ->
	    Base(Problem);  
	false ->
	    SubProblems = Divide(Problem),
	    SubSolutions = lists:map(fun(P) -> 
			      dc({IsBase, Base, Divide, Combine, P})
				 end, SubProblems),
%% [dc({IsBase, Base, Divide, Combine, P}) || P <- SubProblems ]
	    Combine(SubSolutions)
    end.
