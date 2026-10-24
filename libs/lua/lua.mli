open Lua_api

val create_vm : unit -> Lua.state
val load_cart : Lua.state -> string -> unit
val call_global : Lua.state -> string -> unit
