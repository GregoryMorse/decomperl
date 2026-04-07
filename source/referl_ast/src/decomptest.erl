%c("decomptest.erl", [debug_info,{outdir, "temp"}]).
-module(decomptest).
-import(decomp, [traverse_ast/3, decompileast/4]).

-export([incstruct/5, incstructlateerr/5, papertryreceive/2, matchhelper/0,
  slideexample/2,
  getlinenumber/0, tab2file/3, file2tab/2, get_table_list/2,
  testerlangbifs/0, testfloatarith/0, testintarith/0, testbitarith/0,
  testbool/0, testcomparison/0, testbranchcomp/0, testtypecomp/0,
  testtypebranchcomp/0, testlist/0, testlc/0, testlcdouble/0, testlctriple/0,
  testlcquad/0, testlcquint/0, testtuple/0, testbinary/0, testprivbinary/0,
  testbingetinteger/0, testbingetfloat/0, testbingetutf8/0, testbingetutf16/0,
  testbingetutf32/0, testbingetbinary/0, testbingetbinaryall/0,
  testbinskipbits/0, testbinskipbitsall/0, testbinskiputf8/0,
  testbinskiputf16/0, testbinskiputf32/0, testbinmatchstring/0,
  testbinskipinteger/0, testbinskipfloat/0,
  testmap/0, testfun/0, testnamedfun/0, testfuncerr/0, testcalls/0,
  testerrors/0, testall/0,
  testnoret/0, testsend/0, testreceiveref/0,
  testreceiveyield/0, testreceiveyieldexit/0, testreceivesleep/0,
  testreceivesleepexit/0, testreceivehalt/0,
  testreceiveallpoll/0, testreceiveallpollafterexit/0,
  testreceiveallpollmsgexit/0, testreceiveallpollexit/0,
  testreceiveall/0, testreceiveallafterexit/0, testreceiveallmsgexit/0,
  testreceiveallexit/0,
  testreceiveallinfinite/0, testreceiveallinfiniteexit/0,
  testreceivepoll/0, testreceivepollafterexit/0, testreceivepollmsgexit/0,
  testreceivepollexit/0,
  
  testtryexitcatch/0, testtryexitcatchexit/0,
  testtrycatch/0, testtrycatchcaseexit/0, testtrycatchcatchexit/0,
  testtrycatchexit/0,
  testcatch/0, testcatchexit/0,
  testcatchsharedend/0,
  testtrycatchsharedend/0, testtrysharedend/0, testtrytrycatchsharedend/0,
  testreceiveshared/0, testreceivesharedafter/0, testreceivesharedboth/0,
  
  testreceive/0, testreceiveafterexit/0, testreceivemsgexit/0,
  testreceiveexit/0,
  testreceiveinfinite/0, testreceiveinfiniteexit/0,
  
  testcatchcatch/0, testtrytrycatch/0, testtryerrcatch/0, testtrycatcherr/0,
  testtryerrcatcherr/0, testtryafter/0, testtrycatchstack/0,
  testcatchseq/0, testcatchcatchseq/0, testtrycatchseq/0, testtryerrcatchseq/0,
  testtrycatcherrseq/0, testtryerrcatcherrseq/0, testtryafterseq/0,
  testtrycatchstackseq/0,
  testtrycatchrecrs/0, testtrycatchmultirecrs/0, testtrycatchrecrsseq/0,
  testtrycatchmultirecrsseq/0, testtrycatchmulti/0, 
  testbase/3, testdef/1, testerr/2,
  testandalso/4, testorelse/4, testandalso2/5, testorelse2/5,
  testandalsoorelse/5, testorelseandalso/5, testandalsoorelse2/5,
  testorelseandalso2/5,
  testdefandalso/2, testdeforelse/2, testdefandalso2/3, testdeforelse2/3,
  testdefandalsoorelse/3, testdefandalsoorelse2/3, testdeforelseandalso/3,
  testdeforelseandalso2/3,
  testerrandalso/3, testerrorelse/3, testerrandalso2/4, testerrorelse2/4,
  testerrandalsoorelse/4, testerrandalsoorelse2/4, testerrorelseandalso/4,
  testerrorelseandalso2/4,
  testseqbase/3, testseqdef/2,
  testseqandalso/4, testseqorelse/4, testseqandalso2/5, testseqorelse2/5,
  testseqandalsoorelse/5, testseqorelseandalso/5, testseqandalsoorelse2/5,
  testseqorelseandalso2/5,
  testseqdefandalso/2, testseqdeforelse/2, testseqdefandalso2/3,
  testseqdeforelse2/3, testseqdefandalsoorelse/3, testseqdefandalsoorelse2/3,
  testseqdeforelseandalso/3, testseqdeforelseandalso2/3,
  sleep/1, optimized/1, check_decompileast/3, check_bin/0, check_recv/0,
  testdecomp/0,testdecomp2/0,testdecomp3/0]).

-on_load(load_func/0).
load_func() -> erlang:display("loaded"), ok.

incstruct(A, B, C, D, E) ->
  if not A -> A;
  A andalso B orelse C ->
    if D + E =:= 1 -> B; true -> error(D + E) end;
  true -> A end.
  
incstructlateerr(A, B, C, D, E) ->
  if not A -> A;
  A andalso B orelse C ->
    if D + E =:= 1 -> B end;
    true -> A end.

papertryreceive(A, B) ->
  try receive A -> 1; B -> 2 end of X -> X catch error:Y -> Y end.
  
