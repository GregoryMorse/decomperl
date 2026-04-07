%Erlang Quine's:
%http://www.profshonle.com/2012/05/erlang-quine.html
%-module(q).
%-export([main/0]).

%main() ->
%A="-module(q).\n-export([main/0]).\n\nmain() ->\n",
%B="io:format(\"~sA=~p,~nB=~p,~n~s\",[A, A, B, B]).",
%io:format("~sA=~p,~nB=~p,~n~s",[A, A, B, B]).


%-module(r).
%-export([main/0]).

%main() ->
% Fmt = "-module(r).\n-export([main/0]).\n\nmain() ->\n Fmt = ~p,\n io:format(Fmt, [Fmt]).\n",
% io:format(Fmt, [Fmt]).

%https://rosettacode.org/wiki/Quine#Erlang
%-module(quine).
%-export([do/0]).
 
%do() -> Txt=txt(), io:format("~s~ntxt() ->~n~w.~n",[Txt,Txt]), halt().
%txt() ->
%[45,109,111,100,117,108,101,40,113,117,105,110,101,41,46,10,45,101,120,112,111,114,116,40,91,100,111,47,48,93,41,46,10,10,100,111,40,41,32,45,62,32,84,120,116,61,116,120,116,40,41,44,32,105,111,58,102,111,114,109,97,116,40,34,126,115,126,110,116,120,116,40,41,32,45,62,126,110,126,119,46,126,110,34,44,91,84,120,116,44,84,120,116,93,41,44,32,104,97,108,116,40,41,46].
 
 
%cd("c:/users/grego/Downloads").
%c("selfmod.erl"). selfmod:loop().

-module(selfmod).

-export([poc/0, loop/0, recvloop/0]).

poc() ->
	io:format("Hello 1!~n", []),
	{ok, MTs, _} = erl_scan:string("-module(selfmod)."),
	{ok, ETs, _} = erl_scan:string("-export([poc/0])."),
	{ok, FTs, _} = erl_scan:string("poc() -> io:format(\"Hello 2!~n\", [])."),
	{ok, MF} = erl_parse:parse_form(MTs),
	{ok, EF} = erl_parse:parse_form(ETs),
	{ok, FF} = erl_parse:parse_form(FTs),
	{ok, selfmod, Bin} = compile:forms([MF, EF, FF], [binary]),
  code:load_binary(selfmod, [], Bin),
  %code:purge(selfmod),
  %code:delete(selfmod),
  selfmod:poc()
.

loop() ->
	io:format("Hello 1!~n", []),
	{ok, MTs, _} = erl_scan:string("-module(selfmod)."),
	{ok, ETs, _} = erl_scan:string("-export([loop/0])."),
	FH = "loop() -> io:format(\"Hello 2!~n\", [])," ++
	"{ok, MTs, _} = erl_scan:string(\"-module(selfmod).\")," ++
	"{ok, ETs, _} = erl_scan:string(\"-export([loop/0]).\")," ++
	"FH = \"~s\"," ++
	"{ok, FTs, _} = erl_scan:string(lists:flatten(io_lib:format(FH, [re:replace(FH, \"[\\\\\\\\\\\"]\", \"\\\\\\\\&\", [global, {return, list}])])))," ++
	"{ok, MF} = erl_parse:parse_form(MTs)," ++
	"{ok, EF} = erl_parse:parse_form(ETs)," ++
	"{ok, FF} = erl_parse:parse_form(FTs)," ++
	"{ok, selfmod, Bin} = compile:forms([MF, EF, FF], [binary])," ++
	"code:load_binary(selfmod, [], Bin)," ++
	"selfmod:loop().",
	{ok, FTs, _} = erl_scan:string(lists:flatten(io_lib:format(FH, [re:replace(FH, "[\\\\\\\"]", "\\\\&", [global, {return, list}])]))),
	{ok, MF} = erl_parse:parse_form(MTs),
	{ok, EF} = erl_parse:parse_form(ETs),
	{ok, FF} = erl_parse:parse_form(FTs),
	{ok, selfmod, Bin} = compile:forms([MF, EF, FF], [binary]),
  code:load_binary(selfmod, [], Bin),
  selfmod:loop()
.

recvloop() ->
	receive
		{add, Loc, Str} -> ;
		{remove, Loc, Len} -> ;
		{edit, Loc, Str, Len} -> ;
	end
.