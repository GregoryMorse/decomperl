%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2013-2017. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%
{module, recv_eval}.

%% This module uses low-level BEAM instructions for the message queue facility
%% to allow erl_eval to evaluate receive expressions correctly.

%cd(os:getenv("USERPROFILE") ++ "/source/repos/refactorerl/branches/morse/master/tool/lib/referl_ast").
%compile:file("recv_eval.S", [from_asm]).
%{ok, recv_eval, Bin} = compile:file("recv_eval.S", [from_asm,to_asm,binary]).
%lists:filter(fun (El) -> El =/= 10 andalso El =/= 32 end, lists:flatten(io_lib:format("~p", [Bin]))).
%{ok, recv_eval, CplBin} = compile:forms(Bin, [binary, from_asm]).
%code:load_binary(recv_eval, [], CplBin).
%emulator:disassemble("recv_eval.beamasm", "recv_eval").
%recv_eval:'receive'(fun(M, Cb) -> false end, 1000, fun() -> nomatch end).
%self() ! match, recv_eval:'receive'(fun(M, Cb) -> if M =:= match -> Cb(M), {true, M} end end).
%self() ! match, recv_eval:'receive'(fun(M, Cb) -> if M =:= match -> Cb(M), {true, M} end end, infinity, fun() -> nomatch end).

%{exports, [{'receive',1},{'receive',3},{module_info,0},{module_info,1}]}.
{exports, [{'receive',1},{module_info,0},{module_info,1}]}.
%{exports, [{'receive',3},{module_info,0},{module_info,1}]}.

{attributes, []}.

{labels, 16}.

% {function, 'receive', 3, 2}.
  % {label,1}.
    % {func_info,{atom,recv_eval},{atom,'receive'},3}.
  % {label,2}.
    % {allocate,4,4}.
    % {move,{x,2},{y,3}}.
    % {move,{x,1},{y,0}}.
    % {move,{x,0},{y,1}}.
    % {make_fun2,{f,15},0,0,0}.
    % {move,{x,0},{y,2}}.
    % %% Call arg_reg_alloc() in order to ensure
    % %% that def_arg_reg[0] isn't clobbered
    % {call,0,{f,7}}.
  % {label,3}.
    % {loop_rec,{f,5},{x,0}}.
    % {move,{y,2},{x,1}}.
    % {move,{y,1},{x,2}}.
    % {call_fun,2}.
    % %{test,is_ne_exact,{f,4},[{x,0},{atom,false}]}.
    % {test,is_tagged_tuple,{f,4},[{x,0},2,{atom,true}]}.
    % {get_tuple_element,{x,0},1,{x,0}}.
    % {deallocate,4}.
    % return.
  % {label,4}.
    % {loop_rec_end,{f,3}}.
  % {label,5}.
    % {wait_timeout,{f,3},{y,0}}.
    % timeout.
    % {move,{y,3},{x,0}}.
    % {call_fun,0}.
    % {deallocate,4}.
    % return.

{function, 'receive', 1, 2}.
  {label,1}.
    {func_info,{atom,recv_eval},{atom,'receive'},1}.
  {label,2}.
    {allocate,2,2}.
    {move,{x,0},{y,1}}.
    {make_fun2,{f,15},0,0,0}.
    {move,{x,0},{y,0}}.
    %% Call arg_reg_alloc() in order to ensure
    %% that def_arg_reg[0] isn't clobbered
    {call,0,{f,7}}.
  {label,3}.
    {loop_rec,{f,5},{x,0}}.
    {move,{y,0},{x,1}}.
    {move,{y,1},{x,2}}.
    {call_fun,2}.
    %{test,is_ne_exact,{f,4},[{x,0},{atom,false}]}.
    {test,is_tagged_tuple,{f,4},[{x,0},2,{atom,true}]}.
    {get_tuple_element,{x,0},1,{x,0}}.
    {deallocate,2}.
    return.
  {label,4}.
    {loop_rec_end,{f,3}}.
  {label,5}.
    {wait,{f,3}}.

{function, arg_reg_alloc, 0, 7}.
  {label,6}.
    {func_info,{atom,recv_eval},{atom,arg_reg_alloc},0}.
  {label,7}.
    {allocate,0,0}.
    {move,{integer,134217727},{x,0}}.
    {call_ext,1,{extfunc,erlang,bump_reductions,1}}.
    {move,{atom,true},{x,3}}.
    {move,{atom,true},{x,4}}.
    {move,{atom,true},{x,2}}.
    {move,{atom,true},{x,5}}.
    {move,{atom,true},{x,1}}.
    {move,{atom,true},{x,6}}.
    {move,{atom,true},{x,0}}.
    {call_last,7,{f,9},0}.


{function, arg_reg_alloc, 7, 9}.
  {label,8}.
    {func_info,{atom,recv_eval},{atom,arg_reg_alloc},7}.
  {label,9}.
    {move,{atom,ok},{x,0}}.
    return.


{function, module_info, 0, 11}.
  {label,10}.
    {func_info,{atom,recv_eval},{atom,module_info},0}.
  {label,11}.
    {move,{atom,recv_eval},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.


{function, module_info, 1, 13}.
  {label,12}.
    {func_info,{atom,recv_eval},{atom,module_info},1}.
  {label,13}.
    {move,{x,0},{x,1}}.
    {move,{atom,recv_eval},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.

{function, '-receive/1-fun-0-', 1, 15}.
  {label,14}.
    {func_info,{atom,recv_eval},{atom,'-receive/1-fun-0-'},1}.
  {label,15}.
    remove_message.
    return.