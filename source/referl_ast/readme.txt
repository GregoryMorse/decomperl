Download and install latest Erlang OTP service release: https://www.erlang.org/downloads
Grab the latest Source File (e.g. http://erlang.org/download/otp_src_20.3.tar.gz)
Extract lib/compiler/test from the .tar.gz to user profile Downloads folder (e.g. Downloads/otp_src_20.3/test).

On Windows:
Anywhere in build.rules in tool folder where code:root_dir() is used, must surround expression result with case os:type() of {win32, _} -> "\""; {unix, _} -> "" end ++ ... case os:type() of {win32, _} -> "\""; {unix, _} -> "" end
SET Path=%PATH%;%ProgramFiles(x86)%\CodeBlocks\MinGW\bin
SET ERL=%ProgramFiles%\erl9.3\bin\erl.exe
cd /d d:\Source\Repos\refactorerl\branches\morse\master\tool
SET C_COMPILER=C:\Program Files (x86)\CodeBlocks\MinGW\bin\gcc.exe
SET CPP_COMPILER=C:\Program Files (x86)\CodeBlocks\MinGW\bin\g++.exe
SET COMPILE_CPP=true
SET VF2=true
REM many quotes to surround library and include paths for C compiler needed on Windows, because of TODO regarding BOOST it will not compile
bin\referl.bat -build tool


%%Compilation instructions for decompiler:
%%Preferred to create and keep output in a temporary folder:
%%c("decomp.erl", [{outdir, "temp"}]). code:add_path("temp").
%%c("decomptest.erl", [debug_info,{outdir, "temp"}]).
%%c("semequiv.erl", [debug_info,{outdir, "temp"}]).
%%Note debug_info required for decomptest and seqequiv modules both doing semantic equivalence checks or providing AST code.

%%Emulator: c("emulator.erl", [{outdir, "temp"}]).



Usage of decomp.erl:

Decompile directory:
decomp:decomp_dir(DirName, Recurse, OutDirName, [Options...]).
DirName is string for directory name, Recurse is true for recursive, false for only specified directory,
OutDirName is output directory, or base output directory when recursive, Options are described below.

Decompile module:
decomp:decompile(ModName, OutputFileName, [Options...]).
ModName is atom for module name/string for module BEAM path, OutputFileName is string for output .erl file,
Options include following atoms:
writeast - write OutputFileName with .erl extension replaced by .ast containing the decompiled AST.
bfsscan - use Breath First Scanning mode as opposed to default Sequential Scanning.
compile - compile the output erlang file.
stubfuncs - do not write semantic equivalent receive and binaries functions, but use a stub instead (much smaller AST and code, but will not compile).
optimize - apply clean up micro-refactoring optimizations.
progress - show BEAM instructions as a progress indicator while decompiling.
dotfile - write DOT files at each merge point giving a visual control flow graph output (slow).
dot2tex - include with dotfile if desiring the DOT file to contain a tex dot2tex extension compatible format.
changemodname - change module name in output AST and ERL files to match OutputFileName without .erl extension.
nosanitycheck - do not perform certain graph and AST consistency checks for better performance only.

Statistics in OutputFileName with .stat extension always generated containing the statistics for all functions.
Format of statistics file:
[{Funcname,Arity,LambdaMap,
     {Test, SVal, STA, Trys, Catchs, Rcvs, Jmps, Calls, Exits, LnLo, LnHi},
     Time}...]
LambdaMap contains the function itself and all its fun expressions individually in format:
{N, RN, E, RE, C, CN, CE, CRE, MD, AD}
Key: #Mod=Modules, #Func=Functions, #lambda=Total fun expressions, N=Total Graph Nodes, RN=Total Nodes in Return Reaching Set, E=Total Graph Edges, RE=Total Reverse Graph Edges, C=Total Subgraph Code Copies, CN=Total Nodes added from Subgraph Copies, CE=Total Edges added from Subgraph Copies, CRE=Total Reverse Graph Edges added from Subgraph Copies, MD=Maximum Control Flow Structure Depth, AD=Aggregated Weighted Control Flow Structure Depth, Te=test, SV=select_val, ST=select_tuple_arity, Tr=try, Ca=catch, R=receive, J=jump, Cl=call*/apply*, Ex=Exit opcodes, #LoC=Lines of code, LL=First line number based on BEAM, LH=Last line number based on BEAM.

Errors in decompilation, pretty printing (both should not occur), recompilation (if compile option set) written in OutputFileName with .err extension.

Decompile single function in module:
decomp:decompile(ModName, FuncName, Arity, OutputFileName, [Options...]).
ModName is atom for module name/string for module BEAM path, FuncName is atom for function name,
Arity is integer for function arity, OutputFileName is string for output .erl file,
Options include same as above, Statistics and Errors same as above.

Create a readable BEAM dump:
decomp:disassemble(OutputFileName, ModName).
OutputFileName is string for output .beamasm file, ModName is atom for module name/string for module BEAM path.

Create original readable AST dump from BEAM (debug_info must have been turned on):
decomp:getabstractsyntax(ModName, OutputFileName).
OutputFileName is string for output .ast file, ModName is atom for module name/string for module BEAM path.

Create original pretty-printed source code from BEAM (debug_info must have been turned on):
decomp:transform(ModName, OutputFileName).
ModName is atom for module name/string for module BEAM path, OutputFileName is string for output .erl file.


Erlang OTP compiler suite code assumed at OS environment variable OTPCOMPTEST (e.g. define for Windows SET OTPCOMPTEST=%USERPROFILE%/Downloads/otp_src_20.3/test").
Decompilation options fixed for following library functions.
Source must be modified if using different paths or different default options.

Decompile all Erlang libraries:
decomp:decomp_all_lib().

Decompile single Erlang library:
decomp:decomp_lib(LibName). LibName is atom for library name.

Decompile single module from Erlang library (ebin folder only):
decomp:decomp_lib(LibName, ModName).
LibName is string for library name, ModName is string for module name.

Decompile single function of module from Erlang library (ebin folder only):
decomp_lib(LibName, ModName, FuncName, Arity).
LibName is string for library name, ModName is string for module name,
FuncName is atom for function name, Arity is integer for function arity.

Decompile all compiler test suite modules:
decomp:decomp_otp().

Decompile one module from compiler test suite:
decomp:decomp_otp(ModName). ModName is string for module name.

decomp:decomp_otp(ModName, FuncName, Arity). ModName is string for module name,
FuncName is atom for function name, Arity is integer for function arity.

Decompile the decompiler/emulator modules (all must be compiled first):
decomp:decompdecomp().


After successfully running commands to decompile all Erlang libraries and all of the compiler test suite modules:
(See Key in Statistics file description).

Produce tex file tabular snippet library statistics:
decomp:lib_stats_to_tex().
Format: Library, #Mod, #Func, Runtime(s), #lambda, N, RN, E, RE, C, CN, CE, CRE, MD, AD
Format: Library, Te, SV, ST, Tr, Ca, R, J, Cl, Ex, #LoC

Produce tex file tabular snippet 50 slowest sorted module statistics:
decomp:mtime_stats_to_tex().

Produce tex file tabular snippet 50 slowest sorted function statistics:
decomp:ftime_stats_to_tex().
Format: Library, Module, Function, Arity, Runtime(s), #lambda, N, RN
Format: E, RE, C, CN, CE, CRE, MD, AD, Te, SV, ST, Tr, Ca, R, J, Cl, Ex, LL, LH

Produce TSV (tab separated values) statistics for plotting tool (e.g. tex pgfplots) for 50 slowest sorted functions:
decomp:ftime_stats_to_plotdata().
Format: Time N SE LC
Format: Time MD AD



Usage of emulator.erl:

Must pre-compile any modules to be emulated into BEAM code (e.g. c:c(ModName)).  If reloading modules, should take care to purge the code (e.g. code:purge(ModName)) and make sure hot-swapping is not keeping old functions in memory.

Emulating a module's function:
emulator:emulate(module_name, function_name, [FunctionArgs...]).

Emulating the emulator which emulates a module's function:
emulator:emulate(emulator, emulate, [module_name, function_name, [FunctionArgs...]]).
emulator:emulate(emulator, emulate, [emulator, emulate, [module_name, function_name, [FunctionArgs...]]]).



Example after compilation:
c:c("calcpi.erl", [{outdir, "temp"}]).
emulator:emulate(calcpi, calc_pi, [1, true, 10]).
decomp:decompile("temp/calcpi", "temp/calcpi.erl", []).
decomp:decompile("temp/calcpi", "temp/calcpinew.erl", [optimize,changemodname,compile,writeast,dotfile,progress]).


recv_eval note (paper/research workflow):
Use src/recv_eval.S as the hand-crafted assembly artifact.
src/recv_eval.erl is the Dialyzer-oriented stub companion; OTP 28 updates only required fixing its -spec syntax.
Equivalent runtime generation logic is in src/em.erl ('receive'/1 and 'receive'/3) using compile:forms(..., [binary, from_asm]).