open Lua_api
open Core

type t = Lua_api_lib.state

exception Lua_error of string

let init, update, draw = ("Init", "Update", "Draw")

(* -- UTILITY FUNCTIONS -- *)
let where_prefix ls level =
  LuaL.where ls level;
  let s =
    match Lua.tostring ls (-1) with
    | Some s -> s
    | None -> ""
  in
  Lua.pop ls 1;
  s
;;

let arg_error ls i msg =
  let pos = where_prefix ls 1 in
  raise (Lua_error (Printf.sprintf "%sbad argument #%d: %s" pos i msg))
;;

let got ls i = Lua.typename ls (Lua.type_ ls i)

let read_num ls i =
  if Lua.isnumber ls i
  then Lua.tonumber ls i
  else arg_error ls i (Printf.sprintf "number expected, got %s" (got ls i))
;;

let read_int ls i = read_num ls i |> int_of_float

let read_bool ls i =
  if Lua.isboolean ls i
  then Lua.toboolean ls i
  else arg_error ls i (Printf.sprintf "boolean expected, got %s" (got ls i))
;;

let read_color ls i =
  let pen_color = Color.int_of_packed_color Core.Graphics.pen_color in
  let lc = LuaL.optint ls i pen_color in
  Color.packed_color_of_int lc
;;

let read_list ls i =
  let n = Lua.objlen ls i in
  List.init n (fun j ->
    Lua.rawgeti ls i (j + 1);
    let value = Lua.tonumber ls (-1) in
    Lua.pop ls 1;
    value
  )
;;

type 'a number_ops =
  { read : Lua_api_lib.state -> int -> 'a
  ; push : Lua_api_lib.state -> 'a -> unit
  }

let lua_int_ops : int number_ops = { read = read_int; push = Lua.pushinteger }
let lua_float_ops : float number_ops = { read = read_num; push = Lua.pushnumber }

let unary ops f ls =
  let x = ops.read ls 1 in
  ops.push ls (f x);
  1
;;

let binary ops f ls =
  let x = ops.read ls 1 in
  let y = ops.read ls 2 in
  ops.push ls (f x y);
  1
;;

let ternary ops f ls =
  let x = ops.read ls 1 in
  let y = ops.read ls 2 in
  let z = ops.read ls 3 in
  ops.push ls (f x y z);
  1
;;

let l_noop _ = 0

(* -- DRAW STATE -- *)
(* color c *)
let l_color ls =
  let c = read_color ls 1 in
  Graphics.set_color c.primary c.secondary;
  0
;;

(* fillp p [t] *)
let l_fillp ls =
  let p = read_int ls 1 in
  let t = if Lua.gettop ls = 1 then false else read_bool ls 2 in
  Graphics.set_fill_pattern p t;
  0
;;

(* -- GRAPHICS -- *)
(* cls [c] *)
let l_cls ls =
  let c = read_color ls 1 in
  Graphics.cls c.primary;
  0
;;

(* pset x y [c] *)
let l_pset ls =
  let x, y = (read_int ls 1, read_int ls 2) in
  let c = read_color ls 3 in
  Graphics.pset x y c;
  0
;;

(* pget x y : c *)
let l_pget ls =
  let x, y = (read_int ls 1, read_int ls 2) in
  let c = Graphics.pget x y in
  let result = Color.to_enum c in
  Lua.pushnumber ls (float_of_int result);
  1
;;

(* line x0 y0 x1 y1 [c] *)
let l_line ls =
  let x0, y0 = (read_int ls 1, read_int ls 2) in
  let x1, y1 = (read_int ls 3, read_int ls 4) in
  let c = read_color ls 5 in
  Graphics.line x0 y0 x1 y1 c;
  0
;;

(* rect x0 y0 x1 y1 [c] *)
(* rect_fill x0 y0 x1 y1 [c] *)
let l_rect_core ls ~f =
  let x0, y0 = (read_int ls 1, read_int ls 2) in
  let x1, y1 = (read_int ls 3, read_int ls 4) in
  let c = read_color ls 5 in
  f x0 y0 x1 y1 c;
  0
;;

let l_rect ls = l_rect_core ls ~f:Graphics.rect
let l_rect_fill ls = l_rect_core ls ~f:Graphics.rect_fill

(* circ x y r [c] *)
(* circ_fill x y r [c] *)
let l_circ_core ls ~f =
  let x, y = (read_int ls 1, read_int ls 2) in
  let r = read_int ls 3 in
  let c = read_color ls 4 in
  f x y r c;
  0
;;

