-module(dec).
-export([set/0, bld/0]).
set() ->
	os:set_env_var("OTPSOURCEPATH", os:getenv("USERPROFILE") ++ "/Desktop/Apps/otp-OTP-23.0"),
	filelib:ensure_dir("ebin/"),
	filelib:ensure_dir("temp/"),
	c:c("src/semequiv.erl", [debug_info,{outdir, "ebin"}]),
	bld(),
	code:add_path("ebin").
	
bld() -> c:c("src/decomp.erl", [{outdir, "ebin"}]).