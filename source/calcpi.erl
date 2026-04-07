-module(calcpi).
-export([calc_pi/3]).
calc_pi(D, Pos, Lim) ->
	if
		Lim == 0 -> 0;
		Pos == true -> (4 / D) + calc_pi(D + 2, false, Lim - 1);
		true -> (-4 / D) + calc_pi(D + 2, true, Lim - 1)
	end
.
%c("calcpi.erl").
%calcpi:calc_pi(1, true, 10000000).
