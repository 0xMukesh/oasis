open Core
open Lua

let () =
  let vm = Lua.create_vm () in
  Lua.load_cart vm "./examples/demo.lua";
  Lua.call_global vm "_init";
  Renderer.render
    "oasis"
    ~scale:2.0
    ~init:(fun _ -> Lua.call_global vm "_init")
    ~update:(fun _ -> Lua.call_global vm "_update")
    ~draw:(fun _ -> Lua.call_global vm "_draw")
;;