slideexample(A, B) -> %A=4 is for Thursday, B=true
  case datetime:day_of_the_week(datetime:local_time()) of A when B ->
    self() ! "Carpe Diem!",
    try receive Num when is_integer(Num) orelse is_float(Num) -> Num;
      Message -> io:format(Message, []), error(true) end
    catch error:N when is_list(N) -> N end;
  _ -> io:format("Tempus Fugit!", []), error(false) end.

get_table_list(ets, Opts) ->
    HideSys = proplists:get_value(sys_hidden, Opts, true),
    _Info = fun(Id, Acc) ->
       try
           TabId = case ets:info(Id, named_table) of
           true -> ignore;
           false -> Id
             end,
           Name = 3,
           Protection = 1,
           Owner = 2,
           RegName = case catch process_info(Owner, registered_name) of
             [] -> ignore;
             {registered_name, ProcName} -> ProcName
         end,
           HideSys andalso ordsets:is_element(RegName, 0),
           Memory = 5,
           Tab = [{name,Name},
            {id,TabId},
            {protection,Protection},
            {owner,Owner},
            {size,ets:info(Id, size)},
            {reg_name,RegName},
            {type,ets:info(Id, type)},
            {keypos,ets:info(Id, keypos)},
            {heir,ets:info(Id, heir)},
            {memory,Memory},
            {compressed,ets:info(Id, compressed)},
            {fixed,ets:info(Id, fixed)}
           ],
           [Tab|Acc]
       catch _:_What ->
         %% io:format("Skipped ~p: ~p ~n",[Id, _What]),
         Acc
       end
     end.

tab2file(_Tab, _File, Options) ->
    try
  {ok, FtOptions} = Options,

  try
      {LogFun, InitState} = 
      case FtOptions of
    true ->
        {0,
         0};
    false ->
        {0, 
         true}
      end,
      {_NewState1,_Num} = try
          LogFun(InitState,[])
            after
          0
            end
  catch
      error:_ErReason ->
          0
  end
    catch
  exit:_ExReason2 ->
      0
    end.

file2tab(_File, Opts) ->
    try
  Name = make_ref(),
        Name =
      case disk_log:open([]) of
    Name ->
                    {ok, Name}
      end,
  try

      ReadFun = 
          case Opts of
        true ->
      {0,0};
        false ->
      {1,1}
    end,
      try
    file2tab(ReadFun,0)
      catch
    error:ErReason ->
        erlang:raise(error,ErReason,erlang:get_stacktrace())
      end
  after
      _ = disk_log:close(Name)
  end
    catch
  exit:ExReason2 ->
      {error,ExReason2}
    end.
    
matchhelper() ->
  fun(A, B) ->
    case A of [B|[{_C, [_C]}]] when B > 3 -> true; _ -> false end end.
  %fun(A, B) -> case A of {B, 4, C, {3, _, B, B}} -> true; _ -> false end end.
  %fun(A, B) -> case A of <<B, C, 3>> -> true; _ -> false end end.

getlinenumber() -> ?LINE =:= try error(undef)
  catch _:_ -> element(2, hd(tl(element(4, hd(erlang:get_stacktrace()))))) end.

testerlangbifs() -> [size(date()) =:= 3, get() =:= [],
  get("test") =:= undefined, get_keys() =:= [],
  is_pid(group_leader()), is_reference(make_ref()), is_atom(node()),
  is_list(nodes()),
  is_list(pre_loaded()), is_list(processes()), is_list(registered()),
  is_pid(self()), size(time()) =:= 3].

testfloatarith() -> fun(A, B, C, D, E) ->
  (1.0 + A + B - C) * D / E end(2.5, 3.5, 3.0, -4.5, 0.3) =:= -60.0.

testintarith() -> fun(A, B, C, D, E, F) ->
  (((A + B - C) * D) div E) rem F end(10 ,2, 3, 4, 6, 4) =:= 2.

testbitarith() -> fun(A, B, C, D, E, F) ->
  bnot (((((A band B) bor C) bxor D) bsl E) bsr F) end
  (7, 15, 32, 96, 3, 4) =:= -36.

testbool() -> fun(A, B, C, D) ->
  not(A and B or C xor is_boolean(D)) andalso (A orelse B) end
  (true, false, true, true).

testcomparison() -> Fun = fun(A, B, C, D, E, F, G, H, I) ->
  ((((((((A < B) >= C) > D) =< E) == F) /= G) =:= H) =/= I) end,
  Fun(1, 2, [], true, 0, false, true, true, false) =:= false.

testbranchcomp() -> Fun = fun(A, B, C, D, E, F, G, H, I) ->
  if A < B andalso B >= C andalso C > D andalso D =< E andalso E == F andalso
    F /= G andalso G =:= H andalso H =:= I -> true; true -> false end end,
    Fun(1, 2, [], true, 0, false, true, true, false) =:= false.

testtypecomp() -> Fun = fun({A, B, C, D, E, F, G, H, I, J, K}) ->
  is_integer(A) and is_float(B) and is_number(A) and is_number(B) and is_atom(C)
  and is_boolean(C) and is_pid(D) and is_reference(E) and is_port(F) and
  (([] = G) =:= []) and is_binary(H) and is_bitstring(H) and is_list(I) and
  (([_|_] = I) =/= []) and is_tuple(J) and (size({3, 4.0} = J) =:= 2) and
  is_function(K) and is_function(K, 1) end,
  %Fun({3, 4.0, false, <0.1.0>, #Ref<0.0.0.0>, #Port<0.0>, [], <<"test">>,
  %  [3|[4, 5]], {3, 4.0}})
  Fun({3, 4.0, false, self(), make_ref(), open_port({spawn, "cmd"},
    [{packet, 2}]), [], <<"test">>, [3|[4, 5]], {3, 4.0}, Fun}).
  
