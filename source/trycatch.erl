%https://github.com/erlang/otp/blob/master/lib/compiler/src/beam_jump.erl - repeated instruction sequence ending in transfer instruction, Short sequences starting with a label and ending in case_end, if_end, and badmatch, and function calls that cause an exit (such as calls to exit/1) are moved to the end of the function, but only if the the block is not entered via a fallthrough.
%https://github.com/erlang/otp/blob/master/lib/compiler/src/beam_clean.erl - is_record_tuple maybe
%https://github.com/erlang/otp/blob/master/lib/compiler/src/beam_type.erl - =:=
-module(trycatch).
-compile(export_all).

err1() -> 1 / 0.

err2() -> length(1).

err3() -> lists:max([]).

normaltry() ->
	try
		true
	catch
		_:_ -> error
	after
		io:format("after1~n")
	end.
	
normalcatch() ->
	try
		err1(), true
	catch
		_:_ -> error
	after
		io:format("after1~n")
	end.
	
aftererror() ->
	try
		err1(), true
	catch
		_:_ -> error
	after
		io:format("after1~n"), err2(), io:format("after2~n")
	end.

aftererrorcatch() ->
	try
		try
			err1(), true
		catch
			_:_ -> io:format("catch1~n"), error
		after
			io:format("after1~n"), err2(), io:format("after2~n")
		end
	catch
		_:_ -> io:format("catch2~n"), error
	after
		io:format("after3~n")
	end.
	
aftercatcherrorcatch() ->
	try
		try
			err1(), true
		catch
			_:_ -> io:format("catch1~n"), err2(), error
		after
			io:format("after1~n"), err2(), io:format("after2~n")
		end
	catch
		_:_ -> io:format("catch2~n"), error
	after
		io:format("after3~n")
	end.
	
%try exps catch exp after exp

%catch exps