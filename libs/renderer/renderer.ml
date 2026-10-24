open Raylib

let pixels = CArray.make Color.t (Core.w * Core.h)

let update_pixels () =
  for i = 0 to Bytes.length Core.fb - 1 do
    let idx = Char.code (Bytes.get Core.fb i) in
    let rgb = Core.Color.palette.(idx) in
    let r = (rgb lsr 16) land 0xff in
    let g = (rgb lsr 8) land 0xff in
    let b = rgb land 0xff in
    CArray.set pixels i (Color.create r g b 255)
  done
;;

let render title ~scale ~update ~draw =
  let width = int_of_float (float_of_int Core.w *. scale) in
  let height = int_of_float (float_of_int Core.h *. scale) in
  init_window width height title;
  set_target_fps 60;

  let image = gen_image_color Core.w Core.h Color.black in
  let texture = load_texture_from_image image in
  unload_image image;
  set_texture_filter texture TextureFilter.Point;

  while not (window_should_close ()) do
    update ();

    begin_drawing ();
    clear_background Color.black;

    draw ();
    update_pixels ();

    update_texture texture (Ctypes.to_voidp (CArray.start pixels));
    draw_texture_ex texture (Vector2.create 0. 0.) 0. scale Color.white;
    end_drawing ()
  done;

  unload_texture texture
;;
