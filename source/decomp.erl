%http://gomoripeti.github.io/beam_by_example/
%http://erlangonxen.org/more/beam
%http://erlang.org/doc/man/beam_lib.html
%http://www.cs-lab.org/historical_beam_instruction_set.html
%https://github.com/erlang/otp/blob/master/lib/compiler/src/genop.tab
%https://github.com/erlang/otp/blob/master/erts/emulator/beam/bif.tab
%cd(os:getenv("USERPROFILE") ++
% "/source/repos/refactorerl/branches/morse/master/tool/lib/referl_ast").
%cd("d:/source/repos/refactorerl/branches/morse/master/tool/lib/referl_ast").
%cd("c:/users/morse/downloads").
%c("semequiv.erl", [debug_info,{outdir, "temp"}]).
%c("decomp.erl", [{outdir, "temp"}]). code:add_path("temp").
%decomp:disassemble("temp/calcpi.beamasm", "calcpi").
%decomp:disassemble("temp/emulator.beamasm", "emulator").
%decomp:getabstractsyntax("temp/emulator.beam", "temp/em.ast").
%decomp:transform("temp/emulator.beam", "temp/em.erl").

%decomp:decompile("temp/decomptest", "temp/out.erl", [writeast,bfsscan,compile,stubfuncs]).
%decomp:decompile("decomptest", matchhelper, 0, "temp/out.erl", [writeast,stubfuncs]).
%decomp:decompile("decomptest", testtrycatchrecrs, 0, "temp/out.erl", []).

%Search for errors in AST output with regex: graphdata|(?<={error,\n).*\n
%observer:start().
%cprof:start(), cprof:analyze(), cprof:stop().
%eprof:start(), eprof:start_profiling([self()]).
%eprof:stop_profiling(), eprof:analyze(), eprof:stop().
%fprof:start(), fprof:trace([start]),
%fprof:trace([stop]), fprof:profile(),
%fprof:analyse([totals, {dest, "fprof.analysis"}]), fprof:stop().
%EScript: https://github.com/isacssouza/erlgrind/blob/master/src/erlgrind
%KCacheGrind for Windows (QCacheGrind):
%https://sourceforge.net/projects/qcachegrindwin/
%"%ProgramFiles%\erl9.3\bin\escript.exe" erlgrind fprof.trace
%decomp:decomp_otp("map_SUITE.erl").
%decomp:decomp_otp("trycatch_SUITE.erl").
%decomp:decomp_otp("andor_SUITE", comb, 3).
%decomp:decomp_otp("map_SUITE.erl", t_build_and_match_literals, 1).
%decomp:decomp_otp("float_SUITE", math_functions, 1).
%decomp:decomp_lib("mnesia-4.15.3").
%decomp:decomp_lib("erts-9.3", "erlang").
%decomp:decomp_lib("megaco-3.18.3", "megaco_ber_media_gateway_control_prev3a", unused_bitlist, 3).

%decomp:decomp_lib("kernel-5.4.3", "disk_log", log_loop, 7).
%decomp:decomp_lib("kernel-5.4.3", "file_io_server", get_chars_apply, 7).
%decomp:decomp_lib("ssl-8.2.4", "ssl", ssl_accept,3).
%decomp:decomp_lib("stdlib-3.4.4", "ets", file2tab,2).
%decomp:decomp_lib("stdlib-3.4.4", "unicode", characters_to_binary,3).
%decomp:decomp_lib("orber-3.8.4", "orber", dbg, 3).

%decomp:decomp_lib("common_test-1.15.4", "test_server").
%decomp:decomp_lib("stdlib-3.4.4", "ets", tab2file,3).
%decomp:decomp_lib("runtime_tools-1.12.5", "observer_backend", get_table_list,2).
%decomp:decomp_lib("erts-9.3", "erlang", convert_time_unit, 3).
%decomp:decomp_lib("stdlib-3.4.4", "binary").
%decomp:decomp_lib("stdlib-3.4.4", "ms_transform").


%decomp:decomp_lib("observer-2.7", "observer_trace_wx", handle_event,2).
%decomp:decomp_lib("stdlib-3.4.4", "unicode_util", unicode_table,1).
%decomp:decomp_otp("lc_suite", no_gen,2).
%decomp:decomp_otp("map_SUITE", t_build_and_match_literals_large,1).
%decomp:decomp_otp("bs_utf_SUITE", match_literal,1).

-module(decomp).
-import(semequiv, [get_ast_self/0]).

-define(LibPath, os:getenv("ProgramFiles") ++ "/erl9.3/lib/").
-define(OTPPath, os:getenv("USERPROFILE") ++ "/Downloads/otp_src_20.3/test").

-export([gen_paper_dot/0, check_lib_stats/0, decomp_all_lib/0, decomp_lib/1,
	decomp_lib/2, decomp_lib/4, decomp_otp/0, decomp_otp/1, decomp_otp/3,
	get_src_line_numbers/1, ftime_stats_to_tex/0, mtime_stats_to_tex/0, lib_stats_to_tex/0,
	ftime_stats_to_plotdata/0, ast_to_erl_lib/1,
	ast_to_erl_all/0, ast_to_erl_file/1, to_gb_sets/1, paper_rev_graph/0, decompdecomp/0,
	do_get_dfs_parent/3, do_dfs_parent/4, do_tarjan_immdom/2, do_dfs/2,
	check_dfs/0, check_tarjan/0, check_idf/0, check_sgl/0, edgeset_to_dot/2,
	compute_idf/2, sreedhar_gao_lee_add/4, sreedhar_gao_lee_remove/4,
	succ_to_pred/1, get_j_succ/2, check_pred_succ/1, traverse_ast/3,
	disassemble/2, transform/2, getabstractsyntax/2, get_clean_ast/4,
	decompileast/4, decompile/3, decompile/5]).

gen_paper_dot() -> Opts = [dotfile,dot2tex,writeast,stubfuncs,changemodname,compile],
	decomp:decompile("temp/decomptest", slideexample, 2, "temp/slideexample.erl", Opts),
	decomp:decompile("temp/decomptest", incstruct, 5, "temp/incstruct.erl", [optimize,stubfuncs]),
	decomp:decompile("temp/decomptest", papertryreceive, 2, "temp/papertryreceive.erl", [optimize,stubfuncs]),
	decomp:decompile("temp/decomptest", incstruct, 5, "temp/out.erl", Opts),
	decomp:decompile("temp/decomptest", papertryreceive, 2, "temp/out.erl", Opts),
	decomp:decompile("temp/decomptest", testandalso, 4, "temp/out.erl", Opts),
	decomp:decompile("temp/decomptest", testorelse, 4, "temp/out.erl", Opts).

int_fold_lines(Cons, Result, Device) ->
  case io:get_line(Device, "") of eof -> file:close(Device), Result;
  Line -> NewResult = Cons(Line, Result),
  int_fold_lines(Cons, NewResult, Device) end.
check_lib_stats() ->
	filelib:fold_files(?LibPath, ".*\.?rl$",
		true, fun (Filename, Acc) ->
		{ok, Device} = file:open(Filename, [read]),
		Split = filename:split(Filename),
		ModName = case lists:last(lists:droplast(Split)) of "src" ->
				lists:last(lists:droplast(lists:droplast(Split)));
			"include" -> lists:last(lists:droplast(lists:droplast(Split)));
			_ -> lists:append(lists:join("\/",
				lists:nthtail(length(Split) - 4, lists:droplast(Split)))) end,
		Stat = {filename:basename(filename:basename(Filename, ".erl"), ".hrl"),
			Fn = int_fold_lines(fun(_, A) -> A + 1 end, 0, Device)},
		case lists:keyfind(ModName, 1, Acc) of false ->
			lists:keystore(ModName, 1, Acc, {ModName, Fn, [Stat]});
		{_,L,X} -> lists:keyreplace(ModName, 1, Acc, {ModName, L + Fn, [Stat|X]})
		end end, []).
comp_func_stats(Stat) ->
	{Funcname,Arity,LambdaMap,
     {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi},
     Time} = Stat,
  {Nodes, RetNodes, Edges, REdges, Crs, CNodes, CEdges, CREdges, MaxDepth, AggDepth} =
  maps:fold(fun (_, {N, RN, E, RE, C, CN, CE, CRE, MD, AD},
   	{AccN, AccRN, AccE, AccRE, AccC, AccCN, AccCE, AccCRE, AccMD, AccAD}) ->
   		{N+AccN, RN+AccRN, E+AccE, RE+AccRE,
   			C+AccC, CN+AccCN, CE+AccCE, CRE+AccCRE, MD+AccMD, AD+AccAD} end,
   	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, LambdaMap),
  {Funcname,Arity,Time,map_size(LambdaMap) - 1,
  	Nodes, RetNodes, Edges, REdges, Crs, CNodes, CEdges, CREdges, MaxDepth, AggDepth,
  	Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi}
.
comp_mod_stats(Stat) ->
	lists:foldl(fun ({_,_,T,LC,
  	N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  	Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH}, {AccT,AccLC,
  	AccN, AccRN, AccE, AccRE, AccC, AccCN, AccCE, AccCRE, AccMD, AccAD,
  	AccTe, AccSV, AccST, AccTr, AccCa,
  	AccR, AccJ, AccCl, AccEx, AccLL, AccLH}) -> 
  	{T+AccT,LC+AccLC,
  	N+AccN, RN+AccRN, E+AccE, RE+AccRE, C+AccC, CN+AccCN, CE+AccCE, CRE+AccCRE,
  	MD+AccMD, AD+AccAD,
  	Te+AccTe, SV+AccSV, ST+AccST, Tr+AccTr, Ca+AccCa,
  	R+AccR, J+AccJ, Cl+AccCl, Ex+AccEx,
  	if AccLL =:= 0 -> LL; LL =:= 0 -> AccLL;
  	true -> min(LL,AccLL) end, max(LH,AccLH)}
	end, {0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, Stat)
.

get_func_stats() ->
	filelib:fold_files(".", ".*\.stat$", true, fun (Filename, Acc) ->
		{ok, Bin} = file:read_file(Filename),
		{ok, Ts, _} = erl_scan:string(binary_to_list(Bin) ++ "."),
		{ok, Trm} = erl_parse:parse_term(Ts),
		Split = filename:split(Filename),
		LibName = lists:last(lists:droplast(Split)),
		[{LibName, filename:basename(Filename, ".stat"), length(Trm),
			lists:map(fun (El) -> comp_func_stats(El) end, Trm)}|Acc]
		end, []).
		
get_mod_stats() ->
	lists:map(fun ({LN, MN, Fncs, FnStat}) -> {LN, MN, Fncs, comp_mod_stats(FnStat)} end, get_func_stats())
.

ftime_stats_to_tex() ->
	io:format("~s~n~s~n", lists:foldl(fun ({LibName, ModName, _Funcs, MStat}, [Acc, AccOth]) ->
	{FuncName, Arity, T,LC, N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  	Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH} = MStat,
  [Acc ++ lists:flatten(io_lib:format("\\lstinline|~s| & \\lstinline|~s| & \\lstinline|~s| & ~p & ~p & ~p & ~p & ~p\\\\~n",
		[LibName, ModName, FuncName, Arity,T/1000000,LC, N, RN])),
   AccOth ++ lists:flatten(io_lib:format("~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p\\\\~n",
		[E, RE, C, CN, CE, CRE, MD, AD,
  		Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH]))]
	end, ["", ""], lists:sublist(lists:sort(fun (A, B) -> element(3, element(4, A)) >= element(3, element(4, B)) end, lists:append(lists:map(fun ({LN, MN, Fncs, FnStat}) -> lists:map(fun (El) -> {LN, MN, Fncs, El} end, FnStat) end, get_func_stats()))), 1, 50)))
.

ftime_stats_to_plotdata() ->
	io:format("~s~n~s~n", lists:foldl(fun ({_LibName, _ModName, _Funcs, MStat}, [Acc, AccNew]) ->
	{_FuncName, _Arity, T,_LC, N, _RN, _E, _RE, _C, _CN, _CE, _CRE, MD, AD,
  	Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH} = MStat,
  [Acc ++ lists:flatten(io_lib:format("~p ~p ~p ~p~n",
		[T/1000000,N, Te+SV+ST+Tr+Ca+R+J+Cl+Ex, LH-LL+1])),
	 AccNew ++ lists:flatten(io_lib:format("~p ~p ~p~n",
		[T/1000000, MD, AD]))]
	end, ["", ""], lists:sublist(lists:sort(fun (A, B) -> element(3, element(4, A)) >= element(3, element(4, B)) end, lists:append(lists:map(fun ({LN, MN, Fncs, FnStat}) -> lists:map(fun (El) -> {LN, MN, Fncs, El} end, FnStat) end, get_func_stats()))), 1, 50)))
.


mtime_stats_to_tex() ->
	io:format("~s", [lists:foldl(fun ({LibName, ModName, Funcs, MStat}, Acc) ->
	{T,LC, N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  	Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH} = MStat,
	Acc ++ lists:flatten(io_lib:format("\\lstinline|~s| & \\lstinline|~s| & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p\\\\~n",
		[LibName, ModName, Funcs,T/1000000,LC, N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  		Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH]))
	end, "", lists:sublist(lists:sort(fun (A, B) -> element(4, A) >= element(4, B) end, get_mod_stats()), 1, 50))])
.

lib_stats_to_tex() -> %filter out temp, demo, meas, httpd_load_test, sodoku, simple, ex2, ex1, examples, xrc
	LStat = lists:foldl(fun ({LibName, _, Funcs, MStat}, Acc) ->
		{Time,LambdaCount,
			Nodes, RetNodes, Edges, REdges, Crs, CNodes, CEdges, CREdges, MaxDepth, AggDepth,
			Test, SVal, STA, Trys, Catchs,
			Rcvs, Jmps, Calls, Exits, LnLo, LnHi} = MStat,
		case Acc of #{LibName := LibData} ->
			{M,Fn,T,LC,
  			N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  			Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH} = LibData,
  		Acc#{LibName => {M+1,Fn+Funcs,T+Time,LC+LambdaCount,
  			N+Nodes, RN+RetNodes, E+Edges, RE+REdges,
  			C+Crs, CN+CNodes, CE+CEdges, CRE+CREdges, MD+MaxDepth, AD+AggDepth,
  			Te+Test, SV+SVal, ST+STA, Tr+Trys, Ca+Catchs,
  			R+Rcvs, J+Jmps, Cl+Calls, Ex+Exits, LL+LnLo, LH+LnHi}};
		_ -> Acc#{LibName => {1, Funcs, Time,LambdaCount,
			Nodes, RetNodes, Edges, REdges, Crs, CNodes, CEdges, CREdges, MaxDepth, AggDepth,
			Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi}} end
		end, #{}, get_mod_stats()),
	io:format("~s~n~s~n", lists:foldl(fun ({K, {M,Fn,T,LC,
  			N, RN, E, RE, C, CN, CE, CRE, MD, AD,
  			Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH}}, [Acc, AccOth]) ->
  	case lists:member(K, ["temp", "demo", "meas", "httpd_load_test", "sodoku", "simple", "ex2", "ex1", "examples", "xrc"]) of true -> [Acc, AccOth]; _ ->
		[Acc ++ lists:flatten(io_lib:format("\\lstinline|~s| & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p\\\\~n",
			[K,M,Fn,T/1000000,LC, N, RN, E, RE, C, CN, CE, CRE, MD, AD])), AccOth ++ lists:flatten(io_lib:format("\\lstinline|~s| & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p & ~p\\\\~n",
			[K,
  			Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LH - LL + 1]))] end
		end, ["", ""], lists:sort(fun ({_, A}, {_, B}) -> element(3, A) >= element(3, B) end, maps:to_list(LStat)))).

get_terms(Filename) ->
	{ok, Bin} = file:read_file(Filename),
	{ok, Ts, _} = erl_scan:string(binary_to_list(Bin) ++ "."),
	{ok, Trm} = erl_parse:parse_term(Ts), Trm.

ast_to_erl_file(Filename) ->
	%Trm = binary_to_term(Bin),
	Errs = ast_to_erl(get_terms(Filename), filename:dirname(Filename) ++ "/" ++
		filename:basename(Filename, ".ast") ++ ".erl"),
	case Errs of [] -> true; _ ->
		{ok, Efd} = file:open("temp/astconv.err",[append]),
		io:fwrite(Efd, "~ts", [Errs]), file:close(Efd) end,
	io:format("Completed ~s~n", [Filename])
.

ast_to_erl(Trm, OutFile) ->
		try throw(undef), erl_prettypr:format(erl_syntax:form_list(Trm)) of Print ->
			{ok, Fd} = file:open(OutFile, [write, {encoding, utf8}]),
	  	io:fwrite(Fd, "~ts~n", [Print]), file:close(Fd)
	  catch X:Y -> {TermP, TermF} = lists:foldl(fun (El, {AccP, AccF}) ->
	  	try erl_prettypr:format(erl_syntax:form_list([El])) of Prn -> {[Prn|AccP], AccF}
	  	catch Xe:Ye -> {AccP, [{Xe, Ye, case El of {function,_,N,A,_} -> {N, A}; _ -> {} end}|AccF]} end end, {[], []}, Trm),
			{ok, Fd} = file:open(OutFile, [write, {encoding, utf8}]),
	  	io:fwrite(Fd, "~ts~n", [lists:append(lists:join("\n", lists:reverse(TermP)))]), file:close(Fd),
	  	if TermF =:= [] -> []; true ->
	  	ErrMsg = io_lib:format("~p~n", [{X, Y, OutFile, lists:reverse(TermF)}]),
	  	FinErr = lists:flatten(ErrMsg),
	  	io:format("~ts", [FinErr]), FinErr
			end end.

ast_to_erl_lib(LibName) -> file:delete("temp/astconv.err"),
	filelib:fold_files("temp/" ++ LibName, ".*\.ast$", true, fun (Filename, _Acc) ->
		ast_to_erl_file(Filename)
	end, []).

ast_to_erl_all() -> file:delete("temp/astconv.err"),
	filelib:fold_files(".", ".*\.ast$", true, fun (Filename, _Acc) ->
		ast_to_erl_file(Filename)
	end, []).
		
decomp_all_lib() ->
	filelib:fold_files(?LibPath, ".*\.beam$",
		true, fun (Filename, _Acc) ->
		Split = filename:split(Filename),
		ModName = filename:basename(Filename, ".beam"),
		OutFile = "temp/" ++ case lists:last(lists:droplast(Split)) of "ebin" ->
				lists:last(lists:droplast(lists:droplast(Split)));
			_ -> lists:append(lists:join("\/",
				lists:nthtail(length(Split) - 4, lists:droplast(Split)))) end ++ "\/" ++
		ModName ++ ".erl", filelib:ensure_dir(OutFile),
		Time = os:timestamp(), decomp:decompile(Filename, OutFile, [writeast,compile,stubfuncs]),
			{ModName, timer:now_diff(os:timestamp(), Time)} end, []).
decomp_lib(LibName) ->
	filelib:fold_files(?LibPath ++ LibName ++
		"/ebin", ".*\.beam$", false, fun (Filename, _Acc) ->
			filelib:ensure_dir("temp/" ++ LibName ++ "/"),
				decomp:decompile(Filename, "temp/" ++ LibName ++ "/" ++
					filename:basename(Filename, ".beam") ++ ".erl", [writeast,compile,stubfuncs]) end, []).
decomp_lib(LibName, ModName) -> decomp:decompile(
	?LibPath ++ LibName ++ "/ebin/" ++ ModName, "temp/" ++ LibName ++ "/" ++
	ModName ++ ".erl", [writeast,compile,stubfuncs]).
decomp_lib(LibName, ModName, FuncName, Arity) ->
	decomp:decompile(
	?LibPath ++ LibName ++ "/ebin/" ++ ModName, FuncName, Arity,
	"temp/" ++ LibName ++ "/" ++ ModName ++ ".erl", [progress,dotfile,writeast,stubfuncs]).
decomp_otp() -> 
	filelib:fold_files(?OTPPath,
		".*\.erl$", false, fun (Filename, _Acc) ->
			filelib:ensure_dir("temp/compiler_test/"),
			case filelib:is_file("temp/" ++ filename:basename(Filename, ".erl") ++ ".beam") of
			true -> true; _ -> compile:file(Filename, [{outdir, "temp"}]) end,
			decomp:decompile("temp/" ++ filename:basename(Filename, ".erl"),
				"temp/compiler_test/" ++ filename:basename(Filename, ".erl") ++ ".erl", [writeast,compile,stubfuncs]) end, []).
decomp_otp(ModName) ->
	Filename =
		?OTPPath ++ ModName,
	case filelib:is_file("temp/" ++ filename:basename(Filename, ".erl") ++ ".beam") of
		true -> true; _ -> compile:file(Filename, [{outdir, "temp"}]) end,
	decomp:decompile("temp/" ++ filename:basename(Filename, ".erl"),
		"temp/compiler_test/" ++ filename:basename(Filename, ".erl") ++ ".erl", [writeast,compile,stubfuncs]).
decomp_otp(ModName, FuncName, Arity) ->
	Filename =
		?OTPPath ++ ModName,
	case filelib:is_file("temp/" ++ filename:basename(Filename, ".erl") ++ ".beam") of
		true -> true; _ -> compile:file(Filename, [{outdir, "temp"}]) end,
	decomp:decompile("temp/" ++ filename:basename(Filename, ".erl"), FuncName, Arity, 
		"temp/compiler_test/" ++ filename:basename(Filename, ".erl") ++ ".erl", [progress,dotfile,writeast,stubfuncs]).
decompdecomp() ->
	decomp:decompile("temp/decomptest", "temp/decomptest.erl", [writeast,stubfuncs]),
	decomp:decompile("temp/decomp", "temp/decomp.erl", [writeast,stubfuncs]),
	decomp:decompile("temp/semequiv", "temp/semequiv.erl", [writeast,stubfuncs]),
	decomp:decompile("temp/emulator", "temp/emulator.erl", [writeast,stubfuncs]).

disassemble(Outfile, Filename) ->
	%{N, M} = code:load_abs(Filename),
	%beam_lib:all_chunks(M)
	file:write_file(Outfile, io_lib:fwrite("~p.~n", [beam_disasm:file(Filename)]))
.

transform(BeamFName, ErlFName) ->
  case beam_lib:chunks(BeamFName, [abstract_code]) of
	{ok, {_, [{abstract_code, {raw_abstract_v1,Forms}}]}} ->
	  Src = 
		erl_prettypr:format(erl_syntax:form_list(tl(Forms))),
		{ok, Fd} = file:open(ErlFName, [write]),
		io:fwrite(Fd, "~s~n", [Src]),
		file:close(Fd); 
	Error -> Error
  end
.
getabstractsyntax(BeamFName, ErlFName) ->
  case beam_lib:chunks(BeamFName, [abstract_code]) of
	{ok, {_, [{abstract_code, {raw_abstract_v1,Forms}}]}} ->
	  %Src = tl(Forms),
	  Src = lists:map(fun clean_ast_linenums/1, tl(Forms)),
		{ok, Fd} = file:open(ErlFName, [write]),
		io:fwrite(Fd, "~p~n", [Src]),
		file:close(Fd); 
	Error -> Error
  end
.

lookup_ast_args(AST) ->
	Key = element(1, AST),
	#{Key := StrucPosbl} = #{
		%0 - literal, 1 - traversal, 2 - list traversal
		var => [{0}], char => [{0}], integer => [{0}], float => [{0}],
		atom => [{0}], string => [{0}], nil => [{}],
		cons => [{1,1}],
		lc => [{1,2}], generate => [{1,1}],
		bc => [{1,2}], b_generate => [{1,1}],
		tuple => [{2}], record_field => [{1,1},{1}], %record_index => [{0}],
		record => [{0,2},{1,0,2}],
		map => [{2},{1,2}], map_field_assoc => [{1,1}], map_field_exact => [{1,1}],
		block => [{2}], 'if' => [{2}], 'case' => [{1,2}], 'try' => [{2,2,2,2}],
		'receive' => [{2},{2,1,2}],
		'fun' => [{{clauses,2}},{{function,0,0}}],%,{{function,0,0,0}}],
		named_fun => [{0,2}],
		call => [{1,2}], 'catch' => [{1}], match => [{1,1}], op => [{0,1},{0,1,1}],
		bin => [{2}], bin_element => [{1,default,0},{1,1,0}],
		remote => [{1,1}], clause => [{2,3,2}],
		attribute => [{record,{0,2}},{0,0}],
		function => [{0,0,2}], eof => {}},
	StrucL = lists:filter(fun (El) ->
		tuple_size(El) + 2 =:= tuple_size(AST) end, StrucPosbl),
	case StrucL of [H] -> H; [Hd|Tl] ->
		if is_atom(element(1, Hd)) ->
			if element(1, Hd) =:= element(3, AST) -> Hd;
			true -> hd(Tl) end;
		is_tuple(element(1, Hd)) ->
			if element(1, element(1, Hd)) =:= element(1, element(3, AST)) ->
				Hd; true -> hd(Tl) end;
		is_atom(element(2, Hd)) ->
			if element(2, Hd) =:= element(4, AST) -> Hd;
			true -> hd(Tl) end
		end end.

traverse_ast(Fun, Acc, AST) ->
	Struc = lookup_ast_args(AST),
	{NewAST, NewAcc} =
	lists:foldl(fun (El, {CurAST, CurAcc}) ->
		case element(El, Struc) of
		0 -> {CurAST, CurAcc};
		1 -> {New, NewAcc} = traverse_ast(Fun,CurAcc,element(El + 2, CurAST)),
			{setelement(El + 2, CurAST, New), NewAcc};
		2 -> {New, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
				{[], CurAcc}, element(El + 2, CurAST)),
			{setelement(El + 2, CurAST, New), NewAcc};
		3 -> {New, NewAcc} = lists:foldl(fun (Elem, {Lt, Accu}) ->
			{NewEl, NewAccu} = lists:foldl(fun (E, {List,Ac}) ->
				{NewElem, TAc} = traverse_ast(Fun,Ac,E), {List ++ [NewElem], TAc} end,
					{[], Accu}, Elem),
				{Lt ++ [NewEl], NewAccu} end, {[], CurAcc}, element(El + 2, CurAST)),
			{setelement(El + 2, CurAST, New), NewAcc};
		X when is_atom(X) -> {CurAST, CurAcc};
		Y when is_tuple(Y) ->
			{New, NewAcc} = lists:foldl(fun (E, {NCurAST, NCurAcc}) ->
				case element(E, Y) of 0 -> {NCurAST, NCurAcc};
				2 -> {New, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
					{NewElem, TAc} = traverse_ast(Fun,Ac,Elem),
					{List ++ [NewElem], TAc} end, {[], NCurAcc}, element(E, NCurAST)),
					{setelement(E, NCurAST, New), NewAcc};
				X when is_atom(X) -> {NCurAST, NCurAcc} end
				end, {element(El + 2, CurAST), CurAcc}, lists:seq(1, tuple_size(Y))),
			{setelement(El + 2, CurAST, New), NewAcc}
		end end, {AST, Acc}, lists:seq(1, tuple_size(Struc))),
	Fun(NewAST, NewAcc)
.

%traverse_ast_alt(Fun, Acc, AST) -> %erl_eval.erl, eval_bits.erl
%	NewAST = case AST of
%	{var,L,A} -> NewAcc = Acc, {var,L,A};
%	{char,L,A} -> NewAcc = Acc, {char,L,A};
%	{integer,L,A} -> NewAcc = Acc, {integer,L,A};
%	{float,L,A} -> NewAcc = Acc, {float,L,A};
%	{atom,L,A} -> NewAcc = Acc, {atom,L,A};
%	{string,L,A} -> NewAcc = Acc, {string,L,A};
%	{nil,L} -> NewAcc = Acc, {nil,L};
%	{cons,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {cons,L,NewA,NewB};
%
%	{lc,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B), {lc,L,NewA,NewB};
%	{bc,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B), {bc,L,NewA,NewB};
%		{generate,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%			{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {generate,L,NewA,NewB};
%		{b_generate,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%			{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {b_generate,L,NewA,NewB};
%	{tuple,L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {tuple,L,NewA};
%	{record_field,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {record_field,L,NewA,NewB};
%	%{record_index,L,_} -> {record_index,L,_};
%	{record,L,A,B} -> {NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, B),{record,L,A,NewB};
%	{record,L,A,B,C} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewC, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, C), {record,L,NewA,B,NewC};
%
%	{map,L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {map,L,NewA};
%	{map,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B), {map,L,NewA,NewB};
%		{map_field_assoc,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%			{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {map_field_assoc,L,NewA,NewB};
%		{map_field_exact,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%			{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {map_field_exact,L,NewA,NewB};
%	{block,L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {block,L,NewA};
%	{'if',L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {'if',L,NewA};
%	{'case',L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B), {'case',L,NewA,NewB};
%	{'try',L,A,B,C,D} -> {NewA, Acc1} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A),
%		{NewB, Acc2} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B),
%		{NewC, Acc3} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc2}, C),
%		{NewD, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc3}, D), {'try',L,NewA,NewB,NewC,NewD};
%	{'receive',L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {'receive',L,NewA};
%	{'receive',L,A,B,C} -> {NewA, Acc1} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A),
%		{NewB, Acc2} = traverse_ast(Fun,Acc1,B),
%		{NewC, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc2}, C), {'receive',L,NewA,NewB,NewC};
%	{'fun',L,{clauses,A}} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {'fun',L,{clauses,NewA}};
%	{'fun',L,{function,A,B}} -> NewAcc = Acc, {'fun',L,{function,A,B}};
%	%{'fun',L,{function,A,B,C}} -> NewAcc = Acc, {'fun',L,{function,A,B,C}};
%	{named_fun,L,A,B} -> {NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, B), {named_fun,L,A,NewB};
%	%A - {remote,_,{atom,_,qlc},{atom,_,q}}
%	%  {remote,_,{record_field,_,{atom,_,''},{atom,_,qlc}=Mod},{atom,_,q}=Func}
%	%    {remote,_,Mod,Func}  {atom,_,Func}  function or {Mod,Fun}
%	{call,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc1}, B), {call,L,NewA,NewB};
%	{'catch',L,A} -> {NewA, NewAcc} = traverse_ast(Fun,Acc,A), {'catch',L,NewA};
%	{match,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {match,L,NewA,NewB};
%	{op,L,A,B} -> {NewB, NewAcc} = traverse_ast(Fun,Acc,B), {'op',L,A,NewB};
%	{op,L,A,B,C} -> {NewB, Acc1} = traverse_ast(Fun,Acc,B), %'andalso', 'orelse'
%		{NewC, NewAcc} = traverse_ast(Fun,Acc1,C), {'op',L,A,NewB,NewC};
%	{bin,L,A} -> {NewA, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A), {bin,L,NewA};
%		{bin_element,L,A,B,C} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%			{NewB, NewAcc} = if B =:= default -> {B, Acc1}; true ->
%				traverse_ast(Fun,Acc1,B) end, {bin_element,L,NewA,NewB,C};
%	{remote,L,A,B} -> {NewA, Acc1} = traverse_ast(Fun,Acc,A),
%		{NewB, NewAcc} = traverse_ast(Fun,Acc1,B), {remote,L,NewA,NewB};
%
%	{clause,L,A,B,C} -> {NewA, Acc1} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, A),
%		{NewB, Acc2} = lists:foldl(fun (Elem, {Lt, Accu}) ->
%			{NewEl, NewAccu} = lists:foldl(fun (El, {List,Ac}) ->
%				{NewElem, TAc} = traverse_ast(Fun,Ac,El), {List ++ [NewElem], TAc} end,
%					{[], Accu}, Elem),
%			{Lt ++ [NewEl], NewAccu} end, {[], Acc1}, B),
%		{NewC, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%			{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%				{[], Acc2}, C), {clause,L,NewA,NewB,NewC};
%
%	{attribute,L,record,A} -> {NewA2, NewAcc} = lists:foldl(fun (Elem, {List,Ac})
%	-> {NewElem, TAc} = traverse_ast(Fun,Ac,Elem),
%		{List ++ [NewElem], TAc} end, {[], Acc}, element(2, A)),
%		%A=record,B = {name, {record_field,_,{atom,_,_}}, ...}  default values...
%		{attribute,L,record,{element(1, A),NewA2}};
%		{record_field,L,A} ->
%			{NewA, NewAcc} = traverse_ast(Fun,Acc,A), {record_field,L,NewA};
%	{function,L,A,B,C} -> {NewC, NewAcc} = lists:foldl(fun (Elem, {List,Ac}) ->
%		{NewElem, TAc} = traverse_ast(Fun,Ac,Elem), {List ++ [NewElem], TAc} end,
%			{[], Acc}, C), {function,L,A,B,NewC};
%	{attribute,L,A,B} -> NewAcc = Acc, {attribute,L,A,B};
%	{eof,L} -> NewAcc = Acc, {eof,L}
%	end, Fun(NewAST, NewAcc)
%.

clean_ast_linenums(AST) ->
	element(1, traverse_ast(fun (Elem, Acc) -> {setelement(2, Elem, 0), Acc} end,
		[], AST)).

%apply_ast_args(FuncAST, Args) -> FuncAST.

%rename_ast_vars(FuncAST, Args) -> FuncAST.

get_clean_ast(Src, Funcname, Arity, SubOut) ->
	if SubOut -> {clause,0,[],[],[{call,0,{atom,0,Funcname},[]}]}; true ->
  clean_ast_linenums(hd(element(5, hd(lists:dropwhile(fun(Elem) ->
    element(1, Elem) =/= function orelse element(3, Elem) =/= Funcname orelse
    element(4, Elem) =/= Arity end, Src))))) end.

get_clean_ast_all(Src, Funcname, Arity, SubOut) ->
	if SubOut -> [{clause,0,[],[],[{call,0,{atom,0,Funcname},[]}]}]; true ->
  [clean_ast_linenums(El) || El <- element(5, hd(lists:dropwhile(fun(Elem) ->
    element(1, Elem) =/= function orelse element(3, Elem) =/= Funcname orelse
    element(4, Elem) =/= Arity end, Src)))] end.

%% setnth(Index, List, NewElement) -> List.
setnth(1, [_|Rest], New) -> [New|Rest];
setnth(I, [E|Rest], New) -> [E|setnth(I-1, Rest, New)].

index_of(Item, List) -> index_of(Item, List, 1).

index_of(_, [], _)  -> 0;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).

%indexes_of(Item, List) -> indexes_of(Item, List, 1).

%indexes_of(_, [], _)  -> [];
%indexes_of(Item, [Item|Tl], Index) -> [Index|indexes_of(Item, Tl, Index+1)];
%indexes_of(Item, [_|Tl], Index) -> indexes_of(Item, Tl, Index+1).

getliteral(Lit) ->
	if is_integer(Lit) -> {integer,0,Lit};
 	is_atom(Lit) -> {atom,0,Lit};
	is_float(Lit) -> {float,0,Lit};
	is_tuple(Lit) -> {tuple,0,lists:map(fun (Elem) ->
		getliteral(Elem) end, tuple_to_list(Lit))};
	is_list(Lit) ->
%https://github.com/erlang/otp/blob/master/erts/emulator/beam/erl_printf_term.c
	  %is_printable_string
	  IsLatin1 = true,
		case Lit =/= [] andalso lists:all(fun(Elem) -> is_integer(Elem) andalso
			Elem >= 32 andalso Elem =< 126 orelse IsLatin1 andalso
			(Elem >= 128+32 andalso Elem =< 255) orelse
			Elem =:= 10 orelse Elem =:= 9 orelse Elem =:= 13 end, Lit) of true ->
			{string, 0, lists:flatten(io_lib:format("~s", [Lit]))};
		_ ->
			if Lit =:= [] -> {nil, 0}; true ->
				{cons, 0, getliteral(hd(Lit)), getliteral(tl(Lit))} end
		end;
	is_tuple(Lit) ->
		{tuple, 0, lists:map(fun(Elem) -> if is_list(Elem) orelse is_tuple(Elem) ->
			getliteral(Elem); true -> getliteral(Elem) end end, tuple_to_list(Lit))};
	is_binary(Lit) ->
		{bin,0,[{bin_element,0,getliteral(X),default,default} ||
			X <- binary_to_list(Lit)]};
	is_bitstring(Lit) -> BL = bitstring_to_list(Lit),
		S = bit_size(lists:last(BL)), <<N:S/integer>> = lists:last(BL),
		{bin,0,[{bin_element,0,getliteral(X),default,default} ||
			X <- lists:droplast(BL)] ++
			[{bin_element,0,{integer,0,N},{integer,0,S},default}]}; %[bitstring]
	is_map(Lit) ->
		{map,0,[{map_field_assoc,0,getliteral(K),getliteral(V)} ||
			{K, V} <- maps:to_list(Lit)]}
	end
.

getmemd(Graph, Where) ->
	if
		Where =:= nil -> {nil,0};
		true -> case element(1, Where) of
			integer -> if element(2, Where) < 0 ->
				{op,0,'-',{integer,0,-element(2, Where)}};
				true -> {integer,0,element(2, Where)} end;
			atom -> {atom,0,element(2, Where)};
			float -> if element(2, Where) < 0 ->
				{op,0,'-',{float,0,-element(2, Where)}};
				true -> {float,0,element(2, Where)} end;
			list -> element(2, Where);
			literal -> getliteral(element(2, Where));
			x -> array:get(element(2, Where) + 1-1, element(3, Graph));
			y -> case element(2, Where) + 1 > array:size(element(4, Graph)) of true ->
					[]; %{unresolved, Where};
				_ -> array:get(element(2, Where) + 1-1, element(4, Graph))
			end;
			fr -> array:get(element(2, Where) + 1-1, element(5, Graph))
			%f -> lists:dropwhile(fun(Elem) -> is_atom(Elem) orelse
			%element(1, Elem) =/= label orelse element(2, Elem) =/= element(2, Where)
			%end, element(1, State))
		end
	end
.

setmemd(Graph, Where, Val) ->
	case element(1, Where) of
		x -> setelement(3, Graph,
			array:set(element(2, Where) + 1-1, Val, element(3, Graph)));
		y -> case
			element(2, Where) + 1 > array:size(element(4, Graph)) of true ->
				setelement(4, Graph, array:set(element(2, Where), Val,
					array:resize(element(2, Where)+1, element(4, Graph))));
			_ -> setelement(4, Graph,
				array:set(element(2, Where) + 1-1, Val, element(4, Graph)))
		end;
		fr -> setelement(5, Graph,
			array:set(element(2, Where) + 1-1, Val, element(5, Graph)))
	end
.

get_tuple_putsd(Graph, State, Count, ShowProg) ->
	if
		Count =:= 0 -> [];
		true -> Val = hd(element(1, State)),
		  if ShowProg -> io:format("~p~n", [Val]); true -> true end,
			case element(1, Val) of
				put -> [getmemd(Graph, element(2, Val))|get_tuple_putsd(Graph,
					setelement(1, State, tl(element(1, State))), Count - 1, ShowProg)]
			end
	end
.

get_binary_sizes(Exp) ->
	%io:format("~p~n", [Exp]),
	if element(1, Exp) =:= integer -> [element(3, Exp)];
	true ->
		case element(3, Exp) of '*' -> if element(1, element(4, Exp)) =:= integer andalso element(1, element(5, Exp)) =:= integer -> [hd(get_binary_sizes(element(4, Exp))) * hd(get_binary_sizes(element(5, Exp)))];
				element(1, element(4, Exp)) =/= integer andalso element(1, element(5, Exp)) =/= integer -> A = get_binary_sizes(element(4, Exp)), B = get_binary_sizes(element(5, Exp)),
					case lists:all(fun (X) -> is_integer(X) end, A) orelse lists:all(fun (X) -> is_integer(X) end, B) of true ->
						lists:append([case lists:all(fun (X) -> is_integer(X) end, A) of true -> B; _ -> A end || _ <- lists:seq(1, lists:sum(case lists:all(fun (X) -> is_integer(X) end, A) of true -> A; _ -> B end))]);
						_ -> [{op,0,'*',A,B}] end;
				true -> lists:append([get_binary_sizes(element(if element(1, element(4, Exp)) =:= integer -> 5; true -> 4 end, Exp)) ||
					_ <- lists:seq(1, hd(get_binary_sizes(element(if element(1, element(4, Exp)) =:= integer -> 4; true -> 5 end, Exp))))]) end;
			'+' -> get_binary_sizes(element(4, Exp)) ++ get_binary_sizes(element(5, Exp));
			_ -> [Exp]
		end
	end
.

get_binary_flags(Flags) ->
%lib/compiler/src/beam_asm.erl: flag_to_bit(X) 1 is aligned but no longer useful and 8 is exact but unused
	lists:append([if (Flags band 2) =:= 2 -> [little]; true -> [] end|
		[if (Flags band 4) =:= 4 -> [signed]; true -> [] end|
			[if (Flags band 16) =:= 16 -> [native]; true -> [] end]]])
.

get_binary_putsd(Graph, State, Items, Count, Prior, ShowProg) ->
	case
		Prior =/= [] andalso lists:all(fun (El) -> is_integer(El) end, Items) andalso lists:sum(Items) =:= 0 of true -> {Prior, Count};
		_ -> Val = hd(element(1, State)),
		  if ShowProg -> io:format("~p~n", [Val]); true -> true end, %{Val, Items}),
		  %https://github.com/erlang/otp/blob/master/erts/emulator/beam/erl_printf_term.c is_printable_ascii >= 32 <= 126 or 10, 9, 13
		  if element(1, Val) =:= bs_put_string -> get_binary_putsd(Graph, setelement(1, State, tl(element(1, State))), [-(element(2, Val) * 8)|Items], Count + 1,
		  	Prior ++ [{bin_element,0,{integer,0,X},default,default} || X <- element(2, element(3, Val))], ShowProg);
			element(1, Val) =:= bs_put_utf8 ->
				Size = lists:duplicate(8,{'if',0,[{clause,0,[],[[{op,0,'<',getmemd(Graph, element(4, Val)),{integer,0,128}}]],[{integer,0,1}]},
					{clause,0,[],[[{op,0,'<',getmemd(Graph, element(4, Val)),{integer,0,2048}}]],[{integer,0,2}]},{clause,0,[],[[{op,0,'<',getmemd(Graph, element(4, Val)),{integer,0,65536}}]],[{integer,0,3}]},
						{clause,0,[],[[{atom,0,true}]],[{integer,0,4}]}]}),
			  get_binary_putsd(Graph, setelement(1, State, tl(element(1, State))), Items -- Size, Count +  1,
			 		Prior ++ [{bin_element,0,getmemd(Graph, element(4, Val)),default,[utf8|get_binary_flags(element(2, element(3, Val)))]}], ShowProg);
			element(1, Val) =:= bs_put_utf16 ->
				Size = lists:duplicate(8,{'if',0,[{clause,0,[],[[{op,0,'>=',getmemd(Graph, element(4, Val)),{integer,0,65536}}]],[{integer,0,4}]},{clause,0,[],[[{atom,0,true}]],[{integer,0,2}]}]}),
			  get_binary_putsd(Graph, setelement(1, State, tl(element(1, State))), Items -- Size, Count +  1,
			 		Prior ++ [{bin_element,0,getmemd(Graph, element(4, Val)),default,[utf16|get_binary_flags(element(2, element(3, Val)))]}], ShowProg);
			element(1, Val) =:= bs_put_utf32 ->
			  get_binary_putsd(Graph, setelement(1, State, tl(element(1, State))), [-32|Items], Count +  1,
			 		Prior ++ [{bin_element,0,getmemd(Graph, element(4, Val)),default,[utf32|get_binary_flags(element(2, element(3, Val)))]}], ShowProg);
		  true -> Size = case (element(3, Val)) of {atom, all} -> case element(4, Val) =:= 8 andalso lists:member({call,0,{remote,0,{atom,0,erlang},{atom,0,byte_size}},[getmemd(Graph, element(6, Val))]}, Items) of true ->
		  	lists:duplicate(element(4, Val), {call,0,{remote,0,{atom,0,erlang},{atom,0,byte_size}},[getmemd(Graph, element(6, Val))]});
		  	_ -> [{call,0,{remote,0,{atom,0,erlang},{atom,0,bit_size}},[getmemd(Graph, element(6, Val))]}] end; _ -> case lists:member(getmemd(Graph, element(3, Val)), Items) of true ->
		  		lists:duplicate(element(4, Val), getmemd(Graph, element(3, Val)));
		  		_ -> get_binary_sizes({op,0,'*',{integer,0,element(4, Val)},getmemd(Graph, element(3, Val))}) end end,
		  get_binary_putsd(Graph, setelement(1, State, tl(element(1, State))), if is_integer(hd(Size)) -> [-(hd(Size))|Items]; true -> Items -- Size end, Count +  1,
		  Prior ++ [case element(1, Val) of
				bs_put_integer -> {bin_element,0,getmemd(Graph, element(6, Val)),default,[integer|get_binary_flags(element(2, element(5, Val)))]};
				bs_put_binary -> {bin_element,0,getmemd(Graph, element(6, Val)),default,[binary|get_binary_flags(element(2, element(5, Val)))]};
				bs_put_float -> {bin_element,0,getmemd(Graph, element(6, Val)),default,[float|get_binary_flags(element(2, element(5, Val)))]}
				end], ShowProg)
			end
	end
.

getnodevisited(NodeState, El) -> case El > array:size(NodeState) of true -> 0; _ -> array:get(El-1, NodeState) end.
setnodevisited(NodeState, El, Status) ->
	case El > array:size(NodeState) of true -> array:set(El-1, Status, array:resize(El, NodeState)); _ -> array:set(El-1, Status, NodeState) end.
	
getnodeblockstruct({AST, NodesToAST, _, _}, P, CatchNode) ->
	case lists:last(array:get(P-1, NodesToAST)) of {} -> false; _ -> %placeholder for loop back node filtered
	%PN = case length(lists:nth(P, Pred)) =:= 1 andalso lists:suffix([4, 1, 3, 1, 2, 1, 5, 1], hd(array:get(P-1, NodesToAST))) andalso lists:member(P + 1, lists:nth(hd(lists:nth(P, Pred)), Succ)) andalso
		%lists:any(fun (El) -> array:get(El-1, NodesToAST) =:= [{}] end, lists:nth(hd(lists:nth(P, Pred)), Succ)) of true -> hd(lists:nth(P, Pred)); _ -> P end,
	%receive all is the exception where the post dominator of the main block is the first block of the receive block, but need to avoid finding the try block
	Path = getnextsibling(lists:last(array:get(P-1, NodesToAST))),
	%try-catch with all out of band error try block and no of clause must conservatively consider the rest of the function and hence return node as post dominator
	case if CatchNode =/= 0 -> not tup_prefix_same(lists:last(array:get(CatchNode-1, NodesToAST)), lists:last(array:get(P-1, NodesToAST)), 1) orelse element(tuple_size(lists:last(array:get(CatchNode-1, NodesToAST))), lists:last(array:get(CatchNode-1, NodesToAST))) < element(tuple_size(lists:last(array:get(P-1, NodesToAST))), lists:last(array:get(P-1, NodesToAST)));
		true -> PathTup = lists:last(array:get(P-1, NodesToAST)), MaxLen = length(element(element(tuple_size(PathTup) - 1, PathTup), dogetgraphpath(AST, tuple_drop_n(PathTup, 2), 1))),
			element(tuple_size(Path), Path) > MaxLen end of true -> false; _ -> case dogetgraphpath(AST, Path, 1) of
		{match,_,_,[{call,_,{'fun',_,{clauses,_}},_}]} -> 'receive';
		{match,_,_,[{'try', _, _, _, _, _}]} -> 'try';
		{match,_,_,[{'catch',_,_}]} -> 'catch';
		{var,_,_} -> var;
		_ -> false end end end.

isblockstructresolvable({_, NodesToAST, _, _}, P, Node, PIdom, PSucc) ->
	Path = tuple_to_list(getnextsibling(lists:last(array:get(P-1, NodesToAST)))), LPath = length(Path),
	%{Suffix, SuffixAfter} = if Kind =:= 'try' -> {[4, 1, 3, 1], [4, 1, 5, 1, 5, 2]};
		%true -> {[4, 1, 4, 1, 3, 1, 2, 1, 5, 1], [4, 1, 4, 3, 3, 1, 2, 1, 5, 1]} end,
	case not lists:any(fun (El) -> tuple_size(hd(array:get(El-1, NodesToAST))) =:= LPath end, gb_sets:to_list(PSucc)) orelse %already resolved
		Node =/= 2 andalso %(list_to_tuple(Path ++ Suffix) =:= hd(array:get(PIdom-1, NodesToAST)) orelse %not just post dominated but also uncrossed!
			%list_to_tuple(Path ++ SuffixAfter) =:= hd(array:get(PIdom-1, NodesToAST))) orelse
			LPath < tuple_size(hd(array:get(PIdom-1, NodesToAST))) orelse
		%Node =:= 2 andalso not gb_sets:is_element(P, NodeIdomIdx) andalso
			%list_to_tuple(Path ++ Suffix) =/= hd(array:get(PIdom-1, NodesToAST)) andalso
			%list_to_tuple(Path ++ SuffixAfter) =/= hd(array:get(PIdom-1, NodesToAST)) orelse
		hd(array:get(PIdom-1, NodesToAST)) =:= [] of true -> false; _ -> true end.
		
getmergenode({_, NodesToAST, _, _}, P, HeadNodeSucc) ->
	Path = getnextsibling(lists:last(array:get(P-1, NodesToAST))),
	hd(lists:dropwhile(fun (El) -> El =:= 2 orelse tuple_size(hd(array:get(El-1, NodesToAST))) =/= tuple_size(Path) end, gb_sets:to_list(HeadNodeSucc)))
.

issinglepath({_, NodesToAST, _, _}, Kind, HeadNode, HeadNodeIdom) ->
	Path = tuple_to_list(getnextsibling(lists:last(array:get(HeadNode-1, NodesToAST)))),
	{Suffix, SuffixAfter} = if Kind =:= 'try' -> {[4, 1, 3, 1], [4, 1, 5, 1, 5, 2]};
		true -> {[4, 1, 4, 1, 3, 1, 2, 1, 5, 1], [4, 1, 4, 3, 3, 1, 2, 1, 5, 1]} end,
	list_to_tuple(Path ++ Suffix) =:= hd(array:get(HeadNodeIdom-1, NodesToAST)) orelse
	list_to_tuple(Path ++ SuffixAfter) =:= hd(array:get(HeadNodeIdom-1, NodesToAST)).
	
isblockchild({_, NodesToAST, _, _}, Kind, IsFirst, P, Node) ->
	Path = list_to_tuple(tuple_to_list(getnextsibling(lists:last(array:get(P-1, NodesToAST)))) ++ case Kind of
		try_end -> [4, 1, 3];
		'try' -> if IsFirst -> [4, 1, 4]; true -> [4, 1, 5] end;
		'receive' -> if IsFirst -> [4, 1, 4, 1]; true -> [4, 1, 4, 3] end end),
	tup_prefix(Path, lists:last(array:get(Node-1, NodesToAST)), tuple_size(Path))
.

isnested({_, NodesToAST, _, _}, Child, Parent) -> ParentLast = lists:last(array:get(Parent-1, NodesToAST)),
	ChildLast = lists:last(array:get(Child-1, NodesToAST)),
	if tuple_size(ParentLast) =:= tuple_size(ChildLast) -> false; true ->
	tup_prefix(getnextsibling(ParentLast), ChildLast, tuple_size(ParentLast)) end.

getmergepredblockstruct({AST, NodesToAST, _, _}, Elem, Preds) ->
	case gb_sets:size(Preds) of 1 -> P = gb_sets:smallest(Preds), case array:get(P-1, NodesToAST) =/= [{}] of true -> Path = getnextsibling(lists:last(array:get(P-1, NodesToAST))),
		case array:get(Elem-1, NodesToAST) =:= [{}] orelse array:get(P-1, NodesToAST) =:= [{}] orelse
			not tup_prefix_same(lists:last(array:get(Elem-1, NodesToAST)), lists:last(array:get(P-1, NodesToAST)), 1) of true -> false;
			_ -> case dogetgraphpath(AST, Path, 1) of
				{match,_,_,[{call,_,{'fun',_,{clauses,_}},_}]} -> {'receive', P};
				{match,_,_,[{'try', _, _, _, _, _}]} -> {'try', P}; _ -> false end end; _ -> false end; _ -> false end.

getblockstructchild({_, NodesToAST, _, _}, Succs, Kind, IsFirst, P) ->
	Path = tuple_to_list(getnextsibling(lists:last(array:get(P-1, NodesToAST)))),
	Suffix = if Kind =:= 'try' -> if IsFirst -> [4, 1, 3, 1]; true -> [4, 1, 5, 1, 5, 2] end;
		true -> if IsFirst -> [4, 1, 4, 1, 3, 1, 2, 1, 5, 1]; true -> [4, 1, 4, 3, 3, 1, 2, 1, 5, 1] end end,
	X = lists:dropwhile(fun (El) -> list_to_tuple(Path ++ Suffix) =/= hd(array:get(El-1, NodesToAST)) end, gb_sets:to_list(Succs)),
	if X =:= [] -> Y = lists:dropwhile(fun (El) -> [{}] =/= array:get(El-1, NodesToAST) end, gb_sets:to_list(Succs)), if Y =:= [] -> 0; true -> hd(Y) end;
	true -> hd(X) end.

getgraphpathchild({AST, NodesToAST, _, _}, Kind, IsFirst, PathNode) ->
	Path = list_to_tuple(tuple_to_list(getnextsibling(lists:last(array:get(PathNode-1, NodesToAST)))) ++
		case Kind of remove_message -> [4, 1, 4, 1, 3, 1, 2, 1, 3, if IsFirst -> 1; true -> 2 end];
		timeout -> [4, 1, 4, 1]; 'try' -> if IsFirst -> [4, 1, 4, 1, 5, 1]; true -> [4, 1, 5, 1, 5, 2] end;
		{'try', true} -> [4, 1] end),
	dogetgraphpath(AST, Path, 1)
.

getgraphpathfirst({AST, NodesToAST, _, _}, PathNode) ->
	Path = hd(array:get(PathNode-1, NodesToAST)),
	if Path =/= {} -> dogetgraphpath(AST, Path, 1); true -> {} end.

getgraphpath({AST, NodesToAST, _, _}, PathNode) ->
	Path = lists:last(array:get(PathNode-1, NodesToAST)),
	if Path =/= {} -> dogetgraphpath(AST, Path, 1); true -> {} end.

dogetgraphpath(Graph, Path, Idx) ->
	%io:format("~p~n", [{Path, Idx}]),
  if tuple_size(Path) - Idx =:= 0 -> lists:nth(element(Idx, Path), Graph);
	true -> dogetgraphpath(element(element(Idx + 1, Path), lists:nth(element(Idx, Path), Graph)), Path, Idx + 2)
  end
.

setgraphpathchild({AST, NodesToAST, ASTDFS, IdxDFS}, Kind, IsFirst, PathNode, Val) ->
	Path = list_to_tuple(tuple_to_list(getnextsibling(lists:last(array:get(PathNode-1, NodesToAST)))) ++ case Kind of timeout -> [4, 1];
		'try' -> if IsFirst -> [4, 1, 4, 1, 5, 1]; true -> [4, 1, 5, 1, 5, 2] end;
	{'try', true} -> [4, 1] end),
	{dosetgraphpath(AST, Path, Val, 1), NodesToAST, ASTDFS, IdxDFS}.

setgraphpath({AST, NodesToAST, ASTDFS, IdxDFS}, PathNode, Val) ->
	Path = lists:last(array:get(PathNode-1, NodesToAST)),
	{dosetgraphpath(AST, Path, Val, 1), NodesToAST, ASTDFS, IdxDFS}.

dosetgraphpath(Graph, Path, Val, Idx) ->
	%io:format("~p~n", [[Graph, Path, Val]]),
  if tuple_size(Path) - Idx =:= 0 -> if
			element(Idx, Path) > length(Graph) -> Graph ++ [Val];
			true -> setnth(element(Idx, Path), Graph, Val)
		end;
	true -> CurEl = lists:nth(element(Idx, Path), Graph), setnth(element(Idx, Path), Graph, setelement(element(Idx + 1, Path), CurEl,
		dosetgraphpath(element(element(Idx + 1, Path), CurEl), Path, Val, Idx + 2)))
  end
.

insertgraphpath(Graph, Path, Val, Idx) ->
	%io:format("~p~n", [{Graph, Path, Idx}]),
  if tuple_size(Path) - Idx =:= 0 -> if
			element(Idx, Path) > length(Graph) -> Graph ++ [Val];
			true -> {Left, Right} = lists:split(element(Idx, Path) - 1, Graph), Left ++ [Val|Right]
		end;
	true -> CurEl = lists:nth(element(Idx, Path), Graph), setnth(element(Idx, Path), Graph, setelement(element(Idx + 1, Path), CurEl,
		insertgraphpath(element(element(Idx + 1, Path), CurEl), Path, Val, Idx + 2)))
  end
.

removegraphpath(Graph, Path, Idx) ->
	%io:format("~p~n", [[Graph, Path]]),
  if tuple_size(Path) - Idx =:= 0 -> if
			element(Idx, Path) > length(Graph) -> Graph;
			true -> {Left, Right} = lists:split(element(Idx, Path) - 1, Graph), Left ++ tl(Right)
		end;
	true -> CurEl = lists:nth(element(Idx, Path), Graph), setnth(element(Idx, Path), Graph, setelement(element(Idx + 1, Path), CurEl,
		removegraphpath(element(element(Idx + 1, Path), CurEl), Path, Idx + 2)))
  end
.

insert_renumber(NodesToAST, ASTDFS, NodePath, SearchOnly) -> %DFS would give a much more restricted renumbering walk, paths should be tuples not lists
	NodePathLen = tuple_size(NodePath), NodePathLast = element(NodePathLen, NodePath),
	%DFSTup = list_to_tuple(DFS = element(1, lists:unzip(lists:sort(fun({_, [A|_]}, {_, [B|_]}) -> A =< B; ({_, A}, {_, _}) -> A =:= [] end, lists:zip(lists:seq(1, array:size(NodesToAST)), NodesToAST))))),
	Idx = bin_search_lbound(ASTDFS, NodesToAST, NodePath), %io:format("~p~n", [{Idx, NodePath, ASTDFS, NodesToAST}]),
	case Idx > array:size(ASTDFS) of true -> {NodesToAST, Idx}; _ -> %return node emits off the end
	StartIdx = Idx + case tup_compare(lists:last(array:get(array:get(Idx-1, ASTDFS)-1, NodesToAST)), NodePath) < 0 of true -> 1; _ -> 0 end,
	if SearchOnly -> {NodesToAST, StartIdx}; true ->
	Length = case StartIdx > array:size(ASTDFS) of true -> 0; _ -> ASTDFSSize = array:size(ASTDFS), fun CheckLen(El) -> if El =:= ASTDFSSize+1 -> El; true -> Elem = hd(array:get(array:get(El-1, ASTDFS)-1, NodesToAST)),
		case tup_prefix(NodePath, Elem, NodePathLen - 1) andalso element(NodePathLen, Elem) >= NodePathLast of true -> CheckLen(El+1); _ -> El end end end(StartIdx + 1) - StartIdx-1 end,
	%io:format("~p~n", [{Idx, StartIdx, Length, array:size(ASTDFS), lists:last(element(element(Idx, ASTDFS), NodesToAST)), NodePath, NodesToAST}]),
	{lists:foldl(fun (El, Acc) -> X = array:get(StartIdx + El-1, ASTDFS),
		array:set(X-1, lists:map(fun(Elem) -> case X =/= array:get(StartIdx-1, ASTDFS) orelse tup_prefix(NodePath, Elem, NodePathLen - 1) andalso element(NodePathLen, Elem) >= NodePathLast of true ->
			setelement(NodePathLen, Elem, element(NodePathLen, Elem) + 1); _ -> Elem end end, array:get(X-1, Acc)), Acc) end, NodesToAST, lists:seq(0, Length)), StartIdx} end end
	%[lists:map(fun(Elem) -> case lists:prefix(NodePathDropLast, Elem) andalso lists:nth(NodePathLen, Elem) >= NodePathLast of
		%	true -> setnth(NodePathLen, Elem, lists:nth(NodePathLen, Elem) + 1);
		%	_ -> Elem end end, hd(NodesToAST))|insert_renumber(tl(NodesToAST), NodePath)]
.

%remove_renumber([], _) -> [];
%remove_renumber(NodesToAST, NodePath) ->
%	[lists:map(fun(Elem) -> case lists:prefix(lists:droplast(NodePath), Elem) andalso lists:nth(length(NodePath), Elem) >= lists:last(NodePath) of
%			true -> setnth(length(NodePath), Elem, lists:nth(length(NodePath), Elem) - 1);
%			_ -> Elem end end, hd(NodesToAST))|remove_renumber(tl(NodesToAST), NodePath)]
%.

getnextsibling(ElemPath) -> N = tuple_size(ElemPath), setelement(N, ElemPath, element(N, ElemPath) + 1).

isnodeloopback({_, NodesToAST, _, _}, El) -> array:get(El-1, NodesToAST) =:= [{}].

comparenodes({_, _, _, IdxDFS}, A, B) -> array:get(A-1, IdxDFS) =< array:get(B-1, IdxDFS).
%compareedges({_, _, _, IdxDFS}, {Aa, Ba}, {Ca, Da}) ->
%	A = array:get(Aa-1, IdxDFS), B = array:get(Ba-1, IdxDFS),
%	C = array:get(Ca-1, IdxDFS), D = array:get(Da-1, IdxDFS),
%	if A =:= C andalso B =:= D -> true;
%		A < B andalso C < D orelse A > B andalso C > D ->
%			if B =:= D -> A < C; true -> B < D end;
%		A < B -> false; C < D -> true end.

%swapgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Node, Data, NewNode) ->
	%StepAST = insertgraphnode(doinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, lists:last(array:get(Node-1, NodesToAST)), {}, NewNode), NewNode, getgraphpath({AST, NodesToAST, ASTDFS, IdxDFS}, Node), Node),
	%setelement(2, StepAST, setelement(Node, element(2, StepAST), element(Node, element(2, StepAST)) -- element(NewNode, element(2, StepAST))))
%.

batchinsertgraphnodechild({AST, NodesToAST, ASTDFS, IdxDFS}, Node, Kind, NewNode) ->
	Path = lists:reverse(tuple_to_list(getnextsibling(lists:last(array:get(Node-1, NodesToAST))))),
	Batch = lists:reverse(lists:map(fun ({L, NN}) -> {list_to_tuple(lists:reverse(L)), NN} end,
		case Kind of {select_val, N} -> lists:foldl(fun (_, Acc) -> {L,NN} = hd(Acc),
			DL = tl(L), [{[1,5,2,4,2|DL], NN+2},{[1,5,1,4,2|DL], NN+1}|Acc] end, [{[1,5,2,4|Path], NewNode+1},{[1,5,1,4|Path], NewNode}], tl(N)) end)),
	dobatchinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Batch, 0).

insertgraphnodechild({AST, NodesToAST, ASTDFS, IdxDFS}, Node, Kind, IsFirst, NewValue, NewNode) ->
	Path = tuple_to_list(getnextsibling(lists:last(array:get(Node-1, NodesToAST)))) ++
		case Kind of 'receive' -> if IsFirst -> [4, 1, 4, 1, 3, 1, 2, 1, 5, 1]; true -> [4, 1, 4, 3, 3, 1, 2, 1, 5, 1] end;
			{'receive', true} -> if IsFirst -> [4, 1, 4, 1]; true -> [4, 1, 4, 3] end ++ [3, 1, 2, 1, 5];
			wait_timeout -> [5, 1];
			'try' -> if IsFirst -> [4, 1, 3, 1]; true -> [4, 1, 5, 1, 5, 2] end;
			{'try', true} -> if IsFirst -> [4, 1, 4]; true -> [4, 1, 5] end ++ [1, 5];
			try_end -> [4, 1, 4, 1, 5, 1];
			'catch' -> [4, 1, 3, 1];
			test -> if IsFirst -> [4, 1, 5, 1]; true -> [4, 2, 5, 1] end;
			{select_val, N} -> lists:append(lists:duplicate(N - 1, [4, 2, 5, 2])) ++ if IsFirst -> [4, 1, 5, 1]; true -> [4, 2, 5, 1] end end,
	AddPath = list_to_tuple(case Kind of {_, true} -> Path ++ [length(element(lists:nth(length(Path), Path), dogetgraphpath(AST, list_to_tuple(lists:droplast(Path)), 1))) + 1]; _ -> Path end),
	doinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, AddPath, NewValue, NewNode)
.

insertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Node, EmitValue, NewValue, NewNode) ->
	Path = getnextsibling(lists:last(array:get(Node-1, NodesToAST))),
	doinsertgraphnode(doinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Path, NewValue, NewNode), Path, EmitValue, 0).

insertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Node, NewValue, NewNode) ->
	doinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, if Node =:= {} -> Node; true -> getnextsibling(lists:last(array:get(Node-1, NodesToAST))) end, NewValue, NewNode).

doinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, NodePath, NewValue, NewNode) ->
	%io:format("~p~n", [{array:to_list(ASTDFS), array:to_list(IdxDFS), NodePath, NewValue, NewNode}]),
	%case check_nodes({AST, NodesToAST, ASTDFS, IdxDFS}) of true -> true; _ -> error("AST sanity check failed") end,
	{Renum, Idx} = if NodePath =:= {} -> {NodesToAST, 2}; true ->
		insert_renumber(NodesToAST, ASTDFS, NodePath, NewValue =:= {} orelse NewNode =/= 0 andalso NewNode < array:size(NodesToAST) + 1 andalso array:get(NewNode-1, NodesToAST) =:= []) end,
  {if NewValue =:= {} -> AST; true -> insertgraphpath(AST, NodePath, NewValue, 1) end,
  	if NewNode =/= 0 -> case NewNode >= array:size(NodesToAST) + 1 of true -> array:set(NewNode-1, [NodePath], array:resize(NewNode, Renum));
  		_ -> array:set(NewNode-1, array:get(NewNode-1, Renum) ++ [NodePath], Renum) end; true -> Renum end,
  	if NewNode =/= 0 -> case NewNode >= array:size(NodesToAST) + 1 orelse array:get(NewNode-1, Renum) =:= [] of true ->
  		{First, Last} = lists:split(Idx - 1, array:to_list(ASTDFS)), array:from_list(First ++ [NewNode|Last]);
  		_ -> ASTDFS end; true -> ASTDFS end,
  	if NewNode =/= 0 -> case NewNode >= array:size(NodesToAST) + 1 of true ->
  		array:set(NewNode-1, Idx, array:resize(NewNode, array:map(fun (_, El) -> if El >= Idx -> El + 1; true -> El end end, IdxDFS)));
  		%docs: the best way to modify multiple elements in a large tuple is to convert the tuple to a list, modify the list, and convert it back to a tuple. 
  		_ -> case array:get(NewNode-1, Renum) =/= [] of true -> IdxDFS;
  			_ -> array:map(fun (El, NEl) -> if El+1 =:= NewNode -> Idx; NEl >= Idx -> NEl + 1; true -> NEl end end, IdxDFS) end end; true -> IdxDFS end}.

dobatchinsertgraphnode({AST, NodesToAST, ASTDFS, IdxDFS}, Batch, PreLen) ->
	SortBatch = lists:foldr(fun ({Path, Idx}, Acc) -> if Acc =/= [] andalso element(2, hd(Acc)) =:= Idx -> [{[Path|element(1, hd(Acc))], Idx}|tl(Acc)]; true -> [{[Path], Idx}|Acc] end end, [], if PreLen =:= 0 -> Batch; true -> lists:sort(fun ({A, _}, {B, _}) -> tup_compare_pre(PreLen, A, B) =< 0 end, Batch) end),
	OpSort = lists:sort(fun ({_, A}, {_, B}) -> A =< B end, SortBatch),
	case element(2, hd(OpSort)) =< array:size(NodesToAST) of true ->
		{NewNodePaths, _} = lists:unzip(tl(OpSort)), NewNodes = lists:delete(element(2, hd(OpSort)), element(2, lists:unzip(SortBatch)));
	_ -> {NewNodePaths, _} = lists:unzip(OpSort), {_, NewNodes} = lists:unzip(SortBatch) end,
	LoopBackCount = length(lists:takewhile(fun ({[{}], _}) -> true; (_) -> false end, case element(2, hd(OpSort)) =< array:size(NodesToAST) of true -> lists:delete(hd(OpSort), SortBatch); _ -> SortBatch end)),
	{LB, Nodes} = lists:split(LoopBackCount, NewNodes),
	LenNewNodes = length(NewNodes),
	{Renum, Idx} = if NewNodePaths =:= [] -> {NodesToAST, 2}; true -> insert_renumber(NodesToAST, ASTDFS, hd(hd(NewNodePaths)), true) end,
	%io:format("~p~n", [{Batch, Idx, LenNewNodes, LoopBackCount, NewNodePaths, NewNodes, Nodes, element(2, hd(OpSort)) =< array:size(NodesToAST)}]),
	_Show = {AST, array:from_list(array:to_list(case element(2, hd(OpSort)) =< array:size(NodesToAST) of true -> array:set(element(2, hd(OpSort))-1, array:get(element(2, hd(OpSort))-1, Renum) ++ element(1, hd(OpSort)), Renum); _ -> Renum end) ++ NewNodePaths),
		begin {First, Last} = lists:split(Idx - 1, array:to_list(ASTDFS)), {LBFst, LBLast} = lists:split(1, First), array:from_list(LBFst ++ LB ++ LBLast ++ Nodes ++ Last) end,
		array:from_list(lists:map(fun (El) -> if El >= Idx -> El + LenNewNodes; El >= 2 -> El + LoopBackCount; true -> El end end, array:to_list(IdxDFS)) ++ element(2, lists:unzip(lists:sort(lists:zip(LB, lists:seq(2, 2 + LoopBackCount - 1)) ++ lists:zip(Nodes, lists:seq(Idx + LoopBackCount, Idx + LenNewNodes - 1))))))}.
	%io:format("~p~n", [{setelement(1, Show, {})}]), Show.
	%lists:foldl(fun ({X, Y}, B) -> doinsertgraphnode(B, X, {}, Y) end, {AST, NodesToAST, ASTDFS, IdxDFS})

check_nodes({AST, NodesToAST, ASTDFS, IdxDFS}) ->
	fun AstCheck(El) -> if El =:= 0 -> true; true -> case array:get(array:get(El-1, IdxDFS)-1, ASTDFS) =:= El of true -> true; _ -> io:format("~p~n", [El]), false end andalso AstCheck(El-1) end end(array:size(IdxDFS)) andalso
	fun PathCheck(El) -> if El =:= 0 -> true; true -> case tup_compare(lists:last(array:get(array:get(El-1, ASTDFS)-1, NodesToAST)), lists:last(array:get(array:get(El + 1-1, ASTDFS)-1, NodesToAST))) =< 0 of true -> true; _ -> io:format("~p~n", [{El, lists:last(array:get(array:get(El-1, ASTDFS)-1, NodesToAST)), lists:last(array:get(array:get(El + 1-1, ASTDFS)-1, NodesToAST))}]), false end andalso PathCheck(El-1) end end(array:size(IdxDFS) - 1) andalso
	fun MetaCheck(El) -> if El =:= 0 -> true; true -> lists:all(fun(Elem) -> Elem =:= {} orelse element(1, dogetgraphpath(AST, Elem, 1)) =:= graphdata end, array:get(array:get(El-1, ASTDFS)-1, NodesToAST)) andalso MetaCheck(El-1) end end(array:size(ASTDFS)).
	
getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, Node, ConsiderChild) ->
	XOrig = lists:last(array:get(Node-1, NodesToAST)), X = tuple_drop_n(XOrig, 1),
	%DFS = element(1, lists:unzip(lists:sort(fun({_, [A|_]}, {_, [B|_]}) -> A =< B end, lists:zip(lists:seq(1, length(NodesToAST)), NodesToAST)))),
	Nxt = fun TravASTDFS(E) -> case E > array:size(ASTDFS) of true -> []; _ -> El = array:get(E-1, ASTDFS), Z = lists:last(array:get(El-1, NodesToAST)),
		case tup_prefix(X, Z, tuple_size(X)) andalso if ConsiderChild -> tuple_size(X) + 1 =/= tuple_size(Z) orelse (element(tuple_size(XOrig), XOrig) >= element(tuple_size(Z), Z));
			true -> element(tuple_size(XOrig), XOrig) >= element(tuple_size(X) + 1, Z) end of true -> TravASTDFS(E+1); _ -> El end end end(array:get(Node-1, IdxDFS)+1),
	case Nxt =:= [] orelse not tup_prefix(X, lists:last(array:get(Nxt-1, NodesToAST)), tuple_size(X)) of true -> length(element(element(tuple_size(X), X), dogetgraphpath(AST, tuple_drop_n(X, 1), 1)));
		_ -> element(tuple_size(X) + 1, hd(array:get(Nxt-1, NodesToAST))) - 1 end
	%io:format("~p~n", [NodesToAST]),
	%Next = lists:append(lists:map(fun (Y) -> lists:filtermap(fun (Z) -> case lists:prefix(X, Z) andalso if ConsiderChild -> length(X) + 1 =:= length(Z) andalso (lists:last(lists:last(lists:nth(Node, NodesToAST))) < lists:last(Z)); true -> (lists:last(lists:last(lists:nth(Node, NodesToAST))) < lists:nth(length(X) + 1, Z)) end of true ->
		%{ true, lists:nth(length(X) + 1, Z) }; _ -> false end end, Y) end, lists:delete(lists:nth(Node, NodesToAST), NodesToAST))),
	%if length(Next) =:= 0 -> length(element(lists:last(X), getgraphpath(AST, lists:droplast(X)))); true -> lists:min(Next) - 1 end.
.

%getgraphpathparentlength(AST, NodesToAST, Node) ->
%	X = lists:droplast(lists:droplast(lists:droplast(lists:last(lists:nth(Node, NodesToAST))))),
%	length(element(lists:last(X), getgraphpath(AST, lists:droplast(X)))).

%getgraphpathparentelems(AST, NodesToAST, Node) ->
%	X = lists:droplast(lists:droplast(lists:droplast(lists:last(lists:nth(Node, NodesToAST))))),
%	[X ++ [Y] || Y <- lists:seq(1, length(element(lists:last(X), getgraphpath(AST, lists:droplast(X)))))].

%reduce_disp_graph_data({AST, [], _}) -> AST;
%reduce_disp_graph_data({AST, NodesToAST, _}) ->
%	reduce_disp_graph_data({if hd(NodesToAST) =:= [{}] -> AST; true -> lists:foldr(fun(Elem, Acc) ->
%		Data = getgraphpath(Acc, Elem),
%		setgraphpath(Acc, Elem, setelement(5, setelement(3, Data, lists:filter(fun(El) -> El =/= [] end, element(3, Data))),
%			lists:filter(fun(El) -> El =/= [] end, element(5, Data)))
%			) end, AST, hd(NodesToAST)) end, tl(NodesToAST)}).

%addtolistoflists(Index, List, Val) ->
%  if Index > length(List) -> List ++ lists:duplicate(Index - length(List) - 1, []) ++ [[Val]];
%	true -> El = lists:nth(Index, List), case lists:member(Val, El) of true -> List; _ -> setnth(Index, List, [Val|El]) end
%  end.

%addtolistoflistsend(Index, List, Val) ->
%  if
%	Index > length(List) -> List ++ lists:duplicate(Index - length(List) - 1, []) ++ [[Val]];
%	true -> El = lists:nth(Index, List), case lists:member(Val, El) of true -> List; _ -> setnth(Index, List, El ++ [Val]) end
%  end
%.

%removefromlistoflists(Index, List, Val) ->
%	El = lists:nth(Index, List),
%	case not lists:member(Val, El) of true -> error({List, Val}); _ -> true end,
%	setnth(Index, List, lists:delete(Val, El)).

%addtolist(Index, List, Val) ->
%  if Index > length(List) -> List ++ lists:duplicate(Index - length(List) - 1, 0) ++ [Val];
%	true -> setnth(Index, List, Val)
%  end.

index_from_search_tree(Tree) ->
	list_to_tuple(lists:sort(fun (A, B) -> element(A, Tree) =< element(B, Tree) end, lists:seq(1, tuple_size(Tree)))).
	%list_to_tuple(element(2, lists:unzip(lists:sort(lists:zip(tuple_to_list(Tree), lists:seq(1, tuple_size(Tree))))))).

bfs(Succ, FinalBFS, BFS, NewSet) ->
	NextBFS = gb_sets:union(BFS, NewSet),
	NextSet = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, NextBFS) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [array:get(El-1, Succ)|Acc] end, [], NewSet)))),
	case gb_sets:size(NextSet) of 0 -> lists:append(lists:reverse([gb_sets:to_list(NewSet)|FinalBFS]));
	_ -> bfs(Succ, [gb_sets:to_list(NewSet)|FinalBFS], NextBFS, NextSet) end
.

do_bfs({_, Succ, _, _, _, _, _, _}, RootIdx) ->
	list_to_tuple(bfs(Succ, [], gb_sets:new(), gb_sets:from_list([RootIdx])))
.

do_interval_dfs({_, Succ, _, _, _, _, _, _}, RootIdx) ->
	element(1, interval_dfs({{array:new(array:size(Succ), {default,[]}), array:new(array:size(Succ), {default,[]})}, 1, 1, Succ}, RootIdx))
.
interval_edge_dfs({{RDFS, DFS}, RVal, Val, Succ}, CurNode) ->
	case CurNode > array:size(Succ) orelse gb_sets:size(array:get(CurNode-1, Succ)) =:= 0 of
		true -> {{RDFS, DFS}, RVal, Val, Succ};
		false -> {CurEdge, Del} = gb_sets:take_largest(array:get(CurNode-1, Succ)),
			interval_edge_dfs(interval_dfs({{RDFS, DFS}, RVal, Val, array:set(CurNode-1, Del, Succ)}, CurEdge), CurNode)
	end
.
interval_dfs({{RDFS, DFS}, RVal, Val, Succ}, CurNode) ->
	case CurNode =< array:size(DFS) andalso array:get(CurNode-1, DFS) =/= [] of
		true -> {{RDFS, DFS}, RVal, Val, Succ};
		false -> {{NewRDFS, NewDFS}, NewRVal, NewVal, NewSucc} = interval_edge_dfs({{RDFS, case CurNode =< array:size(DFS) of true -> array:set(CurNode-1, Val, DFS);
				_ -> array:set(CurNode-1, Val, array:resize(CurNode, DFS)) end}, RVal, Val + 1, Succ}, CurNode),
					{{array:set(CurNode-1, NewRVal, NewRDFS), NewDFS}, NewRVal + 1, NewVal, NewSucc}
	end
.

do_dfs(Succ, RootIdx) -> element(1, dfs({array:new(array:size(Succ), {default,[]}), 1, Succ}, RootIdx)).
edge_dfs({DFS, Val, Succ}, CurNode) ->
	case CurNode > array:size(Succ) orelse gb_sets:size(array:get(CurNode-1, Succ)) =:= 0 of
		true -> {DFS, Val, Succ};
		false -> {CurEdge, Del} = gb_sets:take_smallest(array:get(CurNode-1, Succ)), edge_dfs(dfs({DFS, Val, array:set(CurNode-1, Del, Succ)}, CurEdge), CurNode)
	end
.
dfs({DFS, Val, Succ}, CurNode) ->
	case CurNode =< array:size(DFS) andalso array:get(CurNode-1, DFS) =/= [] of
		true -> {DFS, Val, Succ};
		false -> edge_dfs({case CurNode =< array:size(DFS) of true -> array:set(CurNode-1, Val, DFS);
				_ -> array:set(CurNode-1, Val, array:resize(CurNode, DFS)) end, Val + 1, Succ}, CurNode)
	end
.

simple_link(V, W, {Semi, Idom, Ancestor, Best, Bucket}) ->
	{Semi, Idom, array:set(W-1, V, Ancestor), Best, Bucket}.
simple_evalhf(Semi, Ancestor, V, A) ->
	case A =/= 0 of
		true -> simple_evalhf(Semi, Ancestor,
			case array:get(V-1, Semi) > array:get(A-1, Semi) of 
				true -> A;
				false -> V
			end, array:get(A-1, Ancestor));
		false -> V
	end
.
simple_eval(V, {Semi, _, Ancestor, _, _}) -> simple_evalhf(Semi, Ancestor, V, array:get(V-1, Ancestor)).
%ds_compress(V, {Semi, Idom, Ancestor, Best, Bucket}) ->
%	A = element(V, Ancestor),
%	case element(A, Ancestor) =:= 0 of
%		true -> {Semi, Idom, Ancestor, Best, Bucket};
%		false ->
%			{_, _, NewAncestor, NewBest, _} = ds_compress(A, {Semi, Idom, Ancestor, Best, Bucket}),
%			{Semi, Idom, setnth(V, NewAncestor, element(A, NewAncestor)),
%					case element(element(V, NewBest), Semi) > element(element(A, NewBest), Semi) of
%						true -> setnth(V, NewBest, element(A, NewBest));
%						false -> NewBest end, Bucket}
%	end
%.
%ds_link(V, W, {Semi, Idom, Ancestor, Best, Bucket}) -> true. %not implemented yet, need size and child lists...
%ds_eval(V, {Semi, Idom, Ancestor, Best, Bucket}) ->
%	case element(V, Ancestor) =:= 0 of
%		true -> {element(V, Best), Ancestor, Best};
%		false -> {_, _, NewAncestor, NewBest, _} = ds_compress(V, {Semi, Idom, Ancestor, Best, Bucket}),
%			{element(case element(element(V, NewAncestor), Semi) < element(element(V, NewBest), Semi) of true -> element(V, NewAncestor); false -> V end, NewBest), NewAncestor, NewBest}
%	end
%.
%simple_evalc(V, {Semi, Idom, Ancestor, Best, Bucket}) ->
%	case element(V, Ancestor) =:= 0 of
%		true -> {V, Ancestor, Best};
%		false -> {_, _, NewAncestor, NewBest, _} = ds_compress(V, {Semi, Idom, Ancestor, Best, Bucket}),
%			{element(V, NewBest), NewAncestor, NewBest}
%	end
%.

do_tarjan_immdom({Pred, Succ, _, _, _, _, _, _}, RootIdx) -> %Succ, Pred
	DFS = do_dfs(Succ, RootIdx), DFSTup = list_to_tuple(array:to_list(DFS)), DFSSize = tuple_size(DFSTup),
	IdxDFS = index_from_search_tree(DFSTup), %io:format("~p~n", [{Pred, Succ, RootIdx, TupDFS, TupIdxDFS}]),
	ZeroTup = array:new(DFSSize, {default,0}),
	element(2, tarjan_immdom4(IdxDFS, Pred,
		tarjan_immdom1({DFSTup, IdxDFS}, Pred, {DFS, ZeroTup, ZeroTup, array:from_list(lists:seq(1, DFSSize)), array:new(DFSSize, {default,[]})},
			DFSSize), RootIdx, 2))
.

to_gb_sets(TupList) -> array:map(fun (El,_) -> gb_sets:from_list(element(El+1, TupList)) end, array:new(tuple_size(TupList))).

%slightly out of order for testing the DFS and its parent in the tree
-define(LTPaperSucc, to_gb_sets({[4, 3, 2], [3, 5], [1, 6, 2, 5], [7, 8], [13], [9], [10], [10, 11], [6, 12], [12], [10], [1, 10], [9]})).
%Lengauer-Tarjan paper example:
check_tarjan() ->
	Idom = [0, 1, 1, 1, 1, 1, 4, 4, 1, 1, 8, 1, 5],
	[array:to_list(do_tarjan_immdom({succ_to_pred(?LTPaperSucc), ?LTPaperSucc, {}, {}, {}, {}, {}, {}}, 1)) =:= Idom,
	 array:to_list(do_tarjan_immdom(rev_interval({succ_to_pred(?LTPaperSucc), ?LTPaperSucc, {}, {}, {}, {}, {}, {}}), 1))
			 =:= Idom]. %Semi also same as Idom
check_dfs() ->
	DFSOrder = {1, 11, 8, 2, 12, 9, 3, 6, 10, 4, 7, 5, 13}, %requires edge ordering for exact match
	[list_to_tuple(array:to_list(do_dfs(element(2, {succ_to_pred(?LTPaperSucc), ?LTPaperSucc, {}, {}, {}, {}, {}, {}}), 1))), DFSOrder,
	do_dfs_parent({DFSOrder, index_from_search_tree(DFSOrder)}, succ_to_pred(?LTPaperSucc), [], 0) =:= [0, 3, 1, 1, 2, 3, 4, 4, 6, 7, 8, 10, 5]].

do_dfs_parent({DFS, IdxDFS}, Pred, Parent, LenPar) ->
	%LenPar = length(Parent),
	case tuple_size(DFS) of LenPar -> lists:reverse(Parent);
	_ ->
		case LenPar =:= 0 orelse hd(Parent) =:= 0 orelse gb_sets:is_element(hd(Parent), array:get(LenPar-1, Pred)) of
			true -> do_dfs_parent({DFS, IdxDFS}, Pred, [if LenPar =:= 0 -> 0; true -> element(element(LenPar + 1, DFS) - 1, IdxDFS) end|Parent], LenPar + 1);
			false -> do_dfs_parent({DFS, IdxDFS}, Pred, [element(element(hd(Parent), DFS) - 1, IdxDFS)|tl(Parent)], LenPar)
		end
	end.

do_get_dfs_parent({DFS, IdxDFS}, Pred, Node) -> get_dfs_parent({DFS, IdxDFS}, array:get(Node-1, Pred), element(element(Node, DFS) - 1, IdxDFS)).
get_dfs_parent({DFS, IdxDFS}, Preds, Idx) ->
	case Idx =:= 0 orelse gb_sets:is_element(Idx, Preds) of
		true -> Idx;
		false -> get_dfs_parent({DFS, IdxDFS}, Preds, element(element(Idx, DFS) - 1, IdxDFS))
	end.

tarjan_immdom4(IdxDFS, Pred, {Semi, Idom, Ancestor, Best, Bucket}, RootIdx, W) ->
	%io:format("~p~n", [{DFS, Pred, {Semi, Idom, Ancestor, Best, Bucket}, W}]),
	case
		tuple_size(IdxDFS) + 1 of W -> {Semi, array:set(RootIdx-1, 0, Idom), Ancestor, Best, Bucket};
		_ -> DepthW = element(W, IdxDFS),
			tarjan_immdom4(IdxDFS, Pred, {Semi,
				case array:get(DepthW-1, Idom) =/= element(array:get(DepthW-1, Semi), IdxDFS) of
					true -> array:set(DepthW-1, array:get(array:get(DepthW-1, Idom)-1, Idom), Idom);
					false -> Idom
				end, Ancestor, Best, Bucket}, RootIdx, W + 1)
	end
.

tarjan_immdom3({Semi, Idom, Ancestor, Best, Bucket}, P, []) ->
	{Semi, Idom, Ancestor, Best, array:set(P-1, [], Bucket)};
tarjan_immdom3({Semi, Idom, Ancestor, Best, Bucket}, P, [V|Vs]) ->
	U = simple_eval(V, {Semi, Idom, Ancestor, Best, Bucket}),
	tarjan_immdom3({Semi, array:set(V-1,
		case array:get(U-1, Semi) < array:get(V-1, Semi) of
			true -> U;
			false -> P
		end, Idom), Ancestor, Best, Bucket}, P, Vs)
.

tarjan_immdom2(IdxDFS, {Semi, Idom, Ancestor, Best, Bucket}, W, P, {0, nil}) -> %gb_sets:new() =:= {0, nil}
	Idx = element(array:get(W-1, Semi), IdxDFS),
	NewBucket = array:set(Idx-1, [W|array:get(Idx-1, Bucket)], Bucket),
	simple_link(P, W, {Semi, Idom, Ancestor, Best, NewBucket});
tarjan_immdom2(IdxDFS, {Semi, Idom, Ancestor, Best, Bucket}, W, P, VVs) ->
	V = gb_sets:smallest(VVs),
	U = simple_eval(V, {Semi, Idom, Ancestor, Best, Bucket}),
	USemi = array:get(U-1, Semi),
	NewSemi = case array:get(W-1, Semi) > USemi of
		true -> array:set(W-1, USemi, Semi);
		false -> Semi end,
	tarjan_immdom2(IdxDFS, {NewSemi, Idom, Ancestor, Best, Bucket}, W, P, gb_sets:del_element(V, VVs))
.

tarjan_immdom1({DFS, IdxDFS}, Pred, {Semi, Idom, Ancestor, Best, Bucket}, W) ->
	%io:format("~p~n", [{DFS, Pred, {Semi, Idom, Ancestor, Best, Bucket}, W}]),
	if
		W =:= 1 -> {Semi, Idom, Ancestor, Best, Bucket};
		true -> DepthW = element(W, IdxDFS), P = do_get_dfs_parent({DFS, IdxDFS}, Pred, DepthW),
			{NewSemi, _, NewAncestor, NewBest, NewBucket} =
				tarjan_immdom2(IdxDFS, {Semi, Idom, Ancestor, Best, Bucket}, DepthW, P, array:get(DepthW-1, Pred)),
			tarjan_immdom1({DFS, IdxDFS}, Pred,
				tarjan_immdom3({NewSemi, Idom, NewAncestor, NewBest, NewBucket}, P, array:get(P-1, NewBucket)), W - 1)
	end
.

%compute_j_edges() ->
%.

succ_to_pred(Succ) ->
	array:foldl(fun (Idx, Elem, Acc) -> gb_sets:fold(fun (E, Ac) -> array:set(E-1, gb_sets:add_element(Idx+1, array:get(E-1, Ac)), Ac) end, Acc, Elem) end,
		array:new(array:size(Succ), {default,gb_sets:new()}), Succ)
.

get_j_succ(Succ, Dom) ->
	array:map(fun (Elem, _) -> gb_sets:fold(fun (E, Ac) -> case lists:member(Elem+1, pathtodomonly(Dom, E)) of true -> Ac;
		_ -> gb_sets:add_element(E, Ac) end end, gb_sets:new(), array:get(Elem, Succ)) end, array:new(array:size(Succ)))
.

check_idf() ->
	%Paper example: 17 is Start, 16 is End
	PaperSucc = to_gb_sets({[2, 3, 4], [4, 7], [9], [5], [6], [2, 8], [8], [7, 15], [10, 11], [12], [12], [13], [3, 14, 15], [12], [16], [], [1, 16]}),
	PaperDom = array:from_list([17, 1, 1, 1, 4, 5, 1, 1, 3, 9, 9, 9, 12, 13, 1, 17, 0]),
	PaperJEdges = to_gb_sets({[], [4, 7], [], [], [], [2, 8], [8], [7, 15], [], [12], [12], [], [3, 15], [12], [16], [], []}),
	%ladder example: 8 is Start, 7 is End
	LadderSucc = to_gb_sets({[3], [3, 4], [5], [5, 6], [7], [7], [], [1, 2]}), LaddDom = array:from_list([8, 8, 8, 2, 8, 4, 8, 0]),
	LaddJEdges = to_gb_sets({[3], [3], [5], [5], [7], [7], [], []}),
	[array:to_list(do_tarjan_immdom({succ_to_pred(PaperSucc), PaperSucc, {}, {}, {}, {}, {}, {}}, 17)) =:= array:to_list(PaperDom),
	cmp_edgeset(get_j_succ(PaperSucc, PaperDom), PaperJEdges),
	lists:sort(compute_idf(d_to_dom(PaperDom, PaperJEdges, make_dom_tree(PaperDom), dom_depth(PaperDom)), gb_sets:from_list([5, 13]))) =:= lists:sort([15, 3, 12, 8, 2] ++ [7, 4, 16]),
	array:to_list(do_tarjan_immdom({succ_to_pred(LadderSucc), LadderSucc, {}, {}, {}, {}, {}, {}}, 8)) =:= array:to_list(LaddDom),
	cmp_edgeset(get_j_succ(LadderSucc, LaddDom), LaddJEdges),
	lists:sort(compute_idf(d_to_dom(LaddDom, LaddJEdges, make_dom_tree(LaddDom), dom_depth(LaddDom)), gb_sets:from_list([8, 2]))) =:= lists:sort([7, 5, 3])].
	
visit(Dom, AlphaNodes, PiggyBank, Nodes, IDF, X, CurrentRootLevel) ->
	#{X := XDom} = Dom,
	gb_sets:fold(fun (Y, {AccPiggyBank, AccNodes, AccIDF}) ->
		case AccNodes of #{Y := _} -> {AccPiggyBank, AccNodes, AccIDF};
			_ -> visit(Dom, AlphaNodes, AccPiggyBank, AccNodes#{Y => true}, AccIDF, Y, CurrentRootLevel)
			end end,
		gb_sets:fold(fun (Y, {AccPiggyBank, AccNodes, AccIDF}) ->
			#{Y := {_,_,_,YDepth}} = Dom,
			case YDepth =< CurrentRootLevel andalso case AccIDF of #{Y := _} -> false; _ -> true end of true ->
			{case gb_sets:is_element(Y, AlphaNodes) of false ->
				setelement(YDepth, AccPiggyBank, [Y|element(YDepth, AccPiggyBank)]);
			 _ -> AccPiggyBank end,
				AccNodes, AccIDF#{Y => true}};
			_ -> {AccPiggyBank, AccNodes, AccIDF} end
			end, {PiggyBank, Nodes, IDF}, element(2, XDom)), element(3, XDom))
	%Succ(x) - traverses the dominator sub-tree SubTree(CurentRoot) in a top-down fashion, also "peeks" at all nodes that are connected through J-edges
.

%getnode
compute_idf_iterate(Dom, AlphaNodes, PiggyBank, Nodes, IDF, CurrentLevel) ->
	if element(CurrentLevel, PiggyBank) =:= [] -> if CurrentLevel =:= 1 -> maps:keys(IDF);
	true -> compute_idf_iterate(Dom, AlphaNodes, PiggyBank, Nodes, IDF, CurrentLevel-1)
	end;
	%NextLevel = lists:dropwhile(fun (El) -> element(El, PiggyBank) =:= [] end, lists:seq(CurrentLevel, 1, -1)),
		%io:format("~p~n", [{CurrentLevel, NextLevel, PiggyBank}]),
	%if NextLevel =:= [] -> IDF;
	true -> X = element(CurrentLevel, PiggyBank), NxX = hd(X), #{NxX := {_, _, _, XLvl}} = Dom,
	{NewPiggyBank, NewNodes, NewIDF} =
		visit(Dom, AlphaNodes, setelement(CurrentLevel, PiggyBank, tl(X)),
			Nodes#{NxX => true},
			IDF, NxX, XLvl),
	compute_idf_iterate(Dom, AlphaNodes, NewPiggyBank, NewNodes, NewIDF, CurrentLevel) end
.

%need to manage the dominator tree depth for efficiency
compute_idf(Dom, AlphaNodes) ->
	%io:format("~p~n", [Nodes]),
	%MaxDepth = tup_max(DomDepth),
	ASize = gb_sets:size(AlphaNodes),
	MaxDepth = if ASize =:= 1 -> A = gb_sets:smallest(AlphaNodes), #{A := {_,_,_,ALvl}} = Dom, ALvl;
	true -> gb_sets:fold(fun (El, Acc) -> #{El := {_,_,_,ElLvl}} = Dom, max(ElLvl, Acc)
		end, 0, AlphaNodes) end,
	compute_idf_iterate(Dom, AlphaNodes, if ASize =:= 1 -> setelement(MaxDepth, erlang:make_tuple(MaxDepth, []), [gb_sets:smallest(AlphaNodes)]); true ->
		gb_sets:fold(fun (El, Acc) -> #{El := {_,_,_,Depth}} = Dom,
			setelement(Depth, Acc, [El|element(Depth, Acc)])
			end, erlang:make_tuple(MaxDepth, []), AlphaNodes) end,
		#{}, #{}, MaxDepth)
.

d_to_dom(Dom, J, DomTree, DomDepth) -> lists:foldl(fun (El, Acc) -> Acc#{El => {array:get(El-1, Dom), array:get(El-1, J), array:get(El-1, DomTree), array:get(El-1, DomDepth)}} end, #{}, lists:seq(1, array:size(Dom))).
dom_to_d(Dom) -> maps:fold(fun (Idx, {D, J, DomTree, DomDepth}, {AccD, AccJ, AccDomTree, AccDomDepth}) -> {array:set(Idx-1, D, AccD), array:set(Idx-1, J, AccJ), array:set(Idx-1, DomTree, AccDomTree), array:set(Idx-1, DomDepth, AccDomDepth)} end,
	{array:new(), array:new(), array:new(), array:new()}, Dom).
make_dom_tree(Dom) -> array:foldl(fun (X, _, Acc) -> N = array:get(X, Dom), if N =:= 0 -> Acc; true -> array:set(N-1, gb_sets:add_element(X+1, array:get(N-1, Acc)), Acc) end end, array:new(array:size(Dom), {default,gb_sets:new()}), Dom).
dom_depth(Dom) -> array:map(fun (_,El) -> if El =:= 0 -> 1; true -> length(pathtodomonly(Dom, El)) + 1 end end, Dom).
%tup_max(Tup) -> array:foldl(fun (_, El, Acc) -> if Acc =:= [] orelse El =/= [] andalso El > Acc -> El; true -> Acc end end, [], Tup).
cmp_edgeset(_A, _B, 0) -> true;
cmp_edgeset(A, B, El) -> gb_sets:size(array:get(El-1, A)) =:= gb_sets:size(array:get(El-1, B)) andalso gb_sets:is_subset(array:get(El-1, A), array:get(El-1, B)) andalso cmp_edgeset(A, B, El-1). 
cmp_edgeset(A, B) -> array:size(A) =:= array:size(B) andalso cmp_edgeset(A, B, array:size(A)).
get_edgeset(A) -> array:to_list(array:map(fun (_,El) -> gb_sets:to_list(El) end, A)).
edgeset_to_dot(A, Var) -> io_lib:format("digraph {~n\tgraph [dpi=150];~n" ++ lists:append(lists:map(fun (El) -> lists:append(lists:map(fun (E) -> "\t" ++ Var ++ integer_to_list(El) ++ " -> " ++ Var ++ integer_to_list(E) ++ ";~n" end, gb_sets:to_list(array:get(El-1, A)))) end, lists:seq(1, array:size(A)))) ++ "}~n", []).

paper_rev_graph() -> Succ = to_gb_sets({[4], [3], [], [5, 6], [7], [9, 11], [8, 9], [3], [10], [3], [2]}),
	{Idom, _, RevGraph} = get_post_dom({succ_to_pred(Succ), Succ, {}, {}, {}, {}, {}, {}}),
	io:format("~s", [edgeset_to_dot(Succ, "v") ++ edgeset_to_dot(element(2, RevGraph), "w") ++ edgeset_to_dot(make_dom_tree(Idom), "i")]).
%nca(Dom, Xd, Yd) -> %with dominator depth, this could be very efficiently implemented
	%L = lists:reverse(pathtodom(Dom, Xd)), Z = lists:reverse(pathtodom(Dom, Yd)),
	%lists:nth(lists:last(lists:takewhile(fun (N) -> lists:nth(N, Z) =:= lists:nth(N, L) end, lists:seq(1, erlang:min(length(L), length(Z))))), L).
	
nca(Dom, Xd, Yd) ->
	#{Xd := {_,_,_,XDepth}} = Dom, #{Yd := {_,_,_,YDepth}} = Dom,
	case XDepth > YDepth of true ->
		nca_rec(Dom, fun LeftNCA(Acc, El) -> if El =:= 0 -> Acc; true -> #{Acc := {X,_,_,_}} = Dom, LeftNCA(X, El-1) end end(Xd, XDepth - YDepth), Yd);
	_ -> nca_rec(Dom, Xd, fun RightNCA(Acc, El) -> if El =:= 0 -> Acc; true -> #{Acc := {X,_,_,_}} = Dom, RightNCA(X, El-1) end end(Yd, YDepth - XDepth)) end.
nca_rec(Dom, Xd, Yd) ->
	if Xd =:= Yd -> Xd; true -> #{Xd := {X,_,_,_}} = Dom, #{Yd := {Y,_,_,_}} = Dom, nca_rec(Dom, X, Y) end.

%Paper example: 10 is Start, 9 is End
check_sgl() ->
	PaperSucc = to_gb_sets({[2, 3], [9], [4, 5, 8], [6], [6], [7], [3, 8], [9], [], [1, 9]}),
	PaperDom = array:from_list([10, 1, 1, 3, 3, 3, 6, 3, 10, 0]), PaperDomDepth = dom_depth(PaperDom),
	PaperJEdges = to_gb_sets({[], [9], [], [6], [6], [], [3, 8], [9], [], []}),
	NextSucc = array:set(2-1, gb_sets:add_element(4, array:get(2-1, PaperSucc)), PaperSucc),
	NextDom = array:from_list([10, 1, 1, 1, 3, 1, 6, 1, 10, 0]), NextDomDepth = dom_depth(NextDom),
	NextJEdges = to_gb_sets({[], [9, 4], [4, 8], [6], [6], [], [3, 8], [9], [], []}),
	[array:to_list(do_tarjan_immdom({succ_to_pred(PaperSucc), PaperSucc, {}, {}, {}, {}, {}, {}}, 10)) =:= array:to_list(PaperDom),
	cmp_edgeset(get_j_succ(PaperSucc, PaperDom), PaperJEdges),
	case dom_to_d(sreedhar_gao_lee_add({succ_to_pred(NextSucc), NextSucc, {}, {}, {}, {}, {}, {}}, d_to_dom(PaperDom, PaperJEdges, make_dom_tree(PaperDom), dom_depth(PaperDom)), 2, 4)) of
		{NextDom, CheckJ, Tree, NextDomDepth} -> cmp_edgeset(CheckJ, NextJEdges) andalso cmp_edgeset(Tree, make_dom_tree(NextDom)); _ -> false end, %note that edge 2->9 J-edge is missing from the paper image
	cmp_edgeset(get_j_succ(NextSucc, NextDom), NextJEdges),
	case dom_to_d(sreedhar_gao_lee_remove({succ_to_pred(PaperSucc), PaperSucc, {}, {}, {}, {}, {}, {}}, d_to_dom(NextDom, NextJEdges, make_dom_tree(NextDom), dom_depth(NextDom)), 2, 4)) of
		{PaperDom, CheckJ, Tree, PaperDomDepth} -> cmp_edgeset(CheckJ, PaperJEdges) andalso cmp_edgeset(Tree, make_dom_tree(PaperDom)); _ -> false end].

sreedhar_gao_lee_add(Graph, Dom, Xd, Yd) ->
	%O(log10(n)) complexity of array lookup presumably, 
	%IsSmall = round(math:log10(array:size(DomTree))),
	Zd = nca(Dom, Xd, Yd), #{Zd := {_,_,_,ZdLevel}} = Dom,
	DomAffected = gb_sets:from_list(lists:filter(fun (Wd) -> #{Wd := {_,_,_,WdLvl}} = Dom, WdLvl > ZdLevel + 1 end, [Yd|compute_idf(Dom, gb_sets:from_list([Yd]))])),
	NextJ = if (Zd =/= Xd) -> #{Xd := XdDom} = Dom, Dom#{Xd => setelement(2, XdDom, gb_sets:add_element(Yd, element(2, XdDom)))}; true -> Dom end,
	#{Zd := {_,_,ZdTree,_}} = NextJ,
	NewDom = gb_sets:fold(fun (Wd, AccDom) ->
		fun RecDomUpdate(Node, A) -> #{Node := {_,_,NodeTree,_}} = AccDom, gb_sets:fold(fun (El, Acc) -> #{El := ElDom} = Acc, #{Node := {_,_,_,NodeDep}} = Acc, RecDomUpdate(El, Acc#{El => setelement(4, ElDom, NodeDep + 1)}) end, A, NodeTree) end(Wd, AccDom) end,
		begin {AcDom, AcZdTree} =
			gb_sets:fold(fun (Wd, {AccDom, AccZdTree}) -> #{Wd := {Ud,WdJ,WdT,_}} = AccDom,
			if Ud =/= Zd -> #{Ud := {UdD, UdJ, UdT, UdDp}} = AccDom,
				{AccDom#{Wd => {Zd, WdJ, WdT, ZdLevel + 1},
				Ud => {UdD, case gb_sets:is_element(Wd, get_succs(Ud, Graph)) of true -> gb_sets:add_element(Wd, UdJ); _ -> UdJ end, gb_sets:del_element(Wd, UdT), UdDp}},
				gb_sets:add_element(Wd, AccZdTree)}; true -> {AccDom, AccZdTree}
			end end, {NextJ, ZdTree}, DomAffected), #{Zd := ZdDom} = AcDom,
			AcDom#{Zd => setelement(3, ZdDom, AcZdTree)} end, DomAffected),
	%{D, J, DTree, DDepth} = dom_to_d(NewDom),
	%case cmp_edgeset(make_dom_tree(D), DTree) of false -> error({get_edgeset(make_dom_tree(D)), get_edgeset(DTree)}); _ -> true end,
	%case cmp_edgeset(get_j_succ(element(2, Graph), D), J) of false -> error({get_edgeset(get_j_succ(element(2, Graph), D)), get_edgeset(J)}); _ -> true end,
	%case dom_depth(D) =:= DDepth of false -> error({dom_depth(D), DDepth}); _ -> true end,
	NewDom
	%lists:foldl(fun (Wd, Acc) -> true end, {Dom, J}, DomAffected)
.

sreedhar_gao_lee_remove_affected(Graph, PossiblyAffected, PseudoDom, DomSt, DomDy, Xd, Yd, DChange) ->
	{NewDomDy, Changes} = gb_sets:fold(fun (Wd, {AccDomDy, AccChange}) ->
			#{Wd := WdDomDy} = AccDomDy,
			{PreDomTemp, NextDomDy, PChange} = gb_sets:fold(fun (Pf, {AcDomTemp, AcDomDy, AcChange}) ->
				%io:format("~p~n", [{Wd, Pf, AcDomTemp, element(PfIdx, DomSt), element(PfIdx, AcDomDy)}]),
				%case maps:get(Pf, ZdSubtreeIdx, false) of false -> {AcDomTemp, AcDomDy}; I ->
				#{Pf := PDy} = AcDomDy,
				{NewDomDy, PfDy, PfChange} = case PseudoDom of #{Pf := P}  ->
					%sdom refers to the original possibly affected pseudo dominator at least until completion of first iteration!
					#{P := Ud} = AcDomDy, 
					%io:format("~p~n", [{Pf, AnySdom, gb_sets:to_list(Ud), PfIdx, gb_sets:to_list(CurDom), get_edgeset(AcDomDy)}]),
				{AcDomDy#{Pf => Ud}, Ud, case Ud =:= [] orelse PDy =:= [] orelse sets:size(Ud) =/= sets:size(PDy) orelse case AcChange of #{P := _} -> true; _ -> false end of true -> AcChange#{Wd => true}; _ -> AcChange end};
				_ -> {AcDomDy, PDy, case PDy =:= [] orelse case AcChange of #{Pf := _} -> true; _ -> false end of true -> AcChange#{Wd => true}; _ -> AcChange end} end,
				%io:format("~p~n", [{AcDomTemp, Pf, DomSt, NewDomDy}]),
				#{Pf := PSt} = DomSt,
				NewISect = if PfDy =:= [] -> []; true -> {PSt, PfDy} end,
				{if NewISect =:= [] -> AcDomTemp; AcDomTemp =:= [] -> [NewISect]; true -> [NewISect|AcDomTemp] end,
				 NewDomDy, PfChange} end, {[], AccDomDy, case WdDomDy of [] -> AccChange; _ -> maps:remove(Wd, AccChange) end}, get_preds(Wd, Graph)),
			case PChange of #{Wd := _} ->
			DomTemp = if PreDomTemp =:= [] -> []; true -> %gb_sets:from_list(element(1, lists:foldl(fun (El, {Acc, AccIters}) ->
				%case fun CheckLists(Checked, ToCheck) -> if ToCheck =:= [] -> {true, Checked}; hd(hd(ToCheck)) =:= [] -> {false, Checked ++ ToCheck};
					%El =:= hd(hd(ToCheck)) -> CheckLists([tl(hd(ToCheck))|Checked], tl(ToCheck));
					%El > hd(hd(ToCheck)) -> CheckLists(Checked, [tl(hd(ToCheck))|tl(ToCheck)]);
					%true -> {false, Checked ++ ToCheck} end end([], AccIters) of {true, NewIt} -> {[El|Acc], NewIt}; {false, NewIt} -> {Acc, NewIt} end end,
					%{[], lists:map(fun (El) -> gb_sets:to_list(El) end, tl(PreDomTemp))}, gb_sets:to_list(hd(PreDomTemp)))))
					sets:intersection(lists:sort(fun (A, B) -> sets:size(A) =< sets:size(B) end, lists:map(fun ({A, B}) -> sets:union(A, B) end, PreDomTemp))) end, %intersection
			NextDomTemp = if DomTemp =:= [] -> []; true -> sets:add_element(Wd, DomTemp) end,
			%io:format("~p~n", [{Wd, gb_sets:to_list(get_preds(Wd, Graph)), gb_sets:to_list(DomTemp), get_edgeset(setelement(WdIdx, NextDomDy, NextDomTemp))}]),
			{NextDomDy#{Wd => NextDomTemp}, case WdDomDy =:= [] orelse
			 sets:size(NextDomTemp) =/= sets:size(WdDomDy) orelse
			 not sets:is_subset(NextDomTemp, WdDomDy) of true -> PChange; _ -> maps:remove(Wd, PChange) end}; _ -> {NextDomDy, PChange} end %AccChanges orelse }
		end, {DomDy, DChange}, PossiblyAffected),
		%io:format("~p~n", [NewDomDy]),
	if map_size(Changes) =/= 0 -> sreedhar_gao_lee_remove_affected(Graph, PossiblyAffected, PseudoDom, DomSt, NewDomDy, Xd, Yd, Changes); true -> NewDomDy end
.

tarjan_sgl_alt(Graph, ZdSubtreeIdx, ZdSubtree, Zd, Dom, DomAffected) ->
	NewPred = array:from_list(lists:map(fun (El) -> gb_sets:fold(fun (E, A) -> case ZdSubtreeIdx of #{E := X} -> gb_sets:add_element(X, A); _ -> A end end, gb_sets:new(), array:get(El-1, element(1, Graph))) end, gb_sets:to_list(ZdSubtree))),
	NewSucc = array:from_list(lists:map(fun (El) -> gb_sets:fold(fun (E, A) -> case ZdSubtreeIdx of #{E := X} -> gb_sets:add_element(X, A); _ -> A end end, gb_sets:new(), array:get(El-1, element(2, Graph))) end, gb_sets:to_list(ZdSubtree))),
	%io:format("~p~n", [{get_edgeset(NewPred), get_edgeset(NewSucc), maps:get(Zd, ZdSubtreeIdx), ZdSubtreeIdx}]),
	#{Zd := ZdIdx} = ZdSubtreeIdx,
	Doms = do_tarjan_immdom(setelement(2, setelement(1, Graph, NewPred), NewSucc), ZdIdx),
	%io:format("~p~n", [{Doms, gb_sets:to_list(DomAffected)}]),
	_NewDom = gb_sets:fold(fun (El, AccDom) -> #{El := ElIdx} = ZdSubtreeIdx,
		case array:get(ElIdx-1, Doms) of 0 -> AccDom; _ -> Up = lists:nth(array:get(ElIdx-1, Doms), gb_sets:to_list(ZdSubtree)),
		#{El := ElDom} = AccDom, Ud = element(1, ElDom), #{Up := UpDom} = AccDom, #{Ud := UdDom} = AccDom,
		AccDom#{El => setelement(4, setelement(1, ElDom, Up), element(4, UpDom) + 1),
			Up => if Up =/= Zd -> setelement(3, UpDom, gb_sets:add_element(El, element(3, UpDom))); true -> UpDom end,
			Ud => if Up =/= Zd -> setelement(3, UdDom, gb_sets:del_element(El, element(3, UdDom))); true -> UdDom end}
			end end, Dom, DomAffected)
.

sreedhar_gao_lee_remove(Graph, Dom, Xd, Yd) ->
	#{Yd := {_,_,_,YdLevel}} = Dom,
	IDF = compute_idf(Dom, gb_sets:from_list([Yd])),
	DomAffected = gb_sets:from_list(lists:filter(fun (Wd) -> case Dom of #{Wd := {_,_,_,YdLevel}} -> true; _ -> false end end, [Yd|IDF])),
	#{Yd := {Zd,_,_,_}} = Dom, %do_tarjan_immdom(Graph, Zd)...
	{DomSt, DomDy, PseudoDom} = fun DomRec(CurNode, CurDomPath, PseudoDom, CurDomSt, CurDomDy, CurPseudoDom) ->
		IsAffected = gb_sets:is_element(CurNode, DomAffected),
		NextDomPath = if IsAffected -> sets:new(); true -> sets:add_element(CurNode, CurDomPath) end,
		NextPseudo = if IsAffected -> CurNode; true -> PseudoDom end,
		#{CurNode := {_,_,CurNodeTree,_}} = Dom,
		gb_sets:fold(fun (El, {AccDomSt, AccDomDy, AccPseudoDom}) ->
			DomRec(El, NextDomPath, NextPseudo, AccDomSt, AccDomDy, AccPseudoDom) end, 
		{CurDomSt#{CurNode => if IsAffected -> sets:new(); true -> NextDomPath end},
		CurDomDy#{CurNode => if IsAffected orelse PseudoDom =/= [] -> []; true -> sets:new() end},
		if PseudoDom =/= [] -> CurPseudoDom#{CurNode => PseudoDom}; true -> CurPseudoDom end}, CurNodeTree)
		end(Zd, sets:new(), [], #{}, #{}, #{}),
	%Time = os:timestamp(),
	case gb_sets:size(DomAffected) >= 1 of true -> %SGL is much faster than Tarjan
	%io:format("~p~n", [{Zd, gb_sets:to_list(DomAffected), gb_sets:to_list(PseudoAffected), gb_sets:to_list(NotAffected), gb_sets:to_list(ZdSubtree), ZdSubtreeIdx, get_edgeset(element(2, Graph)), get_edgeset(DomTree)}]),
	NewDomDy = sreedhar_gao_lee_remove_affected(Graph, DomAffected, 
		PseudoDom, DomSt, DomDy, Xd, Yd, gb_sets:fold(fun (El, Acc) -> Acc#{El => true} end, #{}, DomAffected)),
	%compute immediate dominators for all the possibly affected nodes
	%io:format("~p~n", [{get_edgeset(NewDomDy), gb_sets:to_list(ZdSubtree), {get_edgeset(DomStTup), get_edgeset(list_to_tuple(DomDy))}, Dom, DomDepth}]),
	%can take the union of all strict dominators of each dominator set and subtract them to get immediate dominator	
	NewDom = gb_sets:fold(fun (El, AccDom) ->
		#{El := ElDy} = NewDomDy,
		AllDoms = sets:del_element(El, ElDy),
		%ImmDom = gb_sets:del_element(Zd, AllDoms), %a lot more efficient since either Zd or the new immediate dominator will be the final result only
		%cannot exclude original Zd only but might be a slight speed up to do that
		%the immediate dominator is the one of the set of dominators who is not contained by the others sets of dominators - further thought suggests that its only semi-efficient
		%the immediate dominator is the one of the set of dominators who is a subset with a size one less...the trivial measure
		%OtherDom = sets:add_element(El, sets:union(sets:fold(fun (E, A) -> #{E := ElDomDy} = NewDomDy, #{E := ESt} = DomSt,
			%if a pseudo affected node did not change and still has the original set, then it should be cleared out as obviously this would cause wrong immediate dominator computation
		%		[sets:del_element(E, sets:union(case case PseudoDom of #{E := _} -> true; _ -> false end andalso ElDomDy =:= [] of true -> sets:new(); _ -> ElDomDy end, ESt))|A] end, [], AllDoms))),
		%ImmDom = sets:subtract(AllDoms, OtherDom),
		ImmDom = sets:fold(fun (E, A) -> #{E := ElDomDy} = NewDomDy, #{E := ESt} = DomSt, case A =:= 0 andalso ElDomDy =/= [] andalso sets:size(AllDoms) =:= sets:size(ElDomDy) + sets:size(ESt) of true -> E; _ -> A end end, 0, AllDoms),
		%fun FindFirst(Acc) -> case gb_sets:next(Acc) of none -> []; {E, NewAcc} -> case gb_sets:is_element(E, OtherDom) of true -> FindFirst(NewAcc); _ -> E end end end(gb_sets:iterator(AllDoms)),
		%case sets:size(ImmDom) of 0 -> AccDom; _ -> Up = hd(sets:to_list(ImmDom)),
		case ImmDom of 0 -> AccDom; _ -> Up = ImmDom,
			#{El := {Ud,UdJ,UdT,_}} = AccDom, #{Up := UpDom} = AccDom, #{Ud := UdDom} = AccDom,
			AccDom#{El => {Up, UdJ, UdT, element(4, UpDom) + 1},
			Up => if Up =/= Zd -> setelement(3, UpDom, gb_sets:add_element(El, element(3, UpDom))); true -> UpDom end,
			Ud => if Up =/= Zd -> setelement(3, UdDom, gb_sets:del_element(El, element(3, UdDom))); true -> UdDom end}
			end end, Dom, DomAffected);
	_ -> %Tarjan subtree implementation equivalent
	ZdSubtree = fun DomRec(CurNode, Set) -> #{CurNode := {_,_,CurNodeTree,_}} = Dom,
			gb_sets:fold(fun (El, AccSet) -> DomRec(El, AccSet) end, 
			gb_sets:add_element(CurNode, Set), CurNodeTree)
		end(Zd, gb_sets:new()),
		ZdSubtreeIdx = gb_sets:fold(fun (El, Acc) -> Acc#{El => map_size(Acc) + 1} end, maps:new(), ZdSubtree),
		NewDom = tarjan_sgl_alt(Graph, ZdSubtreeIdx, ZdSubtree, Zd, Dom, DomAffected)
	end,
	%case array:to_list(element(1, tarjan_sgl_alt(Graph, ZdSubtreeIdx, ZdSubtree, Zd, Dom, DomAffected, DomDepth, DomTree))) =/= array:to_list(NewDom) of true -> error({Xd, Yd, array:to_list(NewDom), array:to_list(element(1, tarjan_sgl_alt(Graph, ZdSubtreeIdx, ZdSubtree, Zd, Dom, DomAffected, DomDepth, DomTree)))}); _ -> true end,
	%io:format("~p~n", [{gb_sets:size(ZdSubtree), timer:now_diff(os:timestamp(), Time)}]),
	NextDomDepth = gb_sets:fold(fun (Wd, AccDom) ->
		fun RecDomUpdate(Node, A) -> #{Node := {_,_,NodeTree,_}} = NewDom, gb_sets:fold(fun (El, Acc) -> #{El := ElDom} = Acc, #{Node := {_,_,_,NodeDep}} = Acc, RecDomUpdate(El, Acc#{El => setelement(4, ElDom, NodeDep + 1)}) end, A, NodeTree) end
			(Wd, AccDom) end,
		NewDom, DomAffected),
	%update DJ graph accordingly
	NewJ = gb_sets:fold(fun (El, Acc) -> #{El := {ElDom,_,_,_}} = Acc, #{ElDom := ElDomDom} = Acc, case gb_sets:is_element(El, element(2, ElDomDom)) of false -> Acc;
		_ -> Acc#{ElDom => setelement(2, ElDomDom, gb_sets:del_element(El, element(2, ElDomDom)))} end end,
			if Xd =/= Zd -> #{Xd := XdDom} = NextDomDepth, NextDomDepth#{Xd => setelement(2, XdDom, gb_sets:del_element(Yd, element(2, XdDom)))}; true -> NextDomDepth end, DomAffected),
	%{D, J, DTree, DDepth} = dom_to_d(NewJ),
	%case cmp_edgeset(make_dom_tree(D), DTree) of false -> error({get_edgeset(make_dom_tree(D)), get_edgeset(DTree)}); _ -> true end,
	%case cmp_edgeset(get_j_succ(element(2, Graph), D), J) of false -> error({get_edgeset(get_j_succ(element(2, Graph), D)), get_edgeset(J)}); _ -> true end,
	%case dom_depth(D) =:= DDepth of false -> error({dom_depth(NewDom), DDepth}); _ -> true end,
	NewJ
.

check_succ(_Graph, 0) -> true;
check_succ(Graph, El) -> lists:all(fun (Idx) -> gb_sets:is_element(El, get_preds(Idx, Graph)) end, gb_sets:to_list(get_succs(El, Graph))) andalso check_succ(Graph, El-1).
check_succ(Graph) -> check_succ(Graph, next_node(Graph) - 1).

%every node is referenced, and the graph is fully connected from both head and exit nodes
check_pred_succ(Graph) ->
	check_succ(Graph) andalso check_succ(rev_graph(Graph)) andalso
	gb_sets:size(fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) ->
			[get_preds(El, Graph)|Acc] end, [], X)))),
		case gb_sets:size(Y) of 0 -> Comb; _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list(case gb_sets:to_list(get_succs(2, Graph)) of [3] -> [3]; _ -> [2] end))) =:= next_node(Graph) - 1 andalso
	gb_sets:size(fun SuccRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) ->
			[get_succs(El, Graph)|Acc] end, [], X)))),
		case gb_sets:size(Y) of 0 -> Comb; _ -> SuccRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([1]))) =:= next_node(Graph) - 1
.

find_nc_nodes(DomNodes, Nodes, Pred, Dom, Top, LNodes) ->
	%every predecessor 1st time or dominators thereafter, take it or recurse its dominator
	{A,B} = lists:partition(fun (Elem) -> #{Elem := {ElDom,_,_,_}} = Dom, Elem =:= Top orelse gb_sets:is_element(ElDom, DomNodes) end, Pred),
	lists:foldl(fun (Elem, Acc) -> #{Elem := {ElDom,_,_,_}} = Dom, case Elem =:= Top orelse not gb_sets:is_element(ElDom, Nodes) of true -> [Elem|Acc]; _ -> Acc end end, if B =:= [] -> LNodes;
		true -> find_nc_nodes(DomNodes, Nodes, lists:map(fun (Elem) -> #{Elem := {ElDom,_,_,_}} = Dom, ElDom end, B), Dom, Top, LNodes) end, A)
.

get_all_dom_metadata(Map, Pred, Dom, AST, Top) ->
	case gb_sets:size(Pred) of 0 -> Map;
	_ -> P = gb_sets:smallest(Pred),
		NxtPred = gb_sets:del_element(P, Pred),
		get_all_dom_metadata(Map#{P => getgraphpath(AST, P)},
			if P =:= Top -> NxtPred; true -> #{P := {PDom,_,_,_}} = Dom, 
				gb_sets:add_element(PDom, NxtPred) end, Dom, AST, Top)
	end.

find_change_nodes(Change, Pred, Dom, AST, Top, MData, Var, Idx) ->
	%if Idx =< 5 -> io:format("~p~n", [{Change, Pred, Dom, Top, Var, Idx}]); true -> true end,
	case gb_sets:size(Pred) of 0 -> Change;
	_ -> P = gb_sets:smallest(Pred),
		if P =:= Top -> find_change_nodes(Change, gb_sets:del_element(Top, Pred), Dom, AST, Top, MData, Var, Idx);
		true -> #{P := {D,_,_,_}} = Dom,
		{Cur, DGraph} = if map_size(MData) =:= 0 -> {getgraphpath(AST, P), getgraphpath(AST, D)}; true -> #{P := PMData, D := DMData} = MData, {PMData, DMData} end,
		%TopGraph = getgraphpath(AST, Top),
		%if Idx =< 5 -> io:format("~p~n", [{Idx, Var, Cur, DGraph}]); true -> true end,
		%io:format("~p~n", [{P, D, lists:last(lists:nth(P, NodesToAST)), lists:last(lists:nth(D, NodesToAST))}]),
		%io:format("~p~n", [{element(Idx, element(Var, Cur)), element(Idx, element(Var, DGraph))}]),
		%if {y,N} variables are not present in one or the other, assume no more usage and change merge not necessary
		NotChanged = Cur =/= {} andalso (Idx > array:size(element(Var, Cur)) orelse array:get(Idx-1, element(Var, Cur)) =:= [] orelse
			Idx =< array:size(element(Var, DGraph)) andalso array:get(Idx-1, element(Var, Cur)) =:= array:get(Idx-1, element(Var, DGraph))),% orelse element(Idx, element(Var, Cur)) =:= element(Idx, element(Var, TopGraph)),
		find_change_nodes(if NotChanged -> Change; true -> %io:format("~p~n", [{P, D, Var, Idx, element(Idx, element(Var, Cur)), element(Idx, element(Var, DGraph))}]),
			%file:write_file(integer_to_list(Var) ++ "-" ++ integer_to_list(Idx) ++ "-" ++ integer_to_list(P) ++ "a.txt", lists:flatten(io_lib:format("~p~n", [element(Idx, element(Var, Cur))]))), file:write_file(integer_to_list(Var) ++ "-" ++ integer_to_list(Idx) ++ "-" ++ integer_to_list(P) ++ "b.txt", lists:flatten(io_lib:format("~p~n", [element(Idx, element(Var, DGraph))]))),
			[P|Change] end,
			if NotChanged -> NxtPred = gb_sets:del_element(P, Pred), case gb_sets:is_element(D, NxtPred) of true -> NxtPred; _ -> gb_sets:add_element(D, NxtPred) end;
			true -> gb_sets:del_element(D, gb_sets:del_element(P, Pred)) end,
			Dom, AST, Top, MData, Var, Idx)
	end end.

assign_var(AST, Graph, Dom, Node, AssignedVars, NumAsgn, VarIdx, VarPrefix, Elem, Idx, IsRecv, MData) ->
	%DomSet = gb_sets:from_list(tl(tl(pathtodom(Dom, Node)))),
	%PredSet = lists:filter(fun (El) -> not gb_sets:is_element(El, DomSet) end, gb_sets:to_list(get_preds(Node, Graph))),
	OrdPreds = get_preds(Node, Graph), #{Node := {NodeDom,_,_,_}} = Dom,
	PreNodes = find_change_nodes([], OrdPreds, Dom, AST, NodeDom, MData, VarIdx, Idx),
	AllDoms = gb_sets:union(lists:map(fun (El) -> gb_sets:from_list(tl(pathtodom(Dom, El))) end, PreNodes)),
	OrdNodes = gb_sets:from_list(lists:filter(fun (El) -> not gb_sets:is_element(El, AllDoms) end, PreNodes)),
	Nodes = gb_sets:to_list(OrdNodes),
%	case lists:member(dotfile, Opts) of true -> generate_dot_file(generate_dot_dom_text({Dom, "i", false, 1}, Nodes, NCNodes) ++ "\tedge[constraint=false];~n" ++ %generate_dot_dom_text({Dom, ODFS, element(2, lists:unzip(lists:sort(lists:zip(ODFS, lists:seq(1, length(ODFS)))))), "i", false, 1}) ++ "\tedge[constraint=true];~n" ++
%				"temp/" ++ atom_to_list(ModName) ++ "-" ++ atom_to_list(FuncName) ++ "-" ++ integer_to_list(Arity) ++ "-" ++ if Node =:= 2 -> "ret"; true -> if IsCatch -> "block"; true -> "" end ++ integer_to_list(BaseLabel + index_of(Node, LabelToNode)) end ++ ".dot"); _ -> true end,

	%case Nodes of [] -> true; _ -> io:format("~p~n", [{Pred, [Nodes], [NCNodes], [lists:nth(Node, Pred)], Dom, Node, lists:nth(Node, Dom), Elem, VarIdx, Idx}]) end,
  case Nodes =:= [NodeDom] orelse Nodes =:= [] orelse lists:any(fun(El) ->
  	CurEl = if map_size(MData) =:= 0 -> getgraphpath(AST, El); true -> #{El := ElMData} = MData, ElMData end, if CurEl =:= {} -> true; true -> Vars = element(VarIdx, CurEl),
  	Val = case VarIdx =:= 4 andalso Idx > array:size(Vars) of true -> []; _ -> array:get(Idx-1, Vars) end, Val =:= [] end %orelse case Val of {unresolved, {y, _}} -> true; _ -> false end
  		end, Nodes) of true -> E = Elem,%if Elem =:= [] -> array:get(Idx-1,element(VarIdx, getgraphpath(AST, Node))); true -> Elem end,
  		{if IsRecv -> {tuple,0,[{atom,0,true},E]}; true -> E end, {AST, Idx + 1, NumAsgn}};
  %Binary data flow: match object is a valid AST 2-tuple {tuple,L,[CurrentBinary, StartBinary]}
  %Receive data flow: Loopback contains integer for head node as a single integer list
  %Try-catch and catch data flow: Reference stack object contains integer of head node as a single integer list
	%if tuple or list retains common elements, an optimized algorithm can take place which is critical for binary match structures for restore/save
	%if identical tuple arity, any matching elements can avoid assignment, for list any consecutive heads
	false ->
	CmbNodes = find_nc_nodes(gb_sets:union(OrdNodes, AllDoms), OrdNodes,
		lists:filter(fun (El) -> not gb_sets:is_element(El, OrdNodes) andalso not gb_sets:is_element(El, AllDoms) end, gb_sets:to_list(OrdPreds)), Dom, NodeDom, Nodes),
	%CmbNodes = Nodes ++ NCNodes,
	%but can only write left side in optimizations if it is legal pattern, not for example if it contains fun's, so must use _
	TupLen = case lists:usort(lists:map(fun (El) -> case array:get(Idx-1, element(VarIdx, if map_size(MData) =:= 0 -> getgraphpath(AST, El); true -> #{El := ElMData} = MData, ElMData end)) of {tuple,_,A} -> length(A); _ -> 0 end end, CmbNodes)) of [B] -> B; _ -> 0 end,
		Ident = lists:map(fun (TplIdx) -> lists:usort(lists:map(fun (El) -> lists:nth(TplIdx, element(3, array:get(Idx-1, element(VarIdx, if map_size(MData) =:= 0 -> getgraphpath(AST, El); true -> #{El := ElMData} = MData, ElMData end)))) end, CmbNodes)) end, lists:seq(1, TupLen)),
		case lists:usort(lists:map(fun (El) -> case array:get(Idx-1, element(VarIdx, if map_size(MData) =:= 0 -> getgraphpath(AST, El); true -> #{El := ElMData} = MData, ElMData end)) of {cons,_,A,_} -> A; _ -> 0 end end, CmbNodes)) of [C] when C =/= 0 ->
			NewMatchVar = {cons,0,{var,0,'_'},{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + NumAsgn))}},
			NewVar = {cons,0,C,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + NumAsgn))}}, NumVar = 1;
		_ -> case Ident =/= [] of true -> %lists:any(fun (A) -> length(A) =:= 1 end, Ident) of true -> 
			NewMatchVar = {tuple,0,element(1, lists:foldl(fun (X, {Y, Asgn}) -> case lists:nth(X, Ident) of [_] -> {Y ++ [{var,0,'_'}], Asgn};
				_ -> {Y ++ [{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + NumAsgn + Asgn))}], Asgn + 1} end end, {[], 0}, lists:seq(1, TupLen)))},
			NewVar = {tuple,0,element(1, lists:foldl(fun (X, {Y, Asgn}) -> case lists:nth(X, Ident) of [_] -> {Y ++ [hd(lists:nth(X, Ident))], Asgn};
				_ -> {Y ++ [{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + NumAsgn + Asgn))}], Asgn + 1} end end, {[], 0}, lists:seq(1, TupLen)))},
			NumVar = lists:foldl(fun (X, Asgn) -> case lists:nth(X, Ident) of [_] -> Asgn; _ -> Asgn + 1 end end, 0, lists:seq(1, TupLen));
			_ -> NewMatchVar = NewVar = {var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + NumAsgn))}, NumVar = 1
			end end,
		{NewVar, {lists:foldl(fun(El, A) ->
			Gr = if map_size(MData) =:= 0 -> getgraphpath(A, El); true -> #{El := ElMData} = MData, ElMData end,
			case VarIdx =:= 4 andalso Idx > array:size(element(VarIdx, Gr)) of true -> A; _ -> case array:get(Idx-1, element(VarIdx, Gr)) of [] -> A; [_] when not IsRecv -> A; _ -> %not changed nodes which are not needed
			insertgraphnode(A, El, {match,0, NewMatchVar, if IsRecv -> case array:get(Idx-1, element(VarIdx, Gr)) of [_] -> {atom,0,false}; X -> {tuple,0,[{atom,0,true},X]} end;
				true -> array:get(Idx-1, element(VarIdx, Gr)) end}, setelement(VarIdx, Gr, array:set(Idx-1, NewMatchVar, element(VarIdx, Gr))), El) end end end,
			AST, CmbNodes), Idx + 1, NumAsgn + NumVar}} end
.

assign_vars(AST, Graph, Dom, Node, AssignedVars, VarIdx, VarPrefix) -> %do not consider predecessors which are dominators except for the immediate dominator!
	%DomSet = gb_sets:from_list(tl(tl(pathtodom(Dom, Node)))),
	PredSet = gb_sets:to_list(get_preds(Node, Graph)), %lists:filter(fun (El) -> not gb_sets:is_element(El, DomSet) end, gb_sets:to_list(get_preds(Node, Graph))),
	case case PredSet of [_] -> false; _ -> #{Node := {NdDom,_,_,_}} = Dom, case getnodeblockstruct(AST, NdDom, 0) of 'catch' -> false; 'try' -> false; 'receive' -> false; _ -> true end end of true ->
	#{Node := {NodeDom,_,_,_}} = Dom,
	MData = get_all_dom_metadata(#{}, get_preds(Node, Graph), Dom, AST, NodeDom), #{NodeDom := NodeData} = MData,
	Elements = if VarIdx =:= 4 ->
		YLen = lists:max(lists:map(fun(Elem) -> #{Elem := ElMData} = MData, array:size(element(4, ElMData)) end, PredSet)),
		YDom = element(4, NodeData), %io:format("~p~n", [{YLen, YDom}]),
		array:to_list(YDom) ++ lists:duplicate(case YLen < array:size(YDom) of true -> 0; _ -> YLen - array:size(YDom) end, []);
	true -> array:to_list(element(VarIdx, NodeData)) end,
	lists:mapfoldl(
		fun(Elem, {CurAST, Idx, NumAsgn}) -> assign_var(CurAST, Graph, Dom, Node, AssignedVars, NumAsgn, VarIdx, VarPrefix, Elem, Idx, false, MData) end,
		{AST, 1, 0}, Elements); _ -> {array:to_list(element(VarIdx, getgraphpath(AST, Node))), {AST, 1, 0}} end
.

list_to_tuple_from_n(A, N) -> if N > tuple_size(A) -> []; true -> [element(N, A)|list_to_tuple_from_n(A, N+1)] end.
tuple_drop_n(_A, 0, Acc) -> Acc;
tuple_drop_n(A, El, Acc) -> tuple_drop_n(A, El-1, [element(El, A)|Acc]).
tuple_drop_n(A, N) -> list_to_tuple(tuple_drop_n(A, tuple_size(A) - N, [])).
tup_prefix_same(A, B, Len) -> tuple_size(A) =:= tuple_size(B) andalso
	tup_prefix(A, B, tuple_size(A) - Len).
tup_prefix_rec(_A, _B, 0) -> true;
tup_prefix_rec(A, B, El) -> element(El, A) =:= element(El, B) andalso
	tup_prefix_rec(A, B, El-1).
tup_prefix(A, B, Len) -> tuple_size(B) >= Len andalso tup_prefix_rec(A, B, Len).
tup_suffix_rec(_A, _B, _C, _D, 0) -> true;
tup_suffix_rec(A, B, C, D, El) -> element(C - El + 1, A) =:=
	element(D - El + 1, B) andalso tup_suffix_rec(A, B, C, D, El-1).
tup_suffix(A, B, Len) -> tuple_size(B) >= Len andalso
	tup_suffix_rec(A, B, tuple_size(A), tuple_size(B), Len).
tup_compare(A, B) -> tup_compare_pre(1, A, B).
tup_compare_pre(Pre, A, B) -> LastCheck = min(tuple_size(A), tuple_size(B)),
	Res = if LastCheck =:= 0 -> 1; true -> fun FindFirst(El) -> if El =:= LastCheck+1 orelse element(El, A) =/= element(El, B) -> El; true -> FindFirst(El+1) end end(Pre) end,
	if Res =:= LastCheck+1 -> if tuple_size(A) =:= tuple_size(B) -> 0; true ->
		if tuple_size(A) > tuple_size(B) -> 1; true -> -1 end end; true ->
		if element(Res, A) > element(Res, B) -> 1; true -> -1 end end.

bin_search_lbound(A, B, Key) -> bin_search_lbound(A, B, Key, 1, array:size(A)).

bin_search_lbound(_, _, _, Lower, Upper) when Lower > Upper -> Lower;
bin_search_lbound(A, B, Key, Lower, Upper) ->
    Mid = (Upper + Lower) div 2, MidEl = array:get(array:get(Mid-1, A)-1, B),
    Item = hd(MidEl), LastItem = lists:last(MidEl),
    Gt = tup_compare(Key, LastItem) > 0, Lt = tup_compare(Key, Item) < 0,
    if Gt -> if Lower =:= Upper -> Lower + 1; true ->
        	bin_search_lbound(A, B, Key, Mid + 1, Upper) end;
        Lt -> if Lower =:= Upper -> Lower; true ->
        	bin_search_lbound(A, B, Key, Lower, Mid - 1) end;
        true -> Mid
    end.

hassideeffect(_Func, _Arity) -> true.

%lib/compiler/src/erl_bifs.erl:
%is_pure(Mod, Func, Arity) and is_safe(Mod, Func, Arity)
hassideeffect(Mod, Func, Arity) -> not erl_bifs:is_pure(Mod, Func, Arity).
% andalso erl_bifs:is_safe(Mod, Func, Arity)).

%lib/compiler/src/sys_core_fold.erl: is_safe_bool_expr(Core, Sub) - only boolean
%	returns, is_function specially allowed but not safe,
%	if all arguments are boolean, is_safe(), comp_op(), new_type_test()
%lib/stdlib/src/erl_internal.erl : guard_bif
%isguardbif(Func, Arity) -> erl_internal:guard_bif(Func, Arity).
%true, constants (terms/bound variables) regarded as false
%term comparisons, arithmetic expressions, boolean expressions, andalso/orelse
%	Func =:= 'is_atom' andalso Arity =:= 1 orelse
%	Func =:= 'is_binary' andalso Arity =:= 1 orelse
%	Func =:= 'is_bitstring' andalso Arity =:= 1 orelse
%	Func =:= 'is_boolean' andalso Arity =:= 1 orelse
%	Func =:= 'is_float' andalso Arity =:= 1 orelse
%	Func =:= 'is_function' andalso Arity =:= 1 orelse
%	Func =:= 'is_function' andalso Arity =:= 2 orelse
%	Func =:= 'is_integer' andalso Arity =:= 1 orelse
%	Func =:= 'is_list' andalso Arity =:= 1 orelse
%	Func =:= 'is_map' andalso Arity =:= 1 orelse
%	Func =:= 'is_number' andalso Arity =:= 1 orelse
%	Func =:= 'is_pid' andalso Arity =:= 1 orelse
%	Func =:= 'is_port' andalso Arity =:= 1 orelse
%	Func =:= 'is_record' andalso Arity =:= 2 orelse
%	Func =:= 'is_record' andalso Arity =:= 3 orelse
%	Func =:= 'is_reference' andalso Arity =:= 1 orelse
%	Func =:= 'is_tuple' andalso Arity =:= 1 orelse
%	Func =:= 'abs' andalso Arity =:= 1 orelse
%	Func =:= 'bit_size' andalso Arity =:= 1 orelse
%	Func =:= 'byte_size' andalso Arity =:= 1 orelse
%	Func =:= 'element' andalso Arity =:= 2 orelse
%	Func =:= 'float' andalso Arity =:= 1 orelse
%	Func =:= 'hd' andalso Arity =:= 1 orelse
%	Func =:= 'length' andalso Arity =:= 1 orelse
%	Func =:= 'map_size' andalso Arity =:= 1 orelse
%	Func =:= 'node' andalso Arity =:= 0 orelse
%	Func =:= 'node' andalso Arity =:= 1 orelse
%	Func =:= 'round' andalso Arity =:= 1 orelse
%	Func =:= 'self' andalso Arity =:= 0 orelse
%	Func =:= 'size' andalso Arity =:= 1 orelse
%	Func =:= 'tl' andalso Arity =:= 1 orelse
%	Func =:= 'trunc' andalso Arity =:= 1 orelse
%	Func =:= 'tuple_size' andalso Arity =:= 1 orelse
%	Func =:= 'binary_part' andalso Arity =:= 2 orelse
%	Func =:= 'binary_part' andalso Arity =:= 3 orelse
%	Func =:= 'ceil' andalso Arity =:= 1 orelse
%	Func =:= 'floor' andalso Arity =:= 1
%	.

pathtodom(Tree, Node) ->
	#{Node := ElDom} = Tree,
	El = element(1, ElDom),
	if El =:= 0 -> [Node];
		true -> [Node|pathtodom(Tree, El)]
	end.
pathtodomonly(Tree, Node) ->
	El = array:get(Node-1, Tree),
	if El =:= 0 -> [Node];
		true -> [Node|pathtodomonly(Tree, El)]
	end.

get_copy_affected_nodes(FromPath, {AST, NodesToAST, ASTDFS, IdxDFS}, Graph, Node) ->
	StartFrom = lists:last(array:get(FromPath-1, NodesToAST)),
	LastNodePath = lists:last(array:get(Node-1, NodesToAST)),
	MaxCheck = erlang:min(tuple_size(LastNodePath), tuple_size(StartFrom)),
	MaxSharePath = fun MaxPath(El) -> if El > MaxCheck -> MaxCheck; element(El, LastNodePath) =:=
			element(El, StartFrom) -> MaxPath(El+1); true -> El-1 end end(1),
	PDomPathLen = case MaxSharePath =:= 
		tuple_size(LastNodePath) of true -> 0;
		_ -> %case MaxSharePath =:=
			%	 length(lists:last(lists:nth(FromPath, NodesToAST))) of true -> 
			fun RecCatch(El) ->
				case getnodeblockstruct({AST, NodesToAST, ASTDFS, IdxDFS}, El, 0) of
				'try' -> LatchSet = gb_sets:filter(fun (E) -> tuple_size(hd(array:get(E-1, NodesToAST))) =:= tuple_size(StartFrom) end, get_succs(El, Graph)),
				case gb_sets:size(LatchSet) of 0 -> Pdom = get_pdom(Graph), ElPdom = hd(lists:dropwhile(fun (E) -> E =:= El orelse tuple_size(hd(array:get(E-1, NodesToAST))) =/= tuple_size(StartFrom) end, pathtodom(Pdom, El))), RecCatch(ElPdom);
				_ -> getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, El, true) end; %if already merged must find its merge node
				'receive' -> LatchSet = gb_sets:filter(fun (E) -> tuple_size(hd(array:get(E-1, NodesToAST))) =:= tuple_size(StartFrom) end, get_succs(El, Graph)),
				case gb_sets:size(LatchSet) of 0 -> Pdom = get_pdom(Graph), ElPdom = hd(lists:dropwhile(fun (E) -> E =:= El orelse tuple_size(hd(array:get(E-1, NodesToAST))) =/= tuple_size(StartFrom) end, pathtodom(Pdom, El))), RecCatch(ElPdom);
				_ -> getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, El, true) end; %if already merged must find its merge node
				'catch' -> LatchSet = gb_sets:filter(fun (E) -> tuple_size(hd(array:get(E-1, NodesToAST))) =:= tuple_size(StartFrom) end, get_succs(El, Graph)),
					case gb_sets:size(LatchSet) of 0 ->
					getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, El, true);
					_ -> RecCatch(gb_sets:smallest(LatchSet)) end;
				_ -> getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, El, true) end %catch must copy its merge node too
			end(FromPath)
			%erlang:min(lists:nth(MaxSharePath + 1,
			%    lists:last(lists:nth(Node, NodesToAST))) - 1,
			%	 getgraphpathlength(AST, NodesToAST, FromPath, true))
		%_ -> lists:nth(MaxSharePath + 1, hd(lists:nth(Node, NodesToAST))) - 1 end
		end,
	%cross edges at the end of try-catch or receive will already have
	%  a normal merge node interfering with the placeholder merge node
	%the placeholder merge node should not be copied but remain
	IsNodePfxd = MaxSharePath + 1 =:=
		tuple_size(StartFrom) andalso
		element(MaxSharePath + 1, LastNodePath) =< PDomPathLen,
	%child can post dominates in out of band exit but then still requires copying
	%this introduces merge nodes of try-catch and receive which still latched
	%  to the return node despite not being the post dominator
	MaxSubNodes = if FromPath =:= Node -> [FromPath];
		true -> fun PDomRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X),
			NewComb = gb_sets:union(Comb, gb_sets:from_list
				(if IsNodePfxd -> [2,3]; true -> [2,3,Node] end)),
			Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, NewComb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) ->
					[get_succs(El, Graph)|Acc] end, [], X)))),
			case gb_sets:size(Y) of 0 -> gb_sets:to_list(Comb);
			_ -> PDomRecurse(Comb, Y) end end
		(gb_sets:new(), gb_sets:from_list([FromPath])) end,
	FromPfx = tuple_drop_n(StartFrom, 1),
	LenFromPfx = tuple_size(FromPfx),
	StartIdx = element(tuple_size(StartFrom), hd(array:get(FromPath-1, NodesToAST))),
	%only merge nodes in line with this level,
	%  not child ones which would already be included
	MaxSubNodesSet = gb_sets:from_list(MaxSubNodes),
	{_CurSubNodes, AllNodes, MergeLocs} = lists:foldl(fun (A, {AccNodes, AccAll, AccLocs}) -> Preds = get_preds(A, Graph),
		PredsNodes = case gb_sets:size(Preds) of 0 -> []; _ ->
			array:get(gb_sets:smallest(Preds)-1, NodesToAST) end,
		ANodes = array:get(A-1, NodesToAST), ASuccs = get_succs(A, Graph),
		CheckPath = lists:last(if ANodes =:= [{}] -> PredsNodes; true -> ANodes end),
		case A =:= FromPath orelse
			tup_prefix(FromPfx, CheckPath, tuple_size(FromPfx)) andalso
				begin CheckPathIdx = element(LenFromPfx + 1, CheckPath),
					CheckPathIdx >= StartIdx + 1 andalso CheckPathIdx =< PDomPathLen end of true ->
			{[A|AccNodes], [A|AccAll], AccLocs};
		_ ->
		case gb_sets:size(ASuccs) =:= 1 andalso gb_sets:to_list(ASuccs) =:= [3] andalso
		gb_sets:size(Preds) =:= 1 andalso
		gb_sets:is_element(gb_sets:smallest(Preds), MaxSubNodesSet) andalso
		tup_prefix_same(lists:last(ANodes), lists:last(PredsNodes), 1) andalso
		tuple_drop_n(lists:last(ANodes), 1) =:= FromPfx andalso
		element(tuple_size(lists:last(ANodes)),
			lists:last(ANodes)) >= StartIdx + 1 andalso
		case dogetgraphpath(AST, getnextsibling(lists:last(PredsNodes)), 1) of
			{match,_,_,[{call,_,{'fun',_,{clauses,_}},_}]} -> true;
			{match,_,_,[{'try', _, _, _, _, _}]} -> true;
			{match,_,_,[{'catch',_,_}]} -> true; _ -> false end of true -> {AccNodes, [A|AccAll], [element(LenFromPfx + 1, CheckPath)|AccLocs]}; _ -> {AccNodes, AccAll, AccLocs} end end
	 	end, {[], [], []}, MaxSubNodes),
			%must also take merge nodes of receive or try catch blocks
			%  and the latch back of the receive
	PDomPathMergeLen = if MergeLocs =:= [] -> PDomPathLen; true ->
		lists:max(MergeLocs) end,
	%#{2 := {RetSet,_}} = element(7, Graph),
	{AllNodes, PDomPathMergeLen}.

copy_graph_node(FromPath, ToPath,
	{AST, NodesToAST, ASTDFS, IdxDFS}, Graph, Node) ->
	%case check_pred_succ(Graph) of true -> true;
	%_ -> io:format("Graph sanity check failed~n") end,
	%case check_nodes({AST, NodesToAST, ASTDFS, IdxDFS}) of true -> true;
	%_ -> io:format("AST sanity check failed~n") end,
	%case element(1, getgraphpath(AST, hd(lists:nth(FromPath, NodesToAST)))) of
	%graphdata -> true; _ -> io:format("~p~n",
	%  [getgraphpath(AST, hd(lists:nth(FromPath, NodesToAST)))]) end,
	case array:size(NodesToAST) > 15000 of true -> io:format("Node size on copy: ~p~n", [array:size(NodesToAST)]); _ -> true end,
	case array:size(NodesToAST) > 50000 of true -> error("> 50000"); _ -> true end,
	%io:format("~p~n", [{Graph}]),
	%io:format("~p~n", [{Node, FromPath, ToPath}]),
	%resolve_graph_data({AST, lists:reverse(lists:sort(NodesToAST))}, true),
	%io:format("~p~n", [get_post_dom(Graph)]),
	StartFrom = lists:last(array:get(FromPath-1, NodesToAST)),
	FromPfx = tuple_drop_n(StartFrom, 1),
	LenFromPfx = tuple_size(FromPfx),
	{CurSubNodes, PDomPathMergeLen} = get_copy_affected_nodes(FromPath, {AST, NodesToAST, ASTDFS, IdxDFS}, Graph, Node),
	PredLen = next_node(Graph),
	LastToPath = lists:last(array:get(ToPath-1, NodesToAST)),
	ToPathLen = getgraphpathlength({AST, NodesToAST, ASTDFS, IdxDFS}, ToPath, true), %element(tuple_size(LastToPath), LastToPath),
	StartIdx = element(tuple_size(StartFrom), hd(array:get(FromPath-1, NodesToAST))) - 1,
	ToPathPfx = tuple_drop_n(LastToPath, 1),
	%io:format("~p~n", [{CurSubNodes}]),
	%must sort CurSubNodes into DFS or BFS ordering
	%  if want edge addition to have no gaps
	NodeSet = gb_sets:from_list(CurSubNodes),
	NotSet = gb_sets:from_list(fun BuildNotSet(El, Acc) -> if El =:= 0 -> Acc; true ->
		BuildNotSet(El-1, case not gb_sets:is_element(El, NodeSet) of true -> [El|Acc]; _ -> Acc end) end end(PredLen-1, [])),
	OrderSubNodes = [E || E <- bfs(element(2, Graph), [], NotSet,
			gb_sets:from_list([FromPath])), gb_sets:is_element(E, NodeSet)],
	SubNodeIdxs = if FromPath =:= Node -> #{FromPath => ToPath}; true ->
		 lists:foldl(fun (El, Acc) -> Acc#{El => PredLen + map_size(Acc)} end,
		 #{}, OrderSubNodes) end,
	%this is done from the graph perspective, not the AST perspective,
	%  as its far too inefficient
	%the accumulated SubNodes should always be equal to CurSubNodes,
	%  and no other nodes should be prefixed by nodes in question
	SubNodes = lists:foldl(fun (Elem, Acc) ->
		lists:foldl(fun (El, Ac) -> case El =:= {} orelse
			element(LenFromPfx + 1, El) =:= StartIdx of true -> Ac;
			_ -> OldSet = element(element(LenFromPfx + 1, El) - StartIdx, Ac),
				NewSet = gb_sets:add_element(Elem, OldSet),
				case gb_sets:size(OldSet) =:= gb_sets:size(NewSet) of true -> Ac; _ -> setelement(element(LenFromPfx + 1, El) - StartIdx, Ac, NewSet) end
			end end, Acc, array:get(Elem-1, NodesToAST)) end,
		if PDomPathMergeLen =:= 0 -> {};
		true -> erlang:make_tuple(PDomPathMergeLen - StartIdx, gb_sets:new()) end, CurSubNodes),
	{Result, Batch} = lists:foldl(fun (Z, {Acc, AccBatch}) ->
		%SubNodes = lists:filter(fun (Elem) -> lists:any(fun (El) ->
		%  lists:prefix(FromPfx ++ [Z], El) end, lists:nth(Elem, NodesToAST)) end,
		%  CurSubNodes),
		%case lists:all(fun (T) -> lists:member(T, SubNodes) end,
		%  lists:filter(fun (Elem) -> lists:any(fun (El) ->
		%    lists:prefix(FromPfx ++ [Z], El) end, lists:nth(Elem, NodesToAST)) end,
		%    lists:seq(1, length(NodesToAST)))) of true -> true;
		%  _ -> io:format("~p~n", {CurSubNodes, MaxSubNodes, lists:filter(fun (Elem)
		%     -> lists:any(fun (El) -> lists:prefix(FromPfx ++ [Z], El) end,
		%lists:nth(Elem, NodesToAST)) end, lists:seq(1, length(NodesToAST)))}]) end,
		%io:format("~p~n", [{SubNodeIdxs, SubNodes, Z, MaxSharePath, PDomPathLen,
		%  PDomPathMergeLen, Node, FromPath, ToPath, FromPfx, ToPathPfx}]),
		%case element(1, getgraphpath(AST, FromPfx ++ [Z])) of graphdata -> true;
		%_ -> io:format("~p~n", [getgraphpath(AST, FromPfx ++ [Z])]) end,
		%io:format("~p~n", {lists:filter(fun (Elem) -> lists:any(fun (El) ->
		%  lists:prefix(FromPfx ++ [Z], El) end, lists:nth(Elem, NodesToAST)) end,
		%  lists:seq(1, PredLen - 1))}]),
		CurFromPath = list_to_tuple(tuple_to_list(FromPfx) ++ [Z]),
			NewToPath = tuple_to_list(ToPathPfx) ++ [ToPathLen + Z - StartIdx],
		%must sort SubNodes from largest to smallest, to enable SearchOnly
		%  to take place when inserting, and avoiding renumbering
		%critical code which still has an n squared
		%  causing slowness with very large graphs
		{doinsertgraphnode(Acc, list_to_tuple(NewToPath),
			dogetgraphpath(AST, CurFromPath, 1), 0),
		lists:foldl(fun (X, A) -> #{X := XIdx} = SubNodeIdxs, lists:foldl(fun (Y, B) ->
			case tup_prefix(CurFromPath, Y, tuple_size(CurFromPath)) of true ->
			[{list_to_tuple(NewToPath ++ list_to_tuple_from_n(Y, LenFromPfx + 1+1)), XIdx}|B]; _ -> B end end, 
			A, array:get(X-1, NodesToAST)) end,
			AccBatch, lists:sort(fun (A, B) -> #{A := AIdx, B := BIdx} = SubNodeIdxs,
				AIdx >= BIdx end,
			gb_sets:to_list(element(Z - StartIdx, SubNodes))))}
		%{NewAST, lists:foldl(fun (X, A) -> lists:foldl(fun (Y, B) ->
		%	case lists:prefix(CurFromPath, Y) of true ->
		%		addtolistoflistsend(maps:get(X, SubNodeIdxs), B, NewToPath ++
		%			lists:nthtail(LenFromPfx + 1, Y)); _ -> B end end,
		%		A, array:get(X-1, NodesToAST)) end, NewNodesToAST,
		%	lists:nth(Z - StartIdx, SubNodes)), NewASTDFS, NewIdxDFS}
	end, {{AST, NodesToAST, ASTDFS, IdxDFS},
	lists:foldl(fun (X, A) -> #{X := XIdx} = SubNodeIdxs, lists:foldl(fun (Y, B) -> if Y =:= {} ->
		[{Y, XIdx}|B]; true -> B end end, A,
		array:get(X-1, NodesToAST)) end, [], CurSubNodes)}, if PDomPathMergeLen =:= 0 ->
			[]; true -> lists:seq(StartIdx + 1, PDomPathMergeLen) end),
	%io:format("~p~n", [{FromPath, ToPath, SubNodes, CurSubNodes, FromPfx, ToPathPfx,
	% ToPathLen, element(tuple_size(LastToPath), LastToPath), StartIdx + 1, PDomPathMergeLen, array:get(FromPath-1, NodesToAST)}]),
	%case check_nodes(Result) of true -> true; _ ->
	%	io:format("AST sanity check failed~n") end,
	%any other nodes must be assumed to be cross edges
	%  that will be fixed in later calls
	#{FromPath := FromIdx} = SubNodeIdxs,
	ToSuccs = get_succs(ToPath, Graph),
	NextAST = if Batch =:= [] -> Result;
	true -> dobatchinsertgraphnode(Result, Batch, tuple_size(ToPathPfx)) end,
	AddAST = NextAST, %case gb_sets:is_element(2, get_succs(FromPath, Graph))
	%andalso not gb_sets:is_element(2, ToSuccs) andalso
	%ToSuccs =/= [FromPath] of true ->
	%	insertgraphnode(NextAST, ToPath, getgraphpath(NextAST, ToPath),
	%		PredLen + length(OrderSubNodes) - 1); _ -> NextAST end,
	{AddSet, RetAddSet} = lists:foldl(fun (X, A) -> #{X := XIdx} = SubNodeIdxs,
		gb_sets:fold(fun (Y, {Ac,Cc}) ->
		case X =/= FromPath andalso (Y =:= FromPath andalso
			not gb_sets:is_element(XIdx,
				ToSuccs)) of true ->
			{[{if Y =:= FromPath -> FromIdx; true -> Y end,
				XIdx}|Ac],Cc}; _ -> {Ac,Cc} end end, 
			gb_sets:fold(fun (El, {B,C}) -> if El =:= 2 ->
				{B, case XIdx =:= ToPath andalso
					(gb_sets:size(ToSuccs) =/= 1 orelse gb_sets:to_list(ToSuccs) =/= [FromPath]) of
					true -> C; _ -> [{XIdx, 2}|C] end}; true ->
				 case El =:= 3 andalso XIdx =:= ToPath andalso
				 	gb_sets:is_element(3, ToSuccs) of true -> {B,C};
				 _ -> {[{XIdx,
				 	case SubNodeIdxs of #{El := Idx} -> Idx; _ -> El end}|B],
				 C} end end end, A, get_succs(X, Graph)), get_preds(X, Graph)) end,
		%case get_preds(FromPath, Graph) of [ToPath] -> Graph; _ ->
		%merge nodes must be ignored and processed at later cross edges
		%	post dominating the whole structures
	{[], []}, CurSubNodes),
	%only valid orders to add edges in general are based off nodes in depth
	%  or bread-first search partial ordering
	%io:format("~p~n", [{FromPath, ToPath, Node, PredLen, Batch,SubNodeIdxs,
		%lists:usort(fun ({A, B}, {C, D}) -> if A =:= C andalso B =:= D -> true;
			%A < B andalso C < D orelse A > B andalso C > D ->
			%	if B =:= D -> A < C; true -> B < D end;
			%A < B -> true; C < D -> false end end, RetAddSet ++ AddSet)}]),
	AddEdges = lists:usort(fun ({A, B}, {C, D}) ->
		if A =:= C andalso B =:= D -> true;
		A < B andalso C < D orelse A > B andalso C > D ->
			if B =:= D -> A < C; true -> B < D end;
		A < B -> true; C < D -> false end end, RetAddSet ++ AddSet),
	NewGraph = lists:foldl(fun ({P, S}, A) -> add_edge(P, S, A, AddAST,
		{true, true}) end, Graph, [{ToPath,FromIdx}] ++ AddEdges),
	%reverse BFS can be off rev_graph(Graph) or the actual reverse graph as the
	%  exit nodes still considered firstmost since we add the unconnected
	%  subgraphs as they would ultimately be connected
	%  and there is no other possibility for optimizing
	%do_bfs({element(3, Graph), element(4, Graph), element(1, Graph),
	%	element(2, Graph), element(6, Graph), element(5, Graph),
	%	element(7, Graph), element(8, Graph)}, 3)
	%since the whole of the return set must be traversed
	%	independently of the exit set, a BFS must start at return,
	%	but this misses exit, need 2 BFS
	%DFS however should if and only if traversing return node first
	%	would provide a better partial ordering in this scenario
	#{2 := {RetSet,_}} = element(7, NewGraph),
	ExistPreds = lists:filter(fun ({_P, S}) -> S =< PredLen - 1 end, AddEdges),
	ExistSuccs = gb_sets:from_list(lists:filtermap(fun ({P, _S}) -> if P =< PredLen - 1 -> {true, P}; true -> false end end, AddEdges)),
	{RetPreds, ExitPreds} = lists:partition(fun ({_P, S}) ->
		gb_sets:is_element(S, RetSet) end, ExistPreds),
	BFSExcSet = gb_sets:from_list(fun BuildNotSet(El, Acc) -> if El =:= 0 -> Acc; true ->
		BuildNotSet(El-1, case not gb_sets:is_element(El, ExistSuccs) of true -> [El|Acc]; _ -> Acc end) end end(PredLen-1, [])),
	RevBFS = lists:foldl(fun (El, Acc) ->
		Acc#{El => map_size(Acc) + 1} end, maps:new(),
		bfs(element(1, NewGraph), %partial BFS
			[], BFSExcSet,
			gb_sets:from_list(lists:map(fun ({_, S}) -> S end, ExitPreds)))),
		%index_from_search_tree(do_bfs(rev_graph(NewGraph), 3)),
	%io:format("~p~n",
	%	[{RevBFS, tuple_to_list(do_bfs(rev_graph(NewGraph), 2))}]),
	%RevBFS = index_from_search_tree(list_to_tuple(bfs(element(1, NewGraph), [],
	%	gb_sets:del_element(2, gb_sets:del_element(3, NotSet)),
	%		gb_sets:from_list([3])))),
	RetRevBFS = lists:foldl(fun (El, Acc) ->
		Acc#{El => map_size(Acc) + 1} end, maps:new(),
		%bfs(element(1, NewGraph), [], gb_sets:del_element(2, NotSet),
		%	gb_sets:from_list([Node]))),
		bfs(element(1, NewGraph), %partial BFS
			[], BFSExcSet,
			gb_sets:from_list(lists:map(fun ({_, S}) -> S end, RetPreds)))),
		%do_bfs(rev_graph(NewGraph), 2)), %not contiguous so use map
	%must have the return reaching set copied before the exit set
	%  or fence addition would not go correctly
	%start from all successors added which are in the return set
	SuccSet = gb_sets:from_list(element(2, lists:unzip(RetAddSet ++ AddSet))),
	{IRetSet, ORetSet} = gb_sets:fold(fun (El, {IR, OR}) -> case gb_sets:is_element(El, SuccSet) of false -> {[El|IR], OR};
		_ -> {IR, [El|OR]} end end, {[], []}, RetSet),
	NextRetSet = gb_sets:union(RetSet, element(2, pred_set_recurse(gb_sets:from_list(ORetSet),
		gb_sets:from_list(IRetSet), NewGraph))),
	{Fst, Snd} = lists:partition(fun ({A, B}) ->
		gb_sets:is_element(A, NextRetSet) andalso
		gb_sets:is_element(B, NextRetSet) end, AddSet),
	RetOrd = RetAddSet ++ lists:usort(fun ({Aa, Ba}, {Ca, Da}) ->
		#{Aa := A, Ba := B, Ca := C, Da := D} = RetRevBFS,
		if A =:= C andalso B =:= D -> true;
		A < B andalso C < D orelse A > B andalso C > D ->
			if B =:= D -> A < C; true -> B < D end;
		A < B -> false; C < D -> true end end, Fst),
	{SndExit, SndNoExit} = lists:partition(fun ({_, B}) -> B =:= 3 end, Snd),
	ExitOrd = lists:usort(SndExit) ++
		lists:usort(fun ({Aa, Ba}, {Ca, Da}) ->
		#{Aa := A, Ba := B, Ca := C, Da := D} = RevBFS,
		if A =:= C andalso B =:= D -> true;
		A < B andalso C < D orelse A > B andalso C > D ->
			if B =:= D -> A < C; true -> B < D end;
		A < B -> false; C < D -> true end end, SndNoExit),
	%io:format("~p~n", [{FromPath, ToPath, ORetSet,
	%	gb_sets:to_list(NextRetSet), do_bfs(rev_graph(NewGraph), 2), RetRevBFS,
	%  RetOrd, ExitOrd, element(7, NewGraph)}]),
	FixGraph = lists:foldl(fun ({P, S}, A) ->
		add_edge(P, S, A, AddAST, {true, false}) end,
		setelement(7, NewGraph, begin Map = element(7, NewGraph),
			Map#{2 := {NextRetSet, gb_sets:new()}} end), RetOrd ++ ExitOrd ++ [{ToPath,FromIdx}]),
	%case do_tarjan_immdom({element(3, RevGraph), element(4, RevGraph), 
	%	element(1, NewGraph), element(2, NewGraph), element(6, RevGraph),
	% element(5, NewGraph), element(7, RevGraph), element(8, NewGraph)}, 3) =/=
	%		element(1, element(6, RevGraph)) of true ->
	%			error({do_tarjan_immdom({element(3, RevGraph), element(4, RevGraph),
	%				element(1, NewGraph), element(2, NewGraph), element(6, RevGraph),
	%				element(5, NewGraph), element(7, RevGraph), element(8, NewGraph)},
	%			3), element(6, RevGraph)}); _ -> true end,
	%FixGraph = {element(1, NewGraph), element(2, NewGraph),
	%	element(3, RevGraph), element(4, RevGraph),
	%	element(5, NewGraph), element(6, RevGraph),
		%element(7, RevGraph), element(8, NewGraph)},
	%NextGraph = case gb_sets:is_element(2, get_succs(FromPath, Graph)) andalso
	%	not gb_sets:is_element(2, ToSuccs) of true ->
		%case ToSuccs =:= [FromPath] of true ->
		%add_edge(ToPath, 2, FixGraph, AddAST, false); _ ->
		%io:format("~p~n", [{next_node(Graph), ToPath,
		%	PredLen + length(OrderSubNodes) - 1, SubNodeIdxs}]),
		%add_edge(ToPath, PredLen + length(OrderSubNodes) - 1, FixGraph, AddAST,
		%	false) end; _ ->
		%FixGraph end, %cannot add to return node and other node,
		%  violates pattern so create new node for this purpose
	%io:format("~p~n", [get_preds(FromPath, NextGraph)]),
	FromPreds = get_preds(FromPath, FixGraph),
	{AddAST,
		%if Y (or El) =:= FromPath then ToPath should also be disconnected
		%	from the post dominator node
		%must add nodes in order with existing from path and new to path recursively
		%	so, this new node addition part is precise, such order is certain to exist
		case gb_sets:size(FromPreds) =:= 1 andalso gb_sets:to_list(FromPreds) =:= [ToPath] of true -> FixGraph;
		_ -> remove_edge(ToPath, FromPath, gb_sets:fold(fun (El, Acc) -> case FromIdx =/= FromPath andalso El =/= ToPath andalso tup_prefix(ToPathPfx, lists:last(array:get(El-1, NodesToAST)), tuple_size(ToPathPfx)) of true ->
				remove_edge(El, FromPath, add_edge(El, FromIdx, Acc, AddAST, false), AddAST, false); _ -> Acc end end, FixGraph, FromPreds), AddAST, false) end,
		map_size(SubNodeIdxs) - 1, length(AddEdges), length(RetOrd) + 
		length(SndNoExit) + lists:foldl(fun ({El,_}, Acc) ->
			gb_sets:size(array:get(El-1, element(3, FixGraph))) + Acc end, 0, SndExit)}
.

handle_cross_edges(AST, Graph, Node, MergeNode, NearestCrossPdom) ->
	CrossPairs = array:foldl(fun (Idx, X, A) -> lists:foldl(fun ({Y, Z}, Acc) ->
		case Idx+1 =/= Node andalso (Z =:= Node orelse
		%return node detected as cross edge out of unresolved try-catch or receive
		Z =:= MergeNode) of true -> [{Idx+1, Y}|Acc]; _ -> Acc end end,
			A, X) end,
		[], NearestCrossPdom),
	%TupIdxDFS = list_to_tuple(element(2, lists:unzip(lists:sort(lists:zip(
	%	tuple_to_list(element(3, AST)),
	%	lists:seq(1, tuple_size(element(3, AST)))))))),
	%bottom-up not top-down in target path order or must maintain
	%	excessive duplication information in cross edge structures and so on
	%io:format("~p~n", [{get_edgeset(element(2, Graph)), Node, MergeNode,
	%	array:to_list(NearestCrossPdom), CrossPairs}]),
	{_, DepList, _} = fun RecDep(CurPair, PairList, SortList, SMap, Inner) ->
		case gb_sets:size(PairList) of 0 -> {PairList, SortList, SMap}; _ -> Pair = if CurPair =:= [] -> gb_sets:smallest(PairList); true -> CurPair end, {FromPath,_ToPath} = Pair,
		case SMap of #{Pair := _} -> if Inner -> {PairList, SortList, SMap}; true -> RecDep([], gb_sets:del_element(Pair, PairList), SortList, SMap) end;
		_ -> {CSubNodes, _} = get_copy_affected_nodes(FromPath, AST, Graph, Node),
			CurSubNodes = gb_sets:from_list(CSubNodes),
			{NewPairs, NewList, NewMap} = gb_sets:fold(fun (InPair, {AccPairs, AccList, AccMap}) -> case gb_sets:is_element(InPair, AccPairs) andalso gb_sets:is_element(element(2, InPair), CurSubNodes) of true ->
				RecDep(InPair, AccPairs, AccList, AccMap, true); _ -> {AccPairs, AccList, AccMap} end end, {gb_sets:del_element(Pair, PairList), SortList, SMap#{Pair => map_size(SMap) + 1}},
					gb_sets:del_element(Pair, PairList)),
			if Inner -> {NewPairs, [Pair|NewList], SMap#{Pair => map_size(NewMap) + 1}}; true -> RecDep([], NewPairs, [Pair|NewList], SMap#{Pair => map_size(NewMap) + 1}, false) end
		end end
	end([], gb_sets:from_list(CrossPairs), [], #{}, false),
	%io:format("~p~n", [{Node, CrossPairs, DepList}]),
	%lists:sort(fun ({A,B}, {C,D}) -> compareedges(AST, {B,A}, {D,C}) end, CrossPairs),
	{NewAST, NewGraph, CNodes, CEdges, CREdges} =
		lists:foldl(fun ({X,Y}, {AccAST, AccGraph, A, B, C}) ->
		%io:format("~p~n", [{X, Y, Node, lists:last(lists:nth(X, element(2, Acc))),
		%	lists:last(lists:nth(Y, element(2, Acc))), element(3, Acc)}]),
		%case check_nodes(element(1, Acc)) of true -> true;
		%_ -> error({"AST sanity check failed", X, Y}) end,
		%case gb_sets:to_list(get_succs(Y, AccGraph)) =:= [X] ->
		%	case gb_sets:to_list(get_preds(Y, AccGraph)) of [Z] ->
		%		case gb_sets:to_list(gb_sets:del_element(Y, get_preds(X, AccGraph))) =:= gb_sets:to_list(get_preds(Z, AccGraph)) of true ->
		%			getgraphpath(AST), getgraphpath(AST)
		%			setgraphpath(AST), add_edge(Y, 3), remove_edge(Y, X)
		%		; _ -> end; _ -> end; _ -> end,
		case gb_sets:is_element(Y, get_preds(X, AccGraph)) of true -> 
		{NAST, NGraph, NCNodes, NCEdges, NCREdges} =
			copy_graph_node(X, Y, AccAST, AccGraph, Node),
		{NAST, NGraph, A+NCNodes, B+NCEdges, C+NCREdges}; _ -> {AccAST, AccGraph, A, B, C} end end,
			{AST, Graph, 0, 0, 0}, lists:reverse(DepList)),
	%case check_pred_succ(NewGraph) of true -> true; _ -> io:format("Graph sanity check failed~n", []) end,
	%case check_nodes(NewAST) of true -> true; _ -> io:format("AST sanity check failed~n", []) end,
	{NewAST, NewGraph, length(CrossPairs), CNodes, CEdges, CREdges}
.
%X is predecessor, N is successor
has_cross_edge({AST, NodesToAST, ASTDFS, IdxDFS}, _Graph, X, N) ->
	Has = if N =:= 3 -> false; true ->
	{PathN, PathX} = case comparenodes({AST, NodesToAST, ASTDFS, IdxDFS}, N, X) of
		false -> {hd(array:get(N-1, NodesToAST)), lists:last(array:get(X-1, NodesToAST))};
		_ -> {lists:last(array:get(N-1, NodesToAST)), hd(array:get(X-1, NodesToAST))} end,
	IsTryToOf = case tup_suffix({4, 1, 4, 1, 5, 1}, PathN, 6) of false -> true;
	_ -> TryPath = tuple_drop_n(PathN, 6), PathTry = list_to_tuple(tuple_to_list(TryPath) ++ [4, 1, 3]),
		case tup_prefix(PathTry, PathX, tuple_size(PathTry)) of true ->
			case dogetgraphpath(AST, TryPath, 1) of {match,_,_,[{'try', _, _, _, _, _}]}
			-> false; _ -> true end; _ -> true end end,
	LenPathN = tuple_size(PathN), LenPathX = tuple_size(PathX),
	IsCatchToLatch = %case tup_prefix(CPath, PathX, tuple_size(CPath)) of false -> true;
	%_ -> InPath = list_to_tuple(tuple_to_list(CPath) ++ [4, 1, 3]),
		%case tup_prefix(InPath, PathX, tuple_size(InPath)) of true ->
			%case dogetgraphpath(AST, CPath, 1) of {match,_,_,[{'catch',_,_}]}
			%-> false; _ -> true end; _ -> true end end,
		case LenPathN =:= 0 orelse LenPathX =:= 0 orelse element(tuple_size(PathN), PathN) =:= 1 orelse tup_prefix_same(PathN, PathX, 1) of true -> true; _ ->
			CPath = setelement(tuple_size(PathN), PathN, element(tuple_size(PathN), PathN) - 1),
			case dogetgraphpath(AST, CPath, 1) of {match,_,_,[{'catch',_,_}]} -> Pth = getnextsibling(lists:last(array:get(X-1, NodesToAST))),
		MxLen = length(element(element(tuple_size(PathX) - 1, PathX),
			dogetgraphpath(AST, tuple_drop_n(PathX, 2), 1))), 
		case element(tuple_size(Pth), Pth) > MxLen of true -> false;
		_ -> case dogetgraphpath(AST, Pth, 1) of
			{match,_,_,[{'catch',_,_}]} -> true;
			_ -> false end end; _ -> true end end,
	if LenPathN =:= 0 orelse LenPathX =:= 0 -> false;
		LenPathN =:= LenPathX ->
		case tup_prefix_same(PathX, PathN, 1) of true ->
			%case gb_sets:size(get_preds(N, Graph)) of 1 -> %catch will have 2 pred
			%filter out place holder merge nodes of try and receive before
			%	they are merge processed and catch merge node
		Path = getnextsibling(lists:last(array:get(X-1, NodesToAST))),
		MaxLen = length(element(element(tuple_size(PathX) - 1, PathX),
			dogetgraphpath(AST, tuple_drop_n(PathX, 2), 1))), 
		case element(tuple_size(Path), Path) > MaxLen of true -> true;
		_ -> case dogetgraphpath(AST, Path, 1) of
			{match,_,_,[{call,_,{'fun',_,{clauses,_}},_}]} -> false;
			{match,_,_,[{'try', _, _, _, _, _}]} -> false;
			{match,_,_,[{'catch',_,_}]} -> false;
			_ -> true end end; _ -> true end andalso
		IsTryToOf andalso IsCatchToLatch andalso
	(not tup_prefix_same(PathN, PathX, 1) orelse
		(element(tuple_size(PathX), PathX) + 1 =/=
			element(tuple_size(PathN), PathN)));
			%sole tree edge, DFS check too expensive without incremental method
	true -> SmallPath = if LenPathN < LenPathX -> PathN; true -> PathX end,
		BigPath = if LenPathN < LenPathX -> PathX; true -> PathN end,
		IsTryToOf andalso IsCatchToLatch andalso
		(not tup_prefix(SmallPath, BigPath, tuple_size(SmallPath) - 1) orelse
		element(tuple_size(SmallPath), SmallPath) + if LenPathN < LenPathX -> -1;
			true -> 1 end =/= element(tuple_size(SmallPath), BigPath)) andalso
		(not tup_prefix(SmallPath, BigPath, tuple_size(SmallPath) - 2) orelse
		element(tuple_size(SmallPath) - 1, SmallPath) + if LenPathN < LenPathX ->
			-1; true -> 1 end =/= element(tuple_size(SmallPath) - 1, BigPath))
	end end,
	%if Has -> try throw(undef) catch _:_ -> io:format("~p~n",
	%	[{erlang:get_stacktrace(), X, N, lists:last(array:get(X-1, NodesToAST)),
	%		lists:last(array:get(N-1, NodesToAST))}]) end; true -> true end,
	Has.

get_cross_edges(AST, Graph) ->
	%DFS = element(1, lists:unzip(lists:sort(fun({_, [A|_]}, {_, [B|_]}) -> A =< B
		%end, lists:zip(lists:seq(1, length(NodesToAST)), NodesToAST)))),
	%CrossEdges = [lists:filter(fun (X) -> lists:nth(X, ODFS) > lists:nth(N, ODFS)
		%andalso lists:nth(X, RDFS) > lists:nth(N, RDFS) end, lists:nth(N, Pred)) ||
			%N <- lists:seq(1, LenPred)],
	%io:format("~p~n", [check_nodes({AST, NodesToAST, ASTDFS, IdxDFS})]),
	PredLen = next_node(Graph) - 1,
	array:from_list(
		fun CEdges(N) -> if N =:= PredLen+1 -> []; true ->
		[gb_sets:filter(fun (X) -> has_cross_edge(AST, Graph, X, N) end,
			get_preds(N, Graph))|CEdges(N+1)] end end(1))
  %CrossElim = lists:filtermap(fun (X) -> case lists:any(fun (Y) ->
  	%lists:nth(Y, Idom) =:= X end, lists:nth(X, CrossEdges)) of
  	%true -> {true, X}; _ -> false end end, lists:seq(1, length(Pred))),
  %CrossElim = lists:append(CrossEdges),
  %filter all predecessors in cross edges unless doing a merge on current node
  %CrossElim = lists:append(lists:map(fun (X) -> lists:filtermap(fun (Y) ->
  	%IsPred = lists:member(Y, lists:nth(X, Pred)),
  	%case (if IsPred -> X; true -> Y end) =/= Node of true ->
  	%{true, if IsPred -> Y; true -> X end}; _ -> false end end,
  	%lists:nth(X, CrossEdges)) end, lists:seq(1, length(Pred)))),
.

-define(EntryNode, 1).
-define(ReturnNode, 2).
-define(ExitNode, 3).
get_preds(S, {Pred, _, _, _, _, _, _, _}) -> array:get(S-1, Pred).
get_succs(P, {_, Succ, _, _, _, _, _, _}) -> array:get(P-1, Succ).
next_node({Pred, _, _, _, _, _, _, _}) -> array:size(Pred) + 1.
rev_graph({Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}) ->
	{Succ, Pred, RSucc, RPred, Pdom, Dom, RetReach, CrossEdges}.
rev_interval({Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}) ->
	{array:map(fun (X,_) ->
		gb_sets:from_list(lists:reverse(gb_sets:to_list(array:get(X, Pred)))) end,
		Pred),
	 array:map(fun (X,_) ->
	 	gb_sets:from_list(lists:reverse(gb_sets:to_list(array:get(X, Succ)))) end,
	 	Succ), RPred, RSucc, Dom, Pdom, RetReach,
	 CrossEdges}.
	 
%add_edge_exit(P, S, Graph, AST) -> add_edge(S, 3, add_edge(P, S, Graph, AST, false), AST, false)
	%NewGraph = add_edge(S, 3, add_edge(P, S, Graph, AST, {true, true}), AST, {true, true}),
	%FinGraph = add_edge(P, S, add_edge(S, 3, NewGraph, AST, {true, false}), AST, {true, false}),
	%case get_succs(P, Graph) of [2] -> remove_edge(P, 2, FinGraph, AST, false); _ -> FinGraph end
%.

%3 guarantees:
%add: all new nodes are always automatically connected to return node
%add: all edges going to other than return node,
%	remove edge to the return node such as with exit node
%remove: if the return node has its last predecessor removed,
%	it is automatically added as a successor of the exit node
add_edge(P, S, {Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges},
	AST, BatchMode) ->
%can only add node as successor, not as predecessor so can latch to return node
	case BatchMode =/= {true, false} andalso (S > array:size(Pred) + 1 orelse
		P > array:size(Succ) orelse P =< array:size(Succ) andalso
		gb_sets:is_element(S, array:get(P-1, Succ))) of true ->
		error({P, S, get_edgeset(Succ)}); _ -> true end,
	%io:format("~p~n",
		%[{P, S, get_edgeset(Succ), get_edgeset(RSucc), BatchMode}]),
	%P->S->2 and 2->S->P
	FinGraph = case BatchMode =:= {true, false} andalso
		(P > array:size(RSucc) orelse array:get(P-1, RSucc) =:= gb_sets:new() andalso
		array:get(P-1, RPred) =:= gb_sets:new()) of true ->
		case S =:= 3 andalso gb_sets:to_list(array:get(2-1, Succ)) =:= [3] of true -> #{2 := {RetSet,_}} = RetReach,
			{Set, SubGraph} = pred_set_recurse(gb_sets:from_list([P]), RetSet,
				{Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}),
			Incs = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) ->
				[array:get(X-1, Succ)|Acc] end, [], Set))),
			%io:format("~p~n", [{P, S, gb_sets:to_list(Set), gb_sets:to_list(SubGraph), gb_sets:to_list(RetSet), gb_sets:to_list(Incs)}]),
			{_, RP, RS, Rpd} = gb_sets:fold(fun (El, {IsFirst, AccRPred, AccRSucc, AccPdom}) -> %io:format("~p~n", [get_edgeset(setelement(El, AccRSucc, gb_sets:add_element(P, array:get(El-1, AccRSucc))))]),
				case El > array:size(RSucc) orelse case AccPdom of #{El := _ElDom} -> false; _ -> true end of true -> {IsFirst, AccRPred, AccRSucc, AccPdom}; _ ->
				if IsFirst -> #{El := ElPdom} = AccPdom,
				case P > array:size(RSucc) of true -> {false, array:set(P-1, gb_sets:from_list([El]), array:resize(P, RPred)),
					array:resize(P, array:set(El-1, gb_sets:add_element(P, array:get(El-1, RSucc)), RSucc)),
					AccPdom#{P => {El, gb_sets:new(), gb_sets:new(), element(4, ElPdom) + 1},
						El => setelement(3, ElPdom, gb_sets:add_element(P, element(3, ElPdom)))}};
					_ -> {false, array:set(P-1, gb_sets:add_element(El, array:get(P-1, RPred)), RPred), array:set(El-1, gb_sets:add_element(P, array:get(El-1, RSucc)), RSucc),
						AccPdom#{P => {El, gb_sets:new(), gb_sets:new(), element(4, ElPdom) + 1},
							El => setelement(3, ElPdom, gb_sets:add_element(P, element(3, ElPdom)))}} end;
			true -> {NewRP, NewRS} = {array:set(P-1, gb_sets:add_element(El, array:get(P-1, AccRPred)), AccRPred), array:set(El-1, gb_sets:add_element(P, array:get(El-1, AccRSucc)), AccRSucc)},
				{false, NewRP, NewRS, sreedhar_gao_lee_add({NewRP, NewRS, Pred, Succ, AccPdom, Dom, RetReach, CrossEdges}, AccPdom, El, P)} end end end, {true, RPred, RSucc, Pdom}, Incs),
			{Pred, Succ, RP, RS, Dom, Rpd, RetReach#{P => {Set, SubGraph}}, CrossEdges};
		_ -> case S > array:size(RSucc) orelse array:get(S-1, RPred) =:= gb_sets:new() of true -> error({"Bad partial ordering", P, S}); _ -> true end,
		#{S := SPdom} = Pdom,
		{NewRPred, NewRSucc, NewPdom} = case P > array:size(RSucc) of true -> {
		array:set(P-1, gb_sets:from_list([S]), array:resize(P, RPred)),
			array:resize(P, array:set(S-1, gb_sets:add_element(P, array:get(S-1, RSucc)), RSucc)),
			Pdom#{P => {S, gb_sets:new(), gb_sets:new(), element(4, SPdom) + 1},
				S => setelement(3, SPdom, gb_sets:add_element(P, element(3, SPdom)))}};
		_ -> {array:set(P-1, gb_sets:add_element(S, array:get(P-1, RPred)), RPred), array:set(S-1, gb_sets:add_element(P, array:get(S-1, RSucc)), RSucc),
			Pdom#{P => {S, gb_sets:new(), gb_sets:new(), element(4, SPdom) + 1},
				S => setelement(3, SPdom, gb_sets:add_element(P, element(3, SPdom)))}} end,
		{RPn, RSn, RPdn, NewRetReach} = maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRetReach}) -> %case AccRetReach of #{E := {Fence, SubGraph}} when E =/= 2 ->
				case gb_sets:is_element(P, Fence) of true -> %mirror additions of edges from fence nodes into exit nodes it fences
					if S =/= E ->
					%io:format("~p~n", [{P, S, E}]),
					{NRP, NRS} = {array:set(E-1, gb_sets:add_element(S, array:get(E-1, AccRPred)), AccRPred), array:set(S-1, gb_sets:add_element(E, array:get(S-1, AccRSucc)), AccRSucc)},
					{NRP, NRS, sreedhar_gao_lee_add({NRP, NRS, Pred, Succ, AccPdom, Dom, RetReach, CrossEdges}, AccPdom, S, E), AccRetReach}; true -> {AccRPred, AccRSucc, AccPdom, AccRetReach} end;
				_ -> case gb_sets:is_element(S, SubGraph) of true -> {AccRPred, AccRSucc, AccPdom, AccRetReach#{E => {Fence, gb_sets:add_element(P, SubGraph)}}}; _ -> {AccRPred, AccRSucc, AccPdom, AccRetReach} end
			%must add to subgraph if not reachable
			%end; _ -> {AccRPred, AccRSucc, AccPdom, AccRetReach}
			end end,
			{NewRPred, NewRSucc, NewPdom, RetReach}, maps:remove(2, RetReach)), %array:get(3-1, Pred)),
			{Pred, Succ, RPn, RSn, Dom, RPdn, NewRetReach, CrossEdges} end;
	_ -> case BatchMode =/= {true, false} andalso S > array:size(Pred) of true ->
		{NPred, NSucc} = {array:set(S-1, gb_sets:from_list([P]), array:resize(S, Pred)),
			array:resize(S, array:set(P-1, gb_sets:add_element(S, array:get(P-1, Succ)), Succ))},
		{NewPred, NewSucc} = if BatchMode =:= {true, true} -> {NPred, NSucc}; true -> {array:set(2-1, gb_sets:add_element(S, array:get(2-1, NPred)), NPred), array:set(S-1, gb_sets:add_element(2, array:get(S-1, NSucc)), NSucc)} end,
		{NewDom, NewCrossEdges} = if BatchMode =:= {true, false} -> {Dom, CrossEdges}; true -> #{P := PDom} = Dom,
			ND = Dom#{S => {P, gb_sets:new(), gb_sets:new(), element(4, PDom) + 1},
						P => setelement(3, PDom, gb_sets:add_element(S, element(3, PDom)))},
			{if BatchMode =:= {true, true} -> ND; true -> sreedhar_gao_lee_add({NewPred, NewSucc, RPred, RSucc, ND, Pdom, RetReach, CrossEdges}, ND, S, 2) end,
				array:resize(S, CrossEdges)} end,
		%new nodes are always dominated by the predecessor, and the algorithm is not designed for this trivial case
		{NextRPred, NextRSucc, NextPdom, NextRetReach} = if BatchMode =:= {true, true} -> {RPred, RSucc, Pdom, RetReach}; true ->
			{NRPred, NRSucc} = {array:set(S-1, gb_sets:from_list([2]), array:resize(S, RPred)),
			array:resize(S, array:set(2-1, gb_sets:add_element(S, array:get(2-1, RSucc)), RSucc))},
		#{2 := RetPdom} = Pdom,
		{NewRPred, NewRSucc, NewPdom} = {array:set(P-1, gb_sets:add_element(S, array:get(P-1, NRPred)), NRPred), array:set(S-1, gb_sets:add_element(P, array:get(S-1, NRSucc)), NRSucc),
			Pdom#{S => {2, gb_sets:new(), gb_sets:new(), element(4, RetPdom) + 1},
				2 => setelement(3, RetPdom, gb_sets:add_element(S, element(3, RetPdom)))}},
		AddRetReach = RetReach#{2 := {gb_sets:add_element(S, begin #{2 := {CurRetSet,_}} = RetReach, CurRetSet end), gb_sets:new()}},
		RemPdom = sreedhar_gao_lee_add({NewRPred, NewRSucc, NewPred, NewSucc, NewPdom, NewDom, RetReach, CrossEdges}, NewPdom, S, P),
		#{2 := {RetSet,_}} = AddRetReach,
		case not gb_sets:is_element(P, RetSet) of true ->
			NewRetSet = gb_sets:union(fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [array:get(El-1, NewPred)|Acc] end, [], X)))),
				case gb_sets:size(Y) of 0 -> Comb; _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([P])), RetSet),
			%io:format("~p~n", [{P, S, gb_sets:to_list(NewRetSet), gb_sets:to_list(AddedRetSet)}]),
			maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %check all subgraphs for any added from the return set, update fence and subgraph carefully
				%#{E := {Fence, SubGraph}} = AccRet,
				{DelSubGraph, NotDelSubGraph} = gb_sets:fold(fun (El, {D, ND}) -> case gb_sets:is_element(El, NewRetSet) andalso not gb_sets:is_element(El, RetSet) of true -> {[El|D], ND}; _ -> {D, [El|ND]} end end, {[], []}, SubGraph),
				case DelSubGraph of [] -> {AccRPred, AccRSucc, AccPdom, AccRet};
				_ -> NDSG = gb_sets:from_list(NotDelSubGraph),
				{NewFence, _} = pred_set_recurse(NDSG, NewRetSet, {NewPred, NewSucc, AccRPred, AccRSucc, NewDom, RemPdom, RetReach, NewCrossEdges}),				
				{DelFence, NotDelFence} = gb_sets:fold(fun (El, {DF, F}) -> case not gb_sets:is_element(El, NewFence) of true -> {[El|DF], F}; _ -> {DF, [El|F]} end end, {[], []}, Fence),
				DelEdges = gb_sets:del_element(E, gb_sets:union(lists:foldl(fun (X, Acc) -> [array:get(X-1, NewSucc)|Acc] end, [], DelFence))),
				TotNewFence = gb_sets:union(gb_sets:from_list(NotDelFence), NewFence),
				NewEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, NewSucc)|Acc] end, [], TotNewFence))),
				%io:format("~p~n", [{E, gb_sets:to_list(DelFence), gb_sets:to_list(NewFence), gb_sets:to_list(Fence), gb_sets:to_list(SubGraph), gb_sets:to_list(DelSubGraph), gb_sets:to_list(DelEdges), gb_sets:to_list(NewEdges)}]),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case gb_sets:is_element(El, NewEdges) orelse not gb_sets:is_element(array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NewRP, NewRS} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
					{NewRP, NewRS, sreedhar_gao_lee_remove({NewRP, NewRS, NewPred, NewSucc, AcPdom, NewDom, RetReach, CrossEdges}, AcPdom, El, E)} end end,
					gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
						case gb_sets:is_element(El, DelEdges) orelse gb_sets:is_element(array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
						{NewRP, NewRS} = {array:set(E-1, gb_sets:add_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:add_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
						{NewRP, NewRS, sreedhar_gao_lee_add({NewRP, NewRS, NewPred, NewSucc, AcPdom, NewDom, RetReach, CrossEdges}, AcPdom, El, E)} end end, {AccRPred, AccRSucc, AccPdom}, NewEdges),
					DelEdges),
				{RPn, RSn, RPdn, case gb_sets:size(SubGraph) =:= length(DelSubGraph) of true -> maps:remove(E, AccRet); _ -> AccRet#{E := {TotNewFence, NDSG}} end} end end,
				case AddRetReach of #{P := _} ->
				%merge nodes will go back from the exit set to the return set and should be unwound
				DelEdges = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], begin #{P := {PFence, _}} = AddRetReach, PFence end))),
				%io:format("~p~n", [gb_sets:to_list(DelEdges)]),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case not gb_sets:is_element(El, array:get(P-1, RPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NewRP, NewRS} = {array:set(P-1, gb_sets:del_element(El, array:get(P-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(P, array:get(El-1, AcRSucc)), AcRSucc)},
					{NewRP, NewRS, sreedhar_gao_lee_remove({NewRP, NewRS, NewPred, NewSucc, AcPdom, NewDom, RetReach, CrossEdges}, AcPdom, El, P)} end end, 
					begin
						{NewRP, NewRS} = {array:set(P-1, gb_sets:add_element(S, array:get(P-1, NewRPred)), NewRPred), array:set(S-1, gb_sets:add_element(P, array:get(S-1, NewRSucc)), NewRSucc)},
						{NewRP, NewRS, sreedhar_gao_lee_add({NewRP, NewRS, NewPred, NewSucc, RemPdom, NewDom, RetReach, CrossEdges}, RemPdom, S, P)} end,
					DelEdges),
				{RPn, RSn, RPdn, maps:remove(P, AddRetReach#{2 := {NewRetSet, gb_sets:new()}})}; _ -> {NewRPred, NewRSucc, RemPdom, AddRetReach#{2 := {NewRetSet, gb_sets:new()}}} end, maps:remove(2, AddRetReach)) %gb_sets:del_element(2, array:get(3-1, NewPred)))
		; _ -> {RPn, RSn, RPdn} = maps:fold(fun (E, {Fence, _SubGraph}, {AccRPred, AccRSucc, AccPdom}) -> %#{E := {Fence, SubGraph}} = AddRetReach,
				%io:format("~p~n", [{P, S, E}]),
				case gb_sets:is_element(P, Fence) of true -> %mirror additions of edges from fence nodes into exit nodes it fences
					if S =/= E ->
					{NRP, NRS} = {array:set(E-1, gb_sets:add_element(S, array:get(E-1, AccRPred)), AccRPred), array:set(S-1, gb_sets:add_element(E, array:get(S-1, AccRSucc)), AccRSucc)},
					{NRP, NRS, sreedhar_gao_lee_add({NRP, NRS, NewPred, NewSucc, AccPdom, NewDom, RetReach, CrossEdges}, AccPdom, S, E)}; true -> {AccRPred, AccRSucc, AccPdom} end;
				_ -> {AccRPred, AccRSucc, AccPdom} end end,
			{NewRPred, NewRSucc, RemPdom}, maps:remove(2, RetReach)), %gb_sets:del_element(2, array:get(3-1, NewPred))),
			{RPn, RSn, RPdn, AddRetReach} end end,
		{NewPred, NewSucc,
		 	NextRPred, NextRSucc, NewDom, NextPdom, NextRetReach,
			case BatchMode =:= false andalso has_cross_edge(AST, {NewPred, NewSucc, NextRPred, NextRSucc, NewDom, NextPdom, NextRetReach, NewCrossEdges}, S, 2) of true ->
				array:set(2-1, gb_sets:add_element(S, array:get(2-1, NewCrossEdges)), NewCrossEdges); _ -> NewCrossEdges end};
	_ ->
		{AddPred, AddSucc} = if BatchMode =:= {true, false} -> {Pred, Succ}; true -> {array:set(S-1, gb_sets:add_element(P, array:get(S-1, Pred)), Pred), %P->S and S->P
			array:set(P-1, gb_sets:add_element(S, array:get(P-1, Succ)), Succ)} end,
		NextDom = if BatchMode =:= {true, false} -> Dom; true ->
			sreedhar_gao_lee_add({AddPred, AddSucc, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}, Dom, P, S) end,
		{AddRPred, AddRSucc, NextPdom, NextReach} = if BatchMode =:= {true, true} -> {RPred, RSucc, Pdom, RetReach}; true ->
		{RemRPred, RemRSucc} = case S =:= 3 andalso gb_sets:to_list(array:get(2-1, Succ)) =:= [3] of true -> {RPred, RSucc}; _ -> {array:set(P-1, gb_sets:add_element(S, array:get(P-1, RPred)), RPred), %P->3 then P->SUCCS(PredSetRecurse(P)), must store entire subgraph not just reaching fence {IsMerge, Node, SubGraph, Fence}
			array:set(S-1, gb_sets:add_element(P, array:get(S-1, RSucc)), RSucc)} end,
		RemPdom = case S =:= 3 andalso gb_sets:to_list(array:get(2-1, Succ)) =:= [3] of true -> Pdom; _ -> sreedhar_gao_lee_add({RemRPred, RemRSucc, AddPred, AddSucc, Pdom, NextDom, RetReach, CrossEdges}, Pdom, S, P) end,
		#{2 := {RetSet,_}} = RetReach, SInRetSet = gb_sets:is_element(S, RetSet),
		case not gb_sets:is_element(P, RetSet) andalso SInRetSet of true -> %NewReach =/= []
			if P =:= 3 -> %if totally disconnected, make return node root connected to exit node, and undo all fences restoring back to exit node
				{RPExit, RSExit, PDomExit, PDomReach} = maps:fold(fun (E, {Fence, _}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %case AccRet of #{E := {Fence, _}} ->
				DelEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], Fence))),
				%io:format("~p~n", [{E, gb_sets:to_list(Fence), gb_sets:to_list(DelEdges), gb_sets:to_list(array:get(E-1, RPred))}]),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) -> %io:format("~p~n", [{El, E, get_edgeset(AcRSucc)}]),
					case not gb_sets:is_element(El, array:get(E-1, RemRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NewRPred, NewRSucc} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
					{NewRPred, NewRSucc, sreedhar_gao_lee_remove({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, AccRet, CrossEdges}, AcPdom, El, E)} end end,
					begin
						{NewRPred, NewRSucc} = {array:set(E-1, gb_sets:add_element(P, array:get(E-1, AccRPred)), AccRPred), array:set(P-1, gb_sets:add_element(E, array:get(P-1, AccRSucc)), AccRSucc)},
						{NewRPred, NewRSucc, sreedhar_gao_lee_add({NewRPred, NewRSucc, AddPred, AddSucc, AccPdom, NextDom, AccRet, CrossEdges}, AccPdom, P, E)} end,
					DelEdges),
				{RPn, RSn, RPdn, maps:remove(E, AccRet)} %; _ -> {AccRPred, AccRSucc, AccPdom, AccRet} end
				end,
				{RemRPred, RemRSucc, RemPdom, RetReach#{2 := {gb_sets:new(), gb_sets:new()}}}, maps:remove(2, RetReach)), %gb_sets:del_element(S, gb_sets:del_element(2, array:get(3-1, AddPred)))),
				%now remove 3->2, add 2->3 and manually update dominator to re-root the tree at 2 not 3
				{RPRet, RSRet} = {array:set(2-1, gb_sets:del_element(3, array:get(2-1, RPExit)), RPExit), array:set(3-1, gb_sets:del_element(2, array:get(3-1, RSExit)), RSExit)},
				{RPFinal, RSFinal} = {array:set(3-1, gb_sets:add_element(2, array:get(3-1, RPRet)), RPRet), array:set(2-1, gb_sets:add_element(3, array:get(2-1, RSRet)), RSRet)},
				UpPdom = do_tarjan_immdom({RPFinal, RSFinal, AddPred, AddSucc, PDomExit, NextDom, PDomReach, CrossEdges}, 2), %root node incremental change is basically a moot point when the whole tree has changed
				FinPdom = d_to_dom(UpPdom, get_j_succ(RSFinal, UpPdom), make_dom_tree(UpPdom), dom_depth(UpPdom)),
				%UpPdom = setelement(1, PDomExit, setelement(3, setelement(2, element(1, PDomExit), 0), 2)),
				%FinPdom = setelement(4, setelement(3, UpPdom, setelement(2, setelement(3, element(3, UpPdom), gb_sets:del_element(2, element(3, element(3, UpPdom)))), gb_sets:add_element(3, element(2, element(3, UpPdom))))),
				%	dom_depth(element(1, UpPdom))),
				%case cmp_edgeset(make_dom_tree(element(1, UpPdom)), element(3, FinPdom)) of false -> io:format("~p~n", [{P, S, element(1, FinPdom), get_edgeset(make_dom_tree(element(1, UpPdom))), get_edgeset(element(3, FinPdom))}]); _ -> true end,
				{RPFinal, RSFinal, FinPdom, PDomReach}; %remove that 3 dominates 2, add 2 dominates 3, update level depth by +1 for all not dominated by 2 otherwise -1 - its just as well to do a full recomputation since every depth changes
			true ->
			%if RetReach changed, need to determine which PredSetRecurse(PREDS(Exit)) changed, fence narrowed (any changed in subgraph move to fence, remove from subgraph and fence if not any SUCCS(REVREACH(changed in subgraph)) still in subgraph), add SUCCS(NewFenc) \ SUCCS(OldFence) and remove SUCCS(OldFence) \ SUCCS(NewFenc)
			NewRetSet = gb_sets:union(fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [array:get(El-1, Pred)|Acc] end, [], X)))),
				case gb_sets:size(Y) of 0 -> Comb; _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([P])), RetSet),
			%io:format("~p~n", [{P, S, gb_sets:to_list(NewRetSet), gb_sets:to_list(AddedRetSet)}]),
			maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %#{E := {Fence, SubGraph}} = AccRet, %check all subgraphs for any added from the return set, update fence and subgraph carefully
				{DelSubGraph, NotDelSubGraph} = gb_sets:fold(fun (El, {D, ND}) -> case gb_sets:is_element(El, NewRetSet) andalso not gb_sets:is_element(El, RetSet) of true -> {[El|D], ND}; _ -> {D, [El|ND]} end end, {[], []}, SubGraph),
				case DelSubGraph of [] -> {AccRPred, AccRSucc, AccPdom, AccRet};
				_ -> NDSG = gb_sets:from_list(NotDelSubGraph),
				{NewFence, _} = pred_set_recurse(NDSG, NewRetSet, {AddPred, AddSucc, RemRPred, RemRSucc, NextDom, RemPdom, RetReach, CrossEdges}),
				{DelFence, NotDelFence} = gb_sets:fold(fun (El, {DF, F}) -> case not gb_sets:is_element(El, NewFence) of true -> {[El|DF], F}; _ -> {DF, [El|F]} end end, {[], []}, Fence),
				DelEdges = gb_sets:del_element(E, gb_sets:union(lists:foldl(fun (X, Acc) -> [array:get(X-1, AddSucc)|Acc] end, [], DelFence))),
				TotNewFence = gb_sets:union(gb_sets:from_list(NotDelFence), NewFence),
				NewEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, AddSucc)|Acc] end, [], TotNewFence))),
				%io:format("~p~n", [{E, gb_sets:to_list(DelFence), gb_sets:to_list(NewFence), gb_sets:to_list(Fence), gb_sets:to_list(SubGraph), gb_sets:to_list(DelSubGraph), gb_sets:to_list(DelEdges), gb_sets:to_list(NewEdges)}]),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case gb_sets:is_element(El, NewEdges) orelse not gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NewRPred, NewRSucc} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
					{NewRPred, NewRSucc, sreedhar_gao_lee_remove({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, RetReach, CrossEdges}, AcPdom, El, E)} end end,
					gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
						case gb_sets:is_element(El, DelEdges) orelse gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
						{NewRPred, NewRSucc} = {array:set(E-1, gb_sets:add_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:add_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
						{NewRPred, NewRSucc, sreedhar_gao_lee_add({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, RetReach, CrossEdges}, AcPdom, El, E)} end end, {AccRPred, AccRSucc, AccPdom}, NewEdges),
					DelEdges),
				{RPn, RSn, RPdn, case gb_sets:size(SubGraph) =:= length(DelSubGraph) of true -> maps:remove(E, AccRet); _ -> AccRet#{E := {TotNewFence, NDSG}} end} end end,
				case S =:= 2 andalso (BatchMode =/= {true, false} orelse gb_sets:is_element(3, array:get(P-1, Succ))) of true -> %merge nodes will go back from the exit set to the return set and should be unwound
				DelEdges = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], begin #{P := {PFence, _}} = RetReach, PFence end))),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case not gb_sets:is_element(El, array:get(P-1, RemRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NewRPred, NewRSucc} = {array:set(P-1, gb_sets:del_element(El, array:get(P-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(P, array:get(El-1, AcRSucc)), AcRSucc)},
					{NewRPred, NewRSucc, sreedhar_gao_lee_remove({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, RetReach, CrossEdges}, AcPdom, El, P)} end end, 
					{RemRPred, RemRSucc, RemPdom},
					DelEdges),
				{RPn, RSn, RPdn, maps:remove(P, RetReach#{2 := {gb_sets:add_element(P, RetSet), gb_sets:new()}})};
				_ -> {RemRPred, RemRSucc, RemPdom, RetReach#{2 := {NewRetSet, gb_sets:new()}}} end, maps:remove(2, RetReach)) end; %case S =:= 2 andalso (BatchMode =/= {true, false} orelse gb_sets:is_element(3, array:get(P-1, Succ))) of true -> gb_sets:del_element(P, gb_sets:del_element(2, array:get(3-1, Pred))); _ -> gb_sets:del_element(2, array:get(3-1, Pred)) end) end;
		_ -> if S =:= 3 -> case fun CheckPreds(It) -> case gb_sets:next(It) of none -> false; {El, NextIt} -> case gb_sets:is_element(El, RetSet) of true -> true; _ -> CheckPreds(NextIt) end end end(gb_sets:iterator(array:get(P-1, Succ))) of true -> {RemRPred, RemRSucc, RemPdom, RetReach};
			_ -> %if already not reaching the return and also exiting such as on code duplication, also must make consistent
				{Set, SubGraph} = pred_set_recurse(gb_sets:from_list([P]), RetSet, {AddPred, AddSucc, RemRPred, RemRSucc, NextDom, RemPdom, RetReach, CrossEdges}),
				Incs = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], Set))),
				%io:format("~p~n", [{P, S, gb_sets:to_list(Set), gb_sets:to_list(SubGraph), gb_sets:to_list(RetSet), gb_sets:to_list(Incs)}]),
				{RP, RS, Rpd} = gb_sets:fold(fun (El, {AccRPred, AccRSucc, AccPdom}) ->
					case gb_sets:is_element(El, array:get(P-1, RemRPred)) of true -> {AccRPred, AccRSucc, AccPdom}; _ ->
					{NewRPred, NewRSucc} = {array:set(P-1, gb_sets:add_element(El, array:get(P-1, AccRPred)), AccRPred), array:set(El-1, gb_sets:add_element(P, array:get(El-1, AccRSucc)), AccRSucc)},
					{NewRPred, NewRSucc, sreedhar_gao_lee_add({NewRPred, NewRSucc, AddPred, AddSucc, AccPdom, NextDom, RetReach, CrossEdges}, AccPdom, El, P)} end end, {RemRPred, RemRSucc, RemPdom}, Incs),
				{RP, RS, Rpd, RetReach#{P => {Set, SubGraph}}} end;
		true -> PInRetSet = gb_sets:is_element(P, RetSet),
			maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %case AccRet of #{E := {Fence, SubGraph}} -> %for {true, false} batch add
			%io:format("~p~n", [{P, S, E, gb_sets:to_list(Fence), gb_sets:to_list(SubGraph)}]),
				case PInRetSet andalso gb_sets:is_element(P, Fence) of true -> %mirror additions of edges from fence nodes into exit nodes it fences
					if S =/= E ->
					{NRP, NRS} = {array:set(E-1, gb_sets:add_element(S, array:get(E-1, AccRPred)), AccRPred), array:set(S-1, gb_sets:add_element(E, array:get(S-1, AccRSucc)), AccRSucc)},
					{NRP, NRS, sreedhar_gao_lee_add({NRP, NRS, AddPred, AddSucc, AccPdom, NextDom, RetReach, CrossEdges}, AccPdom, S, E), AccRet}; true -> {AccRPred, AccRSucc, AccPdom, AccRet} end;
				_ -> case P =:= E andalso gb_sets:is_element(3, array:get(P-1, Succ)) of true ->
						DelEdges = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], begin #{P := {PFence, _}} = RetReach, PFence end))),
						{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
							case not gb_sets:is_element(El, array:get(P-1, RemRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
							{NewRPred, NewRSucc} = {array:set(P-1, gb_sets:del_element(El, array:get(P-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(P, array:get(El-1, AcRSucc)), AcRSucc)},
							{NewRPred, NewRSucc, sreedhar_gao_lee_remove({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, RetReach, CrossEdges}, AcPdom, El, P)} end end,
							{RemRPred, RemRSucc, RemPdom},
							DelEdges),
						{RPn, RSn, RPdn, maps:remove(P, RetReach)};
					_ -> case not SInRetSet andalso gb_sets:is_element(S, SubGraph) andalso not gb_sets:is_element(P, SubGraph) of true -> %andalso gb_sets:is_element(P, RetSet) of true -> %new fence entry or new subgraph entry causing new fence
					{NewFence, NewSubGraph} = pred_set_recurse(gb_sets:from_list([S]), RetSet, {AddPred, AddSucc, RemRPred, RemRSucc, NextDom, RemPdom, RetReach, CrossEdges}),
					%DelFence = gb_sets:filter(fun (El) -> end, Fence)
					Incs = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, AccRPred)|Acc] end, [], NewFence))), %gb_sets:del_element(E, array:get(P-1, AddSucc)),
					%io:format("~p~n", [{E, gb_sets:to_list(element(hd(gb_sets:to_list(Fence)), AddSucc)), gb_sets:to_list(Incs), gb_sets:to_list(NewFence), gb_sets:to_list(Fence), gb_sets:to_list(SubGraph)}]),
					{RP, RS, Rpd} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
						case gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
						{NewRPred, NewRSucc} = {array:set(E-1, gb_sets:add_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:add_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
						{NewRPred, NewRSucc, sreedhar_gao_lee_add({NewRPred, NewRSucc, AddPred, AddSucc, AcPdom, NextDom, RetReach, CrossEdges}, AcPdom, El, E)} end end, {AccRPred, AccRSucc, AccPdom}, Incs),
					{RP, RS, Rpd, AccRet#{E := {gb_sets:union(NewFence, Fence), gb_sets:union(SubGraph, NewSubGraph)}}};
				_ -> {AccRPred, AccRSucc, AccPdom, AccRet} end end end %; _ -> {AccRPred, AccRSucc, AccPdom, AccRet} end
				end,
			{RemRPred, RemRSucc, RemPdom, RetReach}, maps:remove(2, RetReach)) end end end, %gb_sets:del_element(2, array:get(3-1, Pred))) end end end,
		{AddPred, AddSucc, AddRPred, AddRSucc, NextDom, NextPdom, NextReach, CrossEdges}
	end end, %has_cross_edge(AST, P, S)
	%case do_tarjan_immdom(FinGraph, 1) =/= element(1, element(5, FinGraph)) of true -> error({P, S, do_tarjan_immdom(FinGraph, 1), element(5, FinGraph)}); _ -> true end,
	%if BatchMode =:= {true, false} andalso not (P > array:size(RSucc) orelse element(P, RSucc) =:= {0,nil}) -> case do_tarjan_immdom({element(3, FinGraph), element(4, FinGraph), element(1, FinGraph), element(2, FinGraph), element(6, FinGraph), element(5, FinGraph), element(7, FinGraph), element(8, FinGraph)}, 3) =/= element(1, element(6, FinGraph)) of true -> io:format("~p~n", [{P, S, do_tarjan_immdom({element(3, FinGraph), element(4, FinGraph), element(1, FinGraph), element(2, FinGraph), element(6, FinGraph), element(5, FinGraph), element(7, FinGraph), element(8, FinGraph)}, 3), element(6, FinGraph)}]), error(true); _ -> true end; true -> true end,
	FinCrossGraph = case BatchMode =/= {true, false} andalso has_cross_edge(AST, FinGraph, P, S) of true -> setelement(8, FinGraph, array:set(S-1, gb_sets:add_element(P, array:get(S-1, element(8, FinGraph))), element(8, FinGraph))); _ -> FinGraph end,

	%case BatchMode =/= false orelse S =:= 3 orelse gb_sets:to_list(element(3, element(2, FinCrossGraph))) =:= [2] orelse lists:all(fun (El) -> if El =:= P andalso S =/= 3 -> true; true -> {Fence, SubG} = maps:get(El, element(7, FinCrossGraph)),
	%	{F, SG} = pred_set_recurse(gb_sets:from_list([El]), element(1, maps:get(2, element(7, FinCrossGraph))), FinCrossGraph),
	%	case El =:= 2 orelse gb_sets:to_list(Fence) =:= gb_sets:to_list(F) andalso gb_sets:to_list(SubG) =:= gb_sets:to_list(SG) of true -> true;
	%	_ -> io:format("~p~n", [{El, gb_sets:to_list(Fence), gb_sets:to_list(SubG), gb_sets:to_list(F), gb_sets:to_list(SG)}]), false end end end, gb_sets:to_list(element(3, element(1, FinCrossGraph)))) of false -> error({"Bad fence/subgraph", P, S}); _ -> true end,
	%case BatchMode =/= {true, true} andalso gb_sets:to_list(element(3, element(2, FinCrossGraph))) =/= [2] of true ->
	%{PostDoms, RR, PostDomGraph} = get_post_dom(FinCrossGraph),
	%case gb_sets:to_list(element(1, maps:get(2, element(7, FinCrossGraph)))) =:= gb_sets:to_list(RR) of false -> error({P, S, gb_sets:to_list(element(1, maps:get(2, element(7, FinCrossGraph)))), gb_sets:to_list(RR)}); _ -> true end,
	%case P =:= 3 orelse cmp_edgeset(element(2, PostDomGraph), element(3, FinCrossGraph)) andalso cmp_edgeset(element(1, PostDomGraph), element(4, FinCrossGraph)) of false -> error({P, S, get_edgeset(element(1, PostDomGraph)), get_edgeset(element(4, FinCrossGraph))}); _ -> true end,
	%case S =/= 3 andalso PostDoms =/= maps:fold(fun (El, {_, _}, Acc) -> case El =:= 2 of true -> Acc; _ -> setelement(El, Acc, 3) end end, case S =:= 3 orelse gb_sets:is_element(3, element(P, Succ)) of true -> setelement(P, element(1, element(6, FinCrossGraph)), 3); _ -> element(1, element(6, FinCrossGraph)) end, element(7, FinCrossGraph)) of true -> error({P, S, PostDoms, maps:fold(fun (El, {_, _}, Acc) -> case El =:= 2 of true -> Acc; _ -> setelement(El, Acc, 3) end end, case S =:= 3 orelse gb_sets:is_element(3, element(P, Succ)) of true -> setelement(P, element(1, element(6, FinCrossGraph)), 3); _ -> element(1, element(6, FinCrossGraph)) end, element(7, FinCrossGraph))}); _ -> true end;
	%_ -> true end,

	case BatchMode =:= false andalso gb_sets:size(array:get(P-1, Succ)) =:= 1 andalso gb_sets:to_list(array:get(P-1, Succ)) =:= [2] of true -> remove_edge(P, 2, FinCrossGraph, AST, BatchMode); _ -> case BatchMode =:= false andalso gb_sets:size(array:get(P-1, Succ)) =:= 1 andalso gb_sets:is_element(3, array:get(P-1, Succ)) of true -> remove_edge(P, 3, FinCrossGraph, AST, BatchMode); _ -> FinCrossGraph end end
.

remove_edge(P, S, {Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}, AST, BatchMode) -> %sanity checks: cannot remove non-existant edges, removal cannot disconnect graph
	case not gb_sets:is_element(S, array:get(P-1, Succ)) of
	true -> error({P, S, get_edgeset(Succ)}); _ -> true end,
	%io:format("~p~n", [{true, P, S, get_edgeset(Succ), BatchMode}]),
	{ExitPred, ExitSucc, ExitRPred, ExitRSucc,
		ExitDom, ExitPdom, ExitRetReach, ExitCrossEdges} =
			case S =:= 2 andalso gb_sets:size(array:get(S-1, Pred)) =:= 1 andalso gb_sets:to_list(array:get(S-1, Pred)) =:= [P] of true ->
		add_edge(3, 2, remove_edge(2, 3, {Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges}, AST, BatchMode), AST, BatchMode); _ -> {Pred, Succ, RPred, RSucc, Dom, Pdom, RetReach, CrossEdges} end,
	{RemPred, RemSucc} = {array:set(S-1, gb_sets:del_element(P, array:get(S-1, ExitPred)), ExitPred), array:set(P-1, gb_sets:del_element(S, array:get(P-1, ExitSucc)), ExitSucc)},
	%case check_pred_succ({RemPred, RemSucc, ExitRPred, ExitRSucc, ExitDom, ExitPdom, ExitRetReach, ExitCrossEdges}) of false -> error({"Graph sanity check failed", P, S, RemPred, RemSucc}); _ -> true end,
	NextDom = if BatchMode =:= {true, false} -> ExitDom; true -> sreedhar_gao_lee_remove({RemPred, RemSucc, ExitRPred, ExitRSucc, ExitDom, ExitPdom, ExitRetReach, ExitCrossEdges}, ExitDom, P, S) end,
	{FinRPred, FinRSucc, FinPdom, NextReach} = if BatchMode =:= {true, true} -> {ExitRPred, ExitSucc, ExitPdom, ExitRetReach}; true ->
	#{2 := {ExitRetSet,_}} = ExitRetReach,
	%io:format("~p~n", [{P, S, gb_sets:to_list(array:get(P-1, RemSucc))}]),
	{RemRPred, RemRSucc, RemPdom, RemRetReach} = case S =:= 2 andalso gb_sets:size(array:get(S-1, ExitRPred)) =:= 0 of true ->
			{NewRP, NewRS} = {array:set(P-1, gb_sets:add_element(3, array:get(P-1, ExitRPred)), ExitRPred), array:set(3-1, gb_sets:add_element(P, array:get(3-1, ExitRSucc)), ExitRSucc)},
			%io:format("~p~n", [{P, S, get_edgeset(NewRS), ExitPdom}]),
			{NewRP, NewRS, sreedhar_gao_lee_add({NewRP, NewRS, RemPred, RemSucc, ExitPdom, NextDom, ExitRetReach, ExitCrossEdges}, ExitPdom, 3, P), ExitRetReach};
		_ -> case gb_sets:is_element(S, ExitRetSet) andalso gb_sets:is_element(3, array:get(P-1, RemSucc)) of true ->
		NotReach = neg_rev_reach(gb_sets:from_list([P]), gb_sets:new(), ExitRetSet, {RemPred, RemSucc, ExitRPred, ExitRSucc, NextDom, ExitPdom, ExitRetReach, ExitCrossEdges}),
		{Set, SubG} = pred_set_recurse(gb_sets:from_list([P]), gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, NotReach) of true -> [El|Acc]; _ -> Acc end end, [], ExitRetSet)), {RemPred, RemSucc, ExitRPred, ExitRSucc, NextDom, ExitPdom, ExitRetReach, ExitCrossEdges}),
		Incs = gb_sets:del_element(P, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, Succ)|Acc] end, [], Set))),
		%io:format("~p~n", [{P, S, gb_sets:to_list(Set), gb_sets:to_list(SubG), gb_sets:to_list(gb_sets:subtract(ExitRetSet, NotReach)), gb_sets:to_list(NotReach), gb_sets:to_list(Incs)}]),
		{RP, RS, Rpd} = gb_sets:fold(fun (El, {AccRPred, AccRSucc, AccPdom}) -> %io:format("~p~n", [get_edgeset(setelement(El, AccRSucc, gb_sets:add_element(P, element(El, AccRSucc))))]),
			case gb_sets:is_element(El, array:get(P-1, ExitRPred)) of true -> {AccRPred, AccRSucc, AccPdom}; _ ->
			{NewRPred, NewRSucc} = {array:set(P-1, gb_sets:add_element(El, array:get(P-1, AccRPred)), AccRPred), array:set(El-1, gb_sets:add_element(P, array:get(El-1, AccRSucc)), AccRSucc)},
			{NewRPred, NewRSucc, sreedhar_gao_lee_add({NewRPred, NewRSucc, RemPred, RemSucc, AccPdom, NextDom, ExitRetReach, ExitCrossEdges}, AccPdom, El, P)} end end, {ExitRPred, ExitRSucc, ExitPdom}, Incs),
		{RP, RS, Rpd, ExitRetReach#{2 := {gb_sets:del_element(P, ExitRetSet), ordsets:new()}, P => {Set, SubG}}};
	_ -> {ExitRPred, ExitRSucc, ExitPdom, ExitRetReach} end
	end,
	%case do_tarjan_immdom({RemRPred, RemRSucc, RemPred, RemSucc, RemPdom, NextDom, RemRetReach, ExitCrossEdges}, case gb_sets:to_list(element(3, RemSucc)) =/= [] of true -> 2; _ -> 3 end) =/= element(1, RemPdom) of true -> error({P, S, do_tarjan_immdom({RemRPred, RemRSucc, RemPred, RemSucc, RemPdom, NextDom, RemRetReach, ExitCrossEdges}, case gb_sets:to_list(element(3, RemSucc)) =/= [] of true -> 2; _ -> 3 end), RemPdom}); _ -> true end,
	{NewRPred, NewRSucc} = if S =:= 3 -> {RemRPred, RemRSucc}; true -> {array:set(P-1, gb_sets:del_element(S, array:get(P-1, RemRPred)), RemRPred), array:set(S-1, gb_sets:del_element(P, array:get(S-1, RemRSucc)), RemRSucc)} end,
	NextPdom = if S =:= 3 -> RemPdom; true -> sreedhar_gao_lee_remove({NewRPred, NewRSucc, RemPred, RemSucc, RemPdom, NextDom, RemRetReach, ExitCrossEdges}, RemPdom, S, P) end,
	%io:format("~p~n", [{P, S, get_edgeset(NewRPred), get_edgeset(NewRSucc), ExitPdom, NextPdom}]),
	%case do_tarjan_immdom({NewRPred, NewRSucc, RemPred, RemSucc, NextPdom, NextDom, RemRetReach, ExitCrossEdges}, case gb_sets:to_list(element(3, RemSucc)) =/= [] of true -> 2; _ -> 3 end) =/= element(1, NextPdom) of true -> error({P, S, gb_sets:to_list(element(3, RemSucc)), do_tarjan_immdom({NewRPred, NewRSucc, RemPred, RemSucc, NextPdom, NextDom, RemRetReach, ExitCrossEdges}, case gb_sets:to_list(element(3, RemSucc)) =/= [] of true -> 2; _ -> 3 end), NextPdom, element(1, RemPdom)}); _ -> true end,
	#{2 := {NextRetSet,_}} = RemRetReach,
	%io:format("~p~n", [{gb_sets:to_list(NextRetSet), gb_sets:to_list(array:get(P-1, RemSucc))}]),
	SInRetSet = gb_sets:is_element(S, NextRetSet),
	case SInRetSet andalso not fun AnyChange(Acc) -> case gb_sets:next(Acc) of none -> false; {El, NewAcc} -> case gb_sets:is_element(El, NextRetSet) of true -> true; _ -> AnyChange(NewAcc) end end end(gb_sets:iterator(array:get(P-1, RemSucc))) of true -> %if RetReach changed, need to determine which PredSetRecurse(PREDS(Exit)) changed, fence expanded (any changed in fence move to subgraph, REVREACH(changed in fence) compute partial new subgraph and fence), add SUCCS(NewFenc) \ SUCCS(OldFence) and remove SUCCS(OldFence) \ SUCCS(NewFenc)
		NowRetSet = gb_sets:del_element(P, NextRetSet),
		NegRev = neg_rev_reach(gb_sets:from_list([P]), gb_sets:new(), NowRetSet, {RemPred, RemSucc, NewRPred, NewRSucc, NextDom, NextPdom, RemRetReach, ExitCrossEdges}),
		NewRetSet = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, NegRev) of true -> [El|Acc]; _ -> Acc end end, [], NowRetSet)),
		%io:format("~p~n", [{P, S, gb_sets:to_list(NewRetSet), gb_sets:to_list(DeletedRetSet), get_edgeset(RemSucc), NextPdom, RemRetReach}]),
		maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %#{E := {Fence, SubGraph}} = AccRet, %check all fences for any deleted from the return set, update fence and subgraph carefully
			{DelFence, NotDelFence} = gb_sets:fold(fun (El, {DF, F}) -> case gb_sets:is_element(El, NextRetSet) andalso not gb_sets:is_element(El, NewRetSet) of true -> {[El|DF], F}; _ -> {DF, [El|F]} end end, {[], []}, Fence),
			case DelFence of [] -> {AccRPred, AccRSucc, AccPdom, AccRet}; _ ->
			{NewFence, AddSubGraph} = pred_set_recurse(gb_sets:from_list(DelFence), NewRetSet, {RemPred, RemSucc, AccRPred, AccRSucc, NextDom, AccPdom, RemRetReach, ExitCrossEdges}),
			DelEdges = gb_sets:union(case gb_sets:is_element(P, Fence) of true -> gb_sets:from_list([S]); _ -> gb_sets:new() end, gb_sets:del_element(E, gb_sets:union(lists:foldl(fun (X, Acc) -> [array:get(X-1, ExitSucc)|Acc] end, [], DelFence)))), %current element also needs mirroring
			TotNewFence = gb_sets:union(gb_sets:from_list(NotDelFence), NewFence),
			NewEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, RemSucc)|Acc] end, [], TotNewFence))),
			%io:format("~p~n", [{E, gb_sets:to_list(DelFence), gb_sets:to_list(NewFence), gb_sets:to_list(Fence), gb_sets:to_list(SubGraph), gb_sets:to_list(AddSubGraph), gb_sets:to_list(DelEdges), gb_sets:to_list(NewEdges)}]),
			{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
				case gb_sets:is_element(El, NewEdges) orelse not gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
				{NRP, NRS} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
				{NRP, NRS, sreedhar_gao_lee_remove({NRP, NRS, RemPred, RemSucc, AcPdom, NextDom, RemRetReach, ExitCrossEdges}, AcPdom, El, E)} end end,
				gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case gb_sets:is_element(El, DelEdges) orelse gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NRP, NRS} = {array:set(E-1, gb_sets:add_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:add_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
					{NRP, NRS, sreedhar_gao_lee_add({NRP, NRS, RemPred, RemSucc, AcPdom, NextDom, RemRetReach, ExitCrossEdges}, AcPdom, El, E)} end end, {AccRPred, AccRSucc, AccPdom}, NewEdges),
				DelEdges),
			{RPn, RSn, RPdn, AccRet#{E := {TotNewFence, gb_sets:union(SubGraph, AddSubGraph)}}} end end,
			{NewRPred, NewRSucc, NextPdom, RemRetReach#{2 := {NewRetSet, gb_sets:new()}}}, maps:remove(2, RemRetReach)); %gb_sets:del_element(2, array:get(3-1, RemPred)));
	_ -> PInRetSet = gb_sets:is_element(P, NextRetSet), maps:fold(fun (E, {Fence, SubGraph}, {AccRPred, AccRSucc, AccPdom, AccRet}) -> %case AccRet of #{E := {Fence, SubGraph}} -> %for the return/exit swap case
			%io:format("~p~n", [{E, gb_sets:to_list(Fence), gb_sets:to_list(SubGraph)}]),
			case PInRetSet andalso gb_sets:is_element(P, Fence) of true ->
				%io:format("~p~n", [E]),
				case not fun CheckPreds(It) -> case gb_sets:next(It) of none -> false; {El, NextIt} -> case gb_sets:is_element(El, SubGraph) of true -> true; _ -> CheckPreds(NextIt) end end end(gb_sets:iterator(array:get(P-1, AccRPred))) of true -> %delete from fence
					%io:format("~p~n", [{P, S, E, gb_sets:to_list(Fence), gb_sets:to_list(SubGraph), gb_sets:to_list(array:get(P-1, AccRPred)), gb_sets:to_list(array:get(P-1, AccRSucc))}]),
					CurEdges = gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, ExitSucc)|Acc] end, [], gb_sets:del_element(P, Fence))),
					DelEdges = gb_sets:del_element(E, array:get(P-1, ExitSucc)),
					{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
						case gb_sets:is_element(El, CurEdges) orelse not gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
						{NRP, NRS} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
						{NRP, NRS, sreedhar_gao_lee_remove({NRP, NRS, RemPred, RemSucc, AcPdom, NextDom, RemRetReach, ExitCrossEdges}, AcPdom, El, E)} end end,
						{AccRPred, AccRSucc, AccPdom}, DelEdges),
					{RPn, RSn, RPdn, AccRet#{E := {gb_sets:del_element(P, Fence), SubGraph}}};
				_ -> %mirror removals of edges from fence nodes into exit nodes it fences
				%io:format("~p~n", [{P, S, E, Fence, SubGraph}]),
				{NRP, NRS} = {array:set(E-1, gb_sets:del_element(S, array:get(E-1, AccRPred)), AccRPred), array:set(S-1, gb_sets:del_element(E, array:get(S-1, AccRSucc)), AccRSucc)},
				{NRP, NRS, sreedhar_gao_lee_remove({NRP, NRS, RemPred, RemSucc, AccPdom, NextDom, RemRetReach, ExitCrossEdges}, AccPdom, S, E), AccRet} end;
			_ -> case not SInRetSet andalso not PInRetSet andalso gb_sets:is_element(P, SubGraph) andalso gb_sets:is_element(S, SubGraph) of true ->
				{NewFence, NewSubGraph} = pred_set_recurse(gb_sets:from_list([E]), NextRetSet, {RemPred, RemSucc, AccRPred, AccRSucc, NextDom, AccPdom, RemRetReach, ExitCrossEdges}),
				DelEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> case gb_sets:is_element(X, NewFence) of true -> Acc; _ -> [array:get(X-1, RemSucc)|Acc] end end, [], Fence))),
				NewEdges = gb_sets:del_element(E, gb_sets:union(gb_sets:fold(fun (X, Acc) -> [array:get(X-1, RemSucc)|Acc] end, [], NewFence))),
				%io:format("~p~n", [{E, gb_sets:to_list(DelEdges), gb_sets:to_list(NewEdges), gb_sets:to_list(Fence), gb_sets:to_list(NewFence), gb_sets:to_list(NewSubGraph), gb_sets:to_list(array:get(E-1, AccRPred))}]),
				{RPn, RSn, RPdn} = gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case gb_sets:is_element(El, NewEdges) orelse not gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
					{NRP, NRS} = {array:set(E-1, gb_sets:del_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:del_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
					{NRP, NRS, sreedhar_gao_lee_remove({NRP, NRS, RemPred, RemSucc, AcPdom, NextDom, RemRetReach, ExitCrossEdges}, AcPdom, El, E)} end end,
					gb_sets:fold(fun (El, {AcRPred, AcRSucc, AcPdom}) ->
					case gb_sets:is_element(El, DelEdges) orelse gb_sets:is_element(El, array:get(E-1, AccRPred)) of true -> {AcRPred, AcRSucc, AcPdom}; _ ->
						{NRP, NRS} = {array:set(E-1, gb_sets:add_element(El, array:get(E-1, AcRPred)), AcRPred), array:set(El-1, gb_sets:add_element(E, array:get(El-1, AcRSucc)), AcRSucc)},
						{NRP, NRS, sreedhar_gao_lee_add({NRP, NRS, RemPred, RemSucc, AcPdom, NextDom, RemRetReach, ExitCrossEdges}, AcPdom, El, E)} end end, {AccRPred, AccRSucc, AccPdom}, NewEdges),
					DelEdges),
				{RPn, RSn, RPdn, AccRet#{E := {NewFence, NewSubGraph}}}; %deletions between any subgraphs require recomputation
			_ -> {AccRPred, AccRSucc, AccPdom, AccRet} end end %; _ -> {AccRPred, AccRSucc, AccPdom, AccRet} end
			end,
		{NewRPred, NewRSucc, NextPdom, RemRetReach}, maps:remove(2, RemRetReach)) end end, %gb_sets:del_element(2, array:get(3-1, RemPred))) end end,
	%case get_j_succ(element(2, NextGraph), do_tarjan_immdom(NextGraph, 1)) =/= element(2, element(5, NextGraph)) of true -> io:format("~p~n", [{P, S, get_j_succ(element(2, NextGraph), do_tarjan_immdom(NextGraph, 1)), element(2, element(5, NextGraph))}]); _ -> true end,
	RetGraph = {RemPred, RemSucc, FinRPred, FinRSucc, NextDom, FinPdom, NextReach, if BatchMode =/= {true, false} -> array:set(S-1, gb_sets:del_element(P, array:get(S-1, ExitCrossEdges)), ExitCrossEdges); true -> ExitCrossEdges end},
	%case do_tarjan_immdom(RetGraph, 1) =/= element(1, element(5, RetGraph)) of true -> error({P, S, do_tarjan_immdom(RetGraph, 1), element(5, RetGraph)}); _ -> true end,
	%if P =/= 2 orelse S =/= 3 ->
	%{PostDoms, RR, PostDomGraph} = get_post_dom(RetGraph),
	%case gb_sets:to_list(element(3, element(2, RetGraph))) =:= [2] orelse lists:all(fun (El) -> {Fence, SubG} = maps:get(El, element(7, RetGraph)),
	%	{F, SG} = pred_set_recurse(gb_sets:from_list([El]), element(1, maps:get(2, element(7, RetGraph))), RetGraph),
	%	case El =:= 2 orelse gb_sets:to_list(Fence) =:= gb_sets:to_list(F) andalso gb_sets:to_list(SubG) =:= gb_sets:to_list(SG) of true -> true;
	%	_ -> io:format("~p~n", [{P, S, El, Fence, F, SubG, SG, gb_sets:to_list(Fence), gb_sets:to_list(SubG), gb_sets:to_list(F), gb_sets:to_list(SG)}]), false end end, gb_sets:to_list(element(3, element(1, RetGraph)))) of false -> error("Bad fence/subgraph"); _ -> true end,
	%case gb_sets:to_list(element(3, element(2, RetGraph))) =:= [2] orelse gb_sets:to_list(element(1, maps:get(2, element(7, RetGraph)))) =:= gb_sets:to_list(RR) of false -> error({P, S, gb_sets:to_list(element(1, maps:get(2, element(7, RetGraph)))), gb_sets:to_list(RR)}); _ -> true end,
	%case cmp_edgeset(element(2, PostDomGraph), element(3, RetGraph)) andalso cmp_edgeset(element(1, PostDomGraph), element(4, RetGraph)) of false -> error({true, P, S, element(7, RetGraph), get_edgeset(element(1, PostDomGraph)), get_edgeset(element(4, RetGraph))}); _ -> true end,
	%case PostDoms =/= element(1, get_pdom(RetGraph)) of true -> error({true, P, S, gb_sets:to_list(RR), get_edgeset(element(1, PostDomGraph)), get_edgeset(element(4, RetGraph)), PostDoms, element(1, element(6, RetGraph)), element(1, get_pdom(RetGraph))}); _ -> true end
	%; true -> true end,
	RetGraph
.

get_pdom({_, _, _, _, _, Pdom, RetReach, _}) ->
	#{2 := {RetSet,_}} = RetReach, %any not in return set with post dominators in return set are moved to exit node
	DomLen = map_size(Pdom), #{3 := ExitPdom} = Pdom,
	{CalcPdom, CalcEx} = fun RePdom(El, {AccPdom, AccEx}) -> if El =:= DomLen + 1 -> {AccPdom, AccEx}; true ->
		RePdom(El+1,
		case gb_sets:is_element(El, RetSet) orelse not gb_sets:is_element(begin #{El := {ElPdm,_,_,_}} = AccPdom, ElPdm end, RetSet) of true ->
			{AccPdom, AccEx};
		_ -> #{El := {ElPdomD,ElPdomJ,ElPdomT,_}} = AccPdom, #{ElPdomD := ElPdomPdom} = AccPdom,
	%must redepth all nodes post dominated by it also
	{fun ReDepth(E, A) -> gb_sets:fold(fun (B, C) -> ReDepth(B, C#{B => setelement(4, begin #{B := BPdom} = C, BPdom end, begin #{E := {_,_,_,EDepth}} = C, EDepth end + 1)}) end, A, begin #{E := {_,_,EDomTree,_}} = AccPdom, EDomTree end) end
		(El, AccPdom#{
			ElPdomD => setelement(3, ElPdomPdom, gb_sets:del_element(El, element(3, ElPdomPdom))),
			El => {3,ElPdomJ,ElPdomT,2}}), gb_sets:add_element(El, AccEx)} end) end end(1, {Pdom, element(3, ExitPdom)}),
	CalcPdom#{3 => setelement(3, ExitPdom, CalcEx)}
.

neg_rev_reach(NotChecked, Checked, R, Graph) ->
	%not efficient to do it in this manner, should coagulate before recursing
	%[U] ++ lists:append(lists:map(fun (Y) -> case lists:all(fun (X) -> not lists:member(X, R) end, lists:nth(Y, Succ)) of true -> neg_rev_reach(Y, R, Graph); _ -> [] end end, lists:nth(U, Pred)))
	NotReach = gb_sets:union(NotChecked, Checked),
	NewNotReach = gb_sets:union(gb_sets:fold(fun (U, Acc) ->
		[gb_sets:filter(fun (Y) -> lists:all(fun (X) -> gb_sets:is_element(X, NotReach) orelse not gb_sets:is_element(X, R) end, gb_sets:to_list(get_succs(Y, Graph))) end, get_preds(U, Graph))|Acc] end, [], NotChecked)),
	NewNotChecked = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, NotReach) of true -> [El|Acc]; _ -> Acc end end, [], NewNotReach)),
	case gb_sets:size(NewNotChecked) of 0 -> NotReach; _ -> neg_rev_reach(NewNotChecked, NotReach, R, Graph) end
.

pred_set_recurse(X, SetReach, Graph) ->
	{Reach, NotReach} = gb_sets:fold(fun (El, {R, NR}) -> case gb_sets:is_element(El, SetReach) of true -> {[El|R], NR};
		_ -> {R, [El|NR]} end end, {[], []}, X),
	NRSet = gb_sets:from_list(NotReach),
	Y = gb_sets:union([NRSet|lists:foldl(fun (El, Acc) ->
		[get_preds(El, Graph)|Acc] end, [], NotReach)]),
	if X =:= Y -> {gb_sets:from_list(Reach), NRSet}; true ->
		{NewReach, NewY} = pred_set_recurse(Y, SetReach, Graph),
	{gb_sets:union(gb_sets:from_list(Reach), NewReach), NewY} end.

%remove_edge_reach_set(U, V, R, Graph) ->
%	case lists:member(V, R) of true ->
%		R -- neg_rev_reach(U, R, Graph); true -> R end
%.

%rewritten non-incrementally as it causes excessive dominator computations and needs to be properly incremental regardless, used only temporarily and as a baseline for regression
get_revgraph(Graph) -> %on return the single node paths give true post dominators, not force return node to remain
	RetReach = fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [get_preds(El, Graph)|Acc] end, [], X)))),
		case gb_sets:size(Y) of 0 -> Comb; _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([2])),
	%merge all exit block structures immediately
	%merge single path block structures: maximally when an outer block is reached, minimally at any node which post dominates the whole single path, or conveniently the first merge node
	%{MergeGraph, NewRetReach} = lists:foldl(fun (Elem, {AccGraph, AccRetReach}) ->
		%only remove post dominator of return node when not a single pathway try or receive (to be very general the respective catch and after clauses also should be checked) but if none or both reach do not remove		
	%	case case getmergepredblockstruct(AST, Elem, get_preds(Elem, Graph)) of {Kind,P} -> Fst = gb_sets:is_element(getblockstructchild(AST, get_succs(P, Graph), Kind, true, P), AccRetReach), Snd = gb_sets:is_element(getblockstructchild(AST, get_succs(P, Graph), Kind, false, P), AccRetReach), Fst and Snd orelse IsRet andalso (Fst xor Snd) orelse IsExit andalso not Fst andalso not Snd; _ -> false end of true ->
	%			RemGraph = setelement(2, setelement(1, AccGraph, setelement(3, setelement(2, element(1, AccGraph), gb_sets:del_element(Elem, element(2, element(1, AccGraph)))), gb_sets:add_element(Elem, element(3, element(1, AccGraph))))), setelement(Elem, element(2, AccGraph), gb_sets:add_element(3, gb_sets:del_element(2, element(Elem, element(2, AccGraph)))))), RemReach = gb_sets:subtract(AccRetReach, neg_rev_reach(gb_sets:from_list([Elem]), gb_sets:new(), AccRetReach, RemGraph)),
	%				{RemGraph, RemReach}; %RetReach must be properly incrementally updated here
	%			_ -> {AccGraph, AccRetReach} end end, {Graph, RetReach}, lists:sort(fun (A, B) -> not comparenodes(AST, A, B) end, gb_sets:to_list(get_preds(2, Graph)))), %ordered since all exit situations must cascade outward
	%cases where the whole try catch or receive structure has exception paths, but not yet handled, then a adjustment needs to be done or a bad graph results - optimally just by removing the node and its head from RetReach not with full recomputation
	%NewRetReach = fun PredRecurse(Pcsd, X) -> Comb = Pcsd ++ X, Y = lists:usort(lists:append(lists:map(fun (El) -> lists:nth(El, MergePred) end, X))) -- Comb, if Y =:= [] -> Comb; true -> PredRecurse(Comb, Y) end end([], [2]),
	%io:format("~p~n", [{Graph,MergeGraph,PostDomGraph, RetReach, NewRetReach}]),
	PostDomGraph = case gb_sets:size(get_succs(3, Graph)) =:= 1 andalso gb_sets:to_list(get_succs(3, Graph)) =:= [2] of true -> Graph; _ ->
		gb_sets:fold(fun (Elem, AccGraph) -> Next = gb_sets:fold(fun (X, Ac) -> gb_sets:fold(fun (El, AGraph) -> case Elem =/= El andalso not gb_sets:is_element(El, get_succs(Elem, AGraph)) of true ->
		setelement(2, setelement(1, AGraph, array:set(El-1, gb_sets:add_element(Elem, array:get(El-1, element(1, AGraph))), element(1, AGraph))),
			array:set(Elem-1, gb_sets:add_element(El, array:get(Elem-1, element(2, AGraph))), element(2, AGraph))); _ -> AGraph end end, Ac, get_succs(X, AccGraph)) end,
				AccGraph, element(1, pred_set_recurse(gb_sets:from_list([Elem]), RetReach, Graph))),
		case gb_sets:size(get_succs(Elem, Next)) =:= 1 andalso gb_sets:to_list(get_succs(Elem, Next)) =:= [3] of true -> Next; _ -> setelement(2, setelement(1, Next, array:set(3-1, gb_sets:del_element(Elem, array:get(3-1, element(1, Next))), element(1, Next))), array:set(Elem-1, gb_sets:del_element(3, array:get(Elem-1, element(2, Next))), element(2, Next))) end end, Graph, gb_sets:del_element(2, get_preds(3, Graph))) end,
	{PostDomGraph, RetReach, Graph}
.

get_post_dom(Graph) -> %on return the single node paths give true post dominators, not force return node to remain
	{PostDomGraph, RetReach, _RevGraph} = get_revgraph(Graph), LenPred = next_node(Graph) - 1,
	{fun FixPdom(Elem, Acc) -> if Elem =:= LenPred + 1 -> Acc; true -> FixPdom(Elem+1, case gb_sets:to_list(get_succs(3, Graph)) =/= [2] andalso gb_sets:is_element(Elem, gb_sets:del_element(2, get_preds(3, Graph))) of true -> %orelse gb_sets:is_element(element(Elem, Acc), RetReach) andalso not gb_sets:is_element(Elem, RetReach)) of true ->
			array:set(Elem-1, 3, Acc); _ -> Acc end) end end(1,
			do_tarjan_immdom(rev_graph(PostDomGraph), case gb_sets:to_list(get_succs(2, PostDomGraph)) of [3] -> 3; _ -> 2 end)), RetReach, PostDomGraph}
.

handle_exit_merge(AST, Graph, NodeState, Node, AssignedVars, VarPrefix,
	{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, Opts) ->
	OrigPdom = get_pdom(Graph),
	ExitGraph = add_edge(Node, 3, Graph, AST, false),
	Pdom = get_pdom(ExitGraph), #{2 := {RetReach,_}} = element(7, ExitGraph),
	%RevGraph = 
	%	{element(3, ExitGraph), element(4, ExitGraph), element(1, ExitGraph), element(2, ExitGraph),
	%		element(6, ExitGraph), element(5, ExitGraph), element(7, ExitGraph),
	%		element(8, ExitGraph)}, %get_post_dom(ExitGraph),
	%IdomIdx = make_dom_tree(Idom),
	PredSetReach = element(1, pred_set_recurse(gb_sets:from_list([Node]),
		RetReach, ExitGraph)),
	IdomDFSOrder = lists:append(fun TreeDFS(Cur, X) ->
		lists:foldl(fun (El, Acc) -> #{El := {_,_,ElDTree,_}} = Pdom,
			TreeDFS(Acc, gb_sets:to_list(ElDTree)) end, [X|Cur], X) end([], [2])),
	%must differentiate before visited and legitimately returning and not yet
	%	visited nodes both of which have a single successor of the return node
	PotlNewPdoms = gb_sets:union(lists:filtermap(fun (El) -> ElSucc = get_succs(El, ExitGraph),
		case (gb_sets:size(ElSucc) =/= 1 orelse gb_sets:to_list(ElSucc) =/= [2] orelse
		not isnodeloopback(AST, El) andalso getnodevisited(NodeState, El) =:= 0)
		andalso begin #{El := {_,_,ElDomTree,_}} = Pdom, #{El := {_,_,ElOrigDomTree,_}} = OrigPdom, not gb_sets:is_subset(ElDomTree, ElOrigDomTree) end
		of true ->
		{true, gb_sets:del_element(3, gb_sets:del_element(2, gb_sets:from_list(pathtodom(Pdom, El))))}; _ -> false end
		end,
		%lists:foldl(fun (El, Acc) -> case lists:member(lists:nth(El, Idom), Acc) of
		%	true -> Acc; _ -> [lists:nth(El, Idom)|Acc] end end, [], PredSetReach) ++ 
		gb_sets:to_list(gb_sets:del_element(3, gb_sets:del_element(2, gb_sets:union(gb_sets:fold(fun (El, Acc) ->
			[gb_sets:from_list(pathtodom(Pdom, El))|Acc] end,
			[], PredSetReach))))))),
		%PredSetReach),
	%NewPdoms = lists:filter(fun (El) -> lists:member(El, PotlNewPdoms) end,
	%	IdomDFSOrder),
	%(pathtodom(Idom, El) -- [El,2,3|Acc])
	NewPdoms = [E || E <- IdomDFSOrder, gb_sets:is_element(E, PotlNewPdoms)],
	%sorted in order of top to bottom so each processed potentially post dominates
	%	more of the graph or different parts
	%io:format("~p~n", [{Node, gb_sets:to_list(PredSetReach), gb_sets:to_list(PotlNewPdoms), gb_sets:to_list(RetReach),
		%get_edgeset(element(2, ExitGraph))}]),
	%if no post dominators and this node does not reach, could process current
	%	node for closing off language block merges of all exits
	%for normal control flow, this would already be handled in other
	%post dominators, as a genuine post dominator of exit node cannot happen there
	%this must be done with a code path as the post dominator is the exit node,
	%but only with respect to the subgraph incumbent by Node
	%all nodes from PSR([Node]) to the exit
	%NowExitReach = fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y =
	%	gb_sets:subtract(gb_sets:subtract(gb_sets:fold(fun (El, Acc) ->
	%		gb_sets:union(Acc, get_preds(El, ExitGraph)) end, gb_sets:new(), X), Comb),
	%			PredSetReach),
		%case gb_sets:size(Y) of 0 -> gb_sets:to_list(Comb);
		%_ -> PredRecurse(Comb, Y) end end(gb_sets:new(),gb_sets:from_list([Node])),
	%io:format("~p~n", [{Idom, gb_sets:to_list(PredSetReach),
	%	gb_sets:to_list(PotlNewPdoms), NewPdoms, IdomDFSOrder}]),
	%must keep resolving nodes whose post dominators change from one block merge
	%as it can allow resolving further outer block structures
	%in a cascading manner
	%{ModAST, ModGraph, ModAssignedVars, _} =
		%handle_lang_block_merge(AST, ExitGraph, NowExitReach, AssignedVars, VarPrefix,
		%	{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, Opts),
	{NextAST, NextGraph, NextAssignedVars, Crs, CNodes, CEdges, CREdges} =
	lists:foldl(fun (ChkPdom, {AcAST, AcGraph, AcAssignedVars,
		AccCrs, AccNodes, AccEdges, AccREdges}) ->
		{RetAST, RetGraph, RetAssignedVars, _, C, CN, CE, CRE} =
			handle_merge_node(AcAST, AcGraph, ChkPdom, ChkPdom,
				AssignedVars + AcAssignedVars, VarPrefix, {BaseLabel, LabelToNode,
				ModName, {FuncName, Arity}},
			% Processed and not post dominating any node -> Process fully
			%check all nodes it is post dominating, which are not in the new exit set
			%not lists:all(fun (El) -> lists:member(El, NowExitReach) end,
			%	lists:nth(ChkPdom, IdomIdx)),
			true,
			false, false, Opts),
		{RetAST, RetGraph, AcAssignedVars + RetAssignedVars,
			AccCrs + C, AccNodes + CN, AccEdges + CE, AccREdges + CRE}
	end, {AST, ExitGraph, 0, 0, 0, 0, 0}, NewPdoms),
	%must check chain of post dominators to return node,
	%need to coagulate in order
	
	%{NextIdom, _} = get_post_dom(NextGraph),
	%ChangedNodes = lists:filter(fun (El) -> lists:nth(El, Idom) =/=
	%	lists:nth(El, NextIdom) end, lists:seq(1, length(Idom))),
	{NextAST, NextGraph, NextAssignedVars, Crs, CNodes, CEdges, CREdges}
.

handle_lang_block_merge(AST, Graph, Node, AssignedVars, VarPrefix,
	{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, Opts) ->
	%case check_nodes(AST) of true -> true; _ -> io:format("AST sanity check failed~n", []) end,
	%{Idom, _, _} = get_post_dom(Graph),
	Pdom = get_pdom(Graph),
	%RetReach = element(1, maps:get(2, element(7, Graph))),
	IdomTree = lists:append(fun TreeDFS(Cur, X) ->
		lists:foldl(fun (El, Acc) -> #{El := {_,_,ElDTree,_}} = Pdom,
			TreeDFS(Acc, gb_sets:to_list(ElDTree)) end, [X|Cur], X) end([], [Node])),
	%NearestResolvable = lists:filter(fun (El) ->
	%	El =/= 2 andalso El =/= Node end, lists:usort(lists:append(lists:map(
	%	fun (Elem) -> PSR([Elem]) end, lists:delete(2, lists:nth(3, MergePred)))))),
	%io:format("~p~n", [NearestResolvable]),
	%ideally try-catch and receive merges should not occur until post-dominator
	%	reached, and cross edges handled by usual appropriate algorithms otherwise
	%	complex compiler optimizations could break naive assumptions
	%IdomIdx = make_dom_tree(Idom),
	%IdomDFSOrder = lists:reverse(fun TreeDFS(X) ->
	%	X ++ lists:append(lists:map(fun (El) ->
	%		TreeDFS(gb_sets:to_list(element(El, IdomIdx))) end, X)) end
	%	([if is_list(Node) -> 2; true -> Node end])),
	%io:format("~p~n", [{Idom, IdomIdx, IdomDFSOrder, Graph}]),
	%entries with single path or all exit paths could be multiply processed as
	%	post dominator is symbolic for exit node consistency
	BlockMerges = lists:usort(fun ({K1,A}, {K2,B}) -> if A =:= B ->
		case K1 of 'catch' -> 1; try_end -> 2; 'try' -> 3; 'receive' -> 4 end =<
			case K2 of 'catch' -> 1; try_end -> 2; 'try' -> 3; 'receive' -> 4 end;
		true -> case A =/= B andalso
			isnested(AST, B, A) of true -> false; _ -> case isnested(AST, A, B) of
					true -> true; _ -> comparenodes(AST, A, B) end end end end,
		lists:filter(fun (A) -> A =/= false end,
			lists:map(fun (P) -> case getnodeblockstruct(AST, P, 0)
			of false -> case gb_sets:to_list(get_preds(P, Graph)) of [Par] -> case getnodeblockstruct(AST, Par, 0) =:= 'try' andalso isblockchild(AST, try_end, true, Par, P) of true -> {try_end, Par}; _ -> false end; _ -> false end;
				'catch' -> case Node =:= P orelse gb_sets:is_element(Node, get_succs(P, Graph)) of true -> false; _ -> {'catch', P} end; var -> false;
				Kind -> if Node =:= 2 -> false; true -> #{Node := PDomNode} = Pdom, case {
					getblockstructchild(AST, get_succs(P, Graph), Kind, true, P),
					getblockstructchild(AST, get_succs(P, Graph), Kind, false, P)} of
				{0, _} -> case isblockstructresolvable(AST, P, Node, element(1, PDomNode),
							get_succs(P, Graph)) andalso
						not isblockchild(AST, Kind, true, P, Node) of true -> {Kind, P}; _ -> false end;
				{_, 0} -> case isblockstructresolvable(AST, P, Node, element(1, PDomNode),
							get_succs(P, Graph)) andalso
						not isblockchild(AST, Kind, false, P, Node) of true -> {Kind, P}; _ -> false end;
				{X, Y} -> NCA = nca(Pdom, X, Y), Fst = isblockchild(AST, Kind, true, P, if NCA =:= 3 -> Node; true -> NCA end),
					Snd = isblockchild(AST, Kind, false, P, if NCA =:= 3 -> Node; true -> NCA end),
					%io:format("~p~n", [{Fst, Snd, X, Y, Node, Min, NCA,
					%	gb_sets:to_list(RetReach), element(7, Graph)}]),
					case NCA =/= Node andalso (NCA =/= 3 orelse not isnested(AST, Node, P) andalso (Kind =/= 'try' orelse lists:all(fun (El) -> not isblockchild(AST, try_end, true, P, El) end, gb_sets:to_list(get_preds(Node, Graph))))) andalso
						not Fst andalso not Snd andalso
						isblockstructresolvable(AST, P, Node, element(1, PDomNode),
							get_succs(P, Graph)) of true -> {Kind, P};
					_ -> false end end end end end,
			lists:delete(Node, IdomTree)) ++ if Node =/= 2 -> []; true -> lists:map(fun (El) ->
				getmergepredblockstruct(AST, El, get_preds(El, Graph)) end,
				gb_sets:to_list(get_preds(3, Graph))) end)),
				%not lists:member(P, lists:usort(fun SuccRecurse(X) ->
				%	X ++ lists:append(lists:map(fun (El) ->
				%		SuccRecurse(lists:nth(El, Succ)) end, X)) end
				%([hd(lists:dropwhile(fun (El) -> hd(lists:nth(El, NodesToAST)) =/=
				%Path ++ [4, 1, 3, 1] end, lists:seq(1, length(NodesToAST))))])))
	%if BlockMerges =/= [] -> io:format("~p~n",
	%	[{Node, IdomTree, BlockMerges, Pdom,
	%		get_edgeset(element(2, Graph)), get_edgeset(element(8, Graph))}]);
	%true -> true end,
	%block merges handled by going up the tree
	%bottom to top required due to storing AST paths
	%{AST, Graph, AssignedVars, Node} =
	lists:foldl(fun ({Kind, HeadNode}, {AccAST, AccGraph, AccAssignedVars}) ->
		%for a detailed reason, cannot safely check consistency until the fold
		%	operation is completed - could investigate this
		%case false of false -> case check_pred_succ(AccGraph) of true -> true;
		%_ -> io:format("Graph sanity check failed~n") end,
		%case check_nodes(AccAST) of true -> true;
		%_ -> io:format("AST sanity check failed~n") end; _ -> true end,
		%{CurIdom, _, _, _} = get_pdom(AccGraph),
		%{CurRetReach, CurRevGraph} ={element(1, maps:get(2, element(7, AccGraph))),
			%{element(3, AccGraph), element(4, AccGraph), element(1, AccGraph),
			%	element(2, AccGraph), element(6, AccGraph), element(5, AccGraph),
			%	element(7, AccGraph), element(8, AccGraph)}},
			%get_post_dom(AccGraph),
		if Kind =:= 'catch' orelse Kind =:= try_end ->
			%need a way to know that variable assignment has not already occurred
			InnerHeadNode = hd(lists:filter(fun (El) -> isblockchild(AccAST, try_end, true, HeadNode, El) end, gb_sets:to_list(get_succs(HeadNode, Graph)))),
			NearPdom = hd(lists:dropwhile(fun (El) -> 
					isblockchild(AccAST, try_end, true, HeadNode, El)
			end, lists:delete(InnerHeadNode, pathtodom(Pdom, InnerHeadNode)))),
			case NearPdom =:= Node orelse not lists:member(NearPdom, IdomTree) of true -> {AccAST, AccGraph, AccAssignedVars}; _ ->
			FixNodes = if NearPdom =:= 3 -> []; true -> lists:filter(fun (X) ->
				isblockchild(AccAST, try_end, true, HeadNode, X) end,
				gb_sets:to_list(get_preds(NearPdom, AccGraph))) end,
			%io:format("~p~n", [{Kind, HeadNode, Node, NearPdom, FixNodes,
			%	gb_sets:to_list(get_preds(Node, AccGraph)), gb_sets:to_list(get_preds(NearPdom, AccGraph))}]),
			case FixNodes =:= [] orelse getnodeblockstruct(AccAST, hd(FixNodes), 0) =:= var of true -> {AccAST, AccGraph, AccAssignedVars}; _ ->
			{NxAST, NxGraph, NxAssignedVars, _, _, _, _, _} =
				handle_merge_node(AccAST, AccGraph, hd(FixNodes), hd(FixNodes),
					AssignedVars + AccAssignedVars, VarPrefix,
					{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, false, true,
					false, Opts),
			{NxAST, NxGraph, AccAssignedVars + NxAssignedVars} end end;
		true ->
		IsTry = Kind =:= 'try',
		%SinglePath = issinglepath(AccAST, Kind, HeadNode, element(HeadNode, Idom)),
		MergeNode = getmergenode(AccAST, HeadNode, get_succs(HeadNode, Graph)),
		%RetSinglePath = if AccNode =:= 2 -> lists:filtermap(fun (X) ->
		%	if X =:= MergeNode -> false; true ->
		%		gb_sets:to_list(element(1, pred_set_recurse(gb_sets:from_list([X]),
		%			CurRetReach, CurRevGraph))) =:= [X] end end,
		%	gb_sets:to_list(get_succs(HeadNode, Graph))); true -> [] end,
		%when single path through block structure due to exits, but nested in an
		%	outer structure, must also check that case specifically to find boundary
		%single path should only have a single converged entry,
		%	except in the case of the outermost one on the return node
		%loop_rec_end node must also be found also
		%	when only an after 0 timeout present
		LoopEnd = if IsTry -> []; true -> lists:dropwhile(fun (El) ->
				El =:= 2 orelse isnodeloopback(AccAST, El) orelse
				not isblockchild(AccAST, Kind, true, HeadNode, El) orelse
				getmemd(getgraphpath(AccAST, El), {x,0}) =/= [HeadNode] end,
			gb_sets:to_list(get_preds(3, Graph))) end,
		%3 cases: parent merge, sequence merge and single path merge while loop back
		%	placeholder needs special resolution for receive
		NearPdom = hd(lists:dropwhile(fun (El) ->
			isblockchild(AccAST, Kind, true, HeadNode, El) orelse
			isblockchild(AccAST, Kind, false, HeadNode, El) end,
				lists:dropwhile(fun (El) -> if IsTry ->
					isblockchild(AccAST, try_end, true, HeadNode, El); true -> false end
			end, lists:delete(HeadNode, pathtodom(Pdom, HeadNode))))),
		FixNodes = if NearPdom =:= 3 -> []; true -> lists:filter(fun (X) ->
			isblockchild(AccAST, Kind, true, HeadNode, X) andalso
			(LoopEnd =:= [] orelse hd(LoopEnd) =/= X) end,
			gb_sets:to_list(get_preds(NearPdom, AccGraph))) end,
		FixAfterNodes = if NearPdom =:= 3 -> []; true -> lists:filter(fun (X) ->
			isblockchild(AccAST, Kind, false, HeadNode, X) end,
			gb_sets:to_list(get_preds(NearPdom, AccGraph))) end,
		TryHasOf = IsTry andalso (lists:any(fun (El) ->
			isblockchild(AccAST, Kind, true, HeadNode, El) end,
			gb_sets:to_list(get_preds(3, Graph))) orelse FixNodes =/= []), 
			%no path or single path catch checks exits, while the rest would have
			%found it as a single/double path try case
		LenAccPred = next_node(AccGraph),
		%if merge nodes are not already created, must create them to hold the
		%	variables, which is the case with return node or 
		%io:format("~p~n", [lists:map(fun (El) -> lists:nth(El, AccNodesToAST) end,
		%	lists:nth(AccNode, AccPred))]),
		%delayed merge already mostly merged by cross edge algorithm,
		%	extra graph node is the difference which now can just be simply linked
		%if all paths lead to an exit, then it also is processable and appears
		%	to be post dominated by the effect of all successors of the predecessors
		%	of the receive being linked
		%the merge node though for post dominators must not point to the exit node,
		%	but to its own try block in case of try catch
		%IsSibling = Idx =/= LenBlockMerges andalso not isnested(AccAST, HeadNode,
		%	element(2, lists:nth(Idx + 1, BlockMerges))),
		%io:format("~p~n", [{Kind, HeadNode, Node, MergeNode, NearPdom, FixNodes, FixAfterNodes,
		%	LoopEnd, IsTry, TryHasOf, %get_edgeset(element(2, AccGraph)),
		%	gb_sets:to_list(get_preds(Node, AccGraph)), LenAccPred}]),
		if FixNodes =:= [] andalso FixAfterNodes =:= [] ->
			{NxAST, NxGraph, NxAssignedVars, MidAssignedVars} =
				{if IsTry andalso not TryHasOf ->
					setgraphpathchild(AccAST, {'try', true}, true, HeadNode,
						setelement(4, getgraphpathchild(AccAST, {'try', true},
							true, HeadNode), [])); true -> AccAST end,
			AccGraph, 0, 0};
		true -> %can only use the existing nodes,
		%if they are merge nodes which post dominate the head nodes of the blocks
			%io:format("~p~n", [{NextPred, NextSucc, IsSibling}]),
			FixAST = if FixNodes =:= [] -> AccAST; true ->
				insertgraphnodechild(AccAST, HeadNode, {Kind, true}, true,
				{graphdata, 0, array:new(1024, {default,[]}), array:new({default,[]}),
					array:new(16, {default,[]})}, LenAccPred) end,
			NextAST = if FixAfterNodes =:= [] -> FixAST;
			true ->
				FixASTNext = insertgraphnodechild(FixAST, HeadNode, {Kind, true}, false,
					{graphdata, 0, array:new(1024, {default,[]}), array:new({default,[]}),
						array:new(16, {default,[]})},
					LenAccPred + if FixNodes =:= [] -> 0; true -> 1 end),
				if FixNodes =:= [] -> if IsTry andalso not TryHasOf ->
					setgraphpathchild(FixASTNext, {'try', true}, true, HeadNode,
						setelement(4, getgraphpathchild(FixASTNext, {'try', true},
							true, HeadNode), [])); true -> FixASTNext end;
				%remove special unlinked try-of graphdata which is assigned before for
				%consistent variable numbering but requires careful cleanup in this case
				true -> FixASTNext end end, %io:format("~p~n", [NextGraph]),
			%if the node is between the merge node and the head node,
			%then a cross edge merge occurred and we can reuse, otherwise create new
			%NotMerged = length(Idxs) =:=
			%	length(lists:last(lists:nth(AccNode, NodesToAST))),
			%first create new sub-block merge nodes
			INextGraph = add_edge(LenAccPred, MergeNode, lists:foldl(fun (El, Acc) ->
				AccAdd = add_edge(El, LenAccPred, Acc, NextAST, false),
				if NearPdom =:= 2 orelse NearPdom =:= 3 -> AccAdd; true ->
					remove_edge(El, NearPdom, AccAdd, NextAST, false) end end,
				if NearPdom =:= 3 -> AccGraph; true ->
					add_edge(MergeNode, NearPdom, AccGraph, NextAST, false) end,
				if FixNodes =:= [] -> FixAfterNodes; true -> FixNodes end),
				NextAST, false),
			MNextGraph = if FixNodes =:= [] orelse FixAfterNodes =:= [] -> INextGraph;
				true -> add_edge(LenAccPred + 1, MergeNode, lists:foldl(fun (E, A) ->
					AAdd = add_edge(E, LenAccPred + 1, A, NextAST, false),
					if NearPdom =:= 2 orelse NearPdom =:= 3 -> AAdd; true ->
						remove_edge(E, NearPdom, AAdd, NextAST, false) end end,
					INextGraph, FixAfterNodes), NextAST, false) end,
			LoopBackGraph = if LoopEnd =/= [] andalso FixNodes =/= [] ->
				add_edge(hd(LoopEnd), LenAccPred, MNextGraph, NextAST, false);
				true -> MNextGraph end,
			NextGraph = remove_edge(HeadNode, MergeNode,
				LoopBackGraph, NextAST, false),
			{MidAST, MidGraph, MidAssignedVars, _, _, _, _, _} =
				handle_merge_node(NextAST, NextGraph, LenAccPred, LenAccPred,
					AssignedVars + AccAssignedVars, VarPrefix,
					{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, false, true,
					FixNodes =/= [] andalso not IsTry, Opts),
			{NxAST, NxGraph, NxAssignedVars, _, _, _, _, _} =
				if FixNodes =:= [] orelse FixAfterNodes =:= [] ->
					{MidAST, MidGraph, MidAssignedVars, Node, 0, 0, 0, 0}; true ->
						NewAfterNode = LenAccPred + 1,
						handle_merge_node(MidAST, MidGraph, NewAfterNode, NewAfterNode,
							AssignedVars + AccAssignedVars + MidAssignedVars, VarPrefix,
							{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, false, true,
							false, Opts) end
		end,
		{NxAST, NxGraph, AccAssignedVars + MidAssignedVars + NxAssignedVars} end end,
		{AST, Graph, 0}, BlockMerges)
.

handle_merge_node(AST, Graph, CurNode, Node, AssignedVars, VarPrefix,
	{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, IsExit, IsCatch, IsRecv,
	Opts) ->
	%if node merge post-dominates, then must merge current node edges, to what it
	%	post-dominates and make sure its a sibling clause
	%	to the highest post-dominated node
	%default case nodes due to erlang semantics must still be later assigned even
	%	without any corresponding node in the beam
	%DFS edge classifier (u, v) edge:
	%tree edge (type of forward edge): if v visited first time in DFS
	%back edge: v already visited and is an ancestor of u (v dominates u)
	%forward edge: v already visited and is a descendent of u
	%cross edge: v already visited and neither ancestor or descendent of u
	%orelse causes cross edges
	%no return node, all out of band exists cancels emission of return value and
	%	deletes node getnextsibling(hd(lists:nth(2, NodesToAST)))
	case Node =:= CurNode andalso Node =/= 2 andalso not IsCatch andalso not IsExit
		andalso gb_sets:size(get_preds(Node, Graph)) =:= 0 orelse isnodeloopback(AST, Node)
		of true -> %start of decompilation labels skipped
		{RetAST, RetGraph, RetAssignedVars} =
			handle_lang_block_merge(AST, Graph, Node, AssignedVars, VarPrefix,
				{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, Opts),
		{RetAST, RetGraph, RetAssignedVars, Node, 0, 0, 0, 0};
	_ ->
	  %first must redirect all return labels not yet reached to the exit latch
		LenPred = next_node(Graph),
		%if Node =:= 2 -> Idom = do_tarjan_immdom(rev_graph(Graph), 3); true ->
		%{Idom, _, _} = get_post_dom(Graph),
		Pdom = get_pdom(Graph), #{Node := {NodePdom,_,NodeDTree,_}} = Pdom, if IsCatch -> #{NodePdom := {NodePdomPdom,_,NodePdomDTree,_}} = Pdom; true -> NodePdomPdom = 0, NodePdomDTree = gb_sets:new() end,
		IsNotPdomOf = Node =/= 2 andalso gb_sets:size(NodeDTree) =:= 0 andalso if IsCatch -> gb_sets:size(NodePdomDTree) =:= 0; true -> true end, %still need variable assignment here, or must go through its predecessors not just dominators at the post dominating node which assigns
			%all care has been taken to make sure that AST hierarchy is having strict
			%	sibling and parent/child relationships which are also followed
			%	by a strict sibling in parent/child
			%try/catch and receive are exceptions filtered out due
			%	to their block merge reservation node
			CrossEdges = element(8, Graph), %get_cross_edges(AST, Graph),
			%case cmp_edgeset(CrossEdges, get_cross_edges(AST, Graph)) of false ->
			%	error({"Bad cross edge calculation", get_edgeset(CrossEdges),
			%	get_edgeset(get_cross_edges(AST, Graph)), element(2, AST)});
			%_ -> true end,
		  NearestCrossPdom = array:map(fun (Idx, X) -> IdxP1 = Idx + 1, #{IdxP1 := {IdxPdom,_,_,_}} = Pdom, IdxPdom, XPath = pathtodom(Pdom, IdxP1),
		  	%L = lists:reverse(if X =:= Node -> pathtodom(Idom, X);
		  	%	true -> tl(pathtodom(Idom, X)) end), %NCA when not considering merge nodes of block structures is the correct approach
		  	lists:map(fun (Y) -> #{Y := {YPdom,_,_,_}} = Pdom,
		  		%if Idx+1 =:= Node -> Node; true ->
		  		InitNCA = nca(Pdom, IdxPdom, YPdom),
			  	NCA = fun WalkPdom(El) -> case getnodeblockstruct(AST, El, 0) of
			  		'catch' -> #{El := {ElPdom,_,_,_}} = Pdom, if ElPdom =:= 2 orelse ElPdom =:= 3 -> ElPdom; true -> WalkPdom(ElPdom) end;
			  		'try' -> #{El := {ElPdom,_,_,_}} = Pdom, case issinglepath(AST, 'try', El, ElPdom) of true -> 2
			  		; _ -> if ElPdom =:= 2 orelse ElPdom =:= 3 -> ElPdom; true -> WalkPdom(ElPdom) end end;
			  		'receive' -> #{El := {ElPdom,_,_,_}} = Pdom, case issinglepath(AST, 'receive', El, ElPdom) of true -> 2
			  		; _ -> if ElPdom =:= 2 orelse ElPdom =:= 3 -> ElPdom; true -> WalkPdom(ElPdom) end end;
			  		_ -> #{El := {ElPdom,_,_,_}} = Pdom, case isnested(AST, ElPdom, El) of true -> WalkPdom(ElPdom); _ -> ElPdom end end end(lists:last(lists:takewhile(fun (El) -> El =/= InitNCA end, XPath))),
		  		{Y, NCA} end,
		  		%Z = lists:reverse(tl(pathtodom(Idom, Y))),
		  		%	lists:nth(lists:last(lists:takewhile(
		  		%		fun (N) -> lists:nth(N, Z) =:= lists:nth(N, L) end,
		  		%lists:seq(1, erlang:min(length(L), length(Z))))), L) end,
		  		gb_sets:to_list(X))
		  	end, CrossEdges),
		  IsCross = Node =/= 2 andalso CurNode =/= Node andalso not IsExit andalso
		  	not IsNotPdomOf andalso
		  	not (CurNode =:= 0 orelse
		  		gb_sets:is_element(CurNode, array:get(Node-1, CrossEdges))),
		  	% andalso hd(lists:nth(Node, NearestCrossPdom)) =/= 2
		  %IsMerge = length(hd(lists:nth(Node, NodesToAST))) =:=
		  %		length(lists:last(lists:nth(FirstPDom, NodesToAST))),
		  %io:format("~p~n",
		  	%[{CurNode, Node, Graph, CrossEdges, NearestCrossPdom, IsCross}]),
		  %[lists:map(fun (X) -> case lists:nth(X, DFS) > lists:nth(N, DFS) of true
		  %		-> case lists:nth(X, RDFS) > lists:nth(N, RDFS) of true -> 'C';
		  %			_ -> 'B' end; _ -> case lists:nth(X, RDFS) > lists:nth(N, RDFS) of
		  %				true -> 'T'; _ -> 'F' end end end,
		  %		lists:nth(N, Pred)) || N <- lists:seq(1, LenPred - 1)],
			%RetPath = hd(lists:nth(2, NodesToAST)),
			%io:format("~p~n", [getgraphpath(AST, hd(lists:nth(Node, NodesToAST)))]),
			%for all predecessors with all values equal to dominator, remove
			%	and add dominator repeating as high in tree as new node dominator
			%if only new node dominator remains, take its value,
			%	otherwise assign variable to all in list
			%Stage 1: merge graph node
			NewInsAST = if Node =:= 2 orelse CurNode =:= Node orelse
				IsCatch orelse IsExit orelse IsNotPdomOf -> AST;
			true ->
				%ChkDom = do_tarjan_immdom(rev_graph(Graph), 1),
				%AllPdoms = lists:filtermap(fun(Elem) -> case lists:nth(Elem, Idom) of
				%	Node -> {true, fun BuildDom(C) -> X = lists:nth(hd(C), ChkDom),
				%case X of 0 -> C; _ -> BuildDom([X|C]) end end([Elem])};
				%_ -> false end end, lists:seq(1, length(Idom))),
				%PdomLen = length(lists:takewhile(fun(Elem) -> length(lists:usort(
				%	lists:map(fun (El) -> lists:nth(Elem, El) end, AllPdoms))) =:= 1 end,
				%	lists:seq(1, lists:min(lists:map(fun (El) ->
				%		length(El) end, AllPdoms))))),
	  		%lists:nth(PdomLen, hd(AllPdoms))
	  		%AllPdoms = lists:filtermap(fun(Elem) -> case lists:nth(Elem, Idom) of
	  		%	Node -> {true, lists:last(lists:nth(Elem, NodesToAST))};
	  		%	_ -> false end end, lists:seq(1, length(Idom))),
	  		%MaxPfx = (length(lists:takewhile(fun(Elem) -> lists:all(fun (El) ->
	  		%	lists:nth(Elem, El) =:= lists:nth(Elem,
	  		%		lists:last(lists:nth(Node, NodesToAST))) end, AllPdoms) end,
	  		%	lists:seq(1,
	  		%		erlang:min(length(lists:last(lists:nth(Node, NodesToAST))),
	  		%	lists:min(lists:map(fun erlang:length/1, AllPdoms)))))) div 2) * 2,
	  		%io:format("~p~n",
	  		%	[{AllPdoms, MaxPfx, lists:last(lists:nth(Node, NodesToAST))}]),
				%PDomPath = lists:last(lists:nth(FirstPDom, NodesToAST)),
				%if code duplication will occur, still must merge
				%LenPDomPath = length(PDomPath),
				%NewNodePath = hd(lists:nth(Node, NodesToAST)),
				if IsCross ->
				insertgraphnode(AST,
				%case LenPDomPath > length(NewNodePath) of true ->
				%	LenNewNodePath = length(NewNodePath),
				%	setnth(LenNewNodePath, lists:sublist(NewNodePath, LenPDomPath),
				%		lists:nth(LenNewNodePath, NewNodePath) + 1);
				%	_ -> setnth(LenPDomPath, lists:sublist(NewNodePath, LenPDomPath),
				%		lists:nth(LenPDomPath, NewNodePath) + 1)
				%end,
				%very significant structural issue is basing this node correctly -
				%	for cross and merge edges off of Node
				%if IsCross -> lists:sublist(hd(AllPdoms), MaxPfx) ++
				%	[erlang:max(lists:nth(MaxPfx + 1,
				%		lists:last(lists:nth(Node, NodesToAST))),
				%	lists:max(lists:map(fun (Elem) -> lists:nth(MaxPfx + 1, Elem) end,
				%	AllPdoms))) + 1];
				%true -> 
				Node,
				getgraphpath(AST, Node),
				%{graphdata, 0, [], [], []},
				LenPred); true -> AST end
				%swapgraphnode(AST, Node, getgraphpath(AST, Node), LenPred) end
			end,
			%andalso/orelse: postdominates 4 nodes, 3 predecessors and
			%	2 of these predecessors preceded by the non-predecessor
			%Stage 2: cross edge code duplication resolution
			{NewAST, FixGraph, Crs, CNodes, CEdges, CREdges} =
				case IsNotPdomOf of true -> {NewInsAST, Graph, 0, 0, 0, 0}; _ -> % orelse gb_sets:size(array:get(Node-1, CrossEdges)) =/= 0
				handle_cross_edges(NewInsAST,
				if Node =:= 2 orelse IsExit -> Graph;
				IsCross -> remove_edge(Node, 2, add_edge(LenPred, 2, add_edge(Node,
					LenPred, gb_sets:fold(fun (El,Acc) -> if El =:= CurNode ->
						add_edge(El, LenPred, remove_edge(El, Node, Acc, NewInsAST, false),
					NewInsAST, false); true -> Acc end end, Graph,
					get_preds(Node, Graph)), NewInsAST, false), NewInsAST, false),
					NewInsAST, false);
				true -> Graph end,
				%remove_edge(CurNode, Node, add_edge(LenPred, Node, add_edge(CurNode,
				%	LenPred, Succ, NewInsAST, false), NewInsAST, false), NewInsAST, false)
				%end,
				if IsCross -> LenPred; true -> Node end,
				if Node =:= 2 -> 3; IsCross -> Node; IsCatch -> NodePdomPdom; true -> 0 end,
				if IsCross ->
					array:set(array:size(NearestCrossPdom), array:get(Node - 1, NearestCrossPdom),
						array:resize(array:size(NearestCrossPdom)+1, NearestCrossPdom)); true -> NearestCrossPdom end) end,
			%Stage 3: variable assignment
			%case check_pred_succ(FixGraph) of true -> true; _ -> io:format("Graph sanity check failed ~p~n",
				%[{FixGraph, IsCross, CrossEdges}]) end,
			%case check_nodes(NewAST) of true -> true; _ -> io:format("AST sanity check failed ~p~n",
				%[do_dfs(element(1, FixGraph), 3)]) end,
			{RetAST, RetGraph, RetAssignedVars} =
				if IsCatch orelse IsNotPdomOf -> {NewAST, FixGraph, 0}; true -> handle_lang_block_merge(NewAST, FixGraph, if Node =/= 2 andalso
					not IsCatch andalso not IsExit andalso IsCross -> LenPred;
					true -> Node end, AssignedVars, VarPrefix,
					{BaseLabel, LabelToNode, ModName, {FuncName, Arity}}, Opts) end,
			Dom = element(5, RetGraph), %do_tarjan_immdom(RetGraph, 1),
			case Node =:= 2 andalso gb_sets:to_list(get_succs(2, Graph)) =/= [3] orelse Node =/= 2 andalso not IsCatch andalso gb_sets:size(get_preds(Node, RetGraph)) =:= 1 orelse IsExit of true ->
				%block merge point, should not further assign
				{FinalAST, NewAsgn} = {RetAST, 0};
			_ -> if Node =:= 2 orelse IsCatch -> #{Node := {NodeDom,_,_,_}} = Dom,
				DefGData = {graphdata, 0, array:new(1024, {default,[]}), array:new({default,[]}),
					array:new(16, {default,[]})}, NodeAST = getgraphpath(RetAST, Node),
				{GrphElem,{ModAST,_,NewAsgn}} =
					assign_var(RetAST, RetGraph, Dom, Node, AssignedVars + 
						RetAssignedVars, 0, 3, VarPrefix, getmemd(case case NodeAST of DefGData -> true; _ -> false end andalso case getnodeblockstruct(AST, NodeDom, 0) of 'catch' -> false; _ -> true end of true -> getgraphpath(RetAST, 
							NodeDom); _ -> NodeAST end, {x,0}), 1, IsRecv, #{});
			true ->
				{XVars, {XModAST, _, XAsgn}} = assign_vars(RetAST, RetGraph, Dom,
					Node, AssignedVars + RetAssignedVars, 3, VarPrefix),
				{YVars, {YModAST, _, YAsgn}} = assign_vars(XModAST, RetGraph, Dom,
					Node, AssignedVars + RetAssignedVars + XAsgn, 4, VarPrefix),
				{FrVars, {ModAST, _, FrAsgn}} = assign_vars(YModAST, RetGraph, Dom,
					Node, AssignedVars + RetAssignedVars + XAsgn + YAsgn, 5,VarPrefix),
				NewAsgn = XAsgn + YAsgn + FrAsgn, GrphElem = {graphdata, 0,
					array:from_list(XVars), array:from_list(YVars), array:from_list(FrVars)}
			end, FinalAST = if IsCatch orelse Node =:= 2 -> insertgraphnode(ModAST,
					if Node =:= 2 -> Node; true -> CurNode end, GrphElem, 0);
				true -> setgraphpath(ModAST, if IsExit -> CurNode; IsCross -> LenPred; 
					true -> Node end, GrphElem) end end,
			%case lists:member(nosanitycheck, Opts) of false ->
			%	case check_pred_succ(RetGraph) of true -> true;
			%	_ -> error("Graph sanity check failed") end,
			%	case check_nodes(FinalAST) of true -> true;
			%	_ -> error("AST sanity check failed") end; _ -> true end,
			%if Node =:= 2 ->
			%	PostIdom = do_tarjan_immdom(rev_graph(RetGraph), 3); true -> 
		  %if IsCatch -> CNP = lists:last(lists:nth(if IsCatch -> CurNode;
		  %	true -> Node end, FinalNodesToAST)), io:format("~p~n", [{CNP}]);
		  %true -> true end,
		  %io:format("~p~n", [{RetGraph, CurNode, Node, NewAsgn, GrphElem}]),
			case lists:member(dotfile, Opts) of true ->
				%{PostIdom, _, _} = get_post_dom(RetGraph),
				PostIdom = get_pdom(RetGraph),
			  {RDFS, ODFS} = do_interval_dfs(rev_interval(RetGraph), 1),
			  {RDFSTup, ODFSTup} = {list_to_tuple(array:to_list(RDFS)), list_to_tuple(array:to_list(ODFS))},
				generate_dot_file(ast_to_dot(AST, Graph, "a",
					lists:member(dot2tex, Opts)) ++
				ast_to_dot(FinalAST, RetGraph, "b", lists:member(dot2tex, Opts)) ++
					generate_dot_text(AST, Graph, "v", 1, lists:member(dot2tex, Opts)) ++
					generate_dot_text(FinalAST, RetGraph, "w", 1,
						lists:member(dot2tex, Opts)) ++
				generate_dot_dom_text({Dom, "i", false, 1}) ++
				"\tedge[constraint=false];~n" ++
					generate_dot_dom_text({Dom, ODFSTup, index_from_search_tree(ODFSTup),
						"i", false, 1}) ++ "\tedge[constraint=true];~n" ++
				generate_dot_dom_text({PostIdom, "j", true, 1}) ++
				"\tedge[constraint=false];~n" ++
					generate_dot_dom_text({PostIdom, RDFSTup, index_from_search_tree(RDFSTup),
						"j", true, 1}),
					"temp/" ++ atom_to_list(ModName) ++ "-" ++
					re:replace(atom_to_list(FuncName), "\/", "_", [global,{return, list}])
					++ "-" ++ integer_to_list(Arity) ++ "-" ++
					if Node =:= 2 -> "ret"; true -> if IsCatch -> "block"; IsExit -> "exit"; true -> "" end
					++ integer_to_list(BaseLabel + begin A = lists:dropwhile(fun ({_K,V}) -> Node =/= V end, maps:to_list(LabelToNode)), if A =:= [] -> 0; true -> element(1, hd(A)) end end) end ++
					case lists:member(dot2tex, Opts) of true -> "-tex"; _ -> "" end ++
					".dot"); _ -> true end,
			{FinalAST, RetGraph, NewAsgn + RetAssignedVars, Node,
				Crs, CNodes, CEdges, CREdges}
	end
.

generate_dot_dom_text({Dom, DFS, IdxDFS, Prefix, IsPost, Idx}) ->
	case map_size(Dom) < Idx of true -> "";
	_ -> #{Idx := {IdxDom,_,_,_}} = Dom, DFSIdx = case element(Idx, DFS) of 1 -> 0;
		_ -> element(element(Idx, DFS) - 1, IdxDFS) end,
			case DFSIdx =/= 0 andalso IdxDom =/= DFSIdx of true ->
				"\t" ++ Prefix ++ integer_to_list(if IsPost -> Idx; true -> DFSIdx end)
				++ " -> " ++ Prefix ++ integer_to_list(if IsPost -> DFSIdx; true -> Idx
					end) ++ " [style=\"dashed\"];~n"; _ -> "" end ++
		generate_dot_dom_text({Dom, DFS, IdxDFS, Prefix, IsPost, Idx + 1}) end;
generate_dot_dom_text({Dom, Prefix, IsPost, Idx}) ->
	case map_size(Dom) < Idx of true -> "";
	_ -> #{Idx := {IdxDom,_,_,_}} = Dom, "\t" ++ Prefix ++ integer_to_list(Idx) ++
		"[label=\"" ++ integer_to_list(Idx) ++ "\"];~n" ++
		case IdxDom =/= 0 of true -> "\t" ++ Prefix ++
			integer_to_list(if IsPost -> Idx; true -> IdxDom end) ++ " -> "
			++ Prefix ++ integer_to_list(if IsPost -> IdxDom; true -> Idx
				end) ++ ";~n"; _ -> "" end ++
		generate_dot_dom_text({Dom, Prefix, IsPost, Idx + 1}) end.

graphdata_to_text(Data, AllPreds) ->
%simple flowgraph predecessor difference emission,
%	no dominator analysis deliberately here
	lists:append(lists:join("\\l",
		lists:filtermap(fun(El) -> case AllPreds =:= [] andalso array:get(El-1, element(3, Data)) =:= [] orelse AllPreds =/= [] andalso lists:all(fun (P) ->
			array:get(El-1, element(3, Data)) =:= array:get(El-1, element(3, P)) end,
			AllPreds) of true -> false; %register clearing now shown, should find a way to combine onto one or less lines though
			_ -> case array:get(El-1, element(3, Data)) of %[] -> false;
			X ->
				{true, "%X" ++ integer_to_list(El) ++ "=" ++ if X =:= [] -> ""; true -> try erl_prettypr:format(X)
					catch _:_ -> io_lib:format("~p", [X]) end end} end end end,
			lists:seq(1, 1024)) ++
		lists:filtermap(fun(El) -> case AllPreds =:= [] andalso array:get(El-1, element(4, Data)) =:= [] orelse AllPreds =/= [] andalso lists:all(fun (P) ->
			array:size(element(4, P)) >= El andalso array:get(El-1, element(4, Data)) =:=
			array:get(El-1, element(4, P)) end, AllPreds) of true -> false;
			_ -> case array:get(El-1, element(4, Data)) of %[] -> false;
			Y ->
				{true, "%Y" ++ integer_to_list(El) ++ "=" ++ if Y =:= [] -> ""; true -> try erl_prettypr:format(Y)
					catch _:_ -> io_lib:format("~p", [Y]) end end} end end end,
			lists:seq(1, array:size(element(4, Data)))) ++
		lists:filtermap(fun(El) -> case AllPreds =:= [] andalso array:get(El-1, element(5, Data)) =:= [] orelse AllPreds =/= [] andalso lists:all(fun (P) ->
			array:get(El-1, element(5, Data)) =:= array:get(El-1, element(5, P)) end,
			AllPreds) of true -> false;
			_ -> case array:get(El-1, element(5, Data)) of %[] -> false;
			Fr ->
				{true, "%Fr" ++ integer_to_list(El) ++ "=" ++ if Fr =:= [] -> ""; true -> try erl_prettypr:format(Fr)
				catch _:_ -> io_lib:format("~p", [Fr]) end end}
			end end end, lists:seq(1, 16))))
.

generate_dot_text({AST, NodesToAST, ASTDFS, IdxDFS},
	Graph, Prefix, Idx, ForTex) ->
	case next_node(Graph) - 1 < Idx of true -> "";
	_ -> DispAST = AST, %reduce_disp_graph_data(AST),
		"\t" ++ Prefix ++ integer_to_list(Idx) ++ "[shape=" ++ case gb_sets:size(get_succs(Idx, Graph)) =< 1 of true -> "rect"; _ -> "rect" end ++ ",label=" ++ "\"" ++ %"<" ++
			integer_to_list(Idx) ++
		case isnodeloopback({DispAST, NodesToAST, ASTDFS, IdxDFS}, Idx) of true -> ""; _ -> HdIdxPath = hd(array:get(Idx-1, NodesToAST)), IdxPath = lists:last(array:get(Idx-1, NodesToAST)), %io:format("~p~n", [{array:get(Idx-1, NodesToAST)}]),
			%"<BR />" ++ re:replace(re:replace(re:replace(
			"\\n" ++ re:replace(re:replace(lists:join("\\l", lists:filter(fun (El) -> El =/= [] end, [begin XPath = list_to_tuple(tuple_to_list(tuple_drop_n(IdxPath, 1)) ++ [X]), Data = lists:foldl(fun (Elem, Acc) -> case lists:any(fun (El) -> tup_prefix(XPath, El, tuple_size(XPath)) end, Elem) of true ->
				FirstPfx = lists:dropwhile(fun (El) -> not tup_prefix(XPath, El, tuple_size(XPath)) end, Elem),
				setelement(element(tuple_size(IdxPath) + 1, hd(FirstPfx)), Acc, case element(element(tuple_size(IdxPath) + 1, hd(FirstPfx)), Acc) of {'case',L,E,_} -> {'case',L,E,[]}; [{call,L,{'fun',_,{clauses,_}},_}] -> {'receive',L, []}; [{'try', L, _, _, _, _}] -> {'try', L, [], [], [], []}; [{'catch',L,_}] -> {'catch',L,[]}; Val when Val =:= {'try', 0, [], [], [], []}; Val =:= {'receive',0, []}; Val =:= {'catch',0,[]} -> Val; _ -> [] end);
				%removegraphpath(Acc, lists:nthtail(tuple_size(IdxPath), hd(lists:dropwhile(fun (El) -> not tup_prefix(XPath, El, tuple_size(XPath)) end, Elem))), 1);
			_ -> Acc end end, dogetgraphpath(DispAST, list_to_tuple(tuple_to_list(tuple_drop_n(IdxPath, 1)) ++ [X]), 1),
				lists:reverse(lists:delete(array:get(Idx-1, NodesToAST), array:to_list(NodesToAST)))),
					if element(1, Data) =:= graphdata -> graphdata_to_text(Data, case X =:= element(tuple_size(HdIdxPath), HdIdxPath) of true -> lists:filtermap(fun (P) -> case isnodeloopback({DispAST, NodesToAST, ASTDFS, IdxDFS}, P) of true -> false; _ -> {true, getgraphpath({DispAST, NodesToAST, ASTDFS, IdxDFS}, P)} end end, gb_sets:to_list(get_preds(Idx, Graph)));
						_ -> [dogetgraphpath(DispAST, list_to_tuple(tuple_to_list(tuple_drop_n(IdxPath, 1)) ++ [begin E = lists:last(lists:takewhile(fun (Y) -> element(tuple_size(Y), Y) < X end, array:get(Idx-1, NodesToAST))), element(tuple_size(E), E) end]), 1)] end);
						true -> try erl_prettypr:format(Data) catch _:_ -> io_lib:format("~p", [Data]) end end end || X <- lists:seq(element(tuple_size(HdIdxPath), HdIdxPath), element(tuple_size(IdxPath), IdxPath) + case getgraphpathlength({DispAST, NodesToAST, ASTDFS, IdxDFS}, Idx, true) > element(tuple_size(IdxPath), IdxPath) of true -> 1; _ -> 0 end)])),
				%"<", "\\&lt;", [global, {return, list}]), ">", "\\&gt;", [global, {return, list}]), "\n", "<BR />", [global, {return, list}]),
					"~", "~~", [global, {return, list}]), "\\\"(.*?)\\\"", if ForTex -> "``\\1''"; true -> "\\\\\"\\1\\\\\"" end, [global, {return, list}]) end ++ "\\l" ++ "\"" ++ %">" ++
					"];~n" ++
		lists:append(["\t" ++ Prefix ++ integer_to_list(Idx) ++ " -> " ++ Prefix ++ integer_to_list(X) ++
			case not isnodeloopback({DispAST, NodesToAST, ASTDFS, IdxDFS}, X) andalso tup_suffix(hd(array:get(X-1, NodesToAST)), {5, 1}, 2) andalso %(gb_sets:size(get_succs(X, Graph)) =/= 1 orelse gb_sets:to_list(get_succs(X, Graph)) =:= [3] orelse not tup_prefix_same(lists:last(array:get(X-1, NodesToAST)), lists:last(array:get(gb_sets:smallest(get_succs(X, Graph))-1, NodesToAST)), 1)) andalso
			element(1, dogetgraphpath(DispAST, tuple_drop_n(hd(array:get(X-1, NodesToAST)), 2), 1)) =:= clause andalso
			element(1, dogetgraphpath(DispAST, tuple_drop_n(hd(array:get(X-1, NodesToAST)), 4), 1)) =:= 'case' of true ->
				" [label=\"" ++ erl_prettypr:format(dogetgraphpath(DispAST, list_to_tuple(tuple_to_list(tuple_drop_n(hd(array:get(X-1, NodesToAST)), 2)) ++ [3,1]), 1)) ++ "\"]"; _ -> "" end ++ ";~n" || X <- gb_sets:to_list(get_succs(Idx, Graph))]) ++
		generate_dot_text({AST, NodesToAST, ASTDFS, IdxDFS}, Graph, Prefix, Idx + 1, ForTex) end
.

ast_to_dot({DispAST, NodesToAST, ASTDFS, IdxDFS}, Graph, Prefix, ForTex) ->
	CrossEdges = get_cross_edges({DispAST, NodesToAST, ASTDFS, IdxDFS}, Graph), Indent = length(integer_to_list(next_node(Graph) - 1)),
	"\t" ++ Prefix ++ "[shape=record fontname=\"monospace\" label=\"{" ++
	lists:foldl(fun (Idx, Ac) -> HdIdxPath = hd(array:get(Idx-1, NodesToAST)),
		Val = "<" ++ Prefix ++ integer_to_list(Idx) ++ "> " ++ integer_to_list(Idx) ++ ":" ++ lists:append(lists:duplicate(tuple_size(HdIdxPath) + Indent - length(integer_to_list(Idx)), "\\ ")) ++
		case isnodeloopback({DispAST, NodesToAST, ASTDFS, IdxDFS}, Idx) of true -> ""; _ -> IdxPath = lists:last(array:get(Idx-1, NodesToAST)),
			SeqEnd = element(tuple_size(IdxPath), IdxPath) + case getgraphpathlength({DispAST, NodesToAST, ASTDFS, IdxDFS}, Idx, true) > element(tuple_size(IdxPath), IdxPath) of true -> 1; _ -> 0 end,
			re:replace(re:replace(re:replace(re:replace(re:replace(re:replace(re:replace(lists:join("\\l" ++ lists:append(lists:duplicate(tuple_size(HdIdxPath) + 1 + Indent, " ")), lists:filter(fun (El) -> El =/= [] end, [begin XPath = list_to_tuple(tuple_to_list(tuple_drop_n(IdxPath, 1)) ++ [X]), Data = lists:foldl(fun (Elem, Acc) -> case lists:any(fun (El) -> tup_prefix(XPath, El, tuple_size(XPath)) end, Elem) of true ->
				FirstPfx = lists:dropwhile(fun (El) -> not tup_prefix(XPath, El, tuple_size(XPath)) end, Elem), %io:format("~p~n", [{Elem, XPath, IdxPath, FirstPfx}]),
				setelement(element(tuple_size(IdxPath) + 1, hd(FirstPfx)), Acc, case element(element(tuple_size(IdxPath) + 1, hd(FirstPfx)), Acc) of {'case',L,E,_} -> {'case',L,E,[]}; [{call,L,{'fun',_,{clauses,_}},_}] -> {'receive',L, []}; [{'try', L, _, _, _, _}] -> {'try', L, [], [], [], []}; [{'catch',L,_}] -> {'catch',L,[]}; Val when Val =:= {'try', 0, [], [], [], []}; Val =:= {'receive',0, []}; Val =:= {'catch',0,[]} -> Val; _ -> [] end);
				%removegraphpath(Acc, lists:nthtail(tuple_size(IdxPath), hd(lists:dropwhile(fun (El) -> not tup_prefix(XPath, El, tuple_size(XPath)) end, Elem))), 1);
			_ -> Acc end end, dogetgraphpath(DispAST, XPath, 1),
				lists:reverse(lists:delete(array:get(Idx-1, NodesToAST), array:to_list(NodesToAST)))),
					if element(1, Data) =:= graphdata -> %case element(tuple_size(HdIdxPath), HdIdxPath) of SeqEnd ->
						case array:get(Idx-1, NodesToAST) =/= [{}] andalso tup_suffix(HdIdxPath, {5, 1}, 2) andalso %(gb_sets:size(get_succs(Idx, Graph)) =/= 1 orelse gb_sets:to_list(get_succs(Idx, Graph)) =:= [3] orelse not tup_prefix_same(IdxPath, lists:last(array:get(gb_sets:smallest(get_succs(Idx, Graph))-1, NodesToAST)), 1)) andalso
							element(1, dogetgraphpath(DispAST, tuple_drop_n(HdIdxPath, 2), 1)) =:= clause andalso
							element(1, dogetgraphpath(DispAST, tuple_drop_n(HdIdxPath, 4), 1)) =:= 'case' of true ->
								erl_prettypr:format(dogetgraphpath(DispAST, list_to_tuple(tuple_to_list(tuple_drop_n(HdIdxPath, 2)) ++ [3,1]), 1)) ++ " -> "; _ -> "" end; %_ -> "" end;
						true -> case X =:= element(tuple_size(HdIdxPath), HdIdxPath) + 1 of true ->
							case array:get(Idx-1, NodesToAST) =/= [{}] andalso tup_suffix(HdIdxPath, {5, 1}, 2) andalso %(gb_sets:size(get_succs(Idx, Graph)) =/= 1 orelse gb_sets:to_list(get_succs(Idx, Graph)) =:= [3] orelse not tup_prefix_same(IdxPath, lists:last(array:get(gb_sets:smallest(get_succs(Idx, Graph))-1, NodesToAST)), 1)) andalso
								element(1, dogetgraphpath(DispAST, tuple_drop_n(HdIdxPath, 2), 1)) =:= clause andalso
								element(1, dogetgraphpath(DispAST, tuple_drop_n(HdIdxPath, 4), 1)) =:= 'case' of true ->
									erl_prettypr:format(dogetgraphpath(DispAST, list_to_tuple(tuple_to_list(tuple_drop_n(HdIdxPath, 2)) ++ [3,1]), 1)) ++ " -> "; _ -> "" end; _ -> "" end ++
							try erl_prettypr:format(Data) catch _:_ -> io_lib:format("~p", [Data]) end end end || X <- lists:seq(element(tuple_size(HdIdxPath), HdIdxPath), SeqEnd)])),
				" ", "\\\\ ", [global, {return, list}]), "~", "~~", [global, {return, list}]), "\\>", "\\\\>", [global, {return, list}]), "\\{", "\\\\{", [global, {return, list}]), "\\}", "\\\\}", [global, {return, list}]), "\\<", "\\\\<", [global, {return, list}]), "\\\"(.*?)\\\"", if ForTex -> "``\\1''"; true -> "\\\\\"\\1\\\\\"" end, [global, {return, list}]) end ++ "\\l",
				if Ac =:= [] -> Ac; true -> Ac ++ "|" end ++ if ForTex -> re:replace(re:replace(Val, "\\\\ (?!\\\\l)", "\\\\&", [global, {return, list}]), "_", "\\\\\\\\_", [global, {return, list}]); true -> Val end
		end, [], tl(array:to_list(ASTDFS)) ++ [array:get(1-1, ASTDFS)]) ++ "}\"];~n" ++ lists:foldl(fun (Idx, Acc) -> Acc ++ lists:append(["\t" ++ Prefix ++ ":" ++ Prefix ++ integer_to_list(Idx) ++ ":w -> " ++ Prefix ++ ":" ++ Prefix ++ integer_to_list(X) ++ ":w;~n" || X <- gb_sets:to_list(array:get(Idx-1, CrossEdges))]) end, [], lists:seq(1, array:size(CrossEdges)))
.

%ast_to_code_label(AST) ->
%	re:replace(re:replace(re:replace(re:replace(erl_prettypr:format(hd(fix_graph_tuples(resolve_graph_data(AST, true)))),
%  	"<", "\\&lt;", [global, {return, list}]), ">", "\\&gt;", [global, {return, list}]), "\n", "<BR />", [global, {return, list}]), "~", "~~", [global, {return, list}]).

generate_dot_file(GraphStr, Filename) ->
	{ok, Fd} = file:open(Filename, [write]),
  io:fwrite(Fd, "digraph {~n\tgraph [dpi=150];~n" ++ "\tlabel=<" ++ "" ++ ">;~n\tlabelloc=\"t\";~n" ++ GraphStr ++ "}~n", []),
  file:close(Fd)
.

continue_scan(FullInstList, AST, Graph, NodeState, LabelToNode, BaseLabel) ->
	%never scan merge nodes which have unresolved predecessors reaching it also linked to the return node
	%it looks like a breadth first search ordering yields an appropriate criterion
	CurBFS = do_bfs(Graph, 1),
	IdxBFS = index_from_search_tree(CurBFS),
	AP = fun AllProc(Nodes, NewNodes) -> NextNodes = gb_sets:union(Nodes, NewNodes),
		TotNextNodes = gb_sets:add_element(3, gb_sets:add_element(2, NextNodes)),
		NextProc = gb_sets:union(gb_sets:fold(fun (El, Acc) -> [case lists:dropwhile(fun (E) -> getmergepredblockstruct(AST, E, get_preds(E, Graph)) =:= false end, gb_sets:to_list(get_succs(El, Graph))) of [] -> get_succs(El, Graph); [Hd|_] -> gb_sets:del_element(Hd, get_succs(El, Graph)) end|Acc] end, [], NewNodes)),
		case gb_sets:is_subset(NextProc, TotNextNodes) of true -> true; _ -> lists:all(fun (El) -> gb_sets:is_element(El, TotNextNodes) orelse isnodeloopback(AST, El) orelse getnodevisited(NodeState, El) =< 0 end, gb_sets:to_list(NextProc)) andalso AllProc(NextNodes, NextProc) end end,
	Candidates = lists:filtermap(fun (El) -> case El =:= 3 orelse not isnodeloopback(AST, El) andalso getnodevisited(NodeState, El) =/= 1 orelse
		(isnodeloopback(AST, El) orelse getnodevisited(NodeState, El) =/= 1) andalso gb_sets:size(get_preds(El, Graph)) =:= 1 andalso
			begin Res = getnodeblockstruct(AST, gb_sets:smallest(get_preds(El, Graph)), 0), Res =/= false andalso Res =/= var end andalso not AP(gb_sets:from_list([El]), gb_sets:from_list([gb_sets:smallest(get_preds(El, Graph))])) of true -> false; _ -> {true, element(El, IdxBFS)} end end, gb_sets:to_list(get_preds(2, Graph))),
	if Candidates =:= [] -> {[], 2}; true ->
	NextNode = element(lists:min(Candidates), CurBFS),
	NodeLabel = BaseLabel - 1 + element(1, hd(lists:dropwhile(fun ({_K,V}) -> NextNode =/= V end, maps:to_list(LabelToNode)))),
	Colliding = lists:dropwhile(fun (El) -> getnodevisited(NodeState, El) =/= -1 end, gb_sets:to_list(get_preds(NextNode, Graph))),
	%LabelToInstruction mapping based on a one time list walk would optimize this lookup
	{lists:dropwhile(fun (El) -> case El of {label,NodeLabel} -> false; _ -> true end end, FullInstList), if Colliding =/= [] -> hd(Colliding); true -> NextNode end} end
.

decompile_select({InstList, AST, Graph, NodeState, LabelToNode, CurNode,
	VarPrefix, AssignedVars, _Jumped, Stats}, Glob, Val, Cur, IsTupleArity) ->
	%IsTupleArity: getmemd(Cur, element(2, Val) vs %{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, element(2, Val))]}
	LblIdx = element(2, element(3, Val)) - element(1, Glob) + 1,
	{_, _, UniqueLbls} = lists:foldl(fun(Elem, {Acc, AccCheck, AccMap}) -> if Acc =:= [] -> {Elem, AccCheck, AccMap}; true -> ElIdx = element(2, Elem), case AccCheck of #{ElIdx := Idx} -> #{Idx := {Lbl, L}} = AccMap, {[], AccCheck, AccMap#{Idx => {Lbl, [Acc|L]}}}; _ -> {[], AccCheck#{element(2, Elem) => map_size(AccMap) + 1}, AccMap#{map_size(AccMap) + 1 => {element(2, Elem), [Acc]}}} end end end, {[], #{}, #{}}, getmemd(Cur, element(4, Val))),
	NextNode = next_node(Graph), DefIdx = map_size(UniqueLbls) + 1, NotExists = gb_sets:from_list(begin NL = lists:filter(fun (Elem) -> 
	ElemIdx = begin #{Elem := {ElemLbl,_}} = UniqueLbls, ElemLbl end - element(1, Glob) + 1, case LabelToNode of #{ElemIdx := _} -> false; _ -> true end
	end, lists:seq(1, map_size(UniqueLbls))), case element(2, element(3, Val)) < element(1, Glob) orelse case LabelToNode of #{LblIdx := _} -> false; _ -> true end of true -> [0|NL]; _ -> NL end end),
	NewAST = batchinsertgraphnodechild(
	%lists:foldl(fun(Elem, Acc) -> insertgraphnodechild(insertgraphnodechild(Acc, CurNode, {select_val, Elem}, true, {graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, NextNode + Elem * 2 - 2),
			%CurNode, {select_val, Elem}, false, {graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, NextNode + Elem * 2 - 1) end,
		insertgraphnode(AST, CurNode,
						%{'case',0,{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, element(2, Val))]}, lists:reverse(lists:foldl(fun(Elem, Acc) -> if length(Acc) =:= 0 orelse is_tuple(hd(Acc)) -> [[Elem]|Acc]; true -> [{clause,0,[{integer,0,hd(hd(Acc))}],[], [{graphdata, element(2, Elem), element(3, Cur), element(4, Cur), element(5, Cur)}]}|tl(Acc)] end end, [], getmemd(Cur, element(4, Val)))) ++ [{clause,0,[{var,0,'_'}],[], [{graphdata, element(2, element(3, Val)), element(3, Cur), element(4, Cur), element(5, Cur)}]}]}),
						%should also call is_tuple here for default case equivalence or badarg would occur!!!
		lists:foldl(fun(Elem, Acc) -> #{Elem := {_,E}} = UniqueLbls, {'case',0,case E of [_] -> if IsTupleArity -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, element(2, Val))]}; true -> getmemd(Cur, element(2, Val)) end; [HdE|Tl] ->
			lists:foldl(fun (A,B) -> if IsTupleArity -> {op,0,'orelse',{op,0,'andalso',{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},[getmemd(Cur, element(2, Val))]},{op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, element(2, Val))]},{integer,0,A}}},B};
				true -> {op,0,'orelse',{op,0,'=:=',getmemd(Cur, element(2, Val)),case element(1, A) of atom -> {atom,0,element(2, A)}; integer -> {integer,0,element(2, A)} end},B} end end,
				if IsTupleArity -> {op,0,'andalso',{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},[getmemd(Cur, element(2, Val))]},{op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, element(2, Val))]},{integer,0,HdE}}};
				true -> {op,0,'=:=',getmemd(Cur, element(2, Val)),case element(1, HdE) of atom -> {atom,0,element(2, HdE)}; integer -> {integer,0,element(2, HdE)} end} end,
				Tl) end,[{clause,0,[case E of [Hd] -> if IsTupleArity -> {integer,0,Hd}; true -> case element(1, Hd) of atom -> {atom,0,element(2, Hd)}; integer -> {integer,0,element(2, Hd)} end end; _ -> {atom,0,true} end],[], [{graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}]},
					{clause,0,[{var,0,'_'}],[], [{graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}] ++ if Acc =:= {} -> if element(2, element(3, Val)) < element(1, Glob) -> [{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{atom, 0, function_clause}]}]; true -> [] end; true -> [Acc] end}]} end, {}, lists:seq(map_size(UniqueLbls), 1, -1)), 0), %lists:foldl(fun (Elem, Acc) -> if length(Acc) rem 2 =:= 0 -> [Elem|Acc]; true -> [hd(Acc)|[Elem|tl(Acc)]] end end, [], getmemd(Cur, element(4, Val)))
			CurNode, {select_val, lists:seq(1, map_size(UniqueLbls))}, NextNode),
		%lists:seq(1, map_size(UniqueLbls))),
	NewEdges = begin UpGraph = lists:foldl(fun(Elem, Acc) ->
			NewGraph = [{if Elem =:= 1 -> CurNode; true -> NextNode + Elem * 2 - 3 end, NextNode + Elem * 2 - 1},
				{if Elem =:= 1 -> CurNode; true -> NextNode + Elem * 2 - 3 end, NextNode + Elem * 2 - 2}|Acc],
			%case gb_sets:is_element(Elem, NotExists) of true -> NewGraph; _ -> [{NextNode + Elem * 2 - 2, lists:nth(begin #{Elem := {ElemLbl,_}} = UniqueLbls, ElemLbl end - element(1, Glob) + 1, LabelToNode)}|NewGraph] end
			[{NextNode + Elem * 2 - 2, case gb_sets:is_element(Elem, NotExists) of true -> 2; _ -> CurLbl = begin #{Elem := {ElemLbl,_}} = UniqueLbls, ElemLbl end - element(1, Glob) + 1, #{CurLbl := CNode} = LabelToNode, CNode end}|NewGraph] 
			end, [], lists:seq(1, map_size(UniqueLbls))),
		case gb_sets:is_element(0, NotExists) of true -> if element(2, element(3, Val)) < element(1, Glob) -> [{NextNode + DefIdx * 2 - 3, 2}|UpGraph]; true -> [{NextNode + DefIdx * 2 - 3, 2}|UpGraph] end; _ -> [{NextNode + DefIdx * 2 - 3, begin #{LblIdx := LblNode} = LabelToNode, LblNode end}|UpGraph] end end,
	NewG = remove_edge(CurNode, 2, lists:foldl(fun({P, S}, Acc) -> add_edge(P, S, Acc, NewAST, {true, false}) end,
		begin G = lists:foldl(fun({P, S}, Acc) -> add_edge(P, S, Acc, NewAST, {true, true}) end, Graph, lists:reverse(NewEdges)), Map = element(7, G), #{2 := {RetSet,_}} = Map, setelement(7, G, Map#{2 := {gb_sets:union(RetSet, gb_sets:from_list(lists:seq(NextNode, NextNode + map_size(UniqueLbls) * 2 - case gb_sets:is_element(0, NotExists) of true -> if element(2, element(3, Val)) < element(1, Glob) -> 2; true -> 1 end; _ -> case gb_sets:is_element(begin #{LblIdx := LblNde} = LabelToNode, LblNde end, RetSet) of true -> 1; _ -> 2 end end))), gb_sets:new()}}) end,
		if element(2, hd(NewEdges)) =:= 3 -> [hd(tl(NewEdges)), hd(tl(tl(tl(NewEdges))))|tl(tl(tl(tl(NewEdges))))] ++ [hd(NewEdges), hd(tl(tl(NewEdges)))]; true -> NewEdges end), NewAST, false),
	{ModAST, ModGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} = if element(2, element(3, Val)) < element(1, Glob) ->
		handle_exit_merge(NewAST, NewG, NodeState, NextNode + DefIdx * 2 - 3, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)); true -> {NewAST, NewG, 0, 0, 0, 0, 0} end,
	#{0 := {C, CN, CE, CRE}} = Stats,
	decompile_step({tl(InstList), ModAST,
		%getmemd(Cur, element(4, Val)), element(3, Val),
						%add_edge(NextNode + DefIdx - 1, case gb_sets:is_element(0, NotExists) of true -> 2; _ -> begin #{LblIdx := LblNode} = LabelToNode, LblNode end end, add_edge(CurNode, NextNode + DefIdx - 1, lists:foldl(fun(Elem, Acc) -> add_edge(NextNode + Elem - 1, case gb_sets:is_element(Elem, NotExists) of true -> 2; _ -> lists:nth(element(2, lists:nth(Elem * 2, getmemd(Cur, element(4, Val)))) - element(1, Glob) + 1, LabelToNode) end, add_edge(CurNode, NextNode + Elem - 1, Acc)) end, Graph, lists:seq(1, length(getmemd(Cur, element(4, Val))) div 2)))),
		ModGraph,
		%insert_renumber(NodesToAST, getnextsibling(CurNodePath)) ++ lists:foldl(fun (El, A) -> if El =:= 1 -> lists:droplast(A); true -> A end ++ [[if El =:= 1 -> lists:last(lists:last(A)); true -> getnextsibling(lists:last(lists:last(A))) end ++ [4, 1, 5, 1]],[if El =:= 1 -> lists:last(lists:last(A)); true -> getnextsibling(lists:last(lists:last(A))) end ++ [4, 2, 5, 1]]] end, [[getnextsibling(CurNodePath)]], lists:seq(1, length(UniqueLbls))),
						%insert_renumber(NodesToAST, getnextsibling(CurNodePath)) ++ [[getnextsibling(CurNodePath) ++ [4, X, 5, 1]] || X <- lists:seq(1, length(getmemd(Cur, element(4, Val))) div 2 + 1)],
						%lists:foldl(fun(Elem, Acc) -> addtolist(element(2, if Elem =:= 0 -> element(3, Val); true -> lists:nth(Elem * 2, getmemd(Cur, element(4, Val))) end) - element(1, Glob) + 1, Acc, NextNode - 1 + if Elem =:= 0 -> DefIdx; true -> Elem end) end, LabelToNode, NotExists)
						%insert_renumber(NodesToAST, getnextsibling(CurNodePath)) ++ lists:foldl(fun (El, A) -> if El =:= 1 -> lists:droplast(A); true -> A end ++ [[if El =:= 1 -> lists:last(lists:last(A)); true -> getnextsibling(lists:last(lists:last(A))) end ++ [4, 1, 5, 1]],[if El =:= 1 -> lists:last(lists:last(A)); true -> getnextsibling(lists:last(lists:last(A))) end ++ [4, 2, 5, 1]]] end, [[getnextsibling(CurNodePath)]], lists:seq(1, length(UniqueLbls))),
		lists:foldl(fun (Elem, Acc) -> NS = case gb_sets:is_element(Elem, NotExists) of true -> setnodevisited(Acc, NextNode + Elem * 2 - 2, 2); _ -> Acc end, if Elem =:= map_size(UniqueLbls) -> case gb_sets:is_element(0, NotExists) of true -> if element(2, element(3, Val)) < element(1, Glob) -> NS; true -> setnodevisited(NS, NextNode + Elem * 2 - 1, 2) end; _ -> NS end; true -> NS end end, NodeState, lists:seq(1, map_size(UniqueLbls))),
		gb_sets:fold(fun(Elem, Acc) -> if Elem =:= 0 andalso element(2, element(3, Val)) < element(1, Glob) -> Acc; true -> Acc#{if Elem =:= 0 -> element(2, element(3, Val)); true -> begin #{Elem := {ElemLbl,_}} = UniqueLbls, ElemLbl end end - element(1, Glob) + 1 => NextNode + if Elem =:= 0 -> DefIdx * 2 - 3; true -> Elem * 2 - 2 end} end end, LabelToNode, NotExists),
		CurNode, VarPrefix, AssignedVars + NewAsgn, true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob)
.

decompile_step({InstList, AST, Graph, NodeState, LabelToNode, CurNode,
	VarPrefix, AssignedVars, Jumped, Stats}, Glob) ->
	%case lists:member(nosanitycheck, element(5, Glob)) of false ->
	%	case check_pred_succ(Graph) of true -> true;
	%	_ -> error({"Graph sanity check failed", Graph}) end,
	%	case check_nodes(AST) of true -> true;
	%	_ -> error("AST sanity check failed") end; _ -> true end,
	%io:format("~p~n", [{LabelToNode, Jumped, CurNode, Graph}]),
	%io:format("~p~n", [AST]),
	%io:format("~p~n", [reduce_disp_graph_data(AST)]),
	%if Jumped -> {NextInstList, NextNode} = continue_scan(, AST, Graph), decompile_step({NextInstList, AST, Graph, NodeState, LabelToNode, NextNode, VarPrefix, AssignedVars, false}, Glob); true -> 
	case Jumped andalso lists:member(bfsscan, element(5, Glob)) of true ->
		NextLabel = lists:dropwhile(fun (El) -> case El of {label,LabelIdx} -> AdjLbl = LabelIdx - element(1, Glob) + 1, case LabelToNode of #{AdjLbl := N} -> case isnodeloopback(AST, N) of true -> true; _ -> false end; _ -> false end; _ -> true end end, InstList),
		NextNodeState = case NextLabel of [{label,LabelIdx}|_] -> AdjLbl = LabelIdx - element(1, Glob) + 1, case LabelToNode of #{AdjLbl := N} -> case isnodeloopback(AST, N) of true -> NodeState; _ -> case getnodevisited(NodeState, N) of 2 -> setnodevisited(NodeState, N, 1); _ -> NodeState end end; _ -> NodeState end; _ -> NodeState end,
		{NextInst, NextNode} = continue_scan(element(6, Glob), AST, Graph, NextNodeState, LabelToNode, element(1, Glob)),
		decompile_step({NextInst, AST, Graph, NextNodeState, LabelToNode, NextNode,
			VarPrefix, AssignedVars, false, Stats}, Glob);
	_ -> case InstList of [] ->
			%merge the node if only one predecessor or an empty expression in graph results
			%case length(lists:nth(2, Pred)) =:= 1 of true ->
			%	NewPred = [hd(Pred)|lists:nthtail(2, Pred)],
			%	RemSucc = setnth(hd(lists:nth(2, Pred)), Succ, lists:delete(2, lists:nth(hd(lists:nth(2, Pred)), Succ))),
			%	NewSucc = [hd(RemSucc)|if length(RemSucc) > 2 -> lists:nthtail(2, RemSucc); true -> [] end],
			%	CurNodePath = lists:last(lists:nth(hd(lists:nth(2, Pred)), NodesToAST)), RemPath = hd(lists:nth(2, NodesToAST)), %getgraphpath(AST, getnextsibling(RemPath))
			%	io:format("~p~n", [{CurNodePath, RemSucc, NewGraph}]),
			%	{InstList, insertgraphnode(AST, CurNode, hd(element(3, getgraphpath(AST, CurNodePath))), 0), NewGraph, [hd(NodesToAST)|lists:nthtail(2, NodesToAST)], LabelToNode, CurNode, VarPrefix, AssignedVars, false};
			%	_ ->
		  {FinalAST, FixGraph, NewAsgn, NextNode, Crs, CNodes, CEdges, CREdges} =
		  	handle_merge_node(AST, Graph, CurNode, 2, AssignedVars, VarPrefix,
		  		{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
		  			hd(element(2, Glob))}, false, false, false, element(5, Glob)),
		  #{0 := {C, CN, CE, CRE}} = Stats,
			{InstList, FinalAST, FixGraph, NodeState, LabelToNode, NextNode,
				VarPrefix, AssignedVars + NewAsgn, false,
				Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}};
			%sanity check: no nodes with 3 successors (unresolved try catch or receive), and no cross edges remaining at this point...
		_ -> Cur = getgraphpath(AST, CurNode), Val = hd(InstList),
		case lists:member(progress, element(5, Glob)) of true -> io:format("~p~n", [Val]); _ -> true end,
		%theoretically should try to skip extra BEAM instructions that are unreachable after jumps, have not yet seen compiler do this though
		case Jumped andalso case Val of {label,_} -> false; _ -> true end of true ->
			decompile_step({lists:dropwhile(fun (El) -> case El of {label,_} -> false;
				_ -> true end end, tl(InstList)), AST, Graph, NodeState, LabelToNode,
				CurNode, VarPrefix, AssignedVars, true, Stats}, Glob);
		_ ->
		case Val of
			return -> decompile_step({tl(InstList), AST, Graph, NodeState,
				LabelToNode, CurNode, VarPrefix, AssignedVars, true, Stats}, Glob);
			on_load -> decompile_step({tl(InstList), AST, Graph, NodeState,
				LabelToNode, CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
			fclearerror -> decompile_step({tl(InstList), AST, Graph, NodeState,
				LabelToNode, CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
			remove_message -> %in this case predecessor search looks to be a valid option and largely the only option due to no side effects or more specifically receives between one receive polling and its processing
				RecvNode = fun PredRecurse(Pcsd, X) -> Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [get_preds(El, Graph)|Acc] end, [], X)))),
					Match = lists:dropwhile(fun(El) -> %case lists:prefix(lists:droplast(lists:last(lists:nth(El, NodesToAST))), lists:last(lists:nth(CurNode, NodesToAST))) of true ->
					case getnodeblockstruct(AST, El, 0) of 'receive' -> false; _ -> true end end, gb_sets:to_list(Y)),
					case Match =/= [] orelse gb_sets:size(Y) =:= 0 of true -> hd(Match); _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([CurNode])),
				NewAST = insertgraphnode(AST, CurNode, {call,0,getgraphpathchild(AST, remove_message, false, RecvNode),[getgraphpathchild(AST, remove_message, true, RecvNode)]}, Cur, CurNode),
			 	decompile_step({tl(InstList), NewAST, Graph, NodeState, LabelToNode,
			 		CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
			send -> ModAST = insertgraphnode(AST, CurNode, {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}, {op,0,'!', getmemd(Cur, {x, 0}), getmemd(Cur, {x, 1})}}, setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode),
				%side effect assignment
				decompile_step({tl(InstList), ModAST, Graph, NodeState, LabelToNode,
					CurNode, VarPrefix, AssignedVars + 1, false, Stats}, Glob);
			bs_init_writable ->
				decompile_step({tl(InstList), setgraphpath(AST, CurNode,
						setmemd(Cur, {x, 0},{bin,0,
								[{bin_element,0,{integer,0,0},getmemd(Cur, {x, 0}),default}]})),
				Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
				false, Stats}, Glob);
			timeout ->
			  case isnodeloopback(AST, CurNode) of false -> %wait_timeout already processed
					decompile_step({tl(InstList), AST, Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				true -> RecvNode = gb_sets:smallest(get_preds(CurNode, Graph)),
					%this should use a length check on all predecessors...
					%RecvNodePath = getnextsibling(lists:last(lists:nth(RecvNode, NodesToAST))) ++ [4, 1], %lists:droplast(CurNodePath) ++ [lists:last(CurNodePath) - 2, 4, 1],
					%case hd(lists:nth(CurNode, NodesToAST)) =:= RecvNodePath ++ [4, 3, 3, 1, 2, 1, 5, 1] of true -> %wait_timeout already processed
					%io:format("~p~n", [{CurNode, RecvNode, RecvNodePath, Graph}]),
					NewNode = next_node(Graph),
					NewAST = insertgraphnodechild(setgraphpathchild(AST, timeout, true, RecvNode, {call,0,{'fun',0,{clauses,get_clean_ast_all(element(4, Glob), 'receive', 3, lists:member(stubfuncs, element(5, Glob)))}},[getgraphpathchild(AST, timeout, true, RecvNode), {integer,0,0}, {'fun',0,[{clauses,[{clause,0,[],[],[]}]}]}]}), RecvNode, 'receive', false, getgraphpath(AST, RecvNode), NewNode),
					decompile_step({tl(InstList), NewAST,
						add_edge(CurNode, 3,
							add_edge(RecvNode, NewNode, Graph, NewAST, false), NewAST, false),
						NodeState, LabelToNode, NewNode, VarPrefix, AssignedVars,
						false, Stats}, Glob)
				end;
			if_end -> {NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
				handle_exit_merge(insertgraphnode(AST, CurNode,
				{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{atom, 0, if_clause}]}, 0),
				Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
				#{0 := {C, CN, CE, CRE}} = Stats,
				decompile_step({tl(InstList), NewAST, NewGraph, NodeState, LabelToNode,
					CurNode, VarPrefix, AssignedVars + NewAsgn, true,
					Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
			_ -> case element(1, Val) of
				label -> AdjLbl = element(2, Val) - element(1, Glob) + 1,
				NewNode = case LabelToNode of #{AdjLbl := N} -> N; _ -> 0 end,
				if NewNode =:= 0 ->
					decompile_step({if Jumped -> lists:dropwhile(fun (El) -> case El of
						{label,_} -> false; _ -> true end end, tl(InstList)); true -> tl(InstList) end, AST, Graph,
						NodeState, LabelToNode#{AdjLbl => CurNode}, CurNode, VarPrefix, AssignedVars,
						Jumped, Stats}, Glob); true ->
				%BEAM can have unreachable code snippits
				%which must be discarded from decompilation
				%if prior instruction was entry or a jump, no edge addition
				%jumps are handled at that deterministic time,
				%	only deal with block colliding/reaching here
				NewGraph = case Jumped orelse NewNode =:= CurNode orelse not isnodeloopback(AST, CurNode) andalso getnodevisited(NodeState, CurNode) =:= -1 of true -> Graph; _ -> add_edge(CurNode, NewNode, Graph, AST, false) end,
				case lists:member(bfsscan, element(5, Glob)) andalso not isnodeloopback(AST, CurNode) andalso getnodevisited(NodeState, CurNode) =:= 0 andalso getnodevisited(NodeState, NewNode) =:= 2 of true ->
					decompile_step({InstList, AST, NewGraph,
						setnodevisited(NodeState, CurNode, -1),
						LabelToNode#{element(2, Val) - element(1, Glob) + 1 => case begin LblIdx = element(2, Val) - element(1, Glob) + 1, case LabelToNode of #{LblIdx := _} -> false; _ -> true end end of true -> CurNode; _ -> NewNode end},
					NewNode, VarPrefix, AssignedVars, true, Stats}, Glob);
				_ ->
				%if catch paths all exit, 1 predecessor and cannot emit variable assignment
				%multiple catch to one catch_end is a compiler optimization
				IsCatch = case isnodeloopback(AST, NewNode) of true -> []; _ -> lists:filter(fun (El) -> getnodeblockstruct(AST, El, NewNode) =:= 'catch' end, gb_sets:to_list(get_preds(NewNode, NewGraph))) end,
				IsTryCatch = case isnodeloopback(AST, NewNode) of true -> []; _ -> lists:filter(fun (El) -> getnodeblockstruct(AST, El, 0) =:= 'try' end, gb_sets:to_list(get_preds(NewNode, NewGraph))) end,
				CAE = fun CheckAllEq(_, _, _, []) -> true; CheckAllEq(Idx, El, V, GDatas) -> case array:get(El-1, element(Idx, hd(GDatas))) of X when X =:= []; X =:= V; V =:= [] -> CheckAllEq(Idx, El, if X =:= [] -> V; true -> X end, tl(GDatas)); _ -> false end end,
				TryAST =
					%try_end does not occur if all try block leads to out of band exits so must handle on exit or via try_end
					%HeadNode = fun PredRecurse(Pcsd, X) -> Comb = Pcsd ++ X, Y = lists:usort(lists:append(lists:map(fun (El) -> lists:nth(El, Pred) end, X))) -- Comb,
						%Match = lists:dropwhile(fun(El) -> case lists:prefix(lists:droplast(lists:last(lists:nth(El, NodesToAST))), lists:last(lists:nth(CurNode, NodesToAST))) of
							%true -> case getgraphpath(AST, getnextsibling(lists:last(lists:nth(El, NodesToAST)))) of {match,_,_,[{'try', _, _, _, _, _}]} -> false; _ -> true end; _ -> true end end, Y),
						%io:format("~p~n", [{Y, Match}]),
						%if Match =/= [] orelse Y =:= [] -> hd(Match); true -> PredRecurse(Comb, Y) end end([], [CurNode]),
					%TryNodePath = getnextsibling(lists:last(lists:nth(HeadNode, NodesToAST))),
					%TryNode = hd(lists:dropwhile(fun (El) -> hd(lists:nth(El, NodesToAST)) =/= TryNodePath ++ [4, 1, 3, 1] end, lists:nth(HeadNode, Succ))),
					%{Idom, _, _} = get_post_dom(Graph),
					%case not lists:member(2, pathtodom(Idom, TryNode)) of true ->
						%io:format("~p~n", [{Idom, Succ, Pred}]),
						%all exit nodes are technically jumps to the catch block, yet the register state must transfer
						%due to no merge due to exits from try node, must take a tree walk, and can put undefined for any variables which have different values down different branches
						%assuming currently that all paths from the try node reach the case node which needs to be further analyzed
					
					%data-flow semantics: scan entire subgraph of try block until try_end, skipping over catch or inner try block (but then still must deal with case and catch block part)
					%need to stop at first unsafe statement, perhaps a simple shortcut for compiled code is to scan until first block end only
					lists:foldl(fun (HeadNode, AccAST) ->
						TryGraphData = fun TreeWalk(Node) -> %catch is already sent to its latch, skip try_end and traverse both parts of try case and catch blocks in case they throw errors
							GraphDatas = lists:filtermap(fun (El) -> case getnodeblockstruct(AccAST, Node, 0) of 'try' -> case isblockchild(AccAST, try_end, true, Node, El) orelse isblockchild(AccAST, 'try', false, Node, El) of true -> {true, TreeWalk(El)}; _ -> false end; 'catch' -> false; _ -> case isnodeloopback(AccAST, El) of true -> false; _ -> false %{true, TreeWalk(El)}
								end end end, gb_sets:to_list(gb_sets:del_element(3, gb_sets:del_element(2, get_succs(Node, NewGraph))))), if GraphDatas =:= [] -> getgraphpath(AccAST, Node); true ->
							lists:foldl(fun (El, A) -> setelement(3, A, array:set(El-1, case CAE(3, El, [], GraphDatas) of true -> array:get(El-1, element(3, hd(GraphDatas))); _ -> [] end, element(3, A))) end, %undefined
								lists:foldl(fun (El, A) -> V = array:get(El-1, element(4, hd(GraphDatas))), setelement(4, A, case El > array:size(element(4, A)) of true -> array:from_list(array:to_list(element(4, A)) ++ case El - 1 > array:size(element(4, A)) of true -> [[] || _Y <- lists:seq(tuple_size(element(4, A)) + 1, El - 1)] ++ [V]; _ -> [V] end);
									_ -> array:set(El-1, case CAE(4, El, [], GraphDatas) of true -> array:get(El-1, element(4, hd(GraphDatas))); _ -> [] end, element(4, A)) end) end,  %undefined
									lists:foldl(fun (El, A) -> setelement(5, A, array:set(El-1, case CAE(5, El, [], GraphDatas) of true -> array:get(El-1, element(5, hd(GraphDatas))); _ -> [] end, element(5, A))) end,  %undefined
										getgraphpath(AccAST, Node), lists:seq(1, 16)), lists:seq(1, lists:min(lists:map(fun (El) -> array:size(element(4, El)) end, GraphDatas)))), lists:seq(1, 1024)) end
							end(hd(lists:dropwhile(fun (El) -> not isblockchild(AccAST, try_end, true, HeadNode, El) end, gb_sets:to_list(get_succs(HeadNode, NewGraph))))),
							%io:format("~p~n", [TryGraphData]),
							%setgraphpath(AccAST, hd(lists:nth(CurNode, NodesToAST)), setmemd(setmemd(setmemd(getgraphpath(AccAST, lists:last(lists:delete(2, lists:droplast(pathtodom(Idom, TryNode))))), {x,0}, getmemd(getgraphpath(AccAST, hd(lists:nth(CurNode, NodesToAST))), {x,0})), {x,1}, getmemd(getgraphpath(AccAST, hd(lists:nth(CurNode, NodesToAST))), {x,1})), {x,2}, getmemd(getgraphpath(AccAST, hd(lists:nth(CurNode, NodesToAST))), {x,2}))),
							NewCur = getgraphpath(AccAST, NewNode),
							FirstSet = setmemd(TryGraphData, {x,0}, getmemd(NewCur, {x,0})),
							setgraphpath(AccAST, NewNode, case lists:member(HeadNode, IsCatch) of true -> FirstSet; _ -> setmemd(setmemd(FirstSet, {x,1}, getmemd(NewCur, {x,1})), {x,2}, getmemd(NewCur, {x,2})) end)
							end, AST, IsTryCatch ++ IsCatch),
				%io:format("~p~n", [{IsCatch, lists:droplast(lists:last(lists:nth(NewNode, NodesToAST))), lists:nth(NewNode, Pred)}]),
				%IsCatch = case lists:last(lists:nth(NewNode, NodesToAST)) =/= [] andalso lists:prefix(lists:droplast(lists:last(lists:nth(NewNode, NodesToAST))) ++ [lists:last(lists:last(lists:nth(NewNode, NodesToAST))) - 1], lists:last(lists:nth(CurNode, NodesToAST))) of true ->
				%		case getgraphpath(AST, lists:droplast(lists:last(lists:nth(NewNode, NodesToAST))) ++ [lists:last(lists:last(lists:nth(NewNode, NodesToAST))) - 1]) of {match,_,_,[{'catch',_,_}]} -> true; _ -> false end; _ -> false end,
				%exit cases can mean there is no other link to this node besides from its catch header
				%catch needs to make sure it further filters all predecessors whose main path always exits
				%{CatchAST, CatchGraph, CatchAsgn} = lists:foldl(fun (El, {AccAST, AccGraph, AccAsgn}) ->
				%	case lists:dropwhile(fun (E) -> E =:= El orelse not gb_sets:is_element(El, fun PredRecurse(Pcsd, InX) -> Comb = gb_sets:union(Pcsd, InX), Y = gb_sets:from_list(gb_sets:fold(fun (InEl, Acc) -> case not gb_sets:is_element(InEl, Comb) of true -> [InEl|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (InEl, Acc) ->
			%[get_preds(InEl, Graph)|Acc] end, [], InX)))),
		%case gb_sets:size(Y) of 0 -> Comb; _ -> PredRecurse(Comb, Y) end end(gb_sets:new(), gb_sets:from_list([E]))) end, gb_sets:to_list(get_preds(NewNode, AccGraph))) of [A|_] ->
						%{AAST, AGraph, AAsgn, _, _, _, _, _} =
							%handle_merge_node(AccAST,
								%remove_edge(El, NewNode, AccGraph, AccAST, false),
								%A, NewNode,
								%AssignedVars + AccAsgn, VarPrefix, {element(1, Glob) + 1,
								%LabelToNode, element(2, element(3, Glob)),
								%hd(element(2, Glob))}, false, true, false, element(5, Glob)),
				%		{AccAST, remove_edge(El, NewNode, AccGraph, AccAST, false), AccAsgn}; _ -> {AccAST, AccGraph, AccAsgn} end end,
				%	{TryAST, NewGraph, 0}, IsCatch),
				{NewAST, FixGraph, NewAsgn, NextNode, Crs, CNodes, CEdges, CREdges} =
					handle_merge_node(TryAST, NewGraph,
					if Jumped orelse IsCatch =/= [] -> NewNode; true -> CurNode end,
					NewNode, AssignedVars, VarPrefix, {element(1, Glob) + 1,
						LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))},
					false, false, false, element(5, Glob)),
				#{0 := {C, CN, CE, CRE}} = Stats,
				%io:format("~p~n", [{Jumped, NewNode, CurNode, Graph, LabelToNode,
				%	FixPred, FixSucc, Cur, getgraphpath(AST, NewNode)}]),
				decompile_step({tl(InstList), NewAST, FixGraph,
					case isnodeloopback(AST, NewNode) of true -> NodeState;
					_ -> setnodevisited(if Jumped -> NodeState; true ->
						setnodevisited(NodeState, CurNode, 0) end, NewNode, 0) end,
					LabelToNode#{element(2, Val) - element(1, Glob) + 1 => case begin LblIdx = element(2, Val) - element(1, Glob) + 1, case LabelToNode of #{LblIdx := _} -> false; _ -> true end end of true -> CurNode; _ -> NewNode end},
					NextNode, VarPrefix, AssignedVars + NewAsgn,
					case lists:member(bfsscan, element(5, Glob)) andalso
						not isnodeloopback(AST, CurNode) andalso NewNode =/= CurNode andalso
						getnodevisited(NodeState, NewNode) =:= 0 of true -> true; _ -> false
					end, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob) end end;
				
				line ->
					decompile_step({tl(InstList),
						setgraphpath(AST, CurNode, setelement(2, Cur, element(2, Val))),
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
						false, Stats}, Glob);
				func_info ->
					decompile_step({tl(InstList), AST, Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				fcheckerror ->
					decompile_step({tl(InstList), AST, Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				test_heap ->
					decompile_step({tl(InstList), AST, Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				badmatch -> {NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
					handle_exit_merge(insertgraphnode(AST, CurNode,
					{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{tuple,0,[{atom, 0, badmatch}, getmemd(Cur, element(2, Val))]}]}, 0),
					Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				case_end -> {NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
					handle_exit_merge(insertgraphnode(AST, CurNode,
					{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{tuple,0,[{atom, 0, case_clause}, getmemd(Cur, element(2, Val))]}]}, 0),
					Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				%could be many to one where many catches to one label, catch_end has a theoretical many to many relationship
				'catch' -> NewNode = next_node(Graph), LblIdx = element(2, element(3, Val)) - element(1, Glob) + 1, NotExists = case LabelToNode of #{LblIdx := _} -> false; _ -> true end,
					InitAST = if NotExists -> insertgraphnode(AST,
						CurNode, {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},[{'catch', 0, []}]}, setmemd(setmemd({graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), element(2, Val), [CurNode]), NewNode); true ->
						insertgraphnode(AST,
						CurNode, {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},[{'catch', 0, []}]}, 0) end,
					ModAST = insertgraphnodechild(InitAST,
						CurNode, 'catch', true, {graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, NewNode + if NotExists -> 1; true -> 0 end),
					InitGraph = add_edge(CurNode, NewNode + if NotExists -> 1; true -> 0 end, add_edge(CurNode, if NotExists -> NewNode; true -> begin #{LblIdx := LblNode} = LabelToNode, LblNode end end, Graph, ModAST, false), ModAST, false),
					{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(ModAST,
						InitGraph, NewNode+if NotExists -> 1; true -> 0 end, NewNode+if NotExists -> 1; true -> 0 end, AssignedVars+1, VarPrefix,
						{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
							hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), FxAST, FxGraph,
						if NotExists -> setnodevisited(NodeState, NewNode, 2); true -> NodeState end,
						if NotExists -> LabelToNode#{LblIdx => NewNode}; true -> LabelToNode end, NewNode + if NotExists -> 1; true -> 0 end, VarPrefix, AssignedVars+1+FxAsgn,
						false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				catch_end -> %only for stack clean up, the label is where the error handling part of the catch has occurred
					decompile_step({tl(InstList), setgraphpath(AST, CurNode, setmemd(Cur, element(2, Val), [])), Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				'try' -> NewNode = next_node(Graph), %this state preserved until try_end or try_case
					LblIdx = element(2, element(3, Val)) - element(1, Glob) + 1, NotExists = case LabelToNode of #{LblIdx := _} -> false; _ -> true end,
					InitAST = insertgraphnode(AST, %[4, 1, 4, 1, 5, 1] added but not referenced and either cleaned up or referenced later
						CurNode, {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},
							[{'try', 0, [], [{clause,0,[{var,0,list_to_atom(VarPrefix ++ "TryVar" ++ integer_to_list(AssignedVars))}],[],
								[setmemd({graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, {x,0}, {var,0,list_to_atom(VarPrefix ++ "TryVar" ++ integer_to_list(AssignedVars))})]}],
								[{clause,0,[{tuple,0,[{var,0,list_to_atom(VarPrefix ++ "Class" ++ integer_to_list(AssignedVars))},{var,0,list_to_atom(VarPrefix ++ "Reason" ++ integer_to_list(AssignedVars))},{var,0,'_'}]}],[],
									[{match,0,{var,0,list_to_atom(VarPrefix ++ "Stacktrace" ++ integer_to_list(AssignedVars))},{call,0,{remote,0,{atom,0,erlang},{atom,0,get_stacktrace}},[]}}]}], []}]},
							setmemd({graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), NewNode),
					ModAST = insertgraphnodechild(insertgraphnodechild(InitAST,
						CurNode, 'try', true, setmemd({graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, element(2, Val), [CurNode]), NewNode + 1),
						CurNode, 'try', false, if NotExists -> setmemd(setmemd(setmemd({graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, {x,0}, {var,0,list_to_atom(VarPrefix ++ "Class" ++ integer_to_list(AssignedVars))}), {x,1}, {var,0,list_to_atom(VarPrefix ++ "Reason" ++ integer_to_list(AssignedVars))}), {x,2}, {var,0,list_to_atom(VarPrefix ++ "Stacktrace" ++ integer_to_list(AssignedVars))});
							true -> getgraphpath(AST, begin #{LblIdx := LblNode} = LabelToNode, LblNode end) end, NewNode + 2),
					%io:format("~p~n", [{[[getnextsibling(CurNodePath) ++ [3, 1]], [getnextsibling(CurNodePath) ++ [5, 1, 5, 2]]]}]),
					InitGraph = add_edge(NewNode, 3,
							add_edge(CurNode, NewNode + 2,
								add_edge(CurNode, NewNode + 1,
									add_edge(CurNode, NewNode, Graph, ModAST, false),
								ModAST, false), ModAST, false), ModAST, false), %add_edge_exit(CurNode, NewNode, Graph, ModAST),
					{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(ModAST,
						if NotExists -> InitGraph; true -> add_edge(NewNode + 2, begin #{LblIdx := LblNde} = LabelToNode, LblNde end, InitGraph, ModAST, false) end, NewNode+1, NewNode+1, AssignedVars+1, VarPrefix,
						{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
							hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), FxAST, FxGraph,
						if NotExists -> setnodevisited(NodeState, NewNode + 2, 2); true -> NodeState end,
						if NotExists -> LabelToNode#{LblIdx => NewNode + 2}; true -> LabelToNode end, NewNode + 1, VarPrefix, AssignedVars+1+FxAsgn,
						false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				%{x,0} merges here and node advance, must be explicitly done despite no label occurring
				try_end -> %all changed values must be assigned variables, and moved to the merge node outside of try block, it must be assumed to be assigned even if an unbound error could occur
					%this may be already handled in try_case or default value case, where try_end can occur after the catch already merges, a small compiler optimization sort of trick
					%HeadNode = fun PredRecurse(Pcsd, X) -> Comb = Pcsd ++ X, Y = lists:usort(lists:append(lists:map(fun (El) -> lists:nth(El, Pred) end, X))) -- Comb,
						%Match = lists:dropwhile(fun(El) -> case lists:prefix(lists:droplast(lists:last(lists:nth(El, NodesToAST))), lists:last(lists:nth(CurNode, NodesToAST))) of
							%true -> case getgraphpath(AST, getnextsibling(lists:last(lists:nth(El, NodesToAST)))) of {match,_,_,[{'try', _, _, _, _, _}]} -> false; _ -> true end; _ -> true end end, Y),
						%if Match =/= [] orelse Y =:= [] -> hd(Match); true -> PredRecurse(Comb, Y) end end([], [CurNode]),
					%must use the state to find the correct block as its possibly undecidable by structure alone without assumptions which are very difficult to implement for all cases
					%there can be cross edges between separate try headers to the try_end as a compiler optimization
					%can stop traversal of {unresolved, {y, _}} values
					HeadNodes = fun PredRecurse(Accept, Pcsd, X) -> {XAcc, XFilt} = lists:partition(fun (El) -> case getmemd(getgraphpathfirst(AST, El), element(2, Val)) of [_A|[]] -> true; _ -> false end end, gb_sets:to_list(X)),
						Comb = gb_sets:union(Pcsd, X), Y = gb_sets:from_list(gb_sets:fold(fun (El, Acc) -> case not gb_sets:is_element(El, Comb) of true -> [El|Acc]; _ -> Acc end end, [], gb_sets:union(gb_sets:fold(fun (El, Acc) -> [get_preds(El, Graph)|Acc] end, [], gb_sets:from_list(XFilt))))),
							case gb_sets:size(Y) of 0 -> gb_sets:union(Accept, gb_sets:from_list(XAcc)); _ -> PredRecurse(gb_sets:union(Accept, gb_sets:from_list(XAcc)), Comb, Y) end end(gb_sets:new(), gb_sets:new(), gb_sets:from_list([CurNode])),
					%if a nested try catch with a single path led to here, then must merge out to correct context or ambiguous variable assignments occur
					%must take the try graphdata in case a try nested within has updated the in its try block before merging
					%however, it is hardly incorrect as the termination of the try block is the termination of a whole try structure so although it looks inconsistent and ridiculous, it could be left to cleanup
					%MergeNode = hd(lists:dropwhile(fun (El) -> length(hd(lists:nth(El, NodesToAST))) =/= length(lists:last(lists:nth(HeadNode, NodesToAST))) end, lists:nth(HeadNode, Succ))),
					%MergeNodePath = hd(lists:nth(MergeNode, NodesToAST)),
					%variable assignment must occur as despite side effect code having been assigned, errors may occur so that an unbound exception should occur, not a replaced value
					%just reuse code by faking a graph with only 2 nodes where the merge node is dominated and preceded by the end of the try block
					%all exit nodes are technically jumps to the catch block, yet the variable assignments are lost
					%MergePred = setnth(MergeNode, lists:duplicate(length(Pred),[]), [CurNode]),
					%FixDom = setnth(MergeNode, lists:duplicate(length(Pred),[]), CurNode),
					%try state must be passed down to merge node as although only at the safe part can the state really cross the boundary except in the eval module, it would only be safe for the code at the merge to use the safe and pure variables the rest
					%{XVars, {{XModAST, XNodesToAST}, _, XAsgn}} = assign_vars(AST, NodesToAST, MergePred, FixDom, MergeNode, AssignedVars, 3, VarPrefix),
					%{YVars, {{YModAST, YNodesToAST}, _, YAsgn}} = assign_vars(XModAST, XNodesToAST, MergePred, FixDom, MergeNode, AssignedVars + XAsgn, 4, VarPrefix),
					%{FrVars, {{ModAST, ModNodesToAST}, _, FrAsgn}} = assign_vars(YModAST, YNodesToAST, MergePred, FixDom, MergeNode, AssignedVars + XAsgn + YAsgn, 5, VarPrefix),
					%TryNewAsgn = XAsgn + YAsgn + FrAsgn, Elem = setmemd({graphdata, 0, XVars, YVars, FrVars}, {x,0}, getmemd(getgraphpath(AST, MergeNodePath), {x,0})),
					%if the catch node reaches, then it has already merged, simply link the graphdata
					MainNode = hd(lists:dropwhile(fun (El) -> gb_sets:is_element(El, array:get(CurNode-1, element(8, Graph))) end, gb_sets:to_list(HeadNodes))),
					NewCur = setmemd(setmemd(getgraphpath(AST, MainNode), element(2, Val), []),
								{x,0}, getmemd(Cur, {x,0})), %Cur will have stale data from when try created - ideally use combination of recent values
					{FixAST, FixGraph, NewAsgn, CntNode, _} = lists:foldl(fun (PredNode, {AccAST, AccGraph, AccAsgn, AccNode, PriorHeadNodes}) ->
						HeadNode = hd(getmemd(getgraphpathfirst(AST, PredNode), element(2, Val))),
						case gb_sets:is_element(HeadNode, PriorHeadNodes) of true -> {AccAST, AccGraph, AccAsgn, AccNode, PriorHeadNodes};
						_ ->
							%HasCatch = lists:any(fun(El) -> isblockchild(AccAST, 'try', false, HeadNode, El) end, gb_sets:to_list(get_preds(CurNode, AccGraph))),
							%if HasCatch -> error(HasCatch); true -> true end,
							%TryCaseNode = if HasCatch -> hd(lists:dropwhile(fun(El) -> not isblockchild(AccAST, try_end, true, HeadNode, El) end, gb_sets:to_list(get_preds(CurNode, AccGraph)))); true -> CurNode end,
							NewNode = next_node(AccGraph),
							NewAST = insertgraphnodechild(setgraphpathchild(AccAST, 'try', true, HeadNode,
								setmemd(setelement(2, NewCur, element(2, getgraphpathchild(AccAST, 'try', true, HeadNode))),
											{x,0}, getmemd(getgraphpathchild(AccAST, 'try', true, HeadNode), {x,0}))), HeadNode, try_end, true, {}, NewNode),
							SubGraph = add_edge(if PredNode =:= MainNode -> CurNode; true -> PredNode end, NewNode, AccGraph, NewAST, false),
							NewGraph = if MainNode =:= PredNode -> SubGraph; true -> remove_edge(PredNode, CurNode, add_edge(NewNode, AccNode, SubGraph, NewAST, false), NewAST, false) end,
							%CatchGraph = if HasCatch -> add_edge(NewNode, CurNode, NewGraph, NewAST, false); true -> NewGraph end,
							%io:format("~p~n", [{CurNode, HeadNode, PredNode, NewNode, MainNode}]),
							%case check_nodes(NewAST) of true -> true; _ -> error("AST sanity check failed") end,
							%{NextAST, NextGraph, NextAsgn, _, _, _, _, _} =
								%handle_merge_node(NewAST, NewGraph, if PredNode =:= MainNode -> CurNode; true -> PredNode end, if PredNode =:= MainNode -> CurNode; true -> PredNode end,
									%AssignedVars + AccAsgn, VarPrefix, {element(1, Glob) + 1,
										%LabelToNode, element(2, element(3, Glob)),
										%hd(element(2, Glob))}, false, true, false, element(5, Glob)),
							{NewAST, NewGraph, AccAsgn, if MainNode =:= PredNode -> NewNode; true -> AccNode end, gb_sets:add_element(HeadNode, PriorHeadNodes)} end end,
						{setgraphpath(AST, CurNode, NewCur), Graph, 0, CurNode, gb_sets:new()}, [MainNode|gb_sets:to_list(gb_sets:del_element(MainNode, HeadNodes))]),
					{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(FixAST, FixGraph, CntNode, CntNode, AssignedVars + NewAsgn, VarPrefix,
						{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
							hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), FxAST, FxGraph, NodeState,
						LabelToNode, CntNode, VarPrefix, AssignedVars + NewAsgn + FxAsgn,
						false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				%try_case equivalent to catch_end, except no merge of throw and no throw paths
				try_case -> %only for stack clean up, the label is where the error handling part of the catch has occurred
					decompile_step({tl(InstList), setgraphpath(AST, CurNode, setmemd(Cur, element(2, Val), [])), Graph, NodeState, LabelToNode,
						CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
					% {x, 0} = Class, {x, 1} = Reason, {x, 2} = Stacktrace or equivalently Class:Reason and erlang:get_stacktrace()
				try_case_end -> {NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
					handle_exit_merge(insertgraphnode(AST, CurNode,
					{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{tuple,0,[{atom, 0, try_clause}, getmemd(Cur, element(2, Val))]}]}, 0),
					Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				raise -> %although erlang:raise is not semantically equivalent due to badarg errors, in a catch block with the original arguments, it is equivalent
					{NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
						handle_exit_merge(insertgraphnode(AST, CurNode,
					{call,0,{remote,0,{atom,0,erlang},{atom,0,raise}},[getmemd(Cur, element(4, Val)), getmemd(Cur, lists:nth(2, element(3, Val))), getmemd(Cur, lists:nth(1, element(3, Val)))]}, 0),
					Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				loop_rec -> NewNode = next_node(Graph), %no graphdata containing the loopback label element(2, element(2, Val))
					ModAST = insertgraphnode(insertgraphnodechild(insertgraphnode(AST,
						CurNode, {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},[{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), 'receive', 1, lists:member(stubfuncs, element(5, Glob)))]}},[{'fun',0,[{clauses,[{clause,0,[{var,0,list_to_atom(VarPrefix ++ "Message" ++ integer_to_list(AssignedVars))},{var,0,list_to_atom(VarPrefix ++ "RemoveMessage" ++ integer_to_list(AssignedVars))}],[],[]}]}]}]}]},
							{graphdata, 0, element(3, setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))})), element(4, Cur), element(5, Cur)}, NewNode),
						CurNode, 'receive', true, {graphdata, 0, element(3, setmemd(Cur, element(3, Val), {var,0,list_to_atom(VarPrefix ++ "Message" ++ integer_to_list(AssignedVars))})), element(4, Cur), element(5, Cur)}, NewNode + 1),
						{}, {}, NewNode + 2),
					{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(ModAST,
						add_edge(NewNode, 3,
							add_edge(CurNode, NewNode + 2,
								add_edge(CurNode, NewNode + 1,
									add_edge(CurNode, NewNode, Graph, ModAST, false),
								ModAST, false), ModAST, false), ModAST, false), NewNode + 1, NewNode + 1, AssignedVars+1, VarPrefix,
						{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
							hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), FxAST, FxGraph,%add_edge_exit(CurNode, NewNode, Graph, ModAST),
						NodeState,
						LabelToNode#{element(2, element(2, Val)) - element(1, Glob) + 1 => NewNode + 2}, NewNode + 1, VarPrefix,
						AssignedVars + 1 + FxAsgn, false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob); %record lambda from here to loop_rec_end as well as the node which post-dominates this and the after clause if there is one
				wait -> %io:format("~p~n", [{CurNode, Graph}]),
					{NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
						handle_exit_merge(AST,
						Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
						#{0 := {C, CN, CE, CRE}} = Stats,
						decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
							LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
							true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob); %no after clause
				wait_timeout -> %if a receive node exists, extend it from a 3 tuple to a 5 tuple and record lambda from here to node which post=dominates this and the loop_rec/loop_rec_end clause
					LblIdx = element(2, element(2, Val)) - element(1, Glob) + 1,
					#{LblIdx := RecvNode} = LabelToNode, %no graphdata because must already be visited as a loop back element(2, element(2, Val))
					NewNode = next_node(Graph), if CurNode =:= RecvNode ->
					ModAST = insertgraphnodechild(insertgraphnode(AST, CurNode, {'receive',0,[],getmemd(Cur, element(3, Val)),[]}, 0),
						CurNode, wait_timeout, true, {graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, NewNode),
					{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(ModAST,
						add_edge(CurNode, NewNode, Graph, ModAST, false), NewNode, NewNode, AssignedVars, VarPrefix,
						{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
							hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), FxAST, FxGraph,
						NodeState, LabelToNode, NewNode, VarPrefix, AssignedVars+FxAsgn,
						false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				true ->
					%RecvNodePath = lists:sublist(lists:last(lists:nth(CurNode - 1, NodesToAST)), length(lists:last(lists:nth(CurNode - 1, NodesToAST))) - 8), %lists:droplast(CurNodePath) ++ [lists:last(CurNodePath) - 2, 4, 1],
					%io:format("~p~n", [{CurNode, RecvNode, RecvNodePath, Graph}]),
					NewAST = insertgraphnodechild(setgraphpathchild(AST, timeout, true, RecvNode, {call,0,{'fun',0,{clauses,get_clean_ast_all(element(4, Glob), 'receive', 3, lists:member(stubfuncs, element(5, Glob)))}},[getgraphpathchild(AST, timeout, true, RecvNode), getmemd(getgraphpath(AST, RecvNode), element(3, Val)), {'fun',0,[{clauses,[{clause,0,[],[],[]}]}]}]}),
						RecvNode, 'receive', false, getgraphpath(AST, RecvNode), NewNode),
					decompile_step({tl(InstList), NewAST,
						add_edge(CurNode, 3,
							add_edge(RecvNode, NewNode, Graph, NewAST, false), NewAST, false),
						NodeState, LabelToNode, NewNode, VarPrefix, AssignedVars,
						false, Stats}, Glob)
				end;
				loop_rec_end -> %set special place holder nil value for lambda function to return false, an exit post dominator check should also occur
					%this is a workaround as technically the control flow does not jump or move here, but to prevent the label before wait/wait_timeout/timeout becoming a merge node which it is in a structurally unimportant way, could perhaps be changed to a different strategy if need be for special cases towards generality but without modified custom BEAM tricks it seems to work fine
					LblIdx = element(2, element(2, Val)) - element(1, Glob) + 1,
					{NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
						handle_exit_merge(setgraphpath(AST, CurNode, setmemd(Cur, {x,0}, [begin #{LblIdx := RecNode} = LabelToNode, RecNode end])), %store the node index of the head node to find this on merge
					Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)),
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				recv_mark -> decompile_step({tl(InstList), AST, Graph, NodeState,
					LabelToNode, CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				recv_set -> decompile_step({tl(InstList), AST, Graph, NodeState,
					LabelToNode, CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				
				select_val -> decompile_select({InstList, AST, Graph, NodeState, LabelToNode, CurNode,
					VarPrefix, AssignedVars, Jumped, Stats}, Glob, Val, Cur, false);
				select_tuple_arity -> decompile_select({InstList, AST, Graph, NodeState, LabelToNode, CurNode,
					VarPrefix, AssignedVars, Jumped, Stats}, Glob, Val, Cur, true);
				test -> LblIdx = element(2, element(3, Val)) - element(1, Glob) + 1, NotExists = element(2, element(3, Val)) < element(1, Glob) orelse case LabelToNode of #{LblIdx := _} -> false; _ -> true end,
					NextNode = next_node(Graph),
					NewCur = case element(2, Val) of
							bs_start_match2 -> setmemd(Cur, lists:nth(4, element(4, Val)), {tuple, 0, [getmemd(Cur, hd(element(4, Val))), getmemd(Cur, hd(element(4, Val)))]}); %{var,0,"A"},{var,0,"B"}]});%
							bs_skip_bits2 -> setmemd(Cur, hd(element(4, Val)), case lists:nth(2, element(4, Val)) of {atom, all} -> {bin,0,[]}; _ -> {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',getmemd(Cur, lists:nth(2, element(4, Val))),{integer,0,lists:nth(3, element(4, Val))}}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]} end);
							bs_skip_utf8 -> setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
								{op,0,'*',{integer,0,8},{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf8_size, 1, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]}}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]});
							bs_skip_utf16 -> setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
								{op,0,'*',{integer,0,8},{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf16_size, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]}}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]});
							bs_skip_utf32 -> setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {integer,0,4*8}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]});
							bs_get_integer2 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(6, element(4, Val)),
								{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_integer, 4, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))},
									case (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(5, element(4, Val))) band 2) =:= 2} end, {atom,0,(element(2, lists:nth(5, element(4, Val))) band 4) =:= 4}]});
							bs_get_float2 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(6, element(4, Val)),
								{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_float, 3, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))},
									case (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(5, element(4, Val))) band 2) =:= 2} end]});
							bs_get_utf8 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,8},{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf8_size, 1, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]}}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(4, element(4, Val)),
								{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf8, 1, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]});
							bs_get_utf16 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,8},{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf16_size, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
								case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]}}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(4, element(4, Val)),
									{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf16, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]});
							bs_get_utf32 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {integer,0,4*8}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(4, element(4, Val)),
								{'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_utf32, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]});
							bs_get_binary2 -> setmemd(setmemd(Cur, hd(element(4, Val)), {tuple, 0, [case lists:nth(3, element(4, Val)) of {atom, all} -> {bin,0,[]}; _ -> {call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',getmemd(Cur, lists:nth(3, element(4, Val))),{integer,0,lists:nth(4, element(4, Val))}}]} end, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]}), lists:nth(6, element(4, Val)),
								case lists:nth(3, element(4, Val)) of {atom, all} -> hd(element(3, getmemd(Cur, hd(element(4, Val))))); _ -> {call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',getmemd(Cur, lists:nth(3, element(4, Val))),{integer,0,lists:nth(4, element(4, Val))}}]} end);
							bs_match_string -> setmemd(Cur, hd(element(4, Val)), {tuple, 0, [{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), skip_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {integer,0,lists:nth(2, element(4, Val))}]}, lists:nth(2, element(3, getmemd(Cur, hd(element(4, Val)))))]});
							_ -> Cur end,
					NewAST = insertgraphnodechild(insertgraphnodechild(insertgraphnode(AST, CurNode,
					{'case',0,case element(2, Val) of
						is_lt -> {op,0,'<',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_ge -> {op,0,'>=',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_eq -> {op,0,'==',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_ne -> {op,0,'/=',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_eq_exact -> {op,0,'=:=',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_ne_exact -> {op,0,'=/=',getmemd(Cur, hd(element(4, Val))),getmemd(Cur, lists:nth(2, element(4, Val)))};
						is_integer -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_integer'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_float -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_float'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_number -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_number'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_atom -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_atom'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_pid -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_pid'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_reference -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_reference'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_port -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_port'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_nil -> {op,0,'=:=',getmemd(Cur, hd(element(4, Val))),{nil, 0}};
						is_boolean -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_boolean'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_binary -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_binary'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_bitstr -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_bitstring'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_list -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_list'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_nonempty_list -> {op, 0, 'andalso', {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_list'}},[getmemd(Cur, hd(element(4, Val)))]}, {op,0,'=/=',getmemd(Cur, hd(element(4, Val))),{nil, 0}}};
						is_tuple -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_function -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_function'}},[getmemd(Cur, hd(element(4, Val)))]};
						is_function2 -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_function'}},[getmemd(Cur, hd(element(4, Val))), getmemd(Cur, lists:nth(2, element(4, Val)))]};
						is_map -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_map'}},[getmemd(Cur, hd(element(4, Val)))]};
						has_map_fields -> {op, 0, 'andalso', {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_map'}},[getmemd(Cur, element(4, Val))]}, lists:foldl(fun(El, Acc) -> Next = {call,0,{remote,0,{atom,0,maps},{atom,0,is_key}}, [getmemd(Cur, El), getmemd(Cur, element(4, Val))]}, if Acc =:= [] -> Next; true -> {op, 0, 'andalso', Next, Acc} end end, [], getmemd(Cur, element(5, Val)))};
						is_tagged_tuple -> {op, 0, 'andalso', {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},[getmemd(Cur, hd(element(4, Val)))]}, {op, 0, 'andalso', {op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, hd(element(4, Val)))]}, {integer,0,lists:nth(2, element(4, Val))}}, {op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'element'}},[{integer,0,1}, getmemd(Cur, hd(element(4, Val)))]}, {atom,0,element(2, lists:nth(3, element(4, Val)))}}}};
						test_arity -> {op, 0, 'andalso', {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},[getmemd(Cur, hd(element(4, Val)))]}, {op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},[getmemd(Cur, hd(element(4, Val)))]}, {integer,0,lists:nth(2, element(4, Val))}}};
						%https://github.com/erlang/otp/blob/master/erts/emulator/beam/ops.tab
						%https://github.com/erlang/otp/blob/master/erts/emulator/beam/beam_load.c
						%https://github.com/erlang/otp/blob/master/erts/emulator/beam/bs_instrs.tab
						%https://github.com/erlang/otp/blob/master/erts/emulator/beam/erl_bits.c
						%SAFE_MUL's empirically do all size * unit multiplications for 64/32 bit integers by checking with division - here overflows are not possible however this is semantically equivalent due to maximum size of binary
						bs_test_unit -> {op,0,'=:=',{op,0,'rem',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{integer,0,lists:nth(2, element(4, Val))}},{integer,0,0}};
						bs_test_tail2 -> {op,0,'=:=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{integer,0,lists:nth(2, element(4, Val))}};
						bs_start_match2 -> case is_tuple(getmemd(Cur, hd(element(4, Val)))) of true -> {atom,0,true}; _ -> {call,0,{remote,0,{atom,0,erlang},{atom,0,'is_bitstring'}},[getmemd(Cur, hd(element(4, Val)))]} end;
						bs_skip_bits2 -> case lists:nth(2, element(4, Val)) of {atom, all} -> {op,0,'=:=',{op,0,'rem',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{integer,0,lists:nth(3, element(4, Val))}},{integer,0,0}};
							_ -> {op,0,'andalso',{op,0,'>=',getmemd(Cur, lists:nth(2, element(4, Val))),{integer,0,0}},{op,0,'>=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]}, {op,0,'*',getmemd(Cur, lists:nth(2, element(4, Val))),{integer,0,lists:nth(3, element(4, Val))}}}} end;
						bs_skip_utf8 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf8, 1, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]};
						bs_skip_utf16 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf16, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
							case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]};
						bs_skip_utf32 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf32, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
							case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]};
						bs_get_integer2 -> {op,0,'>=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))}};
						bs_get_float2 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_float, 3, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {op,0,'*',{integer,0,lists:nth(4, element(4, Val))},getmemd(Cur, lists:nth(3, element(4, Val)))},
							case (element(2, lists:nth(5, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(5, element(4, Val))) band 2) =:= 2} end]};
						bs_get_utf8 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf8, 1, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]};
						bs_get_utf16 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf16, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
							case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]};
						bs_get_utf32 -> {'call',0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), has_utf32, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))),
							case (element(2, lists:nth(3, element(4, Val))) band 16) =:= 16 of true -> {op,0,'=:=',{atom,0,little},{call,0,{remote,0,{atom,0,erlang},{atom,0,system_info}}, [{atom,0,endian}]}}; _ -> {atom,0,(element(2, lists:nth(3, element(4, Val))) band 2) =:= 2} end]};
						bs_get_binary2 -> case lists:nth(3, element(4, Val)) of {atom, all} -> {op,0,'=:=',{op,0,'rem',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{integer,0,lists:nth(4, element(4, Val))}},{integer,0,0}};
							_ -> {op,0,'andalso',{op,0,'>=',getmemd(Cur, lists:nth(3, element(4, Val))),{integer,0,0}},{op,0,'>=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]}, {op,0,'*',getmemd(Cur, lists:nth(3, element(4, Val))),{integer,0,lists:nth(4, element(4, Val))}}}} end;
						bs_match_string -> {op,0,'andalso',{op,0,'>=',{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},[hd(element(3, getmemd(Cur, hd(element(4, Val)))))]},{integer,0,lists:nth(2, element(4, Val))}}, {op,0,'=:=',{call,0,{'fun',0,{clauses,[get_clean_ast(element(4, Glob), get_bits, 2, lists:member(stubfuncs, element(5, Glob)))]}},[hd(element(3, getmemd(Cur, hd(element(4, Val))))), {integer,0,lists:nth(2, element(4, Val))}]},getliteral(lists:nth(3, element(4, Val)))}}
						end,[{clause,0,[{atom,0,true}],[],[]},{clause,0,[{atom,0,false}],[], if element(2, element(3, Val)) < element(1, Glob) -> [{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},[{atom, 0, function_clause}]}]; true -> [] end}]}, 0),
							CurNode, test, true, {graphdata, 0, element(3, NewCur), element(4, NewCur), element(5, NewCur)}, NextNode),
							CurNode, test, false, {graphdata, 0, element(3, Cur), element(4, Cur), element(5, Cur)}, NextNode + 1), %should pass all function arguments as a list to second parameter of error function
					case NotExists of true -> NewGraph = add_edge(CurNode, NextNode + 1, add_edge(CurNode, NextNode, Graph, NewAST, false), NewAST, false),
						%add_edge_exit(CurNode, NextNode + 1, NewGraph, NewAST)
						{ModAST, ModGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} = if element(2, element(3, Val)) < element(1, Glob) ->
							handle_exit_merge(NewAST, NewGraph, NodeState, NextNode + 1, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob)); true -> {NewAST, NewGraph, 0, 0, 0, 0, 0} end,
						{FxAST, FxGraph, FxAsgn, _, NCrs, NCNodes, NCEdges, NCREdges} = handle_merge_node(ModAST, ModGraph, NextNode, NextNode, AssignedVars+NewAsgn, VarPrefix,
							{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
								hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
						#{0 := {C, CN, CE, CRE}} = Stats,
						decompile_step({tl(InstList), FxAST,
							FxGraph,
							%insert_renumber(NodesToAST, getnextsibling(CurNodePath)) ++ [[getnextsibling(CurNodePath) ++ [4, 1, 5, 1]], [getnextsibling(CurNodePath) ++ [4, 2, 5, 1]]],
							if element(2, element(3, Val)) < element(1, Glob) -> NodeState; true -> setnodevisited(NodeState, NextNode + 1, 2) end, if element(2, element(3, Val)) < element(1, Glob) -> LabelToNode; true -> LabelToNode#{LblIdx => NextNode + 1} end,
							NextNode, VarPrefix, AssignedVars + NewAsgn+FxAsgn, false, Stats#{0 := {C + Crs + NCrs, CN + CNodes + NCNodes, CE + CEdges + NCEdges, CRE + CREdges + NCREdges}}}, Glob);
					_ -> #{LblIdx := Node} = LabelToNode,
						{FxAST, FxGraph, FxAsgn, _, Crs, CNodes, CEdges, CREdges} = handle_merge_node(NewAST,
							add_edge(NextNode + 1, Node, add_edge(CurNode, NextNode + 1, add_edge(CurNode, NextNode, Graph, NewAST, false), NewAST, false), NewAST, false), NextNode, NextNode, AssignedVars, VarPrefix,
							{element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)),
								hd(element(2, Glob))}, false, false, false, element(5, Glob)), %implicit merge to resolve cross edges above!
						#{0 := {C, CN, CE, CRE}} = Stats,
						decompile_step({tl(InstList), FxAST, FxGraph,
							%insert_renumber(NodesToAST, getnextsibling(CurNodePath)) ++ [[getnextsibling(CurNodePath) ++ [4, 1, 5, 1]], [getnextsibling(CurNodePath) ++ [4, 2, 5, 1]]],
							NodeState, LabelToNode, NextNode, VarPrefix, AssignedVars+FxAsgn, false, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob)
					end;
				move -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(3, Val),
						getmemd(Cur, element(2, Val)))), Graph, NodeState, LabelToNode,
					CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				fmove -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(3, Val),
						getmemd(Cur, element(2, Val)))), Graph, NodeState, LabelToNode,
					CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				fconv -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(3, Val),
						getmemd(Cur, element(2, Val)))), Graph, NodeState, LabelToNode,
					CurNode, VarPrefix, AssignedVars, false, Stats}, Glob);
				get_tuple_element -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(4, Val),
					{call,0,{remote,0,{atom,0,erlang},{atom,0,element}},
						[{integer, 0, element(3, Val) + 1},
							getmemd(Cur, element(2, Val))]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				set_tuple_element -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(3, Val),
					{call,0,{remote,0,{atom,0,erlang},{atom,0,setelement}},
						[{integer, 0, element(4, Val) + 1}, getmemd(Cur, element(3, Val)),
							getmemd(Cur, element(2, Val))]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				put_tuple -> decompile_step({
					lists:sublist(InstList, 2 + element(2, Val), length(InstList)),
					setgraphpath(AST, CurNode, setmemd(Cur, element(3, Val),
						{tuple, 0, get_tuple_putsd(Cur, {tl(InstList)}, element(2, Val),
							lists:member(progress, element(5, Glob)))})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				get_list -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(setmemd(Cur, element(3, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,hd}},
							[getmemd(Cur, element(2, Val))]}), element(4, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,tl}},
							[getmemd(Cur, element(2, Val))]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				put_list -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {cons, 0, getmemd(Cur, element(2, Val)), 
						getmemd(Cur, element(3, Val))})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_init2 -> {BinList, InstCount} = get_binary_putsd(Cur, {tl(InstList)},
					if is_tuple(element(3, Val)) ->
						get_binary_sizes({op,0,'*',{integer,0,8},
							getmemd(Cur, element(3, Val))});
					true -> [element(3, Val) * 8] end, 0, [],
					lists:member(progress, element(5, Glob))),
					decompile_step({
						lists:sublist(InstList, 2 + InstCount, length(InstList)),
						setgraphpath(AST, CurNode,
							setmemd(Cur, element(7, Val), {bin, 0, BinList})),
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
						false, Stats}, Glob);
				bs_init_bits -> {BinList, InstCount} =
					get_binary_putsd(Cur, {tl(InstList)}, if is_tuple(element(3, Val)) ->
						get_binary_sizes(getmemd(Cur, element(3, Val)));
						true -> [element(3, Val)] end, 0, [],
						lists:member(progress, element(5, Glob))),
					decompile_step({
						lists:sublist(InstList, 2 + InstCount, length(InstList)),
						setgraphpath(AST, CurNode,
							setmemd(Cur, element(7, Val), {bin, 0, BinList})),
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
						false, Stats}, Glob);
				bs_append -> {BinList, InstCount} =
					case get_binary_sizes(getmemd(Cur, element(3, Val))) of [0] ->
						{[], 0}; _ -> get_binary_putsd(Cur, {tl(InstList)},
							get_binary_sizes(getmemd(Cur, element(3, Val))), 0, [],
							lists:member(progress, element(5, Glob))) end,
					decompile_step({
						lists:sublist(InstList, 2 + InstCount, length(InstList)),
						setgraphpath(AST, CurNode, setmemd(Cur, element(9, Val),
							{bin, 0, [{bin_element,0,getmemd(Cur, element(7, Val)),
								default,[binary]}|BinList]})),
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
						false, Stats}, Glob);
				bs_private_append -> {BinList, InstCount} =
					case get_binary_sizes(getmemd(Cur, element(3, Val))) of [0] ->
						{[], 0}; _ -> get_binary_putsd(Cur, {tl(InstList)},
							get_binary_sizes(getmemd(Cur, element(3, Val))), 0, [],
							lists:member(progress, element(5, Glob))) end,
					decompile_step({
						lists:sublist(InstList, 2 + InstCount, length(InstList)),
						setgraphpath(AST, CurNode, setmemd(Cur, element(7, Val),
							{bin, 0, [{bin_element,0,getmemd(Cur, element(5, Val)),
								default,[binary]}|BinList]})),
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
						false, Stats}, Glob);
				bs_add -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {op,0,'+',getmemd(Cur, hd(element(3, Val))), {op,0,'*',getmemd(Cur, lists:nth(2, element(3, Val))), {integer, 0, lists:nth(3, element(3, Val))}}})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_utf8_size -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {'if',0,[{clause,0,[],[[{op,0,'<',getmemd(Cur, element(3, Val)),{integer,0,128}}]],[{integer,0,1}]},{clause,0,[],[[{op,0,'<',getmemd(Cur, element(3, Val)),{integer,0,2048}}]],[{integer,0,2}]},{clause,0,[],[[{op,0,'<',getmemd(Cur, element(3, Val)),{integer,0,65536}}]],[{integer,0,3}]},{clause,0,[],[[{atom,0,true}]],[{integer,0,4}]}]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_utf16_size -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {'if',0,[{clause,0,[],[[{op,0,'>=',getmemd(Cur, element(3, Val)),{integer,0,65536}}]],[{integer,0,4}]},{clause,0,[],[[{atom,0,true}]],[{integer,0,2}]}]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_save2 -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(2, Val), {tuple, 0, [hd(element(3, getmemd(Cur, element(2, Val)))), hd(element(3, getmemd(Cur, element(2, Val))))]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_restore2 -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(2, Val), {tuple, 0, [lists:nth(2, element(3, getmemd(Cur, element(2, Val)))), lists:nth(2, element(3, getmemd(Cur, element(2, Val))))]})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				bs_context_to_binary -> decompile_step({tl(InstList), case getmemd(Cur, element(2, Val)) of {tuple,_,[_,_]} -> setgraphpath(AST, CurNode,
					setmemd(Cur, element(2, Val), lists:nth(2, element(3, getmemd(Cur, element(2, Val)))))); _ -> AST end,
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				get_map_elements -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmemd(Cur, El)]}; true -> {setmemd(Acc, El, {call,0,{remote,0,{atom,0,maps},{atom,0,get}},[hd(Next),getmemd(Cur, element(3, Val))]}), []} end end, {Cur, []}, getmemd(Cur, element(4, Val))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				put_map_exact -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {map,0,getmemd(Cur, element(3, Val)),element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmemd(Cur, El)]}; true -> {[{map_field_exact,0,hd(Next),getmemd(Cur, El)}|Acc], []} end end, {[], []}, getmemd(Cur, element(6, Val))))})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				put_map_assoc -> decompile_step({tl(InstList), setgraphpath(AST, CurNode,
					setmemd(Cur, element(4, Val), {map,0,getmemd(Cur, element(3, Val)),element(1, lists:foldl(fun(El, {Acc, Next}) -> if Next =:= [] -> {Acc, [getmemd(Cur, El)]}; true -> {[{map_field_assoc,0,hd(Next),getmemd(Cur, El)}|Acc], []} end end, {[], []}, getmemd(Cur, element(6, Val))))})),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				
				arithfbif -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, case element(2, Val) of
					fadd -> setmemd(Cur, element(5, Val),
						{op,0,'+',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					fsub -> setmemd(Cur, element(5, Val),
						{op,0,'-',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					fmul -> setmemd(Cur, element(5, Val),
						{op,0,'*',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					fdiv -> setmemd(Cur, element(5, Val),
						{op,0,'/',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					fnegate -> setmemd(Cur, element(5, Val),
						{op,0,'-',getmemd(Cur, hd(element(4, Val)))})
				end), Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
				false, Stats}, Glob);
				%lib/stdlib/src/erl_internal.erl: bif(Func, Arity)
				bif -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, case element(2, Val) of
					'==' -> setmemd(Cur, element(5, Val),
						{op,0,'==',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'<' -> setmemd(Cur, element(5, Val),
						{op,0,'<',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'=<' -> setmemd(Cur, element(5, Val),
						{op,0,'=<',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'>' -> setmemd(Cur, element(5, Val),
						{op,0,'>',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'>=' -> setmemd(Cur, element(5, Val),
						{op,0,'>=',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'=:=' -> setmemd(Cur, element(5, Val),
						{op,0,'=:=',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'/=' -> setmemd(Cur, element(5, Val),
						{op,0,'/=',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'=/=' -> setmemd(Cur, element(5, Val),
						{op,0,'=/=',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'not' -> setmemd(Cur, element(5, Val),
						{op,0,'not',getmemd(Cur, hd(element(4, Val)))});
					'and' -> setmemd(Cur, element(5, Val),
						{op,0,'and',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'or' -> setmemd(Cur, element(5, Val),
						{op,0,'or',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'xor' -> setmemd(Cur, element(5, Val),
						{op,0,'xor',getmemd(Cur, hd(element(4, Val))),
						getmemd(Cur, lists:nth(2, element(4, Val)))});
					'is_integer' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_integer'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_float' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_float'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_number' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_number'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_pid' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_pid'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_reference' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_reference'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_port' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_port'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_boolean' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_boolean'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_binary' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_binary'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_bitstring' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_bitstring'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_list' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_list'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_atom' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_atom'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_tuple' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_tuple'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_function' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_function'}},
							[getmemd(Cur, hd(element(4, Val)))|
								if length(element(4, Val)) =:= 2 ->
									[getmemd(Cur, lists:nth(2, element(4, Val)))]; true -> [] end]
						});
					'is_map' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_map'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					'is_record' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'is_record'}},
							[getmemd(Cur, hd(element(4, Val))),
								getmemd(Cur, lists:nth(2, element(4, Val)))|
								if length(element(4, Val)) =:= 3 ->
									[getmemd(Cur, lists:nth(3, element(4, Val)))]; true -> [] end]
						});
					'get' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'get'}},
						[getmemd(Cur, hd(element(4, Val)))]});
					'node' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'node'}},[]});
					'tuple_size' -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'tuple_size'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					element -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'element'}},
							[getmemd(Cur, hd(element(4, Val))),
								getmemd(Cur, lists:nth(2, element(4, Val)))]});
					hd -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'hd'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					tl -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'tl'}},
							[getmemd(Cur, hd(element(4, Val)))]});
					self -> setmemd(Cur, element(5, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'self'}},[]})
				end), Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
				false, Stats}, Glob);
				gc_bif -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, case element(2, Val) of
					'+' -> setmemd(Cur, element(6, Val),
						if (length(element(5, Val)) =:= 1) ->
							getmemd(Cur, hd(element(5, Val)));
						true -> {op,0,'+',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))} end);
					'-' -> setmemd(Cur, element(6, Val),
						if (length(element(5, Val)) =:= 1) ->
							{op,0,'-',getmemd(Cur, hd(element(5, Val)))};
						true -> {op,0,'-',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))} end);
					'*' -> setmemd(Cur, element(6, Val),
						{op,0,'*',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'/' -> setmemd(Cur, element(6, Val),
						{op,0,'/',getmemd(Cur, hd(element(5, Val))),
						getmemd(Cur, lists:nth(2, element(5, Val)))});
					length -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom, 0, length}},
							[getmemd(Cur, hd(element(5, Val)))]});
					'size' -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'size'}},
							[getmemd(Cur, hd(element(5, Val)))]});
					'map_size' -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'map_size'}},
							[getmemd(Cur, hd(element(5, Val)))]});
					'bit_size' -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'bit_size'}},
							[getmemd(Cur, hd(element(5, Val)))]});
					'byte_size' -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,'byte_size'}},
							[getmemd(Cur, hd(element(5, Val)))]});
					abs -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,abs}},
							[getmemd(Cur, hd(element(5, Val)))]});
					trunc -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,trunc}},
							[getmemd(Cur, hd(element(5, Val)))]});
					round -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,round}},
							[getmemd(Cur, hd(element(5, Val)))]});
					float -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,float}},
							[getmemd(Cur, hd(element(5, Val)))]});
					binary_part -> setmemd(Cur, element(6, Val),
						{call,0,{remote,0,{atom,0,erlang},{atom,0,binary_part}},
							[getmemd(Cur, hd(element(5, Val))),
								getmemd(Cur, lists:nth(2, element(5, Val)))] ++
							if length(element(5, Val)) =:= 3 ->
								[getmemd(Cur, lists:nth(3, element(5, Val)))]; true -> [] end});
					'div' -> setmemd(Cur, element(6, Val),
						{op,0,'div',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'rem' -> setmemd(Cur, element(6, Val),
						{op,0,'rem',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'band' -> setmemd(Cur, element(6, Val),
						{op,0,'band',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'bor' -> setmemd(Cur, element(6, Val),
						{op,0,'bor',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'bxor' -> setmemd(Cur, element(6, Val),
						{op,0,'bxor',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'bsl' -> setmemd(Cur, element(6, Val),
						{op,0,'bsl',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'bsr' -> setmemd(Cur, element(6, Val),
						{op,0,'bsr',getmemd(Cur, hd(element(5, Val))),
							getmemd(Cur, lists:nth(2, element(5, Val)))});
					'bnot' -> setmemd(Cur, element(6, Val),
						{op,0,'bnot',getmemd(Cur, hd(element(5, Val)))})
				end), Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
				false, Stats}, Glob);

				init -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setmemd(Cur, element(2, Val), [])),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				trim -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:sublist(array:to_list(element(4, Cur)),
							element(2, Val) + 1, array:size(element(4, Cur)))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				allocate_zero -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:duplicate(element(2, Val), []) ++
							array:to_list(element(4, Cur))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				allocate_heap -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:duplicate(element(2, Val), []) ++ %{unresolved, {y, Y}}
							array:to_list(element(4, Cur))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				allocate_heap_zero -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:duplicate(element(2, Val), []) ++
							array:to_list(element(4, Cur))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				allocate -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:duplicate(element(2, Val), []) ++ %{unresolved, {y, Y}}
							array:to_list(element(4, Cur))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);
				deallocate -> decompile_step({tl(InstList),
					setgraphpath(AST, CurNode, setelement(4, Cur,
						array:from_list(lists:sublist(array:to_list(element(4, Cur)),
							element(2, Val) + 1, array:size(element(4, Cur)))))),
					Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
					false, Stats}, Glob);

				jump -> LblIdx = element(2, element(2, Val)) - element(1, Glob) + 1, 
					IsExit = element(2, element(2, Val)) < element(1, Glob), case
					IsExit orelse case LabelToNode of #{LblIdx := _} -> false; _ -> true end of true ->
						NextNode = next_node(Graph),
						{ModAST, ModGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} = if IsExit ->
							handle_exit_merge(insertgraphnode(AST, CurNode,
								{call,0,{remote,0,{atom,0,erlang},{atom,0,error}},
									[{atom, 0, function_clause}]}, 0),
								Graph, NodeState, CurNode,
									AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode,
										element(2, element(3, Glob)), hd(element(2, Glob))},
									element(5, Glob));
							true -> NextAST = insertgraphnode(AST, CurNode,
								{graphdata, 0, element(3, Cur), element(4, Cur),
									element(5, Cur)}, NextNode), {NextAST,
								add_edge(CurNode, NextNode, Graph, NextAST, false), 0, 0, 0, 0, 0}
							end,
						#{0 := {C, CN, CE, CRE}} = Stats,
						decompile_step({tl(InstList), ModAST, ModGraph,
							if IsExit -> NodeState; true ->
								setnodevisited(NodeState, NextNode, 2) end,
							if IsExit -> LabelToNode; true ->
								LabelToNode#{element(2, element(2, Val)) - element(1, Glob) + 1 => NextNode} end, CurNode, VarPrefix,
							AssignedVars + NewAsgn, true, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
					_ -> #{LblIdx := Node} = LabelToNode,
						decompile_step({tl(InstList), AST, 
							add_edge(CurNode, Node, Graph, AST, false),
							NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars,
							true, Stats}, Glob)
				end;
				%side effect function merges forward iff the result is referenced only
				%  once, no other side effects between it and its usage
				%easier to always assign variable with AST matching expression,
				%  add new graphdata node, set result to variable
				
				%lib/compilter/src/erl_bifs.erl: is_exit_bif(Module, Func, Arity)
				%erlang:exit/1, erlang:throw/1, erlang:error/1, erlang:error/2 should be
				%  specially handled for control flow transfer to nearest
				%  try/catch or catch handler or end of function with no return value
				
				%side-effect free calls:
				apply -> ModAST = insertgraphnode(AST, CurNode,
					{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++
						integer_to_list(AssignedVars))},
						{call,0,{remote,0,{atom,0,erlang},{atom,0,apply}},
							[getmemd(Cur, {x, element(2, Val)}),
								getmemd(Cur, {x, element(2, Val) + 1}),
								lists:foldr(fun (El, Acc) -> {cons,0,getmemd(Cur, {x, El}), Acc}
									end, {nil, 0}, lists:seq(0, element(2, Val) - 1))]}},
					setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++
						integer_to_list(AssignedVars))}), CurNode),
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars + 1,
						false, Stats}, Glob);
				apply_last -> ModAST = insertgraphnode(AST, CurNode,
					{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++
						integer_to_list(AssignedVars))},
						{call,0,{remote,0,{atom,0,erlang},{atom,0,apply}},
							[getmemd(Cur, {x, element(2, Val)}),
								getmemd(Cur, {x, element(2, Val) + 1}),
								lists:foldr(fun (El, Acc) -> {cons,0,getmemd(Cur, {x, El}), Acc}
									end, {nil, 0}, lists:seq(0, element(2, Val) - 1))]}},
					setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++
						integer_to_list(AssignedVars))}), CurNode),
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars + 1,
						true, Stats}, Glob);
				call -> MakeNamedFun = not lists:member({element(2, element(3, Val)),
					element(3, element(3, Val))}, element(2, Glob)) andalso
					re:run(atom_to_list(element(2, element(3, Val))),
						".*-(?:.*|(?:lc|lbc|after)\\$\\^\\d*?)\/\\d*?-\\d*?-", [unicode,ucp]) =/=
						nomatch, %-FUNCNAME/ARITY-[lc/lbc/after]$^InnerNum/Arity-Num-
					FunNum = case lists:member({element(2, element(3, Val)), element(3, element(3, Val))}, element(2, Glob)) andalso
						re:run(atom_to_list(element(2, element(3, Val))),
							"-.*(?:\\$\\^\\d*?)?\/\\d*?-\\d*?-", [unicode,ucp]) =/= nomatch orelse
						MakeNamedFun of true -> string:split(lists:nth(2, string:split(atom_to_list(element(2, element(3, Val))), "\/")), "-", all); _ -> [] end,
					SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val))), %hd(atom_to_list(element(2, element(3, Val)))) =:= 45,
					{FunAST, CStats} = if MakeNamedFun -> {DecAST, InStats, _} = dodecompileast(element(3, Glob), element(2, element(3, Val)), element(3, element(3, Val)), case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) ++ "_" ++ VarPrefix end, [], element(4, Glob), element(2, Glob), element(5, Glob)),
					{{named_fun,0,case hd(lists:nth(2, FunNum)) of Nme when Nme >= $A, Nme =< $Z; Nme =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++
						lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end,
							element(5, DecAST)}, InStats};
						true -> {if FunNum =/= [] -> {var,0,list_to_atom(case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end)}; true -> {atom,0,element(2, element(3, Val))} end, #{}} end,
					GenAST = {call,0,FunAST,[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(3, element(3, Val)) - 1)]},
					case MakeNamedFun andalso re:run(atom_to_list(element(2, element(3, Val))), %after name function seems to have ignored return value by emulator so raise opcode has its class value still
						".*-after\\$\\^\\d*?\/\\d*?-\\d*?-", [unicode,ucp]) =/= nomatch of true -> ModAST = insertgraphnode(AST, CurNode,
							GenAST, Cur, CurNode);
					_ -> if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},
								GenAST},
									setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x, 0},
						GenAST)) end end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, false, maps:merge(Stats, CStats)}, Glob);
				call_only -> MakeNamedFun = not lists:member({element(2, element(3, Val)), element(3, element(3, Val))}, element(2, Glob)) andalso
					re:run(atom_to_list(element(2, element(3, Val))),
						".*-(?:.*|(?:lc|lbc|after)\\$\\^\\d*?)\/\\d*?-\\d*?-", [unicode,ucp]) =/=
						nomatch, %-FUNCNAME/ARITY-[lc/lbc/after]$^InnerNum/Arity-Num-
					FunNum = case lists:member({element(2, element(3, Val)), element(3, element(3, Val))}, element(2, Glob)) andalso
						re:run(atom_to_list(element(2, element(3, Val))),
							"-.*(?:\\$\\^\\d*?)?\/\\d*?-\\d*?-", [unicode,ucp]) =/= nomatch orelse
						MakeNamedFun of true -> string:split(lists:nth(2, string:split(atom_to_list(element(2, element(3, Val))), "\/")), "-", all); _ -> [] end,
					SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val))),
					{FunAST, CStats} = if MakeNamedFun -> {DecAST, InStats, _} = dodecompileast(element(3, Glob), element(2, element(3, Val)), element(3, element(3, Val)), case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) ++ "_" ++ VarPrefix end, [], element(4, Glob), element(2, Glob), element(5, Glob)),
						{{named_fun,0,case hd(lists:nth(2, FunNum)) of Nme when Nme >= $A, Nme =< $Z; Nme =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end,element(5, DecAST)}, InStats};
						true -> {if FunNum =/= [] -> {var,0,list_to_atom(case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end)}; true -> {atom,0,element(2, element(3, Val))} end, #{}} end,
					GenAST = {call,0,FunAST,[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(3, element(3, Val)) - 1)]},
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},
								GenAST},
									setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x, 0}, GenAST)) end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, true, maps:merge(Stats, CStats)}, Glob);
				call_last -> MakeNamedFun = not lists:member({element(2, element(3, Val)), element(3, element(3, Val))}, element(2, Glob)) andalso
					re:run(atom_to_list(element(2, element(3, Val))),
						".*-(?:.*|(?:lc|lbc|after)\\$\\^\\d*?)\/\\d*?-\\d*?-", [unicode,ucp]) =/=
						nomatch, %-FUNCNAME/ARITY-[lc/lbc/after]$^InnerNum/Arity-Num-
					FunNum = case lists:member({element(2, element(3, Val)), element(3, element(3, Val))}, element(2, Glob)) andalso
						re:run(atom_to_list(element(2, element(3, Val))),
							"-.*(?:\\$\\^\\d*?)?\/\\d*?-\\d*?-", [unicode,ucp]) =/= nomatch orelse
						MakeNamedFun of true -> string:split(lists:nth(2, string:split(atom_to_list(element(2, element(3, Val))), "\/")), "-", all); _ -> [] end,
					SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val))),
					{FunAST, CStats} = if MakeNamedFun -> {DecAST, InStats, _} = dodecompileast(element(3, Glob), element(2, element(3, Val)), element(3, element(3, Val)), case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) ++ "_" ++ VarPrefix end, [], element(4, Glob), element(2, Glob), element(5, Glob)),
						{{named_fun,0,case hd(lists:nth(2, FunNum)) of Nme when Nme >= $A, Nme =< $Z; Nme =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end,element(5, DecAST)}, InStats};
						true -> {if FunNum =/= [] -> {var,0,list_to_atom(case hd(lists:nth(2, FunNum)) of Nm when Nm >= $A, Nm =< $Z; Nm =:= $_ -> hd(string:split(lists:nth(2, FunNum), "\/")); _ -> "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) end)}; true -> {atom,0,element(2, element(3, Val))} end, #{}} end,
					GenAST = {call,0,FunAST,[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(3, element(3, Val)) - 1)]},
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},
								GenAST},
									setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x, 0}, GenAST)) end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, true, maps:merge(Stats, CStats)}, Glob);
				call_ext -> IsExit = erl_bifs:is_exit_bif(element(2, element(3, Val)), element(3, element(3, Val)), element(4, element(3, Val))), SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val)), element(4, element(3, Val))),
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							%move this to cleanup as must check function table, plus makes cleanups harder if have to check 2 cases with and without remote erlang for errors specifically
							if IsExit -> {call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]};
							true -> {match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},{call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]}} end,
								if IsExit -> Cur; true -> setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}) end, CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x,0}, {call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]})) end,
					{NewAST, NewGraph, NewAsgn, Crs, CNodes, CEdges, CREdges} =
						if IsExit -> handle_exit_merge(ModAST,
							Graph, NodeState, CurNode, AssignedVars, VarPrefix, {element(1, Glob) + 1, LabelToNode, element(2, element(3, Glob)), hd(element(2, Glob))}, element(5, Glob));
						true -> {ModAST, Graph, if SEffect -> 1; true -> 0 end, 0, 0, 0, 0} end,
					#{0 := {C, CN, CE, CRE}} = Stats,
					decompile_step({tl(InstList), NewAST, NewGraph, NodeState,
						LabelToNode, CurNode, VarPrefix, AssignedVars + NewAsgn,
						IsExit, Stats#{0 := {C + Crs, CN + CNodes, CE + CEdges, CRE + CREdges}}}, Glob);
				call_ext_only -> SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val)), element(4, element(3, Val))),
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},{call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]}},
								setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x,0}, {call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]})) end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, true, Stats}, Glob);
				call_ext_last -> SEffect = hassideeffect(element(2, element(3, Val)), element(3, element(3, Val)), element(4, element(3, Val))),
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},{call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]}},
								setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x,0}, {call,0,{remote,0,{atom,0,element(2, element(3, Val))},{atom,0,element(3, element(3, Val))}},[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(4, element(3, Val)) - 1)]})) end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, true, Stats}, Glob);
				call_fun -> SEffect = hassideeffect(getmemd(Cur, {x, element(2, Val)}), element(2, Val)),
					if SEffect -> ModAST = insertgraphnode(AST, CurNode,
							{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))},{call,0,getmemd(Cur, {x, element(2, Val)}),[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(2, Val) - 1)]}},
								setmemd(Cur, {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars))}), CurNode);
					true -> ModAST = setgraphpath(AST, CurNode, setmemd(Cur, {x, 0}, {call,0,getmemd(Cur, {x, element(2, Val)}),[getmemd(Cur, {x, X}) || X <- lists:seq(0, element(2, Val) - 1)]})) end,
					decompile_step({tl(InstList), ModAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							if SEffect -> 1; true -> 0 end, false, Stats}, Glob);
				make_fun2 -> FunNum = string:split(lists:nth(2, string:split(atom_to_list(element(2, element(2, Val))), "/")), "-", all), %-FUNCNAME/ARITY-fun-Num-
					%no side effect but this is saved for code cleanup as its easier to find single use than duplicate code
					{CapAssign, NewCur} = lists:foldl(fun (Elem, Acc) -> El = getmemd(Cur, {x, Elem}), case El of {var,_,_} -> {element(1, Acc), [hd(element(2, Acc))|element(2, Acc)]}; _ ->
						C = setmemd(hd(element(2, Acc)), {x, Elem}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + element(1, Acc)))}),
						{element(1, Acc) + 1, [C|element(2, Acc)]} end end, {0, [Cur]}, lists:seq(0, element(5, Val) - 1)),
					CapAST = lists:foldl(fun (Elem, Acc) -> El = getmemd(Cur, {x, Elem}), case El of {var,_,_} -> Acc; _ ->
						A = insertgraphnode(Acc, CurNode,
							{match,0,getmemd(lists:nth(element(5, Val) - Elem, NewCur), {x, Elem}), El}, lists:nth(element(5, Val) - Elem, NewCur), CurNode),
						A end end, AST, lists:seq(element(5, Val) - 1, 0, -1)),
					{DecAST, InStats, _} = dodecompileast(if element(2, element(3, Glob)) =:= element(1, element(2, Val)) -> element(3, Glob); true -> atom_to_list(element(1, element(2, Val))) end, element(2, element(2, Val)), element(3, element(2, Val)), "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) ++ "_" ++ VarPrefix, lists:sublist(array:to_list(element(3, hd(NewCur))), 1, element(5, Val)), element(4, Glob), element(2, Glob), element(5, Glob)),
					FinAST = insertgraphnode(CapAST, CurNode,
						{match,0,{var,0,list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + element(5, Val)))},
							{'fun',0,{clauses,element(5, DecAST)}}},
								setmemd(hd(NewCur), {x,0}, {var, 0, list_to_atom(VarPrefix ++ "Var" ++ integer_to_list(AssignedVars + element(5, Val)))}), CurNode),
					%setgraphpath(CapAST, lists:droplast(CurNodePath) ++ [lists:last(CurNodePath) + CapAssign * 2], setmemd(NewCur, {x, 0}, %need to handle capture variables through naming
						%{'fun',0,{clauses,element(5, element(1, dodecompileast(atom_to_list(element(1, element(2, Val))), element(2, element(2, Val)), element(3, element(2, Val)), "F" ++ lists:nth(1, FunNum) ++ "_" ++ lists:nth(3, FunNum) ++ "_" ++ VarPrefix, lists:sublist(element(3, NewCur), 1, element(5, Val)))))}})),
					decompile_step({tl(InstList), FinAST,
						Graph, NodeState, LabelToNode, CurNode, VarPrefix, AssignedVars +
							CapAssign + 1, false, maps:merge(Stats, InStats)}, Glob)
			end end end
		end
	end
.

%lib/compiler/src/sys_core_fold.erl: is_safe_bool_expr(Core, Sub) - only boolean returns, is_function specially allowed but not safe, if all arguments are boolean, is_safe(), comp_op(), new_type_test()
%lib/stdlib/src/erl_internal.erl : guard_bif
is_guard_bif(Name, Arity) -> %is_record and is_function are not safe depending on arguments though they will not fail in guards, possibly due to extra argument check
	erl_internal:guard_bif(Name, Arity)
    orelse erl_internal:arith_op(Name, Arity)
    orelse erl_internal:bool_op(Name, Arity)
    orelse erl_internal:comp_op(Name, Arity)
    orelse erl_internal:new_type_test(Name, Arity)
    orelse erl_bifs:is_safe(erlang, Name, Arity).

isguardexpr(AST) -> %lib/compiler/src/core_lint.erl, v3_core.erl
	element(2, traverse_ast(fun (Elem, Acc) ->
	{Elem, Acc andalso case Elem of
	{var,_,_} -> true;
	{char,_,_} -> true;
	{integer,_,_} -> true;
	{float,_,_} -> true;
	{atom,_,_} -> true;
	{string,_,_} -> true;
	{nil,_} -> true;
	{cons,_,_,_} -> true;
	{tuple,_,_} -> true;
	{map,_,_} -> true;
	{bin,_,_} -> true;
		{bin_element,_,_,_,_} -> true;
	{call,_,A,B} -> case A of {atom,_,C} -> is_guard_bif(C, length(B)); {remote,_,{atom,_,'erlang'},{atom,_,C}} -> is_guard_bif(C, length(B)); _ -> false end; %is_record must have a atom, integer argument
	{match,_,_,_} -> true;
	{op,_,A,_} -> A =:= 'not' orelse is_guard_bif(A, 1);%erl_internal:bool_op(A, 1);
	{op,_,A,_,_} -> A =:= 'andalso' orelse A =:= 'orelse' orelse is_guard_bif(A, 2);%erl_internal:bool_op(A, 2);
	{remote,_,_,_} -> true;
	_ -> false end} end, true, AST))
.

issafesingleuse(AST,Var,Mod) -> %4 states: not yet found, not yet found/side-effect, found once, found more than once/side-effect
	%top to bottom scan order, must processing siblings first and then recursively in order for side-effects
	traverse_ast(fun (Elem, Acc) ->
	{case Elem of {var,_,Var} -> Mod; _ -> Elem end, case Elem of
	{var,_,Var} -> {true, element(1, Acc)};
	{var,_,_} -> Acc;
	{char,_,_} -> Acc;
	{integer,_,_} -> Acc;
	{float,_,_} -> Acc;
	{atom,_,_} -> Acc;
	{string,_,_} -> Acc;
	{nil,_} -> Acc;
	{cons,_,_,_} -> Acc;
	{tuple,_,_} -> Acc;
	{map,_,_} -> Acc;
	{bin,_,_} -> Acc;
		{bin_element,_,_,_,_} -> Acc;
	{call,_,A,B} -> case Acc of {true, On} -> {true, case A of {atom,_,C} -> On orelse not is_guard_bif(C, length(B));
		{remote,_,{atom,_,'erlang'},{atom,_,C}} -> On orelse not is_guard_bif(C, length(B)); _ -> false end}; _ -> Acc end; %is_record must have a atom, integer argument
	{match,_,_,_} -> Acc;
	{op,_,A,_} -> case Acc of {true, On} -> {true, On orelse not (A =:= 'not' orelse is_guard_bif(A, 1))}; _ -> Acc end;%erl_internal:bool_op(A, 1);
	{op,_,A,_,_} -> case Acc of {true, On} -> {true, On orelse not (A =:= 'andalso' orelse A =:= 'orelse' orelse is_guard_bif(A, 2))}; _ -> Acc end;%erl_internal:bool_op(A, 2);
	{remote,_,_,_} -> case Acc of {true, _} -> {true, true}; _ -> Acc end;
	_ -> case Acc of {true, _} -> {true, true}; _ -> Acc end end} end, {false, false}, AST)
.

min_cleanup_ast(AST) ->
	[element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of 
		{clause,L,A,B,[]} -> {clause,L,A,B,[{atom,0,true}]};
		{'receive',L,A,B,[]} -> {'receive',L,A,B,[{atom,0,true}]};
		_ -> Elem end, Acc} end, [], hd(AST)))]
.

%get_ast_depth(AST) -> %bottom to top
%	element(1, traverse_ast(fun (Elem, Acc) ->
%		{case Elem of 
%		{cons,_L,A,B} -> max(A, B);
%		{lc,_L,A,B} -> max(A, lists:max(B));
%		{bc,_L,A,B} -> max(A, lists:max(B));
%		{tuple,_L,A} -> if A =:= [] -> 0; true -> lists:max(A) end;
%		{map,_L,A} -> if A =:= [] -> 0; true -> lists:max(A) end;
%		{map,_L,A,B} -> max(A, lists:max(B));
%			{map_field_assoc,_L,A,B} -> max(A, B);
%			{map_field_exact,_L,A,B} -> max(A, B);
%		{call,_L,A,B} -> max(A, if B =:= [] -> 0; true -> lists:max(B) end);
%		{match,_L,A,B} -> max(A, B);
%		{op,_L,_A,B} -> B;
%		{op,_L,_A,B,C} -> max(B, C);
%		{bin,_L,A} -> if A =:= [] -> 0; true -> lists:max(A) end;
%			{bin_element,_L,A,B,_C} ->
%				max(A, if B =:= default -> 0; true -> B end);
%		{remote,_L,A,B} -> max(A, B);
%		{clause,_L,A,B,C} -> max(max(if A =:= [] -> 0; true -> lists:max(A) end,
%			if B =:= [] -> 0; true -> lists:max(lists:map(fun (El) ->
%				if El =:= [] -> 0; true -> lists:max(El) end end, B)) end),
%			if C =:= [] -> 0; true -> lists:max(C) end);
%		{function,_L,_A,_B,C} -> lists:max(C);
%		
%		{block,_L,A} -> lists:max(A) + 1;
%		{'if',_L,A} -> if A =:= [] -> 0; true -> lists:max(A) end + 1;
%		{'case',_L,A,B} -> max(A, lists:max(B)) + 1;
%		{'try',_L,A,B,C,D} -> max(max(if A =:= [] -> 0; true -> lists:max(A) end,
%			if B =:= [] -> 0; true -> lists:max(B) end),
%				max(if C =:= [] -> 0; true -> lists:max(C) end,
%					if D =:= [] -> 0; true -> lists:max(D) end)) + 1;
%		{'receive',_L,A} -> lists:max(A) + 1;
%		{'receive',_L,A,B,C} -> max(max(if A =:= [] -> 0; true ->
%			lists:max(A) end, B), if C =:= [] -> 0; true -> lists:max(C) end) + 1;
%		{'fun',_L,{clauses,A}} -> if A =:= [] -> 0; true -> lists:max(A) end + 1;
%		{'fun',_L,{function,_A,_B}} -> 1;
%		{named_fun,_L,_A,B} -> lists:max(B) + 1;
%		{'catch',_L,A} -> A + 1;
%		_ -> 0 end, Acc} end, [], hd(AST)))
%.

sumlists([]) -> [];
sumlists(Lst) -> {A, B} = lists:unzip(lists:filtermap(fun (El) ->
	case El of [] -> false; [H|T] -> {true, {H, T}} end end, Lst)),
	if A =:= [] -> []; true -> [lists:sum(A)|sumlists(B)] end.

get_ast_depth_agg(AST) -> %bottom to top
	element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of 
		{cons,_L,A,B} -> sumlists([A, B]);
		{lc,_L,A,B} -> sumlists([A|B]);
		{bc,_L,A,B} -> sumlists([A|B]);
		{tuple,_L,A} -> sumlists(A);
		{map,_L,A} -> sumlists(A);
		{map,_L,A,B} -> sumlists([A|B]);
			{map_field_assoc,_L,A,B} -> sumlists([A, B]);
			{map_field_exact,_L,A,B} -> sumlists([A, B]);
		{call,_L,A,B} -> sumlists([A|B]);
		{match,_L,A,B} -> sumlists([A, B]);
		{op,_L,_A,B} -> B;
		{op,_L,_A,B,C} -> sumlists([B, C]);
		{bin,_L,A} -> sumlists(A);
			{bin_element,_L,A,B,_C} ->
				sumlists(if B =:= default -> [A]; true -> [A,B] end);
		{remote,_L,A,B} -> sumlists([A, B]);
		{clause,_L,A,B,C} -> sumlists(A ++ lists:append(B) ++ C);
		{function,_L,_A,_B,C} -> sumlists(C);
		
		{block,_L,A} -> [1|sumlists(A)];
		{'if',_L,A} -> [1|sumlists(A)];
		{'case',_L,A,B} -> [1|sumlists([A|B])];
		{'try',_L,A,B,C,D} -> [1|sumlists(A ++ B ++ C ++ D)];
		{'receive',_L,A} -> [1|sumlists(A)];
		{'receive',_L,A,B,C} -> [1|sumlists([B|A ++ C])];
		{'fun',_L,{clauses,A}} -> [1|sumlists(A)];
		{'fun',_L,{function,_A,_B}} -> [1];
		{named_fun,_L,_A,B} -> [1|sumlists(B)];
		{'catch',_L,A} -> [1|A];
		_ -> [] end, Acc} end, [], hd(AST)))
.

%guardseqs(AST) -> %orelse
%	case AST of {op,_,'orelse',A,B} -> lists:append([guardseqs(A), guardseqs(B)]);
%	_ -> [AST] end
%.

%guardexprs(AST) -> %andalso
%	case AST of {op,_,'andalso',A,B} ->
%   lists:append([guardexprs(A), guardexprs(B)]);
%	_ -> [AST] end
%.

isbinarypattern(AST, CleanAST, SubOut) ->
%io:format("~p~n", [AST]),
	GetBits = get_clean_ast(CleanAST, get_bits, 2, SubOut),
	SkipBits = get_clean_ast(CleanAST, skip_bits, 2, SubOut),
	case AST of
	{op,L,'=:=',{op,L,'rem',{call,L,{remote,L,{atom,L,erlang},{atom,L,bit_size}},
		[B]},{integer,L,C}},{integer,L,0}} -> %bs_get_binary2 all
 		[{B,{bin,L,[{bin_element,L,{var,L,'_'},default,[bitstring,{unit,C}]}]}}];
 	{op,L,'=:=',{call,L,{remote,L,{atom,L,erlang},{atom,L,'bit_size'}},[B]},
 		{integer,L,C}} -> %bs_test_tail2
 	io:format("bs_test_tail2~n"),
 		[{B, {bin,L,[{bin_element,L,{var,L,'_'},{integer,L,C},[bitstring]}]}}];
 	{op,L,'andalso',{atom,L,true},A} ->
 		isbinarypattern(A, CleanAST, SubOut); %bs_start_match2
 	{op,L,'>=',{call,L,{remote,L,{atom,L,erlang},{atom,L,'bit_size'}},[B]},
 		{op,L,'*',{integer,L,C},{integer,L,D}}} -> %bs_get_integer2
 	io:format("bs_get_integer2~n"),
 		[{B, {bin,L,[{bin_element,L,{var,L,'_'},{integer,L,C*D},[integer]}]}}];
 	{op,L,'andalso',{op,L,'>=',{call,L,{remote,L,{atom,L,erlang},
 		{atom,L,bit_size}},[B]},{integer,L,C}},
 		{op,L,'=:=',{call,L,{'fun',L,{clauses,[GetBits]}},[B,{integer,L,C}]},D}} ->
 	io:format("bs_match_string~n"), %bs_match_string
 		 [{B, D}];
	{op,L,'=:=',{op,L,'rem',{call,L,{remote,L,{atom,L,erlang},
		{atom,L,'bit_size'}},[B]},{integer,L,C}},{integer,L,0}} -> %bs_skip_bits2
 	io:format("bs_skip_bits2~n"),
 		[{B, {bin,L,[{bin_element,L,{var,L,'_'},{integer,L,C},[bitstring]}]}}];
 	{op,L,'andalso',{op,L,'>=',{integer,L,C},{integer,L,0}},
 		{op,L,'>=',{call,L,{remote,L,{atom,L,erlang},{atom,L,bit_size}},[B]},
 			{op,L,'*',{integer,L,C},{integer,L,D}}}} -> %bs_skip_bits2 all
 	io:format("bs_skip_bits2 all~n"), %_ is length of C * D
 		[{B, {bin,L,[{bin_element,L,{var,L,'_'},{integer,L,C*D},[bitstring]}]}}];
 	{op,_,'andalso',A,B} ->
 		case isbinarypattern(A, CleanAST, SubOut) of false -> false; Elems -> io:format("~p~n", [hd(Elems)]),
 			case isbinarypattern(B, CleanAST, SubOut) of false -> false; Els ->
 				case hd(Elems) of %{{call,L,{'fun',L,{clauses,[SkipBits]}},[Bin,{integer,L,C}]}, F} -> [{{bin,L,case Bin of {bin,L,BE} -> BE ++ [F]; _ -> [Bin,F] end}, element(2, hd(Els))}];
 				{{call,L,{'fun',L,{clauses,[SkipBits]}},[Bin,{op,L,'*',{integer,L,_C},{integer,L,_D}}]}, {bin,L,F}} -> case hd(Els) of {_H, {bin, L, G}} when length(Els) =:= 1 -> [{Bin, {bin,L,F ++ G}}]; _ -> false end;
 				{{var,L,E},{bin,L,F}} when length(Elems) =:= 1 -> case hd(Els) of {_H, {bin, L, G}} when length(Els) =:= 1 -> [{{var,L,E}, {bin,L, F ++ G}}]; _ -> false end;
 				{{block,L,[{match,L,{bin,L,_},{bin,L,E}},{var,L,_}]}, {bin,L,F}} when length(Elems) =:= 1 -> case hd(Els) of {_H, {bin, L, G}} when length(Els) =:= 1 -> [{{bin,L,E}, {bin,L, F ++ G}}]; _ -> io:format("~p~n", [{length(Elems),hd(Elems),length(Els),hd(Els)}]), false end;
 					{{bin,L,E}, {bin,L,F}} when length(Elems) =:= 1 -> case hd(Els) of {_H, {bin, L, G}} when length(Els) =:= 1 -> [{{bin,L,E}, {bin,L, F ++ G}}]; _ -> io:format("~p~n", [{length(Elems),hd(Elems),length(Els),hd(Els)}]), false end;
 					_ -> io:format("~p~n", [{length(Elems),hd(Elems)}]), false end end end;
	%{op,0,'=:=',A,B} ->
		
 	_ -> io:format("~p~n", [AST]), false
	end.
	
ispatternmatch(AST, CleanAST, SubOut) -> %{[{Original, Pattern}|...}], NewVar, VarUse, Guards}
	%base cases: lists, tuples, binaries, recursive constructions
	%variable fence for current state in patterns
	%emitting variables for pattern matches used thereafter
	%emission of variable used multiple times in pattern
	%guard expressions at the end including variable replacement
	case isbinarypattern(AST, CleanAST, SubOut) of false ->
	case AST of
	%any strict equality
 	{op,_,'=:=',A,B} -> {[{A, B}], [], [], []};
 	%tuples
 	{op,L,'andalso',{call,L,{remote,L,{atom,L,erlang},{atom,L,is_tuple}},[A]},{op,L,'andalso',{op,L,'andalso',{call,L,{remote,L,{atom,L,erlang},{atom,L,is_tuple}},[A]},{op,L,'=:=',{call,L,{remote,L,{atom,L,erlang},{atom,L,tuple_size}},[A]},{integer,L,C}}},B}} ->
 		case ispatternmatch(B, CleanAST, SubOut) of false -> false; Elems -> {Rest, Asgn} = lists:partition(fun({Elem,_}) -> case Elem of {call,L,{remote,L,{atom,L,erlang},{atom,L,element}},[{integer,L,_},A]} -> false; _ -> true end end, element(1, Elems)),
 			{[{A, {tuple,L,[case lists:keyfind({call,L,{remote,L,{atom,L,erlang},{atom,L,element}},[{integer,L,X},A]},1,element(1, Elems)) of {_,Pat} -> Pat; _ -> {var,L,'_'} end || X <- lists:seq(1, C)]}}|Rest],
 				element(2, Elems), element(3, Elems) ++ Asgn, element(4, Elems)} end;
 	%lists
 	{op,L,'andalso',{op,L,'andalso',{call,L,{remote,L,{atom,L,erlang},{atom,L,is_list}},[A]},{op,L,'=/=',A,{nil,L}}},B} ->
 		case ispatternmatch(B, CleanAST, SubOut) of false -> false;
 			Elems -> {Rest, Asgn} = lists:partition(fun({Elem,_}) -> case Elem of {call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[A]} -> false; {call,L,{remote,L,{atom,L,erlang},{atom,L,tl}},[A]} -> false; _ -> true end end, element(1, Elems)),
 			{[{A, {cons,L,case lists:keyfind({call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[A]},1,element(1, Elems)) of {_,Pat} -> Pat; _ -> {var,L,'_'} end,
 				case lists:keyfind({call,L,{remote,L,{atom,L,erlang},{atom,L,tl}},[A]},1,element(1, Elems)) of {_,Pat} -> Pat; _ -> {var,L,'_'} end}}|Rest],
 					element(2, Elems), element(3, Elems) ++ Asgn, element(4, Elems)} end;
 	{op,_,'andalso',A,B} -> case ispatternmatch(A, CleanAST, SubOut) of false -> false; Elems1 -> case ispatternmatch(B, CleanAST, SubOut) of false -> false; Elems2 -> {element(1, Elems1) ++ element(1, Elems2), element(2, Elems1) ++ element(2, Elems2), element(3, Elems1) ++ element(3, Elems2), element(4, Elems1) ++ element(4, Elems2)} end end;
	_ -> case isguardexpr(AST) of true -> {[], [], [], [AST]}; _ -> io:format("~p~n", [AST]), false end end; BinPat -> io:format("~p~n", [{length(BinPat), tuple_size(hd(BinPat)), BinPat}]), BinPat end
.

cleanup_ast(AST, CleanAST, _VarPrefix, _AssignedVars, Beam, SubOut) ->
	%andalso, orelse, andalso with orelse for case
	BoolAST = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of
		{'case',L,A,[{clause,L,[{atom,L,true}],[],[{'case',L,B,[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]}]},{clause,L,[{atom,L,false}],[],D}]} ->
			{'case',L,{op,L,'andalso',A,B},[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]};
		{'case',L,A,[{clause,L,[{atom,L,true}],[],[{'case',L,B,[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]}]},{clause,L,[{atom,L,false}],[],C}]} ->
			{'case',L,{op,L,'orelse',{op,L,'not',A},B},[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]};
		{'case',L,A,[{clause,L,[{atom,L,true}],[],[{'case',L,B,[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]}]},{clause,L,[{atom,L,false}],[],[{'case',L,E,[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]}]}]} ->
			{'case',L,{op,L,'orelse',{op,L,'andalso',{op,L,'not',A},E},{op,L,'andalso',A,B}},[{clause,L,[{atom,L,true}],[],C},{clause,L,[{atom,L,false}],[],D}]};
		_ -> Elem end, Acc} end, [], hd(AST)))],
  %SkipBits = get_clean_ast(CleanAST, skip_bits, 2, SubOut),
	SimpBoolAST = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of
		{op,L,'orelse',{op,L,'andalso',{op,L,'not',A},C},{op,L,'andalso',A,{op,L,'orelse',B,C}}} ->
			{op,L,'orelse',{op,L,'andalso',A,B},C}; %!A && C || A && (B || C) -> A && B || C
		{op,L,'orelse',{op,L,'andalso',A,C},{op,L,'andalso',{op,L,'not',A},{op,L,'orelse',B,C}}} ->
			{op,L,'orelse',{op,L,'andalso',A,B},C}; %A && C || !A && (B || C) -> A && B || C
		{op,L,'orelse',{op,L,'andalso',{op,L,'not',A},C},{op,L,'andalso',A,{op,L,'andalso',B,C}}} ->
			{op,L,'andalso',{op,L,'orelse',A,B},C}; %!A && C || A && B && C -> (A || B) && C
		{op,L,'orelse',{op,L,'andalso',A,C},{op,L,'andalso',{op,L,'not',A},{op,L,'andalso',B,C}}} ->
			{op,L,'andalso',{op,L,'orelse',A,B},C}; %A && C || !A && B && C -> (A || B) && C
		{op,L,'not',{op,L,'not',A}} -> A;
		{op,L,'not',{op,L,'=/=',A,B}} -> {op,L,'=:=',A,B};
		{op,L,'not',{op,L,'=:=',A,B}} -> {op,L,'=/=',A,B};
		{op,L,'not',{op,L,'/=',A,B}} -> {op,L,'==',A,B};
		{op,L,'not',{op,L,'==',A,B}} -> {op,L,'/=',A,B};
		{op,L,'not',{op,L,'<',A,B}} -> {op,L,'>=',A,B};
		{op,L,'not',{op,L,'=<',A,B}} -> {op,L,'>',A,B};
		{op,L,'not',{op,L,'>=',A,B}} -> {op,L,'<',A,B};
		{op,L,'not',{op,L,'>',A,B}} -> {op,L,'<=',A,B};
		{op,L,'=:=',A,{atom,L,true}} -> A; %only in a boolean expression
		{op,L,'=/=',A,{atom,L,true}} -> {op,L,'not',A}; %only in a boolean expression
		%{call,L,{'fun',L,{clauses,[SkipBits]}},[{bin,L,B},{integer,L,C}]} -> {block,L,[{match,L,{bin,L,[{bin_element,L,{var,L,'_'},{integer,L,C},[bitstring]},{bin_element,L,{var,L,'Var'},default,[bitstring]}]},{bin,L,B}},{var,L,'Var'}]};
		%{call,L,{'fun',L,{clauses,[SkipBits]}},[{block,L,[{match,L,{bin,L,E},{bin,L,B}},{var,L,D}]},{op,L,'*',{integer,L,C},{integer,L,F}}]} ->
		%	case lists:all(fun (A) -> case A of {bin_element,L,{var,L,'_'},{integer,L,_},[bitstring]} -> true; _ -> false end end, lists:droplast(E)) of true ->
		%		case lists:last(E) of {bin_element,L,{var,L,D},default,[bitstring]} -> {block,L,[{match,L,{bin,L,lists:droplast(E) ++ [{bin_element,L,{var,L,'_'},{integer,L,C*F},[bitstring]},lists:last(E)]},{bin,L,B}},{var,L,'Var'}]}; _ -> Elem end; _ -> Elem end;
		%{call,L,{'fun',L,{clauses,[SkipBits]}},[{block,L,[{match,L,{bin,L,E},{bin,L,B}},{var,L,D}]},{integer,L,C}]} ->
		%	case lists:all(fun (A) -> case A of {bin_element,L,{var,L,'_'},{integer,L,_},[bitstring]} -> true; _ -> false end end, lists:droplast(E)) of true ->
		%		case lists:last(E) of {bin_element,L,{var,L,D},default,[bitstring]} -> {block,L,[{match,L,{bin,L,lists:droplast(E) ++ [{bin_element,L,{var,L,'_'},{integer,L,C},[bitstring]},lists:last(E)]},{bin,L,B}},{var,L,'Var'}]}; _ -> Elem end; _ -> Elem end;
		_ -> Elem end, Acc} end, [], hd(BoolAST)))],
	%return value from case
	CaseRetAST = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of
		{'case',L,A,[{clause,L,[{atom,L,true}],[],B},{clause,L,[{atom,L,false}],[],C}]} ->
			case {if length(B) =/= 0 -> lists:last(B); true -> {} end,if length(C) =/= 0 -> lists:last(C); true -> {} end} of {{match,L,{var,L,X},D},{match,L,{var,L,X},E}} ->
				{match,L,{var,L,X},{'case',L,A,[{clause,L,[{atom,L,true}],[],lists:droplast(B) ++ [D]},{clause,L,[{atom,L,false}],[],lists:droplast(C) ++ [E]}]}};
			{{match,L,{var,L,X},D},{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},_}} ->
				{match,L,{var,L,X},{'case',L,A,[{clause,L,[{atom,L,true}],[],lists:droplast(B) ++ [D]},{clause,L,[{atom,L,false}],[],C}]}}; _ -> Elem end;
		_ -> Elem end, Acc} end, [], hd(SimpBoolAST)))],
	%unnesting cases
	%pull out guard expressions
	%case/if simplify - at function level if solely based on function arguments and pattern match with legal guard expressions,
	%		pattern match comes before guard checks, so guard can only come from end of tree
	%		if_clause andalso all legal guard expression then if, all legal guard expression and not pattern match then if, case_clause then case, otherwise case
	IfCaseAST = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of
		{'case',L,A,[{clause,L,[{atom,L,true}],[],B},{clause,L,[{atom,L,false}],[],[{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},[{atom,L,if_clause}]}]}]} ->
			case isguardexpr(A) of true -> %{'case',L,{atom,L,true},[{clause,L,[{atom,L,true}],[guardexprs(X) || X <- guardseqs(A)],B},{clause,L,[{atom,L,false}],[],C}]};
				{'if',L,[{clause,L,[],[[A]],B}]}; _ -> Elem end;
		{'case',L,A,[{clause,L,[{atom,L,true}],[],B},{clause,L,[{atom,L,false}],[],[{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},[{atom,L,case_clause}]}]}]} ->
			{'case',L,A,[{clause,L,[{atom,L,true}],[],B}]};
		{'case',L,A,[{clause,L,[{atom,L,true}],[],B},{clause,L,[{atom,L,false}],[],[{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},[{tuple,L,[{atom,L,badmatch},C]}]}]}]} ->
			case ispatternmatch(A, CleanAST, SubOut) of [{E, D}] -> io:format("~p~n", [{C, D, E}]),if C =:= E -> {block,L,[{match,L, D, E}|B]}; true -> Elem end; _ -> Elem end;
		{'case',L,A,[{clause,L,[{atom,L,true}],[],B},{clause,L,[{atom,L,false}],[],C}]} ->
			case ispatternmatch(A, CleanAST, SubOut) of {[{E, D}], _, _, Guards} ->
				{'case',L,E,[{clause,L,[D],if Guards =:= [] -> []; true -> [Guards] end,B},{clause,L,[{var,L,'_'}],[],C}]};
			_ -> case isguardexpr(A) of true -> %{'case',L,{atom,L,true},[{clause,L,[{atom,L,true}],[guardexprs(X) || X <- guardseqs(A)],B},{clause,L,[{atom,L,false}],[],C}]};
				{'if',L,[{clause,L,[],[[A]],B},{clause,L,[],[[{atom,L,true}]],C}]}; _ -> Elem end end;
		_ -> Elem end, Acc} end, [], hd(CaseRetAST)))],
	PureSingleUse = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of
		{clause,L,A,B,C} ->
			if length(C) >= 2 -> case lists:nthtail(length(C) - 2, C) of [{match,L,{var,L,X},D},{var,L,X}] ->
				{clause,L,A,B,lists:droplast(lists:droplast(C)) ++ [D]};
				[{match,L,{var,L,X},D},Y] -> case issafesingleuse(Y,X,D) of {Mod, {true, false}} -> {clause,L,A,B,lists:droplast(lists:droplast(C)) ++ [Mod]}; _ -> Elem end; %single use, and no side effects between match and use
				[{'if',L,[{clause,L,[],[D],[]}]},{var,L,X}] -> {clause,L,A,B,lists:droplast(lists:droplast(C)) ++ [{'if',L,[{clause,L,[],[D],[{var,L,X}]}]}]};
				_ -> Elem end; true -> Elem end;
		_ -> Elem end, Acc} end, [], hd(IfCaseAST)))],
	Receive1 = get_clean_ast(CleanAST, 'receive', 1, SubOut),
	Receive3 = get_clean_ast(CleanAST, 'receive', 3, SubOut),
	ListComp = [element(1, traverse_ast(fun (Elem, Acc) ->
		LCR = fun ListCompRec(E, {OuterName, OuterOrigVars, OuterFunArgs, OuterCallArgs, OuterCond}) -> case E of
	  {call,L,{named_fun,L,FunName,[{clause,L,[{var,L,FunArg}|FunArgs],[],[{'if',L,[{clause,L,[],[[{op,L,'andalso',{call,L,{remote,L,{atom,L,erlang},{atom,L,is_list}},[{var,L,FunArg}]},{op,L,'=/=',{var,L,FunArg},{nil,L}}}]],
             [{match,L,{var,L,FunVar},Condition}]},
            {clause,L,[],[[{atom,L,true}]],CallRec}]},
          {var,L,FunVar}]}]},[OrigVar|PassArgs]} -> %when FunName =:= atom_to_list(FunNameAtom) -> FunArgs are all {var, 0, _}
          %PassArgs = {call,L,{remote,L,{atom,L,erlang},{atom,L,tl}},[{var,L,FunArg}]},{call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[{var,L,FunArg}]}
          _CallArgs = case CallRec of [{match,L,{var,L,FunVar},{var,L,FunArg}},{'case',L,{var,L,FunArg},[{clause,L,[{nil,L}],[],[]},{clause,L,[{var,L,'_'}],[],[{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},[{atom,L,function_clause}]}]}]}] -> [];
          	[{'case',L,{var,L,FunArg},[{clause,L,[{nil,L}],[],[{match,L,{var,L,FunVar},{call,L,{var,L,_InnerFunNameAtom},InnerFunArgs}}]},{clause,L,[{var,L,'_'}],[],[{call,L,{remote,L,{atom,L,erlang},{atom,L,error}},[{atom,L,function_clause},{cons,L,{var,L,FunArg},{nil,L}}]}]}]}] -> InnerFunArgs
          	end,
          	{NextExpr, Cond} = case Condition of
          		{'if',L,[{clause,L,[],[[Condit]],[NextExp]},{clause,L,[],[[{atom,L,true}]],[{call,L,{var,L,_FunNameAt},[{call,L,{remote,L,{atom,L,erlang},{atom,L,tl}},[{var,L,FunArg}]}|FunArgs]}]}]}
          	 -> {NextExp, Condit}; NextExp -> {NextExp, []} end,
          	if FunArgs =/= [] andalso OuterName =:= [] -> E; true -> %prevent inner from being processed before outer
          	case NextExpr of {cons,L,ListCompExpr,{call,L,{var,L,_FunNameAtom},[{call,L,{remote,L,{atom,L,erlang},{atom,L,tl}},[{var,L,FunArg}]}|FunArgs]}} ->
          		MVI = fun MapVarIndex(Value, CallOrders, FunOrders) -> if length(CallOrders) =:= 1 -> lists:nth(index_of(Value, [OrigVar|PassArgs]), [{var,L,FunArg}|FunArgs]); true -> MapVarIndex(lists:nth(index_of(Value, lists:last(lists:droplast(CallOrders))), lists:last(lists:droplast(FunOrders))), lists:droplast(CallOrders), lists:droplast(FunOrders)) end end, Tot = (length(FunArgs) + 1) div 2,
          		OuterGens = if OuterName =:= [] -> []; true -> lists:append(lists:map(fun (M) -> Gen = {generate,L,MVI({call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[hd(lists:nth(M, OuterFunArgs))]}, lists:sublist(OuterCallArgs, 1, M), lists:sublist(OuterFunArgs, 1, M)),element(1, traverse_ast(fun (El, A) -> CVar = index_of(El, lists:nth(M, OuterCallArgs)), {case CVar of 0 -> El; 1 -> El; _ -> io:format("~p~n", [{M, El}]), MVI(El, lists:sublist(OuterCallArgs, 1, M+1), lists:sublist(OuterFunArgs, 1, M+1)) end, A} end, [], lists:nth(M, OuterOrigVars)))},
          			case lists:nth(M, OuterCond) of [] -> [Gen]; CurCond -> [element(1, traverse_ast(fun (El, A) -> CVar = index_of(El, if M =:= 1 -> [OrigVar|PassArgs]; true -> lists:nth(M - 1, OuterCallArgs) end), {case CVar of 0 -> El; _ -> MVI(El, lists:sublist(OuterCallArgs, 1, M), lists:sublist(OuterFunArgs, 1, M)) end, A} end, [], CurCond)),Gen] end end, lists:seq(1, Tot))) end,
          		Gen = {generate,L,{var,L,FunArg},element(1, traverse_ast(fun (El, A) -> CVar = index_of(El, PassArgs), {case CVar of 0 -> El; _ -> lists:nth(CVar + 1, [{var,L,FunArg}|FunArgs]) end, A} end, [], OrigVar))},
          		{lc,L,element(1, traverse_ast(fun (El, A) -> {case El of {call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[{var,L,FunArg}]} -> {var,L,FunArg}; _ -> El end, A} end, [], ListCompExpr)),lists:reverse(if Cond =/= [] -> [element(1, traverse_ast(fun (El, A) -> {case El of {call,L,{remote,L,{atom,L,erlang},{atom,L,hd}},[{var,L,FunArg}]} -> {var,L,FunArg}; _ -> El end, A} end, [], Cond)),Gen|OuterGens]; true -> [Gen|OuterGens] end)};
          	_ -> case ListCompRec(NextExpr, {FunName, [OrigVar|OuterOrigVars], [[{var,L,FunArg}|FunArgs]|OuterFunArgs], [[OrigVar|PassArgs]|OuterCallArgs], [Cond|OuterCond]}) of {lc,A,B,C} -> {lc,A,B,C}; _ -> E end end end;
    _ -> E end end,
		{case LCR(Elem, {[], [], [], [], []}) of
		{call,L,{'fun',L,{clauses,[Receive1]}},[{'fun',L,[{clauses,[{clause,L,[{var,L,_MsgVar},{var,L,_RemMsgFunc}],[],_Func}]}]}]} -> %{clause,L,[],[],[]},
			{'receive',0,[],[],[]};
		{call,L,{'fun',L,{clauses,[Receive3]}},[{'fun',L,[{clauses,[{clause,L,[{var,L,_MsgVar},{var,L,_RemMsgFunc}],[],_Func}]}]}, Timeout, {'fun',L,[{clauses,[{clause,L,[],[],AfterFunc}]}]}]} -> {'receive',0,[],Timeout,AfterFunc};
		X -> X end, Acc} end, [], hd(PureSingleUse)))],
	InternalClean = [element(1, traverse_ast(fun (Elem, Acc) ->
		{case Elem of {call,L,{remote,0,{atom,_,erlang},{atom,L,Name}},A} -> case erl_internal:bif(Name) andalso not lists:any(fun (Func) -> element(2, Func) =:= Name end, element(6, Beam)) of true -> {call,L,{atom,L,Name},A};
		X -> X end; X -> X end, Acc} end, [], hd(ListComp)))],
	InternalClean
	%simplify boolean expressions
	%convert booleans to pattern matching,
	%  convert nested binary pattern matching structures
	%binary comprehensions
	%receive
	%try - after
	%unnecessary variable assignments
	%remove erlang: remote call prefix from internal functions
	%  where name/arity not also defined in module
	%remove module_info
.

resolve_graph_data({AST, NodesToAST, ASTDFS, _}, SanityCheck) ->
	lists:foldl(fun (El, A) -> case array:get(array:get(El-1, ASTDFS)-1, NodesToAST) of
		[{}] -> A;
		_ -> lists:foldl(fun(Elem, Acc) ->
				if SanityCheck -> case element(1, dogetgraphpath(Acc, Elem, 1)) of
				graphdata -> true;
				_ -> io:format("~p~n", [{Elem}]) end; true -> true end,
				removegraphpath(Acc, Elem, 1) end, A,
			lists:reverse(array:get(array:get(El-1, ASTDFS)-1, NodesToAST))) end end,
		AST, lists:seq(array:size(ASTDFS), 1, -1)).

fix_graph_tuples(AST) ->
	lists:map(fun (Elem) -> if is_tuple(Elem) ->
		Tuple = list_to_tuple(lists:map(fun (El) -> if is_list(El) ->
			fix_graph_tuples(El); true -> El end end, tuple_to_list(Elem))),
		case Tuple of {match,L,{var,L,A},[{'catch',L,[B]}]} ->
			{match,L,{var,L,A},{'catch',L,B}};
		{match,L,{var,L,A},[{'catch',L,B}]} ->
			{match,L,{var,L,A},{'catch',L,{block,L,B}}};
		{match,L,{var,L,A},[{call,L,{'fun',L,{clauses,B}},C}]} ->
			{match,L,{var,L,A},{call,L,{'fun',L,{clauses,B}},C}};
		{match,L,{var,L,A},[{'try',L,B,C,D,E}]} ->
			{match,L,{var,L,A},{'try',L,B,C,D,E}};
		{'fun',L,[{clauses,X}]} -> {'fun',L,{clauses,X}};
		_ -> Tuple end; true -> Elem end end, AST)
.

%filelib:fold_files(".", ".*\.erl", true, fun (Filename, Acc) ->
%	[decomp:get_src_line_numbers(Filename)|Acc] end, []).
get_src_line_numbers(ErlFname) ->
	{ok, Forms} = epp:parse_file(ErlFname, []),
	lists:filtermap(fun (El) -> if element(1, El) =:= function ->
		DepthList = get_ast_depth_agg(element(5, El)),
		{MaxDepth, AggDepth} = lists:foldl(fun (E, {Lvl, Acc}) ->
		{Lvl + 1, Acc + (Lvl + 1) * E} end, {0, 0}, DepthList),
			{true, {element(3, El), element(4, El), element(2, El),
		element(2, traverse_ast(fun (Elem, Acc) ->
			{Elem, max(Acc, element(2, Elem))}
		end, 0, hd(element(5, El)))), MaxDepth, AggDepth}}; true -> false end end, Forms).

get_func_stats(InstList) ->
	lists:foldl(fun (El, {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi}) ->
		if El =:= if_end -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			is_tuple(El) -> case element(1, El) of
			line -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits,
				if LnLo =:= 0 -> element(2, El); element(2, El) =:= 0 -> LnLo;
				true -> min(element(2, El), LnLo) end, max(element(2, El), LnHi)};
			'catch' -> {Test, SVal, STA, Trys, Catchs+1, Rcvs, Jmps, Calls, Exits, LnLo, LnHi};
			'try' -> {Test, SVal, STA, Trys+1, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi};
			loop_rec -> {Test, SVal, STA, Trys, Catchs, Rcvs+1, Jmps, Calls, Exits, LnLo, LnHi};
			select_val -> {Test, SVal+1, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi};
			select_tuple_arity -> {Test, SVal, STA+1, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi};
			test -> {Test+1, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi};
			jump -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps+1, Calls, Exits, LnLo, LnHi};
			wait -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			loop_rec_end -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			badmatch -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			case_end -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			try_case_end -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			raise -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
			apply -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			apply_last -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call_only -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call_last -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call_ext -> case erl_bifs:is_exit_bif(element(2, element(3, El)),
					element(3, element(3, El)), element(4, element(3, El))) of true ->
				{Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits+1, LnLo, LnHi};
				_ -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi} end;
			call_ext_only -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call_ext_last -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			call_fun -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls+1, Exits, LnLo, LnHi};
			_ -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi} end;
		true -> {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi} end end,
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, InstList)
.

dodecompileast(Func, VarPrefix, Capts, Beam, CleanAST, Ctxt, Opts) ->
	%graph rooted at first node, reverse graph always rooted at second node
	%state: instruction list, AST, predecessors, successors, node to AST,
	%  label to node, curnode, # assigned vars
	%metadata: label, outbound delta values x, y, fr
	State = {	lists:dropwhile(fun(Elem) -> is_atom(Elem) orelse
		element(1, Elem) =/= label orelse element(2, Elem) =/= element(4, Func) end,
		element(5, Func)),
		{[{function,0,element(2, Func),element(3, Func),
			[{clause,0,[{var, 0,
				list_to_atom(VarPrefix ++ "Arg" ++ integer_to_list(X))} ||
				X <- lists:seq(1, element(3, Func) - length(Capts))], [],
				[{graphdata, 0, array:resize(1024, array:from_list([{var, 0,
					list_to_atom(VarPrefix ++ "Arg" ++ integer_to_list(X))} ||
					X <- lists:seq(1, element(3, Func) - length(Capts))] ++ Capts, [])),
							array:new({default,[]}), array:new(16, {default,[]})},
				 {graphdata, 0, array:new(1024, {default,[]}),
				 	array:new({default,[]}), array:new(16, {default,[]})}]}]} %, {unresolved, {x, 0}}
		 ], array:from_list([[{1,5,1,5,1}], [{1,5,1,5,2}], [{}]], []),
		 array:from_list([3, 1, 2]), array:from_list([2, 3, 1], 0)},		 
		 {array:from_list([gb_sets:new(), gb_sets:from_list([1]), gb_sets:from_list([2])], gb_sets:new()),
		 array:from_list([gb_sets:from_list([2]), gb_sets:from_list([3]), gb_sets:new()], gb_sets:new()),
		 array:from_list([gb_sets:from_list([2]), gb_sets:from_list([3]), gb_sets:new()], gb_sets:new()),
		 array:from_list([gb_sets:new(), gb_sets:from_list([1]), gb_sets:from_list([2])], gb_sets:new()),
		 #{1 => {0, gb_sets:new(), gb_sets:from_list([2]), 1},
		 	 2 => {1, gb_sets:new(), gb_sets:from_list([3]), 2},
		 	 3 => {2, gb_sets:new(), gb_sets:new(), 3}},
		 #{1 => {2, gb_sets:new(), gb_sets:new(), 3},
		 	 2 => {3, gb_sets:new(), gb_sets:from_list([1]), 2},
		 	 3 => {0, gb_sets:new(), gb_sets:from_list([2]), 1}},
		 	#{2 => {gb_sets:from_list([1, 2]), gb_sets:new()}},
		 	array:from_list([gb_sets:new(), gb_sets:new(), gb_sets:new()], gb_sets:new())}, array:from_list([1, 0, 0], 0),
		#{1 => 1}, 1, VarPrefix, 1, true, #{0 => {0, 0, 0, 0}}},
	DecState = decompile_step(State, {element(4, Func),
		[{element(2, Func),element(3, Func) - length(Capts)}|Ctxt], Beam, CleanAST,
		Opts, element(5, Func)}),
	%because of sequential processing, important post condition and sanity check
	%to make sure bugs are not being brushed under the rug -
	%  all cross edges resolved
	%merge nodes of course must be filtered out as these
	%variable placeholder nodes are legal cross edges,
	%if only successor is the cross edge, filtered as merge node
	case lists:member(nosanitycheck, Opts) of false ->
		case check_pred_succ(element(3, DecState)) of true -> true;
		_ -> error("Graph sanity check failed") end,
		case check_nodes(element(2, DecState)) of true -> true;
		_ -> error("AST sanity check failed") end,
		case gb_sets:to_list(array:get(3-1, element(2, element(3, DecState)))) =/=
			[2] of true -> #{2 := {RetSet, _}} = element(7, element(3, DecState)), case lists:all(fun (El) ->
				#{El := {Fence, SubG}} = element(7, element(3, DecState)),
				{F, SG} = pred_set_recurse(gb_sets:from_list([El]), RetSet,
					element(3, DecState)),
				case El =:= 2 orelse gb_sets:to_list(Fence) =:= gb_sets:to_list(F)
					andalso gb_sets:to_list(SubG) =:= gb_sets:to_list(SG) of true -> true;
				_ -> io:format("~p~n", [{El, gb_sets:to_list(Fence), gb_sets:to_list(F),
					gb_sets:to_list(SubG), gb_sets:to_list(SG)}]), false end end,
				gb_sets:to_list(array:get(3-1, element(1, element(3, DecState))))) of false
			-> error("Bad fence/subgraph"); _ -> true end,
			{PostDoms, RR, PostDomGraph} = get_post_dom(element(3, DecState)),
			case gb_sets:to_list(RetSet) =:= gb_sets:to_list(RR) of false ->
				io:format("~p~n", [{"Bad return reaching set",
					gb_sets:to_list(RetSet), gb_sets:to_list(RR)}]); _ -> true end,
			case cmp_edgeset(element(2, PostDomGraph),
				element(3, element(3, DecState))) andalso
				cmp_edgeset(element(1, PostDomGraph),
					element(4, element(3, DecState))) of false ->
				error({"Bad reverse graph", get_edgeset(element(1, PostDomGraph)),
					get_edgeset(element(4, element(3, DecState))),
					get_edgeset(element(2, element(3, DecState)))}); _ -> true end,
			case array:to_list(PostDoms) =/= array:to_list(element(1, dom_to_d(maps:fold(fun (El, {_, _}, Acc) -> case El =:= 2 of
			true -> Acc; _ -> Acc#{El => setelement(1, begin #{El := ElPdom} = Acc, ElPdom end, 3)} end end,
					element(6, element(3, DecState)),
				element(7, element(3, DecState)))))) of true ->
				error({"Bad post dominators", PostDoms, maps:fold(fun (El, {_, _}, Acc)
				-> case El =:= 2 of true -> Acc; _ -> array:set(El-1, 3, Acc) end end,
				element(1, element(6, element(3, DecState))),
				element(7, element(3, DecState)))}); _ -> true end;
		_ -> true end,
		CrossEdges = element(8, element(3, DecState)),
		%get_cross_edges(element(2, DecState), element(3, DecState)), 
		case cmp_edgeset(CrossEdges, get_cross_edges(element(2, DecState),
				element(3, DecState))) of false ->
			error({"Bad cross edge calculation", get_edgeset(CrossEdges),
				get_edgeset(get_cross_edges(element(2, DecState),
					element(3, DecState))), element(2, element(2, DecState))}); _ -> true
		end,
		case lists:filter(fun (Idx) ->
			case gb_sets:to_list(array:get(Idx-1, CrossEdges)) =/= [] of true -> io:format("~p~n", [{Idx, gb_sets:to_list(array:get(Idx-1, CrossEdges))}]), true; _ -> false end end 
			, lists:seq(1, array:size(CrossEdges))) of [] -> true;
		_ -> error({"Bad cross edges", get_edgeset(CrossEdges),
			element(2, element(2, DecState)),
			get_edgeset(element(2, element(3, DecState)))}) end; _ -> true end,
	%as for try-catch blocks, the merge nodes must be identified on return,
	%so their failure to resolve properly would need to be checked
	%in some other way prior to this
	ResData = fix_graph_tuples(resolve_graph_data(element(2, DecState),
		not lists:member(nosanitycheck, Opts))),
	NodeCount = array:size(element(1, element(3, DecState))),
	{ResAST, DepthList} = try {case lists:member(optimize, Opts) of true ->
		cleanup_ast(ResData, CleanAST, VarPrefix, element(7, DecState), Beam, lists:member(stubfuncs, Opts));
	_ -> min_cleanup_ast(ResData) end, get_ast_depth_agg(ResData)} catch _:_ -> {ResData, []} end,
	%get_ast_depth(ResAST),
	{MaxDepth, AggDepth} = lists:foldl(fun (El, {Lvl, Acc}) ->
		{Lvl + 1, Acc + (Lvl + 1) * El} end, {0, 0}, DepthList),
	#{0 := {Crs, CNodes, CEdges, CREdges}} = element(10, DecState),
	Stats = maps:remove(0, element(10, DecState)),
	{ResAST, Stats#{{element(2, Func),element(3, Func)} => {NodeCount,
		case element(7, element(3, DecState)) of #{2 := {RtSet,_}} -> gb_sets:size(RtSet); _ -> 0 end,
		lists:foldl(fun (El, Acc) ->
			Acc + gb_sets:size(get_succs(El, element(3, DecState))) end,
			0, lists:seq(1, NodeCount)),
		lists:foldl(fun (El, Acc) ->
			Acc + gb_sets:size(array:get(El-1, element(3, element(3, DecState)))) end,
			0, lists:seq(1, NodeCount)), Crs, CNodes, CEdges, CREdges, MaxDepth, AggDepth}}}
	%element(2, DecState)
	%pc/ip, x[1024], y[], fr[16]
.
dodecompileast(Func, Beam, CleanAST, Opts) ->
	dodecompileast(Func, "", [], Beam, CleanAST, [], Opts).

dodecompileast(File, Funcname, Arity, VarPrefix, Capts, CleanAST, Ctxt, Opts) ->
	Func = hd(lists:dropwhile(fun(Elem) -> element(2, Elem) =/= Funcname orelse
		element(3, Elem) =/= Arity end, element(6, File))),
	{AST, Stats} =
		dodecompileast(Func, VarPrefix, Capts, File, CleanAST, Ctxt, Opts),
	{hd(AST), Stats, get_func_stats(element(5, Func))}
.

decompileast(Filename, Funcname, Arity, Opts) ->
	File = try beam_disasm:file(Filename) catch _:_ ->
		io:format("Error Opening Module: " ++ Filename ++ "~n") end,
	if File =:= false -> {}; true -> Time = os:timestamp(),
	{AST, Stats, ErlStats} =
		dodecompileast(File, Funcname, Arity, "", [], get_ast_self(), [], Opts),
	{[{attribute,0,module,case lists:member(changemodname, Opts) of true -> list_to_atom(element(2, lists:keyfind(changemodname, 1, Opts))); _ -> element(2, File) end},
		{attribute,0,export,[{Funcname,Arity}]},
		AST,
		{eof,0}], Stats, ErlStats,
		timer:now_diff(os:timestamp(), Time)} end
.
decompile(Filename, Funcname, Arity, ErlFName, Opts) ->
	{AST, Stats, ErlStats, Timing} =
		decompileast(Filename, Funcname, Arity, case lists:member(changemodname, Opts) of true -> [{changemodname, filename:basename(ErlFName, ".erl")}|Opts]; _ -> Opts end),
	case lists:member(writeast, Opts) of true ->
		{ok, Fd} = file:open(filename:rootname(ErlFName) ++ ".ast", [write]),
  	io:fwrite(Fd, "~p~n", [AST]),
  	file:close(Fd); _ -> true end,
  ErrNext = [ast_to_erl(AST, ErlFName)],
  ErrAll = case lists:member(compile, Opts) of true ->
  	case compile:file(ErlFName, [{outdir, filename:dirname(ErlFName)},return]) of {error,Err,Warn} ->
  	[lists:flatten(io_lib:format("~p~n", [{ErlFName,Err,Warn}]))|ErrNext]; _ -> ErrNext end; _ -> ErrNext end,
  case ErrAll of [] -> true; _ ->
  	{ok, Efd} = file:open(filename:rootname(ErlFName) ++ ".err",[write, {encoding, utf8}]),
		io:fwrite(Efd, "~s", [lists:append(lists:reverse(ErrAll))]),
		file:close(Efd) end,
  {Stats, ErlStats, Timing}
.

decompile(Filename, ErlFName, Opts) ->
	%file:delete("temp/cur.err"),
	File = try beam_disasm:file(Filename) catch _:_ ->
		io:format("Error Opening Module: " ++ Filename ++ "~n"), false end,
	if File =:= false -> []; true ->
	io:format("Processing Module: " ++ Filename ++ "~n"),
	LoadFunc = lists:dropwhile(fun (Func) ->
		not lists:member(on_load, element(5, Func)) end, element(6, File)),
	{Funcs, Times, ErrMsgs} =
		lists:foldl(fun(Func, {F, T, E}) ->
			case element(2, Func) =:= module_info orelse %dash and slash characters
				lists:any(fun(Elem) -> Elem =:= 45 orelse Elem =:= 47 end,
			atom_to_list(element(2, Func))) of true -> {F, T, E}; _ ->
				io:format(" Function: " ++ atom_to_list(element(2, Func)) ++ "\/" ++
					integer_to_list(element(3, Func)) ++ "~n"), Time = os:timestamp(),
				try {AST, Stats} =
					dodecompileast(Func, File, get_ast_self(), Opts),
					{[hd(AST)|F], [{element(2, Func), element(3, Func), Stats,
						get_func_stats(element(5, Func)),
						timer:now_diff(os:timestamp(), Time)}|T], E}
				catch Y:Z -> ErrMsg = io_lib:format("~p~n",
					[{Filename, element(2, Func), element(3, Func),
						Y, Z, erlang:get_stacktrace()}]), FinErr = lists:flatten(ErrMsg),
					io:format("~s", [FinErr]),
					%{ok, Efd} = file:open("temp/cur.err",[append]),
					%io:fwrite(Efd, "~s", [FinErr]), file:close(Efd),
					{F, T, [FinErr|E]} end
 				end end, {[], [], []}, element(6, File)),
	ResState = [{attribute,0,module,case lists:member(changemodname, Opts) of true -> list_to_atom(filename:basename(ErlFName, ".erl")); _ -> element(2, File) end},
	{attribute,0,export,lists:filtermap(fun({A, B, _}) ->
	    if A =:= module_info -> false; true -> {true, {A, B}} end end,
	  element(3, File))}] ++
	  if LoadFunc =:= [] -> [];
	  true -> [{attribute,0,on_load,
	  	{element(2, hd(LoadFunc)),element(3, hd(LoadFunc))}}] end ++
	 	lists:reverse(Funcs) ++ [{eof,0}],
	{ok, Sfd} = file:open(filename:rootname(ErlFName) ++ ".stat", [write]),
  io:fwrite(Sfd, "~p~n", [lists:reverse(Times)]),
	file:close(Sfd),
	case lists:member(writeast, Opts) of true ->
		{ok, Fd} = file:open(filename:rootname(ErlFName) ++ ".ast", [write]),
  	io:fwrite(Fd, "~p~n", [ResState]),
  	file:close(Fd); _ -> true end,
  ErrNext = case ast_to_erl(ResState, ErlFName) of [] -> ErrMsgs; Er -> [Er|ErrMsgs] end, 
  ErrAll = case lists:member(compile, Opts) of true ->
  	case compile:file(ErlFName, [{outdir, filename:dirname(ErlFName)},return]) of {error,Err,Warn} ->
  	[lists:flatten(io_lib:format("~p~n", [{ErlFName,Err,Warn}]))|ErrNext]; _ -> ErrNext end; _ -> ErrNext end,
  case ErrAll of [] -> file:delete(filename:rootname(ErlFName) ++ ".err"); _ ->
  	{ok, Efd} = file:open(filename:rootname(ErlFName) ++ ".err",[write, {encoding, utf8}]),
		io:fwrite(Efd, "~s", [lists:append(lists:reverse(ErrAll))]),
		file:close(Efd) end,
	Times end
.