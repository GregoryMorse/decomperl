%file:copy("ebin/dumpbeam.beam", "ebin/dumpbeam.beam2").
-module(dumpbeam).
-compile(export_all).

%c("src/dumpbeam.erl").
%code:purge(dumpbeam).
%code:load_abs("ebin/dumpbeam").

%compile:file("src/dumpbeam.erl", ['S',{outdir,"src"}]).
%debugger:start().
%compile:file("src/dumpbeam.S", [from_asm,no_postopt,return,{outdir,"ebin"}]).

%{#MatchState} is what is in BEAM register for binary matching
%uninitialized register contains []

%beam_validator will cause any attempt to fail so take BEAM output with {x, 2} to a .beam2 file then {x, 0} to .beam
%diff change first one byte different 23 to 03, try 13 and then 83 to get matching or uninitialized
%    {move,{literal,{<<3,4,5>>}},{x,2}}.
% 	 {move,{x,2},{x,0}}.
%    {move,{literal,{<<3,4,5>>}},{x,0}}.
% 	 {move,{x,0},{x,0}}.


funtobeam() -> fun (A) -> A end.

dumpregs() ->
	[erlang:display({X}) || X <- lists:seq(0, 1023)].
	
dumpbinmatch() ->
	erlang:display({<<X, _, _>> = <<3, 4, 5>>}).
	
select_receive(F, Af, AF) -> RemoveMessage = fun(M) -> receive _ -> true end end, %only remove_message
	receive M -> F(M, RemoveMessage) after Af -> AF() end. %take out the remove_message from here
	
diffpatch() ->
  {ok,{file_info,Sz,_,_,_,_,_,_,_,_,_,_,_,_}}=file:read_file_info("ebin/dumpbeam.beam"),
  {ok,{file_info,Sz2,_,_,_,_,_,_,_,_,_,_,_,_}}=file:read_file_info("ebin/dumpbeam.beam2"),
  {ok, Fd} = file:open("ebin/dumpbeam.beam", [read, write]),
  {ok, Fd2} = file:open("ebin/dumpbeam.beam2", [read]),
  {ok, Bin} = file:read(Fd, Sz),
  {ok, Bin2} = file:read(Fd2, Sz2),
  erlang:display({Sz, Sz2}), %Sz =:= Sz2
  Diff = lists:filter(fun ({N, X, Y}) -> X =/= Y end, lists:zip3(lists:seq(1, Sz), Bin, Bin2)),
  file:pwrite(Fd, {bof, element(1, hd(Diff))-1}, [element(3, hd(Diff))]),
  erlang:display(Diff),
  file:close(Fd), file:close(Fd2).