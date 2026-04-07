%c("src/obfusc.S", [from_asm,{outdir,"ebin"}]).
%fun Clear_mailbox() -> receive _Any -> Clear_mailbox() after 0 -> ok end end().
%fun Clear_uid_mailbox(U, N) -> if N =:= 0 -> ok; true -> receive {U, _Any} -> Clear_uid_mailbox(U, N-1) end end end(U, N).

{module, obfusc}.

{exports, [{binary_obfuscation,4},{sum_to_n_loop,1},{merge_sort,1},{module_info,0},{module_info,1}]}.

{attributes, []}.

{labels, 18}.

{function, module_info, 0, 2}.
  {label,1}.
    {func_info,{atom,obfusc},{atom,module_info},0}.
  {label,2}.
    {move,{atom,obfusc},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.

{function, module_info, 1, 4}.
  {label,3}.
    {func_info,{atom,obfusc},{atom,module_info},1}.
  {label,4}.
    {move,{x,0},{x,1}}.
    {move,{atom,obfusc},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.

{function, get_size, 0, 6}.
  {label,5}.
    {func_info,{atom,obfusc},{atom,get_size},0}.
  {label,6}.
    {allocate_zero,1,0}.
    {call_ext,0,{extfunc,erlang,unique_integer,0}}.
    {test_heap,3,1}.
    {bif,self,{f,0},[],{x,1}}.
    {put_tuple2,{x,2},{list,[{x,0},{integer,4}]}}.
    {move,{x,0},{y,0}}.
    {move,{x,1},{x,0}}.
    {move,{x,2},{x,1}}.
    send.
  {label,7}.
    {loop_rec,{f,9},{x,0}}.
    {test,is_tuple,{f,8},[{x,0}]}.
    {test,test_arity,{f,8},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {test,is_eq_exact,{f,8},[{x,1},{y,0}]}.
    {get_tuple_element,{x,0},1,{x,0}}.
    remove_message.
    {deallocate,1}.
    return.
  {label,8}.
    {loop_rec_end,{f,7}}.
  {label,9}.
    {wait,{f,7}}.
	
{function, binary_obfuscation, 4, 11}.
  {label,10}.
    {func_info,{atom,obfusc},{atom,binary_obfuscation},4}.
  {label,11}.
    {allocate,4,4}.
    {move,{x,3},{y,0}}.
    {move,{x,2},{y,1}}.
    {move,{x,1},{y,2}}.
    {move,{x,0},{y,3}}.
    {call,0,{f,6}}.
	{move,{x,0},{x,4}}.
    {bs_init2,{f,0},{x,4},0,0,{field_flags,[]},{x,0}}.
    {bs_put_integer,{f,0},{integer,8},1,{field_flags,[unsigned,big]},{y,3}}.
    {bs_put_integer,{f,0},{integer,8},1,{field_flags,[unsigned,big]},{y,2}}.
    {bs_put_integer,{f,0},{integer,8},1,{field_flags,[unsigned,big]},{y,1}}.
	{move,{integer,0},{x,1}}.
	%{test,is_eq_exact,{f,12},[{y,1},{integer,3}]}.
    {bs_put_integer,{f,0},{integer,8},1,{field_flags,[unsigned,big]},{y,0}}.
    {deallocate,4}.
    return.
  %{label,12}.
    %{bs_put_integer,{f,0},{integer,8},1,{field_flags,[unsigned,big]},{y,3}}.  
    %{deallocate,4}.
    %return.

{function, sum_to_n_loop, 1, 13}.
  {label,12}.
    {func_info,{atom,obfusc},{atom,sum_to_n_loop},1}.
  {label,13}.
	{allocate_heap,5,3,1}.
	{move,{x,0},{y,0}}.
	{move,{integer,0},{y,1}}.
	{bif,self,{f,0},[],{y,2}}.
	{init,{y,3}}.
	{move,{integer,0},{y,4}}.
	{call_ext,0,{extfunc,erlang,unique_integer,0}}.
	{move,{x,0},{y,3}}.
	{put_tuple2,{x,1},{list,[{y,3},{y,0}]}}.
	{move,{y,2},{x,0}}.
	send.
  {label,14}.
    {loop_rec,{f,17},{x,0}}.
    {test,is_tuple,{f,16},[{x,0}]}.
    {test,test_arity,{f,16},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{x,1}}.
    {test,is_eq_exact,{f,16},[{x,1},{y,3}]}.
	{get_tuple_element,{x,0},1,{x,1}}.
    {test,is_eq_exact,{f,15},[{x,1},{atom,true}]}.	
	remove_message.
	{move,{y,3},{x,0}}.
	{move,{y,4},{x,1}}.
	{call,0,{f,19}}.
	{move,{y,1},{x,0}}.
	{deallocate,5}.
    return.
  {label,15}.
	{gc_bif,'+',{f,0},0,[{y,4},{integer,1}],{y,4}}.
	{gc_bif,'+',{f,0},0,[{y,1},{y,0}],{y,1}}.
	{gc_bif,'-',{f,0},0,[{y,0},{integer,1}],{y,0}}.
	{test_heap,3,0}.
	{bif,'=:=',{f,0},[{y,0},{integer,0}],{x,0}}.
	{put_tuple2,{x,1},{list,[{y,3},{x,0}]}}.
	{move,{y,2},{x,0}}.
	send.
  {label,16}.
    {loop_rec_end,{f,14}}.
  {label,17}.
    {wait,{f,14}}.

{function, clear_uid_mailbox, 2, 19}.
  {label,18}.
    {func_info,{atom,obfuscation},{atom,clear_uid_mailbox},2}.
  {label,19}.
    {test,is_eq_exact,{f,20},[{x,1},{integer,0}]}.
    {move,{atom,ok},{x,0}}.
    return.
  {label,20}.
    {allocate,2,2}.
    {move,{x,1},{y,0}}.
    {move,{x,0},{y,1}}.
  {label,21}.
    {loop_rec,{f,23},{x,0}}.
    {test,is_tuple,{f,22},[{x,0}]}.
    {test,test_arity,{f,22},[{x,0},2]}.
    {get_tuple_element,{x,0},0,{x,0}}.
    {test,is_eq_exact,{f,22},[{x,0},{y,1}]}.
    remove_message.
    {gc_bif,'-',{f,0},0,[{y,0},{integer,1}],{x,1}}.
    {move,{y,1},{x,0}}.
    {call_last,2,{f,19},2}.
  {label,22}.
    {loop_rec_end,{f,21}}.
  {label,23}.
    {wait,{f,21}}.
	
{function, do_merge, 8, 25}.
  {label,24}.
    {line,[{location,"src/obfuscation.erl",60}]}.
    {func_info,{atom,obfuscation},{atom,do_merge},8}.
  {label,25}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {'%',{var_info,{x,1},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,3},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,4},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,5},[{type,{t_integer,any}}]}}.
    {bif,'=<',{f,0},[{x,1},{x,4}],{x,8}}.
    {bif,'=<',{f,0},[{x,2},{x,5}],{x,9}}.
    {test,is_eq_exact,{f,26},[{x,9},{atom,true}]}.
    {test,is_eq_exact,{f,28},[{x,8},{atom,true}]}.
    {line,[{location,"src/obfuscation.erl",62}]}.
    {bif,element,{f,0},[{x,1},{x,6}],{x,10}}.
    {line,[{location,"src/obfuscation.erl",62}]}.
    {bif,element,{f,0},[{x,2},{x,7}],{x,11}}.
    {bif,'=<',{f,0},[{x,10},{x,11}],{x,10}}.
    {jump,{f,27}}.
  {label,26}.
    {move,{atom,true},{x,10}}.
  {label,27}.
    {test,is_eq_exact,{f,28},[{x,8},{atom,true}]}.
    {test,is_eq_exact,{f,28},[{x,10},{atom,true}]}.
    {line,[{location,"src/obfuscation.erl",63}]}.
    {bif,element,{f,0},[{x,1},{x,6}],{x,8}}.
    {allocate,7,9}.
    {move,{x,7},{y,0}}.
    {move,{x,6},{y,1}}.
    {move,{x,5},{y,2}}.
    {move,{x,4},{y,3}}.
    {move,{x,3},{y,4}}.
    {move,{x,2},{y,5}}.
    {move,{x,1},{y,6}}.
    {move,{x,0},{x,1}}.
    {move,{x,8},{x,2}}.
    {move,{x,3},{x,0}}.
    {line,[{location,"src/obfuscation.erl",63}]}.
    {call_ext,3,{extfunc,erlang,setelement,3}}.
    {line,[{location,"src/obfuscation.erl",63}]}.
    {gc_bif,'+',{f,0},1,[{y,6},{integer,1}],{x,1}}.
    {line,[{location,"src/obfuscation.erl",63}]}.
    {gc_bif,'+',{f,0},2,[{y,4},{integer,1}],{x,3}}.
    {move,{y,0},{x,7}}.
    {move,{y,1},{x,6}}.
    {move,{y,2},{x,5}}.
    {move,{y,3},{x,4}}.
    {move,{y,5},{x,2}}.
    {call_last,8,{f,25},7}.
  {label,28}.
    {test,is_eq_exact,{f,29},[{x,9},{atom,true}]}.
    {line,[{location,"src/obfuscation.erl",64}]}.
    {bif,element,{f,0},[{x,2},{x,7}],{x,8}}.
    {allocate,7,9}.
    {move,{x,7},{y,0}}.
    {move,{x,6},{y,1}}.
    {move,{x,5},{y,2}}.
    {move,{x,4},{y,3}}.
    {move,{x,3},{y,4}}.
    {move,{x,2},{y,5}}.
    {move,{x,1},{y,6}}.
    {move,{x,0},{x,1}}.
    {move,{x,8},{x,2}}.
    {move,{x,3},{x,0}}.
    {line,[{location,"src/obfuscation.erl",64}]}.
    {call_ext,3,{extfunc,erlang,setelement,3}}.
    {line,[{location,"src/obfuscation.erl",64}]}.
    {gc_bif,'+',{f,0},1,[{y,5},{integer,1}],{x,1}}.
    {line,[{location,"src/obfuscation.erl",64}]}.
    {gc_bif,'+',{f,0},2,[{y,4},{integer,1}],{x,3}}.
    {move,{y,1},{x,6}}.
    {move,{y,2},{x,5}}.
    {move,{y,3},{x,4}}.
    {move,{x,1},{x,2}}.
    {move,{y,0},{x,7}}.
    {move,{y,6},{x,1}}.
    {call_last,8,{f,25},7}.
  {label,29}.
    return.