testtypebranchcomp() -> Fun = fun({A, B, C, D, E, F, G, H, I, J, K}) ->
  [] = G, [_|_] = I, {3, 4.0} = J, if is_integer(A) and is_float(B) and
    is_number(A) and is_number(B) and is_atom(C) and is_boolean(C) and is_pid(D)
    and is_reference(E) and is_port(F) and (G =:= []) and is_binary(H) and
    is_bitstring(H) and is_list(I) and (I =/= []) and is_tuple(J) and
    (size(J) =:= 2) and is_function(K) and is_function(K, 1) -> true;
  true -> false end end,
  Fun({3, 4.0, false, self(), make_ref(), open_port({spawn, "cmd"},
    [{packet, 2}]), [], <<"test">>, [3|[4, 5]], {3, 4.0}, Fun}).
  
testlist() -> Fun = fun(List) -> A = hd(List) + hd(tl(List)),
  [H|T] = List, [A =:= H + hd(T)] end,
  Fun([3|[4, 5, [], true, false]]) =:= [true].
testlc() -> [A || A <- lists:seq(1,5), A < 3].
testlcdouble() -> [(A + 3) * B ||
  A <- lists:seq(1,4), A < 3, B <- lists:seq(A,5), B < 4].
testlctriple() -> [((A + 3) * B + 2) * C ||
  A <- lists:seq(1,4), B <- lists:seq(1,A), C <- lists:seq(A, B)].
testlcquad() -> [(((A + 3) * B + 2) * C + 1) * D ||
  A <- lists:seq(1,4), B <- lists:seq(1,5), A < B, C <- lists:seq(1, 6),
  A + 3 * B < C, D <- lists:seq(1, 7), C < D].
testlcquint() -> [((((A + 3) * B + 2) * C + 1) * D + 4) * E ||
  A <- lists:seq(1,4), B <- lists:seq(1,5), A < B, C <- lists:seq(1, 6),
  A + 3 * B < C, D <- lists:seq(1, 7), (B + 3) * C < D + 4 * A,
  E <- lists:seq(1, 2), A < E].

testall() -> [testerlangbifs(), testfloatarith(), testintarith(),
  testbitarith(), testbool(), testcomparison(), testbranchcomp(),
  testtypecomp(), testtypebranchcomp(), testlist(), testtuple(), testbinary(),
  testprivbinary(), testmap(), testsend() =:= msg].

