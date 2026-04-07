-module(dumpbeam).
-compile(export_all).

%compile:file("dumpbeam.erl", ['S']).
%debugger:start().
%compile:file("dumpbeam.S", [from_asm,no_postopt,return]).

%{#MatchState} is what is in BEAM register for binary matching
%uninitialized register contains []

%beam_validator will cause any attempt to fail so take BEAM output with {x, 2} to a .beam2 file then {x, 0} to .beam
%diff change first one byte different 23 to 03, try 13 and then 83 to get matching or uninitialized

funtobeam() -> fun (A) -> A end.

dumpregs() ->
	[erlang:display({X}) || X <- lists:seq(0, 1023)].
	
dumpbinmatch() ->
	erlang:display({<<X, _>> = <<3, 4, 5>>}).
	
select_receive(F, Af, AF) -> RemoveMessage = fun(M) -> receive _ -> true end end, %only remove_message
	receive M -> F(M, RemoveMessage) after Af -> AF() end. %take out the remove_message from here