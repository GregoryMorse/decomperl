%c("src/handasm.S", [from_asm,{outdir,"ebin"}]).

{module, handasm}.

{exports, [{paperrevgraph,5},{module_info,0},{module_info,1}]}.

{attributes, []}.

{labels, 9}.

{function,paperrevgraph,5,2}.
	{label,1}.
		{func_info,{atom,handasm},{atom,paperrevgraph},5}.
	{label,2}.
  	{test,is_eq_exact,{f,3},[{x,0},{atom,true}]}.
		{test,is_eq_exact,{f,4},[{x,1},{atom,true}]}.
  	{call,5,{f,2}}.
  	{call_ext,1,{extfunc,erlang,error,1}}.
	{label,3}.
		{test,is_eq_exact,{f,4},[{x,2},{atom,false}]}.
  	{move,{x,3},{x,0}}.
  	return.
	{label,4}.
  	{move,{x,4},{x,0}}.
  	{call_ext,1,{extfunc,erlang,error,1}}.

{function, module_info, 0, 6}.
  {label,5}.
    {func_info,{atom,handasm},{atom,module_info},0}.
  {label,6}.
    {move,{atom,handasm},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 8}.
  {label,7}.
    {func_info,{atom,handasm},{atom,module_info},1}.
  {label,8}.
    {move,{x,0},{x,1}}.
    {move,{atom,handasm},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