-record(testrec, {test1, test2, test3, test4, test5}).
testtuple() -> Fun = fun({Tuple, Other}) -> A = element(1, Tuple),
  {A, B} = Tuple, {A =:= B, setelement(1, Tuple, B),
  Other#testrec{test1=1, test3=2}} end,
  Fun({{3, 4}, #testrec{test1=0, test2=1, test3=1, test4=3, test5=4}}) =:=
    {false, {4, 4}, {testrec, 1, 1, 2, 3, 4}}.
    
testbingetinteger() -> _Fun = fun(A) -> <<B/integer>> = A, B end(<<4>>) =:= 4.
testbingetfloat() -> _Fun = fun(A) -> <<B/float>> = A, B end(<<4.2/float>>) =:= 4.2.
testbingetutf8() -> _Fun = fun(A) -> <<B/utf8>> = A, B end(<<$H/utf8>>) =:= $H.
testbingetutf16() -> _Fun = fun(A) -> <<B/utf16>> = A, B end(<<$I/utf16>>) =:= $I.
testbingetutf32() -> _Fun = fun(A) -> <<B/utf32>> = A, B end(<<$J/utf32>>) =:= $J.
testbingetbinary() -> _Fun = fun(A) -> <<B:2/binary, _/binary>> = A, B end(<<5,6,7,8>>) =:= <<5,6>>. %testunit
testbingetbinaryall() -> _Fun = fun(A) -> <<B/binary>> = A, B end(<<5,6,7,8>>) =:= <<5,6,7,8>>.
testbinskipbits() -> _Fun = fun(A) -> <<_:2/binary, B/binary>> = A, B end(<<5,6,7,8>>) =:= <<7,8>>.
testbinskipbitsall() -> _Fun = fun(A) -> <<B:17/bitstring, _:15/bitstring>> = A, B end(<<5,6,7,8>>) =:= <<5,6,0:1>>. %testtail, this is not right - case must only occur in special cases or optimizations e.g. binary comprehensions, need to find the minimal form after
testbinskiputf8() -> _Fun = fun(A) -> <<_/utf8, B/utf8>> = A, B end(<<$A/utf8, $H/utf8>>) =:= $H. %testtail
testbinskiputf16()  -> _Fun = fun(A) -> <<_/utf16, B/utf16>> = A, B end(<<$B/utf16, $I/utf16>>) =:= $I.%testtail
testbinskiputf32()  -> _Fun = fun(A) -> <<_/utf32, B/utf32>> = A, B end(<<$C/utf32, $J/utf32>>) =:= $J. %testtail
testbinmatchstring() -> _Fun = fun(A) -> <<5, 6, B/binary>> = A, B end(<<5,6,7,8>>) =:= <<7,8>>.

testbinskipinteger() -> _Fun = fun(A) -> <<_/integer, B/integer>> = A, B end(<<0,4>>) =:= 4. %testtail
testbinskipfloat() -> _Fun = fun(A) -> <<_/float, B/float>> = A, B end(<<0.2/float,4.2/float>>) =:= 4.2. %testtail

testbinary() -> Fun = fun(A) -> B = <<A/signed-native>>, C = <<4.0:64/float-unit:1>>, D = <<A/utf16-little>>, Dd = <<A/utf16-big>>, E = <<A/utf8>>, F = <<A/utf32-little>>, G = <<A/utf32-big>>,
  <<_H, _T/binary>> = <<B/binary, C/binary, D/binary, Dd/binary, E/binary, F/binary, G/binary, 0, 1, 2>> end, A = Fun(4),
  <<T0/integer, S0/integer, T1/float, S1/float, T2/utf8, S2/utf8, T3/utf16, S3/utf16, _:8/integer-unit:4, T4/utf32-little, S4/utf32, T5/binary>> = <<A/binary, A/binary>>,
  erlang:display({T0, S0, T1, S1, T2, S2, T3, S3, T4, S4, T5, A}),
  {[16257, 1], <<0>>} = inc_on_ones(<<255,1,128,1,128,0>>, 0, [], 5),
  T6 = <<1:1>>, <<0:8, 4:8, _:8/integer-unit:1, 4:8, 0:8, T7/bitstring>> = T6, <<T9:1, _/bitstring>> = T7 , <<_T8:1, _:1>> = <<T6/bitstring, T6/bitstring>>, C2 = is_bitstring(A),
  is_bitstring(A) andalso C2 andalso case T9 of <<1:1, X1:7, X2/binary>> -> X1 =:= 2 andalso X2 =:= <<2>>; <<X1, X2/binary>> -> X1 =:= 1 andalso X2 =:= <<2>>; _ -> false end andalso T9 =:= 0 andalso
  Fun(3) =:= <<T0, T1/float, T2, T3, T4, T5/binary, T6/bitstring, T9/bitstring, 0, 1, 2>>
.

inc_on_ones(Buffer, _Av, Al, 0) ->
  {lists:reverse(Al), Buffer};
inc_on_ones(<<1:1, H:7, T/binary>>, Av, Al, Len) ->
  inc_on_ones(T, (Av bsl 7) bor H, Al, Len-1);
inc_on_ones(<<H, T/binary>>, Av, Al, Len) ->
  inc_on_ones(T, 0, [((Av bsl 7) bor H)|Al], Len-1).

testprivbinary() -> Fun = fun(Input) -> << <<0, 1, 2, Bin:42>> || <<Bin:42>> <= Input >> end, Fun(<<8:42, 9:42, 10:42, 11:42>>) =:= <<0, 1, 2, <<8:42>>/bitstring, 0, 1, 2, <<9:42>>/bitstring, 0, 1, 2, <<10:42>>/bitstring, 0, 1, 2, <<11:42>>/bitstring>>.

testmap() -> Fun = fun() -> _M = #{a => 2, b => 3, c=> 4, "a" => 1, "b" => 2, "c" => 4} end, X = Fun(), #{b := Y} = X, Z = X#{b := 8, c := 10}, Z2 = X#{c => 10, b => 8}, T = maps:is_key(a, (#{a := _} = Z)), Y2 = maps:get(b, X), erlang:display({Z, Z2, X, Y, Y2, T}), if is_map(Z) andalso map_size(X) =:= 6 andalso Y =:= Y2 andalso T -> Z2 =:= Z; true -> false end.
%Future map comprehensions:
%Weather = #{toronto => rain, montreal => storms, london => fog, paris => sun, boston => fog, vancouver => snow}.
%FoggyPlaces = [X || X := fog <- Weather].
%#{X => foggy || X <- [london,boston]}.
%map(F, Map) -> #{K => F(V) || K := V <- Map}.

testfun() -> Fun = fun(A) -> C = A + 3, D = A * 6, fun (B) -> A + B * D + C end end, (Fun(3))(4) =:= 13.
testnamedfun() -> fun MyFun(A) -> if A =:= 0 -> A; true -> MyFun(A - 1) end end(12).
testfuncerr() -> erlang:display({catch fun (A) when is_integer(A) -> A end(4.0), catch fun(A) -> case is_integer(A) of true -> A; _ -> error(function_clause, [A]) end end(4.0)}),
  case catch fun (A) when is_integer(A) -> A end(4.0) of {'EXIT',{function_clause,[_|_]}} -> true; _ -> false end.

testsend() -> self() ! msg.

testcalls() -> Fun = fun(Mod, Func) -> apply(Mod, Func, [1, [3]]) + erlang:apply(Mod, Func, [1, [4]]) end, lists:nth(1, [3]) =:= 3 andalso Fun(lists, nth) =:= 7.

sleep(T) -> receive after T -> ok end.
%flush() -> receive _ -> flush() after 0 -> ok end.
%important() -> receive {Priority, Message} when Priority > 10 -> [Message | important()] after 0 -> normal() end.
%normal() -> receive {_, Message} -> [Message | normal()] after 0 -> [] end.
%% optimized in R14A
optimized(Pid) -> Ref = make_ref(), Pid ! {self(), Ref, hello}, receive {Pid, Ref, Msg} -> io:format("~p~n", [Msg]) end.

testerrors() -> FunIf = fun(A) -> try if A =:= 1 -> true end of true -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= if_clause end end,
  FunCatch = fun() -> catch erlang:error(if_clause) end, erlang:display(FunCatch()), Ln = ?LINE,
  FunAfter = fun(A) -> try try A = 1 of _ -> false after 3 end of _ -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {badmatch,1} end end,
  FunThrowAfter = fun(A) -> try try throw(A) of _ -> false after 3 end of _ -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= throw andalso Reason =:= A end end,
  FunCase = fun(A) -> try case A of 1 -> true end of true -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {case_clause,A} end end,
  FunTry = fun(A) -> try try A of 1 -> false catch _ -> true end catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {try_clause,A} end end,
  FunMatch = fun(A) -> try A = 1 of _ -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {badmatch,1} end end,
  FunClause = fun(A) -> FunInner = fun(B) when B =:= 1 -> B end, try FunInner(A) of _ -> false catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= function_clause end end,
  FunBadArg = fun(A) -> try length(A) catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= badarg end end,
  FunBadArith = fun(A) -> try A + 1 catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= badarith end end,
  FunBadFun = fun(A) -> try A() catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {badfun, A} end end,
  FunBadArity = fun(A) -> try A() catch Class:Reason -> erlang:display({Class,Reason}),Class =:= error andalso Reason =:= {badarity, {A, []}} end end,
  [FunIf(0), FunIf(1) =:= false, 
  FunCatch() =:= {'EXIT',{if_clause,[{?MODULE,'-testerrors/0-fun-1-',0,[{file,?MODULE_STRING ".erl"},{line,Ln}]},{?MODULE,testerrors,0,[{file,?MODULE_STRING ".erl"},{line,?LINE}]},{erl_eval,do_apply,6,[{file,"erl_eval.erl"},{line,674}]},{shell,exprs,7,[{file,"shell.erl"},{line,687}]},{shell,eval_exprs,7,[{file,"shell.erl"},{line,642}]},{shell,eval_loop,3,[{file,"shell.erl"},{line,627}]}]}},
  FunThrowAfter(0), FunAfter(0), FunAfter(1) =:= false, FunCase(0), FunCase(1) =:= false, FunTry(0), FunTry(1) =:= false, FunMatch(0), FunMatch(1) =:= false, FunClause(0), FunClause(1) =:= false, FunBadArg({}), FunBadArith({}), FunBadFun({}), FunBadArity(fun (A) -> A end)].

testnoret() -> error(0).

testreceiveref() -> A = make_ref(), self() ! A, try receive A -> throw([]) after 1 -> 1 end of _ -> 0 catch _ -> 2 end.

testreceiveyield() -> fun (A) -> receive after 0 -> A end end(2).
testreceiveyieldexit() -> fun (A) -> receive after 0 -> exit(A) end end(2).
testreceivesleep() -> fun (N, A) -> receive after N -> A end end(1, 2).
testreceivesleepexit() -> fun (N, A) -> receive after N -> exit(A) end end(1, 2).
testreceivehalt() -> fun (A) -> receive after infinity -> A end end(2).

testreceiveallpoll() -> fun (A) -> receive X -> X after 0 -> A end end(2).
testreceiveallpollafterexit() ->
  fun (A) -> receive X -> X after 0 -> exit(A) end end(2).
testreceiveallpollmsgexit() ->
  fun (A) -> receive X -> exit(X) after 0 -> A end end(2).
testreceiveallpollexit() ->
  fun (A) -> receive X -> exit(X) after 0 -> exit(A) end end(2).
testreceiveall() -> fun (N, A) -> receive X -> X after N -> A end end(1, 2).
testreceiveallafterexit() ->
  fun (N, A) -> receive X -> X after N -> exit(A) end end(1, 2).
testreceiveallmsgexit() ->
  fun (N, A) -> receive X -> exit(X) after N -> A end end(1, 2).
testreceiveallexit() ->
  fun (N, A) -> receive X -> exit(X) after N -> exit(A) end end(1, 2).
testreceiveallinfinite() -> fun() -> receive X -> X end end().
testreceiveallinfiniteexit() -> fun() -> receive X -> exit(X) end end().

testreceivepoll() -> fun (X, A) -> receive X -> X after 0 -> A end end(1, 2).
testreceivepollafterexit() ->
  fun (X, A) -> receive X -> X after 0 -> exit(A) end end(1, 2).
testreceivepollmsgexit() ->
  fun (X, A) -> receive X -> exit(X) after 0 -> A end end(1, 2).
testreceivepollexit() ->
  fun (X, A) -> receive X -> exit(X) after 0 -> exit(A) end end(1, 2).
testreceive() -> fun (X, N, A) -> receive X -> X after N -> A end end(1, 2, 3).
testreceiveafterexit() ->
  fun (X, N, A) -> receive X -> X after N -> exit(A) end end(1, 2, 3).
testreceivemsgexit() ->
  fun (X, N, A) -> receive X -> exit(X) after N -> A end end(1, 2, 3).
testreceiveexit() ->
  fun (X, N, A) -> receive X -> exit(X) after N -> exit(A) end end(1, 2, 3).
testreceiveinfinite() -> fun(X) -> receive X -> X end end.
testreceiveinfiniteexit() -> fun(X) -> receive X -> exit(X) end end.

testtryexitcatch() -> fun (A) -> try exit(A) catch _:B -> B end end(1).
testtryexitcatchexit() ->
  fun (A) -> try exit(A) catch _:B -> exit(B) end end(1).
testtrycatch() -> fun (A) -> try A() of X -> X catch _:Y -> Y end end
  (fun () -> fun (A, B) -> A / B end(5, 0) end).
testtrycatchcaseexit() ->
  fun (A) -> try A() of X -> exit(X) catch _:Y -> Y end end
  (fun () -> fun (A, B) -> A / B end(5, 0) end).
testtrycatchcatchexit() ->
  fun (A) -> try A() of X -> X catch _:Y -> exit(Y) end end
  (fun () -> fun (A, B) -> A / B end(5, 0) end).
testtrycatchexit() ->
  fun (A) -> try A() of X -> exit(X) catch _:Y -> exit(Y) end end
  (fun () -> fun (A, B) -> A / B end(5, 0) end).

testcatch() ->
  fun (A) -> catch A() end(fun () -> fun (A, B) -> A / B end(5, 0) end).
testcatchexit() -> fun (A) -> catch exit(A) end(1).

testcatchsharedend() -> fun (A, B, C) -> case A of true -> catch B(); _ -> catch C() end end(true, fun () -> false end, fun () -> true end).
testtrycatchsharedend() -> fun (A, B, C) -> case A of true -> try B() of _ -> true catch X1:Y1 -> {X1,Y1} end; _ -> try C() of _ -> false catch X2:Y2 -> {X2,Y2} end end end(true, fun () -> false end, fun () -> true end).
testtrysharedend() -> fun (A, B, C) -> case A of true -> try B() of X1 -> X1 catch _:_ -> true end; _ -> try C() of X2 -> X2 catch _:_ -> false end end end(true, fun () -> false end, fun () -> true end).
testtrytrycatchsharedend() -> fun (A, B, C) -> case A of true -> try B() of W1 -> W1 catch X1:Y1 -> {X1,Y1} end; _ -> try C() of W2 -> W2 catch X2:Y2 -> {X2,Y2} end end end(true, fun () -> false end, fun () -> true end).
testreceivesharedboth() -> fun (A, B, C) -> case A of true -> receive B -> B after 1 -> C end; _ -> receive B -> B after 2 -> C end end end(true, true, false).
testreceivesharedafter() -> fun (A, B, C) -> case A of true -> receive B -> B after 1 -> 1 end; _ -> receive C -> C after 2 -> 1 end end end(true, true, false).
testreceiveshared() -> fun (A, B, C) -> case A of true -> receive 0 -> 0 after 1 -> B end; _ -> receive 0 -> 0 after 2 -> C end end end(true, true, false).

testcatchcatch() -> catch catch fun (A, B) -> A / B end(5, 0).
testcatchcatchseq() -> catch catch fun (A, B) -> A / B end(5, 0) + 7.
testcatchseq() -> catch fun (A, B) -> A / B end(5, 0) + 7.
testtrytrycatch() -> try try fun (A, B) -> A / B end(5, 0) of X -> X catch _X:Y -> Y end of XI -> XI catch _XI:YI -> YI end.
testtrycatchrecrs() -> try fun (A, B) -> A / B end(5, 0) of _X -> try fun (A, B) -> A / B end(5, 0) of XI -> XI catch _XI:YI -> YI end catch _X:Y -> Y end.
testtrycatchmultirecrs() -> try fun (A, B) -> A / B end(5, 0) of _X -> try fun (A, B) -> A / B end(5, 0) of _XI -> try fun (A, B) -> A / B end(5, 0) of XII -> XII catch _XII:YII -> YII end catch _XI:YI -> YI end catch _X:Y -> Y end.
testtrycatchrecrsseq() -> try fun (A, B) -> A / B end(5, 0) of _X -> try fun (A, B) -> A / B end(5, 0) of XI -> XI catch _XI:YI -> YI end catch _X:Y -> Y end + 7.
testtrycatchmultirecrsseq() -> try fun (A, B) -> A / B end(5, 0) of _X -> try fun (A, B) -> A / B end(5, 0) of _XI -> try fun (A, B) -> A / B end(5, 0) of XII -> XII catch _XII:YII -> YII end catch _XI:YI -> YI end catch _X:Y -> Y end + 7.
testtrycatchmulti() -> try fun (A, B) -> A / B end(5, 0) of test -> 1; X -> X catch a:b -> a; _X:Y -> Y end.
testtrycatchseq() -> try fun (A, B) -> A / B end(5, 0) of X -> X catch _X:Y -> Y end + 7.
testtryerrcatch() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch _X:Y -> Y end.
testtryerrcatchseq() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch _X:Y -> Y end + 7.
testtrycatcherr() -> try fun (A, B) -> A / B end(5, 0) of X -> X catch test -> test end.
testtrycatcherrseq() -> try fun (A, B) -> A / B end(5, 0) of X -> X catch test -> test end + 7.
testtryerrcatcherr() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch test -> test end.
testtryerrcatcherrseq() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch test -> test end + 7.
testtryafter() -> fun (A, B) -> try A of B -> A after B end end().
testtryafterseq() -> fun (A, B) -> try A of B -> A after B end end() + 7.
testtrycatchstack() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch X:Y -> Z = erlang:get_stacktrace(), erlang:display({X, Y, Z}) after 3 end.
testtrycatchstackseq() -> try fun (A, B) -> A / B end(5, 0) of X when is_integer(X) -> X catch X:Y -> Z = erlang:get_stacktrace(), erlang:display({X, Y, Z}) after 3 end + 7.

testbase(A, B, C) -> if A -> B; true -> C end.
testdef(A) -> if A -> not A; true -> A end.
testerr(A, B) -> if A -> B end.

testandalso(A, B, C, D) -> if A andalso B -> C; true -> D end.
testorelse(A, B, C, D) -> if A orelse B -> C; true -> D end.
testandalso2(A, B, C, D, E) -> if A andalso B andalso C -> D; true -> E end.
testandalsoorelse(A, B, C, D, E) -> if A andalso B orelse C -> D; true -> E end.
testandalsoorelse2(A, B, C, D, E) -> if A andalso (B orelse C) -> D; true -> E end.
testorelse2(A, B, C, D, E) -> if A orelse B orelse C -> D; true -> E end.
testorelseandalso(A, B, C, D, E) -> if A orelse B andalso C -> D; true -> E end.
testorelseandalso2(A, B, C, D, E) -> if (A orelse B) andalso C -> D; true -> E end.

testdefandalso(A, B) -> if A andalso B -> not A; true -> A end.
testdeforelse(A, B) -> if A orelse B -> not A; true -> A end.
testdefandalso2(A, B, C) -> if A andalso B andalso C -> not A; true -> A end.
testdefandalsoorelse(A, B, C) -> if A andalso B orelse C -> not A; true -> A end.
testdefandalsoorelse2(A, B, C) -> if A andalso (B orelse C) -> not A; true -> A end.
testdeforelse2(A, B, C) -> if A orelse B orelse C -> not A; true -> A end.
testdeforelseandalso(A, B, C) -> if A orelse B andalso C -> not A; true -> A end.
testdeforelseandalso2(A, B, C) -> if (A orelse B) andalso C -> not A; true -> A end.

testerrandalso(A, B, C) -> if A andalso B -> C end.
testerrorelse(A, B, C) -> if A orelse B -> C end.
testerrandalso2(A, B, C, D) -> if A andalso B andalso C -> D end.
testerrandalsoorelse(A, B, C, D) -> if A andalso B orelse C -> D end.
testerrandalsoorelse2(A, B, C, D) -> if A andalso (B orelse C) -> D end.
testerrorelse2(A, B, C, D) -> if A orelse B orelse C -> D end.
testerrorelseandalso(A, B, C, D) -> if A orelse B andalso C -> D end.
testerrorelseandalso2(A, B, C, D) -> if (A orelse B) andalso C -> D end.

testseqbase(A, B, C) -> if A -> B; true -> C end and B.
testseqdef(A, B) -> if A -> not A; true -> A end and B.

testseqandalso(A, B, C, D) -> if A andalso B -> C; true -> D end and B.
testseqorelse(A, B, C, D) -> if A orelse B -> C; true -> D end and B.
testseqandalso2(A, B, C, D, E) -> if A andalso B andalso C -> D; true -> E end and B.
testseqandalsoorelse(A, B, C, D, E) -> if A andalso B orelse C -> D; true -> E end and B.
testseqandalsoorelse2(A, B, C, D, E) -> if A andalso (B orelse C) -> D; true -> E end and B.
testseqorelse2(A, B, C, D, E) -> if A orelse B orelse C -> D; true -> E end and B.
testseqorelseandalso(A, B, C, D, E) -> if A orelse B andalso C -> D; true -> E end and B.
testseqorelseandalso2(A, B, C, D, E) -> if (A orelse B) andalso C -> D; true -> E end and B.

testseqdefandalso(A, B) -> if A andalso B -> not A; true -> A end and B.
testseqdeforelse(A, B) -> if A orelse B -> not A; true -> A end and B.
testseqdefandalso2(A, B, C) -> if A andalso B andalso C -> not A; true -> A end and B.
testseqdefandalsoorelse(A, B, C) -> if A andalso B orelse C -> not A; true -> A end and B.
testseqdefandalsoorelse2(A, B, C) -> if A andalso (B orelse C) -> not A; true -> A end and B.
testseqdeforelse2(A, B, C) -> if A orelse B orelse C -> not A; true -> A end and B.
testseqdeforelseandalso(A, B, C) -> if A orelse B andalso C -> not A; true -> A end and B.
testseqdeforelseandalso2(A, B, C) -> if (A orelse B) andalso C -> not A; true -> A end and B.


change_var_names(AST) ->
  element(1, traverse_ast(fun(Elem, Acc) -> case Elem of {var,_,A} -> case lists:keyfind(A, 1, Acc) of {A, Idx} -> {{var,0,list_to_atom("Var" ++ integer_to_list(Idx))}, Acc};
      false -> {{var,0,list_to_atom("Var" ++ integer_to_list(length(Acc) + 1))}, lists:keystore(A, 1, Acc, {A, length(Acc) + 1})} end; _ -> {setelement(2, Elem, 0), Acc} end end, [], AST))
.

compare_ast(AST, OrigAST) ->
  FixAST = change_var_names(AST),
  OrigFixAST = change_var_names(OrigAST),
  if FixAST =/= OrigFixAST -> erlang:display(FixAST), erlang:display(OrigFixAST); true -> true end,
  FixAST =:= OrigFixAST
.

check_sem_equiv(AST, BeamFName, Funcname, Arity) ->
  case beam_lib:chunks(BeamFName, [abstract_code]) of
  {ok, {_, [{abstract_code, {raw_abstract_v1,Forms}}]}} ->
    Src = tl(Forms),
    compare_ast(hd(element(5, AST)), hd(element(5, hd(lists:dropwhile(fun(Elem) -> element(1, Elem) =/= function orelse element(3, Elem) =/= Funcname orelse element(4, Elem) =/= Arity end, Src)))))
  end
.
check_decompileast(Filename, Funcname, Arity) ->
  check_sem_equiv(lists:nth(3, element(1, decompileast(Filename, Funcname, Arity, [optimize, progress, bfsscan]))), Filename, Funcname, Arity)
.

auto_check(Func, Args) ->
  decomp:decompile(code:which(?MODULE), Func, length(Args), "temp/out.erl", [changemodname,compile]),
  c:l(out), RetVal = apply(out, Func, Args),
  code:purge(out), code:delete(out), RetVal.

check_bin() ->
  [auto_check(testbingetinteger,[]), auto_check(testbingetfloat,[]),
  auto_check(testbingetutf8,[]),auto_check(testbingetutf16,[]),
  auto_check(testbingetutf32,[]), auto_check(testbingetbinary,[]),
  auto_check(testbingetbinaryall,[]), auto_check(testbinskipbits,[]),
  auto_check(testbinskipbitsall,[]), auto_check(testbinskiputf8,[]),
  auto_check(testbinskiputf16,[]), auto_check(testbinskiputf32,[]),
  auto_check(testbinmatchstring,[]), auto_check(testbinskipinteger,[]),
  auto_check(testbinskipfloat,[])]
.

check_recv() ->
  [auto_check(testreceiveyield,[]) =:= 2,
  auto_check(testreceiveall,[]) =:= 2,
  auto_check(testreceiveallpoll,[]) =:= 2,
  begin self() ! {}, auto_check(testreceiveallinfinite,[]) =:= {} end]
.

testdecomp() -> [check_decompileast(code:which(?MODULE), testbase, 3),
  check_decompileast(code:which(?MODULE), testdef, 1), check_decompileast(code:which(?MODULE), testerr, 2),
  check_decompileast(code:which(?MODULE), testandalso, 4),check_decompileast(code:which(?MODULE), testorelse, 4),
  check_decompileast(code:which(?MODULE), testandalso2, 5),check_decompileast(code:which(?MODULE), testandalsoorelse, 5),
  check_decompileast(code:which(?MODULE), testandalsoorelse2, 5),check_decompileast(code:which(?MODULE), testorelse2, 5),
  check_decompileast(code:which(?MODULE), testorelseandalso, 5),check_decompileast(code:which(?MODULE), testorelseandalso2, 5),
  check_decompileast(code:which(?MODULE), testdefandalso, 2),check_decompileast(code:which(?MODULE), testdeforelse, 2),
  check_decompileast(code:which(?MODULE), testdefandalso2, 3),check_decompileast(code:which(?MODULE), testdefandalsoorelse, 3),
  check_decompileast(code:which(?MODULE), testdefandalsoorelse2, 3),check_decompileast(code:which(?MODULE), testdeforelse2, 3),
  check_decompileast(code:which(?MODULE), testdeforelseandalso, 3),check_decompileast(code:which(?MODULE), testdeforelseandalso2, 3),
  check_decompileast(code:which(?MODULE), testerrandalso, 3),check_decompileast(code:which(?MODULE), testerrorelse, 3),
  check_decompileast(code:which(?MODULE), testerrandalso2, 4),check_decompileast(code:which(?MODULE), testerrandalsoorelse, 4),
  check_decompileast(code:which(?MODULE), testerrandalsoorelse2, 4),check_decompileast(code:which(?MODULE), testerrorelse2, 4),
  check_decompileast(code:which(?MODULE), testerrorelseandalso, 4),check_decompileast(code:which(?MODULE), testerrorelseandalso2, 4)].
testdecomp2() -> [check_decompileast(code:which(?MODULE), testseqbase, 3), check_decompileast(code:which(?MODULE), testseqdef, 2),
  check_decompileast(code:which(?MODULE), testseqandalso, 4),check_decompileast(code:which(?MODULE), testseqorelse, 4),
  check_decompileast(code:which(?MODULE), testseqandalso2, 5),check_decompileast(code:which(?MODULE), testseqandalsoorelse, 5),
  check_decompileast(code:which(?MODULE), testseqandalsoorelse2, 5),check_decompileast(code:which(?MODULE), testseqorelse2, 5),
  check_decompileast(code:which(?MODULE), testseqorelseandalso, 5),check_decompileast(code:which(?MODULE), testseqorelseandalso2, 5),
  check_decompileast(code:which(?MODULE), testseqdefandalso, 2),check_decompileast(code:which(?MODULE), testseqdeforelse, 2),
  check_decompileast(code:which(?MODULE), testseqdefandalso2, 3),check_decompileast(code:which(?MODULE), testseqdefandalsoorelse, 3),
  check_decompileast(code:which(?MODULE), testseqdefandalsoorelse2, 3),check_decompileast(code:which(?MODULE), testseqdeforelse2, 3),
  check_decompileast(code:which(?MODULE), testseqdeforelseandalso, 3),check_decompileast(code:which(?MODULE), testseqdeforelseandalso2, 3)].
testdecomp3() -> [check_decompileast(code:which(?MODULE), testerlangbifs, 0),check_decompileast(code:which(?MODULE), testfloatarith, 0),
  check_decompileast(code:which(?MODULE), testintarith, 0),check_decompileast(code:which(?MODULE), testbitarith, 0),
  check_decompileast(code:which(?MODULE), testbool, 0),check_decompileast(code:which(?MODULE), testcomparison, 0),
  check_decompileast(code:which(?MODULE), testbranchcomp, 0),check_decompileast(code:which(?MODULE), testtypecomp, 0),
  check_decompileast(code:which(?MODULE), testtypebranchcomp, 0),check_decompileast(code:which(?MODULE), testlist, 0),
  check_decompileast(code:which(?MODULE), testmap, 0),check_decompileast(code:which(?MODULE), testtuple, 0),
  check_decompileast(code:which(?MODULE), testsend, 0),check_decompileast(code:which(?MODULE), testcalls, 0)].
