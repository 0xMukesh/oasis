open Lua_api

type t = Lua_api_lib.state

let color = ref (Core.Color.to_enum Core.Color.default)
let callbacks = [ "_init"; "_update"; "_draw" ]
let num ls i = LuaL.checknumber ls i
let int_ ls i = num ls i |> int_of_float

let color_ ls i =
  let n = LuaL.optint ls i !color in
  match Core.Color.of_enum n with
  | Some c -> c
  | None -> LuaL.argerror ls i (Printf.sprintf "invalid color index: %d" n)
;;

let l_noop _ = 0

(* pset x y c *)
let l_pset ls =
  let x, y = (int_ ls 1, int_ ls 2) in
  let c = color_ ls 3 in
  Core.pset x y c;
  0
;;

(* pget x y : c *)
let l_pget ls =
  let x, y = (int_ ls 1, int_ ls 2) in
  let c = Core.pget x y in
  let result =
    match c with
    | Some v -> Core.Color.to_enum v
    | None -> 0
  in
  Lua.pushnumber ls (float_of_int result);
  1
;;

(* cls c *)
let l_cls ls =
  let c = color_ ls 1 in
  Core.cls c;
  0
;;

(* color c *)
let l_color ls =
  let arg_index = 1 in
  let c = int_ ls arg_index in
  ( match Core.Color.of_enum c with
    | Some _ -> color := c
    | None ->
      LuaL.argerror ls arg_index (Printf.sprintf "invalid color index: %d" arg_index)
  );
  0
;;

(* line x0 y0 x1 y1 c *)
let l_line ls =
  let x0, y0 = (int_ ls 1, int_ ls 2) in
  let x1, y1 = (int_ ls 3, int_ ls 4) in
  let c = color_ ls 5 in
  Core.line x0 y0 x1 y1 c;
  0
;;

(* rect x0 y0 x1 y1 c *)
(* rect_fill x0 y0 x1 y1 c *)
let l_rect_core ls ~f =
  let x0, y0 = (int_ ls 1, int_ ls 2) in
  let x1, y1 = (int_ ls 3, int_ ls 4) in
  let c = color_ ls 5 in
  f x0 y0 x1 y1 c;
  0
;;

let l_rect ls = l_rect_core ls ~f:Core.rect
let l_rect_fill ls = l_rect_core ls ~f:Core.rect_fill

(* circ x y r c *)
(* circ_fill x y r c *)
let l_circ_core ls ~f =
  let x, y = (int_ ls 1, int_ ls 2) in
  let r = int_ ls 3 in
  let c = color_ ls 4 in
  f x y r c;
  0
;;

let l_circ ls = l_circ_core ls ~f:Core.circ
let l_circ_fill ls = l_circ_core ls ~f:Core.circ_fill

let register_functions ls =
  let functions =
    [ ("pset", l_pset)
    ; ("pget", l_pget)
    ; ("cls", l_cls)
    ; ("color", l_color)
    ; ("line", l_line)
    ; ("rect", l_rect)
    ; ("rect_fill", l_rect_fill)
    ; ("circ", l_circ)
    ; ("circ_fill", l_circ_fill)
    ]
  in
  List.iter (fun (name, f) -> Lua.register ls name f) functions
;;

let register_variables ls =
  let set_int name value =
    Lua.pushinteger ls value;
    Lua.setglobal ls name
  in
  set_int "W" Core.w;
  set_int "H" Core.h;
  for i = Core.Color.min to Core.Color.max do
    let color = Option.get @@ Core.Color.of_enum i in
    let name = String.uppercase_ascii @@ Core.Color.show color in
    set_int name i
  done
;;

let create_vm () =
  let ls = LuaL.newstate () in
  LuaL.openlibs ls;
  register_functions ls;
  register_variables ls;
  ls
;;

let report_err ls =
  let message =
    match Lua.tostring ls (-1) with
    | Some s -> "Lua error: " ^ s
    | None -> "Lua error: failed to retrieve the error message"
  in
  Lua.pop ls 1;
  failwith message
;;

let exec_func ls name =
  Option.iter (Lua.getglobal ls) name;
  match Lua.pcall ls 0 0 0 with
  | Lua.LUA_OK -> ()
  | _ -> report_err ls
;;

let ensure_callback ls name =
  Lua.getglobal ls name;
  if not (Lua.isfunction ls (-1))
  then (
    Lua.pop ls 1;
    Lua.pushcfunction ls l_noop;
    Lua.setglobal ls name
  )
  else Lua.pop ls 1
;;

let load_cart ls path =
  ( match LuaL.loadfile ls path with
    | Lua.LUA_OK -> exec_func ls None
    | _ -> report_err ls
  );
  List.iter (ensure_callback ls) callbacks
;;

let call_init ls = exec_func ls (Some "_init")
let call_update ls = exec_func ls (Some "_update")
let call_draw ls = exec_func ls (Some "_draw")
