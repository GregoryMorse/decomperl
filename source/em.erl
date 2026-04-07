-module(emulator).

-export([testerlangbifs/0, testfloatarith/0,
	 testintarith/0, testbitarith/0, testbool/0,
	 testcomparison/0, testbranchcomp/0, testtypecomp/0,
	 testtypebranchcomp/0, testlist/0, testtuple/0,
	 testbinary/0, testprivbinary/0, testmap/0, testfun/0,
	 testnamedfun/0, testfuncerr/0, testcalls/0,
	 testerrors/0, testall/0, testsend/0, testreceivesleep/0,
	 testreceiveselective/0, testreceiveall/0,
	 testreceiveselectiveafter/0, testreceiveallafter/0,
	 testcatch/0, testcatchcatch/0, testtrycatch/0,
	 testtrytrycatch/0, testtryerrcatch/0, testtrycatcherr/0,
	 testtryerrcatcherr/0, testtryafter/0,
	 testtrycatchstack/0, testcatchseq/0,
	 testcatchcatchseq/0, testtrycatchseq/0,
	 testtryerrcatchseq/0, testtrycatcherrseq/0,
	 testtryerrcatcherrseq/0, testtryafterseq/0,
	 testtrycatchstackseq/0, testtrycatchrecrs/0,
	 testtrycatchrecrsseq/0, testtrycatchmulti/0, testbase/3,
	 testdef/1, testerr/2, testandalso/4, testorelse/4,
	 testandalso2/5, testorelse2/5, testandalsoorelse/5,
	 testorelseandalso/5, testandalsoorelse2/5,
	 testorelseandalso2/5, testdefandalso/2, testdeforelse/2,
	 testdefandalso2/3, testdeforelse2/3,
	 testdefandalsoorelse/3, testdefandalsoorelse2/3,
	 testdeforelseandalso/3, testdeforelseandalso2/3,
	 testerrandalso/3, testerrorelse/3, testerrandalso2/4,
	 testerrorelse2/4, testerrandalsoorelse/4,
	 testerrandalsoorelse2/4, testerrorelseandalso/4,
	 testerrorelseandalso2/4, testseqbase/3, testseqdef/2,
	 testseqandalso/4, testseqorelse/4, testseqandalso2/5,
	 testseqorelse2/5, testseqandalsoorelse/5,
	 testseqorelseandalso/5, testseqandalsoorelse2/5,
	 testseqorelseandalso2/5, testseqdefandalso/2,
	 testseqdeforelse/2, testseqdefandalso2/3,
	 testseqdeforelse2/3, testseqdefandalsoorelse/3,
	 testseqdefandalsoorelse2/3, testseqdeforelseandalso/3,
	 testseqdeforelseandalso2/3, bug_step/4,
	 pd_emu_receive/3, pd_emu_receive/1, sleep/1,
	 optimized/1, testdecomp/0, testdecomp2/0, testdecomp3/0,
	 check_decompileast/3, test_sem_equiv/0,
	 do_get_dfs_parent/3, do_dfs_parent/3,
	 do_tarjan_immdom/3, do_dfs/2, check_pred_succ/2,
	 has_float/3, get_float/3, has_utf8/1, get_utf8/1,
	 has_utf16/2, get_utf16/2, has_utf32/2, get_utf32/2,
	 skip_bits/2, get_bits/2, get_integer/4, 'receive'/1,
	 'receive'/3, disassemble/2, emulate/3, emulate/4,
	 getmem/2, transform/2, getabstractsyntax/2,
	 get_clean_ast/3, decompileast/2, decompile/2,
	 decompileast/4, decompile/4]).

-on_load({load_func, 0}).

load_func() -> erlang:display("loaded"), ok.

testerlangbifs() ->
    [size(date()) =:= 3, get() =:= [],
     get("test") =:= undefined, get_keys() =:= [],
     is_pid(group_leader()), is_reference(make_ref()),
     is_atom(node()), is_list(nodes()),
     is_list(pre_loaded()), is_list(processes()),
     is_list(registered()), is_pid(self()),
     size(time()) =:= 3].

testfloatarith() ->
    fun (A, B, C, D, E) -> (1.0 + A + B - C) * D / E
    end(2.5, 3.5, 3.0, -4.5, 2.9999999999999999e-1)
      =:= -6.0e+1.

testintarith() ->
    fun (A, B, C, D, E, F) -> (A + B - C) * D div E rem F
    end(10, 2, 3, 4, 6, 4)
      =:= 2.

testbitarith() ->
    fun (A, B, C, D, E, F) ->
	    bnot (A band B bor C bxor D bsl E bsr F)
    end(7, 15, 32, 96, 3, 4)
      =:= -36.

testbool() ->
    fun (A, B, C, D) ->
	    not (A and B or C xor is_boolean(D)) andalso
	      (A orelse B)
    end(true, false, true, true).

testcomparison() ->
    Fun = fun (A, B, C, D, E, F, G, H, I) ->
		  (((((((A < B) >= C) > D) =< E) == F) /= G) =:= H) =/= I
	  end,
    Fun(1, 2, [], true, 0, false, true, true, false) =:=
      false.

testbranchcomp() ->
    Fun = fun (A, B, C, D, E, F, G, H, I) ->
		  if A < B andalso
		       B >= C andalso
			 C > D andalso
			   D =< E andalso
			     E == F andalso
			       F /= G andalso G =:= H andalso H =:= I ->
			 true;
		     true -> false
		  end
	  end,
    Fun(1, 2, [], true, 0, false, true, true, false) =:=
      false.

testtypecomp() ->
    Fun = fun ({A, B, C, D, E, F, G, H, I, J, K}) ->
		  is_integer(A) and is_float(B) and is_number(A) and
		    is_number(B)
		    and is_atom(C)
		    and is_boolean(C)
		    and is_pid(D)
		    and is_reference(E)
		    and is_port(F)
		    and (([] = G) =:= [])
		    and is_binary(H)
		    and is_bitstring(H)
		    and is_list(I)
		    and (([_ | _] = I) =/= [])
		    and is_tuple(J)
		    and (size({3, 4.0} = J) =:= 2)
		    and is_function(K)
		    and is_function(K, 1)
	  end,
    Fun({3, 4.0, false, self(), make_ref(),
	 open_port({spawn, "cmd"}, [{packet, 2}]), [],
	 <<"test">>, [3, 4, 5], {3, 4.0}, Fun}).

testtypebranchcomp() ->
    Fun = fun ({A, B, C, D, E, F, G, H, I, J, K}) ->
		  [] = G,
		  [_ | _] = I,
		  {3, 4.0} = J,
		  if is_integer(A) and is_float(B) and is_number(A) and
		       is_number(B)
		       and is_atom(C)
		       and is_boolean(C)
		       and is_pid(D)
		       and is_reference(E)
		       and is_port(F)
		       and (G =:= [])
		       and is_binary(H)
		       and is_bitstring(H)
		       and is_list(I)
		       and (I =/= [])
		       and is_tuple(J)
		       and (size(J) =:= 2)
		       and is_function(K)
		       and is_function(K, 1) ->
			 true;
		     true -> false
		  end
	  end,
    Fun({3, 4.0, false, self(), make_ref(),
	 open_port({spawn, "cmd"}, [{packet, 2}]), [],
	 <<"test">>, [3, 4, 5], {3, 4.0}, Fun}).

testlist() ->
    Fun = fun (List) ->
		  A = hd(List) + hd(tl(List)),
		  [H | T] = List,
		  [A =:= H + hd(T)]
	  end,
    Fun([3, 4, 5, [], true, false]) =:= [true].

testall() ->
    [testerlangbifs(), testfloatarith(), testintarith(),
     testbitarith(), testbool(), testcomparison(),
     testbranchcomp(), testtypecomp(), testtypebranchcomp(),
     testlist(), testtuple(), testbinary(), testprivbinary(),
     testmap(), testsend() =:= msg].

-record(testrec, {test1, test2, test3, test4, test5}).

testtuple() ->
    Fun = fun ({Tuple, Other}) ->
		  A = element(1, Tuple),
		  {A, B} = Tuple,
		  {A =:= B, setelement(1, Tuple, B),
		   Other#testrec{test1 = 1, test3 = 2}}
	  end,
    Fun({{3, 4},
	 #testrec{test1 = 0, test2 = 1, test3 = 1, test4 = 3,
		  test5 = 4}})
      =:= {false, {4, 4}, {testrec, 1, 1, 2, 3, 4}}.

testbinary() ->
    Fun = fun (A) ->
		  B = <<A/signed-native>>,
		  C = <<4.0:64/float-unit:1>>,
		  D = <<A/utf16-little>>,
		  Dd = <<A/utf16-big>>,
		  E = <<A/utf8>>,
		  F = <<A/utf32-little>>,
		  G = <<A/utf32-big>>,
		  <<_H, _T/binary>> = <<B/binary, C/binary, D/binary,
					Dd/binary, E/binary, F/binary, G/binary,
					0, 1, 2>>
	  end,
    A = Fun(4),
    <<T0/integer, S0/integer, T1/float, S1/float, T2/utf8,
      S2/utf8, T3/utf16, S3/utf16, _:8/integer-unit:4,
      T4/utf32-little, S4/utf32, T5/binary>> =
	<<A/binary, A/binary>>,
    erlang:display({T0, S0, T1, S1, T2, S2, T3, S3, T4, S4,
		    T5, A}),
    {[16257, 1], <<0>>} = inc_on_ones(<<255, 1, 128, 1, 128,
					0>>,
				      0, [], 5),
    T6 = <<1:1>>,
    <<0:8, 4:8, _:8/integer-unit:1, 4:8, 0:8,
      T7/bitstring>> =
	T6,
    <<T9:1, _/bitstring>> = T7,
    <<_T8:1, _:1>> = <<T6/bitstring, T6/bitstring>>,
    C2 = is_bitstring(A),
    is_bitstring(A) andalso
      C2 andalso
	case T9 of
	  <<1:1, X1:7, X2/binary>> ->
	      X1 =:= 2 andalso X2 =:= <<2>>;
	  <<X1, X2/binary>> -> X1 =:= 1 andalso X2 =:= <<2>>;
	  _ -> false
	end
	  andalso
	  T9 =:= 0 andalso
	    Fun(3) =:=
	      <<T0, T1/float, T2, T3, T4, T5/binary, T6/bitstring,
		T9/bitstring, 0, 1, 2>>.

inc_on_ones(Buffer, _Av, Al, 0) ->
    {lists:reverse(Al), Buffer};
inc_on_ones(<<1:1, H:7, T/binary>>, Av, Al, Len) ->
    inc_on_ones(T, Av bsl 7 bor H, Al, Len - 1);
inc_on_ones(<<H, T/binary>>, Av, Al, Len) ->
    inc_on_ones(T, 0, [Av bsl 7 bor H | Al], Len - 1).

testprivbinary() ->
    Fun = fun (Input) ->
		  << <<0, 1, 2, Bin:42>>  || <<Bin:42>> <= Input >>
	  end,
    Fun(<<8:42, 9:42, 10:42, 11:42>>) =:=
      <<0, 1, 2, <<8:42>>/bitstring, 0, 1, 2,
	<<9:42>>/bitstring, 0, 1, 2, <<10:42>>/bitstring, 0, 1,
	2, <<11:42>>/bitstring>>.

testmap() ->
    Fun = fun () ->
		  _M = #{a => 2, b => 3, c => 4, "a" => 1, "b" => 2,
			 "c" => 4}
	  end,
    X = Fun(),
    #{b := Y} = X,
    Z = X#{b := 8, c := 10},
    Z2 = X#{c => 10, b => 8},
    T = maps:is_key(a, #{a := _} = Z),
    Y2 = maps:get(b, X),
    erlang:display({Z, Z2, X, Y, Y2, T}),
    if is_map(Z) andalso
	 map_size(X) =:= 6 andalso Y =:= Y2 andalso T ->
	   Z2 =:= Z;
       true -> false
    end.

testfun() ->
    Fun = fun (A) -> C = A + 3, fun (B) -> A + B + C end
	  end,
    (Fun(3))(4) =:= 13.

testnamedfun() ->
    fun MyFun(A) ->
	    if A =:= 0 -> A;
	       true -> MyFun(A - 1)
	    end
    end(12).

testfuncerr() ->
    erlang:display({catch fun (A) when is_integer(A) -> A
			  end(4.0),
		    catch fun (A) ->
				  case is_integer(A) of
				    true -> A;
				    _ -> error(function_clause, [A])
				  end
			  end(4.0)}),
    case catch fun (A) when is_integer(A) -> A end(4.0) of
      {'EXIT', {function_clause, [_ | _]}} -> true;
      _ -> false
    end.

testsend() -> self() ! msg.

testcalls() ->
    Fun = fun (Mod, Func) ->
		  apply(Mod, Func, [1, [3]]) +
		    erlang:apply(Mod, Func, [1, [4]])
	  end,
    lists:nth(1, [3]) =:= 3 andalso Fun(lists, nth) =:= 7.

sleep(T) -> receive  after T -> ok end.

optimized(Pid) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, hello},
    receive {Pid, Ref, Msg} -> io:format("~p~n", [Msg]) end.

testerrors() ->
    FunIf = fun (A) ->
		    try if A =:= 1 -> true end of
		      true -> false
		    catch
		      Class:Reason ->
			  erlang:display({Class, Reason}),
			  Class =:= error andalso Reason =:= if_clause
		    end
	    end,
    FunCatch = fun () -> catch erlang:error(if_clause) end,
    erlang:display(FunCatch()),
    Ln = 137,
    FunAfter = fun (A) ->
		       try try A = 1 of _ -> false after 3 end of
			 _ -> false
		       catch
			 Class:Reason ->
			     erlang:display({Class, Reason}),
			     Class =:= error andalso Reason =:= {badmatch, 1}
		       end
	       end,
    FunThrowAfter = fun (A) ->
			    try try throw(A) of _ -> false after 3 end of
			      _ -> false
			    catch
			      Class:Reason ->
				  erlang:display({Class, Reason}),
				  Class =:= throw andalso Reason =:= A
			    end
		    end,
    FunCase = fun (A) ->
		      try case A of 1 -> true end of
			true -> false
		      catch
			Class:Reason ->
			    erlang:display({Class, Reason}),
			    Class =:= error andalso Reason =:= {case_clause, A}
		      end
	      end,
    FunTry = fun (A) ->
		     try try A of 1 -> false catch _ -> true end catch
		       Class:Reason ->
			   erlang:display({Class, Reason}),
			   Class =:= error andalso Reason =:= {try_clause, A}
		     end
	     end,
    FunMatch = fun (A) ->
		       try A = 1 of
			 _ -> false
		       catch
			 Class:Reason ->
			     erlang:display({Class, Reason}),
			     Class =:= error andalso Reason =:= {badmatch, 1}
		       end
	       end,
    FunClause = fun (A) ->
			FunInner = fun (B) when B =:= 1 -> B end,
			try FunInner(A) of
			  _ -> false
			catch
			  Class:Reason ->
			      erlang:display({Class, Reason}),
			      Class =:= error andalso Reason =:= function_clause
			end
		end,
    FunBadArg = fun (A) ->
			try length(A) catch
			  Class:Reason ->
			      erlang:display({Class, Reason}),
			      Class =:= error andalso Reason =:= badarg
			end
		end,
    FunBadArith = fun (A) ->
			  try A + 1 catch
			    Class:Reason ->
				erlang:display({Class, Reason}),
				Class =:= error andalso Reason =:= badarith
			  end
		  end,
    FunBadFun = fun (A) ->
			try A() catch
			  Class:Reason ->
			      erlang:display({Class, Reason}),
			      Class =:= error andalso Reason =:= {badfun, A}
			end
		end,
    FunBadArity = fun (A) ->
			  try A() catch
			    Class:Reason ->
				erlang:display({Class, Reason}),
				Class =:= error andalso
				  Reason =:= {badarity, {A, []}}
			  end
		  end,
    [FunIf(0), FunIf(1) =:= false,
     FunCatch() =:=
       {'EXIT',
	{if_clause,
	 [{emulator, '-testerrors/0-fun-1-', 0,
	   [{file, "emulator.erl"}, {line, Ln}]},
	  {emulator, testerrors, 0,
	   [{file, "emulator.erl"}, {line, 149}]},
	  {erl_eval, do_apply, 6,
	   [{file, "erl_eval.erl"}, {line, 674}]},
	  {shell, exprs, 7, [{file, "shell.erl"}, {line, 687}]},
	  {shell, eval_exprs, 7,
	   [{file, "shell.erl"}, {line, 642}]},
	  {shell, eval_loop, 3,
	   [{file, "shell.erl"}, {line, 627}]}]}},
     FunThrowAfter(0), FunAfter(0), FunAfter(1) =:= false,
     FunCase(0), FunCase(1) =:= false, FunTry(0),
     FunTry(1) =:= false, FunMatch(0), FunMatch(1) =:= false,
     FunClause(0), FunClause(1) =:= false, FunBadArg({}),
     FunBadArith({}), FunBadFun({}),
     FunBadArity(fun (A) -> A end)].

testreceive() ->
    A = make_ref(),
    self() ! A,
    try receive A -> throw([]) after 1 -> 1 end of
      _ -> 0
    catch
      _ -> 2
    end.

testreceivesleep() -> receive  after 1 -> 2 end.

testreceiveselective() ->
    receive
      abc -> erlang:display(abc);
      def -> erlang:display(def)
    end.

testreceiveall() -> receive _ -> 1 end.

testreceiveselectiveafter() ->
    receive
      abc -> erlang:display(abc);
      def -> erlang:display(def)
      after 2 -> 3
    end.

testreceiveallafter() ->
    receive _ -> 1 after 2 -> 3 end.

testcatchcatch() ->
    catch (catch fun (A, B) -> A / B end(5, 0)).

testcatchcatchseq() ->
    catch (catch fun (A, B) -> A / B end(5, 0) + 7).

testcatch() -> catch fun (A, B) -> A / B end(5, 0).

testcatchseq() ->
    catch fun (A, B) -> A / B end(5, 0) + 7.

testtrytrycatch() ->
    try try fun (A, B) -> A / B end(5, 0) of
	  X -> X
	catch
	  X:Y -> Y
	end
    of
      XI -> XI
    catch
      XI:YI -> YI
    end.

testtrycatch() ->
    try fun (A, B) -> A / B end(5, 0) of
      X -> X
    catch
      X:Y -> Y
    end.

testtrycatchrecrs() ->
    try fun (A, B) -> A / B end(5, 0) of
      X ->
	  try fun (A, B) -> A / B end(5, 0) of
	    XI -> XI
	  catch
	    XI:YI -> YI
	  end
    catch
      X:Y -> Y
    end.

testtrycatchrecrsseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X ->
	  try fun (A, B) -> A / B end(5, 0) of
	    XI -> XI
	  catch
	    XI:YI -> YI
	  end
    catch
      X:Y -> Y
    end
      + 7.

testtrycatchmulti() ->
    try fun (A, B) -> A / B end(5, 0) of
      test -> 1;
      X -> X
    catch
      a:b -> a;
      X:Y -> Y
    end.

testtrycatchseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X -> X
    catch
      X:Y -> Y
    end
      + 7.

testtryerrcatch() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      X:Y -> Y
    end.

testtryerrcatchseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      X:Y -> Y
    end
      + 7.

testtrycatcherr() ->
    try fun (A, B) -> A / B end(5, 0) of
      X -> X
    catch
      test -> test
    end.

testtrycatcherrseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X -> X
    catch
      test -> test
    end
      + 7.

testtryerrcatcherr() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      test -> test
    end.

testtryerrcatcherrseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      test -> test
    end
      + 7.

testtryafter() -> try 5 + 3 of 8 -> 8 after 3 end.

testtryafterseq() ->
    try 5 + 3 of 8 -> 8 after 3 end + 7.

testtrycatchstack() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      X:Y ->
	  Z = erlang:get_stacktrace(), erlang:display({X, Y, Z})
    after
      3
    end.

testtrycatchstackseq() ->
    try fun (A, B) -> A / B end(5, 0) of
      X when is_integer(X) -> X
    catch
      X:Y ->
	  Z = erlang:get_stacktrace(), erlang:display({X, Y, Z})
    after
      3
    end
      + 7.

testbase(A, B, C) ->
    if A -> B;
       true -> C
    end.

testdef(A) ->
    if A -> not A;
       true -> A
    end.

testerr(A, B) -> if A -> B end.

testandalso(A, B, C, D) ->
    if A andalso B -> C;
       true -> D
    end.

testorelse(A, B, C, D) ->
    if A orelse B -> C;
       true -> D
    end.

testandalso2(A, B, C, D, E) ->
    if A andalso B andalso C -> D;
       true -> E
    end.

testandalsoorelse(A, B, C, D, E) ->
    if A andalso B orelse C -> D;
       true -> E
    end.

testandalsoorelse2(A, B, C, D, E) ->
    if A andalso (B orelse C) -> D;
       true -> E
    end.

testorelse2(A, B, C, D, E) ->
    if A orelse B orelse C -> D;
       true -> E
    end.

testorelseandalso(A, B, C, D, E) ->
    if A orelse B andalso C -> D;
       true -> E
    end.

testorelseandalso2(A, B, C, D, E) ->
    if (A orelse B) andalso C -> D;
       true -> E
    end.

testdefandalso(A, B) ->
    if A andalso B -> not A;
       true -> A
    end.

testdeforelse(A, B) ->
    if A orelse B -> not A;
       true -> A
    end.

testdefandalso2(A, B, C) ->
    if A andalso B andalso C -> not A;
       true -> A
    end.

testdefandalsoorelse(A, B, C) ->
    if A andalso B orelse C -> not A;
       true -> A
    end.

testdefandalsoorelse2(A, B, C) ->
    if A andalso (B orelse C) -> not A;
       true -> A
    end.

testdeforelse2(A, B, C) ->
    if A orelse B orelse C -> not A;
       true -> A
    end.

testdeforelseandalso(A, B, C) ->
    if A orelse B andalso C -> not A;
       true -> A
    end.

testdeforelseandalso2(A, B, C) ->
    if (A orelse B) andalso C -> not A;
       true -> A
    end.

testerrandalso(A, B, C) -> if A andalso B -> C end.

testerrorelse(A, B, C) -> if A orelse B -> C end.

testerrandalso2(A, B, C, D) ->
    if A andalso B andalso C -> D end.

testerrandalsoorelse(A, B, C, D) ->
    if A andalso B orelse C -> D end.

testerrandalsoorelse2(A, B, C, D) ->
    if A andalso (B orelse C) -> D end.

testerrorelse2(A, B, C, D) ->
    if A orelse B orelse C -> D end.

testerrorelseandalso(A, B, C, D) ->
    if A orelse B andalso C -> D end.

testerrorelseandalso2(A, B, C, D) ->
    if (A orelse B) andalso C -> D end.

testseqbase(A, B, C) ->
    if A -> B;
       true -> C
    end
      and B.

testseqdef(A, B) ->
    if A -> not A;
       true -> A
    end
      and B.

testseqandalso(A, B, C, D) ->
    if A andalso B -> C;
       true -> D
    end
      and B.

testseqorelse(A, B, C, D) ->
    if A orelse B -> C;
       true -> D
    end
      and B.

testseqandalso2(A, B, C, D, E) ->
    if A andalso B andalso C -> D;
       true -> E
    end
      and B.

testseqandalsoorelse(A, B, C, D, E) ->
    if A andalso B orelse C -> D;
       true -> E
    end
      and B.

testseqandalsoorelse2(A, B, C, D, E) ->
    if A andalso (B orelse C) -> D;
       true -> E
    end
      and B.

testseqorelse2(A, B, C, D, E) ->
    if A orelse B orelse C -> D;
       true -> E
    end
      and B.

testseqorelseandalso(A, B, C, D, E) ->
    if A orelse B andalso C -> D;
       true -> E
    end
      and B.

testseqorelseandalso2(A, B, C, D, E) ->
    if (A orelse B) andalso C -> D;
       true -> E
    end
      and B.

testseqdefandalso(A, B) ->
    if A andalso B -> not A;
       true -> A
    end
      and B.

testseqdeforelse(A, B) ->
    if A orelse B -> not A;
       true -> A
    end
      and B.

testseqdefandalso2(A, B, C) ->
    if A andalso B andalso C -> not A;
       true -> A
    end
      and B.

testseqdefandalsoorelse(A, B, C) ->
    if A andalso B orelse C -> not A;
       true -> A
    end
      and B.

testseqdefandalsoorelse2(A, B, C) ->
    if A andalso (B orelse C) -> not A;
       true -> A
    end
      and B.

testseqdeforelse2(A, B, C) ->
    if A orelse B orelse C -> not A;
       true -> A
    end
      and B.

testseqdeforelseandalso(A, B, C) ->
    if A orelse B andalso C -> not A;
       true -> A
    end
      and B.

testseqdeforelseandalso2(A, B, C) ->
    if (A orelse B) andalso C -> not A;
       true -> A
    end
      and B.

testdecomp() ->
    [check_decompileast("emulator", testbase, 3),
     check_decompileast("emulator", testdef, 1),
     check_decompileast("emulator", testerr, 2),
     check_decompileast("emulator", testandalso, 4),
     check_decompileast("emulator", testorelse, 4),
     check_decompileast("emulator", testandalso2, 5),
     check_decompileast("emulator", testandalsoorelse, 5),
     check_decompileast("emulator", testandalsoorelse2, 5),
     check_decompileast("emulator", testorelse2, 5),
     check_decompileast("emulator", testorelseandalso, 5),
     check_decompileast("emulator", testorelseandalso2, 5),
     check_decompileast("emulator", testdefandalso, 2),
     check_decompileast("emulator", testdeforelse, 2),
     check_decompileast("emulator", testdefandalso2, 3),
     check_decompileast("emulator", testdefandalsoorelse, 3),
     check_decompileast("emulator", testdefandalsoorelse2,
			3),
     check_decompileast("emulator", testdeforelse2, 3),
     check_decompileast("emulator", testdeforelseandalso, 3),
     check_decompileast("emulator", testdeforelseandalso2,
			3),
     check_decompileast("emulator", testerrandalso, 3),
     check_decompileast("emulator", testerrorelse, 3),
     check_decompileast("emulator", testerrandalso2, 4),
     check_decompileast("emulator", testerrandalsoorelse, 4),
     check_decompileast("emulator", testerrandalsoorelse2,
			4),
     check_decompileast("emulator", testerrorelse2, 4),
     check_decompileast("emulator", testerrorelseandalso, 4),
     check_decompileast("emulator", testerrorelseandalso2,
			4)].

testdecomp2() ->
    [check_decompileast("emulator", testseqbase, 3),
     check_decompileast("emulator", testseqdef, 2),
     check_decompileast("emulator", testseqandalso, 4),
     check_decompileast("emulator", testseqorelse, 4),
     check_decompileast("emulator", testseqandalso2, 5),
     check_decompileast("emulator", testseqandalsoorelse, 5),
     check_decompileast("emulator", testseqandalsoorelse2,
			5),
     check_decompileast("emulator", testseqorelse2, 5),
     check_decompileast("emulator", testseqorelseandalso, 5),
     check_decompileast("emulator", testseqorelseandalso2,
			5),
     check_decompileast("emulator", testseqdefandalso, 2),
     check_decompileast("emulator", testseqdeforelse, 2),
     check_decompileast("emulator", testseqdefandalso2, 3),
     check_decompileast("emulator", testseqdefandalsoorelse,
			3),
     check_decompileast("emulator", testseqdefandalsoorelse2,
			3),
     check_decompileast("emulator", testseqdeforelse2, 3),
     check_decompileast("emulator", testseqdeforelseandalso,
			3),
     check_decompileast("emulator", testseqdeforelseandalso2,
			3)].

testdecomp3() ->
    [check_decompileast("emulator", testerlangbifs, 0),
     check_decompileast("emulator", testfloatarith, 0),
     check_decompileast("emulator", testintarith, 0),
     check_decompileast("emulator", testbitarith, 0),
     check_decompileast("emulator", testbool, 0),
     check_decompileast("emulator", testcomparison, 0),
     check_decompileast("emulator", testbranchcomp, 0),
     check_decompileast("emulator", testtypecomp, 0),
     check_decompileast("emulator", testtypebranchcomp, 0),
     check_decompileast("emulator", testlist, 0),
     check_decompileast("emulator", testmap, 0),
     check_decompileast("emulator", testtuple, 0),
     check_decompileast("emulator", testsend, 0),
     check_decompileast("emulator", testcalls, 0)].

pd_emu_receive(Fr) ->
    Msgs = get(messages),
    {Result, MQ} = emu_receive(Fr,
			       if Msgs =:= undefined -> [];
				  true -> Msgs
			       end),
    put(messages, MQ),
    Result.

pd_emu_receive(Fr, A, Fa) ->
    Msgs = get(messages),
    {Result, MQ} = emu_receive(Fr, A, Fa,
			       if Msgs =:= undefined -> [];
				  true -> Msgs
			       end),
    put(messages, MQ),
    Result.

emu_receive_msg(_, _, []) -> false;
emu_receive_msg(Fr, Pre, [H | T]) ->
    Y = Fr(H),
    if is_tuple(Y) andalso element(1, Y) =:= true ->
	   {element(2, Y), Pre ++ T};
       true -> emu_receive_msg(Fr, Pre ++ H, T)
    end.

emu_receive(Fr, MQ) ->
    emu_receive(Fr, infinity, [], MQ).

emu_receive(Fr, infinity, _, MQ) ->
    Y = emu_receive_msg(Fr, [], MQ),
    if is_tuple(Y) -> Y;
       true -> emu_receive(Fr, infinity, [], 0, MQ)
    end;
emu_receive(Fr, A, Fa, MQ) ->
    Start = os:system_time(millisecond),
    Y = emu_receive_msg(Fr, [], MQ),
    if is_tuple(Y) -> Y;
       true -> emu_receive(Fr, A, Fa, Start, MQ)
    end.

emu_receive(Fr, infinity, _, _, MQ) ->
    receive
      X ->
	  Y = Fr(X),
	  if is_tuple(Y) andalso element(1, Y) =:= true ->
		 {element(2, Y), MQ};
	     true -> emu_receive(Fr, infinity, [], 0, MQ ++ [X])
	  end
    end;
emu_receive(Fr, A, Fa, Start, MQ) ->
    Now = os:system_time(millisecond),
    if A =< Now - Start -> Fa();
       true ->
	   receive
	     X ->
		 Y = Fr(X),
		 if is_tuple(Y) andalso element(1, Y) =:= true ->
			{element(2, Y), MQ};
		    true -> emu_receive(Fr, A, Fa, Start, MQ ++ [X])
		 end
	     after A - (Now - Start) -> {Fa(), MQ}
	   end
    end.

transform(BeamFName, ErlFName) ->
    case beam_lib:chunks(BeamFName, [abstract_code]) of
      {ok,
       {_, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
	  Src =
	      erl_prettypr:format(erl_syntax:form_list(tl(Forms))),
	  {ok, Fd} = file:open(ErlFName, [write]),
	  io:fwrite(Fd, "~s~n", [Src]),
	  file:close(Fd);
      Error -> Error
    end.

getabstractsyntax(BeamFName, ErlFName) ->
    case beam_lib:chunks(BeamFName, [abstract_code]) of
      {ok,
       {_, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
	  Src = lists:map(fun clean_ast_linenums/1, tl(Forms)),
	  {ok, Fd} = file:open(ErlFName, [write]),
	  io:fwrite(Fd, "~p~n", [Src]),
	  file:close(Fd);
      Error -> Error
    end.

traverse_ast(Fun, Acc, AST) ->
    NewAST = case AST of
	       {var, L, A} -> NewAcc = Acc, {var, L, A};
	       {char, L, A} -> NewAcc = Acc, {char, L, A};
	       {integer, L, A} -> NewAcc = Acc, {integer, L, A};
	       {float, L, A} -> NewAcc = Acc, {float, L, A};
	       {atom, L, A} -> NewAcc = Acc, {atom, L, A};
	       {string, L, A} -> NewAcc = Acc, {string, L, A};
	       {nil, L} -> NewAcc = Acc, {nil, L};
	       {cons, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {cons, L, NewA, NewB};
	       {lc, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, B),
		   {lc, L, NewA, NewB};
	       {bc, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, B),
		   {bc, L, NewA, NewB};
	       {generate, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {generate, L, NewA, NewB};
	       {b_generate, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {b_generate, L, NewA, NewB};
	       {tuple, L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {tuple, L, NewA};
	       {record_field, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {record_field, L, NewA, NewB};
	       {record, L, A, B} ->
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, B),
		   {record, L, A, NewB};
	       {record, L, A, B, C} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewC, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, C),
		   {record, L, NewA, B, NewC};
	       {map, L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {map, L, NewA};
	       {map, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, B),
		   {map, L, NewA, NewB};
	       {map_field_assoc, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {map_field_assoc, L, NewA, NewB};
	       {map_field_exact, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {map_field_exact, L, NewA, NewB};
	       {block, L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {block, L, NewA};
	       {'if', L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {'if', L, NewA};
	       {'case', L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, B),
		   {'case', L, NewA, NewB};
	       {'try', L, A, B, C, D} ->
		   {NewA, Acc1} = lists:foldl(fun (Elem, {List, Ac}) ->
						      {NewElem, TAc} =
							  traverse_ast(Fun, Ac,
								       Elem),
						      {List ++ [NewElem], TAc}
					      end,
					      {[], Acc}, A),
		   {NewB, Acc2} = lists:foldl(fun (Elem, {List, Ac}) ->
						      {NewElem, TAc} =
							  traverse_ast(Fun, Ac,
								       Elem),
						      {List ++ [NewElem], TAc}
					      end,
					      {[], Acc1}, B),
		   {NewC, Acc3} = lists:foldl(fun (Elem, {List, Ac}) ->
						      {NewElem, TAc} =
							  traverse_ast(Fun, Ac,
								       Elem),
						      {List ++ [NewElem], TAc}
					      end,
					      {[], Acc2}, C),
		   {NewD, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc3}, D),
		   {'try', L, NewA, NewB, NewC, NewD};
	       {'receive', L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {'receive', L, NewA};
	       {'receive', L, A, B, C} ->
		   {NewA, Acc1} = lists:foldl(fun (Elem, {List, Ac}) ->
						      {NewElem, TAc} =
							  traverse_ast(Fun, Ac,
								       Elem),
						      {List ++ [NewElem], TAc}
					      end,
					      {[], Acc}, A),
		   {NewB, Acc2} = traverse_ast(Fun, Acc1, B),
		   {NewC, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc2}, C),
		   {'receive', L, NewA, NewB, NewC};
	       {'fun', L, {clauses, A}} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {'fun', L, {clauses, NewA}};
	       {'fun', L, {function, A, B}} ->
		   NewAcc = Acc, {'fun', L, {function, A, B}};
	       {named_fun, L, A, B} ->
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, B),
		   {named_fun, L, A, NewB};
	       {call, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc1}, B),
		   {call, L, NewA, NewB};
	       {'catch', L, A} ->
		   {NewA, NewAcc} = traverse_ast(Fun, Acc, A),
		   {'catch', L, NewA};
	       {match, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {match, L, NewA, NewB};
	       {op, L, A, B} ->
		   {NewB, NewAcc} = traverse_ast(Fun, Acc, B),
		   {op, L, A, NewB};
	       {op, L, A, B, C} ->
		   {NewB, Acc1} = traverse_ast(Fun, Acc, B),
		   {NewC, NewAcc} = traverse_ast(Fun, Acc1, C),
		   {op, L, A, NewB, NewC};
	       {bin, L, A} ->
		   {NewA, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, A),
		   {bin, L, NewA};
	       {bin_element, L, A, B, C} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = if B =:= default -> {B, Acc1};
				       true -> traverse_ast(Fun, Acc1, B)
				    end,
		   {bin_element, L, NewA, NewB, C};
	       {remote, L, A, B} ->
		   {NewA, Acc1} = traverse_ast(Fun, Acc, A),
		   {NewB, NewAcc} = traverse_ast(Fun, Acc1, B),
		   {remote, L, NewA, NewB};
	       {clause, L, A, B, C} ->
		   {NewA, Acc1} = lists:foldl(fun (Elem, {List, Ac}) ->
						      {NewElem, TAc} =
							  traverse_ast(Fun, Ac,
								       Elem),
						      {List ++ [NewElem], TAc}
					      end,
					      {[], Acc}, A),
		   {NewB, Acc2} = lists:foldl(fun (Elem, {Lt, Accu}) ->
						      {NewEl, NewAccu} =
							  lists:foldl(fun (El,
									   {List,
									    Ac}) ->
									      {NewElem,
									       TAc} =
										  traverse_ast(Fun,
											       Ac,
											       El),
									      {List
										 ++
										 [NewElem],
									       TAc}
								      end,
								      {[],
								       Accu},
								      Elem),
						      {Lt ++ [NewEl], NewAccu}
					      end,
					      {[], Acc1}, B),
		   {NewC, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc2}, C),
		   {clause, L, NewA, NewB, NewC};
	       {attribute, L, record, A} ->
		   {NewA2, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							 {NewElem, TAc} =
							     traverse_ast(Fun,
									  Ac,
									  Elem),
							 {List ++ [NewElem],
							  TAc}
						 end,
						 {[], Acc}, element(2, A)),
		   {attribute, L, record, {element(1, A), NewA2}};
	       {record_field, L, A} ->
		   {NewA, NewAcc} = traverse_ast(Fun, Acc, A),
		   {record_field, L, NewA};
	       {function, L, A, B, C} ->
		   {NewC, NewAcc} = lists:foldl(fun (Elem, {List, Ac}) ->
							{NewElem, TAc} =
							    traverse_ast(Fun,
									 Ac,
									 Elem),
							{List ++ [NewElem], TAc}
						end,
						{[], Acc}, C),
		   {function, L, A, B, NewC};
	       {attribute, L, A, B} ->
		   NewAcc = Acc, {attribute, L, A, B};
	       {eof, L} -> NewAcc = Acc, {eof, L}
	     end,
    Fun(NewAST, NewAcc).

clean_ast_linenums(AST) ->
    element(1,
	    traverse_ast(fun (Elem, Acc) ->
				 {setelement(2, Elem, 0), Acc}
			 end,
			 [], AST)).

get_ast_self() ->
    case beam_lib:chunks(emulator, [abstract_code]) of
      {ok,
       {_, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
	  tl(Forms)
    end.

get_clean_ast(Src, Funcname, Arity) ->
    {call, 0, {atom, 0, Funcname}, []}.

disassemble(Outfile, Filename) ->
    file:write_file(Outfile,
		    io_lib:fwrite("~p.~n", [beam_disasm:file(Filename)])).

setnth(1, [_ | Rest], New) -> [New | Rest];
setnth(I, [E | Rest], New) ->
    [E | setnth(I - 1, Rest, New)].

choose_dest(Val, List, Def) ->
    erlang:display({Val, List, Def}),
    if List =:= [] -> Def;
       hd(List) =:= Val orelse element(2, hd(List)) =:= Val ->
	   hd(tl(List));
       true -> choose_dest(Val, tl(tl(List)), Def)
    end.

get_binary_puts(State, Bin, Items, Count) ->
    if Items =:= 0 -> {Bin, Count};
       true ->
	   Val = hd(element(1, State)),
	   erlang:display({Val, Items}),
	   if element(1, Val) =:= bs_put_string ->
		  X = list_to_binary(element(2, element(3, Val))),
		  B = <<Bin/bitstring, X/binary>>,
		  get_binary_puts(setelement(1, State,
					     tl(element(1, State))),
				  B, Items - element(2, Val) * 8, Count + 1);
	      element(1, Val) =:= bs_put_utf8 ->
		  X = getmem(State, element(4, Val)),
		  Size = byte_size(BB = <<X/utf8>>) * 8,
		  B = <<Bin/bitstring, BB/binary>>,
		  get_binary_puts(setelement(1, State,
					     tl(element(1, State))),
				  B, Items - Size, Count + 1);
	      element(1, Val) =:= bs_put_utf16 ->
		  X = getmem(State, element(4, Val)),
		  Size = byte_size(BB = case element(2, element(3, Val))
					       band 2
					       =:= 2
					       orelse
					       element(2, element(3, Val)) band
						 16
						 =:= 16
						 andalso
						 erlang:system_info(endian) =:=
						   little
					    of
					  true -> <<X/utf16-little>>;
					  _ -> <<X/utf16>>
					end)
			   * 8,
		  B = <<Bin/bitstring, BB/binary>>,
		  get_binary_puts(setelement(1, State,
					     tl(element(1, State))),
				  B, Items - Size, Count + 1);
	      element(1, Val) =:= bs_put_utf32 ->
		  X = getmem(State, element(4, Val)),
		  BB = case element(2, element(3, Val)) band 2 =:= 2
			      orelse
			      element(2, element(3, Val)) band 16 =:= 16 andalso
				erlang:system_info(endian) =:= little
			   of
			 true -> <<X/utf32-little>>;
			 _ -> <<X/utf32>>
		       end,
		  B = <<Bin/bitstring, BB/binary>>,
		  get_binary_puts(setelement(1, State,
					     tl(element(1, State))),
				  B, Items - 8 * 4, Count + 1);
	      true ->
		  X = getmem(State, element(6, Val)),
		  get_binary_puts(setelement(1, State,
					     tl(element(1, State))),
				  case element(1, Val) of
				    bs_put_integer ->
					case element(2, element(5, Val)) band 2
					       =:= 2
					       orelse
					       element(2, element(5, Val)) band
						 16
						 =:= 16
						 andalso
						 erlang:system_info(endian) =:=
						   little
					    of
					  true ->
					      <<Bin/bitstring,
						X:(getmem(State,
							  element(3, Val))
						     *
						     element(4,
							     Val))/integer-little>>;
					  _ ->
					      <<Bin/bitstring,
						X:(getmem(State,
							  element(3, Val))
						     *
						     element(4, Val))/integer>>
					end;
				    bs_put_binary ->
					case element(3, Val) of
					  {atom, all} ->
					      <<Bin/bitstring, X/bitstring>>;
					  _ ->
					      <<Bin/bitstring,
						X:(getmem(State,
							  element(3, Val))
						     *
						     element(4,
							     Val))/bitstring>>
					end;
				    bs_put_float ->
					case element(2, element(5, Val)) band 2
					       =:= 2
					       orelse
					       element(2, element(5, Val)) band
						 16
						 =:= 16
						 andalso
						 erlang:system_info(endian) =:=
						   little
					    of
					  true ->
					      <<Bin/bitstring,
						X:(getmem(State,
							  element(3, Val))
						     *
						     element(4,
							     Val))/float-little>>;
					  _ ->
					      <<Bin/bitstring,
						X:(getmem(State,
							  element(3, Val))
						     * element(4, Val))/float>>
					end
				  end,
				  Items -
				    case element(3, Val) of
				      {atom, all} ->
					  bit_size(getmem(State,
							  element(6, Val)));
				      _ ->
					  getmem(State, element(3, Val)) *
					    element(4, Val)
				    end,
				  Count + 1)
	   end
    end.

getmem(State, Where) ->
    if Where =:= nil -> [];
       true ->
	   case element(1, Where) of
	     integer -> element(2, Where);
	     atom -> element(2, Where);
	     float -> element(2, Where);
	     list -> element(2, Where);
	     literal -> element(2, Where);
	     x ->
		 lists:nth(element(2, Where) + 1, element(2, State));
	     y ->
		 lists:nth(element(2, Where) + 1, element(3, State));
	     fr ->
		 lists:nth(element(2, Where) + 1, element(4, State));
	     f ->
		 lists:dropwhile(fun (Elem) ->
					 is_atom(Elem) orelse
					   element(1, Elem) =/= label orelse
					     element(2, Elem) =/=
					       element(2, Where)
				 end,
				 element(1, State))
	   end
    end.

setmem(State, Where, Val) ->
    case element(1, Where) of
      x ->
	  setelement(2, State,
		     setnth(element(2, Where) + 1, element(2, State), Val));
      y ->
	  setelement(3, State,
		     setnth(element(2, Where) + 1, element(3, State), Val));
      fr ->
	  setelement(4, State,
		     setnth(element(2, Where) + 1, element(4, State), Val))
    end.

get_tuple_puts(State, Count) ->
    if Count =:= 0 -> [];
       true ->
	   Val = hd(element(1, State)),
	   erlang:display(Val),
	   case element(1, Val) of
	     put ->
		 [getmem(State, element(2, Val))
		  | get_tuple_puts(setelement(1, State,
					      tl(element(1, State))),
				   Count - 1)]
	   end
    end.

fun_arglist(Fun, Arity) ->
    case Arity of
      0 -> fun () -> Fun([]) end;
      1 -> fun (X1) -> Fun([X1]) end;
      2 -> fun (X1, X2) -> Fun([X1, X2]) end;
      3 -> fun (X1, X2, X3) -> Fun([X1, X2, X3]) end;
      4 -> fun (X1, X2, X3, X4) -> Fun([X1, X2, X3, X4]) end;
      5 ->
	  fun (X1, X2, X3, X4, X5) -> Fun([X1, X2, X3, X4, X5])
	  end;
      6 ->
	  fun (X1, X2, X3, X4, X5, X6) ->
		  Fun([X1, X2, X3, X4, X5, X6])
	  end;
      7 ->
	  fun (X1, X2, X3, X4, X5, X6, X7) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7])
	  end;
      8 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8])
	  end;
      9 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9])
	  end;
      10 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10])
	  end;
      11 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11])
	  end;
      12 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11,
	       X12) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12])
	  end;
      13 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13])
	  end;
      14 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14])
	  end;
      15 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15])
	  end;
      16 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16])
	  end;
      17 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17])
	  end;
      18 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18])
	  end;
      19 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19])
	  end;
      20 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20])
	  end;
      21 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21])
	  end;
      22 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22])
	  end;
      23 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22,
	       X23) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23])
	  end;
      24 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24])
	  end;
      25 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25])
	  end;
      26 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26])
	  end;
      27 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27])
	  end;
      28 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28])
	  end;
      29 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29])
	  end;
      30 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30])
	  end;
      31 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31])
	  end;
      32 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32])
	  end;
      33 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33])
	  end;
      34 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33,
	       X34) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34])
	  end;
      35 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35])
	  end;
      36 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36])
	  end;
      37 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37])
	  end;
      38 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38])
	  end;
      39 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39])
	  end;
      40 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40])
	  end;
      41 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41])
	  end;
      42 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42])
	  end;
      43 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43])
	  end;
      44 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44])
	  end;
      45 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44,
	       X45) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45])
	  end;
      46 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46])
	  end;
      47 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47])
	  end;
      48 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48])
	  end;
      49 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49])
	  end;
      50 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50])
	  end;
      51 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51])
	  end;
      52 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52])
	  end;
      53 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53])
	  end;
      54 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54])
	  end;
      55 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55])
	  end;
      56 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55,
	       X56) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56])
	  end;
      57 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57])
	  end;
      58 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58])
	  end;
      59 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59])
	  end;
      60 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60])
	  end;
      61 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61])
	  end;
      62 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62])
	  end;
      63 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63])
	  end;
      64 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64])
	  end;
      65 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65])
	  end;
      66 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66])
	  end;
      67 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66,
	       X67) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67])
	  end;
      68 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68])
	  end;
      69 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69])
	  end;
      70 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70])
	  end;
      71 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71])
	  end;
      72 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72])
	  end;
      73 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73])
	  end;
      74 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74])
	  end;
      75 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75])
	  end;
      76 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76])
	  end;
      77 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77])
	  end;
      78 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77,
	       X78) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78])
	  end;
      79 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79])
	  end;
      80 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80])
	  end;
      81 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81])
	  end;
      82 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82])
	  end;
      83 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83])
	  end;
      84 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84])
	  end;
      85 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85])
	  end;
      86 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86])
	  end;
      87 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87])
	  end;
      88 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88])
	  end;
      89 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88,
	       X89) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89])
	  end;
      90 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90])
	  end;
      91 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91])
	  end;
      92 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92])
	  end;
      93 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93])
	  end;
      94 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94])
	  end;
      95 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95])
	  end;
      96 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96])
	  end;
      97 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97])
	  end;
      98 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98])
	  end;
      99 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99])
	  end;
      100 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99,
	       X100) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100])
	  end;
      101 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101])
	  end;
      102 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102])
	  end;
      103 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103])
	  end;
      104 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104])
	  end;
      105 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105])
	  end;
      106 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106])
	  end;
      107 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107])
	  end;
      108 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108])
	  end;
      109 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109])
	  end;
      110 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110])
	  end;
      111 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111])
	  end;
      112 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112])
	  end;
      113 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113])
	  end;
      114 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114])
	  end;
      115 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115])
	  end;
      116 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116])
	  end;
      117 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117])
	  end;
      118 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118])
	  end;
      119 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119])
	  end;
      120 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120])
	  end;
      121 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121])
	  end;
      122 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122])
	  end;
      123 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123])
	  end;
      124 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124])
	  end;
      125 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125])
	  end;
      126 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126])
	  end;
      127 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127])
	  end;
      128 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128])
	  end;
      129 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129])
	  end;
      130 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130])
	  end;
      131 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131])
	  end;
      132 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132])
	  end;
      133 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133])
	  end;
      134 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134])
	  end;
      135 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135])
	  end;
      136 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136])
	  end;
      137 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137])
	  end;
      138 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138])
	  end;
      139 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139])
	  end;
      140 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140])
	  end;
      141 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141])
	  end;
      142 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142])
	  end;
      143 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143])
	  end;
      144 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144])
	  end;
      145 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145])
	  end;
      146 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146])
	  end;
      147 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147])
	  end;
      148 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148])
	  end;
      149 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149])
	  end;
      150 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150])
	  end;
      151 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151])
	  end;
      152 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152])
	  end;
      153 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153])
	  end;
      154 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154])
	  end;
      155 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155])
	  end;
      156 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156])
	  end;
      157 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157])
	  end;
      158 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158])
	  end;
      159 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159])
	  end;
      160 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160])
	  end;
      161 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161])
	  end;
      162 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162])
	  end;
      163 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163])
	  end;
      164 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164])
	  end;
      165 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165])
	  end;
      166 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166])
	  end;
      167 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167])
	  end;
      168 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168])
	  end;
      169 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169])
	  end;
      170 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170])
	  end;
      171 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171])
	  end;
      172 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172])
	  end;
      173 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173])
	  end;
      174 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174])
	  end;
      175 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175])
	  end;
      176 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176])
	  end;
      177 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177])
	  end;
      178 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178])
	  end;
      179 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179])
	  end;
      180 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180])
	  end;
      181 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181])
	  end;
      182 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182])
	  end;
      183 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183])
	  end;
      184 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184])
	  end;
      185 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185])
	  end;
      186 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186])
	  end;
      187 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187])
	  end;
      188 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188])
	  end;
      189 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189])
	  end;
      190 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190])
	  end;
      191 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191])
	  end;
      192 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192])
	  end;
      193 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193])
	  end;
      194 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194])
	  end;
      195 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195])
	  end;
      196 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196])
	  end;
      197 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197])
	  end;
      198 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198])
	  end;
      199 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199])
	  end;
      200 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200])
	  end;
      201 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201])
	  end;
      202 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202])
	  end;
      203 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203])
	  end;
      204 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204])
	  end;
      205 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205])
	  end;
      206 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206])
	  end;
      207 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207])
	  end;
      208 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208])
	  end;
      209 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209])
	  end;
      210 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210])
	  end;
      211 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211])
	  end;
      212 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212])
	  end;
      213 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213])
	  end;
      214 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214])
	  end;
      215 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215])
	  end;
      216 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216])
	  end;
      217 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217])
	  end;
      218 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218])
	  end;
      219 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219])
	  end;
      220 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220])
	  end;
      221 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221])
	  end;
      222 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222])
	  end;
      223 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223])
	  end;
      224 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224])
	  end;
      225 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225])
	  end;
      226 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226])
	  end;
      227 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227])
	  end;
      228 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228])
	  end;
      229 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229])
	  end;
      230 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230])
	  end;
      231 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231])
	  end;
      232 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232])
	  end;
      233 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233])
	  end;
      234 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234])
	  end;
      235 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235])
	  end;
      236 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236])
	  end;
      237 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237])
	  end;
      238 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238])
	  end;
      239 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239])
	  end;
      240 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240])
	  end;
      241 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241])
	  end;
      242 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242])
	  end;
      243 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243])
	  end;
      244 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244])
	  end;
      245 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245])
	  end;
      246 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246])
	  end;
      247 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247])
	  end;
      248 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248])
	  end;
      249 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249])
	  end;
      250 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249, X250) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249, X250])
	  end;
      251 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249, X250, X251) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249, X250, X251])
	  end;
      252 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249, X250, X251, X252) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249, X250, X251, X252])
	  end;
      253 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249, X250, X251, X252, X253) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249, X250, X251, X252, X253])
	  end;
      254 ->
	  fun (X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
	       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
	       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
	       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
	       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
	       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
	       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
	       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
	       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
	       X101, X102, X103, X104, X105, X106, X107, X108, X109,
	       X110, X111, X112, X113, X114, X115, X116, X117, X118,
	       X119, X120, X121, X122, X123, X124, X125, X126, X127,
	       X128, X129, X130, X131, X132, X133, X134, X135, X136,
	       X137, X138, X139, X140, X141, X142, X143, X144, X145,
	       X146, X147, X148, X149, X150, X151, X152, X153, X154,
	       X155, X156, X157, X158, X159, X160, X161, X162, X163,
	       X164, X165, X166, X167, X168, X169, X170, X171, X172,
	       X173, X174, X175, X176, X177, X178, X179, X180, X181,
	       X182, X183, X184, X185, X186, X187, X188, X189, X190,
	       X191, X192, X193, X194, X195, X196, X197, X198, X199,
	       X200, X201, X202, X203, X204, X205, X206, X207, X208,
	       X209, X210, X211, X212, X213, X214, X215, X216, X217,
	       X218, X219, X220, X221, X222, X223, X224, X225, X226,
	       X227, X228, X229, X230, X231, X232, X233, X234, X235,
	       X236, X237, X238, X239, X240, X241, X242, X243, X244,
	       X245, X246, X247, X248, X249, X250, X251, X252, X253,
	       X254) ->
		  Fun([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
		       X13, X14, X15, X16, X17, X18, X19, X20, X21, X22, X23,
		       X24, X25, X26, X27, X28, X29, X30, X31, X32, X33, X34,
		       X35, X36, X37, X38, X39, X40, X41, X42, X43, X44, X45,
		       X46, X47, X48, X49, X50, X51, X52, X53, X54, X55, X56,
		       X57, X58, X59, X60, X61, X62, X63, X64, X65, X66, X67,
		       X68, X69, X70, X71, X72, X73, X74, X75, X76, X77, X78,
		       X79, X80, X81, X82, X83, X84, X85, X86, X87, X88, X89,
		       X90, X91, X92, X93, X94, X95, X96, X97, X98, X99, X100,
		       X101, X102, X103, X104, X105, X106, X107, X108, X109,
		       X110, X111, X112, X113, X114, X115, X116, X117, X118,
		       X119, X120, X121, X122, X123, X124, X125, X126, X127,
		       X128, X129, X130, X131, X132, X133, X134, X135, X136,
		       X137, X138, X139, X140, X141, X142, X143, X144, X145,
		       X146, X147, X148, X149, X150, X151, X152, X153, X154,
		       X155, X156, X157, X158, X159, X160, X161, X162, X163,
		       X164, X165, X166, X167, X168, X169, X170, X171, X172,
		       X173, X174, X175, X176, X177, X178, X179, X180, X181,
		       X182, X183, X184, X185, X186, X187, X188, X189, X190,
		       X191, X192, X193, X194, X195, X196, X197, X198, X199,
		       X200, X201, X202, X203, X204, X205, X206, X207, X208,
		       X209, X210, X211, X212, X213, X214, X215, X216, X217,
		       X218, X219, X220, X221, X222, X223, X224, X225, X226,
		       X227, X228, X229, X230, X231, X232, X233, X234, X235,
		       X236, X237, X238, X239, X240, X241, X242, X243, X244,
		       X245, X246, X247, X248, X249, X250, X251, X252, X253,
		       X254])
	  end;
      255 ->
	  NewFun = fun NamedFun(X1, X2, X3, X4, X5, X6, X7, X8,
				X9, X10, X11, X12, X13, X14, X15, X16, X17, X18,
				X19, X20, X21, X22, X23, X24, X25, X26, X27,
				X28, X29, X30, X31, X32, X33, X34, X35, X36,
				X37, X38, X39, X40, X41, X42, X43, X44, X45,
				X46, X47, X48, X49, X50, X51, X52, X53, X54,
				X55, X56, X57, X58, X59, X60, X61, X62, X63,
				X64, X65, X66, X67, X68, X69, X70, X71, X72,
				X73, X74, X75, X76, X77, X78, X79, X80, X81,
				X82, X83, X84, X85, X86, X87, X88, X89, X90,
				X91, X92, X93, X94, X95, X96, X97, X98, X99,
				X100, X101, X102, X103, X104, X105, X106, X107,
				X108, X109, X110, X111, X112, X113, X114, X115,
				X116, X117, X118, X119, X120, X121, X122, X123,
				X124, X125, X126, X127, X128, X129, X130, X131,
				X132, X133, X134, X135, X136, X137, X138, X139,
				X140, X141, X142, X143, X144, X145, X146, X147,
				X148, X149, X150, X151, X152, X153, X154, X155,
				X156, X157, X158, X159, X160, X161, X162, X163,
				X164, X165, X166, X167, X168, X169, X170, X171,
				X172, X173, X174, X175, X176, X177, X178, X179,
				X180, X181, X182, X183, X184, X185, X186, X187,
				X188, X189, X190, X191, X192, X193, X194, X195,
				X196, X197, X198, X199, X200, X201, X202, X203,
				X204, X205, X206, X207, X208, X209, X210, X211,
				X212, X213, X214, X215, X216, X217, X218, X219,
				X220, X221, X222, X223, X224, X225, X226, X227,
				X228, X229, X230, X231, X232, X233, X234, X235,
				X236, X237, X238, X239, X240, X241, X242, X243,
				X244, X245, X246, X247, X248, X249, X250, X251,
				X252, X253, X254, X255) ->
			   F = get(NamedFun),
			   erase(NamedFun),
			   F([X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12,
			      X13, X14, X15, X16, X17, X18, X19, X20, X21, X22,
			      X23, X24, X25, X26, X27, X28, X29, X30, X31, X32,
			      X33, X34, X35, X36, X37, X38, X39, X40, X41, X42,
			      X43, X44, X45, X46, X47, X48, X49, X50, X51, X52,
			      X53, X54, X55, X56, X57, X58, X59, X60, X61, X62,
			      X63, X64, X65, X66, X67, X68, X69, X70, X71, X72,
			      X73, X74, X75, X76, X77, X78, X79, X80, X81, X82,
			      X83, X84, X85, X86, X87, X88, X89, X90, X91, X92,
			      X93, X94, X95, X96, X97, X98, X99, X100, X101,
			      X102, X103, X104, X105, X106, X107, X108, X109,
			      X110, X111, X112, X113, X114, X115, X116, X117,
			      X118, X119, X120, X121, X122, X123, X124, X125,
			      X126, X127, X128, X129, X130, X131, X132, X133,
			      X134, X135, X136, X137, X138, X139, X140, X141,
			      X142, X143, X144, X145, X146, X147, X148, X149,
			      X150, X151, X152, X153, X154, X155, X156, X157,
			      X158, X159, X160, X161, X162, X163, X164, X165,
			      X166, X167, X168, X169, X170, X171, X172, X173,
			      X174, X175, X176, X177, X178, X179, X180, X181,
			      X182, X183, X184, X185, X186, X187, X188, X189,
			      X190, X191, X192, X193, X194, X195, X196, X197,
			      X198, X199, X200, X201, X202, X203, X204, X205,
			      X206, X207, X208, X209, X210, X211, X212, X213,
			      X214, X215, X216, X217, X218, X219, X220, X221,
			      X222, X223, X224, X225, X226, X227, X228, X229,
			      X230, X231, X232, X233, X234, X235, X236, X237,
			      X238, X239, X240, X241, X242, X243, X244, X245,
			      X246, X247, X248, X249, X250, X251, X252, X253,
			      X254, X255])
		   end,
	  put(NewFun, Fun),
	  NewFun
    end.

has_utf8(Binary) ->
    (Bits = bit_size(Binary)) >= 8 andalso
      ((FB = hd(binary_to_list(binary_part(Binary, 0, 1)))) =<
	 127
	 orelse
	 Bits >= 16 andalso
	   (SB = hd(binary_to_list(binary_part(Binary, 1, 1))))
	     band 192
	     =:= 128
	     andalso
	     (FB >= 194 andalso FB =< 223 orelse
		Bits >= 24 andalso
		  (TB = hd(binary_to_list(binary_part(Binary, 2, 1))))
		    band 192
		    =:= 128
		    andalso
		    (FB >= 224 andalso
		       FB =< 239 andalso
			 (FB =/= 224 orelse SB >= 160) andalso
			   ((Result = FB bsl 6 bor SB bsl 6 bor TB - 925824) =<
			      55295
			      orelse Result >= 57344)
		       orelse
		       FB >= 240 andalso
			 FB =< 247 andalso
			   Bits >= 32 andalso
			     (HB = hd(binary_to_list(binary_part(Binary, 3,
								 1))))
			       band 192
			       =:= 128
			       andalso
			       (FB =/= 240 orelse SB >= 144) andalso
				 FB bsl 6 bor SB bsl 6 bor TB bsl 6 bor HB -
				   63447168
				   =< 1114111))).

get_utf8_size(Binary) ->
    FB = hd(binary_to_list(binary_part(Binary, 0, 1))),
    if FB =< 127 -> 1;
       FB >= 194 andalso FB =< 223 -> 2;
       FB >= 224 andalso FB =< 239 -> 3;
       FB >= 240 andalso FB =< 247 -> 4
    end.

get_utf8(Binary) ->
    FB = hd(binary_to_list(binary_part(Binary, 0, 1))),
    if FB =< 127 -> FB;
       FB >= 194 andalso FB =< 223 ->
	   FB bsl 6 bor
	     hd(binary_to_list(binary_part(Binary, 1, 1)))
	     - 12416;
       FB >= 224 andalso FB =< 239 ->
	   [L1, L2] = binary_to_list(binary_part(Binary, 1, 2)),
	   FB bsl 6 bor L1 bsl 6 bor L2 - 925824;
       FB >= 240 andalso FB =< 247 ->
	   [L1, L2, L3] = binary_to_list(binary_part(Binary, 1,
						     3)),
	   FB bsl 6 bor L1 bsl 6 bor L2 bsl 6 bor L3 - 63447168
    end.

has_utf16(Binary, IsLittle) ->
    (Bits = bit_size(Binary)) >= 16 andalso
      ((FW = hd(binary_to_list(binary_part(Binary,
					   if IsLittle -> 1;
					      true -> 0
					   end,
					   1))))
	 =< 215
	 orelse
	 FW >= 224 orelse
	   FW =< 219 andalso
	     Bits >= 32 andalso
	       ((SW = hd(binary_to_list(binary_part(Binary,
						    if IsLittle -> 3;
						       true -> 2
						    end,
						    1))))
		  =< 219
		  orelse SW >= 224)).

get_utf16_size(Binary, IsLittle) ->
    [L1, L2] = binary_to_list(binary_part(Binary, 0, 2)),
    FW = if IsLittle -> L2;
	    true -> L1
	 end,
    if FW =< 215 orelse FW >= 224 -> 2;
       FW =< 219 -> 4
    end.

get_utf16(Binary, IsLittle) ->
    [L1, L2] = binary_to_list(binary_part(Binary, 0, 2)),
    FW = if IsLittle -> L2;
	    true -> L1
	 end,
    if FW =< 215 orelse FW >= 224 ->
	   FW bsl 8 bor
	     if IsLittle -> L1;
		true -> L2
	     end;
       FW =< 219 ->
	   [L3, L4] = binary_to_list(binary_part(Binary, 2, 2)),
	   (FW bsl 8 bor
	      if IsLittle -> L1;
		 true -> 2
	      end)
	     band 1023
	     bsl 10
	     bor
	     (if IsLittle -> L4;
		 true -> L3
	      end
		bsl 8
		bor
		if IsLittle -> L3;
		   true -> L4
		end)
	       band 1023
	     + 65536
    end.

has_utf32(Binary, IsLittle) ->
    bit_size(Binary) >= 32 andalso
      begin
	[B1, B2, B3, B4] = binary_to_list(binary_part(Binary, 0,
						      4)),
	(Res = if IsLittle -> B4;
		  true -> B1
	       end
		 bsl 8
		 bor
		 if IsLittle -> B3;
		    true -> B2
		 end
		 bsl 8
		 bor
		 if IsLittle -> B2;
		    true -> B3
		 end
		 bsl 8
		 bor
		 if IsLittle -> B1;
		    true -> B4
		 end)
	  =< 1114111
	  andalso (Res =< 55295 orelse Res >= 57344)
      end.

get_utf32(Binary, IsLittle) ->
    [B1, B2, B3, B4] = binary_to_list(binary_part(Binary, 0,
						  4)),
    if IsLittle -> B4;
       true -> B1
    end
      bsl 8
      bor
      if IsLittle -> B3;
	 true -> B2
      end
      bsl 8
      bor
      if IsLittle -> B2;
	 true -> B3
      end
      bsl 8
      bor
      if IsLittle -> B1;
	 true -> B4
      end.

has_float(Binary, Size, IsLittle) ->
    bit_size(Binary) >= Size andalso
      (Size =:= 0 orelse
	 Size =:= 32 andalso
	   begin
	     [B1, B2] = binary_to_list(binary_part(Binary,
						   if IsLittle -> 2;
						      true -> 0
						   end,
						   2)),
	     (if IsLittle -> B2;
		 true -> B1
	      end
		bsl 8
		bor
		if IsLittle -> B1;
		   true -> B2
		end)
	       band 32640
	       =/= 32640
	   end
	   orelse
	   Size =:= 64 andalso
	     begin
	       [D1, D2] = binary_to_list(binary_part(Binary,
						     if IsLittle -> 6;
							true -> 0
						     end,
						     2)),
	       (if IsLittle -> D2;
		   true -> D1
		end
		  bsl 8
		  bor
		  if IsLittle -> D1;
		     true -> D2
		  end)
		 band 32752
		 =/= 32752
	     end).

get_float(Float, Size, IsLittle) ->
    if Size =:= 0 -> 0.0;
       Size =:= 32 ->
	   [B1, B2, B3, B4] = binary_to_list(binary_part(Float, 0,
							 4)),
	   {S, E, M} = if IsLittle ->
			      {B4 bsr 7, B4 band 127 bsl 1 bor (B3 bsr 7),
			       B3 band 127 bsl 8 bor B2 bsl 8 bor B1};
			  true ->
			      {B1 bsr 7, B1 band 127 bsl 1 bor (B2 bsr 7),
			       B2 band 127 bsl 8 bor B3 bsl 8 bor B4}
		       end,
	   case {S, E, M} of
	     {_, 0, 0} -> 0.0;
	     {S, 0, M} -> (1 - 2 * S) * M / (1 bsl (126 + 23));
	     {S, E, M} when E > 127 + 23 ->
		 float((1 - 2 * S) * (M + (1 bsl 23)) *
			 (1 bsl (E - 127 - 23)));
	     {S, E, M} ->
		 (1 - 2 * S) * (M + (1 bsl 23)) / (1 bsl (127 + 23 - E))
	   end;
       Size =:= 64 ->
	   [B1, B2, B3, B4, B5, B6, B7, B8] =
	       binary_to_list(binary_part(Float, 0, 8)),
	   {S, E, M} = if IsLittle ->
			      {B8 bsr 7, B8 band 127 bsl 4 bor (B7 bsr 4),
			       B7 band 15 bsl 8 bor B6 bsl 8 bor B5 bsl 8 bor B4
				 bsl 8
				 bor B3
				 bsl 8
				 bor B2
				 bsl 8
				 bor B1};
			  true ->
			      {B1 bsr 7, B1 band 127 bsl 4 bor (B2 bsr 4),
			       B2 band 15 bsl 8 bor B3 bsl 8 bor B4 bsl 8 bor B5
				 bsl 8
				 bor B6
				 bsl 8
				 bor B7
				 bsl 8
				 bor B8}
		       end,
	   case {S, E, M} of
	     {_, 0, 0} -> 0.0;
	     {S, 0, M} ->
		 (1 - 2 * S) * M / (1 bsl 1022) / (1 bsl 52);
	     {S, E, M} when E > 1022 + 52 ->
		 float((1 - 2 * S) * (M + (1 bsl 52)) *
			 (1 bsl (E - 1022 - 52 - 1)));
	     {S, E, M} when E < 52 ->
		 (1 - 2 * S) * ((M + (1 bsl 52)) / (1 bsl 1022)) /
		   (1 bsl (52 + 1 - E));
	     {S, E, M} ->
		 (1 - 2 * S) * (M + (1 bsl 52)) /
		   (1 bsl (1022 + 52 + 1 - E))
	   end
    end.

get_integer(Binary, Size, IsLittle, IsSigned) ->
    BS = bit_size(Binary),
    B = binary_to_list(if BS rem 8 =:= 0 -> Binary;
			  true -> S = 8 - BS rem 8, <<Binary/bitstring, 0:S>>
		       end),
    Sub = if Size =:= 0 -> 0;
	     true ->
		 apply(lists,
		       if IsLittle -> foldr;
			  true -> foldl
		       end,
		       [fun (El, Acc) -> Acc bsl 8 bor El end,
			if Size rem 8 =/= 0 andalso IsLittle ->
			       lists:nth(Size div 8 + 1, B) bsr
				 (8 - Size rem 8);
			   true -> 0
			end,
			lists:sublist(B, Size div 8)])
	  end,
    if Size rem 8 =:= 0 orelse IsLittle ->
	   case Size =/= 0 andalso
		  IsSigned andalso
		    lists:nth(if IsLittle ->
				     Size div 8 +
				       if Size rem 8 =:= 0 -> 0;
					  true -> 1
				       end;
				 true -> 1
			      end,
			      B)
		      band 128
		      =:= 128
	       of
	     true -> Sub - (1 bsl Size);
	     _ -> Sub
	   end;
       true ->
	   Sub bsl 8 bor lists:nth(Size div 8 + 1, B) bsr
	     (8 - Size rem 8)
	     -
	     if IsSigned andalso hd(B) band 128 =:= 128 ->
		    1 bsl Size;
		true -> 0
	     end
    end.

get_bits(Binary, Size) ->
    BS = bit_size(Binary),
    B = binary_to_list(if BS rem 8 =:= 0 -> Binary;
			  true -> S = 8 - BS rem 8, <<Binary/bitstring, 0:S>>
		       end),
    Sub = lists:sublist(B, Size div 8),
    list_to_bitstring(if Size rem 8 =:= 0 -> Sub;
			 true ->
			     Sz = Size rem 8,
			     E = lists:nth(Size div 8 + 1, B) bsr (8 - Sz),
			     Sub ++ [<<E:Sz>>]
		      end).

skip_bits(Binary, Size) ->
    erlang:display({Binary, Size}),
    BS = bit_size(Binary),
    B = binary_to_list(if BS rem 8 =:= 0 -> Binary;
			  true -> S = 8 - BS rem 8, <<Binary/bitstring, 0:S>>
		       end),
    if Size =:= 0 -> Binary;
       BS =:= Size -> <<>>;
       true ->
	   list_to_bitstring(lists:foldl(fun (El, Acc) ->
						 if Acc =:= [] -> Acc;
						    true ->
							lists:droplast(Acc) ++
							  if length(Acc) =:=
							       length(B) -
								 Size div 8
								 - 1
							       andalso
							       BS rem 8 =/= 0
								 andalso
								 BS rem 8 <
								   Size rem 8 ->
								 E =
								     lists:last(Acc)
								       bsr
								       (Size rem
									  8
									  -
									  BS rem
									    8)
								       bor
								       (El bsr
									  (8 -
									     BS
									       rem
									       8))
									 band
									 (1 bsl
									    (BS
									       -
									       Size)
									      rem
									      8
									    -
									    1),
								 Sz = (BS -
									 Size)
									rem 8,
								 [<<E:Sz>>];
							     true ->
								 [lists:last(Acc)
								    bor
								    (El bsr
								       (8 -
									  Size
									    rem
									    8))]
							  end
						 end
						   ++
						   if length(Acc) =:=
							length(B) - Size div 8 -
							  1
							andalso
							BS rem 8 =/= 0 andalso
							  ((BS - Size) rem 8 =:=
							     0
							     orelse
							     BS rem 8 <
							       Size rem 8) ->
							  [];
						      length(Acc) =:=
							length(B) - Size div 8 -
							  1
							andalso
							(BS - Size) rem 8 =/=
							  0 ->
							  E = (El bsr
								 if BS rem 8 =:=
								      0 ->
									0;
								    true ->
									8 -
									  BS rem
									    8
								 end)
								band
								(1 bsl
								   (BS - Size)
								     rem 8
								   - 1),
							  Sz = (BS - Size) rem
								 8,
							  [<<E:Sz>>];
						      true ->
							  [El band
							     (1 bsl
								(8 - Size rem 8)
								- 1)
							     bsl Size rem 8]
						   end
					 end,
					 [], lists:nthtail(Size div 8, B)))
    end.

test_sem_equiv() ->
    Fun1 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<Z:32/integer>>,
		   case case Y of
			  <<B:32/float>> -> B =/= get_float(Y, 32, false);
			  _ -> true
			end
			  =:= not has_float(Y, 32, false)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun2 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<Z:32/integer>>,
		   case case Y of
			  <<B:32/float-little>> -> B =/= get_float(Y, 32, true);
			  _ -> true
			end
			  =:= not has_float(Y, 32, true)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun3 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(18446744073709551616) - 1,
		   Y = <<Z:64/integer>>,
		   case case Y of
			  <<B:64/float>> -> B =/= get_float(Y, 64, false);
			  _ -> true
			end
			  =:= not has_float(Y, 64, false)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun4 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(18446744073709551616) - 1,
		   Y = <<Z:64/integer>>,
		   case case Y of
			  <<B:64/float-little>> -> B =/= get_float(Y, 64, true);
			  _ -> true
			end
			  =:= not has_float(Y, 64, true)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun5 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<X:32/integer>>,
		   case case Y of
			  <<B/utf8, _/bitstring>> -> B =/= get_utf8(Y);
			  _ -> true
			end
			  =:= not has_utf8(Y)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun6 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<X:32/integer>>,
		   case case Y of
			  <<B/utf16, _/bitstring>> -> B =/= get_utf16(Y, false);
			  _ -> true
			end
			  =:= not has_utf16(Y, false)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun7 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<X:32/integer>>,
		   case case Y of
			  <<B/utf16-little, _/bitstring>> ->
			      B =/= get_utf16(Y, true);
			  _ -> true
			end
			  =:= not has_utf16(Y, true)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun8 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<X:32/integer>>,
		   case case Y of
			  <<B/utf32>> -> B =/= get_utf32(Y, false);
			  _ -> true
			end
			  =:= not has_utf32(Y, false)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun9 = fun (X, F) when X =/= 2097152 ->
		   Z = rand:uniform(4294967296) - 1,
		   Y = <<X:32/integer>>,
		   case case Y of
			  <<B/utf32-little>> -> B =/= get_utf32(Y, true);
			  _ -> true
			end
			  =:= not has_utf32(Y, true)
		       of
		     true -> F(X + 1, F);
		     false -> Z
		   end;
	       (_, _) -> true
	   end,
    Fun10 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case get_integer(<<Y:Z>>, S, true, false) =:=
			   fun (Binary, Size) ->
				   <<Result:Size/little, _/bitstring>> = Binary,
				   Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    Fun11 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case get_integer(<<Y:Z>>, S, false, false) =:=
			   fun (Binary, Size) ->
				   <<Result:Size, _/bitstring>> = Binary, Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    Fun12 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case get_integer(<<Y:Z>>, S, true, true) =:=
			   fun (Binary, Size) ->
				   <<Result:Size/little-signed, _/bitstring>> =
				       Binary,
				   Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    Fun13 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case get_integer(<<Y:Z>>, S, false, true) =:=
			   fun (Binary, Size) ->
				   <<Result:Size/signed, _/bitstring>> = Binary,
				   Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    Fun14 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case get_bits(<<Y:Z>>, S) =:=
			   fun (Binary, Size) ->
				   <<Result:Size/bitstring, _/bitstring>> =
				       Binary,
				   Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    Fun15 = fun (X, F) when X =/= 2097152 ->
		    Z = rand:uniform(64) - 1,
		    Y = rand:uniform(1 bsl Z),
		    S = rand:uniform(Z + 1) - 1,
		    case skip_bits(<<Y:Z>>, S) =:=
			   fun (Binary, Size) ->
				   <<_:Size, Result/bitstring>> = Binary, Result
			   end(<<Y:Z>>, S)
			of
		      true -> F(X + 1, F);
		      false -> {Z, Y, S}
		    end;
		(_, _) -> true
	    end,
    [Fun1(0, Fun1), Fun2(0, Fun2), Fun3(0, Fun3),
     Fun4(0, Fun4), Fun5(0, Fun5), Fun6(0, Fun6),
     Fun7(0, Fun7), Fun8(0, Fun8), Fun9(0, Fun9),
     Fun10(0, Fun10), Fun11(0, Fun11), Fun12(0, Fun12),
     Fun13(0, Fun13), Fun14(0, Fun14), Fun15(0, Fun15)].

exec_step(State) ->
    {RemainingCode, XVars, YVars, FrVars, LineNo,
     LastErrClass, StackTrace, OrigCode} =
	State,
    Val = hd(RemainingCode),
    erlang:display(Val),
    case Val of
      return ->
	  {[], XVars, YVars, FrVars, LineNo, LastErrClass,
	   StackTrace, OrigCode};
      on_load ->
	  exec_step({tl(RemainingCode), XVars, YVars, FrVars,
		     LineNo, LastErrClass, StackTrace, OrigCode});
      fclearerror ->
	  exec_step({tl(RemainingCode), XVars, YVars, FrVars,
		     LineNo, LastErrClass, StackTrace, OrigCode});
      remove_message ->
	  {true,
	   exec_step({tl(RemainingCode), XVars, YVars, FrVars,
		      LineNo, LastErrClass, StackTrace, OrigCode})};
      send ->
	  exec_step({tl(RemainingCode),
		     [hd(XVars) ! hd(tl(XVars)) | tl(XVars)], YVars, FrVars,
		     LineNo, LastErrClass, StackTrace, OrigCode});
      bs_init_writable ->
	  _Size = getmem(State, {x, 0}),
	  exec_step({tl(RemainingCode), [<<>> | tl(XVars)], YVars,
		     FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
      timeout ->
	  exec_step({tl(RemainingCode), XVars, YVars, FrVars,
		     LineNo, LastErrClass, StackTrace, OrigCode});
      if_end -> emulate(erlang, error, [if_clause], State);
      _ ->
	  case element(1, Val) of
	    label ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    line ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   [element(2, Val) | tl(LineNo)], LastErrClass,
			   StackTrace, OrigCode});
	    func_info ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    fcheckerror ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    test_heap ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    badmatch ->
		emulate(erlang, error,
			[{badmatch, getmem(State, element(2, Val))}], State);
	    case_end ->
		emulate(erlang, error,
			[{case_clause, getmem(State, element(2, Val))}], State);
	    catch_end -> State;
	    try_end -> setelement(State, 6, tl(LastErrClass));
	    try_case ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    try_case_end ->
		emulate(erlang, error,
			[{try_clause, getmem(State, element(2, Val))}], State);
	    raise ->
		emulate(erlang, raise,
			[hd(LastErrClass),
			 getmem(State, lists:nth(2, element(3, Val))),
			 getmem(State, lists:nth(1, element(3, Val)))],
			State);
	    loop_rec ->
		exec_step({getmem(State, element(2, Val)), XVars, YVars,
			   FrVars, LineNo, LastErrClass, StackTrace, OrigCode});
	    wait ->
		pd_emu_receive(fun (ChkMsg) ->
				       InstList = getmem({OrigCode},
							 element(2, Val)),
				       exec_step({tl(tl(InstList)),
						  [ChkMsg | tl(XVars)], YVars,
						  FrVars, LineNo, LastErrClass,
						  StackTrace, OrigCode})
			       end);
	    wait_timeout ->
		pd_emu_receive(fun (ChkMsg) ->
				       _InstList = getmem({OrigCode},
							  element(2, Val)),
				       exec_step({getmem({OrigCode},
							 element(2, Val)),
						  [ChkMsg | tl(XVars)], YVars,
						  FrVars, LineNo, LastErrClass,
						  StackTrace, OrigCode})
			       end,
			       getmem(State, element(3, Val)),
			       fun () ->
				       exec_step({tl(RemainingCode), XVars,
						  YVars, FrVars, LineNo,
						  LastErrClass, StackTrace,
						  OrigCode})
			       end);
	    loop_rec_end -> false;
	    recv_mark ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    recv_set ->
		exec_step({tl(RemainingCode), XVars, YVars, FrVars,
			   LineNo, LastErrClass, StackTrace, OrigCode});
	    select_val ->
		InstList = getmem(State,
				  choose_dest(getmem(State, element(2, Val)),
					      getmem(State, element(4, Val)),
					      element(3, Val))),
		if InstList =:= [] ->
		       emulate(erlang, error, [function_clause], State);
		   true -> exec_step(setelement(1, State, InstList))
		end;
	    select_tuple_arity ->
		InstList = getmem(State,
				  choose_dest(tuple_size(getmem(State,
								element(2,
									Val))),
					      getmem(State, element(4, Val)),
					      element(3, Val))),
		if InstList =:= [] ->
		       emulate(erlang, error, [function_clause], State);
		   true -> exec_step(setelement(1, State, InstList))
		end;
	    test ->
		case case element(2, Val) of
		       is_lt ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) <
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_ge ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) >=
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_eq ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) ==
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_ne ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) /=
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_eq_exact ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) =:=
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_ne_exact ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) =/=
			     getmem(State, lists:nth(2, element(4, Val)));
		       is_integer ->
			   NewState = State,
			   is_integer(getmem(State, hd(element(4, Val))));
		       is_float ->
			   NewState = State,
			   is_float(getmem(State, hd(element(4, Val))));
		       is_number ->
			   NewState = State,
			   is_number(getmem(State, hd(element(4, Val))));
		       is_atom ->
			   NewState = State,
			   is_atom(getmem(State, hd(element(4, Val))));
		       is_pid ->
			   NewState = State,
			   is_pid(getmem(State, hd(element(4, Val))));
		       is_reference ->
			   NewState = State,
			   is_reference(getmem(State, hd(element(4, Val))));
		       is_port ->
			   NewState = State,
			   is_port(getmem(State, hd(element(4, Val))));
		       is_nil ->
			   NewState = State,
			   getmem(State, hd(element(4, Val))) =:= [];
		       is_boolean ->
			   NewState = State,
			   is_boolean(getmem(State, hd(element(4, Val))));
		       is_binary ->
			   NewState = State,
			   is_binary(getmem(State, hd(element(4, Val))));
		       is_bitstr ->
			   NewState = State,
			   is_bitstring(getmem(State, hd(element(4, Val))));
		       is_list ->
			   NewState = State,
			   is_list(getmem(State, hd(element(4, Val))));
		       is_nonempty_list ->
			   NewState = State,
			   is_list(getmem(State, hd(element(4, Val)))) andalso
			     getmem(State, hd(element(4, Val))) =/= [];
		       is_tuple ->
			   NewState = State,
			   is_tuple(getmem(State, hd(element(4, Val))));
		       is_function ->
			   NewState = State,
			   is_function(getmem(State, hd(element(4, Val))));
		       is_function2 ->
			   NewState = State,
			   is_function(getmem(State, hd(element(4, Val))),
				       getmem(State,
					      lists:nth(2, element(4, Val))));
		       is_map ->
			   NewState = State,
			   is_map(getmem(State, hd(element(4, Val))));
		       has_map_fields ->
			   NewState = State,
			   lists:foldl(fun (El, Acc) ->
					       Next = maps:is_key(getmem(State,
									 El),
								  getmem(State,
									 element(4,
										 Val))),
					       if Acc =:= [] -> Next;
						  true -> Next andalso Acc
					       end
				       end,
				       [], getmem(State, element(5, Val)));
		       is_tagged_tuple ->
			   NewState = State,
			   is_tuple(getmem(State, hd(element(4, Val)))) andalso
			     tuple_size(getmem(State, hd(element(4, Val)))) =:=
			       lists:nth(2, element(4, Val))
			       andalso
			       element(1, getmem(State, hd(element(4, Val))))
				 =:= element(2, lists:nth(3, element(4, Val)));
		       test_arity ->
			   NewState = State,
			   tuple_size(getmem(State, hd(element(4, Val)))) =:=
			     lists:nth(2, element(4, Val));
		       bs_test_unit ->
			   NewState = State,
			   bit_size(element(1,
					    getmem(State, hd(element(4, Val)))))
			     rem lists:nth(2, element(4, Val))
			     =:= 0;
		       bs_test_tail2 ->
			   NewState = State,
			   bit_size(element(1,
					    getmem(State, hd(element(4, Val)))))
			     =:= lists:nth(2, element(4, Val));
		       bs_start_match2 ->
			   X = getmem(State, hd(element(4, Val))),
			   Cond = case is_tuple(X) of
				    true ->
					is_bitstring(element(1, X)) andalso
					  is_bitstring(element(2, X));
				    _ -> is_bitstring(X)
				  end,
			   if Cond ->
				  NewState = setmem(State,
						    lists:nth(4,
							      element(4, Val)),
						    case is_tuple(getmem(State,
									 hd(element(4,
										    Val))))
							of
						      true ->
							  getmem(State,
								 hd(element(4,
									    Val)));
						      _ ->
							  {getmem(State,
								  hd(element(4,
									     Val))),
							   getmem(State,
								  hd(element(4,
									     Val)))}
						    end);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_skip_bits2 ->
			   {Y, Z} = getmem(State, hd(element(4, Val))),
			   Cond = case getmem(State,
					      lists:nth(2, element(4, Val)))
					 =:= all
				      of
				    true ->
					bit_size(Y) rem
					  lists:nth(3, element(4, Val))
					  =:= 0;
				    _ ->
					getmem(State,
					       lists:nth(2, element(4, Val)))
					  >= 0
					  andalso
					  bit_size(Y) >=
					    getmem(State,
						   lists:nth(2,
							     element(4, Val)))
					      * lists:nth(3, element(4, Val))
				  end,
			   if Cond ->
				  X = case getmem(State,
						  lists:nth(2, element(4, Val)))
					     =:= all
					  of
					true -> <<>>;
					_ ->
					    skip_bits(Y,
						      getmem(State,
							     lists:nth(2,
								       element(4,
									       Val)))
							*
							lists:nth(3,
								  element(4,
									  Val)))
				      end,
				  NewState = setmem(State, hd(element(4, Val)),
						    {X, Z});
			      true -> NewState = State
			   end,
			   Cond;
		       bs_skip_utf8 ->
			   {Y, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf8(Y),
			   if Cond ->
				  X = skip_bits(Y, get_utf8_size(Y) * 8),
				  NewState = setmem(State, hd(element(4, Val)),
						    {X, Z});
			      true -> NewState = State
			   end,
			   Cond;
		       bs_skip_utf16 ->
			   {Y, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf16(Y,
					    element(2,
						    lists:nth(3,
							      element(4, Val)))
					      band 2
					      =:= 2
					      orelse
					      element(2,
						      lists:nth(3,
								element(4,
									Val)))
						band 16
						=:= 16
						andalso
						little =:=
						  erlang:system_info(endian)),
			   if Cond ->
				  X = skip_bits(Y,
						get_utf16_size(Y,
							       element(2,
								       lists:nth(3,
										 element(4,
											 Val)))
								 band 2
								 =:= 2
								 orelse
								 element(2,
									 lists:nth(3,
										   element(4,
											   Val)))
								   band 16
								   =:= 16
								   andalso
								   little =:=
								     erlang:system_info(endian))
						  * 8),
				  NewState = setmem(State, hd(element(4, Val)),
						    {X, Z});
			      true -> NewState = State
			   end,
			   Cond;
		       bs_skip_utf32 ->
			   {Y, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf32(Y,
					    element(2,
						    lists:nth(3,
							      element(4, Val)))
					      band 2
					      =:= 2
					      orelse
					      element(2,
						      lists:nth(3,
								element(4,
									Val)))
						band 16
						=:= 16
						andalso
						little =:=
						  erlang:system_info(endian)),
			   if Cond ->
				  X = skip_bits(Y, 4 * 8),
				  NewState = setmem(State, hd(element(4, Val)),
						    {X, Z});
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_integer2 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = bit_size(Q) >=
				    lists:nth(4, element(4, Val)) *
				      getmem(State,
					     lists:nth(3, element(4, Val))),
			   if Cond ->
				  X = get_integer(Q,
						  lists:nth(4, element(4, Val))
						    *
						    element(2,
							    lists:nth(3,
								      element(4,
									      Val))),
						  element(2,
							  lists:nth(5,
								    element(4,
									    Val)))
						    band 2
						    =:= 2
						    orelse
						    element(2,
							    lists:nth(5,
								      element(4,
									      Val)))
						      band 16
						      =:= 16
						      andalso
						      little =:=
							erlang:system_info(endian),
						  element(2,
							  lists:nth(5,
								    element(4,
									    Val)))
						    band 4
						    =:= 4),
				  Y = skip_bits(Q,
						lists:nth(4, element(4, Val)) *
						  element(2,
							  lists:nth(3,
								    element(4,
									    Val)))),
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(6,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_float2 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_float(Q,
					    lists:nth(4, element(4, Val)) *
					      getmem(State,
						     lists:nth(3,
							       element(4,
								       Val))),
					    element(2,
						    lists:nth(5,
							      element(4, Val)))
					      band 2
					      =:= 2
					      orelse
					      element(2,
						      lists:nth(5,
								element(4,
									Val)))
						band 16
						=:= 16
						andalso
						little =:=
						  erlang:system_info(endian)),
			   if Cond ->
				  X = get_float(Q,
						lists:nth(4, element(4, Val)) *
						  getmem(State,
							 lists:nth(3,
								   element(4,
									   Val))),
						element(2,
							lists:nth(5,
								  element(4,
									  Val)))
						  band 2
						  =:= 2
						  orelse
						  element(2,
							  lists:nth(5,
								    element(4,
									    Val)))
						    band 16
						    =:= 16
						    andalso
						    little =:=
						      erlang:system_info(endian)),
				  Y = skip_bits(Q,
						lists:nth(4, element(4, Val)) *
						  getmem(State,
							 lists:nth(3,
								   element(4,
									   Val)))),
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(6,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_utf8 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf8(Q),
			   if Cond ->
				  X = get_utf8(Q),
				  Y = skip_bits(Q, get_utf8_size(Q) * 8),
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(4,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_utf16 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf16(Q,
					    element(2,
						    lists:nth(3,
							      element(4, Val)))
					      band 2
					      =:= 2
					      orelse
					      element(2,
						      lists:nth(3,
								element(4,
									Val)))
						band 16
						=:= 16
						andalso
						little =:=
						  erlang:system_info(endian)),
			   if Cond ->
				  X = get_utf16(Q,
						element(2,
							lists:nth(3,
								  element(4,
									  Val)))
						  band 2
						  =:= 2
						  orelse
						  element(2,
							  lists:nth(3,
								    element(4,
									    Val)))
						    band 16
						    =:= 16
						    andalso
						    little =:=
						      erlang:system_info(endian)),
				  Y = skip_bits(Q,
						get_utf16_size(Q,
							       element(2,
								       lists:nth(3,
										 element(4,
											 Val)))
								 band 2
								 =:= 2
								 orelse
								 element(2,
									 lists:nth(3,
										   element(4,
											   Val)))
								   band 16
								   =:= 16
								   andalso
								   little =:=
								     erlang:system_info(endian))
						  * 8),
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(4,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_utf32 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = has_utf32(Q,
					    element(2,
						    lists:nth(3,
							      element(4, Val)))
					      band 2
					      =:= 2
					      orelse
					      element(2,
						      lists:nth(3,
								element(4,
									Val)))
						band 16
						=:= 16
						andalso
						little =:=
						  erlang:system_info(endian)),
			   if Cond ->
				  X = get_utf32(Q,
						element(2,
							lists:nth(3,
								  element(4,
									  Val)))
						  band 2
						  =:= 2
						  orelse
						  element(2,
							  lists:nth(3,
								    element(4,
									    Val)))
						    band 16
						    =:= 16
						    andalso
						    little =:=
						      erlang:system_info(endian)),
				  Y = skip_bits(Q, 4 * 8),
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(4,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_get_binary2 ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = case getmem(State,
					      lists:nth(3, element(4, Val)))
					 =:= all
				      of
				    true ->
					bit_size(Q) rem
					  lists:nth(4, element(4, Val))
					  =:= 0;
				    _ ->
					getmem(State,
					       lists:nth(3, element(4, Val)))
					  >= 0
					  andalso
					  bit_size(Q) >=
					    getmem(State,
						   lists:nth(3,
							     element(4, Val)))
					      * lists:nth(4, element(4, Val))
				  end,
			   if Cond ->
				  X = case getmem(State,
						  lists:nth(3, element(4, Val)))
					     =:= all
					  of
					true -> Q;
					_ ->
					    get_bits(Q,
						     getmem(State,
							    lists:nth(3,
								      element(4,
									      Val)))
						       *
						       lists:nth(4,
								 element(4,
									 Val)))
				      end,
				  Y = case getmem(State,
						  lists:nth(3, element(4, Val)))
					     =:= all
					  of
					true -> <<>>;
					_ ->
					    skip_bits(Q,
						      getmem(State,
							     lists:nth(3,
								       element(4,
									       Val)))
							*
							lists:nth(4,
								  element(4,
									  Val)))
				      end,
				  NewState = setmem(setmem(State,
							   hd(element(4, Val)),
							   {Y, Z}),
						    lists:nth(6,
							      element(4, Val)),
						    X);
			      true -> NewState = State
			   end,
			   Cond;
		       bs_match_string ->
			   {Q, Z} = getmem(State, hd(element(4, Val))),
			   Cond = bit_size(Q) >= lists:nth(2, element(4, Val))
				    andalso
				    get_bits(Q, lists:nth(2, element(4, Val)))
				      =:= lists:nth(3, element(4, Val)),
			   if Cond ->
				  Y = skip_bits(Q,
						lists:nth(2, element(4, Val))),
				  NewState = setmem(State, hd(element(4, Val)),
						    {Y, Z});
			      true -> NewState = State
			   end,
			   Cond
		     end
		    of
		  true ->
		      exec_step(setelement(1, NewState, tl(RemainingCode)));
		  _ ->
		      InstList = getmem(State, element(3, Val)),
		      if InstList =:= [] ->
			     emulate(erlang, error, [function_clause], State);
			 true -> exec_step(setelement(1, NewState, InstList))
		      end
		end;
	    move ->
		exec_step(setelement(1,
				     setmem(State, element(3, Val),
					    getmem(State, element(2, Val))),
				     tl(RemainingCode)));
	    fmove ->
		exec_step(setelement(1,
				     setmem(State, element(3, Val),
					    getmem(State, element(2, Val))),
				     tl(RemainingCode)));
	    fconv ->
		exec_step(setelement(1,
				     setmem(State, element(3, Val),
					    getmem(State, element(2, Val))),
				     tl(RemainingCode)));
	    get_tuple_element ->
		exec_step(setelement(1,
				     setmem(State, element(4, Val),
					    element(element(3, Val) + 1,
						    getmem(State,
							   element(2, Val)))),
				     tl(RemainingCode)));
	    set_tuple_element ->
		exec_step(setelement(1,
				     setmem(State, element(3, Val),
					    setelement(element(4, Val) + 1,
						       getmem(State,
							      element(3, Val)),
						       getmem(State,
							      element(2,
								      Val)))),
				     tl(RemainingCode)));
	    put_tuple ->
		exec_step(setelement(1,
				     setmem(State, element(3, Val),
					    list_to_tuple(get_tuple_puts(setelement(1,
										    State,
										    tl(RemainingCode)),
									 element(2,
										 Val)))),
				     lists:sublist(element(1, State),
						   2 + element(2, Val),
						   length(RemainingCode))));
	    get_list ->
		exec_step(setelement(1,
				     setmem(setmem(State, element(3, Val),
						   hd(getmem(State,
							     element(2, Val)))),
					    element(4, Val),
					    tl(getmem(State, element(2, Val)))),
				     tl(RemainingCode)));
	    put_list ->
		exec_step(setelement(1,
				     setmem(State, element(4, Val),
					    [getmem(State, element(2, Val))
					     | getmem(State, element(3, Val))]),
				     tl(RemainingCode)));
	    bs_init2 ->
		{Bin, InstCount} = get_binary_puts(setelement(1, State,
							      tl(RemainingCode)),
						   <<>>,
						   if is_tuple(element(3,
								       Val)) ->
							  getmem(State,
								 element(3,
									 Val));
						      true -> element(3, Val)
						   end
						     * 8,
						   0),
		exec_step(setelement(1,
				     setmem(State, element(7, Val), Bin),
				     lists:sublist(element(1, State),
						   2 + InstCount,
						   length(RemainingCode))));
	    bs_init_bits ->
		{Bin, InstCount} = get_binary_puts(setelement(1, State,
							      tl(RemainingCode)),
						   <<>>,
						   if is_tuple(element(3,
								       Val)) ->
							  getmem(State,
								 element(3,
									 Val));
						      true -> element(3, Val)
						   end,
						   0),
		exec_step(setelement(1,
				     setmem(State, element(7, Val), Bin),
				     lists:sublist(element(1, State),
						   2 + InstCount,
						   length(RemainingCode))));
	    bs_append ->
		{Bin, InstCount} = get_binary_puts(setelement(1, State,
							      tl(RemainingCode)),
						   getmem(State,
							  element(7, Val)),
						   getmem(State,
							  element(3, Val)),
						   0),
		exec_step(setelement(1,
				     setmem(State, element(9, Val), Bin),
				     lists:sublist(element(1, State),
						   2 + InstCount,
						   length(RemainingCode))));
	    bs_private_append ->
		{Bin, InstCount} = get_binary_puts(setelement(1, State,
							      tl(RemainingCode)),
						   getmem(State,
							  element(5, Val)),
						   getmem(State,
							  element(3, Val)),
						   0),
		exec_step(setelement(1,
				     setmem(State, element(7, Val), Bin),
				     lists:sublist(element(1, State),
						   2 + InstCount,
						   length(RemainingCode))));
	    bs_add ->
		exec_step(setelement(1,
				     setmem(State, element(4, Val),
					    getmem(State, hd(element(3, Val))) +
					      getmem(State,
						     lists:nth(2,
							       element(3, Val)))
						*
						lists:nth(3, element(3, Val))),
				     tl(RemainingCode)));
	    bs_utf8_size ->
		X = getmem(State, element(3, Val)),
		exec_step(setelement(1,
				     setmem(State, element(4, Val),
					    if X < 128 -> 1;
					       X < 2048 -> 2;
					       X < 65536 -> 3;
					       true -> 4
					    end),
				     tl(RemainingCode)));
	    bs_utf16_size ->
		X = getmem(State, element(3, Val)),
		exec_step(setelement(1,
				     setmem(State, element(4, Val),
					    if X >= 65536 -> 4;
					       true -> 2
					    end),
				     tl(RemainingCode)));
	    bs_save2 ->
		{X, _} = getmem(State, element(2, Val)),
		exec_step(setelement(1,
				     setmem(State, element(2, Val),
					    {X,
					     case getmem(State, element(3, Val))
						 of
					       start -> X;
					       _ -> X
					     end}),
				     tl(RemainingCode)));
	    bs_restore2 ->
		{_, X} = getmem(State, element(2, Val)),
		exec_step(setelement(1,
				     setmem(State, element(2, Val),
					    {case getmem(State, element(3, Val))
						 of
					       start -> X;
					       _ -> X
					     end,
					     X}),
				     tl(RemainingCode)));
	    bs_context_to_binary ->
		exec_step(setelement(1,
				     case getmem(State, element(2, Val)) of
				       {X, _} ->
					   setmem(State, element(2, Val), X);
				       _ -> State
				     end,
				     tl(RemainingCode)));
	    get_map_elements ->
		exec_step(setelement(1,
				     element(1,
					     lists:foldl(fun (El,
							      {Acc, Next}) ->
								 if Next =:=
								      [] ->
									{Acc,
									 [getmem(State,
										 El)]};
								    true ->
									{setmem(Acc,
										El,
										maps:get(hd(Next),
											 getmem(State,
												element(3,
													Val)))),
									 []}
								 end
							 end,
							 {State, []},
							 getmem(State,
								element(4,
									Val)))),
				     tl(RemainingCode)));
	    put_map_exact ->
		exec_step(setelement(1,
				     element(1,
					     lists:foldl(fun (El,
							      {Acc, Next}) ->
								 if Next =:=
								      [] ->
									{Acc,
									 [getmem(State,
										 El)]};
								    true ->
									{setmem(Acc,
										element(4,
											Val),
										maps:update(hd(Next),
											    getmem(Acc,
												   El),
											    getmem(Acc,
												   element(4,
													   Val)))),
									 []}
								 end
							 end,
							 {setmem(State,
								 element(4,
									 Val),
								 getmem(State,
									element(3,
										Val))),
							  []},
							 getmem(State,
								element(6,
									Val)))),
				     tl(RemainingCode)));
	    put_map_assoc ->
		exec_step(setelement(1,
				     element(1,
					     lists:foldl(fun (El,
							      {Acc, Next}) ->
								 if Next =:=
								      [] ->
									{Acc,
									 [getmem(State,
										 El)]};
								    true ->
									{setmem(Acc,
										element(4,
											Val),
										maps:put(hd(Next),
											 getmem(Acc,
												El),
											 getmem(Acc,
												element(4,
													Val)))),
									 []}
								 end
							 end,
							 {setmem(State,
								 element(4,
									 Val),
								 getmem(State,
									element(3,
										Val))),
							  []},
							 getmem(State,
								element(6,
									Val)))),
				     tl(RemainingCode)));
	    arithfbif ->
		case element(2, Val) of
		  fadd ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    +
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  fsub ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    -
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  fmul ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    *
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  fdiv ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    /
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  fnegate ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  -getmem(State,
							  hd(element(4, Val)))),
					   tl(RemainingCode)))
		end;
	    bif ->
		case element(2, Val) of
		  '==' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    ==
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '<' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    <
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '=<' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    =<
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '>' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    >
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '>=' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    >=
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '=:=' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    =:=
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '/=' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    /=
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  '=/=' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    =/=
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  'not' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  not
						    getmem(State,
							   hd(element(4,
								      Val)))),
					   tl(RemainingCode)));
		  'and' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    and
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  'or' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    or
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  'xor' ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  getmem(State,
							 hd(element(4, Val)))
						    xor
						    getmem(State,
							   lists:nth(2,
								     element(4,
									     Val)))),
					   tl(RemainingCode)));
		  is_integer ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_integer(getmem(State,
								    hd(element(4,
									       Val))))),
					   tl(RemainingCode)));
		  is_float ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_float(getmem(State,
								  hd(element(4,
									     Val))))),
					   tl(RemainingCode)));
		  is_number ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_number(getmem(State,
								   hd(element(4,
									      Val))))),
					   tl(RemainingCode)));
		  is_pid ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_pid(getmem(State,
								hd(element(4,
									   Val))))),
					   tl(RemainingCode)));
		  is_reference ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_reference(getmem(State,
								      hd(element(4,
										 Val))))),
					   tl(RemainingCode)));
		  is_port ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_port(getmem(State,
								 hd(element(4,
									    Val))))),
					   tl(RemainingCode)));
		  is_boolean ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_boolean(getmem(State,
								    hd(element(4,
									       Val))))),
					   tl(RemainingCode)));
		  is_binary ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_binary(getmem(State,
								   hd(element(4,
									      Val))))),
					   tl(RemainingCode)));
		  is_bitstring ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_bitstring(getmem(State,
								      hd(element(4,
										 Val))))),
					   tl(RemainingCode)));
		  is_list ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_list(getmem(State,
								 hd(element(4,
									    Val))))),
					   tl(RemainingCode)));
		  is_atom ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_atom(getmem(State,
								 hd(element(4,
									    Val))))),
					   tl(RemainingCode)));
		  is_tuple ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_tuple(getmem(State,
								  hd(element(4,
									     Val))))),
					   tl(RemainingCode)));
		  is_function ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  if length(element(4, Val)) =:=
						       2 ->
							 is_function(getmem(State,
									    hd(element(4,
										       Val))),
								     getmem(State,
									    lists:nth(2,
										      element(4,
											      Val))));
						     true ->
							 is_function(getmem(State,
									    hd(element(4,
										       Val))))
						  end),
					   tl(RemainingCode)));
		  is_map ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  is_map(getmem(State,
								hd(element(4,
									   Val))))),
					   tl(RemainingCode)));
		  get ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  get(getmem(State,
							     hd(element(4,
									Val))))),
					   tl(RemainingCode)));
		  node ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  node()),
					   tl(RemainingCode)));
		  tuple_size ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  tuple_size(getmem(State,
								    hd(element(4,
									       Val))))),
					   tl(RemainingCode)));
		  element ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  element(getmem(State,
								 hd(element(4,
									    Val))),
							  getmem(State,
								 lists:nth(2,
									   element(4,
										   Val))))),
					   tl(RemainingCode)));
		  hd ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  hd(getmem(State,
							    hd(element(4,
								       Val))))),
					   tl(RemainingCode)));
		  tl ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  tl(getmem(State,
							    hd(element(4,
								       Val))))),
					   tl(RemainingCode)));
		  self ->
		      exec_step(setelement(1,
					   setmem(State, element(5, Val),
						  self()),
					   tl(RemainingCode)))
		end;
	    gc_bif ->
		case element(2, Val) of
		  '+' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    +
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  '-' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  if length(element(5, Val)) =:=
						       1 ->
							 -getmem(State,
								 hd(element(5,
									    Val)));
						     true ->
							 getmem(State,
								hd(element(5,
									   Val)))
							   -
							   getmem(State,
								  lists:nth(2,
									    element(5,
										    Val)))
						  end),
					   tl(RemainingCode)));
		  '*' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    *
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  '/' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    /
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  length ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  length(getmem(State,
								hd(element(5,
									   Val))))),
					   tl(RemainingCode)));
		  size ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  size(getmem(State,
							      hd(element(5,
									 Val))))),
					   tl(RemainingCode)));
		  map_size ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  map_size(getmem(State,
								  hd(element(5,
									     Val))))),
					   tl(RemainingCode)));
		  bit_size ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  bit_size(getmem(State,
								  hd(element(5,
									     Val))))),
					   tl(RemainingCode)));
		  byte_size ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  byte_size(getmem(State,
								   hd(element(5,
									      Val))))),
					   tl(RemainingCode)));
		  round ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  round(getmem(State,
							       hd(element(5,
									  Val))))),
					   tl(RemainingCode)));
		  'div' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    div
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'rem' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    rem
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'band' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    band
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'bor' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    bor
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'bxor' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    bxor
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'bsl' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    bsl
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'bsr' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  getmem(State,
							 hd(element(5, Val)))
						    bsr
						    getmem(State,
							   lists:nth(2,
								     element(5,
									     Val)))),
					   tl(RemainingCode)));
		  'bnot' ->
		      exec_step(setelement(1,
					   setmem(State, element(6, Val),
						  bnot
						    getmem(State,
							   hd(element(5,
								      Val)))),
					   tl(RemainingCode)))
		end;
	    init ->
		exec_step(setelement(1,
				     setmem(State, element(2, Val), []),
				     tl(RemainingCode)));
	    trim ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:sublist(element(3, State),
							      element(2, Val) +
								1,
							      length(element(3,
									     State)))),
				     tl(RemainingCode)));
	    allocate_zero ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:duplicate(element(2, Val),
								[])
						  ++ element(3, State)),
				     tl(RemainingCode)));
	    allocate_heap ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:duplicate(element(2, Val),
								undefined)
						  ++ element(3, State)),
				     tl(RemainingCode)));
	    allocate_heap_zero ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:duplicate(element(2, Val),
								[])
						  ++ element(3, State)),
				     tl(RemainingCode)));
	    allocate ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:duplicate(element(2, Val),
								undefined)
						  ++ element(3, State)),
				     tl(RemainingCode)));
	    deallocate ->
		exec_step(setelement(1,
				     setelement(3, State,
						lists:sublist(element(3, State),
							      element(2, Val) +
								1,
							      length(element(3,
									     State)))),
				     tl(RemainingCode)));
	    jump ->
		InstList = getmem(State, element(2, Val)),
		if InstList =:= [] ->
		       emulate(erlang, error, [function_clause], State);
		   true -> exec_step(setelement(1, State, InstList))
		end;
	    apply ->
		exec_step(setelement(1,
				     emulate(getmem(State,
						    {x, element(2, Val)}),
					     getmem(State,
						    {x, element(2, Val) + 1}),
					     lists:sublist(element(2, State),
							   element(2, Val)),
					     State),
				     tl(RemainingCode)));
	    apply_last ->
		emulate(getmem(State, {x, element(2, Val)}),
			getmem(State, {x, element(2, Val) + 1}),
			lists:sublist(element(2, State), element(2, Val)),
			setelement(3, State,
				   lists:sublist(element(3, State),
						 element(3, Val) + 1,
						 length(element(3, State)))));
	    call ->
		exec_step(setelement(1,
				     emulate(element(1, element(3, Val)),
					     element(2, element(3, Val)),
					     lists:sublist(element(2, State),
							   element(3,
								   element(3,
									   Val))),
					     State),
				     tl(RemainingCode)));
	    call_only ->
		emulate(element(1, element(3, Val)),
			element(2, element(3, Val)),
			lists:sublist(element(2, State),
				      element(3, element(3, Val))),
			State);
	    call_last ->
		emulate(element(1, element(3, Val)),
			element(2, element(3, Val)),
			lists:sublist(element(2, State),
				      element(3, element(3, Val))),
			setelement(3, State,
				   lists:sublist(element(3, State),
						 element(4, Val) + 1,
						 length(element(3, State)))));
	    call_ext ->
		exec_step(setelement(1,
				     emulate(element(2, element(3, Val)),
					     element(3, element(3, Val)),
					     lists:sublist(element(2, State),
							   element(4,
								   element(3,
									   Val))),
					     State),
				     tl(RemainingCode)));
	    call_ext_only ->
		emulate(element(2, element(3, Val)),
			element(3, element(3, Val)),
			lists:sublist(element(2, State),
				      element(4, element(3, Val))),
			State);
	    call_ext_last ->
		emulate(element(2, element(3, Val)),
			element(3, element(3, Val)),
			lists:sublist(element(2, State),
				      element(4, element(3, Val))),
			setelement(3, State,
				   emulate(element(3, State),
					   element(4, Val) + 1,
					   length(element(3, State)))));
	    call_fun ->
		exec_step(setelement(1,
				     case element(2,
						  erlang:fun_info(getmem(State,
									 {x,
									  element(2,
										  Val)}),
								  module))
					    =:= emulator
					    andalso
					    lists:prefix("-fun_arglist/",
							 atom_to_list(element(2,
									      erlang:fun_info(getmem(State,
												     {x,
												      element(2,
													      Val)}),
											      name))))
					 of
				       true ->
					   setmem(State, {x, 0},
						  apply(getmem(State,
							       {x,
								element(2,
									Val)}),
							lists:sublist(element(2,
									      State),
								      1,
								      element(2,
									      Val))));
				       _ ->
					   case element(2,
							erlang:fun_info(getmem(State,
									       {x,
										element(2,
											Val)}),
									type))
						  =:= external
						  orelse
						  element(2,
							  erlang:fun_info(getmem(State,
										 {x,
										  element(2,
											  Val)}),
									  module))
						    =/= erl_eval
					       of
					     true ->
						 emulate(element(2,
								 erlang:fun_info(getmem(State,
											{x,
											 element(2,
												 Val)}),
										 module)),
							 element(2,
								 erlang:fun_info(getmem(State,
											{x,
											 element(2,
												 Val)}),
										 name)),
							 lists:sublist(element(2,
									       State),
								       1,
								       element(2,
									       Val))
							   ++
							   element(2,
								   erlang:fun_info(getmem(State,
											  {x,
											   element(2,
												   Val)}),
										   env)));
					     _ ->
						 UI = erlang:unique_integer(),
						 Name = list_to_atom(StrName =
									 "emu"
									   ++
									   string:strip(integer_to_list(UI),
											left,
											$-)),
						 {ok, MTs, _} =
						     erl_scan:string("-module("
								       ++
								       StrName
									 ++
									 ")."),
						 {ok, ETs, _} =
						     erl_scan:string("-export([f/"
								       ++
								       integer_to_list(element(2,
											       erlang:fun_info(getmem(State,
														      {x,
														       element(2,
															       Val)}),
													       arity)))
									 ++
									 "])."),
						 {ok, FTs, _} =
						     erl_scan:string("f" ++
								       erl_prettypr:format(erl_syntax:form_list(element(4,
															hd(element(2,
																   erlang:fun_info(getmem(State,
																			  {x,
																			   element(2,
																				   Val)}),
																		   env))))))
									 ++
									 "."),
						 {ok, MF} =
						     erl_parse:parse_form(MTs),
						 {ok, EF} =
						     erl_parse:parse_form(ETs),
						 {ok, FF} =
						     erl_parse:parse_form(FTs),
						 {ok, Name, Bin} =
						     compile:forms([MF, EF, FF],
								   [binary]),
						 emulate(beam_disasm:file(Bin),
							 Name, f,
							 lists:sublist(element(2,
									       State),
								       1,
								       element(2,
									       Val)),
							 State)
					   end
				     end,
				     tl(RemainingCode)));
	    make_fun2 ->
		exec_step(setelement(1,
				     setmem(State, {x, 0},
					    fun_arglist(fun (Args) ->
								getmem(emulate(element(1,
										       element(2,
											       Val)),
									       element(2,
										       element(2,
											       Val)),
									       Args
										 ++
										 lists:sublist(element(2,
												       State),
											       1,
											       element(5,
												       Val)),
									       State),
								       {x, 0})
							end,
							element(3,
								element(2, Val))
							  - element(5, Val))),
				     tl(RemainingCode)))
	  end
    end.

emulate(Beam, Filename, Funcname, Params, State) ->
    erlang:display([Filename, Funcname, length(Params)]),
    Func = hd(lists:dropwhile(fun (Elem) ->
				      element(2, Elem) =/= Funcname orelse
					element(3, Elem) =/= length(Params)
			      end,
			      element(6, Beam))),
    InstList = lists:dropwhile(fun (Elem) ->
				       is_atom(Elem) orelse
					 element(1, Elem) =/= label orelse
					   element(2, Elem) =/= element(4, Func)
			       end,
			       element(5, Func)),
    setelement(7,
	       setelement(5,
			  exec_step(setelement(8,
					       setelement(7,
							  setelement(5,
								     setelement(1,
										setelement(2,
											   State,
											   Params
											     ++
											     lists:sublist(element(2,
														   State),
													   length(Params)
													     +
													     1,
													   1024)),
										InstList),
								     [-1
								      | element(5,
										State)]),
							  [{Filename, Funcname,
							    length(Params),
							    if length(element(5,
									      State))
								 =:= 0 ->
								   [];
							       true ->
								   [{file,
								     atom_to_list(Filename)
								       ++
								       ".erl"},
								    {line,
								     hd(element(5,
										State))}]
							    end}
							   | element(7,
								     State)]),
					       InstList)),
			  element(5, State)),
	       element(7, State)).

emulate(Filename, Funcname, Params, State) ->
    case erlang:is_builtin(Filename, Funcname,
			   length(Params))
	of
      true ->
	  if Filename =:= erlang andalso
	       Funcname =:= get_stacktrace andalso
		 length(Params) =:= 0 ->
		 setmem(State, {x, 0},
			element(7, State) ++
			  lists:foldl(fun (Elem, Acc) ->
					      if Elem =:=
						   {emulator, emulate, 3,
						    [{file, "emulator.erl"},
						     {line, 1204 + 23}]} ->
						     [];
						 true -> Acc ++ [Elem]
					      end
				      end,
				      [],
				      erlang:apply(Filename, Funcname,
						   Params)));
	     Filename =:= erlang andalso
	       Funcname =:= spawn andalso length(Params) =:= 3 ->
		 setmem(State, {x, 0},
			spawn(emulator, emulate, Params ++ [State]));
	     Filename =:= erlang andalso
	       Funcname =:= spawn andalso length(Params) =:= 4 ->
		 setmem(State, {x, 0},
			spawn(hd(Params), emulator, emulate,
			      tl(Params) ++ [State]));
	     Filename =:= erlang andalso
	       Funcname =:= spawn_link andalso length(Params) =:= 3 ->
		 setmem(State, {x, 0},
			spawn_link(emulator, emulate, Params ++ [State]));
	     Filename =:= erlang andalso
	       Funcname =:= spawn_link andalso length(Params) =:= 4 ->
		 setmem(State, {x, 0},
			spawn_link(hd(Params), emulator, emulate,
				   tl(Params) ++ [State]));
	     Filename =:= erlang andalso
	       Funcname =:= spawn_monitor andalso
		 length(Params) =:= 3 ->
		 setmem(State, {x, 0},
			spawn_monitor(emulator, emulate, Params ++ [State]));
	     Filename =:= erlang andalso
	       Funcname =:= spawn_opt andalso length(Params) =:= 4 ->
		 setmem(State, {x, 0},
			spawn_opt(emulator, emulate,
				  lists:droplast(Params) ++ [State],
				  lists:last(Params)));
	     Filename =:= erlang andalso
	       Funcname =:= spawn_opt andalso length(Params) =:= 5 ->
		 setmem(State, {x, 0},
			spawn_opt(hd(Params), emulator, emulate,
				  lists:droplast(tl(Params)) ++ [State],
				  lists:last(Params)));
	     true ->
		 setmem(State, {x, 0},
			erlang:apply(Filename, Funcname, Params))
	  end;
      _ ->
	  Path = hd(lists:dropwhile(fun (Elem) ->
					    case beam_disasm:file(Elem ++
								    "/" ++
								      atom_to_list(Filename))
						of
					      {error, beam_lib,
					       {file_error, _, enoent}} ->
						  true;
					      _ -> false
					    end
				    end,
				    code:get_path())),
	  emulate(beam_disasm:file(Path ++
				     "/" ++ atom_to_list(Filename)),
		  Filename, Funcname, Params, State)
    end.

emulate(Filename, Funcname, Params) ->
    getmem(emulate(Filename, Funcname, Params,
		   {[], lists:duplicate(1024, []), [],
		    lists:duplicate(16, []), [], [], [], []}),
	   {x, 0}).

getliteral(Lit) ->
    if is_integer(Lit) -> {integer, 0, Lit};
       is_atom(Lit) -> {atom, 0, Lit};
       is_float(Lit) -> {float, 0, Lit};
       is_tuple(Lit) ->
	   {tuple, 0,
	    lists:map(fun (Elem) -> getliteral(Elem) end,
		      tuple_to_list(Lit))};
       is_list(Lit) ->
	   IsLatin1 = true,
	   case length(Lit) =/= 0 andalso
		  lists:all(fun (Elem) ->
				    is_integer(Elem) andalso
				      Elem >= 32 andalso Elem =< 126
				      orelse
				      IsLatin1 andalso
					Elem >= 128 + 32 andalso Elem =< 255
					orelse
					Elem =:= 10 orelse
					  Elem =:= 9 orelse Elem =:= 13
			    end,
			    Lit)
	       of
	     true ->
		 {string, 0, lists:flatten(io_lib:format("~s", [Lit]))};
	     _ ->
		 lists:foldr(fun (Elem, Acc) ->
				     {cons, 0, getliteral(Elem), Acc}
			     end,
			     {nil, 0}, Lit)
	   end;
       is_tuple(Lit) ->
	   {tuple, 0,
	    lists:map(fun (Elem) ->
			      if is_list(Elem) orelse is_tuple(Elem) ->
				     getliteral(Elem);
				 true -> getliteral(Elem)
			      end
		      end,
		      tuple_to_list(Lit))};
       is_binary(Lit) ->
	   {bin, 0,
	    [{bin_element, 0, getliteral(X), default, default}
	     || X <- binary_to_list(Lit)]};
       is_bitstring(Lit) ->
	   BL = bitstring_to_list(Lit),
	   S = bit_size(lists:last(BL)),
	   <<N:S/integer>> = lists:last(BL),
	   {bin, 0,
	    [{bin_element, 0, getliteral(X), default, default}
	     || X <- lists:droplast(BL)]
	      ++
	      [{bin_element, 0, {integer, 0, N}, {integer, 0, S},
		default}]};
       is_map(Lit) ->
	   {map, 0,
	    [{map_field_assoc, 0, getliteral(K), getliteral(V)}
	     || {K, V} <- maps:to_list(Lit)]}
    end.

getmemd(Graph, Where) ->
    if Where =:= nil -> {nil, 0};
       true ->
	   case element(1, Where) of
	     integer ->
		 if element(2, Where) < 0 ->
			{op, 0, '-', {integer, 0, -element(2, Where)}};
		    true -> {integer, 0, element(2, Where)}
		 end;
	     atom -> {atom, 0, element(2, Where)};
	     float ->
		 if element(2, Where) < 0 ->
			{op, 0, '-', {float, 0, -element(2, Where)}};
		    true -> {float, 0, element(2, Where)}
		 end;
	     list -> element(2, Where);
	     literal -> getliteral(element(2, Where));
	     x ->
		 lists:nth(element(2, Where) + 1, element(3, Graph));
	     y ->
		 if element(2, Where) + 1 > length(element(4, Graph)) ->
			error({unresolved, Where});
		    true ->
			lists:nth(element(2, Where) + 1, element(4, Graph))
		 end;
	     fr ->
		 lists:nth(element(2, Where) + 1, element(5, Graph))
	   end
    end.

setmemd(Graph, Where, Val) ->
    case element(1, Where) of
      x ->
	  setelement(3, Graph,
		     setnth(element(2, Where) + 1, element(3, Graph), Val));
      y ->
	  if element(2, Where) + 1 > length(element(4, Graph)) ->
		 setelement(4, Graph,
			    element(4, Graph) ++
			      if element(2, Where) >
				   length(element(4, Graph)) ->
				     [{unresolved, {y, Y}}
				      || Y
					     <- lists:seq(length(element(4,
									 Graph))
							    + 1,
							  element(2, Where))]
				       ++ [Val];
				 true -> [Val]
			      end);
	     true ->
		 setelement(4, Graph,
			    setnth(element(2, Where) + 1, element(4, Graph),
				   Val))
	  end;
      fr ->
	  setelement(5, Graph,
		     setnth(element(2, Where) + 1, element(5, Graph), Val))
    end.

get_tuple_putsd(Graph, State, Count) ->
    if Count =:= 0 -> [];
       true ->
	   Val = hd(element(1, State)),
	   erlang:display(Val),
	   case element(1, Val) of
	     put ->
		 [getmemd(Graph, element(2, Val))
		  | get_tuple_putsd(Graph,
				    setelement(1, State, tl(element(1, State))),
				    Count - 1)]
	   end
    end.

get_binary_sizes(Exp) ->
    if element(1, Exp) =:= integer -> [element(3, Exp)];
       true ->
	   case element(3, Exp) of
	     '*' ->
		 if element(1, element(4, Exp)) =:= integer andalso
		      element(1, element(5, Exp)) =:= integer ->
			[hd(get_binary_sizes(element(4, Exp))) *
			   hd(get_binary_sizes(element(5, Exp)))];
		    true ->
			[element(if element(1, element(4, Exp)) =:= integer ->
					5;
				    true -> 4
				 end,
				 Exp)
			 || _
				<- lists:seq(1,
					     hd(get_binary_sizes(element(if
									   element(1,
										   element(4,
											   Exp))
									     =:=
									     integer ->
									       4;
									   true ->
									       5
									 end,
									 Exp))))]
		 end;
	     '+' ->
		 get_binary_sizes(element(4, Exp)) ++
		   get_binary_sizes(element(5, Exp))
	   end
    end.

get_binary_flags(Flags) ->
    lists:append([if Flags band 2 =:= 2 -> [little];
		     true -> []
		  end,
		  if Flags band 4 =:= 4 -> [signed];
		     true -> []
		  end,
		  if Flags band 16 =:= 16 -> [native];
		     true -> []
		  end]).

get_binary_putsd(Graph, State, Items, Count) ->
    case lists:all(fun (El) -> is_integer(El) end, Items)
	   andalso lists:sum(Items) =:= 0
	of
      true -> {[], Count};
      _ ->
	  Val = hd(element(1, State)),
	  erlang:display({Val, Items}),
	  if element(1, Val) =:= bs_put_string ->
		 {Res, NewCount} = get_binary_putsd(Graph,
						    setelement(1, State,
							       tl(element(1,
									  State))),
						    [-(element(2, Val) * 8)
						     | Items],
						    Count + 1),
		 {[{bin_element, 0, {integer, 0, X}, default, default}
		   || X <- element(2, element(3, Val))]
		    ++ Res,
		  NewCount};
	     element(1, Val) =:= bs_put_utf8 ->
		 Size = [{'if', 0,
			  [{clause, 0, [],
			    [[{op, 0, '<', getmemd(Graph, element(4, Val)),
			       {integer, 0, 128}}]],
			    [{integer, 0, 1}]},
			   {clause, 0, [],
			    [[{op, 0, '<', getmemd(Graph, element(4, Val)),
			       {integer, 0, 2048}}]],
			    [{integer, 0, 2}]},
			   {clause, 0, [],
			    [[{op, 0, '<', getmemd(Graph, element(4, Val)),
			       {integer, 0, 65536}}]],
			    [{integer, 0, 3}]},
			   {clause, 0, [], [[{atom, 0, true}]],
			    [{integer, 0, 4}]}]}],
		 {Res, NewCount} = get_binary_putsd(Graph,
						    setelement(1, State,
							       tl(element(1,
									  State))),
						    lists:delete(hd(Size),
								 Items),
						    Count + 1),
		 {[{bin_element, 0, getmemd(Graph, element(4, Val)),
		    default,
		    [utf8 | get_binary_flags(element(2, element(3, Val)))]}
		   | Res],
		  NewCount};
	     element(1, Val) =:= bs_put_utf16 ->
		 Size = [{'if', 0,
			  [{clause, 0, [],
			    [[{op, 0, '>=', getmemd(Graph, element(4, Val)),
			       {integer, 0, 65536}}]],
			    [{integer, 0, 4}]},
			   {clause, 0, [], [[{atom, 0, true}]],
			    [{integer, 0, 2}]}]}],
		 {Res, NewCount} = get_binary_putsd(Graph,
						    setelement(1, State,
							       tl(element(1,
									  State))),
						    lists:delete(hd(Size),
								 Items),
						    Count + 1),
		 {[{bin_element, 0, getmemd(Graph, element(4, Val)),
		    default,
		    [utf16 | get_binary_flags(element(2, element(3, Val)))]}
		   | Res],
		  NewCount};
	     element(1, Val) =:= bs_put_utf32 ->
		 {Res, NewCount} = get_binary_putsd(Graph,
						    setelement(1, State,
							       tl(element(1,
									  State))),
						    [-32 | Items], Count + 1),
		 {[{bin_element, 0, getmemd(Graph, element(4, Val)),
		    default,
		    [utf32 | get_binary_flags(element(2, element(3, Val)))]}
		   | Res],
		  NewCount};
	     true ->
		 Size = case element(3, Val) of
			  {atom, all} ->
			      [{call, 0, {atom, 0, bit_size},
				[getmemd(Graph, element(6, Val))]}];
			  _ ->
			      case lists:member(getmemd(Graph, element(3, Val)),
						Items)
				  of
				true -> [getmemd(Graph, element(3, Val))];
				_ ->
				    get_binary_sizes(getmemd(Graph,
							     element(3, Val)))
			      end
			end,
		 {Res, NewCount} = get_binary_putsd(Graph,
						    setelement(1, State,
							       tl(element(1,
									  State))),
						    if is_integer(hd(Size)) ->
							   [-hd(Size) | Items];
						       true -> Items -- Size
						    end,
						    Count + 1),
		 {[case element(1, Val) of
		     bs_put_integer ->
			 {bin_element, 0, getmemd(Graph, element(6, Val)),
			  default,
			  [integer | get_binary_flags(element(2,
							      element(5,
								      Val)))]};
		     bs_put_binary ->
			 {bin_element, 0, getmemd(Graph, element(6, Val)),
			  default,
			  [binary | get_binary_flags(element(2,
							     element(5,
								     Val)))]};
		     bs_put_float ->
			 {bin_element, 0, getmemd(Graph, element(6, Val)),
			  default,
			  [float | get_binary_flags(element(2,
							    element(5, Val)))]}
		   end
		   | Res],
		  NewCount}
	  end
    end.

getgraphpath(Graph, Path) ->
    if length(Path) =:= 1 -> lists:nth(hd(Path), Graph);
       true ->
	   getgraphpath(element(hd(tl(Path)),
				lists:nth(hd(Path), Graph)),
			tl(tl(Path)))
    end.

setgraphpath(Graph, Path, Val) ->
    if length(Path) =:= 1 ->
	   if hd(Path) > length(Graph) -> Graph ++ [Val];
	      true -> setnth(hd(Path), Graph, Val)
	   end;
       true ->
	   setnth(hd(Path), Graph,
		  setelement(hd(tl(Path)), lists:nth(hd(Path), Graph),
			     setgraphpath(element(hd(tl(Path)),
						  lists:nth(hd(Path), Graph)),
					  tl(tl(Path)), Val)))
    end.

insertgraphpath(Graph, Path, Val) ->
    if length(Path) =:= 1 ->
	   if hd(Path) > length(Graph) -> Graph ++ [Val];
	      true ->
		  {Left, Right} = lists:split(hd(Path) - 1, Graph),
		  Left ++ [Val | Right]
	   end;
       true ->
	   setnth(hd(Path), Graph,
		  setelement(hd(tl(Path)), lists:nth(hd(Path), Graph),
			     insertgraphpath(element(hd(tl(Path)),
						     lists:nth(hd(Path),
							       Graph)),
					     tl(tl(Path)), Val)))
    end.

removegraphpath(Graph, Path) ->
    if length(Path) =:= 1 ->
	   if hd(Path) > length(Graph) -> Graph;
	      true ->
		  {Left, Right} = lists:split(hd(Path) - 1, Graph),
		  Left ++ tl(Right)
	   end;
       true ->
	   setnth(hd(Path), Graph,
		  setelement(hd(tl(Path)), lists:nth(hd(Path), Graph),
			     removegraphpath(element(hd(tl(Path)),
						     lists:nth(hd(Path),
							       Graph)),
					     tl(tl(Path)))))
    end.

addtolistoflists(Index, List, Val) ->
    if Index > length(List) ->
	   List ++
	     lists:duplicate(Index - length(List) - 1, []) ++
	       [[Val]];
       true ->
	   case lists:any(fun (Elem) -> Elem =:= Val end,
			  lists:nth(Index, List))
	       of
	     true -> List;
	     _ -> setnth(Index, List, [Val | lists:nth(Index, List)])
	   end
    end.

addtolistoflistsend(Index, List, Val) ->
    if Index > length(List) ->
	   List ++
	     lists:duplicate(Index - length(List) - 1, []) ++
	       [[Val]];
       true ->
	   case lists:any(fun (Elem) -> Elem =:= Val end,
			  lists:nth(Index, List))
	       of
	     true -> List;
	     _ ->
		 setnth(Index, List, lists:nth(Index, List) ++ [Val])
	   end
    end.

removefromlistoflists(Index, List, Val) ->
    setnth(Index, List,
	   lists:delete(Val, lists:nth(Index, List))).

addtolist(Index, List, Val) ->
    if Index > length(List) ->
	   List ++
	     lists:duplicate(Index - length(List) - 1, 0) ++ [Val];
       true -> setnth(Index, List, Val)
    end.

do_interval_dfs(Succ, RootIdx) ->
    element(1,
	    interval_dfs({{lists:duplicate(length(Succ), []),
			   lists:duplicate(length(Succ), [])},
			  1, 1},
			 Succ, RootIdx)).

interval_edge_dfs({{RDFS, DFS}, RVal, Val}, Succ,
		  CurNode, CurEdge) ->
    case CurNode > length(Succ) orelse
	   CurEdge > length(lists:nth(CurNode, Succ))
	of
      true -> {{RDFS, DFS}, RVal, Val};
      false ->
	  interval_edge_dfs(interval_dfs({{RDFS, DFS}, RVal, Val},
					 Succ,
					 lists:nth(CurEdge,
						   lists:nth(CurNode, Succ))),
			    Succ, CurNode, CurEdge + 1)
    end.

interval_dfs({{RDFS, DFS}, RVal, Val}, Succ, CurNode) ->
    case CurNode =< length(DFS) andalso
	   lists:nth(CurNode, DFS) =/= []
	of
      true -> {{RDFS, DFS}, RVal, Val};
      false ->
	  {{NewRDFS, NewDFS}, NewRVal, NewVal} =
	      interval_edge_dfs({{RDFS,
				  if CurNode =< length(DFS) ->
					 setnth(CurNode, DFS, Val);
				     true ->
					 DFS ++
					   lists:duplicate(CurNode - length(DFS)
							     - 1,
							   [])
					     ++ [Val]
				  end},
				 RVal, Val + 1},
				Succ, CurNode, 1),
	  {{setnth(CurNode, NewRDFS, NewRVal), NewDFS},
	   NewRVal + 1, NewVal}
    end.

do_dfs(Succ, RootIdx) ->
    element(1,
	    dfs({lists:duplicate(length(Succ), []), 1}, Succ,
		RootIdx)).

edge_dfs({DFS, Val}, Succ, CurNode, CurEdge) ->
    case CurNode > length(Succ) orelse
	   CurEdge > length(lists:nth(CurNode, Succ))
	of
      true -> {DFS, Val};
      false ->
	  edge_dfs(dfs({DFS, Val}, Succ,
		       lists:nth(CurEdge, lists:nth(CurNode, Succ))),
		   Succ, CurNode, CurEdge + 1)
    end.

dfs({DFS, Val}, Succ, CurNode) ->
    case CurNode =< length(DFS) andalso
	   lists:nth(CurNode, DFS) =/= []
	of
      true -> {DFS, Val};
      false ->
	  edge_dfs({if CurNode =< length(DFS) ->
			   setnth(CurNode, DFS, Val);
		       true ->
			   DFS ++
			     lists:duplicate(CurNode - length(DFS) - 1, []) ++
			       [Val]
		    end,
		    Val + 1},
		   Succ, CurNode, 1)
    end.

simple_link(V, W,
	    {Semi, Idom, Ancestor, Best, Bucket}) ->
    {Semi, Idom, setnth(W, Ancestor, V), Best, Bucket}.

simple_evalhf(Semi, Ancestor, V, A) ->
    case A =/= 0 of
      true ->
	  simple_evalhf(Semi, Ancestor,
			case lists:nth(V, Semi) > lists:nth(A, Semi) of
			  true -> A;
			  false -> V
			end,
			lists:nth(A, Ancestor));
      false -> V
    end.

simple_eval(V, {Semi, _, Ancestor, _, _}) ->
    simple_evalhf(Semi, Ancestor, V,
		  lists:nth(V, Ancestor)).

do_tarjan_immdom(Succ, Pred, RootIdx) ->
    DFS = do_dfs(Succ, RootIdx),
    element(2,
	    tarjan_immdom4(DFS, Succ, Pred,
			   tarjan_immdom1(DFS, Succ, Pred,
					  {DFS, lists:duplicate(length(DFS), 0),
					   lists:duplicate(length(DFS), 0),
					   lists:seq(1, length(DFS)),
					   lists:duplicate(length(DFS), [])},
					  length(DFS)),
			   RootIdx, 2)).

check_succ(_, [], _) -> true;
check_succ(Num, [[] | Succ], Pred) ->
    check_succ(Num + 1, Succ, Pred);
check_succ(Num, [[C | Cs] | Succ], Pred) ->
    lists:any(fun (A) -> A =:= Num end, lists:nth(C, Pred))
      andalso check_succ(Num, [Cs | Succ], Pred).

check_pred_succ(Succ, Pred) ->
    check_succ(1, Succ, Pred) andalso
      check_succ(1, Pred, Succ).

do_dfs_parent(DFS, Pred, Parent) ->
    if length(DFS) =:= length(Parent) -> Parent;
       true ->
	   case length(Parent) =:= 0 orelse
		  lists:last(Parent) =:= 0 orelse
		    lists:any(fun (A) -> A =:= lists:last(Parent) end,
			      lists:nth(length(Parent), Pred))
	       of
	     true ->
		 do_dfs_parent(DFS, Pred,
			       Parent ++
				 [index_of(lists:nth(length(Parent) + 1, DFS) -
					     1,
					   DFS)]);
	     false ->
		 do_dfs_parent(DFS, Pred,
			       setnth(length(Parent), Parent,
				      index_of(lists:nth(lists:last(Parent),
							 DFS)
						 - 1,
					       DFS)))
	   end
    end.

do_get_dfs_parent(DFS, Pred, Node) ->
    get_dfs_parent(DFS, lists:nth(Node, Pred),
		   index_of(lists:nth(Node, DFS) - 1, DFS)).

get_dfs_parent(DFS, Preds, Idx) ->
    case Idx =:= 0 orelse
	   lists:any(fun (A) -> A =:= Idx end, Preds)
	of
      true -> Idx;
      false ->
	  get_dfs_parent(DFS, Preds,
			 index_of(lists:nth(Idx, DFS) - 1, DFS))
    end.

tarjan_immdom4(DFS, Succ, Pred,
	       {Semi, Idom, Ancestor, Best, Bucket}, RootIdx, W) ->
    if W =:= length(DFS) + 1 ->
	   {Semi, setnth(RootIdx, Idom, 0), Ancestor, Best,
	    Bucket};
       true ->
	   DepthW = index_of(W, DFS),
	   tarjan_immdom4(DFS, Succ, Pred,
			  {Semi,
			   case lists:nth(DepthW, Idom) =/=
				  index_of(lists:nth(DepthW, Semi), DFS)
			       of
			     true ->
				 setnth(DepthW, Idom,
					lists:nth(lists:nth(DepthW, Idom),
						  Idom));
			     false -> Idom
			   end,
			   Ancestor, Best, Bucket},
			  RootIdx, W + 1)
    end.

tarjan_immdom3({Semi, Idom, Ancestor, Best, Bucket}, P,
	       []) ->
    {Semi, Idom, Ancestor, Best, setnth(P, Bucket, [])};
tarjan_immdom3({Semi, Idom, Ancestor, Best, Bucket}, P,
	       [V | Vs]) ->
    U = simple_eval(V,
		    {Semi, Idom, Ancestor, Best, Bucket}),
    tarjan_immdom3({Semi,
		    setnth(V, Idom,
			   case lists:nth(U, Semi) < lists:nth(V, Semi) of
			     true -> U;
			     false -> P
			   end),
		    Ancestor, Best, Bucket},
		   P, Vs).

tarjan_immdom2(DFS,
	       {Semi, Idom, Ancestor, Best, Bucket}, W, P, []) ->
    NewBucket = addtolistoflists(index_of(lists:nth(W,
						    Semi),
					  DFS),
				 Bucket, W),
    simple_link(P, W,
		{Semi, Idom, Ancestor, Best, NewBucket});
tarjan_immdom2(DFS,
	       {Semi, Idom, Ancestor, Best, Bucket}, W, P, [V | Vs]) ->
    U = simple_eval(V,
		    {Semi, Idom, Ancestor, Best, Bucket}),
    NewSemi = case lists:nth(W, Semi) > lists:nth(U, Semi)
		  of
		true -> setnth(W, Semi, lists:nth(U, Semi));
		false -> Semi
	      end,
    tarjan_immdom2(DFS,
		   {NewSemi, Idom, Ancestor, Best, Bucket}, W, P, Vs).

index_of(Item, List) -> index_of(Item, List, 1).

index_of(_, [], _) -> 0;
index_of(Item, [Item | _], Index) -> Index;
index_of(Item, [_ | Tl], Index) ->
    index_of(Item, Tl, Index + 1).

tarjan_immdom1(DFS, Succ, Pred,
	       {Semi, Idom, Ancestor, Best, Bucket}, W) ->
    if W =:= 1 -> {Semi, Idom, Ancestor, Best, Bucket};
       true ->
	   DepthW = index_of(W, DFS),
	   P = do_get_dfs_parent(DFS, Pred, DepthW),
	   {NewSemi, _, NewAncestor, NewBest, NewBucket} =
	       tarjan_immdom2(DFS,
			      {Semi, Idom, Ancestor, Best, Bucket}, DepthW, P,
			      lists:nth(DepthW, Pred)),
	   tarjan_immdom1(DFS, Succ, Pred,
			  tarjan_immdom3({NewSemi, Idom, NewAncestor, NewBest,
					  NewBucket},
					 P, lists:nth(P, NewBucket)),
			  W - 1)
    end.

find_nc_nodes(DomNodes, Nodes, Pred, Dom, Top) ->
    {A, B} = lists:partition(fun (Elem) ->
				     Elem =:= Top orelse
				       lists:member(lists:nth(Elem, Dom),
						    DomNodes)
			     end,
			     Pred),
    lists:filter(fun (Elem) ->
			 Elem =:= Top orelse
			   not lists:member(lists:nth(Elem, Dom), Nodes)
		 end,
		 A)
      ++
      if B =:= [] -> B;
	 true ->
	     find_nc_nodes(DomNodes, Nodes,
			   lists:map(fun (Elem) -> lists:nth(Elem, Dom) end, B),
			   Dom, Top)
      end.

find_change_nodes(Change, Pred, Dom, AST, NodesToAST,
		  Top, Var, Idx) ->
    if length(Pred) =:= 0 -> Change;
       hd(Pred) =:= Top ->
	   find_change_nodes(Change, tl(Pred), Dom, AST,
			     NodesToAST, Top, Var, Idx);
       true ->
	   P = hd(Pred),
	   D = lists:nth(P, Dom),
	   Cur = getgraphpath(AST,
			      lists:last(lists:nth(P, NodesToAST))),
	   DGraph = getgraphpath(AST,
				 lists:last(lists:nth(D, NodesToAST))),
	   NotChanged = Idx > length(element(Var, Cur)) orelse
			  Idx > length(element(Var, DGraph)) orelse
			    lists:nth(Idx, element(Var, Cur)) =:= [] orelse
			      lists:nth(Idx, element(Var, DGraph)) =:= [] orelse
				lists:nth(Idx, element(Var, Cur)) =:=
				  lists:nth(Idx, element(Var, DGraph)),
	   find_change_nodes(if NotChanged -> Change;
				true -> [P | Change]
			     end,
			     if NotChanged ->
				    case lists:member(D, tl(Pred)) of
				      true -> tl(Pred);
				      _ -> tl(Pred) ++ [D]
				    end;
				true -> lists:delete(D, tl(Pred))
			     end,
			     Dom, AST, NodesToAST, Top, Var, Idx)
    end.

assign_var(AST, NodesToAST, Pred, Dom, Node,
	   AssignedVars, NumAsgn, VarIdx, VarPrefix, Elem, Idx) ->
    Nodes = find_change_nodes([], lists:nth(Node, Pred),
			      Dom, AST, NodesToAST, lists:nth(Node, Dom),
			      VarIdx, Idx),
    NCNodes = find_nc_nodes(lists:append(lists:map(fun
						     (X) -> pathtodom(Dom, X)
						   end,
						   Nodes)),
			    Nodes, lists:nth(Node, Pred) -- Nodes, Dom,
			    lists:nth(Node, Dom)),
    case Nodes =:= [lists:nth(Node, Dom)] orelse
	   Nodes =:= [] orelse
	     lists:any(fun (El) ->
			       Val = lists:nth(Idx,
					       element(VarIdx,
						       getgraphpath(AST,
								    lists:last(lists:nth(El,
											 NodesToAST))))),
			       Val =:= [] orelse
				 case Val of
				   {unresolved, {y, _}} -> true;
				   _ -> false
				 end
		       end,
		       Nodes ++ NCNodes)
	of
      true -> {Elem, {{AST, NodesToAST}, Idx + 1, NumAsgn}};
      false ->
	  TupLen = case lists:usort(lists:map(fun (El) ->
						      ElemPath =
							  lists:last(lists:nth(El,
									       NodesToAST)),
						      case lists:nth(Idx,
								     element(VarIdx,
									     getgraphpath(AST,
											  ElemPath)))
							  of
							{tuple, _, A} ->
							    length(A);
							_ -> 0
						      end
					      end,
					      Nodes ++ NCNodes))
		       of
		     [B] -> B;
		     _ -> 0
		   end,
	  Ident = lists:map(fun (TplIdx) ->
				    lists:usort(lists:map(fun (El) ->
								  ElemPath =
								      lists:last(lists:nth(El,
											   NodesToAST)),
								  lists:nth(TplIdx,
									    element(3,
										    lists:nth(Idx,
											      element(VarIdx,
												      getgraphpath(AST,
														   ElemPath)))))
							  end,
							  Nodes ++ NCNodes))
			    end,
			    lists:seq(1, TupLen)),
	  case lists:usort(lists:map(fun (El) ->
					     ElemPath = lists:last(lists:nth(El,
									     NodesToAST)),
					     case lists:nth(Idx,
							    element(VarIdx,
								    getgraphpath(AST,
										 ElemPath)))
						 of
					       {cons, _, A, _} -> A;
					       _ -> 0
					     end
				     end,
				     Nodes ++ NCNodes))
	      of
	    [C] when C =/= 0 ->
		{{cons, 0, C,
		  {var, 0,
		   list_to_atom(VarPrefix ++
				  "Var" ++
				    integer_to_list(AssignedVars + NumAsgn))}},
		 {lists:foldl(fun (El, A) ->
				      ElemPath = lists:last(lists:nth(El,
								      element(2,
									      A))),
				      insertgraphnode(insertgraphnode(A,
								      lists:droplast(ElemPath)
									++
									[getgraphpathlength(element(1,
												    A),
											    element(2,
												    A),
											    El)
									   + 1],
								      getgraphpath(element(1,
											   A),
										   ElemPath),
								      0, El),
						      lists:droplast(ElemPath)
							++
							[getgraphpathlength(element(1,
										    A),
									    element(2,
										    A),
									    El)
							   + 1],
						      {match, 0,
						       {cons, 0, C,
							{var, 0,
							 list_to_atom(VarPrefix
									++
									"Var" ++
									  integer_to_list(AssignedVars
											    +
											    NumAsgn))}},
						       lists:nth(Idx,
								 element(VarIdx,
									 getgraphpath(element(1,
											      A),
										      ElemPath)))},
						      0, 0)
			      end,
			      {AST, NodesToAST}, Nodes ++ NCNodes),
		  Idx + 1, NumAsgn + 1}};
	    _ ->
		case lists:any(fun (A) -> length(A) =:= 1 end, Ident) of
		  true ->
		      {{tuple, 0,
			element(1,
				lists:foldl(fun (X, {Y, Asgn}) ->
						    case length(lists:nth(X,
									  Ident))
							of
						      1 ->
							  {Y ++
							     [hd(lists:nth(X,
									   Ident))],
							   Asgn};
						      _ ->
							  {Y ++
							     [{var, 0,
							       list_to_atom(VarPrefix
									      ++
									      "Var"
										++
										integer_to_list(AssignedVars
												  +
												  NumAsgn
												  +
												  Asgn))}],
							   Asgn + 1}
						    end
					    end,
					    {[], 0}, lists:seq(1, TupLen)))},
		       {lists:foldl(fun (El, A) ->
					    ElemPath = lists:last(lists:nth(El,
									    element(2,
										    A))),
					    insertgraphnode(insertgraphnode(A,
									    lists:droplast(ElemPath)
									      ++
									      [getgraphpathlength(element(1,
													  A),
												  element(2,
													  A),
												  El)
										 +
										 1],
									    getgraphpath(element(1,
												 A),
											 ElemPath),
									    0,
									    El),
							    lists:droplast(ElemPath)
							      ++
							      [getgraphpathlength(element(1,
											  A),
										  element(2,
											  A),
										  El)
								 + 1],
							    {match, 0,
							     {tuple, 0,
							      element(1,
								      lists:foldl(fun
										    (X,
										     {Y,
										      Asgn}) ->
											case
											  length(lists:nth(X,
													   Ident))
											    of
											  1 ->
											      {Y
												 ++
												 [hd(lists:nth(X,
													       Ident))],
											       Asgn};
											  _ ->
											      {Y
												 ++
												 [{var,
												   0,
												   list_to_atom(VarPrefix
														  ++
														  "Var"
														    ++
														    integer_to_list(AssignedVars
																      +
																      NumAsgn
																      +
																      Asgn))}],
											       Asgn
												 +
												 1}
											end
										  end,
										  {[],
										   0},
										  lists:seq(1,
											    TupLen)))},
							     lists:nth(Idx,
								       element(VarIdx,
									       getgraphpath(element(1,
												    A),
											    ElemPath)))},
							    0, 0)
				    end,
				    {AST, NodesToAST}, Nodes ++ NCNodes),
			Idx + 1,
			NumAsgn +
			  lists:foldl(fun (X, Asgn) ->
					      case length(lists:nth(X, Ident))
						  of
						1 -> Asgn;
						_ -> Asgn + 1
					      end
				      end,
				      0, lists:seq(1, TupLen))}};
		  _ ->
		      {{var, 0,
			list_to_atom(VarPrefix ++
				       "Var" ++
					 integer_to_list(AssignedVars +
							   NumAsgn))},
		       {lists:foldl(fun (El, A) ->
					    ElemPath = lists:last(lists:nth(El,
									    element(2,
										    A))),
					    insertgraphnode(insertgraphnode(A,
									    lists:droplast(ElemPath)
									      ++
									      [getgraphpathlength(element(1,
													  A),
												  element(2,
													  A),
												  El)
										 +
										 1],
									    getgraphpath(element(1,
												 A),
											 ElemPath),
									    0,
									    El),
							    lists:droplast(ElemPath)
							      ++
							      [getgraphpathlength(element(1,
											  A),
										  element(2,
											  A),
										  El)
								 + 1],
							    {match, 0,
							     {var, 0,
							      list_to_atom(VarPrefix
									     ++
									     "Var"
									       ++
									       integer_to_list(AssignedVars
												 +
												 NumAsgn))},
							     lists:nth(Idx,
								       element(VarIdx,
									       getgraphpath(element(1,
												    A),
											    ElemPath)))},
							    0, 0)
				    end,
				    {AST, NodesToAST}, Nodes ++ NCNodes),
			Idx + 1, NumAsgn + 1}}
		end
	  end
    end.

assign_vars(AST, NodesToAST, Pred, Dom, Node,
	    AssignedVars, VarIdx, VarPrefix) ->
    Elements = if VarIdx =:= 4 ->
		      YLen = lists:max(lists:map(fun (Elem) ->
							 length(element(4,
									getgraphpath(AST,
										     lists:last(lists:nth(Elem,
													  NodesToAST)))))
						 end,
						 lists:nth(Node, Pred))),
		      YDom = element(4,
				     getgraphpath(AST,
						  lists:last(lists:nth(lists:nth(Node,
										 Dom),
								       NodesToAST)))),
		      YDom ++ lists:duplicate(YLen - length(YDom), []);
		  true ->
		      element(VarIdx,
			      getgraphpath(AST,
					   lists:last(lists:nth(lists:nth(Node,
									  Dom),
								NodesToAST))))
	       end,
    lists:mapfoldl(fun (Elem,
			{{CurAST, CurNodesToAST}, Idx, NumAsgn}) ->
			   assign_var(CurAST, CurNodesToAST, Pred, Dom, Node,
				      AssignedVars, NumAsgn, VarIdx, VarPrefix,
				      Elem, Idx)
		   end,
		   {{AST, NodesToAST}, 1, 0}, Elements).

insert_renumber([], _) -> [];
insert_renumber(NodesToAST, NodePath) ->
    [lists:map(fun (Elem) ->
		       case lists:prefix(lists:droplast(NodePath), Elem)
			      andalso
			      lists:nth(length(NodePath), Elem) >=
				lists:last(NodePath)
			   of
			 true ->
			     setnth(length(NodePath), Elem,
				    lists:nth(length(NodePath), Elem) + 1);
			 _ -> Elem
		       end
	       end,
	       hd(NodesToAST))
     | insert_renumber(tl(NodesToAST), NodePath)].

insertgraphnode({AST, NodesToAST}, NodePath, NewValue,
		MergeNode, NewNode) ->
    Renum = insert_renumber(NodesToAST, NodePath),
    {insertgraphpath(AST, NodePath, NewValue),
     if MergeNode =/= 0 ->
	    setnth(MergeNode, Renum, [NodePath]);
	true ->
	    if NewNode =/= 0 ->
		   setnth(NewNode, Renum,
			  lists:nth(NewNode, Renum) ++ [NodePath]);
	       true -> Renum
	    end
     end}.

check_nodes(_, []) -> true;
check_nodes(AST, NodesToAST) ->
    (hd(NodesToAST) =:= [[]] orelse
       lists:all(fun (Elem) ->
			 element(1, getgraphpath(AST, Elem)) =:= graphdata
		 end,
		 hd(NodesToAST)))
      andalso check_nodes(AST, tl(NodesToAST)).

hassideeffect(_Func, _Arity) -> true.

hassideeffect(Mod, Func, Arity) ->
    not
      (erl_bifs:is_pure(Mod, Func, Arity) orelse
	 erl_bifs:is_safe(Mod, Func, Arity)).

pathtodom(Tree, Node) ->
    El = lists:nth(Node, Tree),
    if El =:= 0 -> [Node];
       true -> [Node | pathtodom(Tree, El)]
    end.

getgraphpathlength(AST, NodesToAST, Node) ->
    X = lists:droplast(lists:last(lists:nth(Node,
					    NodesToAST))),
    Next = lists:append(lists:map(fun (Y) ->
					  lists:filtermap(fun (Z) ->
								  case
								    lists:prefix(X,
										 Z)
								      andalso
								      lists:last(lists:last(lists:nth(Node,
												      NodesToAST)))
									<
									lists:nth(length(X)
										    +
										    1,
										  Z)
								      of
								    true ->
									{true,
									 lists:nth(length(X)
										     +
										     1,
										   Z)};
								    _ -> false
								  end
							  end,
							  Y)
				  end,
				  lists:delete(lists:nth(Node, NodesToAST),
					       NodesToAST))),
    if length(Next) =:= 0 ->
	   length(element(lists:last(X),
			  getgraphpath(AST, lists:droplast(X))));
       true -> lists:min(Next) - 1
    end.

reduce_disp_graph_data({AST, []}) -> AST;
reduce_disp_graph_data({AST, NodesToAST}) ->
    reduce_disp_graph_data({if hd(NodesToAST) =:= [[]] ->
				   AST;
			       true ->
				   lists:foldr(fun (Elem, Acc) ->
						       Data = getgraphpath(Acc,
									   Elem),
						       setgraphpath(Acc, Elem,
								    setelement(5,
									       setelement(3,
											  Data,
											  lists:filter(fun
													 (El) ->
													     El
													       =/=
													       []
												       end,
												       element(3,
													       Data))),
									       lists:filter(fun
											      (El) ->
												  El
												    =/=
												    []
											    end,
											    element(5,
												    Data))))
					       end,
					       AST, hd(NodesToAST))
			    end,
			    tl(NodesToAST)}).

copy_graph_node({FromPath, ToPath, AST, NodesToAST,
		 Pred, Succ, Node}) ->
    case lists:last(hd(lists:nth(FromPath, NodesToAST))) =:=
	   getgraphpathlength(AST, NodesToAST, FromPath)
	of
      true ->
	  {AST, NodesToAST,
	   removefromlistoflists(FromPath,
				 addtolistoflists(Node, Pred, ToPath), ToPath),
	   removefromlistoflists(ToPath,
				 addtolistoflists(ToPath, Succ, Node),
				 FromPath)};
      _ ->
	  lists:foldl(fun (Z, Acc) ->
			      SubNodes = lists:filter(fun (Elem) ->
							      lists:any(fun
									  (El) ->
									      lists:prefix(lists:droplast(lists:last(lists:nth(FromPath,
															       NodesToAST)))
											     ++
											     [Z],
											   El)
									end,
									lists:nth(Elem,
										  NodesToAST))
						      end,
						      lists:seq(1,
								length(NodesToAST))),
			      {NewAST, NewNodesToAST} =
				  insertgraphnode({element(1, Acc),
						   element(2, Acc)},
						  lists:droplast(lists:last(lists:nth(ToPath,
										      NodesToAST)))
						    ++
						    [getgraphpathlength(AST,
									NodesToAST,
									ToPath)
						       + Z
						       -
						       lists:last(hd(lists:nth(FromPath,
									       NodesToAST)))],
						  getgraphpath(AST,
							       lists:droplast(lists:last(lists:nth(FromPath,
												   NodesToAST)))
								 ++ [Z]),
						  0, 0),
			      {NewAST,
			       NewNodesToAST ++
				 [[lists:droplast(lists:last(lists:nth(ToPath,
								       NodesToAST)))
				     ++
				     [getgraphpathlength(AST, NodesToAST,
							 ToPath)
					+ Z
					-
					lists:last(hd(lists:nth(FromPath,
								NodesToAST)))]
				       ++
				       lists:nthtail(length(lists:droplast(lists:last(lists:nth(FromPath,
												NodesToAST)))
							      ++ [Z]),
						     Y)
				   || Y <- lists:nth(X, NodesToAST)]
				  || X <- SubNodes],
			       lists:foldl(fun (X, A) ->
						   lists:foldl(fun (El, Ac) ->
								       Idx =
									   index_of(El,
										    SubNodes),
								       if Idx
									    =:=
									    0 ->
									      addtolistoflists(El,
											       Ac,
											       length(element(3,
													      Acc))
												 +
												 index_of(X,
													  SubNodes));
									  true ->
									      Ac
								       end
							       end,
							       A,
							       lists:nth(X,
									 Succ))
					   end,
					   removefromlistoflists(FromPath,
								 if SubNodes =/=
								      [] ->
									element(3,
										Acc);
								    true ->
									addtolistoflists(case
											   lists:member(FromPath,
													lists:nth(3,
														  Pred))
											     of
											   true ->
											       3;
											   _ ->
											       Node
											 end,
											 element(3,
												 Acc),
											 ToPath)
								 end,
								 ToPath),
					   SubNodes)
				 ++
				 [lists:map(fun (El) ->
						    Idx = index_of(El,
								   SubNodes),
						    if Idx =/= 0 ->
							   length(element(3,
									  Acc))
							     + Idx;
						       El =:= FromPath ->
							   ToPath;
						       true -> El
						    end
					    end,
					    lists:nth(X, Pred))
				  || X <- SubNodes],
			       lists:foldl(fun (X, A) ->
						   lists:foldl(fun (El, Ac) ->
								       Idx =
									   index_of(El,
										    SubNodes),
								       if Idx
									    =:=
									    0 ->
									      addtolistoflists(if
												 El
												   =:=
												   FromPath ->
												     ToPath;
												 true ->
												     El
											       end,
											       Ac,
											       length(element(3,
													      Acc))
												 +
												 index_of(X,
													  SubNodes));
									  true ->
									      Ac
								       end
							       end,
							       A,
							       lists:nth(X,
									 Pred))
					   end,
					   removefromlistoflists(ToPath,
								 if SubNodes =/=
								      [] ->
									element(4,
										Acc);
								    true ->
									addtolistoflists(ToPath,
											 element(4,
												 Acc),
											 case
											   lists:member(FromPath,
													lists:nth(3,
														  Pred))
											     of
											   true ->
											       3;
											   _ ->
											       Node
											 end)
								 end,
								 FromPath),
					   SubNodes)
				 ++
				 [lists:map(fun (El) ->
						    Idx = index_of(El,
								   SubNodes),
						    if Idx =/= 0 ->
							   length(element(3,
									  Acc))
							     + Idx;
						       true -> El
						    end
					    end,
					    lists:nth(X, Succ))
				  || X <- SubNodes]}
		      end,
		      {AST, NodesToAST, Pred, Succ},
		      lists:seq(lists:last(hd(lists:nth(FromPath,
							NodesToAST)))
				  + 1,
				getgraphpathlength(AST, NodesToAST, FromPath)))
    end.

handle_cross_edges(AST, NodesToAST, Pred, Succ, Node,
		   MergeNode, NearestCrossPdom, CrossEdges, DFS) ->
    CrossPairs = lists:foldl(fun (X, A) ->
				     lists:foldl(fun (Y, Acc) ->
							 case lists:nth(Y,
									lists:nth(X,
										  NearestCrossPdom))
								=:= Node
								orelse
								lists:nth(Y,
									  lists:nth(X,
										    NearestCrossPdom))
								  =:= MergeNode
							     of
							   true ->
							       DupInto =
								   lists:nth(Y,
									     lists:nth(X,
										       CrossEdges)),
							       IsPred =
								   lists:any(fun
									       (N) ->
										   N
										     =:=
										     DupInto
									     end,
									     lists:nth(X,
										       Pred)),
							       [{if IsPred -> X;
								    true ->
									DupInto
								 end,
								 if IsPred ->
									DupInto;
								    true -> X
								 end}
								| Acc];
							   _ -> Acc
							 end
						 end,
						 A,
						 lists:seq(1,
							   length(lists:nth(X,
									    CrossEdges))))
			     end,
			     [], lists:seq(1, length(CrossEdges))),
    erlang:display({Pred, Succ, Node, MergeNode,
		    NearestCrossPdom, CrossEdges, CrossPairs}),
    {NewAST, NewNodesToAST, NewPred, NewSucc} =
	lists:foldl(fun ({X, Y}, Acc) ->
			    erlang:display({X, Y,
					    lists:last(lists:nth(X,
								 element(2,
									 Acc))),
					    lists:last(lists:nth(Y,
								 element(2,
									 Acc))),
					    element(3, Acc), element(4, Acc)}),
			    copy_graph_node({X, Y, element(1, Acc),
					     element(2, Acc), element(3, Acc),
					     element(4, Acc), Node})
		    end,
		    {AST, NodesToAST, Pred, Succ},
		    lists:sort(fun ({A, _}, {B, _}) ->
				       index_of(A, DFS) =< index_of(B, DFS)
			       end,
			       CrossPairs)),
    {NewAST, NewNodesToAST, NewPred, NewSucc}.

handle_merge_node(OrigAST, OrigNodesToAST, OrigPred,
		  OrigSucc, OrigCurNode, OrigNode, OrigAssignedVars,
		  VarPrefix, LblIdx, IsCatch) ->
    BlockMerges = lists:usort(fun (A, B) ->
				      case A =/= B andalso lists:prefix(A, B) of
					true -> false;
					_ ->
					    case lists:prefix(B, A) of
					      true -> true;
					      _ -> A =< B
					    end
				      end
			      end,
			      lists:filter(fun (A) -> A =/= [] end,
					   lists:map(fun (P) ->
							     begin
							       A =
								   lists:dropwhile(fun
										     (X) ->
											 not
											   case
											     case
											       getgraphpath(OrigAST,
													    lists:sublist(hd(lists:nth(P,
																       OrigNodesToAST)),
															  1,
															  X))
												 of
											       {match,
												_,
												_,
												[{call,
												  _,
												  {'fun',
												   _,
												   {clauses,
												    _}},
												  _}]} ->
												   {[4,
												     1,
												     4,
												     1],
												    [4,
												     1,
												     4,
												     3]};
											       {match,
												_,
												_,
												[{'try',
												  _,
												  _,
												  _,
												  _,
												  _}]} ->
												   {[4,
												     1,
												     4],
												    [4,
												     1,
												     5]};
											       _ ->
												   false
											     end
											       of
											     {FixPfx,
											      FixAfterPfx} ->
												 (OrigNode
												    =:=
												    OrigCurNode
												    andalso
												    not
												      IsCatch
												      andalso
												      lists:any(fun
														  (Y) ->
														      lists:prefix(lists:sublist(hd(lists:nth(P,
																			      OrigNodesToAST)),
																		 1,
																		 X)
																     ++
																     FixPfx,
																   hd(lists:nth(Y,
																		OrigNodesToAST)))
														end,
														lists:nth(OrigNode,
															  OrigPred))
												    orelse
												    lists:prefix(lists:sublist(hd(lists:nth(P,
																	    OrigNodesToAST)),
															       1,
															       X)
														   ++
														   FixPfx,
														 hd(lists:nth(P,
															      OrigNodesToAST))))
												   andalso
												   (OrigNode
												      =:=
												      2
												      orelse
												      lists:prefix(lists:sublist(hd(lists:nth(P,
																	      OrigNodesToAST)),
																 1,
																 X)
														     ++
														     FixAfterPfx,
														   hd(lists:nth(OrigNode,
																OrigNodesToAST))))
												   orelse
												   (OrigNode
												      =:=
												      OrigCurNode
												      andalso
												      not
													IsCatch
													andalso
													lists:any(fun
														    (Y) ->
															lists:prefix(lists:sublist(hd(lists:nth(P,
																				OrigNodesToAST)),
																		   1,
																		   X)
																       ++
																       FixAfterPfx,
																     hd(lists:nth(Y,
																		  OrigNodesToAST)))
														  end,
														  lists:nth(OrigNode,
															    OrigPred))
												      orelse
												      lists:prefix(lists:sublist(hd(lists:nth(P,
																	      OrigNodesToAST)),
																 1,
																 X)
														     ++
														     FixAfterPfx,
														   hd(lists:nth(P,
																OrigNodesToAST))))
												     andalso
												     (OrigNode
													=:=
													2
													orelse
													lists:prefix(lists:sublist(hd(lists:nth(P,
																		OrigNodesToAST)),
																   1,
																   X)
														       ++
														       FixPfx,
														     hd(lists:nth(OrigNode,
																  OrigNodesToAST))));
											     _ ->
												 false
											   end
										   end,
										   lists:seq(length(hd(lists:nth(P,
														 OrigNodesToAST))),
											     1,
											     -2)),
							       if A =:= [] -> A;
								  true ->
								      lists:sublist(hd(lists:nth(P,
												 OrigNodesToAST)),
										    1,
										    hd(A))
							       end
							     end
						     end,
						     lists:nth(OrigNode,
							       OrigPred)))),
    {AST, NodesToAST, Pred, Succ, AssignedVars, CurNode,
     Node} =
	lists:foldl(fun (Idx,
			 {AccAST, AccNodesToAST, AccPred, AccSucc,
			  AccAssignedVars, _, AccNode}) ->
			    Idxs = lists:nth(Idx, BlockMerges),
			    {FixPfx, FixAfterPfx, FullSuffix} = case
								  getgraphpath(AccAST,
									       Idxs)
								    of
								  {match, _, _,
								   [{'try', _,
								     _, _, _,
								     _}]} ->
								      {[4, 1,
									4],
								       [4, 1,
									5],
								       [1, 5]};
								  _ ->
								      {[4, 1, 4,
									1],
								       [4, 1, 4,
									3],
								       [3, 1, 2,
									1, 5]}
								end,
			    P = hd(lists:dropwhile(fun (X) ->
							   not
							     lists:prefix(Idxs,
									  hd(lists:nth(X,
										       AccNodesToAST)))
						   end,
						   lists:nth(AccNode,
							     AccPred))),
			    MergeNode = index_of([lists:droplast(Idxs) ++
						    [lists:last(Idxs) + 1]],
						 AccNodesToAST),
			    FixNodes = lists:filter(fun (X) ->
							    lists:prefix(Idxs ++
									   FixPfx,
									 lists:last(lists:nth(X,
											      AccNodesToAST)))
						    end,
						    lists:nth(AccNode, AccPred))
					 ++
					 case P =/= AccNode andalso
						AccNode =/= 2 andalso
						  lists:prefix(Idxs ++ FixPfx,
							       hd(lists:nth(P,
									    AccNodesToAST)))
					     of
					   true -> [P];
					   _ -> []
					 end
					   ++
					   case P =/= AccNode andalso
						  lists:prefix(Idxs ++ FixPfx,
							       hd(lists:nth(AccNode,
									    AccNodesToAST)))
					       of
					     true -> [AccNode];
					     _ -> []
					   end,
			    FixAfterNodes = lists:filter(fun (X) ->
								 lists:prefix(Idxs
										++
										FixAfterPfx,
									      lists:last(lists:nth(X,
												   AccNodesToAST)))
							 end,
							 lists:nth(AccNode,
								   AccPred))
					      ++
					      case P =/= AccNode andalso
						     AccNode =/= 2 andalso
						       lists:prefix(Idxs ++
								      FixAfterPfx,
								    hd(lists:nth(P,
										 AccNodesToAST)))
						  of
						true -> [P];
						_ -> []
					      end
						++
						case P =/= AccNode andalso
						       lists:prefix(Idxs ++
								      FixAfterPfx,
								    hd(lists:nth(AccNode,
										 AccNodesToAST)))
						    of
						  true -> [AccNode];
						  _ -> []
						end,
			    MNextPred = lists:foldl(fun (El, Acc) ->
							    removefromlistoflists(MergeNode,
										  Acc,
										  El)
						    end,
						    addtolistoflists(MergeNode,
								     lists:foldl(fun
										   (El,
										    Acc) ->
										       addtolistoflists(length(AccPred)
													  +
													  1,
													removefromlistoflists(2,
															      Acc,
															      El),
													El)
										 end,
										 lists:foldl(fun
											       (E,
												A) ->
												   addtolistoflists(length(AccPred)
														      +
														      2,
														    removefromlistoflists(AccNode,
																	  A,
																	  E),
														    E)
											     end,
											     AccPred,
											     FixAfterNodes),
										 FixNodes),
								     length(AccPred)
								       + 1),
						    lists:nth(MergeNode,
							      AccPred)),
			    MNextSucc = lists:foldl(fun (El, Acc) ->
							    removefromlistoflists(El,
										  Acc,
										  MergeNode)
						    end,
						    addtolistoflists(length(AccPred)
								       + 1,
								     lists:foldl(fun
										   (El,
										    Acc) ->
										       addtolistoflists(El,
													removefromlistoflists(El,
															      Acc,
															      2),
													length(AccPred)
													  +
													  1)
										 end,
										 lists:foldl(fun
											       (E,
												A) ->
												   addtolistoflists(E,
														    removefromlistoflists(E,
																	  A,
																	  AccNode),
														    length(AccPred)
														      +
														      2)
											     end,
											     AccSucc,
											     FixAfterNodes),
										 FixNodes),
								     MergeNode),
						    lists:nth(MergeNode,
							      AccPred)),
			    ANextPred = if FixAfterNodes =:= [] -> MNextPred;
					   true ->
					       addtolistoflists(MergeNode,
								MNextPred,
								length(AccPred)
								  + 2)
					end,
			    ANextSucc = if FixAfterNodes =:= [] -> MNextSucc;
					   true ->
					       addtolistoflists(length(AccPred)
								  + 2,
								MNextSucc,
								MergeNode)
					end,
			    {NextPred, NextSucc} = if Idx =:=
							length(BlockMerges) ->
							  NextMergeNode =
							      MergeNode,
							  {ANextPred,
							   ANextSucc};
						      true ->
							  NextIdxs =
							      lists:nth(Idx + 1,
									BlockMerges),
							  NextMergeNode =
							      index_of([lists:droplast(NextIdxs)
									  ++
									  [lists:last(NextIdxs)
									     +
									     1]],
								       AccNodesToAST),
							  LastIdxs =
							      lists:nth(length(BlockMerges),
									BlockMerges),
							  LastMergeNode =
							      index_of([lists:droplast(LastIdxs)
									  ++
									  [lists:last(LastIdxs)
									     +
									     1]],
								       AccNodesToAST),
							  {lists:foldl(fun (El,
									    Acc) ->
									       case
										 AccNode
										   =:=
										   2
										   andalso
										   El
										     =:=
										     LastMergeNode
										   orelse
										   lists:prefix(Idxs,
												hd(lists:nth(El,
													     AccNodesToAST)))
										   of
										 true ->
										     Acc;
										 _ ->
										     addtolistoflists(NextMergeNode,
												      removefromlistoflists(AccNode,
															    Acc,
															    El),
												      El)
									       end
								       end,
								       removefromlistoflists(2,
											     addtolistoflists(NextMergeNode,
													      ANextPred,
													      MergeNode),
											     MergeNode),
								       lists:nth(AccNode,
										 AccPred)),
							   lists:foldl(fun (El,
									    Acc) ->
									       case
										 AccNode
										   =:=
										   2
										   andalso
										   El
										     =:=
										     LastMergeNode
										   orelse
										   lists:prefix(Idxs,
												hd(lists:nth(El,
													     AccNodesToAST)))
										   of
										 true ->
										     Acc;
										 _ ->
										     addtolistoflists(El,
												      removefromlistoflists(El,
															    Acc,
															    AccNode),
												      NextMergeNode)
									       end
								       end,
								       removefromlistoflists(MergeNode,
											     addtolistoflists(MergeNode,
													      ANextSucc,
													      NextMergeNode),
											     2),
								       lists:nth(AccNode,
										 AccPred))}
						   end,
			    FixNodePath = Idxs ++
					    FixPfx ++
					      FullSuffix ++
						[length(element(lists:last(FullSuffix),
								getgraphpath(AccAST,
									     Idxs
									       ++
									       FixPfx
										 ++
										 lists:droplast(FullSuffix))))
						   + 1],
			    FixAST = insertgraphpath(AccAST, FixNodePath,
						     {graphdata, 0,
						      [[]
						       || _
							      <- lists:seq(1,
									   1024)],
						      [],
						      [[]
						       || _
							      <- lists:seq(1,
									   16)]}),
			    {NextAST, NextNodesToAST} = if FixAfterNodes =:=
							     [] ->
							       {FixAST,
								AccNodesToAST ++
								  [[FixNodePath]]};
							   true ->
							       FixNodeAfterPath =
								   Idxs ++
								     FixAfterPfx
								       ++
								       FullSuffix
									 ++
									 [length(element(lists:last(FullSuffix),
											 getgraphpath(AccAST,
												      Idxs
													++
													FixAfterPfx
													  ++
													  lists:droplast(FullSuffix))))
									    +
									    1],
							       {insertgraphpath(FixAST,
										FixNodeAfterPath,
										{graphdata,
										 0,
										 [[]
										  || _
											 <- lists:seq(1,
												      1024)],
										 [],
										 [[]
										  || _
											 <- lists:seq(1,
												      16)]}),
								AccNodesToAST ++
								  [[FixNodePath],
								   [FixNodeAfterPath]]}
							end,
			    {MidAST, MidNodesToAST, MidPred, MidSucc,
			     MidAssignedVars, _} =
				handle_merge_node(NextAST, NextNodesToAST,
						  NextPred, NextSucc,
						  length(AccPred) + 1,
						  length(AccPred) + 1,
						  AccAssignedVars, VarPrefix, 0,
						  true),
			    {NxAST, NxNodesToAST, NxPred, NxSucc,
			     NxAssignedVars, _} =
				if FixAfterNodes =:= [] ->
				       {MidAST, MidNodesToAST, MidPred, MidSucc,
					MidAssignedVars, AccNode};
				   true ->
				       handle_merge_node(MidAST, MidNodesToAST,
							 MidPred, MidSucc,
							 length(AccPred) + 2,
							 length(AccPred) + 2,
							 AccAssignedVars +
							   MidAssignedVars,
							 VarPrefix, 0, true)
				end,
			    {NxAST, NxNodesToAST, NxPred, NxSucc,
			     AccAssignedVars + MidAssignedVars + NxAssignedVars,
			     NextMergeNode,
			     if Idx =:= length(BlockMerges) andalso
				  OrigNode =:= 2 ->
				    OrigNode;
				true -> NextMergeNode
			     end}
		    end,
		    {OrigAST, OrigNodesToAST, OrigPred, OrigSucc,
		     OrigAssignedVars, OrigCurNode, OrigNode},
		    lists:seq(1, length(BlockMerges))),
    if Node =:= CurNode andalso not IsCatch ->
	   {AST, NodesToAST, Pred, Succ, 0, Node};
       true ->
	   Idom = if Node =:= 2 -> do_tarjan_immdom(Pred, Succ, 3);
		     true ->
			 lists:foldl(fun (Elem, Acc) -> setnth(Elem, Acc, 3)
				     end,
				     do_tarjan_immdom(lists:foldl(fun (Elem,
								       Acc) ->
									  lists:foldl(fun
											(X,
											 Ac) ->
											    lists:foldl(fun
													  (El,
													   A) ->
													      if
														Elem
														  =/=
														  El ->
														    addtolistoflists(El,
																     A,
																     Elem);
														true ->
														    A
													      end
													end,
													Ac,
													lists:nth(X,
														  Succ))
										      end,
										      Acc,
										      lists:nth(Elem,
												Pred))
								  end,
								  setnth(3,
									 Pred,
									 [2]),
								  lists:delete(2,
									       lists:nth(3,
											 Pred))),
						      lists:foldl(fun (Elem,
								       Acc) ->
									  lists:foldl(fun
											(X,
											 Ac) ->
											    lists:foldl(fun
													  (El,
													   A) ->
													      if
														Elem
														  =/=
														  El ->
														    addtolistoflists(Elem,
																     A,
																     El);
														true ->
														    A
													      end
													end,
													Ac,
													lists:nth(X,
														  Succ))
										      end,
										      removefromlistoflists(Elem,
													    Acc,
													    3),
										      lists:nth(Elem,
												Pred))
								  end,
								  Succ,
								  lists:delete(2,
									       lists:nth(3,
											 Pred))),
						      3),
				     lists:delete(2, lists:nth(3, Pred)))
		  end,
	   ChkDom = do_tarjan_immdom(Succ, Pred, 1),
	   AllPdoms = lists:filtermap(fun (Elem) ->
					      case lists:nth(Elem, Idom) of
						Node ->
						    {true,
						     BuildDom = fun
								  BuildDom(C) ->
								      X =
									  lists:nth(hd(C),
										    ChkDom),
								      case X of
									0 -> C;
									_ ->
									    BuildDom([X
										      | C])
								      end
								end([Elem])};
						_ -> false
					      end
				      end,
				      lists:seq(1, length(Idom))),
	   PdomLen = length(lists:takewhile(fun (Elem) ->
						    length(lists:usort(lists:map(fun
										   (El) ->
										       lists:nth(Elem,
												 El)
										 end,
										 AllPdoms)))
						      =:= 1
					    end,
					    lists:seq(1,
						      lists:min(lists:map(fun
									    (El) ->
										length(El)
									  end,
									  AllPdoms))))),
	   FirstPDom = lists:nth(PdomLen, hd(AllPdoms)),
	   if Node =/= 2 andalso FirstPDom =:= length(Idom) + 1 ->
		  {AST, NodesToAST, Pred, Succ, 0, Node};
	      true ->
		  DFS = element(1,
				lists:unzip(lists:sort(fun ({_, [A | _]},
							    {_, [B | _]}) ->
							       A =< B
						       end,
						       lists:zip(lists:seq(1,
									   length(NodesToAST)),
								 NodesToAST)))),
		  CrossEdges = [lists:filter(fun (X) ->
						     NearN = lists:takewhile(fun
									       (Elem) ->
										   Elem
										     <
										     hd(lists:nth(X,
												  NodesToAST))
									     end,
									     lists:nth(N,
										       NodesToAST)),
						     NearX = lists:takewhile(fun
									       (Elem) ->
										   Elem
										     <
										     hd(lists:nth(N,
												  NodesToAST))
									     end,
									     lists:nth(X,
										       NodesToAST)),
						     PathN = if NearN =:= [] ->
								    hd(lists:nth(N,
										 NodesToAST));
								true ->
								    lists:last(NearN)
							     end,
						     PathX = if NearX =:= [] ->
								    hd(lists:nth(X,
										 NodesToAST));
								true ->
								    lists:last(NearX)
							     end,
						     if length(PathN) =:= 0
							  orelse
							  length(PathX) =:= 0 ->
							    false;
							length(PathN) =:=
							  length(PathX) ->
							    lists:droplast(PathN)
							      =/=
							      lists:droplast(PathX)
							      orelse
							      index_of(N, DFS) +
								1
								=/=
								index_of(X, DFS)
								andalso
								index_of(N, DFS)
								  - 1
								  =/=
								  index_of(X,
									   DFS);
							true ->
							    SmallPath = if
									  length(PathN)
									    <
									    length(PathX) ->
									      PathN;
									  true ->
									      PathX
									end,
							    BigPath = if
									length(PathN)
									  <
									  length(PathX) ->
									    PathX;
									true ->
									    PathN
								      end,
							    (not
							       lists:prefix(lists:droplast(SmallPath),
									    BigPath)
							       orelse
							       begin
								 A =
								     lists:last(SmallPath),
								 B =
								     lists:nth(length(SmallPath),
									       BigPath),
								 A + 1 =/= B
								   andalso
								   A - 1 =/= B
							       end)
							      andalso
							      (not
								 lists:prefix(lists:droplast(lists:droplast(SmallPath)),
									      BigPath)
								 orelse
								 begin
								   C =
								       lists:last(lists:droplast(SmallPath)),
								   D =
								       lists:nth(length(SmallPath)
										   -
										   1,
										 BigPath),
								   C + 1 =/= D
								     andalso
								     C - 1 =/= D
								 end)
						     end
					     end,
					     lists:nth(N, Pred))
				|| N <- lists:seq(1, length(Pred))],
		  NearestCrossPdom = lists:map(fun (X) ->
						       L = lists:reverse(if X
									      =:=
									      Node ->
										pathtodom(Idom,
											  X);
									    true ->
										tl(pathtodom(Idom,
											     X))
									 end),
						       lists:map(fun (Y) ->
									 Z =
									     lists:reverse(tl(pathtodom(Idom,
													Y))),
									 lists:nth(lists:last(lists:takewhile(fun
														(N) ->
														    lists:nth(N,
															      Z)
														      =:=
														      lists:nth(N,
																L)
													      end,
													      lists:seq(1,
															erlang:min(length(L),
																   length(Z))))),
										   L)
								 end,
								 lists:nth(X,
									   CrossEdges))
					       end,
					       lists:seq(1, length(Pred))),
		  IsCross = CurNode =:= 0 orelse
			      lists:any(fun (X) -> X =:= CurNode end,
					lists:nth(Node, CrossEdges)),
		  erlang:display({CurNode, Node, Pred, Succ, FirstPDom,
				  Idom, CrossEdges, NearestCrossPdom, IsCross,
				  DFS, NodesToAST}),
		  {NewInsAST, NewInsNodesToAST} = if Node =:= 2 orelse
						       IsCatch ->
							 {AST, NodesToAST};
						     true ->
							 PDomPath =
							     lists:last(lists:nth(FirstPDom,
										  NodesToAST)),
							 insertgraphnode({AST,
									  NodesToAST
									    ++
									    [lists:nth(Node,
										       NodesToAST)]},
									 case
									   length(PDomPath)
									     >
									     length(hd(lists:nth(Node,
												 NodesToAST)))
									     of
									   true ->
									       NewNodePath =
										   hd(lists:nth(Node,
												NodesToAST)),
									       setnth(length(NewNodePath),
										      lists:sublist(NewNodePath,
												    length(PDomPath)),
										      lists:nth(length(NewNodePath),
												NewNodePath)
											+
											1);
									   _ ->
									       erlang:display({PDomPath,
											       lists:sublist(hd(lists:nth(Node,
															  NodesToAST)),
													     length(PDomPath))}),
									       setnth(length(PDomPath),
										      lists:sublist(hd(lists:nth(Node,
														 NodesToAST)),
												    length(PDomPath)),
										      lists:nth(length(PDomPath),
												hd(lists:nth(Node,
													     NodesToAST)))
											+
											1)
									 end,
									 {graphdata,
									  LblIdx,
									  [],
									  [],
									  []},
									 if
									   IsCross ->
									       length(Pred)
										 +
										 1;
									   true ->
									       Node
									 end,
									 0)
						  end,
		  {NewAST, NewNodesToAST, FixPred, FixSucc} = if
								IsCatch ->
								    {NewInsAST,
								     NewInsNodesToAST,
								     Pred,
								     Succ};
								true ->
								    handle_cross_edges(NewInsAST,
										       NewInsNodesToAST,
										       if
											 Node
											   =:=
											   2 ->
											     Pred;
											 IsCross ->
											     removefromlistoflists(2,
														   addtolistoflists(2,
																    addtolistoflists(length(Pred)
																		       +
																		       1,
																		     lists:foldl(fun
																				   (El,
																				    Acc) ->
																				       if
																					 El
																					   =:=
																					   CurNode ->
																					     addtolistoflists(length(Pred)
																								+
																								1,
																							      removefromlistoflists(Node,
																										    Acc,
																										    El),
																							      El);
																					 true ->
																					     Acc
																				       end
																				 end,
																				 Pred,
																				 lists:nth(Node,
																					   Pred)),
																		     Node),
																    length(Pred)
																      +
																      1),
														   Node);
											 true ->
											     removefromlistoflists(Node,
														   addtolistoflists(Node,
																    addtolistoflists(length(Pred)
																		       +
																		       1,
																		     Pred,
																		     CurNode),
																    length(Pred)
																      +
																      1),
														   CurNode)
										       end,
										       if
											 Node
											   =:=
											   2 ->
											     Succ;
											 IsCross ->
											     removefromlistoflists(Node,
														   addtolistoflists(length(Pred)
																      +
																      1,
																    addtolistoflists(Node,
																		     lists:foldl(fun
																				   (El,
																				    Acc) ->
																				       if
																					 El
																					   =:=
																					   CurNode ->
																					     addtolistoflists(El,
																							      removefromlistoflists(El,
																										    Acc,
																										    Node),
																							      length(Pred)
																								+
																								1);
																					 true ->
																					     Acc
																				       end
																				 end,
																				 Succ,
																				 lists:nth(Node,
																					   Pred)),
																		     length(Pred)
																		       +
																		       1),
																    2),
														   2);
											 true ->
											     removefromlistoflists(CurNode,
														   addtolistoflists(length(Pred)
																      +
																      1,
																    addtolistoflists(CurNode,
																		     Succ,
																		     length(Pred)
																		       +
																		       1),
																    Node),
														   Node)
										       end,
										       if
											 IsCross ->
											     length(Pred)
											       +
											       1;
											 true ->
											     Node
										       end,
										       if
											 Node
											   =:=
											   2 ->
											     3;
											 IsCross ->
											     Node;
											 true ->
											     0
										       end,
										       if
											 IsCross ->
											     setnth(Node,
												    NearestCrossPdom,
												    lists:nth(Node,
													      NearestCrossPdom))
											       ++
											       [lists:nth(Node,
													  NearestCrossPdom)];
											 true ->
											     NearestCrossPdom
										       end,
										       if
											 IsCross ->
											     setnth(Node,
												    CrossEdges,
												    lists:delete(CurNode,
														 lists:nth(Node,
															   CrossEdges)))
											       ++
											       [[]];
											 true ->
											     CrossEdges
										       end,
										       DFS)
							      end,
		  erlang:display({FixSucc, FixPred, IsCross, CrossEdges,
				  check_pred_succ(FixPred, FixSucc)}),
		  Dom = do_tarjan_immdom(FixSucc, FixPred, 1),
		  if Node =:= 2 orelse IsCatch ->
			 {Elem, {{ModAST, ModNodesToAST}, _, NewAsgn}} =
			     assign_var(NewAST, NewNodesToAST, FixPred, Dom,
					Node, AssignedVars, 0, 3, VarPrefix,
					hd(element(3,
						   getgraphpath(NewAST,
								lists:last(lists:nth(lists:nth(Node,
											       Dom),
										     NewNodesToAST))))),
					1);
		     true ->
			 {XVars, {{XModAST, XNodesToAST}, _, XAsgn}} =
			     assign_vars(NewAST, NewNodesToAST, FixPred, Dom,
					 if IsCross -> length(Pred) + 1;
					    true -> Node
					 end,
					 AssignedVars, 3, VarPrefix),
			 {YVars, {{YModAST, YNodesToAST}, _, YAsgn}} =
			     assign_vars(XModAST, XNodesToAST, FixPred, Dom,
					 if IsCross -> length(Pred) + 1;
					    true -> Node
					 end,
					 AssignedVars + XAsgn, 4, VarPrefix),
			 {FrVars, {{ModAST, ModNodesToAST}, _, FrAsgn}} =
			     assign_vars(YModAST, YNodesToAST, FixPred, Dom,
					 if IsCross -> length(Pred) + 1;
					    true -> Node
					 end,
					 AssignedVars + XAsgn + YAsgn, 5,
					 VarPrefix),
			 NewAsgn = XAsgn + YAsgn + FrAsgn,
			 Elem = {graphdata, LblIdx, XVars, YVars, FrVars}
		  end,
		  FinalAST = setgraphpath(ModAST,
					  if Node =:= 2 orelse IsCatch ->
						 CurNodePath =
						     lists:last(lists:nth(if
									    IsCatch ->
										CurNode;
									    true ->
										Node
									  end,
									  ModNodesToAST)),
						 lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) +
						      1];
					     true ->
						 lists:last(lists:nth(length(Pred)
									+ 1,
								      ModNodesToAST))
					  end,
					  Elem),
		  PostIdom = if Node =:= 2 ->
				    do_tarjan_immdom(FixPred, FixSucc, 3);
				true ->
				    lists:foldl(fun (E, Acc) ->
							setnth(E, Acc, 3)
						end,
						do_tarjan_immdom(lists:foldl(fun
									       (E,
										Acc) ->
										   lists:foldl(fun
												 (X,
												  Ac) ->
												     lists:foldl(fun
														   (El,
														    A) ->
														       if
															 E
															   =/=
															   El ->
															     addtolistoflists(El,
																	      A,
																	      E);
															 true ->
															     A
														       end
														 end,
														 Ac,
														 lists:nth(X,
															   FixSucc))
											       end,
											       Acc,
											       lists:nth(E,
													 FixPred))
									     end,
									     setnth(3,
										    FixPred,
										    [2]),
									     lists:delete(2,
											  lists:nth(3,
												    FixPred))),
								 lists:foldl(fun
									       (E,
										Acc) ->
										   lists:foldl(fun
												 (X,
												  Ac) ->
												     lists:foldl(fun
														   (El,
														    A) ->
														       if
															 E
															   =/=
															   El ->
															     addtolistoflists(E,
																	      A,
																	      El);
															 true ->
															     A
														       end
														 end,
														 Ac,
														 lists:nth(X,
															   FixSucc))
											       end,
											       removefromlistoflists(E,
														     Acc,
														     3),
											       lists:nth(E,
													 FixPred))
									     end,
									     FixSucc,
									     lists:delete(2,
											  lists:nth(3,
												    FixPred))),
								 3),
						lists:delete(2,
							     lists:nth(3,
								       FixPred)))
			     end,
		  {RDFS, ODFS} = do_interval_dfs(lists:map(fun (X) ->
								   lists:reverse(X)
							   end,
							   FixSucc),
						 1),
		  {FinalAST, ModNodesToAST, FixPred, FixSucc, NewAsgn,
		   if Node =/= 2 andalso not IsCatch andalso IsCross ->
			  length(Pred) + 1;
		      true -> Node
		   end}
	   end
    end.

generate_dot_dom_text({Dom, DFS, Prefix, IsPost,
		       Idx}) ->
    if length(Dom) < Idx -> "";
       true ->
	   DFSIdx = index_of(lists:nth(Idx, DFS) - 1, DFS),
	   case DFSIdx =/= 0 andalso lists:nth(Idx, Dom) =/= DFSIdx
	       of
	     true ->
		 "\t" ++
		   Prefix ++
		     integer_to_list(if IsPost -> Idx;
					true -> DFSIdx
				     end)
		       ++
		       " -> " ++
			 Prefix ++
			   integer_to_list(if IsPost -> DFSIdx;
					      true -> Idx
					   end)
			     ++ " [style=\"dashed\"];~n";
	     _ -> ""
	   end
	     ++
	     generate_dot_dom_text({Dom, DFS, Prefix, IsPost,
				    Idx + 1})
    end;
generate_dot_dom_text({Dom, Prefix, IsPost, Idx}) ->
    if length(Dom) < Idx -> "";
       true ->
	   "\t" ++
	     Prefix ++
	       integer_to_list(Idx) ++
		 "[label=\"" ++
		   integer_to_list(Idx) ++
		     "\"];~n" ++
		       case lists:nth(Idx, Dom) =/= 0 of
			 true ->
			     "\t" ++
			       Prefix ++
				 integer_to_list(if IsPost -> Idx;
						    true -> lists:nth(Idx, Dom)
						 end)
				   ++
				   " -> " ++
				     Prefix ++
				       integer_to_list(if IsPost ->
							      lists:nth(Idx,
									Dom);
							  true -> Idx
						       end)
					 ++ ";~n";
			 _ -> ""
		       end
			 ++
			 generate_dot_dom_text({Dom, Prefix, IsPost, Idx + 1})
    end.

generate_dot_text({AST, Succ, NodesToAST, Prefix,
		   Idx}) ->
    if length(Succ) < Idx -> "";
       true ->
	   DispAST = reduce_disp_graph_data({AST, NodesToAST}),
	   "\t" ++
	     Prefix ++
	       integer_to_list(Idx) ++
		 "[label=<" ++
		   integer_to_list(Idx) ++
		     case lists:nth(Idx, NodesToAST) =:= [[]] of
		       true -> "";
		       _ ->
			   "<BR />" ++
			     re:replace(re:replace(re:replace(re:replace(lists:append([lists:flatten(io_lib:format("~p~n",
														   [lists:foldl(fun
																  (Elem,
																   Acc) ->
																      case
																	lists:any(fun
																		    (El) ->
																			lists:prefix(lists:droplast(lists:last(lists:nth(Idx,
																									 NodesToAST)))
																				       ++
																				       [X],
																				     El)
																		  end,
																		  Elem)
																	  of
																	true ->
																	    FirstPfx =
																		lists:dropwhile(fun
																				  (El) ->
																				      not
																					lists:prefix(lists:droplast(lists:last(lists:nth(Idx,
																											 NodesToAST)))
																						       ++
																						       [X],
																						     El)
																				end,
																				Elem),
																	    setelement(lists:nth(length(lists:droplast(lists:last(lists:nth(Idx,
																									    NodesToAST)))
																					  ++
																					  [X])
																				   +
																				   1,
																				 hd(FirstPfx)),
																		       Acc,
																		       {});
																	_ ->
																	    Acc
																      end
																end,
																getgraphpath(DispAST,
																	     lists:droplast(lists:last(lists:nth(Idx,
																						 NodesToAST)))
																	       ++
																	       [X]),
																lists:reverse(lists:delete(lists:nth(Idx,
																				     NodesToAST),
																			   NodesToAST)))]))
										       || X
											      <- lists:seq(lists:last(hd(lists:nth(Idx,
																   NodesToAST))),
													   getgraphpathlength(AST,
															      NodesToAST,
															      Idx))]),
									 "<",
									 "\\&lt;",
									 [global,
									  {return,
									   list}]),
							      ">", "\\&gt;",
							      [global,
							       {return, list}]),
						   "\n", "<BR />",
						   [global, {return, list}]),
					"~", "~~", [global, {return, list}])
		     end
		       ++
		       ">];~n" ++
			 lists:append(["\t" ++
					 Prefix ++
					   integer_to_list(Idx) ++
					     " -> " ++
					       Prefix ++
						 integer_to_list(X) ++
						   case lists:nth(X, NodesToAST)
							  =/= [[]]
							  andalso
							  element(1,
								  getgraphpath(AST,
									       lists:droplast(lists:droplast(hd(lists:nth(X,
															  NodesToAST))))))
							    =:= clause
							    andalso
							    element(1,
								    getgraphpath(AST,
										 lists:droplast(lists:droplast(lists:droplast(lists:droplast(hd(lists:nth(X,
																			  NodesToAST))))))))
							      =:= 'case'
						       of
						     true ->
							 " [label=\"" ++
							   lists:flatten(io_lib:format("~p",
										       [getgraphpath(AST,
												     lists:droplast(lists:droplast(hd(lists:nth(X,
																		NodesToAST))))
												       ++
												       [3,
													1])]))
							     ++ "\"]";
						     _ -> ""
						   end
						     ++ ";~n"
				       || X <- lists:nth(Idx, Succ)])
			   ++
			   generate_dot_text({AST, Succ, NodesToAST, Prefix,
					      Idx + 1})
    end.

generate_dot_file(GraphStr, Filename) ->
    {ok, Fd} = file:open(Filename, [write]),
    io:fwrite(Fd,
	      "digraph {~n\tgraph [dpi=150];~n" ++ GraphStr ++ "}~n",
	      []),
    file:close(Fd).

bug_step(Val, Cur, NewCur, Glob) ->
    {'case', 0,
     case element(2, Val) of
       has_map_fields -> 0;
       more_test -> 3;
       other_test -> 2;
       is_tagged_tuple -> 1
     end,
     [{clause, 0, [{atom, 0, true}], [],
       [{graphdata, 0, element(3, NewCur), element(4, NewCur),
	 element(5, NewCur)}]},
      {clause, 0, [{atom, 0, false}], [],
       [{graphdata, element(2, element(3, Val)),
	 element(3, Cur), element(4, Cur), element(5, Cur)}
	| if element(2, element(3, Val)) < element(1, Glob) ->
		 [{call, 0,
		   {remote, 0, {atom, 0, erlang}, {atom, 0, error}},
		   [{atom, 0, function_clause}]}];
	     true -> []
	  end]}]}.

decompile_step({InstList, AST, Pred, Succ, NodesToAST,
		LabelToNode, CurNode, VarPrefix, AssignedVars, Jumped},
	       Glob) ->
    if length(InstList) =:= 0 ->
	   {FinalAST, FinalNodesToAST, FixPred, FixSucc, NewAsgn,
	    NextNode} =
	       handle_merge_node(AST, NodesToAST, Pred, Succ, CurNode,
				 2, AssignedVars, VarPrefix, 0, false),
	   {InstList, FinalAST, FixPred, FixSucc, FinalNodesToAST,
	    LabelToNode, NextNode, VarPrefix,
	    AssignedVars + NewAsgn, false};
       true ->
	   CurNodePath = lists:last(lists:nth(CurNode,
					      NodesToAST)),
	   Cur = if CurNodePath =/= [] ->
			getgraphpath(AST, CurNodePath);
		    true -> {}
		 end,
	   Val = hd(InstList),
	   erlang:display(Val),
	   case Val of
	     return ->
		 decompile_step({tl(InstList), AST, Pred, Succ,
				 NodesToAST, LabelToNode, CurNode, VarPrefix,
				 AssignedVars, true},
				Glob);
	     on_load ->
		 decompile_step({tl(InstList), AST, Pred, Succ,
				 NodesToAST, LabelToNode, CurNode, VarPrefix,
				 AssignedVars, false},
				Glob);
	     fclearerror ->
		 decompile_step({tl(InstList), AST, Pred, Succ,
				 NodesToAST, LabelToNode, CurNode, VarPrefix,
				 AssignedVars, false},
				Glob);
	     remove_message ->
		 decompile_step({tl(InstList), AST, Pred, Succ,
				 NodesToAST, LabelToNode, CurNode, VarPrefix,
				 AssignedVars, false},
				Glob);
	     send ->
		 decompile_step({tl(InstList),
				 setgraphpath(AST, CurNodePath,
					      setmemd(Cur, {x, 0},
						      {op, 0, '!',
						       getmemd(Cur, {x, 0}),
						       getmemd(Cur, {x, 1})})),
				 Pred, Succ, NodesToAST, LabelToNode, CurNode,
				 VarPrefix, AssignedVars, false},
				Glob);
	     bs_init_writable ->
		 decompile_step({tl(InstList),
				 setgraphpath(AST, CurNodePath,
					      setmemd(Cur, {x, 0},
						      {bin, 0,
						       [{bin_element, 0,
							 {integer, 0, 0},
							 getmemd(Cur, {x, 0}),
							 default}]})),
				 Pred, Succ, NodesToAST, LabelToNode, CurNode,
				 VarPrefix, AssignedVars, false},
				Glob);
	     timeout ->
		 decompile_step({tl(InstList), AST, Pred, Succ,
				 NodesToAST, LabelToNode, CurNode, VarPrefix,
				 AssignedVars, false},
				Glob);
	     if_end ->
		 decompile_step({tl(InstList),
				 insertgraphpath(AST,
						 lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) +
						      1],
						 {call, 0,
						  {remote, 0, {atom, 0, erlang},
						   {atom, 0, error}},
						  [{atom, 0, if_clause}]}),
				 removefromlistoflists(2,
						       addtolistoflists(3, Pred,
									CurNode),
						       CurNode),
				 removefromlistoflists(CurNode,
						       addtolistoflists(CurNode,
									Succ,
									3),
						       2),
				 insert_renumber(NodesToAST,
						 lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) +
						      1]),
				 LabelToNode, CurNode, VarPrefix, AssignedVars,
				 true},
				Glob);
	     _ ->
		 case element(1, Val) of
		   label ->
		       NewNode = if element(2, Val) - element(1, Glob) + 1 >
				      length(LabelToNode) ->
					CurNode;
				    true ->
					case lists:nth(element(2, Val) -
							 element(1, Glob)
							 + 1,
						       LabelToNode)
					    of
					  0 -> CurNode;
					  X -> X
					end
				 end,
		       NewPred = if Jumped orelse NewNode =:= CurNode -> Pred;
				    true ->
					removefromlistoflists(2,
							      addtolistoflistsend(NewNode,
										  lists:foldl(fun
												(X,
												 A) ->
												    setnth(X,
													   A,
													   lists:delete(NewNode,
															lists:nth(X,
																  A))
													     ++
													     [NewNode])
											      end,
											      Pred,
											      lists:nth(NewNode,
													Succ)),
										  CurNode),
							      CurNode)
				 end,
		       NewSucc = if Jumped orelse NewNode =:= CurNode -> Succ;
				    true ->
					removefromlistoflists(CurNode,
							      addtolistoflistsend(CurNode,
										  lists:foldl(fun
												(X,
												 A) ->
												    setnth(X,
													   A,
													   lists:delete(NewNode,
															lists:nth(X,
																  A))
													     ++
													     [NewNode])
											      end,
											      Succ,
											      lists:nth(NewNode,
													Pred)),
										  NewNode),
							      2)
				 end,
		       IsCatch = case lists:last(lists:nth(NewNode,
							   NodesToAST))
					=/= []
					andalso
					lists:prefix(lists:droplast(lists:last(lists:nth(NewNode,
											 NodesToAST)))
						       ++
						       [lists:last(lists:last(lists:nth(NewNode,
											NodesToAST)))
							  - 1],
						     lists:last(lists:nth(CurNode,
									  NodesToAST)))
				     of
				   true ->
				       case getgraphpath(AST,
							 lists:droplast(lists:last(lists:nth(NewNode,
											     NodesToAST)))
							   ++
							   [lists:last(lists:last(lists:nth(NewNode,
											    NodesToAST)))
							      - 1])
					   of
					 {match, _, _, [{'catch', _, _}]} ->
					     true;
					 _ -> false
				       end;
				   _ -> false
				 end,
		       {NewAST, NewNodesToAST, FixPred, FixSucc, NewAsgn,
			NextNode} =
			   handle_merge_node(AST, NodesToAST,
					     if IsCatch andalso
						  CurNode =/= NewNode - 1 ->
						    removefromlistoflists(NewNode,
									  NewPred,
									  NewNode
									    -
									    1);
						true -> NewPred
					     end,
					     if IsCatch andalso
						  CurNode =/= NewNode - 1 ->
						    removefromlistoflists(NewNode
									    - 1,
									  NewSucc,
									  NewNode);
						true -> NewSucc
					     end,
					     if Jumped -> NewNode;
						true -> CurNode
					     end,
					     NewNode, AssignedVars, VarPrefix,
					     element(2, Val), IsCatch),
		       decompile_step({tl(InstList), NewAST, FixPred, FixSucc,
				       NewNodesToAST,
				       if element(2, Val) - element(1, Glob) + 1
					    > length(LabelToNode) ->
					      addtolist(element(2, Val) -
							  element(1, Glob)
							  + 1,
							LabelToNode, CurNode);
					  true ->
					      setnth(element(2, Val) -
						       element(1, Glob)
						       + 1,
						     LabelToNode, NewNode)
				       end,
				       NextNode, VarPrefix,
				       AssignedVars + NewAsgn, false},
				      Glob);
		   line ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   func_info ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   fcheckerror ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   test_heap ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   badmatch ->
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       {call, 0,
							{remote, 0,
							 {atom, 0, erlang},
							 {atom, 0, error}},
							[{tuple, 0,
							  [{atom, 0, badmatch},
							   getmemd(Cur,
								   element(2,
									   Val))]}]}),
				       removefromlistoflists(2,
							     addtolistoflists(3,
									      Pred,
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      Succ,
									      3),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1]),
				       LabelToNode, CurNode, VarPrefix,
				       AssignedVars, true},
				      Glob);
		   case_end ->
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       {call, 0,
							{remote, 0,
							 {atom, 0, erlang},
							 {atom, 0, error}},
							[{tuple, 0,
							  [{atom, 0,
							    case_clause},
							   getmemd(Cur,
								   element(2,
									   Val))]}]}),
				       removefromlistoflists(2,
							     addtolistoflists(3,
									      Pred,
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      Succ,
									      3),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1]),
				       LabelToNode, CurNode, VarPrefix,
				       AssignedVars, true},
				      Glob);
		   'catch' ->
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({AST, NodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))},
							    [{'catch', 0,
							      [{graphdata, 0,
								element(3, Cur),
								element(4, Cur),
								element(5,
									Cur)}]}]},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2],
					   {graphdata,
					    element(2, element(3, Val)),
					    element(3,
						    setmemd(Cur, {x, 0},
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))})),
					    element(4, Cur), element(5, Cur)},
					   0, 0),
		       decompile_step({tl(InstList), ModAST,
				       removefromlistoflists(2,
							     addtolistoflists(2,
									      addtolistoflists(length(Pred)
												 +
												 2,
											       addtolistoflists(length(Pred)
														  +
														  1,
														Pred,
														CurNode),
											       length(Pred)
												 +
												 1),
									      length(Pred)
										+
										2),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(length(Pred)
										+
										2,
									      addtolistoflists(length(Pred)
												 +
												 1,
											       addtolistoflists(CurNode,
														Succ,
														length(Pred)
														  +
														  1),
											       length(Pred)
												 +
												 2),
									      2),
							     2),
				       ModNodesToAST ++
					 [[lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 1, 4, 1,
					      3, 1]],
					  [lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2]]],
				       addtolist(element(2, element(3, Val)) -
						   element(1, Glob)
						   + 1,
						 LabelToNode, length(Pred) + 2),
				       length(Pred) + 1, VarPrefix,
				       AssignedVars + 1, false},
				      Glob);
		   catch_end ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   'try' ->
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({AST, NodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))},
							    [{'try', 0,
							      [{graphdata, 0,
								element(3, Cur),
								element(4, Cur),
								element(5,
									Cur)}],
							      [{clause, 0,
								[{var, 0,
								  list_to_atom(VarPrefix
										 ++
										 "TryVar"
										   ++
										   integer_to_list(AssignedVars))}],
								[],
								[{graphdata, 0,
								  element(3,
									  setmemd(Cur,
										  {x,
										   0},
										  {var,
										   0,
										   list_to_atom(VarPrefix
												  ++
												  "TryVar"
												    ++
												    integer_to_list(AssignedVars))})),
								  element(4,
									  Cur),
								  element(5,
									  Cur)}]}],
							      [{clause, 0,
								[{tuple, 0,
								  [{var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Class"
										     ++
										     integer_to_list(AssignedVars))},
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Reason"
										     ++
										     integer_to_list(AssignedVars))},
								   {var, 0,
								    '_'}]}],
								[],
								[{match, 0,
								  {var, 0,
								   list_to_atom(VarPrefix
										  ++
										  "Stacktrace"
										    ++
										    integer_to_list(AssignedVars))},
								  {call, 0,
								   {remote, 0,
								    {atom, 0,
								     erlang},
								    {atom, 0,
								     get_stacktrace}},
								   []}},
								 {graphdata, 0,
								  element(3,
									  setmemd(setmemd(setmemd(Cur,
												  {x,
												   0},
												  {var,
												   0,
												   list_to_atom(VarPrefix
														  ++
														  "Class"
														    ++
														    integer_to_list(AssignedVars))}),
											  {x,
											   1},
											  {var,
											   0,
											   list_to_atom(VarPrefix
													  ++
													  "Reason"
													    ++
													    integer_to_list(AssignedVars))}),
										  {x,
										   2},
										  {var,
										   0,
										   list_to_atom(VarPrefix
												  ++
												  "Stacktrace"
												    ++
												    integer_to_list(AssignedVars))})),
								  element(4,
									  Cur),
								  element(5,
									  Cur)}]}],
							      []}]},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2],
					   {graphdata, 0,
					    element(3,
						    setmemd(Cur, {x, 0},
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))})),
					    element(4, Cur), element(5, Cur)},
					   0, 0),
		       NewNode = length(Pred) + 1,
		       decompile_step({tl(InstList), ModAST,
				       removefromlistoflists(2,
							     addtolistoflists(NewNode,
									      addtolistoflists(2,
											       addtolistoflists(length(Pred)
														  +
														  3,
														addtolistoflists(2,
																 addtolistoflists(length(Pred)
																		    +
																		    2,
																		  addtolistoflists(2,
																				   Pred,
																				   length(Pred)
																				     +
																				     2),
																		  CurNode),
																 length(Pred)
																   +
																   3),
														CurNode),
											       NewNode),
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      addtolistoflists(NewNode,
											       addtolistoflists(CurNode,
														addtolistoflists(length(Pred)
																   +
																   3,
																 addtolistoflists(CurNode,
																		  addtolistoflists(length(Pred)
																				     +
																				     2,
																				   Succ,
																				   2),
																		  length(Pred)
																		    +
																		    2),
																 2),
														length(Pred)
														  +
														  3),
											       2),
									      NewNode),
							     2),
				       ModNodesToAST ++
					 [[lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 1, 4, 1,
					      3, 1]],
					  [lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 1, 4, 1,
					      5, 1, 5, 2]],
					  [lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2]]],
				       addtolist(element(2, element(3, Val)) -
						   element(1, Glob)
						   + 1,
						 LabelToNode, length(Pred) + 2),
				       length(Pred) + 1, VarPrefix,
				       AssignedVars + 1, false},
				      Glob);
		   try_end ->
		       NewNode = length(Pred) + 1,
		       TryNodePath = lists:sublist(CurNodePath, 1,
						   hd(lists:dropwhile(fun
									(Elem) ->
									    element(1,
										    getgraphpath(AST,
												 lists:sublist(CurNodePath,
													       1,
													       Elem)))
									      =/=
									      'try'
									      orelse
									      lists:prefix(lists:sublist(CurNodePath,
													 1,
													 Elem)
											     ++
											     [4,
											      1],
											   CurNodePath)
								      end,
								      lists:seq(length(CurNodePath)
										  -
										  2,
										5,
										-2)))),
		       NewPred = removefromlistoflists(2,
						       addtolistoflists(NewNode,
									addtolistoflists(2,
											 Pred,
											 NewNode),
									CurNode),
						       CurNode),
		       NewSucc = removefromlistoflists(CurNode,
						       addtolistoflists(CurNode,
									addtolistoflists(NewNode,
											 Succ,
											 2),
									NewNode),
						       2),
		       {NewAST, NewNodesToAST, FixPred, FixSucc, NewAsgn,
			NextNode} =
			   handle_merge_node(AST,
					     NodesToAST ++
					       [[TryNodePath ++ [4, 1, 5, 1]]],
					     NewPred, NewSucc, CurNode, NewNode,
					     AssignedVars, VarPrefix, 0, true),
		       decompile_step({tl(InstList), NewAST, FixPred, FixSucc,
				       NewNodesToAST, LabelToNode, NextNode,
				       VarPrefix, AssignedVars + NewAsgn,
				       false},
				      Glob);
		   try_case ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   try_case_end ->
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       {call, 0,
							{remote, 0,
							 {atom, 0, erlang},
							 {atom, 0, error}},
							[{tuple, 0,
							  [{atom, 0,
							    try_clause},
							   getmemd(Cur,
								   element(2,
									   Val))]}]}),
				       removefromlistoflists(2,
							     addtolistoflists(3,
									      Pred,
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      Succ,
									      3),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1]),
				       LabelToNode, CurNode, VarPrefix,
				       AssignedVars, true},
				      Glob);
		   raise ->
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       {call, 0,
							{remote, 0,
							 {atom, 0, erlang},
							 {atom, 0, raise}},
							[getmemd(Cur,
								 element(4,
									 Val)),
							 getmemd(Cur,
								 lists:nth(2,
									   element(3,
										   Val))),
							 getmemd(Cur,
								 lists:nth(1,
									   element(3,
										   Val)))]}),
				       removefromlistoflists(2,
							     addtolistoflists(3,
									      Pred,
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      Succ,
									      3),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1]),
				       LabelToNode, CurNode, VarPrefix,
				       AssignedVars, true},
				      Glob);
		   loop_rec ->
		       NewNode = length(Pred) + 1,
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({AST, NodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))},
							    [{call, 0,
							      {'fun', 0,
							       {clauses,
								[get_clean_ast(element(4,
										       Glob),
									       'receive',
									       1)]}},
							      [{'fun', 0,
								[{clauses,
								  [{clause, 0,
								    [{var, 0,
								      list_to_atom(VarPrefix
										     ++
										     "Message"
										       ++
										       integer_to_list(AssignedVars))},
								     {var, 0,
								      list_to_atom(VarPrefix
										     ++
										     "RemoveMessage"
										       ++
										       integer_to_list(AssignedVars))}],
								    [],
								    [{graphdata,
								      0,
								      element(3,
									      setmemd(Cur,
										      {x,
										       0},
										      {var,
										       0,
										       list_to_atom(VarPrefix
												      ++
												      "Message"
													++
													integer_to_list(AssignedVars))})),
								      element(4,
									      Cur),
								      element(5,
									      Cur)}]}]}]}]}]},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2],
					   {graphdata, 0,
					    element(3,
						    setmemd(Cur, {x, 0},
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))})),
					    element(4, Cur), element(5, Cur)},
					   0, 0),
		       decompile_step({tl(InstList), ModAST,
				       removefromlistoflists(2,
							     addtolistoflists(NewNode,
									      addtolistoflists(2,
											       addtolistoflists(length(Pred)
														  +
														  3,
														addtolistoflists(2,
																 addtolistoflists(length(Pred)
																		    +
																		    2,
																		  addtolistoflists(2,
																				   Pred,
																				   length(Pred)
																				     +
																				     2),
																		  CurNode),
																 length(Pred)
																   +
																   3),
														CurNode),
											       NewNode),
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      addtolistoflists(NewNode,
											       addtolistoflists(CurNode,
														addtolistoflists(length(Pred)
																   +
																   3,
																 addtolistoflists(CurNode,
																		  addtolistoflists(length(Pred)
																				     +
																				     2,
																				   Succ,
																				   2),
																		  length(Pred)
																		    +
																		    2),
																 2),
														length(Pred)
														  +
														  3),
											       2),
									      NewNode),
							     2),
				       ModNodesToAST ++
					 [[lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 1, 4, 1,
					      4, 1, 3, 1, 2, 1, 5, 1]],
					  [lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2]],
					  [[]]],
				       addtolist(element(2, element(2, Val)) -
						   element(1, Glob)
						   + 1,
						 LabelToNode, length(Pred) + 3),
				       NewNode, VarPrefix, AssignedVars + 1,
				       false},
				      Glob);
		   wait ->
		       erlang:display({CurNode, Pred, Succ, NodesToAST}),
		       decompile_step({tl(InstList), AST,
				       removefromlistoflists(2,
							     addtolistoflists(3,
									      Pred,
									      CurNode),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(CurNode,
									      Succ,
									      3),
							     2),
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, true},
				      Glob);
		   wait_timeout ->
		       RecvNode = lists:nth(element(2, element(2, Val)) -
					      element(1, Glob)
					      + 1,
					    LabelToNode),
		       NewNode = length(Pred) + 1,
		       if CurNode =:= RecvNode ->
			      {ModAST, ModNodesToAST} = insertgraphnode({AST,
									 NodesToAST},
									lists:droplast(CurNodePath)
									  ++
									  [lists:last(CurNodePath)
									     +
									     1],
									{'receive',
									 0, [],
									 getmemd(Cur,
										 element(3,
											 Val)),
									 [{graphdata,
									   0,
									   element(3,
										   Cur),
									   element(4,
										   Cur),
									   element(5,
										   Cur)}]},
									0, 0),
			      decompile_step({tl(InstList), ModAST,
					      removefromlistoflists(2,
								    addtolistoflists(NewNode,
										     addtolistoflists(2,
												      Pred,
												      NewNode),
										     CurNode),
								    CurNode),
					      removefromlistoflists(CurNode,
								    addtolistoflists(CurNode,
										     addtolistoflists(NewNode,
												      Succ,
												      2),
										     NewNode),
								    2),
					      ModNodesToAST ++
						[[lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       1,
						     5, 1]]],
					      LabelToNode, NewNode, VarPrefix,
					      AssignedVars, false},
					     Glob);
			  true ->
			      RecvNodePath =
				  lists:sublist(lists:last(lists:nth(CurNode -
								       2,
								     NodesToAST)),
						length(lists:last(lists:nth(CurNode
									      -
									      2,
									    NodesToAST)))
						  - 8),
			      erlang:display({CurNode, RecvNode, RecvNodePath,
					      Pred, Succ, NodesToAST}),
			      decompile_step({tl(InstList),
					      setgraphpath(AST, RecvNodePath,
							   {call, 0,
							    {'fun', 0,
							     {clauses,
							      [get_clean_ast(element(4,
										     Glob),
									     'receive',
									     3)]}},
							    [getgraphpath(AST,
									  RecvNodePath
									    ++
									    [4,
									     1]),
							     getmemd(Cur,
								     element(3,
									     Val)),
							     {'fun', 0,
							      [{clauses,
								[{clause, 0, [],
								  [],
								  [getgraphpath(AST,
										lists:last(lists:nth(CurNode
												       -
												       2,
												     NodesToAST)))]}]}]}]}),
					      removefromlistoflists(2,
								    addtolistoflists(3,
										     addtolistoflists(NewNode,
												      addtolistoflists(2,
														       Pred,
														       NewNode),
												      RecvNode),
										     CurNode),
								    CurNode),
					      removefromlistoflists(CurNode,
								    addtolistoflists(CurNode,
										     addtolistoflists(RecvNode,
												      addtolistoflists(NewNode,
														       Succ,
														       2),
												      NewNode),
										     3),
								    2),
					      NodesToAST ++
						[[RecvNodePath ++
						    [4, 3, 3, 1, 2, 1, 5, 1]]],
					      LabelToNode, NewNode, VarPrefix,
					      AssignedVars, false},
					     Glob)
		       end;
		   loop_rec_end ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, true},
				      Glob);
		   recv_mark ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   recv_set ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   select_val ->
		       DefIdx = length(getmemd(Cur, element(4, Val))) div 2 +
				  1,
		       NotExists = lists:filter(fun (Elem) ->
							element(2,
								lists:nth(Elem *
									    2,
									  getmemd(Cur,
										  element(4,
											  Val))))
							  - element(1, Glob)
							  + 1
							  > length(LabelToNode)
							  orelse
							  lists:nth(element(2,
									    lists:nth(Elem
											*
											2,
										      getmemd(Cur,
											      element(4,
												      Val))))
								      -
								      element(1,
									      Glob)
								      + 1,
								    LabelToNode)
							    =:= 0
						end,
						lists:seq(1,
							  length(getmemd(Cur,
									 element(4,
										 Val)))
							    div 2))
				     ++
				     case element(2, element(3, Val)) -
					    element(1, Glob)
					    + 1
					    > length(LabelToNode)
					    orelse
					    lists:nth(element(2,
							      element(3, Val))
							- element(1, Glob)
							+ 1,
						      LabelToNode)
					      =:= 0
					 of
				       true -> [0];
				       _ -> []
				     end,
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       element(2,
							       lists:foldl(fun
									     (Elem,
									      Acc) ->
										 if
										   element(1,
											   Acc)
										     =:=
										     [] ->
										       {Elem,
											element(2,
												Acc)};
										   true ->
										       {[],
											{'case',
											 0,
											 getmemd(Cur,
												 element(2,
													 Val)),
											 [{clause,
											   0,
											   [case
											      element(1,
												      element(1,
													      Acc))
												of
											      atom ->
												  {atom,
												   0,
												   element(2,
													   element(1,
														   Acc))};
											      integer ->
												  {integer,
												   0,
												   element(2,
													   element(1,
														   Acc))}
											    end],
											   [],
											   [{graphdata,
											     element(2,
												     Elem),
											     element(3,
												     Cur),
											     element(4,
												     Cur),
											     element(5,
												     Cur)}]},
											  {clause,
											   0,
											   [{var,
											     0,
											     '_'}],
											   [],
											   [{graphdata,
											     if
											       element(2,
												       Acc)
												 =:=
												 {} ->
												   element(2,
													   element(3,
														   Val));
											       true ->
												   0
											     end,
											     element(3,
												     Cur),
											     element(4,
												     Cur),
											     element(5,
												     Cur)}]
											     ++
											     if
											       element(2,
												       Acc)
												 =:=
												 {} ->
												   [];
											       true ->
												   [element(2,
													    Acc)]
											     end}]}}
										 end
									   end,
									   {[],
									    {}},
									   lists:foldl(fun
											 (Elem,
											  Acc) ->
											     if
											       length(Acc)
												 rem
												 2
												 =:=
												 0 ->
												   [Elem
												    | Acc];
											       true ->
												   [hd(Acc),
												    Elem
												    | tl(Acc)]
											     end
										       end,
										       [],
										       getmemd(Cur,
											       element(4,
												       Val)))))),
				       removefromlistoflists(2,
							     addtolistoflists(case
										lists:any(fun
											    (X) ->
												X
												  =:=
												  0
											  end,
											  NotExists)
										  of
										true ->
										    2;
										_ ->
										    lists:nth(element(2,
												      element(3,
													      Val))
												-
												element(1,
													Glob)
												+
												1,
											      LabelToNode)
									      end,
									      lists:foldl(fun
											    (Elem,
											     Acc) ->
												addtolistoflists(case
														   lists:any(fun
															       (X) ->
																   X
																     =:=
																     Elem
															     end,
															     NotExists)
														     of
														   true ->
														       2;
														   _ ->
														       lists:nth(element(2,
																	 lists:nth(Elem
																		     *
																		     2,
																		   getmemd(Cur,
																			   element(4,
																				   Val))))
																   -
																   element(1,
																	   Glob)
																   +
																   1,
																 LabelToNode)
														 end,
														 addtolistoflists(length(Pred)
																    +
																    Elem
																      *
																      2,
																  addtolistoflists(length(Pred)
																		     +
																		     Elem
																		       *
																		       2
																		     -
																		     1,
																		   Acc,
																		   if
																		     Elem
																		       =:=
																		       1 ->
																			 CurNode;
																		     true ->
																			 length(Pred)
																			   +
																			   Elem
																			     *
																			     2
																			   -
																			   2
																		   end),
																  if
																    Elem
																      =:=
																      1 ->
																	CurNode;
																    true ->
																	length(Pred)
																	  +
																	  Elem
																	    *
																	    2
																	  -
																	  2
																  end),
														 length(Pred)
														   +
														   Elem
														     *
														     2
														   -
														   1)
											  end,
											  Pred,
											  lists:seq(1,
												    length(getmemd(Cur,
														   element(4,
															   Val)))
												      div
												      2)),
									      length(Pred)
										+
										DefIdx
										  *
										  2
										-
										2),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(length(Pred)
										+
										DefIdx
										  *
										  2
										-
										2,
									      lists:foldl(fun
											    (Elem,
											     Acc) ->
												addtolistoflists(length(Pred)
														   +
														   Elem
														     *
														     2
														   -
														   1,
														 addtolistoflists(if
																    Elem
																      =:=
																      1 ->
																	CurNode;
																    true ->
																	length(Pred)
																	  +
																	  Elem
																	    *
																	    2
																	  -
																	  2
																  end,
																  addtolistoflists(if
																		     Elem
																		       =:=
																		       1 ->
																			 CurNode;
																		     true ->
																			 length(Pred)
																			   +
																			   Elem
																			     *
																			     2
																			   -
																			   2
																		   end,
																		   Acc,
																		   length(Pred)
																		     +
																		     Elem
																		       *
																		       2
																		     -
																		     1),
																  length(Pred)
																    +
																    Elem
																      *
																      2),
														 case
														   lists:any(fun
															       (X) ->
																   X
																     =:=
																     Elem
															     end,
															     NotExists)
														     of
														   true ->
														       2;
														   _ ->
														       lists:nth(element(2,
																	 lists:nth(Elem
																		     *
																		     2,
																		   getmemd(Cur,
																			   element(4,
																				   Val))))
																   -
																   element(1,
																	   Glob)
																   +
																   1,
																 LabelToNode)
														 end)
											  end,
											  Succ,
											  lists:seq(1,
												    length(getmemd(Cur,
														   element(4,
															   Val)))
												      div
												      2)),
									      case
										lists:any(fun
											    (X) ->
												X
												  =:=
												  0
											  end,
											  NotExists)
										  of
										true ->
										    2;
										_ ->
										    lists:nth(element(2,
												      element(3,
													      Val))
												-
												element(1,
													Glob)
												+
												1,
											      LabelToNode)
									      end),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1])
					 ++
					 lists:foldl(fun (El, A) ->
							     if El =:= 1 ->
								    lists:droplast(A);
								true -> A
							     end
							       ++
							       [[if El =:= 1 ->
									lists:last(lists:last(A));
								    true ->
									lists:droplast(lists:last(lists:last(A)))
									  ++
									  [lists:last(lists:last(lists:last(A)))
									     +
									     1]
								 end
								   ++
								   [4, 1, 5,
								    1]],
								[if El =:= 1 ->
									lists:last(lists:last(A));
								    true ->
									lists:droplast(lists:last(lists:last(A)))
									  ++
									  [lists:last(lists:last(lists:last(A)))
									     +
									     1]
								 end
								   ++
								   [4, 2, 5,
								    1]]]
						     end,
						     [[lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1]]],
						     lists:seq(1,
							       length(getmemd(Cur,
									      element(4,
										      Val)))
								 div 2)),
				       lists:foldl(fun (Elem, Acc) ->
							   addtolist(element(2,
									     if
									       Elem
										 =:=
										 0 ->
										   element(3,
											   Val);
									       true ->
										   lists:nth(Elem
											       *
											       2,
											     getmemd(Cur,
												     element(4,
													     Val)))
									     end)
								       -
								       element(1,
									       Glob)
								       + 1,
								     Acc,
								     length(Pred)
								       +
								       if Elem
									    =:=
									    0 ->
									      DefIdx;
									  true ->
									      Elem
								       end
									 * 2
								       - 1)
						   end,
						   LabelToNode, NotExists),
				       CurNode, VarPrefix, AssignedVars, true},
				      Glob);
		   select_tuple_arity ->
		       DefIdx = length(getmemd(Cur, element(4, Val))) div 2 +
				  1,
		       NotExists = lists:filter(fun (Elem) ->
							element(2,
								lists:nth(Elem *
									    2,
									  getmemd(Cur,
										  element(4,
											  Val))))
							  - element(1, Glob)
							  + 1
							  > length(LabelToNode)
							  orelse
							  lists:nth(element(2,
									    lists:nth(Elem
											*
											2,
										      getmemd(Cur,
											      element(4,
												      Val))))
								      -
								      element(1,
									      Glob)
								      + 1,
								    LabelToNode)
							    =:= 0
						end,
						lists:seq(1,
							  length(getmemd(Cur,
									 element(4,
										 Val)))
							    div 2))
				     ++
				     case element(2, element(3, Val)) -
					    element(1, Glob)
					    + 1
					    > length(LabelToNode)
					    orelse
					    lists:nth(element(2,
							      element(3, Val))
							- element(1, Glob)
							+ 1,
						      LabelToNode)
					      =:= 0
					 of
				       true -> [0];
				       _ -> []
				     end,
		       decompile_step({tl(InstList),
				       insertgraphpath(AST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1],
						       {'case', 0,
							{call, 0,
							 {atom, 0, tuple_size},
							 [getmemd(Cur,
								  element(2,
									  Val))]},
							lists:reverse(lists:foldl(fun
										    (Elem,
										     Acc) ->
											if
											  length(Acc)
											    =:=
											    0
											    orelse
											    is_tuple(hd(Acc)) ->
											      [[Elem]
											       | Acc];
											  true ->
											      [{clause,
												0,
												[case
												   element(1,
													   hd(hd(Acc)))
												     of
												   atom ->
												       {atom,
													0,
													element(2,
														hd(hd(Acc)))};
												   integer ->
												       {integer,
													0,
													element(2,
														hd(hd(Acc)))}
												 end],
												[],
												[{graphdata,
												  element(2,
													  Elem),
												  element(3,
													  Cur),
												  element(4,
													  Cur),
												  element(5,
													  Cur)}]}
											       | tl(Acc)]
											end
										  end,
										  [],
										  getmemd(Cur,
											  element(4,
												  Val))))
							  ++
							  [{clause, 0,
							    [{var, 0, '_'}], [],
							    [{graphdata,
							      element(2,
								      element(3,
									      Val)),
							      element(3, Cur),
							      element(4, Cur),
							      element(5,
								      Cur)}]}]}),
				       removefromlistoflists(2,
							     addtolistoflists(case
										lists:any(fun
											    (X) ->
												X
												  =:=
												  0
											  end,
											  NotExists)
										  of
										true ->
										    2;
										_ ->
										    lists:nth(element(2,
												      element(3,
													      Val))
												-
												element(1,
													Glob)
												+
												1,
											      LabelToNode)
									      end,
									      addtolistoflists(length(Pred)
												 +
												 DefIdx,
											       lists:foldl(fun
													     (Elem,
													      Acc) ->
														 addtolistoflists(case
																    lists:any(fun
																		(X) ->
																		    X
																		      =:=
																		      Elem
																	      end,
																	      NotExists)
																      of
																    true ->
																	2;
																    _ ->
																	lists:nth(element(2,
																			  lists:nth(Elem
																				      *
																				      2,
																				    getmemd(Cur,
																					    element(4,
																						    Val))))
																		    -
																		    element(1,
																			    Glob)
																		    +
																		    1,
																		  LabelToNode)
																  end,
																  addtolistoflists(length(Pred)
																		     +
																		     Elem,
																		   Acc,
																		   CurNode),
																  length(Pred)
																    +
																    Elem)
													   end,
													   Pred,
													   lists:seq(1,
														     length(getmemd(Cur,
																    element(4,
																	    Val)))
														       div
														       2)),
											       CurNode),
									      length(Pred)
										+
										DefIdx),
							     CurNode),
				       removefromlistoflists(CurNode,
							     addtolistoflists(length(Pred)
										+
										DefIdx,
									      addtolistoflists(CurNode,
											       lists:foldl(fun
													     (Elem,
													      Acc) ->
														 addtolistoflists(length(Pred)
																    +
																    Elem,
																  addtolistoflists(CurNode,
																		   Acc,
																		   length(Pred)
																		     +
																		     Elem),
																  case
																    lists:any(fun
																		(X) ->
																		    X
																		      =:=
																		      Elem
																	      end,
																	      NotExists)
																      of
																    true ->
																	2;
																    _ ->
																	lists:nth(element(2,
																			  lists:nth(Elem
																				      *
																				      2,
																				    getmemd(Cur,
																					    element(4,
																						    Val))))
																		    -
																		    element(1,
																			    Glob)
																		    +
																		    1,
																		  LabelToNode)
																  end)
													   end,
													   Succ,
													   lists:seq(1,
														     length(getmemd(Cur,
																    element(4,
																	    Val)))
														       div
														       2)),
											       length(Pred)
												 +
												 DefIdx),
									      case
										lists:any(fun
											    (X) ->
												X
												  =:=
												  0
											  end,
											  NotExists)
										  of
										true ->
										    2;
										_ ->
										    lists:nth(element(2,
												      element(3,
													      Val))
												-
												element(1,
													Glob)
												+
												1,
											      LabelToNode)
									      end),
							     2),
				       insert_renumber(NodesToAST,
						       lists:droplast(CurNodePath)
							 ++
							 [lists:last(CurNodePath)
							    + 1])
					 ++
					 [[lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 1, 4, X,
					      5, 1]]
					  || X
						 <- lists:seq(1,
							      length(getmemd(Cur,
									     element(4,
										     Val)))
								div 2
								+ 1)],
				       lists:foldl(fun (Elem, Acc) ->
							   addtolist(element(2,
									     if
									       Elem
										 =:=
										 0 ->
										   element(3,
											   Val);
									       true ->
										   lists:nth(Elem
											       *
											       2,
											     getmemd(Cur,
												     element(4,
													     Val)))
									     end)
								       -
								       element(1,
									       Glob)
								       + 1,
								     Acc,
								     length(Pred)
								       +
								       if Elem
									    =:=
									    0 ->
									      DefIdx;
									  true ->
									      Elem
								       end)
						   end,
						   LabelToNode, NotExists),
				       CurNode, VarPrefix, AssignedVars, true},
				      Glob);
		   test ->
		       NotExists = element(2, element(3, Val)) <
				     element(1, Glob)
				     orelse
				     element(2, element(3, Val)) -
				       element(1, Glob)
				       + 1
				       > length(LabelToNode)
				       orelse
				       lists:nth(element(2, element(3, Val)) -
						   element(1, Glob)
						   + 1,
						 LabelToNode)
					 =:= 0,
		       NewCur = case element(2, Val) of
				  bs_start_match2 ->
				      setmemd(Cur,
					      lists:nth(4, element(4, Val)),
					      {tuple, 0,
					       [getmemd(Cur,
							hd(element(4, Val))),
						getmemd(Cur,
							hd(element(4, Val)))]});
				  bs_skip_bits2 ->
				      setmemd(Cur, hd(element(4, Val)),
					      case lists:nth(2, element(4, Val))
						  of
						{atom, all} -> {bin, 0, []};
						_ ->
						    {tuple, 0,
						     [{call, 0,
						       {'fun', 0,
							{clauses,
							 [get_clean_ast(element(4,
										Glob),
									skip_bits,
									2)]}},
						       [hd(element(3,
								   getmemd(Cur,
									   hd(element(4,
										      Val))))),
							{op, 0, '*',
							 getmemd(Cur,
								 lists:nth(2,
									   element(4,
										   Val))),
							 {integer, 0,
							  lists:nth(3,
								    element(4,
									    Val))}}]},
						      lists:nth(2,
								element(3,
									getmemd(Cur,
										hd(element(4,
											   Val)))))]}
					      end);
				  bs_skip_utf8 ->
				      setmemd(Cur, hd(element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  skip_bits,
								  2)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {call, 0,
						   {'fun', 0,
						    {clauses,
						     [get_clean_ast(element(4,
									    Glob),
								    get_utf8_size,
								    1)]}},
						   [hd(element(3,
							       getmemd(Cur,
								       hd(element(4,
										  Val)))))]}]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  bs_skip_utf16 ->
				      setmemd(Cur, hd(element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  skip_bits,
								  2)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {call, 0,
						   {'fun', 0,
						    {clauses,
						     [get_clean_ast(element(4,
									    Glob),
								    get_utf16_size,
								    2)]}},
						   [hd(element(3,
							       getmemd(Cur,
								       hd(element(4,
										  Val))))),
						    case element(2,
								 lists:nth(3,
									   element(4,
										   Val)))
							   band 16
							   =:= 16
							of
						      true ->
							  {op, 0, '=:=',
							   {atom, 0, little},
							   {call, 0,
							    {remote,
							     {atom, 0, erlang},
							     {atom, 0,
							      system_info}},
							    [{atom, 0,
							      endian}]}};
						      _ ->
							  {atom, 0,
							   element(2,
								   lists:nth(3,
									     element(4,
										     Val)))
							     band 2
							     =:= 2}
						    end]}]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  bs_skip_utf32 ->
				      setmemd(Cur, hd(element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  skip_bits,
								  2)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {integer, 0, 4 * 8}]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  bs_get_integer2 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      {tuple, 0,
						       [{call, 0,
							 {'fun', 0,
							  {clauses,
							   [get_clean_ast(element(4,
										  Glob),
									  skip_bits,
									  2)]}},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val))))),
							  {op, 0, '*',
							   {integer, 0,
							    lists:nth(4,
								      element(4,
									      Val))},
							   getmemd(Cur,
								   lists:nth(3,
									     element(4,
										     Val)))}]},
							lists:nth(2,
								  element(3,
									  getmemd(Cur,
										  hd(element(4,
											     Val)))))]}),
					      lists:nth(6, element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  get_integer,
								  4)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {op, 0, '*',
						   {integer, 0,
						    lists:nth(4,
							      element(4, Val))},
						   getmemd(Cur,
							   lists:nth(3,
								     element(4,
									     Val)))},
						  case element(2,
							       lists:nth(5,
									 element(4,
										 Val)))
							 band 16
							 =:= 16
						      of
						    true ->
							{op, 0, '=:=',
							 {atom, 0, little},
							 {call, 0,
							  {remote,
							   {atom, 0, erlang},
							   {atom, 0,
							    system_info}},
							  [{atom, 0, endian}]}};
						    _ ->
							{atom, 0,
							 element(2,
								 lists:nth(5,
									   element(4,
										   Val)))
							   band 2
							   =:= 2}
						  end,
						  {atom, 0,
						   element(2,
							   lists:nth(5,
								     element(4,
									     Val)))
						     band 4
						     =:= 4}]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  bs_get_float2 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      {tuple, 0,
						       [{call, 0,
							 {'fun', 0,
							  {clauses,
							   [get_clean_ast(element(4,
										  Glob),
									  skip_bits,
									  2)]}},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val))))),
							  {op, 0, '*',
							   {integer, 0,
							    lists:nth(4,
								      element(4,
									      Val))},
							   getmemd(Cur,
								   lists:nth(3,
									     element(4,
										     Val)))}]},
							lists:nth(2,
								  element(3,
									  getmemd(Cur,
										  hd(element(4,
											     Val)))))]}),
					      lists:nth(6, element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  get_float,
								  3)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {op, 0, '*',
						   {integer, 0,
						    lists:nth(4,
							      element(4, Val))},
						   getmemd(Cur,
							   lists:nth(3,
								     element(4,
									     Val)))},
						  case element(2,
							       lists:nth(5,
									 element(4,
										 Val)))
							 band 16
							 =:= 16
						      of
						    true ->
							{op, 0, '=:=',
							 {atom, 0, little},
							 {call, 0,
							  {remote,
							   {atom, 0, erlang},
							   {atom, 0,
							    system_info}},
							  [{atom, 0, endian}]}};
						    _ ->
							{atom, 0,
							 element(2,
								 lists:nth(5,
									   element(4,
										   Val)))
							   band 2
							   =:= 2}
						  end]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  bs_get_utf8 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      {tuple, 0,
						       [{call, 0,
							 {'fun', 0,
							  {clauses,
							   [get_clean_ast(element(4,
										  Glob),
									  skip_bits,
									  2)]}},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val))))),
							  {call, 0,
							   {'fun', 0,
							    {clauses,
							     [get_clean_ast(element(4,
										    Glob),
									    get_utf8_size,
									    1)]}},
							   [hd(element(3,
								       getmemd(Cur,
									       hd(element(4,
											  Val)))))]}]},
							lists:nth(2,
								  element(3,
									  getmemd(Cur,
										  hd(element(4,
											     Val)))))]}),
					      lists:nth(4, element(4, Val)),
					      {call, 0,
					       {'fun', 0,
						{clauses,
						 [get_clean_ast(element(4,
									Glob),
								get_utf8, 1)]}},
					       [hd(element(3,
							   getmemd(Cur,
								   hd(element(4,
									      Val)))))]});
				  bs_get_utf16 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      {tuple, 0,
						       [{call, 0,
							 {'fun', 0,
							  {clauses,
							   [get_clean_ast(element(4,
										  Glob),
									  skip_bits,
									  2)]}},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val))))),
							  {call, 0,
							   {'fun', 0,
							    {clauses,
							     [get_clean_ast(element(4,
										    Glob),
									    get_utf16_size,
									    2)]}},
							   [hd(element(3,
								       getmemd(Cur,
									       hd(element(4,
											  Val))))),
							    case element(2,
									 lists:nth(3,
										   element(4,
											   Val)))
								   band 16
								   =:= 16
								of
							      true ->
								  {op, 0, '=:=',
								   {atom, 0,
								    little},
								   {call, 0,
								    {remote,
								     {atom, 0,
								      erlang},
								     {atom, 0,
								      system_info}},
								    [{atom, 0,
								      endian}]}};
							      _ ->
								  {atom, 0,
								   element(2,
									   lists:nth(3,
										     element(4,
											     Val)))
								     band 2
								     =:= 2}
							    end]}]},
							lists:nth(2,
								  element(3,
									  getmemd(Cur,
										  hd(element(4,
											     Val)))))]}),
					      lists:nth(4, element(4, Val)),
					      {call, 0,
					       {'fun', 0,
						{clauses,
						 [get_clean_ast(element(4,
									Glob),
								get_utf16,
								2)]}},
					       [hd(element(3,
							   getmemd(Cur,
								   hd(element(4,
									      Val))))),
						case element(2,
							     lists:nth(3,
								       element(4,
									       Val)))
						       band 16
						       =:= 16
						    of
						  true ->
						      {op, 0, '=:=',
						       {atom, 0, little},
						       {call, 0,
							{remote,
							 {atom, 0, erlang},
							 {atom, 0,
							  system_info}},
							[{atom, 0, endian}]}};
						  _ ->
						      {atom, 0,
						       element(2,
							       lists:nth(3,
									 element(4,
										 Val)))
							 band 2
							 =:= 2}
						end]});
				  bs_get_utf32 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      {tuple, 0,
						       [{call, 0,
							 {'fun', 0,
							  {clauses,
							   [get_clean_ast(element(4,
										  Glob),
									  skip_bits,
									  2)]}},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val))))),
							  {integer, 0, 4 * 8}]},
							lists:nth(2,
								  element(3,
									  getmemd(Cur,
										  hd(element(4,
											     Val)))))]}),
					      lists:nth(4, element(4, Val)),
					      {call, 0,
					       {'fun', 0,
						{clauses,
						 [get_clean_ast(element(4,
									Glob),
								get_utf32,
								2)]}},
					       [hd(element(3,
							   getmemd(Cur,
								   hd(element(4,
									      Val))))),
						case element(2,
							     lists:nth(3,
								       element(4,
									       Val)))
						       band 16
						       =:= 16
						    of
						  true ->
						      {op, 0, '=:=',
						       {atom, 0, little},
						       {call, 0,
							{remote,
							 {atom, 0, erlang},
							 {atom, 0,
							  system_info}},
							[{atom, 0, endian}]}};
						  _ ->
						      {atom, 0,
						       element(2,
							       lists:nth(3,
									 element(4,
										 Val)))
							 band 2
							 =:= 2}
						end]});
				  bs_get_binary2 ->
				      setmemd(setmemd(Cur, hd(element(4, Val)),
						      case lists:nth(3,
								     element(4,
									     Val))
							  of
							{atom, all} ->
							    {bin, 0, []};
							_ ->
							    {tuple, 0,
							     [{call, 0,
							       {'fun', 0,
								{clauses,
								 [get_clean_ast(element(4,
											Glob),
										skip_bits,
										2)]}},
							       [hd(element(3,
									   getmemd(Cur,
										   hd(element(4,
											      Val))))),
								{op, 0, '*',
								 getmemd(Cur,
									 lists:nth(3,
										   element(4,
											   Val))),
								 {integer, 0,
								  lists:nth(4,
									    element(4,
										    Val))}}]},
							      lists:nth(2,
									element(3,
										getmemd(Cur,
											hd(element(4,
												   Val)))))]}
						      end),
					      lists:nth(6, element(4, Val)),
					      case lists:nth(3, element(4, Val))
						  of
						{atom, all} ->
						    hd(element(3,
							       getmemd(Cur,
								       hd(element(4,
										  Val)))));
						_ ->
						    {tuple, 0,
						     [{call, 0,
						       {'fun', 0,
							{clauses,
							 [get_clean_ast(element(4,
										Glob),
									get_bits,
									2)]}},
						       [hd(element(3,
								   getmemd(Cur,
									   hd(element(4,
										      Val))))),
							{op, 0, '*',
							 getmemd(Cur,
								 lists:nth(3,
									   element(4,
										   Val))),
							 {integer, 0,
							  lists:nth(4,
								    element(4,
									    Val))}}]},
						      lists:nth(2,
								element(3,
									getmemd(Cur,
										hd(element(4,
											   Val)))))]}
					      end);
				  bs_match_string ->
				      setmemd(Cur, hd(element(4, Val)),
					      {tuple, 0,
					       [{call, 0,
						 {'fun', 0,
						  {clauses,
						   [get_clean_ast(element(4,
									  Glob),
								  skip_bits,
								  2)]}},
						 [hd(element(3,
							     getmemd(Cur,
								     hd(element(4,
										Val))))),
						  {integer, 0,
						   lists:nth(2,
							     element(4,
								     Val))}]},
						lists:nth(2,
							  element(3,
								  getmemd(Cur,
									  hd(element(4,
										     Val)))))]});
				  _ -> Cur
				end,
		       NewAST = insertgraphpath(AST,
						lists:droplast(CurNodePath) ++
						  [lists:last(CurNodePath) + 1],
						{'case', 0,
						 case element(2, Val) of
						   is_lt ->
						       {op, 0, '<',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_ge ->
						       {op, 0, '>=',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_eq ->
						       {op, 0, '==',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_ne ->
						       {op, 0, '/=',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_eq_exact ->
						       {op, 0, '=:=',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_ne_exact ->
						       {op, 0, '=/=',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							getmemd(Cur,
								lists:nth(2,
									  element(4,
										  Val)))};
						   is_integer ->
						       {call, 0,
							{atom, 0, is_integer},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_float ->
						       {call, 0,
							{atom, 0, is_float},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_number ->
						       {call, 0,
							{atom, 0, is_number},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_atom ->
						       {call, 0,
							{atom, 0, is_atom},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_pid ->
						       {call, 0,
							{atom, 0, is_pid},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_reference ->
						       {call, 0,
							{atom, 0, is_reference},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_port ->
						       {call, 0,
							{atom, 0, is_port},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_nil ->
						       {op, 0, '=:=',
							getmemd(Cur,
								hd(element(4,
									   Val))),
							{nil, 0}};
						   is_boolean ->
						       {call, 0,
							{atom, 0, is_boolean},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_binary ->
						       {call, 0,
							{atom, 0, is_binary},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_bitstr ->
						       {call, 0,
							{atom, 0, is_bitstring},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_list ->
						       {call, 0,
							{atom, 0, is_list},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_nonempty_list ->
						       {op, 0, 'andalso',
							{call, 0,
							 {atom, 0, is_list},
							 [getmemd(Cur,
								  hd(element(4,
									     Val)))]},
							{op, 0, '=/=',
							 getmemd(Cur,
								 hd(element(4,
									    Val))),
							 {nil, 0}}};
						   is_tuple ->
						       {call, 0,
							{atom, 0, is_tuple},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_function ->
						       {call, 0,
							{atom, 0, is_function},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   is_function2 ->
						       {call, 0,
							{atom, 0, is_function},
							[getmemd(Cur,
								 hd(element(4,
									    Val))),
							 getmemd(Cur,
								 lists:nth(2,
									   element(4,
										   Val)))]};
						   is_map ->
						       {call, 0,
							{atom, 0, is_map},
							[getmemd(Cur,
								 hd(element(4,
									    Val)))]};
						   has_map_fields ->
						       lists:foldl(fun (El,
									Acc) ->
									   Next =
									       {call,
										0,
										{remote,
										 0,
										 {atom,
										  0,
										  maps},
										 {atom,
										  0,
										  is_key}},
										[getmemd(Cur,
											 El),
										 getmemd(Cur,
											 element(4,
												 Val))]},
									   if
									     Acc
									       =:=
									       [] ->
										 Next;
									     true ->
										 {op,
										  0,
										  'andalso',
										  Next,
										  Acc}
									   end
								   end,
								   [],
								   getmemd(Cur,
									   element(5,
										   Val)));
						   is_tagged_tuple ->
						       {op, 0, 'andalso',
							{call, 0,
							 {atom, 0, is_tuple},
							 [getmemd(Cur,
								  hd(element(4,
									     Val)))]},
							{op, 0, 'andalso',
							 {op, 0, '=:=',
							  {call, 0,
							   {atom, 0,
							    tuple_size},
							   [getmemd(Cur,
								    hd(element(4,
									       Val)))]},
							  {integer, 0,
							   lists:nth(2,
								     element(4,
									     Val))}},
							 {op, 0, '=:=',
							  {call, 0,
							   {atom, 0, element},
							   [{integer, 0, 1},
							    getmemd(Cur,
								    hd(element(4,
									       Val)))]},
							  {atom, 0,
							   element(2,
								   lists:nth(3,
									     element(4,
										     Val)))}}}};
						   test_arity ->
						       {op, 0, '=:=',
							{call, 0,
							 {atom, 0, tuple_size},
							 [getmemd(Cur,
								  hd(element(4,
									     Val)))]},
							{integer, 0,
							 lists:nth(2,
								   element(4,
									   Val))}};
						   bs_test_unit ->
						       {op, 0, '=:=',
							{op, 0, 'rem',
							 {call, 0,
							  {atom, 0, bit_size},
							  [getmemd(Cur,
								   hd(element(4,
									      Val)))]},
							 {integer, 0,
							  lists:nth(2,
								    element(4,
									    Val))}},
							{integer, 0, 0}};
						   bs_test_tail2 ->
						       {op, 0, '=:=',
							{call, 0,
							 {atom, 0, bit_size},
							 [getmemd(Cur,
								  hd(element(4,
									     Val)))]},
							{integer, 0,
							 lists:nth(2,
								   element(4,
									   Val))}};
						   bs_start_match2 ->
						       case
							 is_tuple(getmemd(Cur,
									  hd(element(4,
										     Val))))
							   of
							 true ->
							     {atom, 0, true};
							 _ ->
							     {call, 0,
							      {atom, 0,
							       is_bitstring},
							      [getmemd(Cur,
								       hd(element(4,
										  Val)))]}
						       end;
						   bs_skip_bits2 ->
						       case lists:nth(2,
								      element(4,
									      Val))
							   of
							 {atom, all} ->
							     {op, 0, '=:=',
							      {op, 0, 'rem',
							       {call, 0,
								{atom, 0,
								 bit_size},
								[hd(element(3,
									    getmemd(Cur,
										    hd(element(4,
											       Val)))))]},
							       {integer, 0,
								lists:nth(3,
									  element(4,
										  Val))}},
							      {integer, 0, 0}};
							 _ ->
							     {op, 0, 'andalso',
							      {op, 0, '>=',
							       getmemd(Cur,
								       lists:nth(2,
										 element(4,
											 Val))),
							       {integer, 0, 0}},
							      {op, 0, '>=',
							       {call, 0,
								{atom, 0,
								 bit_size},
								[hd(element(3,
									    getmemd(Cur,
										    hd(element(4,
											       Val)))))]},
							       {op, 0, '*',
								getmemd(Cur,
									lists:nth(2,
										  element(4,
											  Val))),
								{integer, 0,
								 lists:nth(3,
									   element(4,
										   Val))}}}}
						       end;
						   bs_skip_utf8 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf8,
									 1)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val)))))]};
						   bs_skip_utf16 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf16,
									 2)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val))))),
							 case element(2,
								      lists:nth(3,
										element(4,
											Val)))
								band 16
								=:= 16
							     of
							   true ->
							       {op, 0, '=:=',
								{atom, 0,
								 little},
								{call, 0,
								 {remote,
								  {atom, 0,
								   erlang},
								  {atom, 0,
								   system_info}},
								 [{atom, 0,
								   endian}]}};
							   _ ->
							       {atom, 0,
								element(2,
									lists:nth(3,
										  element(4,
											  Val)))
								  band 2
								  =:= 2}
							 end]};
						   bs_skip_utf32 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf32,
									 2)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val))))),
							 case element(2,
								      lists:nth(3,
										element(4,
											Val)))
								band 16
								=:= 16
							     of
							   true ->
							       {op, 0, '=:=',
								{atom, 0,
								 little},
								{call, 0,
								 {remote,
								  {atom, 0,
								   erlang},
								  {atom, 0,
								   system_info}},
								 [{atom, 0,
								   endian}]}};
							   _ ->
							       {atom, 0,
								element(2,
									lists:nth(3,
										  element(4,
											  Val)))
								  band 2
								  =:= 2}
							 end]};
						   bs_get_integer2 ->
						       {op, 0, '>=',
							{call, 0,
							 {atom, 0, bit_size},
							 [hd(element(3,
								     getmemd(Cur,
									     hd(element(4,
											Val)))))]},
							{op, 0, '*',
							 {integer, 0,
							  lists:nth(4,
								    element(4,
									    Val))},
							 getmemd(Cur,
								 lists:nth(3,
									   element(4,
										   Val)))}};
						   bs_get_float2 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_float,
									 3)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val))))),
							 {op, 0, '*',
							  {integer, 0,
							   lists:nth(4,
								     element(4,
									     Val))},
							  getmemd(Cur,
								  lists:nth(3,
									    element(4,
										    Val)))},
							 case element(2,
								      lists:nth(5,
										element(4,
											Val)))
								band 16
								=:= 16
							     of
							   true ->
							       {op, 0, '=:=',
								{atom, 0,
								 little},
								{call, 0,
								 {remote,
								  {atom, 0,
								   erlang},
								  {atom, 0,
								   system_info}},
								 [{atom, 0,
								   endian}]}};
							   _ ->
							       {atom, 0,
								element(2,
									lists:nth(5,
										  element(4,
											  Val)))
								  band 2
								  =:= 2}
							 end]};
						   bs_get_utf8 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf8,
									 1)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val)))))]};
						   bs_get_utf16 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf16,
									 2)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val))))),
							 case element(2,
								      lists:nth(3,
										element(4,
											Val)))
								band 16
								=:= 16
							     of
							   true ->
							       {op, 0, '=:=',
								{atom, 0,
								 little},
								{call, 0,
								 {remote,
								  {atom, 0,
								   erlang},
								  {atom, 0,
								   system_info}},
								 [{atom, 0,
								   endian}]}};
							   _ ->
							       {atom, 0,
								element(2,
									lists:nth(3,
										  element(4,
											  Val)))
								  band 2
								  =:= 2}
							 end]};
						   bs_get_utf32 ->
						       {call, 0,
							{'fun', 0,
							 {clauses,
							  [get_clean_ast(element(4,
										 Glob),
									 has_utf32,
									 2)]}},
							[hd(element(3,
								    getmemd(Cur,
									    hd(element(4,
										       Val))))),
							 case element(2,
								      lists:nth(3,
										element(4,
											Val)))
								band 16
								=:= 16
							     of
							   true ->
							       {op, 0, '=:=',
								{atom, 0,
								 little},
								{call, 0,
								 {remote,
								  {atom, 0,
								   erlang},
								  {atom, 0,
								   system_info}},
								 [{atom, 0,
								   endian}]}};
							   _ ->
							       {atom, 0,
								element(2,
									lists:nth(3,
										  element(4,
											  Val)))
								  band 2
								  =:= 2}
							 end]};
						   bs_get_binary2 ->
						       case lists:nth(3,
								      element(4,
									      Val))
							   of
							 {atom, all} ->
							     {op, 0, '=:=',
							      {op, 0, 'rem',
							       {call, 0,
								{atom, 0,
								 bit_size},
								[hd(element(3,
									    getmemd(Cur,
										    hd(element(4,
											       Val)))))]},
							       {integer, 0,
								lists:nth(4,
									  element(4,
										  Val))}},
							      {integer, 0, 0}};
							 _ ->
							     {op, 0, 'andalso',
							      {op, 0, '>=',
							       getmemd(Cur,
								       lists:nth(3,
										 element(4,
											 Val))),
							       {integer, 0, 0}},
							      {op, 0, '>=',
							       {call, 0,
								{atom, 0,
								 bit_size},
								[hd(element(3,
									    getmemd(Cur,
										    hd(element(4,
											       Val)))))]},
							       {op, 0, '*',
								getmemd(Cur,
									lists:nth(3,
										  element(4,
											  Val))),
								{integer, 0,
								 lists:nth(4,
									   element(4,
										   Val))}}}}
						       end;
						   bs_match_string ->
						       {op, 0, 'andalso',
							{op, 0, '>=',
							 {call, 0,
							  {atom, 0, bit_size},
							  [hd(element(3,
								      getmemd(Cur,
									      hd(element(4,
											 Val)))))]},
							 {integer, 0,
							  lists:nth(2,
								    element(4,
									    Val))}},
							{op, 0, '=:=',
							 {call, 0,
							  {'fun', 0,
							   {clauses,
							    [get_clean_ast(element(4,
										   Glob),
									   get_bits,
									   2)]}},
							  [hd(element(3,
								      getmemd(Cur,
									      hd(element(4,
											 Val))))),
							   {integer, 0,
							    lists:nth(2,
								      element(4,
									      Val))}]},
							 getliteral(lists:nth(3,
									      element(4,
										      Val)))}}
						 end,
						 [{clause, 0, [{atom, 0, true}],
						   [],
						   [{graphdata, 0,
						     element(3, NewCur),
						     element(4, NewCur),
						     element(5, NewCur)}]},
						  {clause, 0,
						   [{atom, 0, false}], [],
						   [{graphdata,
						     element(2,
							     element(3, Val)),
						     element(3, Cur),
						     element(4, Cur),
						     element(5, Cur)}
						    | if element(2,
								 element(3,
									 Val))
							   < element(1, Glob) ->
							     [{call, 0,
							       {remote, 0,
								{atom, 0,
								 erlang},
								{atom, 0,
								 error}},
							       [{atom, 0,
								 function_clause}]}];
							 true -> []
						      end]}]}),
		       case NotExists of
			 true ->
			     decompile_step({tl(InstList), NewAST,
					     removefromlistoflists(2,
								   addtolistoflists(2,
										    addtolistoflists(2,
												     addtolistoflists(length(Pred)
															+
															2,
														      addtolistoflists(length(Pred)
																	 +
																	 1,
																       if
																	 element(2,
																		 element(3,
																			 Val))
																	   <
																	   element(1,
																		   Glob) ->
																	     addtolistoflists(3,
																			      Pred,
																			      length(Pred)
																				+
																				2);
																	 true ->
																	     Pred
																       end,
																       CurNode),
														      CurNode),
												     length(Pred)
												       +
												       1),
										    length(Pred)
										      +
										      2),
								   CurNode),
					     removefromlistoflists(CurNode,
								   addtolistoflists(length(Pred)
										      +
										      2,
										    addtolistoflists(length(Pred)
												       +
												       1,
												     addtolistoflists(CurNode,
														      addtolistoflists(CurNode,
																       if
																	 element(2,
																		 element(3,
																			 Val))
																	   <
																	   element(1,
																		   Glob) ->
																	     addtolistoflists(length(Pred)
																				+
																				2,
																			      Succ,
																			      3);
																	 true ->
																	     Succ
																       end,
																       length(Pred)
																	 +
																	 1),
														      length(Pred)
															+
															2),
												     2),
										    2),
								   2),
					     insert_renumber(NodesToAST,
							     lists:droplast(CurNodePath)
							       ++
							       [lists:last(CurNodePath)
								  + 1])
					       ++
					       [[lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) + 1,
						    4, 1, 5, 1]],
						[lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) + 1,
						    4, 2, 5, 1]]],
					     if element(2, element(3, Val)) <
						  element(1, Glob) ->
						    LabelToNode;
						true ->
						    addtolist(element(2,
								      element(3,
									      Val))
								-
								element(1, Glob)
								+ 1,
							      LabelToNode,
							      length(Pred) + 2)
					     end,
					     length(Pred) + 1, VarPrefix,
					     AssignedVars, false},
					    Glob);
			 _ ->
			     Node = lists:nth(element(2, element(3, Val)) -
						element(1, Glob)
						+ 1,
					      LabelToNode),
			     decompile_step({tl(InstList), NewAST,
					     removefromlistoflists(2,
								   addtolistoflists(Node,
										    addtolistoflists(2,
												     addtolistoflists(length(Pred)
															+
															2,
														      addtolistoflists(length(Pred)
																	 +
																	 1,
																       Pred,
																       CurNode),
														      CurNode),
												     length(Pred)
												       +
												       1),
										    length(Pred)
										      +
										      2),
								   CurNode),
					     removefromlistoflists(CurNode,
								   addtolistoflists(length(Pred)
										      +
										      2,
										    addtolistoflists(length(Pred)
												       +
												       1,
												     addtolistoflists(CurNode,
														      addtolistoflists(CurNode,
																       Succ,
																       length(Pred)
																	 +
																	 1),
														      length(Pred)
															+
															2),
												     2),
										    Node),
								   2),
					     insert_renumber(NodesToAST,
							     lists:droplast(CurNodePath)
							       ++
							       [lists:last(CurNodePath)
								  + 1])
					       ++
					       [[lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) + 1,
						    4, 1, 5, 1]],
						[lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) + 1,
						    4, 2, 5, 1]]],
					     LabelToNode, length(Pred) + 1,
					     VarPrefix, AssignedVars, false},
					    Glob)
		       end;
		   move ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(3, Val),
							    getmemd(Cur,
								    element(2,
									    Val)))),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   fmove ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(3, Val),
							    getmemd(Cur,
								    element(2,
									    Val)))),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   fconv ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(3, Val),
							    getmemd(Cur,
								    element(2,
									    Val)))),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   get_tuple_element ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {call, 0,
							     {atom, 0, element},
							     [{integer, 0,
							       element(3, Val) +
								 1},
							      getmemd(Cur,
								      element(2,
									      Val))]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   set_tuple_element ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(3, Val),
							    {call, 0,
							     {atom, 0,
							      setelement},
							     [{integer, 0,
							       element(4, Val) +
								 1},
							      getmemd(Cur,
								      element(3,
									      Val)),
							      getmemd(Cur,
								      element(2,
									      Val))]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   put_tuple ->
		       decompile_step({lists:sublist(InstList,
						     2 + element(2, Val),
						     length(InstList)),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(3, Val),
							    {tuple, 0,
							     get_tuple_putsd(Cur,
									     {tl(InstList)},
									     element(2,
										     Val))})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   get_list ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(setmemd(Cur,
								    element(3,
									    Val),
								    {call, 0,
								     {atom, 0,
								      hd},
								     [getmemd(Cur,
									      element(2,
										      Val))]}),
							    element(4, Val),
							    {call, 0,
							     {atom, 0, tl},
							     [getmemd(Cur,
								      element(2,
									      Val))]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   put_list ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {cons, 0,
							     getmemd(Cur,
								     element(2,
									     Val)),
							     getmemd(Cur,
								     element(3,
									     Val))})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_init2 ->
		       {BinList, InstCount} = get_binary_putsd(Cur,
							       {tl(InstList)},
							       if
								 is_tuple(element(3,
										  Val)) ->
								     get_binary_sizes(getmemd(Cur,
											      element(3,
												      Val)));
								 true ->
								     lists:duplicate(element(3,
											     Val),
										     8)
							       end,
							       0),
		       decompile_step({lists:sublist(InstList, 2 + InstCount,
						     length(InstList)),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(7, Val),
							    {bin, 0, BinList})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_init_bits ->
		       {BinList, InstCount} = get_binary_putsd(Cur,
							       {tl(InstList)},
							       if
								 is_tuple(element(3,
										  Val)) ->
								     get_binary_sizes(getmemd(Cur,
											      element(3,
												      Val)));
								 true ->
								     element(3,
									     Val)
							       end,
							       0),
		       decompile_step({lists:sublist(InstList, 2 + InstCount,
						     length(InstList)),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(7, Val),
							    {bin, 0, BinList})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_append ->
		       {BinList, InstCount} = get_binary_putsd(Cur,
							       {tl(InstList)},
							       get_binary_sizes(getmemd(Cur,
											element(3,
												Val))),
							       0),
		       decompile_step({lists:sublist(InstList, 2 + InstCount,
						     length(InstList)),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(9, Val),
							    {bin, 0,
							     [{bin_element, 0,
							       getmemd(Cur,
								       element(7,
									       Val)),
							       default,
							       [binary]}
							      | BinList]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_private_append ->
		       {BinList, InstCount} = get_binary_putsd(Cur,
							       {tl(InstList)},
							       get_binary_sizes(getmemd(Cur,
											element(3,
												Val))),
							       0),
		       decompile_step({lists:sublist(InstList, 2 + InstCount,
						     length(InstList)),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(7, Val),
							    {bin, 0,
							     [{bin_element, 0,
							       getmemd(Cur,
								       element(5,
									       Val)),
							       default,
							       [binary]}
							      | BinList]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_add ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {op, 0, '+',
							     getmemd(Cur,
								     hd(element(3,
										Val))),
							     {op, 0, '*',
							      getmemd(Cur,
								      lists:nth(2,
										element(3,
											Val))),
							      {integer, 0,
							       lists:nth(3,
									 element(3,
										 Val))}}})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_utf8_size ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {'if', 0,
							     [{clause, 0, [],
							       [[{op, 0, '<',
								  getmemd(Cur,
									  element(3,
										  Val)),
								  {integer, 0,
								   128}}]],
							       [{integer, 0,
								 1}]},
							      {clause, 0, [],
							       [[{op, 0, '<',
								  getmemd(Cur,
									  element(3,
										  Val)),
								  {integer, 0,
								   2048}}]],
							       [{integer, 0,
								 2}]},
							      {clause, 0, [],
							       [[{op, 0, '<',
								  getmemd(Cur,
									  element(3,
										  Val)),
								  {integer, 0,
								   65536}}]],
							       [{integer, 0,
								 3}]},
							      {clause, 0, [],
							       [[{atom, 0,
								  true}]],
							       [{integer, 0,
								 4}]}]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_utf16_size ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {'if', 0,
							     [{clause, 0, [],
							       [[{op, 0, '>=',
								  getmemd(Cur,
									  element(3,
										  Val)),
								  {integer, 0,
								   65536}}]],
							       [{integer, 0,
								 4}]},
							      {clause, 0, [],
							       [[{atom, 0,
								  true}]],
							       [{integer, 0,
								 2}]}]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_save2 ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(2, Val),
							    {tuple, 0,
							     [hd(element(3,
									 getmemd(Cur,
										 element(2,
											 Val)))),
							      hd(element(3,
									 getmemd(Cur,
										 element(2,
											 Val))))]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_restore2 ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(2, Val),
							    {tuple, 0,
							     [lists:nth(2,
									element(3,
										getmemd(Cur,
											element(2,
												Val)))),
							      lists:nth(2,
									element(3,
										getmemd(Cur,
											element(2,
												Val))))]})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bs_context_to_binary ->
		       decompile_step({tl(InstList),
				       case getmemd(Cur, element(2, Val)) of
					 {tuple, _, [_, _]} ->
					     setgraphpath(AST, CurNodePath,
							  setmemd(Cur,
								  element(2,
									  Val),
								  lists:nth(2,
									    element(3,
										    getmemd(Cur,
											    element(2,
												    Val))))));
					 _ -> AST
				       end,
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   get_map_elements ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    element(1,
							    lists:foldl(fun (El,
									     {Acc,
									      Next}) ->
										if
										  Next
										    =:=
										    [] ->
										      {Acc,
										       [getmemd(Cur,
												El)]};
										  true ->
										      {setmemd(Acc,
											       El,
											       {call,
												0,
												{remote,
												 0,
												 {atom,
												  0,
												  maps},
												 {atom,
												  0,
												  get}},
												[hd(Next),
												 getmemd(Cur,
													 element(3,
														 Val))]}),
										       []}
										end
									end,
									{Cur,
									 []},
									getmemd(Cur,
										element(4,
											Val))))),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   put_map_exact ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {map, 0,
							     getmemd(Cur,
								     element(3,
									     Val)),
							     element(1,
								     lists:foldl(fun
										   (El,
										    {Acc,
										     Next}) ->
										       if
											 Next
											   =:=
											   [] ->
											     {Acc,
											      [getmemd(Cur,
												       El)]};
											 true ->
											     {[{map_field_exact,
												0,
												hd(Next),
												getmemd(Cur,
													El)}
											       | Acc],
											      []}
										       end
										 end,
										 {[],
										  []},
										 getmemd(Cur,
											 element(6,
												 Val))))})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   put_map_assoc ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setmemd(Cur,
							    element(4, Val),
							    {map, 0,
							     getmemd(Cur,
								     element(3,
									     Val)),
							     element(1,
								     lists:foldl(fun
										   (El,
										    {Acc,
										     Next}) ->
										       if
											 Next
											   =:=
											   [] ->
											     {Acc,
											      [getmemd(Cur,
												       El)]};
											 true ->
											     {[{map_field_assoc,
												0,
												hd(Next),
												getmemd(Cur,
													El)}
											       | Acc],
											      []}
										       end
										 end,
										 {[],
										  []},
										 getmemd(Cur,
											 element(6,
												 Val))))})),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   arithfbif ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    case element(2, Val) of
						      fadd ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '+',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      fsub ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '-',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      fmul ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '*',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      fdiv ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '/',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      fnegate ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '-',
								   getmemd(Cur,
									   hd(element(4,
										      Val)))})
						    end),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   bif ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    case element(2, Val) of
						      '==' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '==',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '<' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '<',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '=<' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '=<',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '>' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '>',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '>=' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '>=',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '=:=' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '=:=',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '/=' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '/=',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      '=/=' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, '=/=',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      'not' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, 'not',
								   getmemd(Cur,
									   hd(element(4,
										      Val)))});
						      'and' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, 'and',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      'or' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, 'or',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      'xor' ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {op, 0, 'xor',
								   getmemd(Cur,
									   hd(element(4,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(4,
											     Val)))});
						      is_integer ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_integer},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_float ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_float},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_number ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_number},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_pid ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_pid},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_reference ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_reference},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_port ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_port},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_boolean ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_boolean},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_binary ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_binary},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_bitstring ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_bitstring},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_list ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_list},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_atom ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_atom},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_tuple ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_tuple},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      is_function ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_function},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))
								    | if
									length(element(4,
										       Val))
									  =:=
									  2 ->
									    [getmemd(Cur,
										     lists:nth(2,
											       element(4,
												       Val)))];
									true ->
									    []
								      end]});
						      is_map ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    is_map},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      get ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    get},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      node ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    node},
								   []});
						      tuple_size ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    tuple_size},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      element ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    element},
								   [getmemd(Cur,
									    hd(element(4,
										       Val))),
								    getmemd(Cur,
									    lists:nth(2,
										      element(4,
											      Val)))]});
						      hd ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    hd},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      tl ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    tl},
								   [getmemd(Cur,
									    hd(element(4,
										       Val)))]});
						      self ->
							  setmemd(Cur,
								  element(5,
									  Val),
								  {call, 0,
								   {atom, 0,
								    self},
								   []})
						    end),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   gc_bif ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    case element(2, Val) of
						      '+' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, '+',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      '-' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  if
								    length(element(5,
										   Val))
								      =:= 1 ->
									{op, 0,
									 '-',
									 getmemd(Cur,
										 hd(element(5,
											    Val)))};
								    true ->
									{op, 0,
									 '-',
									 getmemd(Cur,
										 hd(element(5,
											    Val))),
									 getmemd(Cur,
										 lists:nth(2,
											   element(5,
												   Val)))}
								  end);
						      '*' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, '*',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      '/' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, '/',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      length ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {call, 0,
								   {atom, 0,
								    length},
								   [getmemd(Cur,
									    hd(element(5,
										       Val)))]});
						      size ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {call, 0,
								   {atom, 0,
								    size},
								   [getmemd(Cur,
									    hd(element(5,
										       Val)))]});
						      map_size ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {call, 0,
								   {atom, 0,
								    map_size},
								   [getmemd(Cur,
									    hd(element(5,
										       Val)))]});
						      bit_size ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {call, 0,
								   {atom, 0,
								    bit_size},
								   [getmemd(Cur,
									    hd(element(5,
										       Val)))]});
						      byte_size ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {call, 0,
								   {atom, 0,
								    byte_size},
								   [getmemd(Cur,
									    hd(element(5,
										       Val)))]});
						      round ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, round,
								   getmemd(Cur,
									   hd(element(5,
										      Val)))});
						      'div' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, 'div',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'rem' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, 'rem',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'band' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0,
								   'band',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'bor' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, 'bor',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'bxor' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0,
								   'bxor',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'bsl' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, 'bsl',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'bsr' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0, 'bsr',
								   getmemd(Cur,
									   hd(element(5,
										      Val))),
								   getmemd(Cur,
									   lists:nth(2,
										     element(5,
											     Val)))});
						      'bnot' ->
							  setmemd(Cur,
								  element(6,
									  Val),
								  {op, 0,
								   'bnot',
								   getmemd(Cur,
									   hd(element(5,
										      Val)))})
						    end),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   init ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   trim ->
		       decompile_step({tl(InstList),
				       setgraphpath(AST, CurNodePath,
						    setelement(4, Cur,
							       lists:sublist(element(4,
										     Cur),
									     element(2,
										     Val)
									       +
									       1,
									     length(element(4,
											    Cur))))),
				       Pred, Succ, NodesToAST, LabelToNode,
				       CurNode, VarPrefix, AssignedVars, false},
				      Glob);
		   allocate_zero ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   allocate_heap ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   allocate_heap_zero ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   allocate ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   deallocate ->
		       decompile_step({tl(InstList), AST, Pred, Succ,
				       NodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars, false},
				      Glob);
		   jump ->
		       case element(2, element(2, Val)) - element(1, Glob) + 1
			      > length(LabelToNode)
			      orelse
			      lists:nth(element(2, element(2, Val)) -
					  element(1, Glob)
					  + 1,
					LabelToNode)
				=:= 0
			   of
			 true ->
			     decompile_step({tl(InstList),
					     insertgraphpath(AST,
							     lists:droplast(CurNodePath)
							       ++
							       [lists:last(CurNodePath)
								  + 1],
							     {graphdata,
							      element(2,
								      element(2,
									      Val)),
							      element(3, Cur),
							      element(4, Cur),
							      element(5, Cur)}),
					     removefromlistoflists(2,
								   addtolistoflists(2,
										    addtolistoflists(length(Pred)
												       +
												       1,
												     Pred,
												     CurNode),
										    length(Pred)
										      +
										      1),
								   CurNode),
					     removefromlistoflists(CurNode,
								   addtolistoflists(length(Pred)
										      +
										      1,
										    addtolistoflists(CurNode,
												     Succ,
												     length(Pred)
												       +
												       1),
										    2),
								   2),
					     insert_renumber(NodesToAST,
							     lists:droplast(CurNodePath)
							       ++
							       [lists:last(CurNodePath)
								  + 1])
					       ++
					       [[lists:droplast(CurNodePath) ++
						   [lists:last(CurNodePath) +
						      1]]],
					     addtolist(element(2,
							       element(2, Val))
							 - element(1, Glob)
							 + 1,
						       LabelToNode,
						       length(Pred) + 1),
					     CurNode, VarPrefix, AssignedVars,
					     true},
					    Glob);
			 _ ->
			     Node = lists:nth(element(2, element(2, Val)) -
						element(1, Glob)
						+ 1,
					      LabelToNode),
			     decompile_step({tl(InstList), AST,
					     removefromlistoflists(2,
								   addtolistoflists(Node,
										    Pred,
										    CurNode),
								   CurNode),
					     removefromlistoflists(CurNode,
								   addtolistoflists(CurNode,
										    Succ,
										    Node),
								   2),
					     NodesToAST, LabelToNode, CurNode,
					     VarPrefix, AssignedVars, true},
					    Glob)
		       end;
		   apply ->
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({AST, NodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))},
							    {call, 0,
							     {atom, 0, apply},
							     [getmemd(Cur,
								      {x,
								       element(2,
									       Val)}),
							      getmemd(Cur,
								      {x,
								       element(2,
									       Val)
									 + 1}),
							      lists:foldr(fun
									    (El,
									     Acc) ->
										{cons,
										 0,
										 getmemd(Cur,
											 {x,
											  El}),
										 Acc}
									  end,
									  {nil,
									   0},
									  lists:seq(0,
										    element(2,
											    Val)
										      -
										      1))]}},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2],
					   setmemd(Cur, {x, 0},
						   {var, 0,
						    list_to_atom(VarPrefix ++
								   "Var" ++
								     integer_to_list(AssignedVars))}),
					   0, CurNode),
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars + 1, false},
				      Glob);
		   apply_last ->
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({AST, NodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars))},
							    {call, 0,
							     {atom, 0, apply},
							     [getmemd(Cur,
								      {x,
								       element(2,
									       Val)}),
							      getmemd(Cur,
								      {x,
								       element(2,
									       Val)
									 + 1}),
							      lists:foldr(fun
									    (El,
									     Acc) ->
										{cons,
										 0,
										 getmemd(Cur,
											 {x,
											  El}),
										 Acc}
									  end,
									  {nil,
									   0},
									  lists:seq(0,
										    element(2,
											    Val)
										      -
										      1))]}},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) + 2],
					   setmemd(Cur, {x, 0},
						   {var, 0,
						    list_to_atom(VarPrefix ++
								   "Var" ++
								     integer_to_list(AssignedVars))}),
					   0, CurNode),
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars + 1, true},
				      Glob);
		   call ->
		       MakeNamedFun = not
					(element(2, element(3, Val)) =:=
					   element(2, Glob)
					   andalso
					   element(3, element(3, Val)) =:=
					     length(element(3,
							    getgraphpath(AST,
									 [1, 5,
									  1]))))
					andalso
					re:run(atom_to_list(element(2,
								    element(3,
									    Val))),
					       ".*-(?:lc|lbc|after)\\$\\^\\d*?/\\d*?-\\d*?-",
					       [unicode, ucp])
					  =/= nomatch,
		       FunNum = case element(2, element(3, Val)) =:=
				       element(2, Glob)
				       andalso
				       element(3, element(3, Val)) =:=
					 length(element(3,
							getgraphpath(AST,
								     [1, 5,
								      1])))
					 andalso
					 re:run(atom_to_list(element(2,
								     element(3,
									     Val))),
						"-.*\\$\\^\\d*?/\\d*?-\\d*?-",
						[unicode, ucp])
					   =/= nomatch
				       orelse MakeNamedFun
				    of
				  true ->
				      string:split(lists:nth(2,
							     string:split(atom_to_list(element(2,
											       element(3,
												       Val))),
									  "/")),
						   "-", all);
				  _ -> []
				end,
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    if
								      MakeNamedFun ->
									  {named_fun,
									   0,
									   "F"
									     ++
									     lists:nth(1,
										       FunNum)
									       ++
									       "_"
										 ++
										 lists:nth(3,
											   FunNum),
									   element(5,
										   dodecompileast(element(3,
													  Glob),
												  element(2,
													  element(3,
														  Val)),
												  element(3,
													  element(3,
														  Val)),
												  "F"
												    ++
												    lists:nth(1,
													      FunNum)
												      ++
												      "_"
													++
													lists:nth(3,
														  FunNum)
													  ++
													  "_"
													    ++
													    VarPrefix,
												  [],
												  element(4,
													  Glob)))};
								      true ->
									  if
									    FunNum
									      =/=
									      [] ->
										{var,
										 0,
										 list_to_atom("F"
												++
												lists:nth(1,
													  FunNum)
												  ++
												  "_"
												    ++
												    lists:nth(3,
													      FunNum))};
									    true ->
										{atom,
										 0,
										 element(2,
											 element(3,
												 Val))}
									  end
								    end,
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(3,
												 element(3,
													 Val))
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       if
										 MakeNamedFun ->
										     {named_fun,
										      0,
										      "F"
											++
											lists:nth(1,
												  FunNum)
											  ++
											  "_"
											    ++
											    lists:nth(3,
												      FunNum),
										      element(5,
											      dodecompileast(element(3,
														     Glob),
													     element(2,
														     element(3,
															     Val)),
													     element(3,
														     element(3,
															     Val)),
													     "F"
													       ++
													       lists:nth(1,
															 FunNum)
														 ++
														 "_"
														   ++
														   lists:nth(3,
															     FunNum)
														     ++
														     "_"
														       ++
														       VarPrefix,
													     [],
													     element(4,
														     Glob)))};
										 true ->
										     if
										       FunNum
											 =/=
											 [] ->
											   {var,
											    0,
											    list_to_atom("F"
													   ++
													   lists:nth(1,
														     FunNum)
													     ++
													     "_"
													       ++
													       lists:nth(3,
															 FunNum))};
										       true ->
											   {atom,
											    0,
											    element(2,
												    element(3,
													    Val))}
										     end
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(3,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       false},
				      Glob);
		   call_only ->
		       MakeNamedFun = not
					(element(2, element(3, Val)) =:=
					   element(2, Glob)
					   andalso
					   element(3, element(3, Val)) =:=
					     length(element(3,
							    getgraphpath(AST,
									 [1, 5,
									  1]))))
					andalso
					re:run(atom_to_list(element(2,
								    element(3,
									    Val))),
					       ".*-(?:lc|lbc|after)\\$\\^\\d*?/\\d*?-\\d*?-",
					       [unicode, ucp])
					  =/= nomatch,
		       FunNum = case element(2, element(3, Val)) =:=
				       element(2, Glob)
				       andalso
				       element(3, element(3, Val)) =:=
					 length(element(3,
							getgraphpath(AST,
								     [1, 5,
								      1])))
					 andalso
					 re:run(atom_to_list(element(2,
								     element(3,
									     Val))),
						"-.*\\$\\^\\d*?/\\d*?-\\d*?-",
						[unicode, ucp])
					   =/= nomatch
				       orelse MakeNamedFun
				    of
				  true ->
				      string:split(lists:nth(2,
							     string:split(atom_to_list(element(2,
											       element(3,
												       Val))),
									  "/")),
						   "-", all);
				  _ -> []
				end,
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    if
								      MakeNamedFun ->
									  {named_fun,
									   0,
									   "F"
									     ++
									     lists:nth(1,
										       FunNum)
									       ++
									       "_"
										 ++
										 lists:nth(3,
											   FunNum),
									   element(5,
										   dodecompileast(element(3,
													  Glob),
												  element(2,
													  element(3,
														  Val)),
												  element(3,
													  element(3,
														  Val)),
												  "F"
												    ++
												    lists:nth(1,
													      FunNum)
												      ++
												      "_"
													++
													lists:nth(3,
														  FunNum)
													  ++
													  "_"
													    ++
													    VarPrefix,
												  [],
												  element(4,
													  Glob)))};
								      true ->
									  if
									    FunNum
									      =/=
									      [] ->
										{var,
										 0,
										 list_to_atom("F"
												++
												lists:nth(1,
													  FunNum)
												  ++
												  "_"
												    ++
												    lists:nth(3,
													      FunNum))};
									    true ->
										{atom,
										 0,
										 element(2,
											 element(3,
												 Val))}
									  end
								    end,
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(3,
												 element(3,
													 Val))
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       if
										 MakeNamedFun ->
										     {named_fun,
										      0,
										      "F"
											++
											lists:nth(1,
												  FunNum)
											  ++
											  "_"
											    ++
											    lists:nth(3,
												      FunNum),
										      element(5,
											      dodecompileast(element(3,
														     Glob),
													     element(2,
														     element(3,
															     Val)),
													     element(3,
														     element(3,
															     Val)),
													     "F"
													       ++
													       lists:nth(1,
															 FunNum)
														 ++
														 "_"
														   ++
														   lists:nth(3,
															     FunNum)
														     ++
														     "_"
														       ++
														       VarPrefix,
													     [],
													     element(4,
														     Glob)))};
										 true ->
										     if
										       FunNum
											 =/=
											 [] ->
											   {var,
											    0,
											    list_to_atom("F"
													   ++
													   lists:nth(1,
														     FunNum)
													     ++
													     "_"
													       ++
													       lists:nth(3,
															 FunNum))};
										       true ->
											   {atom,
											    0,
											    element(2,
												    element(3,
													    Val))}
										     end
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(3,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       true},
				      Glob);
		   call_last ->
		       MakeNamedFun = not
					(element(2, element(3, Val)) =:=
					   element(2, Glob)
					   andalso
					   element(3, element(3, Val)) =:=
					     length(element(3,
							    getgraphpath(AST,
									 [1, 5,
									  1]))))
					andalso
					re:run(atom_to_list(element(2,
								    element(3,
									    Val))),
					       ".*-(?:lc|lbc|after)\\$\\^\\d*?/\\d*?-\\d*?-",
					       [unicode, ucp])
					  =/= nomatch,
		       FunNum = case element(2, element(3, Val)) =:=
				       element(2, Glob)
				       andalso
				       element(3, element(3, Val)) =:=
					 length(element(3,
							getgraphpath(AST,
								     [1, 5,
								      1])))
					 andalso
					 re:run(atom_to_list(element(2,
								     element(3,
									     Val))),
						"-.*\\$\\^\\d*?/\\d*?-\\d*?-",
						[unicode, ucp])
					   =/= nomatch
				       orelse MakeNamedFun
				    of
				  true ->
				      string:split(lists:nth(2,
							     string:split(atom_to_list(element(2,
											       element(3,
												       Val))),
									  "/")),
						   "-", all);
				  _ -> []
				end,
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    if
								      MakeNamedFun ->
									  {named_fun,
									   0,
									   "F"
									     ++
									     lists:nth(1,
										       FunNum)
									       ++
									       "_"
										 ++
										 lists:nth(3,
											   FunNum),
									   element(5,
										   dodecompileast(element(3,
													  Glob),
												  element(2,
													  element(3,
														  Val)),
												  element(3,
													  element(3,
														  Val)),
												  "F"
												    ++
												    lists:nth(1,
													      FunNum)
												      ++
												      "_"
													++
													lists:nth(3,
														  FunNum)
													  ++
													  "_"
													    ++
													    VarPrefix,
												  [],
												  element(4,
													  Glob)))};
								      true ->
									  if
									    FunNum
									      =/=
									      [] ->
										{var,
										 0,
										 list_to_atom("F"
												++
												lists:nth(1,
													  FunNum)
												  ++
												  "_"
												    ++
												    lists:nth(3,
													      FunNum))};
									    true ->
										{atom,
										 0,
										 element(2,
											 element(3,
												 Val))}
									  end
								    end,
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(3,
												 element(3,
													 Val))
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       if
										 MakeNamedFun ->
										     {named_fun,
										      0,
										      "F"
											++
											lists:nth(1,
												  FunNum)
											  ++
											  "_"
											    ++
											    lists:nth(3,
												      FunNum),
										      element(5,
											      dodecompileast(element(3,
														     Glob),
													     element(2,
														     element(3,
															     Val)),
													     element(3,
														     element(3,
															     Val)),
													     "F"
													       ++
													       lists:nth(1,
															 FunNum)
														 ++
														 "_"
														   ++
														   lists:nth(3,
															     FunNum)
														     ++
														     "_"
														       ++
														       VarPrefix,
													     [],
													     element(4,
														     Glob)))};
										 true ->
										     if
										       FunNum
											 =/=
											 [] ->
											   {var,
											    0,
											    list_to_atom("F"
													   ++
													   lists:nth(1,
														     FunNum)
													     ++
													     "_"
													       ++
													       lists:nth(3,
															 FunNum))};
										       true ->
											   {atom,
											    0,
											    element(2,
												    element(3,
													    Val))}
										     end
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(3,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       true},
				      Glob);
		   call_ext ->
		       IsExit = erl_bifs:is_exit_bif(element(2,
							     element(3, Val)),
						     element(3,
							     element(3, Val)),
						     element(4,
							     element(3, Val))),
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val)),
					       element(4, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  if IsExit ->
									 {call,
									  0,
									  case
									    element(2,
										    element(3,
											    Val))
									      =:=
									      erlang
									      andalso
									      erl_internal:bif(element(3,
												       element(3,
													       Val)),
											       element(4,
												       element(3,
													       Val)))
									      of
									    true ->
										{atom,
										 0,
										 element(3,
											 element(3,
												 Val))};
									    _ ->
										{remote,
										 0,
										 {atom,
										  0,
										  element(2,
											  element(3,
												  Val))},
										 {atom,
										  0,
										  element(3,
											  element(3,
												  Val))}}
									  end,
									  [getmemd(Cur,
										   {x,
										    X})
									   || X
										  <- lists:seq(0,
											       element(4,
												       element(3,
													       Val))
												 -
												 1)]};
								     true ->
									 {match,
									  0,
									  {var,
									   0,
									   list_to_atom(VarPrefix
											  ++
											  "Var"
											    ++
											    integer_to_list(AssignedVars))},
									  {call,
									   0,
									   case
									     element(2,
										     element(3,
											     Val))
									       =:=
									       erlang
									       andalso
									       erl_internal:bif(element(3,
													element(3,
														Val)),
												element(4,
													element(3,
														Val)))
									       of
									     true ->
										 {atom,
										  0,
										  element(3,
											  element(3,
												  Val))};
									     _ ->
										 {remote,
										  0,
										  {atom,
										   0,
										   element(2,
											   element(3,
												   Val))},
										  {atom,
										   0,
										   element(3,
											   element(3,
												   Val))}}
									   end,
									   [getmemd(Cur,
										    {x,
										     X})
									    || X
										   <- lists:seq(0,
												element(4,
													element(3,
														Val))
												  -
												  1)]}}
								  end,
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  if IsExit -> Cur;
						     true ->
							 setmemd(Cur, {x, 0},
								 {var, 0,
								  list_to_atom(VarPrefix
										 ++
										 "Var"
										   ++
										   integer_to_list(AssignedVars))})
						  end,
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       case
										 element(2,
											 element(3,
												 Val))
										   =:=
										   erlang
										   andalso
										   erl_internal:bif(element(3,
													    element(3,
														    Val)),
												    element(4,
													    element(3,
														    Val)))
										   of
										 true ->
										     {atom,
										      0,
										      element(3,
											      element(3,
												      Val))};
										 _ ->
										     {remote,
										      0,
										      {atom,
										       0,
										       element(2,
											       element(3,
												       Val))},
										      {atom,
										       0,
										       element(3,
											       element(3,
												       Val))}}
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(4,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST,
				       if IsExit ->
					      removefromlistoflists(2,
								    addtolistoflists(3,
										     Pred,
										     CurNode),
								    CurNode);
					  true -> Pred
				       end,
				       if IsExit ->
					      removefromlistoflists(CurNode,
								    addtolistoflists(CurNode,
										     Succ,
										     3),
								    2);
					  true -> Succ
				       end,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if not IsExit andalso SEffect -> 1;
					    true -> 0
					 end,
				       IsExit},
				      Glob);
		   call_ext_only ->
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val)),
					       element(4, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    case
								      element(2,
									      element(3,
										      Val))
									=:=
									erlang
									andalso
									erl_internal:bif(element(3,
												 element(3,
													 Val)),
											 element(4,
												 element(3,
													 Val)))
									of
								      true ->
									  {atom,
									   0,
									   element(3,
										   element(3,
											   Val))};
								      _ ->
									  {remote,
									   0,
									   {atom,
									    0,
									    element(2,
										    element(3,
											    Val))},
									   {atom,
									    0,
									    element(3,
										    element(3,
											    Val))}}
								    end,
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(4,
												 element(3,
													 Val))
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       case
										 element(2,
											 element(3,
												 Val))
										   =:=
										   erlang
										   andalso
										   erl_internal:bif(element(3,
													    element(3,
														    Val)),
												    element(4,
													    element(3,
														    Val)))
										   of
										 true ->
										     {atom,
										      0,
										      element(3,
											      element(3,
												      Val))};
										 _ ->
										     {remote,
										      0,
										      {atom,
										       0,
										       element(2,
											       element(3,
												       Val))},
										      {atom,
										       0,
										       element(3,
											       element(3,
												       Val))}}
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(4,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       true},
				      Glob);
		   call_ext_last ->
		       SEffect = hassideeffect(element(2, element(3, Val)),
					       element(3, element(3, Val)),
					       element(4, element(3, Val))),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    case
								      element(2,
									      element(3,
										      Val))
									=:=
									erlang
									andalso
									erl_internal:bif(element(3,
												 element(3,
													 Val)),
											 element(4,
												 element(3,
													 Val)))
									of
								      true ->
									  {atom,
									   0,
									   element(3,
										   element(3,
											   Val))};
								      _ ->
									  {remote,
									   0,
									   {atom,
									    0,
									    element(2,
										    element(3,
											    Val))},
									   {atom,
									    0,
									    element(3,
										    element(3,
											    Val))}}
								    end,
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(4,
												 element(3,
													 Val))
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       case
										 element(2,
											 element(3,
												 Val))
										   =:=
										   erlang
										   andalso
										   erl_internal:bif(element(3,
													    element(3,
														    Val)),
												    element(4,
													    element(3,
														    Val)))
										   of
										 true ->
										     {atom,
										      0,
										      element(3,
											      element(3,
												      Val))};
										 _ ->
										     {remote,
										      0,
										      {atom,
										       0,
										       element(2,
											       element(3,
												       Val))},
										      {atom,
										       0,
										       element(3,
											       element(3,
												       Val))}}
									       end,
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(4,
													    element(3,
														    Val))
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       true},
				      Glob);
		   call_fun ->
		       SEffect = hassideeffect(getmemd(Cur,
						       {x, element(2, Val)}),
					       element(2, Val)),
		       if SEffect ->
			      {ModAST, ModNodesToAST} =
				  insertgraphnode(insertgraphnode({AST,
								   NodesToAST},
								  lists:droplast(CurNodePath)
								    ++
								    [lists:last(CurNodePath)
								       + 1],
								  {match, 0,
								   {var, 0,
								    list_to_atom(VarPrefix
										   ++
										   "Var"
										     ++
										     integer_to_list(AssignedVars))},
								   {call, 0,
								    getmemd(Cur,
									    {x,
									     element(2,
										     Val)}),
								    [getmemd(Cur,
									     {x,
									      X})
								     || X
									    <- lists:seq(0,
											 element(2,
												 Val)
											   -
											   1)]}},
								  0, 0),
						  lists:droplast(CurNodePath) ++
						    [lists:last(CurNodePath) +
						       2],
						  setmemd(Cur, {x, 0},
							  {var, 0,
							   list_to_atom(VarPrefix
									  ++
									  "Var"
									    ++
									    integer_to_list(AssignedVars))}),
						  0, CurNode);
			  true ->
			      {ModAST, ModNodesToAST} = {setgraphpath(AST,
								      CurNodePath,
								      setmemd(Cur,
									      {x,
									       0},
									      {call,
									       0,
									       getmemd(Cur,
										       {x,
											element(2,
												Val)}),
									       [getmemd(Cur,
											{x,
											 X})
										|| X
										       <- lists:seq(0,
												    element(2,
													    Val)
												      -
												      1)]})),
							 NodesToAST}
		       end,
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix,
				       AssignedVars +
					 if SEffect -> 1;
					    true -> 0
					 end,
				       false},
				      Glob);
		   make_fun2 ->
		       FunNum = string:split(lists:nth(2,
						       string:split(atom_to_list(element(2,
											 element(2,
												 Val))),
								    "/")),
					     "-", all),
		       {CapAST, CapNodesToAST, CapAssign, NewCur} =
			   lists:foldl(fun (Elem, Acc) ->
					       El = getmemd(Cur, {x, Elem}),
					       case El of
						 {var, _, _} -> Acc;
						 _ ->
						     C = setmemd(element(4,
									 Acc),
								 {x, Elem},
								 {var, 0,
								  list_to_atom(VarPrefix
										 ++
										 "Var"
										   ++
										   integer_to_list(AssignedVars
												     +
												     element(3,
													     Acc)))}),
						     {A, B} =
							 insertgraphnode(insertgraphnode({element(1,
												  Acc),
											  element(2,
												  Acc)},
											 lists:droplast(CurNodePath)
											   ++
											   [lists:last(CurNodePath)
											      +
											      element(3,
												      Acc)
												*
												2
											      +
											      1],
											 {match,
											  0,
											  {var,
											   0,
											   list_to_atom(VarPrefix
													  ++
													  "Var"
													    ++
													    integer_to_list(AssignedVars
															      +
															      element(3,
																      Acc)))},
											  El},
											 0,
											 0),
									 lists:droplast(CurNodePath)
									   ++
									   [lists:last(CurNodePath)
									      +
									      element(3,
										      Acc)
										*
										2
									      +
									      2],
									 C, 0,
									 CurNode),
						     {A, B, element(3, Acc) + 1,
						      C}
					       end
				       end,
				       {AST, NodesToAST, 0, Cur},
				       lists:seq(0, element(5, Val) - 1)),
		       {ModAST, ModNodesToAST} =
			   insertgraphnode(insertgraphnode({CapAST,
							    CapNodesToAST},
							   lists:droplast(CurNodePath)
							     ++
							     [lists:last(CurNodePath)
								+ CapAssign * 2
								+ 1],
							   {match, 0,
							    {var, 0,
							     list_to_atom(VarPrefix
									    ++
									    "Var"
									      ++
									      integer_to_list(AssignedVars
												+
												CapAssign))},
							    {'fun', 0,
							     {clauses,
							      element(5,
								      dodecompileast(if
										       element(2,
											       element(3,
												       Glob))
											 =:=
											 element(1,
												 element(2,
													 Val)) ->
											   element(3,
												   Glob);
										       true ->
											   atom_to_list(element(1,
														element(2,
															Val)))
										     end,
										     element(2,
											     element(2,
												     Val)),
										     element(3,
											     element(2,
												     Val)),
										     "F"
										       ++
										       lists:nth(1,
												 FunNum)
											 ++
											 "_"
											   ++
											   lists:nth(3,
												     FunNum)
											     ++
											     "_"
											       ++
											       VarPrefix,
										     lists:sublist(element(3,
													   NewCur),
												   1,
												   element(5,
													   Val)),
										     element(4,
											     Glob)))}}},
							   0, 0),
					   lists:droplast(CurNodePath) ++
					     [lists:last(CurNodePath) +
						CapAssign * 2
						+ 2],
					   setmemd(NewCur, {x, 0},
						   {var, 0,
						    list_to_atom(VarPrefix ++
								   "Var" ++
								     integer_to_list(AssignedVars
										       +
										       CapAssign))}),
					   0, CurNode),
		       decompile_step({tl(InstList), ModAST, Pred, Succ,
				       ModNodesToAST, LabelToNode, CurNode,
				       VarPrefix, AssignedVars + CapAssign + 1,
				       false},
				      Glob)
		 end
	   end
    end.

change_var_names(AST) ->
    element(1,
	    traverse_ast(fun (Elem, Acc) ->
				 case Elem of
				   {var, _, A} ->
				       case lists:keyfind(A, 1, Acc) of
					 {A, Idx} ->
					     {{var, 0,
					       list_to_atom("Var" ++
							      integer_to_list(Idx))},
					      Acc};
					 false ->
					     {{var, 0,
					       list_to_atom("Var" ++
							      integer_to_list(length(Acc)
										+
										1))},
					      lists:keystore(A, 1, Acc,
							     {A,
							      length(Acc) + 1})}
				       end;
				   _ -> {setelement(2, Elem, 0), Acc}
				 end
			 end,
			 [], AST)).

compare_ast(AST, OrigAST) ->
    FixAST = change_var_names(AST),
    OrigFixAST = change_var_names(OrigAST),
    if FixAST =/= OrigFixAST ->
	   erlang:display(FixAST), erlang:display(OrigFixAST);
       true -> true
    end,
    FixAST =:= OrigFixAST.

check_sem_equiv(AST, BeamFName, Funcname, Arity) ->
    case beam_lib:chunks(BeamFName, [abstract_code]) of
      {ok,
       {_, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
	  Src = tl(Forms),
	  compare_ast(hd(element(5, AST)),
		      hd(element(5,
				 hd(lists:dropwhile(fun (Elem) ->
							    element(1, Elem) =/=
							      function
							      orelse
							      element(3, Elem)
								=/= Funcname
								orelse
								element(4, Elem)
								  =/= Arity
						    end,
						    Src)))))
    end.

is_guard_bif(Name, Arity) ->
    erl_internal:guard_bif(Name, Arity) orelse
      erl_internal:arith_op(Name, Arity) orelse
	erl_internal:bool_op(Name, Arity) orelse
	  erl_internal:comp_op(Name, Arity) orelse
	    erl_internal:new_type_test(Name, Arity) orelse
	      erl_bifs:is_safe(erlang, Name, Arity).

isguardexpr(AST) ->
    element(2,
	    traverse_ast(fun (Elem, Acc) ->
				 {Elem,
				  Acc andalso
				    case Elem of
				      {var, _, _} -> true;
				      {char, _, _} -> true;
				      {integer, _, _} -> true;
				      {float, _, _} -> true;
				      {atom, _, _} -> true;
				      {string, _, _} -> true;
				      {nil, _} -> true;
				      {cons, _, _, _} -> true;
				      {tuple, _, _} -> true;
				      {map, _, _} -> true;
				      {bin, _, _} -> true;
				      {bin_element, _, _, _, _} -> true;
				      {call, _, A, B} ->
					  case A of
					    {atom, _, C} ->
						is_guard_bif(C, length(B));
					    {remote, _, {atom, _, erlang},
					     {atom, _, C}} ->
						is_guard_bif(C, length(B));
					    _ -> false
					  end;
				      {match, _, _, _} -> true;
				      {op, _, A, _} ->
					  A =:= 'not' orelse is_guard_bif(A, 1);
				      {op, _, A, _, _} ->
					  A =:= 'andalso' orelse
					    A =:= 'orelse' orelse
					      is_guard_bif(A, 2);
				      {remote, _, _, _} -> true;
				      _ -> false
				    end}
			 end,
			 true, AST)).

issafesingleuse(AST, Var, Mod) ->
    traverse_ast(fun (Elem, Acc) ->
			 {case Elem of
			    {var, _, Var} -> Mod;
			    _ -> Elem
			  end,
			  case Elem of
			    {var, _, Var} -> {true, element(1, Acc)};
			    {var, _, _} -> Acc;
			    {char, _, _} -> Acc;
			    {integer, _, _} -> Acc;
			    {float, _, _} -> Acc;
			    {atom, _, _} -> Acc;
			    {string, _, _} -> Acc;
			    {nil, _} -> Acc;
			    {cons, _, _, _} -> Acc;
			    {tuple, _, _} -> Acc;
			    {map, _, _} -> Acc;
			    {bin, _, _} -> Acc;
			    {bin_element, _, _, _, _} -> Acc;
			    {call, _, A, B} ->
				case Acc of
				  {true, On} ->
				      {true,
				       case A of
					 {atom, _, C} ->
					     On orelse
					       not is_guard_bif(C, length(B));
					 {remote, _, {atom, _, erlang},
					  {atom, _, C}} ->
					     On orelse
					       not is_guard_bif(C, length(B));
					 _ -> false
				       end};
				  _ -> Acc
				end;
			    {match, _, _, _} -> Acc;
			    {op, _, A, _} ->
				case Acc of
				  {true, On} ->
				      {true,
				       On orelse
					 not
					   (A =:= 'not' orelse
					      is_guard_bif(A, 1))};
				  _ -> Acc
				end;
			    {op, _, A, _, _} ->
				case Acc of
				  {true, On} ->
				      {true,
				       On orelse
					 not
					   (A =:= 'andalso' orelse
					      A =:= 'orelse' orelse
						is_guard_bif(A, 2))};
				  _ -> Acc
				end;
			    {remote, _, _, _} ->
				case Acc of
				  {true, _} -> {true, true};
				  _ -> Acc
				end;
			    _ ->
				case Acc of
				  {true, _} -> {true, true};
				  _ -> Acc
				end
			  end}
		 end,
		 {false, false}, AST).

isbinarypattern(AST) ->
    case AST of
      {op, L, '=:=',
       {op, L, 'rem', {call, L, {atom, L, bit_size}, [B]},
	{integer, L, C}},
       {integer, 0, 0}} ->
	  [{B,
	    {bin, L,
	     [{bin_element, L, {var, L, '_'}, default,
	       [bitstring, {unit, C}]}]}}];
      {op, _, 'andalso', {atom, 0, true}, A} ->
	  isbinarypattern(A);
      {op, L, 'andalso',
       {op, L, '>=', {call, L, {atom, L, bit_size}, [B]},
	{integer, L, C}},
       {op, L, '=:=',
	{call, L,
	 {'fun', L,
	  {clauses, [{call, L, {atom, L, get_bits}, []}]}},
	 [B, {integer, L, C}]},
	D}} ->
	  [{B, D}];
      {op, L, 'andalso',
       {op, L, '>=', {integer, L, C}, {integer, L, 0}},
       {op, L, '>=', {call, L, {atom, L, bit_size}, [B]},
	{op, L, '*', {integer, L, C}, {integer, L, D}}}} ->
	  [{B,
	    {bin, L,
	     [{bin_element, L, {var, L, '_'}, {integer, L, C * D},
	       [bitstring]}]}}];
      {op, _, 'andalso', A, B} ->
	  case isbinarypattern(A) of
	    false -> false;
	    Elems ->
		case isbinarypattern(B) of
		  false -> false;
		  Els ->
		      case hd(Elems) of
			{{block, L,
			  [{match, L, {bin, L, _}, {bin, L, E}}, {var, L, _}]},
			 {bin, L, F}}
			    when length(Elems) =:= 1 ->
			    case hd(Els) of
			      {H, {bin, L, G}} when length(Els) =:= 1 ->
				  [{{bin, L, E}, {bin, L, F ++ G}}];
			      _ ->
				  erlang:display({length(Elems), hd(Elems),
						  length(Els), hd(Els)}),
				  false
			    end;
			{{bin, L, E}, {bin, L, F}} when length(Elems) =:= 1 ->
			    case hd(Els) of
			      {H, {bin, L, G}} when length(Els) =:= 1 ->
				  [{{bin, L, E}, {bin, L, F ++ G}}];
			      _ ->
				  erlang:display({length(Elems), hd(Elems),
						  length(Els), hd(Els)}),
				  false
			    end;
			_ -> erlang:display({length(Elems), hd(Elems)}), false
		      end
		end
	  end;
      _ -> false
    end.

ispatternmatch(AST) ->
    case isbinarypattern(AST) of
      false ->
	  case AST of
	    {op, _, '=:=', A, B} -> [{A, B}];
	    {op, L, 'andalso',
	     {op, L, 'andalso', {call, L, {atom, L, is_tuple}, [A]},
	      {op, L, 'andalso',
	       {op, L, '=:=', {call, L, {atom, L, tuple_size}, [A]},
		{integer, L, C}},
	       {op, L, '=:=',
		{call, L, {atom, L, element}, [{integer, L, D}, A]},
		E}}},
	     B} ->
		case ispatternmatch(B) of
		  false -> false;
		  Elems ->
		      [{A,
			{tuple, L,
			 [case lists:keyfind({call, L, {atom, L, element},
					      [{integer, L, X}, A]},
					     1, Elems)
			      of
			    {_, Pat} -> Pat;
			    _ ->
				if X =:= D -> E;
				   true -> {var, L, '_'}
				end
			  end
			  || X <- lists:seq(1, C)]}}
		       | lists:filter(fun ({Elem, _}) ->
					      case Elem of
						{call, L, {atom, L, element},
						 [{integer, L, _}, A]} ->
						    false;
						_ -> true
					      end
				      end,
				      Elems)]
		end;
	    {op, L, 'andalso', {call, L, {atom, L, is_tuple}, [A]},
	     {op, L, 'andalso',
	      {op, L, '=:=', {call, L, {atom, L, tuple_size}, [A]},
	       {integer, L, C}},
	      B}} ->
		case ispatternmatch(B) of
		  false -> false;
		  Elems ->
		      [{A,
			{tuple, L,
			 [case lists:keyfind({call, L, {atom, L, element},
					      [{integer, L, X}, A]},
					     1, Elems)
			      of
			    {_, Pat} -> Pat;
			    _ -> {var, L, '_'}
			  end
			  || X <- lists:seq(1, C)]}}
		       | lists:filter(fun ({Elem, _}) ->
					      case Elem of
						{call, L, {atom, L, element},
						 [{integer, L, _}, A]} ->
						    false;
						_ -> true
					      end
				      end,
				      Elems)]
		end;
	    {op, L, 'andalso',
	     {op, L, 'andalso', {call, L, {atom, L, is_list}, [A]},
	      {op, L, '=/=', A, {nil, L}}},
	     B} ->
		case ispatternmatch(B) of
		  false -> false;
		  Elems ->
		      [{A,
			{cons, L,
			 case lists:keyfind({call, L, {atom, L, hd}, [A]}, 1,
					    Elems)
			     of
			   {_, Pat} -> Pat;
			   _ -> {var, L, '_'}
			 end,
			 case lists:keyfind({call, L, {atom, L, tl}, [A]}, 1,
					    Elems)
			     of
			   {_, Pat} -> Pat;
			   _ -> {var, L, '_'}
			 end}}
		       | lists:filter(fun ({Elem, _}) ->
					      case Elem of
						{call, L, {atom, L, hd}, [A]} ->
						    false;
						{call, L, {atom, L, tl}, [A]} ->
						    false;
						_ -> true
					      end
				      end,
				      Elems)]
		end;
	    {op, _, 'andalso', A, B} ->
		case ispatternmatch(A) of
		  false -> false;
		  Elems1 ->
		      case ispatternmatch(B) of
			false -> false;
			Elems2 -> Elems1 ++ Elems2
		      end
		end;
	    _ -> erlang:display(AST), false
	  end;
      BinPat ->
	  erlang:display({length(BinPat), tuple_size(hd(BinPat)),
			  BinPat}),
	  BinPat
    end.

cleanup_ast(AST) ->
    BoolAST = [element(1,
		       traverse_ast(fun (Elem, Acc) ->
					    {case Elem of
					       {'case', L, A,
						[{clause, L, [{atom, L, true}],
						  [],
						  [{'case', L, B,
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]}]},
						 {clause, L, [{atom, L, false}],
						  [], D}]} ->
						   {'case', L,
						    {op, L, 'andalso', A, B},
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]};
					       {'case', L, A,
						[{clause, L, [{atom, L, true}],
						  [],
						  [{'case', L, B,
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]}]},
						 {clause, L, [{atom, L, false}],
						  [], C}]} ->
						   {'case', L,
						    {op, L, 'orelse',
						     {op, L, 'not', A}, B},
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]};
					       {'case', L, A,
						[{clause, L, [{atom, L, true}],
						  [],
						  [{'case', L, B,
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]}]},
						 {clause, L, [{atom, L, false}],
						  [],
						  [{'case', L, E,
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]}]}]} ->
						   {'case', L,
						    {op, L, 'orelse',
						     {op, L, 'andalso',
						      {op, L, 'not', A}, E},
						     {op, L, 'andalso', A, B}},
						    [{clause, L,
						      [{atom, L, true}], [], C},
						     {clause, L,
						      [{atom, L, false}], [],
						      D}]};
					       _ -> Elem
					     end,
					     Acc}
				    end,
				    [], hd(AST)))],
    SimpBoolAST = [element(1,
			   traverse_ast(fun (Elem, Acc) ->
						{case Elem of
						   {op, L, 'orelse',
						    {op, L, 'andalso',
						     {op, L, 'not', A}, C},
						    {op, L, 'andalso', A,
						     {op, L, 'orelse', B,
						      C}}} ->
						       {op, L, 'orelse',
							{op, L, 'andalso', A,
							 B},
							C};
						   {op, L, 'orelse',
						    {op, L, 'andalso', A, C},
						    {op, L, 'andalso',
						     {op, L, 'not', A},
						     {op, L, 'orelse', B,
						      C}}} ->
						       {op, L, 'orelse',
							{op, L, 'andalso', A,
							 B},
							C};
						   {op, L, 'orelse',
						    {op, L, 'andalso',
						     {op, L, 'not', A}, C},
						    {op, L, 'andalso', A,
						     {op, L, 'andalso', B,
						      C}}} ->
						       {op, L, 'andalso',
							{op, L, 'orelse', A, B},
							C};
						   {op, L, 'orelse',
						    {op, L, 'andalso', A, C},
						    {op, L, 'andalso',
						     {op, L, 'not', A},
						     {op, L, 'andalso', B,
						      C}}} ->
						       {op, L, 'andalso',
							{op, L, 'orelse', A, B},
							C};
						   {op, L, 'not',
						    {op, L, 'not', A}} ->
						       A;
						   {op, L, 'not',
						    {op, L, '=/=', A, B}} ->
						       {op, L, '=:=', A, B};
						   {op, L, 'not',
						    {op, L, '=:=', A, B}} ->
						       {op, L, '=/=', A, B};
						   {op, L, 'not',
						    {op, L, '/=', A, B}} ->
						       {op, L, '==', A, B};
						   {op, L, 'not',
						    {op, L, '==', A, B}} ->
						       {op, L, '/=', A, B};
						   {op, L, 'not',
						    {op, L, '<', A, B}} ->
						       {op, L, '>=', A, B};
						   {op, L, 'not',
						    {op, L, '=<', A, B}} ->
						       {op, L, '>', A, B};
						   {op, L, 'not',
						    {op, L, '>=', A, B}} ->
						       {op, L, '<', A, B};
						   {op, L, 'not',
						    {op, L, '>', A, B}} ->
						       {op, L, '<=', A, B};
						   {op, L, '=:=', A,
						    {atom, L, true}} ->
						       A;
						   {op, L, '=/=', A,
						    {atom, L, true}} ->
						       {op, L, 'not', A};
						   {call, L,
						    {'fun', L,
						     {clauses,
						      [{call, L,
							{atom, L, skip_bits},
							[]}]}},
						    [{bin, L, B},
						     {integer, L, C}]} ->
						       {block, L,
							[{match, L,
							  {bin, L,
							   [{bin_element, L,
							     {var, L, '_'},
							     {integer, L, C},
							     [bitstring]},
							    {bin_element, L,
							     {var, L, 'Var'},
							     default,
							     [bitstring]}]},
							  {bin, L, B}},
							 {var, L, 'Var'}]};
						   {call, L,
						    {'fun', L,
						     {clauses,
						      [{call, L,
							{atom, L, skip_bits},
							[]}]}},
						    [{block, L,
						      [{match, L, {bin, L, E},
							{bin, L, B}},
						       {var, L, D}]},
						     {op, L, '*',
						      {integer, L, C},
						      {integer, L, F}}]} ->
						       case lists:all(fun (A) ->
									      case
										A
										  of
										{bin_element,
										 L,
										 {var,
										  L,
										  '_'},
										 {integer,
										  L,
										  _},
										 [bitstring]} ->
										    true;
										_ ->
										    false
									      end
								      end,
								      lists:droplast(E))
							   of
							 true ->
							     case lists:last(E)
								 of
							       {bin_element, L,
								{var, L, D},
								default,
								[bitstring]} ->
								   {block, L,
								    [{match, L,
								      {bin, L,
								       lists:droplast(E)
									 ++
									 [{bin_element,
									   L,
									   {var,
									    L,
									    '_'},
									   {integer,
									    L,
									    C *
									      F},
									   [bitstring]},
									  lists:last(E)]},
								      {bin, L,
								       B}},
								     {var, L,
								      'Var'}]};
							       _ -> Elem
							     end;
							 _ -> Elem
						       end;
						   {call, L,
						    {'fun', L,
						     {clauses,
						      [{call, L,
							{atom, L, skip_bits},
							[]}]}},
						    [{block, L,
						      [{match, L, {bin, L, E},
							{bin, L, B}},
						       {var, L, D}]},
						     {integer, L, C}]} ->
						       case lists:all(fun (A) ->
									      case
										A
										  of
										{bin_element,
										 L,
										 {var,
										  L,
										  '_'},
										 {integer,
										  L,
										  _},
										 [bitstring]} ->
										    true;
										_ ->
										    false
									      end
								      end,
								      lists:droplast(E))
							   of
							 true ->
							     case lists:last(E)
								 of
							       {bin_element, L,
								{var, L, D},
								default,
								[bitstring]} ->
								   {block, L,
								    [{match, L,
								      {bin, L,
								       lists:droplast(E)
									 ++
									 [{bin_element,
									   L,
									   {var,
									    L,
									    '_'},
									   {integer,
									    L,
									    C},
									   [bitstring]},
									  lists:last(E)]},
								      {bin, L,
								       B}},
								     {var, L,
								      'Var'}]};
							       _ -> Elem
							     end;
							 _ -> Elem
						       end;
						   _ -> Elem
						 end,
						 Acc}
					end,
					[], hd(BoolAST)))],
    CaseRetAST = [element(1,
			  traverse_ast(fun (Elem, Acc) ->
					       {case Elem of
						  {'case', L, A,
						   [{clause, L,
						     [{atom, L, true}], [], B},
						    {clause, L,
						     [{atom, L, false}], [],
						     C}]} ->
						      case {if length(B) =/=
								 0 ->
								   lists:last(B);
							       true -> {}
							    end,
							    if length(C) =/=
								 0 ->
								   lists:last(C);
							       true -> {}
							    end}
							  of
							{{match, L, {var, L, X},
							  D},
							 {match, L, {var, L, X},
							  E}} ->
							    {match, L,
							     {var, L, X},
							     {'case', L, A,
							      [{clause, L,
								[{atom, L,
								  true}],
								[],
								lists:droplast(B)
								  ++ [D]},
							       {clause, L,
								[{atom, L,
								  false}],
								[],
								lists:droplast(C)
								  ++ [E]}]}};
							{{match, L, {var, L, X},
							  D},
							 {call, L,
							  {remote, L,
							   {atom, L, erlang},
							   {atom, L, error}},
							  _}} ->
							    {match, L,
							     {var, L, X},
							     {'case', L, A,
							      [{clause, L,
								[{atom, L,
								  true}],
								[],
								lists:droplast(B)
								  ++ [D]},
							       {clause, L,
								[{atom, L,
								  false}],
								[], C}]}};
							_ -> Elem
						      end;
						  _ -> Elem
						end,
						Acc}
				       end,
				       [], hd(SimpBoolAST)))],
    IfCaseAST = [element(1,
			 traverse_ast(fun (Elem, Acc) ->
					      {case Elem of
						 {'case', L, A,
						  [{clause, L,
						    [{atom, L, true}], [], B},
						   {clause, L,
						    [{atom, L, false}], [],
						    [{call, L,
						      {remote, L,
						       {atom, L, erlang},
						       {atom, L, error}},
						      [{atom, L,
							if_clause}]}]}]} ->
						     case isguardexpr(A) of
						       true ->
							   {'if', L,
							    [{clause, L, [],
							      [[A]], B}]};
						       _ -> Elem
						     end;
						 {'case', L, A,
						  [{clause, L,
						    [{atom, L, true}], [], B},
						   {clause, L,
						    [{atom, L, false}], [],
						    [{call, L,
						      {remote, L,
						       {atom, L, erlang},
						       {atom, L, error}},
						      [{atom, L,
							case_clause}]}]}]} ->
						     {'case', L, A,
						      [{clause, L,
							[{atom, L, true}], [],
							B}]};
						 {'case', L, A,
						  [{clause, L,
						    [{atom, L, true}], [], B},
						   {clause, L,
						    [{atom, L, false}], [],
						    [{call, L,
						      {remote, L,
						       {atom, L, erlang},
						       {atom, L, error}},
						      [{tuple, L,
							[{atom, L, badmatch},
							 C]}]}]}]} ->
						     case ispatternmatch(A) of
						       [{E, D}] ->
							   erlang:display({C, D,
									   E}),
							   if C =:= E ->
								  {block, L,
								   [{match, L,
								     D, E}
								    | B]};
							      true -> Elem
							   end;
						       _ -> Elem
						     end;
						 {'case', L, A,
						  [{clause, L,
						    [{atom, L, true}], [], B},
						   {clause, L,
						    [{atom, L, false}], [],
						    C}]} ->
						     case ispatternmatch(A) of
						       [{E, D}] ->
							   {'case', L, E,
							    [{clause, L, [D],
							      [], B},
							     {clause, L,
							      [{var, L, '_'}],
							      [], C}]};
						       _ ->
							   case isguardexpr(A)
							       of
							     true ->
								 {'if', L,
								  [{clause, L,
								    [], [[A]],
								    B},
								   {clause, L,
								    [],
								    [[{atom, L,
								       true}]],
								    C}]};
							     _ -> Elem
							   end
						     end;
						 _ -> Elem
					       end,
					       Acc}
				      end,
				      [], hd(CaseRetAST)))],
    [element(1,
	     traverse_ast(fun (Elem, Acc) ->
				  {case Elem of
				     {clause, L, A, B, C} ->
					 if length(C) >= 2 ->
						case lists:nthtail(length(C) -
								     2,
								   C)
						    of
						  [{match, L, {var, L, X}, D},
						   {var, L, X}] ->
						      {clause, L, A, B,
						       lists:droplast(lists:droplast(C))
							 ++ [D]};
						  [{match, L, {var, L, X}, D},
						   Y] ->
						      case issafesingleuse(Y, X,
									   D)
							  of
							{Mod, {true, false}} ->
							    {clause, L, A, B,
							     lists:droplast(lists:droplast(C))
							       ++ [Mod]};
							_ -> Elem
						      end;
						  [{'if', L,
						    [{clause, L, [], [D], []}]},
						   {var, L, X}] ->
						      {clause, L, A, B,
						       lists:droplast(lists:droplast(C))
							 ++
							 [{'if', L,
							   [{clause, L, [], [D],
							     [{var, L, X}]}]}]};
						  _ -> Elem
						end;
					    true -> Elem
					 end;
				     _ -> Elem
				   end,
				   Acc}
			  end,
			  [], hd(IfCaseAST)))].

resolve_graph_data({AST, []}) -> AST;
resolve_graph_data({AST, NodesToAST}) ->
    resolve_graph_data({if hd(NodesToAST) =:= [[]] -> AST;
			   true ->
			       lists:foldr(fun (Elem, Acc) ->
						   removegraphpath(Acc, Elem)
					   end,
					   AST, hd(NodesToAST))
			end,
			tl(NodesToAST)}).

fix_graph_tuples(AST) ->
    lists:map(fun (Elem) ->
		      if is_tuple(Elem) ->
			     Tuple = list_to_tuple(lists:map(fun (El) ->
								     if
								       is_list(El) ->
									   fix_graph_tuples(El);
								       true ->
									   El
								     end
							     end,
							     tuple_to_list(Elem))),
			     case Tuple of
			       {match, L, {var, L, A}, [{'catch', L, [B]}]} ->
				   {match, L, {var, L, A}, {'catch', L, B}};
			       {match, L, {var, L, A}, [{'catch', L, B}]} ->
				   {match, L, {var, L, A},
				    {'catch', L, {block, L, B}}};
			       {match, L, {var, L, A},
				[{call, L, {'fun', L, {clauses, B}}, C}]} ->
				   {match, L, {var, L, A},
				    {call, L, {'fun', L, {clauses, B}}, C}};
			       {match, L, {var, L, A},
				[{'try', L, B, C, D, E}]} ->
				   {match, L, {var, L, A},
				    {'try', L, B, C, D, E}};
			       {'fun', L, [{clauses, X}]} ->
				   {'fun', L, {clauses, X}};
			       _ -> Tuple
			     end;
			 true -> Elem
		      end
	      end,
	      AST).

dodecompileast(Func, VarPrefix, Capts, Beam,
	       CleanAST) ->
    State = {lists:dropwhile(fun (Elem) ->
				     is_atom(Elem) orelse
				       element(1, Elem) =/= label orelse
					 element(2, Elem) =/= element(4, Func)
			     end,
			     element(5, Func)),
	     [{function, 0, element(2, Func), 2,
	       [{clause, 0,
		 [{var, 0,
		   list_to_atom(VarPrefix ++ "Arg" ++ integer_to_list(X))}
		  || X <- lists:seq(1, element(3, Func) - length(Capts))],
		 [],
		 [{graphdata, element(4, Func),
		   [{var, 0,
		     list_to_atom(VarPrefix ++ "Arg" ++ integer_to_list(X))}
		    || X <- lists:seq(1, element(3, Func) - length(Capts))]
		     ++
		     Capts ++ lists:duplicate(1024 - element(3, Func), []),
		   [], lists:duplicate(16, [])},
		  {graphdata, 0, [[] || _ <- lists:seq(1, 1024)], [],
		   [[] || _ <- lists:seq(1, 16)]},
		  {unresolved, {x, 0}}]}]}],
	     [[], [1], [2]], [[2], [3], []],
	     [[[1, 5, 1, 5, 1]], [[1, 5, 1, 5, 2]], [[]]], [1], 1,
	     VarPrefix, 1, true},
    DecState = decompile_step(State,
			      {element(4, Func), element(2, Func), Beam,
			       CleanAST}),
    ResData =
	fix_graph_tuples(resolve_graph_data({element(2,
						     DecState),
					     lists:reverse(lists:sort(element(5,
									      DecState)))})).

dodecompileast(Func, Beam, CleanAST) ->
    dodecompileast(Func, "", [], Beam, CleanAST).

dodecompileast(Filename, Funcname, Arity, VarPrefix,
	       Capts, CleanAST) ->
    File = if is_list(Filename) ->
		  beam_disasm:file(Filename);
	      true -> Filename
	   end,
    Func = hd(lists:dropwhile(fun (Elem) ->
				      element(2, Elem) =/= Funcname orelse
					element(3, Elem) =/= Arity
			      end,
			      element(6, File))),
    hd(dodecompileast(Func, VarPrefix, Capts, File,
		      CleanAST)).

decompileast(Filename, Funcname, Arity, ErlFName) ->
    {ok, Fd} = file:open(ErlFName, [write]),
    io:fwrite(Fd, "~p~n",
	      [decompileast(Filename, Funcname, Arity)]),
    file:close(Fd).

decompileast(Filename, Funcname, Arity) ->
    [{attribute, 0, module, list_to_atom(Filename)},
     {attribute, 0, export, [{Funcname, Arity}]},
     dodecompileast(Filename, Funcname, Arity, "", [],
		    get_ast_self()),
     {eof, 0}].

check_decompileast(Filename, Funcname, Arity) ->
    check_sem_equiv(lists:nth(3,
			      decompileast(Filename, Funcname, Arity)),
		    Filename, Funcname, Arity).

decompile(Filename, Funcname, Arity, ErlFName) ->
    ResState = [{attribute, 0, module,
		 list_to_atom(Filename)},
		{attribute, 0, export, [{Funcname, Arity}]},
		dodecompileast(Filename, Funcname, Arity, "", [],
			       get_ast_self()),
		{eof, 0}],
    {ok, Fd} = file:open(ErlFName, [write]),
    io:fwrite(Fd, "~s~n",
	      [erl_prettypr:format(erl_syntax:form_list(ResState))]),
    file:close(Fd).

decompileast(Filename, ErlFName) ->
    File = beam_disasm:file(Filename),
    LoadFunc = lists:dropwhile(fun (Func) ->
				       not
					 lists:any(fun (Elem) ->
							   Elem =:= on_load
						   end,
						   element(5, Func))
			       end,
			       element(6, File)),
    ResState = [{attribute, 0, module,
		 list_to_atom(Filename)},
		{attribute, 0, export,
		 lists:filtermap(fun ({A, B, _}) ->
					 if A =:= module_info -> false;
					    true -> {true, {A, B}}
					 end
				 end,
				 element(3, File))}]
		 ++
		 if LoadFunc =:= [] -> [];
		    true ->
			[{attribute, 0, on_load,
			  {element(2, hd(LoadFunc)), element(3, hd(LoadFunc))}}]
		 end
		   ++
		   lists:filtermap(fun (Func) ->
					   case element(2, Func) =:= module_info
						  orelse
						  lists:any(fun (Elem) ->
								    Elem =:= 45
								      orelse
								      Elem =:=
									47
							    end,
							    atom_to_list(element(2,
										 Func)))
					       of
					     true -> false;
					     _ ->
						 {true,
						  catch hd(dodecompileast(Func,
									  File,
									  get_ast_self()))}
					   end
				   end,
				   element(6, File))
		     ++ [{eof, 0}],
    {ok, Fd} = file:open(ErlFName, [write]),
    io:fwrite(Fd, "~p~n", [ResState]),
    file:close(Fd).

decompile(Filename, ErlFName) ->
    File = beam_disasm:file(Filename),
    LoadFunc = lists:dropwhile(fun (Func) ->
				       not
					 lists:any(fun (Elem) ->
							   Elem =:= on_load
						   end,
						   element(5, Func))
			       end,
			       element(6, File)),
    ResState = [{attribute, 0, module,
		 list_to_atom(Filename)},
		{attribute, 0, export,
		 lists:filtermap(fun ({A, B, _}) ->
					 if A =:= module_info -> false;
					    true -> {true, {A, B}}
					 end
				 end,
				 element(3, File))}]
		 ++
		 if LoadFunc =:= [] -> [];
		    true ->
			[{attribute, 0, on_load,
			  {element(2, hd(LoadFunc)), element(3, hd(LoadFunc))}}]
		 end
		   ++
		   lists:filtermap(fun (Func) ->
					   case element(2, Func) =:= module_info
						  orelse
						  lists:any(fun (Elem) ->
								    Elem =:= 45
								      orelse
								      Elem =:=
									47
							    end,
							    atom_to_list(element(2,
										 Func)))
					       of
					     true -> false;
					     _ ->
						 {true,
						  catch hd(dodecompileast(Func,
									  File,
									  get_ast_self()))}
					   end
				   end,
				   element(6, File))
		     ++ [{eof, 0}],
    {ok, Fd} = file:open(ErlFName, [write]),
    io:fwrite(Fd, "~s~n",
	      [erl_prettypr:format(erl_syntax:form_list(ResState))]),
    file:close(Fd).

'receive'(Fr) ->
    {ok, recv_eval, CplBin} = compile:forms({recv_eval,
					     [{'receive', 1}, {module_info, 0},
					      {module_info, 1}],
					     [],
					     [{function, 'receive', 1, 2,
					       [{label, 1},
						{func_info, {atom, recv_eval},
						 {atom, 'receive'}, 1},
						{label, 2},
						{allocate_zero, 2, 1},
						{move, {x, 0}, {y, 1}},
						{make_fun2, {f, 15}, 0, 0, 0},
						{move, {x, 0}, {y, 0}},
						{call, 0, {f, 7}}, {label, 3},
						{loop_rec, {f, 5}, {x, 0}},
						{move, {y, 0}, {x, 1}},
						{move, {y, 1}, {x, 2}},
						{call_fun, 2},
						{test, is_tagged_tuple, {f, 4},
						 [{x, 0}, 2, {atom, true}]},
						{get_tuple_element, {x, 0}, 1,
						 {x, 0}},
						{deallocate, 2}, return,
						{label, 4},
						{loop_rec_end, {f, 3}},
						{label, 5}, {wait, {f, 3}}]},
					      {function, arg_reg_alloc, 0, 7,
					       [{label, 6},
						{func_info, {atom, recv_eval},
						 {atom, arg_reg_alloc}, 0},
						{label, 7}, {allocate, 0, 0},
						{move, {integer, 134217727},
						 {x, 0}},
						{call_ext, 1,
						 {extfunc, erlang,
						  bump_reductions, 1}},
						{move, {atom, true}, {x, 3}},
						{move, {atom, true}, {x, 4}},
						{move, {atom, true}, {x, 2}},
						{move, {atom, true}, {x, 5}},
						{move, {atom, true}, {x, 1}},
						{move, {atom, true}, {x, 6}},
						{move, {atom, true}, {x, 0}},
						{call_last, 7, {f, 9}, 0}]},
					      {function, arg_reg_alloc, 7, 9,
					       [{label, 8},
						{func_info, {atom, recv_eval},
						 {atom, arg_reg_alloc}, 7},
						{label, 9},
						{move, {atom, ok}, {x, 0}},
						return]},
					      {function, module_info, 0, 11,
					       [{label, 10},
						{func_info, {atom, recv_eval},
						 {atom, module_info}, 0},
						{label, 11},
						{move, {atom, recv_eval},
						 {x, 0}},
						{call_ext_only, 1,
						 {extfunc, erlang,
						  get_module_info, 1}}]},
					      {function, module_info, 1, 13,
					       [{label, 12},
						{func_info, {atom, recv_eval},
						 {atom, module_info}, 1},
						{label, 13},
						{move, {x, 0}, {x, 1}},
						{move, {atom, recv_eval},
						 {x, 0}},
						{call_ext_only, 2,
						 {extfunc, erlang,
						  get_module_info, 2}}]},
					      {function, '-receive/1-fun-0-', 1,
					       15,
					       [{label, 14},
						{func_info, {atom, recv_eval},
						 {atom, '-receive/1-fun-0-'},
						 1},
						{label, 15}, remove_message,
						return]}],
					     16},
					    [binary, from_asm]),
    code:load_binary(recv_eval, [], CplBin),
    Result = recv_eval:'receive'(Fr),
    code:delete(recv_eval),
    code:purge(recv_eval),
    Result.

'receive'(Fr, infinity, _) -> 'receive'(Fr);
'receive'(Fr, A, Fa) ->
    {ok, recv_eval, CplBin} = compile:forms({recv_eval,
					     [{'receive', 3}, {module_info, 0},
					      {module_info, 1}],
					     [],
					     [{function, 'receive', 3, 2,
					       [{label, 1},
						{func_info, {atom, recv_eval},
						 {atom, 'receive'}, 3},
						{label, 2}, {allocate, 4, 3},
						{init, {y, 2}},
						{move, {x, 2}, {y, 3}},
						{move, {x, 1}, {y, 0}},
						{move, {x, 0}, {y, 1}},
						{make_fun2, {f, 15}, 0, 0, 0},
						{move, {x, 0}, {y, 2}},
						{call, 0, {f, 7}}, {label, 3},
						{loop_rec, {f, 5}, {x, 0}},
						{move, {y, 2}, {x, 1}},
						{move, {y, 1}, {x, 2}},
						{call_fun, 2},
						{test, is_tagged_tuple, {f, 4},
						 [{x, 0}, 2, {atom, true}]},
						{get_tuple_element, {x, 0}, 1,
						 {x, 0}},
						{deallocate, 4}, return,
						{label, 4},
						{loop_rec_end, {f, 3}},
						{label, 5},
						{wait_timeout, {f, 3}, {y, 0}},
						timeout, {move, {y, 3}, {x, 0}},
						{call_fun, 0}, {deallocate, 4},
						return]},
					      {function, arg_reg_alloc, 0, 7,
					       [{label, 6},
						{func_info, {atom, recv_eval},
						 {atom, arg_reg_alloc}, 0},
						{label, 7}, {allocate, 0, 0},
						{move, {integer, 134217727},
						 {x, 0}},
						{call_ext, 1,
						 {extfunc, erlang,
						  bump_reductions, 1}},
						{move, {atom, true}, {x, 3}},
						{move, {atom, true}, {x, 4}},
						{move, {atom, true}, {x, 2}},
						{move, {atom, true}, {x, 5}},
						{move, {atom, true}, {x, 1}},
						{move, {atom, true}, {x, 6}},
						{move, {atom, true}, {x, 0}},
						{call_last, 7, {f, 9}, 0}]},
					      {function, arg_reg_alloc, 7, 9,
					       [{label, 8},
						{func_info, {atom, recv_eval},
						 {atom, arg_reg_alloc}, 7},
						{label, 9},
						{move, {atom, ok}, {x, 0}},
						return]},
					      {function, module_info, 0, 11,
					       [{label, 10},
						{func_info, {atom, recv_eval},
						 {atom, module_info}, 0},
						{label, 11},
						{move, {atom, recv_eval},
						 {x, 0}},
						{call_ext_only, 1,
						 {extfunc, erlang,
						  get_module_info, 1}}]},
					      {function, module_info, 1, 13,
					       [{label, 12},
						{func_info, {atom, recv_eval},
						 {atom, module_info}, 1},
						{label, 13},
						{move, {x, 0}, {x, 1}},
						{move, {atom, recv_eval},
						 {x, 0}},
						{call_ext_only, 2,
						 {extfunc, erlang,
						  get_module_info, 2}}]},
					      {function, '-receive/1-fun-0-', 1,
					       15,
					       [{label, 14},
						{func_info, {atom, recv_eval},
						 {atom, '-receive/1-fun-0-'},
						 1},
						{label, 15}, remove_message,
						return]}],
					     16},
					    [binary, from_asm]),
    code:load_binary(recv_eval, [], CplBin),
    Result = recv_eval:'receive'(Fr, A, Fa),
    code:delete(recv_eval),
    code:purge(recv_eval),
    Result.


