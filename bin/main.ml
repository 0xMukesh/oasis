open Core

let w = Core.w
let h = Core.h
let horizon = 200
let frame = ref 0

let stars =
  Array.init 120 (fun _ ->
    ( Random.float (float_of_int w)
    , Random.float (float_of_int horizon)
    , Random.float (2.0 *. Float.pi) ))
;;

let update () =
  incr frame;
  rectfill (0, horizon) (w - 1, h - 1) Color.Dark_blue;
  rect (0, horizon) (w - 1, horizon) Color.Dark_gray;
  let t = float_of_int !frame *. 0.05 in
  Array.iter
    (fun (x, y, ph) ->
       let c =
         if Float.sin (t +. ph) > 0.0 then
           Color.White
         else
           Color.Black
       in
       pset (int_of_float x, int_of_float y) c)
    stars
;;

let () = Random.self_init ()
let () = Renderer.render "oasis" ~scale:2.0 ~update
