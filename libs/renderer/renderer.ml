open Raylib
open Core
module RLColor = Raylib.Color

let pixels = CArray.make RLColor.t (Graphics.w * Graphics.h)

let update_pixels () =
  for i = 0 to Bytes.length Graphics.fb - 1 do
    let idx = Char.code (Bytes.get Graphics.fb i) in
    let rgb = Core.Color.palette.(idx) in
    let r = (rgb lsr 16) land 0xff in
    let g = (rgb lsr 8) land 0xff in
    let b = rgb land 0xff in
    CArray.set pixels i (RLColor.create r g b 255)
  done
;;

let render title ~scale ~runtime ~cart =
  let module R = (val runtime : Runtime.Runtime) in
  let vm = R.create_vm () in
  R.load_cart vm cart;

  let width = int_of_float (float_of_int Graphics.w *. scale) in
  let height = int_of_float (float_of_int Graphics.h *. scale) in
  init_window width height title;
  set_target_fps 60;

  let image = gen_image_color Graphics.w Graphics.h RLColor.black in
  let texture = load_texture_from_image image in
  unload_image image;
  set_texture_filter texture TextureFilter.Point;

  R.call_init vm;

  while not (window_should_close ()) do
    R.call_update vm;

    begin_drawing ();
    clear_background RLColor.black;

    R.call_draw vm;
    update_pixels ();

    update_texture texture (Ctypes.to_voidp (CArray.start pixels));
    draw_texture_ex texture (Vector2.create 0. 0.) 0. scale RLColor.white;
    end_drawing ()
  done;

  unload_texture texture
;;
