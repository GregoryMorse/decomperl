%cd(dir).
%cd(os:getenv("USERPROFILE") ++ "/OneDrive/Documents/Projects/ELTE/erlang").
%c('undecidable.erl').
%undecidable:simple_undecidable().

-module (undecidable).
-export([simple_undecidable/0]).
get_timestamp() ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + round(Micro/1000)
.
simple_undecidable() ->
  case (get_timestamp() band 1) of
    0 -> simple_undecidable() + 1;
    1 -> 0
  end
.
%output: 0, 1165, 0, 2670, 0, 0, 0, 0, 1234, 0, 492, ...
%interestingly shows performance measurement of simple recursion over repeated use of boiler plate band, comparison, recursion and basic OS timestamp function.