{module, dumpbeam}.  %% version = 0

{exports, [{dumpbinmatch,0},
           {dumpregs,0},
           {module_info,0},
           {module_info,1},
           {select_receive,1}]}.

{attributes, []}.

{labels, 21}.


{function, dumpregs, 0, 2}.
  {label,1}.
    {line,[{location,"dumpbeam.erl",14}]}.
    {func_info,{atom,dumpbeam},{atom,dumpregs},0}.
  {label,2}.
    {allocate,0,0}.
    {move,{integer,1023},{x,1}}.
    {move,{integer,0},{x,0}}.
    {line,[{location,"dumpbeam.erl",15}]}.
    {call_ext,2,{extfunc,lists,seq,2}}.
    {call_last,1,{f,19},0}.


{function, dumpbinmatch, 0, 4}.
  {label,3}.
    {line,[{location,"dumpbeam.erl",17}]}.
    {func_info,{atom,dumpbeam},{atom,dumpbinmatch},0}.
  {label,4}.
    {move,{literal,<<3,4,5>>},{x,0}}.
    {test,bs_start_match2,{f,5},1,[{x,0},0],{x,1}}.
    {test,bs_test_tail2,{f,5},[{x,1},16]}.
    {test_heap,2,1}.
    {put_tuple,1,{x,1}}.
    {put,{x,0}}.
    {move,{x,1},{x,0}}.
    {line,[{location,"dumpbeam.erl",18}]}.
    {call_ext_only,1,{extfunc,erlang,display,1}}.
  {label,5}.
    {line,[{location,"dumpbeam.erl",18}]}.
    {badmatch,{x,0}}.


{function, select_receive, 1, 7}.
  {label,6}.
    {func_info,{atom,dumpbeam},{atom,select_receive},1}.
  {label,7}.
    {allocate_zero,2,1}.
    {move,{x,0},{y,1}}.
    {make_fun2,{f,15},0,0,0}.
    {move,{x,0},{y,0}}.
  {label,8}.
    {loop_rec,{f,9},{x,0}}.
    {move,{y,1},{x,2}}.
    {move,{y,0},{x,1}}.
    {call_fun,2}.
    {deallocate,2}.
    return.
  {label,9}.
    {wait,{f,8}}.


{function, module_info, 0, 11}.
  {label,10}.
    {line,[]}.
    {func_info,{atom,dumpbeam},{atom,module_info},0}.
  {label,11}.
    {move,{atom,dumpbeam},{x,0}}.
    {line,[]}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 13}.
  {label,12}.
    {line,[]}.
    {func_info,{atom,dumpbeam},{atom,module_info},1}.
  {label,13}.
    {move,{x,0},{x,1}}.
    {move,{atom,dumpbeam},{x,0}}.
    {line,[]}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.


{function, '-select_receive/1-fun-0-', 1, 15}.
  {label,14}.
    {func_info,{atom,dumpbeam},{atom,'-select_receive/1-fun-0-'},1}.
  {label,15}.
    remove_message.
    return.


{function, '-dumpregs/0-lc$^0/1-0-', 1, 19}.
  {label,18}.
    {line,[{location,"dumpbeam.erl",15}]}.
    {func_info,{atom,dumpbeam},{atom,'-dumpregs/0-lc$^0/1-0-'},1}.
  {label,19}.
    {test,is_nonempty_list,{f,20},[{x,0}]}.
    {allocate_heap,1,2,1}.
    {get_list,{x,0},{x,1},{y,0}}.
    {put_tuple,1,{x,0}}.
    {put,{x,1}}.
    {line,[{location,"dumpbeam.erl",15}]}.
    {call_ext,1,{extfunc,erlang,display,1}}.
    {move,{x,0},{x,1}}.
    {move,{y,0},{x,0}}.
    {move,{x,1},{y,0}}.
    {line,[{location,"dumpbeam.erl",15}]}.
    {call,1,{f,19}}.
    {test_heap,2,1}.
    {put_list,{y,0},{x,0},{x,0}}.
    {deallocate,1}.
    return.
  {label,20}.
    {test,is_nil,{f,18},[{x,0}]}.
    return.
