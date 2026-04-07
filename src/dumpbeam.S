{module, dumpbeam}.  %% version = 0

{exports, [{diffpatch,0},
           {dumpbinmatch,0},
           {dumpregs,0},
           {funtobeam,0},
           {module_info,0},
           {module_info,1},
           {select_receive,3}]}.

{attributes, []}.

{labels, 35}.


{function, funtobeam, 0, 2}.
  {label,1}.
    {line,[{location,"src/dumpbeam.erl",15}]}.
    {func_info,{atom,dumpbeam},{atom,funtobeam},0}.
  {label,2}.
    {make_fun2,{f,34},0,0,0}.
    return.


{function, dumpregs, 0, 4}.
  {label,3}.
    {line,[{location,"src/dumpbeam.erl",17}]}.
    {func_info,{atom,dumpbeam},{atom,dumpregs},0}.
  {label,4}.
    {allocate,0,0}.
    {move,{integer,1023},{x,1}}.
    {move,{integer,0},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",18}]}.
    {call_ext,2,{extfunc,lists,seq,2}}.
    {call_last,1,{f,31},0}.


{function, dumpbinmatch, 0, 6}.
  {label,5}.
    {line,[{location,"src/dumpbeam.erl",20}]}.
    {func_info,{atom,dumpbeam},{atom,dumpbinmatch},0}.
  {label,6}.
    {move,{literal,<<3,4,5>>},{x,0}}.
    {bs_start_match4,{atom,no_fail},0,{x,0},{x,0}}.
    {test,bs_test_tail2,{f,7},[{x,0},24]}.
    {move,{literal,{<<3,4,5>>}},{x,0}}.
	{move,{x,0},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",21}]}.
    {call_ext_only,1,{extfunc,erlang,display,1}}.
  {label,7}.
    {line,[{location,"src/dumpbeam.erl",21}]}.
    {badmatch,{literal,<<3,4,5>>}}.


{function, select_receive, 3, 9}.
  {label,8}.
    {line,[{location,"src/dumpbeam.erl",23}]}.
    {func_info,{atom,dumpbeam},{atom,select_receive},3}.
  {label,9}.
    {allocate,4,3}.
    {init,{y,0}}.
    {move,{x,2},{y,1}}.
    {move,{x,1},{y,2}}.
    {move,{x,0},{y,3}}.
    {make_fun2,{f,27},0,0,0}.
    {move,{x,0},{y,0}}.
    {'%',{var_info,{y,0},[{fun_type,{t_atom,[true]}}]}}.
  {label,10}.
    {loop_rec,{f,11},{x,0}}.
    remove_message.
    {move,{y,0},{x,1}}.
    {move,{y,3},{x,2}}.
    {line,[{location,"src/dumpbeam.erl",24}]}.
    {call_fun,2}.
    {deallocate,4}.
    return.
  {label,11}.
    {wait_timeout,{f,10},{y,2}}.
    timeout.
    {move,{y,1},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",24}]}.
    {call_fun,0}.
    {deallocate,4}.
    return.


{function, diffpatch, 0, 13}.
  {label,12}.
    {line,[{location,"src/dumpbeam.erl",26}]}.
    {func_info,{atom,dumpbeam},{atom,diffpatch},0}.
  {label,13}.
    {allocate_zero,6,0}.
    {move,{literal,"ebin/dumpbeam.beam"},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",27}]}.
    {call_ext,1,{extfunc,file,read_file_info,1}}.
    {test,is_tagged_tuple,{f,19},[{x,0},2,{atom,ok}]}.
    {get_tuple_element,{x,0},1,{y,5}}.
    {test,is_tagged_tuple,{f,19},[{y,5},14,{atom,file_info}]}.
    {move,{literal,"ebin/dumpbeam.beam2"},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",28}]}.
    {call_ext,1,{extfunc,file,read_file_info,1}}.
    {test,is_tagged_tuple,{f,18},[{x,0},2,{atom,ok}]}.
    {get_tuple_element,{x,0},1,{y,4}}.
    {test,is_tagged_tuple,{f,18},[{y,4},14,{atom,file_info}]}.
    {move,{literal,[read,write]},{x,1}}.
    {move,{literal,"ebin/dumpbeam.beam"},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",29}]}.
    {call_ext,2,{extfunc,file,open,2}}.
    {move,{x,0},{y,3}}.
    {test,is_tagged_tuple,{f,17},[{x,0},2,{atom,ok}]}.
    {move,{literal,[read]},{x,1}}.
    {move,{literal,"ebin/dumpbeam.beam2"},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",30}]}.
    {call_ext,2,{extfunc,file,open,2}}.
    {move,{x,0},{y,2}}.
    {test,is_tagged_tuple,{f,16},[{x,0},2,{atom,ok}]}.
    {get_tuple_element,{y,3},1,{y,3}}.
    {get_tuple_element,{y,5},1,{y,5}}.
    {move,{y,5},{x,1}}.
    {move,{y,3},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",31}]}.
    {call_ext,2,{extfunc,file,read,2}}.
    {move,{x,0},{y,1}}.
    {test,is_tagged_tuple,{f,15},[{x,0},2,{atom,ok}]}.
    {get_tuple_element,{y,2},1,{y,2}}.
    {get_tuple_element,{y,4},1,{y,4}}.
    {move,{y,4},{x,1}}.
    {move,{y,2},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",32}]}.
    {call_ext,2,{extfunc,file,read,2}}.
    {move,{x,0},{y,0}}.
    {test,is_tagged_tuple,{f,14},[{x,0},2,{atom,ok}]}.
    {test_heap,3,0}.
    {put_tuple2,{x,0},{list,[{y,5},{y,4}]}}.
    {move,{y,0},{y,4}}.
    {trim,1,5}.
    {line,[{location,"src/dumpbeam.erl",33}]}.
    {call_ext,1,{extfunc,erlang,display,1}}.
    {make_fun2,{f,25},0,0,0}.
    {'%',{var_info,{x,0},[{fun_type,{t_atom,[false,true]}}]}}.
    {move,{y,4},{x,1}}.
    {move,{x,0},{y,4}}.
    {move,{integer,1},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",34}]}.
    {call_ext,2,{extfunc,lists,seq,2}}.
    {get_tuple_element,{y,3},1,{x,2}}.
    {get_tuple_element,{y,0},1,{x,1}}.
    {move,{y,1},{y,3}}.
    {trim,2,3}.
    {line,[{location,"src/dumpbeam.erl",34}]}.
    {call_ext,3,{extfunc,lists,zip3,3}}.
    {move,{x,0},{x,1}}.
    {move,{y,2},{x,0}}.
    {move,{y,0},{y,2}}.
    {trim,1,2}.
    {line,[{location,"src/dumpbeam.erl",34}]}.
    {call_ext,2,{extfunc,lists,filter,2}}.
    {line,[{location,"src/dumpbeam.erl",35}]}.
    {call_ext,1,{extfunc,erlang,display,1}}.
    {move,{y,1},{x,0}}.
    {move,{y,0},{y,1}}.
    {trim,1,1}.
    {line,[{location,"src/dumpbeam.erl",36}]}.
    {call_ext,1,{extfunc,file,close,1}}.
    {move,{y,0},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",36}]}.
    {call_ext_last,1,{extfunc,file,close,1},1}.
  {label,14}.
    {line,[{location,"src/dumpbeam.erl",32}]}.
    {badmatch,{x,0}}.
  {label,15}.
    {line,[{location,"src/dumpbeam.erl",31}]}.
    {badmatch,{x,0}}.
  {label,16}.
    {line,[{location,"src/dumpbeam.erl",30}]}.
    {badmatch,{x,0}}.
  {label,17}.
    {line,[{location,"src/dumpbeam.erl",29}]}.
    {badmatch,{x,0}}.
  {label,18}.
    {line,[{location,"src/dumpbeam.erl",28}]}.
    {badmatch,{x,0}}.
  {label,19}.
    {line,[{location,"src/dumpbeam.erl",27}]}.
    {badmatch,{x,0}}.


{function, module_info, 0, 21}.
  {label,20}.
    {line,[]}.
    {func_info,{atom,dumpbeam},{atom,module_info},0}.
  {label,21}.
    {move,{atom,dumpbeam},{x,0}}.
    {line,[]}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 23}.
  {label,22}.
    {line,[]}.
    {func_info,{atom,dumpbeam},{atom,module_info},1}.
  {label,23}.
    {move,{x,0},{x,1}}.
    {move,{atom,dumpbeam},{x,0}}.
    {line,[]}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.


{function, '-diffpatch/0-fun-0-', 1, 25}.
  {label,24}.
    {line,[{location,"src/dumpbeam.erl",34}]}.
    {func_info,{atom,dumpbeam},{atom,'-diffpatch/0-fun-0-'},1}.
  {label,25}.
    {test,is_tuple,{f,24},[{x,0}]}.
    {test,test_arity,{f,24},[{x,0},3]}.
    {get_tuple_element,{x,0},1,{x,1}}.
    {get_tuple_element,{x,0},2,{x,0}}.
    {bif,'=/=',{f,0},[{x,1},{x,0}],{x,0}}.
    return.


{function, '-select_receive/3-fun-0-', 1, 27}.
  {label,26}.
    {line,[{location,"src/dumpbeam.erl",23}]}.
    {func_info,{atom,dumpbeam},{atom,'-select_receive/3-fun-0-'},1}.
  {label,27}.
    {allocate,0,0}.
  {label,28}.
    {loop_rec,{f,29},{x,0}}.
    remove_message.
    {move,{atom,true},{x,0}}.
    {deallocate,0}.
    return.
  {label,29}.
    {wait,{f,28}}.


{function, '-dumpregs/0-lc$^0/1-0-', 1, 31}.
  {label,30}.
    {line,[{location,"src/dumpbeam.erl",18}]}.
    {func_info,{atom,dumpbeam},{atom,'-dumpregs/0-lc$^0/1-0-'},1}.
  {label,31}.
    {test,is_nonempty_list,{f,32},[{x,0}]}.
    {allocate_heap,1,2,1}.
    {get_list,{x,0},{x,0},{y,0}}.
    {put_tuple2,{x,0},{list,[{x,0}]}}.
    {line,[{location,"src/dumpbeam.erl",18}]}.
    {call_ext,1,{extfunc,erlang,display,1}}.
    {swap,{y,0},{x,0}}.
    {line,[{location,"src/dumpbeam.erl",18}]}.
    {call,1,{f,31}}.
    {'%',{var_info,{x,0},[{type,{t_list,any,nil}}]}}.
    {test_heap,2,1}.
    {put_list,{y,0},{x,0},{x,0}}.
    {deallocate,1}.
    return.
  {label,32}.
    {test,is_nil,{f,30},[{x,0}]}.
    return.


{function, '-funtobeam/0-fun-0-', 1, 34}.
  {label,33}.
    {line,[{location,"src/dumpbeam.erl",15}]}.
    {func_info,{atom,dumpbeam},{atom,'-funtobeam/0-fun-0-'},1}.
  {label,34}.
    return.