let l_circ ls = l_circ_core ls ~f:Graphics.circ
let l_circ_fill ls = l_circ_core ls ~f:Graphics.circ_fill

(* -- MATH -- *)
let l_min ls = binary lua_float_ops Math.min ls
let l_max ls = binary lua_float_ops Math.max ls
let l_mid ls = ternary lua_float_ops Math.mid ls
let l_abs ls = unary lua_float_ops Math.abs ls
let l_floor ls = unary lua_float_ops Math.floor ls
let l_ceil ls = unary lua_float_ops Math.ceil ls
let l_sin ls = unary lua_float_ops Math.sin ls
let l_cos ls = unary lua_float_ops Math.cos ls
let l_atan2 ls = binary lua_float_ops Math.atan2 ls

(* rnd / rnd limit / rnd table *)
let l_rnd ls =
  if Lua.gettop ls = 0
  then (
    Lua.pushnumber ls (Math.rnd 1.0);
    1
  )
  else if Lua.isnumber ls (-1)
  then unary lua_float_ops Math.rnd ls
  else if Lua.istable ls (-1)
  then (
    let l = read_list ls 1 in
    let result = Math.rnd_list l in
    Lua.pushnumber ls result;
    1
  )
  else arg_error ls 1 "argument can be either a number or table"
;;

let l_srnd ls =
  let seed = read_int ls 1 in
  Math.srnd seed;
  0
;;

let l_sqrt ls = unary lua_float_ops Math.sqrt ls
let l_sgn ls = unary lua_float_ops Math.sgn ls
let l_band ls = binary lua_int_ops Math.band ls
let l_bor ls = binary lua_int_ops Math.bor ls
let l_bxor ls = binary lua_int_ops Math.bxor ls
let l_shl ls = binary lua_int_ops Math.shl ls
let l_lshr ls = binary lua_int_ops Math.lshr ls
let l_ashr ls = binary lua_int_ops Math.ashr ls
let l_rotl ls = binary lua_int_ops Math.rotl ls
let l_rotr ls = binary lua_int_ops Math.rotr ls

(* -- CORE FUNCTIONS -- *)
let register_functions ls =
  let functions =
    [ ("color", l_color)
    ; ("fillp", l_fillp)
    ; ("pset", l_pset)
    ; ("pget", l_pget)
    ; ("cls", l_cls)
    ; ("line", l_line)
    ; ("rect", l_rect)
    ; ("rect_fill", l_rect_fill)
    ; ("circ", l_circ)
    ; ("circ_fill", l_circ_fill)
    ; ("min", l_min)
    ; ("max", l_max)
    ; ("mid", l_mid)
    ; ("abs", l_abs)
    ; ("floor", l_floor)
    ; ("ceil", l_ceil)
    ; ("sin", l_sin)
    ; ("cos", l_cos)
    ; ("atan2", l_atan2)
    ; ("rnd", l_rnd)
    ; ("srnd", l_srnd)
    ; ("sqrt", l_sqrt)
    ; ("sgn", l_sgn)
    ; ("band", l_band)
    ; ("bor", l_bor)
    ; ("bxor", l_bxor)
    ; ("shl", l_shl)
    ; ("lshr", l_lshr)
    ; ("ashr", l_ashr)
    ; ("rotl", l_rotl)
    ; ("rotr", l_rotr)
    ]
  in
  List.iter (fun (name, f) -> Lua.register ls name f) functions
;;

let register_variables ls =
  let set_int name value =
    Lua.pushinteger ls value;
    Lua.setglobal ls name
  in
  let set_float name value =
    Lua.pushnumber ls value;
    Lua.setglobal ls name
  in
  set_int "W" Graphics.w;
  set_int "H" Graphics.h;
  set_float "PI" Float.pi;
  for i = Core.Color.min to Core.Color.max do
    let color = Option.get @@ Core.Color.of_enum i in
    let name = String.uppercase_ascii @@ Core.Color.show color in
    set_int name i
  done
;;

let create_vm () =
  let ls = LuaL.newstate () in
  register_functions ls;
  register_variables ls;
  ls
;;

let report_err ls =
  let message =
    match Lua.tostring ls (-1) with
    | Some s -> s
    | None -> "failed to retrieve the error message"
  in
  Lua.pop ls 1;
  raise (Lua_error message)
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
  List.iter (ensure_callback ls) [ init; update; draw ]
;;

let call_init ls = exec_func ls (Some init)
let call_update ls = exec_func ls (Some update)
let call_draw ls = exec_func ls (Some draw)
