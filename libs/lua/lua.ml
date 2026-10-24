open Lua_api

let num ls i = LuaL.checknumber ls i
let int_ ls i = num ls i |> int_of_float

let color_ ls i =
  let n = int_ ls i in
  match Core.Color.of_enum n with
  | Some c -> c
  | None -> LuaL.argerror ls i (Printf.sprintf "invalid color index: %d" i)
;;

let l_line ls =
  let x0, y0 = (int_ ls 1, int_ ls 2) in
  let x1, y1 = (int_ ls 3, int_ ls 4) in
  let color = color_ ls 5 in
  Core.line x0 y0 x1 y1 color;
  0
;;

let register_api ls =
  let api = [ ("line", l_line) ] in
  List.iter
    (fun (name, f) ->
       Lua.pushcfunction ls f;
       Lua.setglobal ls name
     )
    api
;;

let create_vm () =
  let ls = LuaL.newstate () in
  LuaL.openlibs ls;
  register_api ls;
  ls
;;

let report_err ls =
  match Lua.tostring ls (-1) with
  | Some s ->
    Lua.pop ls 1;
    prerr_endline ("Lua error: " ^ s)
  | None -> prerr_endline "Error: Failed to retrieve the error message"
;;

let load_cart ls path =
  match LuaL.loadfile ls path with
  | Lua.LUA_OK ->
    ( match Lua.pcall ls 0 0 0 with
      | Lua.LUA_OK -> ()
      | _ -> report_err ls
    )
  | _ -> report_err ls
;;

let call_global ls name =
  Lua.getglobal ls name;
  if Lua.isfunction ls (-1)
  then (
    match Lua.pcall ls 0 0 0 with
    | Lua.LUA_OK -> ()
    | _ -> report_err ls
  )
  else Lua.pop ls 1
;;