{function, make_subtuple, 3, 31}.
  {label,30}.
    {line,[{location,"src/obfuscation.erl",66}]}.
    {func_info,{atom,obfuscation},{atom,make_subtuple},3}.
  {label,31}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {'%',{var_info,{x,1},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {allocate,3,3}.
    {move,{x,2},{y,0}}.
    {move,{x,1},{y,1}}.
    {move,{x,0},{y,2}}.
    {move,nil,{x,1}}.
    {move,{x,2},{x,0}}.
    {line,[{location,"src/obfuscation.erl",66}]}.
    {call_ext,2,{extfunc,erlang,make_tuple,2}}.
    {move,{integer,1},{x,3}}.
    {move,{y,0},{x,4}}.
    {move,{y,1},{x,2}}.
    {move,{y,2},{x,1}}.
    {call_last,5,{f,33},3}.


{function, subtuple, 5, 33}.
  {label,32}.
    {line,[{location,"src/obfuscation.erl",67}]}.
    {func_info,{atom,obfuscation},{atom,subtuple},5}.
  {label,33}.
    %{'%',{var_info,{x,1},[{type,{t_tuple,0,false,#{}}}]}}.
	{'%',{var_info,{x,0},[{type,{t_tuple,{x,3},false,#{}}}]}}.
	{'%',{var_info,{x,1},[{type,{t_tuple,{x,2},false,#{}}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,3},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,4},[{type,{t_integer,any}}]}}.
    {test,is_eq_exact,{f,34},[{x,4},{integer,0}]}.
    return.
  {label,34}.
    {line,[{location,"src/obfuscation.erl",68}]}.
	%{gc_bif,'-',{f,0},5,[{x,2},{integer,0}],{x,5}}.
	%{move,{x,2},{x,5}}.
    {bif,element,{f,0},[{x,2},{x,1}],{x,5}}.
	%{get_tuple_element,{x,1},{x,2},{x,5}}.
    {allocate,4,6}.
    {move,{x,4},{y,0}}.
    {move,{x,3},{y,1}}.
    {move,{x,2},{y,2}}.
    {move,{x,1},{y,3}}.
    {move,{x,0},{x,1}}.
    {move,{x,5},{x,2}}.
    {move,{x,3},{x,0}}.
    {line,[{location,"src/obfuscation.erl",68}]}.
    {call_ext,3,{extfunc,erlang,setelement,3}}.
	%{set_tuple_element,{x,5},{x,0},{x,3}}.
    {line,[{location,"src/obfuscation.erl",68}]}.
    {gc_bif,'+',{f,0},1,[{y,2},{integer,1}],{x,1}}.
    {line,[{location,"src/obfuscation.erl",68}]}.
    {gc_bif,'+',{f,0},2,[{y,1},{integer,1}],{x,2}}.
    {line,[{location,"src/obfuscation.erl",68}]}.
    {gc_bif,'-',{f,0},3,[{y,0},{integer,1}],{x,4}}.
    {move,{x,2},{x,3}}.
    {move,{x,1},{x,2}}.
    {move,{y,3},{x,1}}.
    {call_last,5,{f,33},4}.


{function, merge, 4, 36}.
  {label,35}.
    {line,[{location,"src/obfuscation.erl",69}]}.
    {func_info,{atom,obfuscation},{atom,merge},4}.
  {label,36}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {'%',{var_info,{x,1},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,3},[{type,{t_integer,any}}]}}.
    {line,[{location,"src/obfuscation.erl",70}]}.
    {gc_bif,'-',{f,0},4,[{x,2},{x,1}],{x,4}}.
    {line,[{location,"src/obfuscation.erl",70}]}.
    {gc_bif,'+',{f,0},5,[{x,4},{integer,1}],{x,4}}.
    {line,[{location,"src/obfuscation.erl",71}]}.
    {gc_bif,'-',{f,0},5,[{x,3},{x,2}],{x,3}}.
    {allocate,5,5}.
    {move,{x,3},{y,0}}.
    {move,{x,4},{y,1}}.
    {move,{x,2},{y,2}}.
    {move,{x,1},{y,3}}.
    {move,{x,0},{y,4}}.
    {move,{x,4},{x,2}}.
    {line,[{location,"src/obfuscation.erl",75}]}.
    {call,3,{f,31}}.
    {line,[{location,"src/obfuscation.erl",75}]}.
    {gc_bif,'+',{f,0},1,[{y,2},{integer,1}],{x,1}}.
    {move,{y,0},{x,3}}.
    {move,{x,0},{y,2}}.
    {move,{y,4},{x,0}}.
    {move,{x,3},{x,2}}.
    {line,[{location,"src/obfuscation.erl",75}]}.
    {call,3,{f,31}}.
    {move,{y,0},{x,5}}.
    {move,{y,1},{x,4}}.
    {move,{y,3},{x,3}}.
    {move,{integer,1},{x,2}}.
    {move,{y,2},{x,6}}.
    {move,{integer,1},{x,1}}.
    {move,{x,0},{x,7}}.
    {move,{y,4},{x,0}}.
    {call_last,8,{f,25},5}.


{function, merge_sort, 1, 38}.
  {label,37}.
    {line,[{location,"src/obfuscation.erl",77}]}.
    {func_info,{atom,obfuscation},{atom,merge_sort},1}.
  {label,38}.
    {line,[{location,"src/obfuscation.erl",77}]}.
    {bif,tuple_size,{f,0},[{x,0}],{x,2}}.
    {move,{integer,1},{x,1}}.
    {call_only,3,{f,40}}.


{function, merge_sort, 3, 40}.
  {label,39}.
    {line,[{location,"src/obfuscation.erl",78}]}.
    {func_info,{atom,obfuscation},{atom,merge_sort},3}.
  {label,40}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {'%',{var_info,{x,1},[{type,{t_integer,any}}]}}.
    {'%',{var_info,{x,2},[{type,{t_integer,any}}]}}.
    {test,is_lt,{f,41},[{x,1},{x,2}]}.
    {line,[{location,"src/obfuscation.erl",80}]}.
    {gc_bif,'-',{f,0},3,[{x,2},{integer,1}],{x,3}}.
    {line,[{location,"src/obfuscation.erl",80}]}.
    {gc_bif,'+',{f,0},4,[{x,1},{x,3}],{x,3}}.
    {line,[{location,"src/obfuscation.erl",80}]}.
    {gc_bif,'bsr',{f,0},4,[{x,3},{integer,1}],{x,3}}.
    {allocate,3,4}.
    {move,{x,3},{y,0}}.
    {move,{x,2},{y,1}}.
    {move,{x,1},{y,2}}.
    {move,{x,3},{x,2}}.
    {line,[{location,"src/obfuscation.erl",81}]}.
    {call,3,{f,40}}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {line,[{location,"src/obfuscation.erl",81}]}.
    {gc_bif,'+',{f,0},1,[{y,0},{integer,1}],{x,1}}.
    {move,{y,1},{x,2}}.
    {line,[{location,"src/obfuscation.erl",81}]}.
    {call,3,{f,40}}.
    {'%',{var_info,{x,0},[{type,{t_tuple,0,false,#{}}}]}}.
    {move,{y,0},{x,2}}.
    {move,{y,1},{x,3}}.
    {move,{y,2},{x,1}}.
    {call_last,4,{f,36},3}.
  {label,41}.
    return.
