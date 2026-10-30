(* -- GLOBAL CONSTANTS -- *)
let w, h = (256, 256)
let fb = Bytes.make (w * h) '\000'

(* -- DRAW STATE -- *)
let pen_color = Color.make_packed_color ~primary:Color.Black ~secondary:Color.Black
let fill_pattern = ref 0 (* 4x4 pattern mask *)
let fill_transparent = ref false
let fps = ref 30

(* -- UTILITY FUNCTIONS -- *)
let is_point_in_bounds x y = (x >= 0 && x < w) && y >= 0 && y < h
let fb_idx_of_coords x y = (y * w) + x

let is_pixel_on x y =
  let idx = 15 - ((y land 3 * 4) + (x land 3)) in
  (!fill_pattern lsr idx) land 1 = 1
;;

(* -- DRAW STATE MODIFIERS -- *)
let set_color pri sec =
  pen_color.primary <- pri;
  pen_color.secondary <- sec
;;

let set_fill_pattern pat transparent =
  fill_pattern := pat;
  fill_transparent := transparent
;;

let set_fps v = fps := v

(* -- GRAPHICS FUNCTIONS -- *)
let cls c =
  let b = c |> Color.to_enum |> Char.chr in
  Bytes.fill fb 0 (Bytes.length fb) b
;;

let pset x y (pc : Color.packed_color) =
  let idx = fb_idx_of_coords x y in
  let set c = Bytes.set fb idx (Char.chr (Color.to_enum @@ c)) in
  if is_point_in_bounds x y
  then
    if is_pixel_on x y
    then (if not !fill_transparent then set pc.secondary)
    else set pc.primary
;;

let pget x y =
  let idx = fb_idx_of_coords x y in
  if is_point_in_bounds x y
  then Bytes.get fb idx |> Char.code |> Color.of_enum |> Option.get
  else Color.default
;;

let line x0 y0 x1 y1 pc =
  let dx = abs (x1 - x0) in
  let dy = abs (y1 - y0) in
  let sx = if x0 < x1 then 1 else -1 in
  let sy = if y0 < y1 then 1 else -1 in
  let steep = dy > dx in
  let major, minor = if steep then (dy, dx) else (dx, dy) in
  let plot i j =
    if steep
    then pset (x0 + (sx * j)) (y0 + (sy * i)) pc
    else pset (x0 + (sx * i)) (y0 + (sy * j)) pc
  in
  let rec loop i j d =
    plot i j;
    if i < major
    then
      if d > 0
      then loop (i + 1) (j + 1) (d + (2 * (minor - major)))
      else loop (i + 1) j (d + (2 * minor))
  in
  loop 0 0 ((2 * minor) - major)
;;

let rect x0 y0 x1 y1 pc =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  line x0 y0 x1 y0 pc;
  line x1 y0 x1 y1 pc;
  line x1 y1 x0 y1 pc;
  line x0 y1 x0 y0 pc
;;

let rect_fill x0 y0 x1 y1 pc =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  for x = x0 to x1 do
    for y = y0 to y1 do
      pset x y pc
    done
  done
;;

let circ_core xc yc r pc ~draw_step =
  let rec loop x y err =
    if x >= 0
    then ()
    else (
      draw_step xc yc x y pc;
      let e2 = err in
      let y, err =
        if e2 <= y
        then (
          let y = y + 1 in
          (y, err + (y * 2) + 1)
        )
        else (y, err)
      in
      let x, err =
        if e2 > x || err > y
        then (
          let x = x + 1 in
          (x, err + (x * 2) + 1)
        )
        else (x, err)
      in
      loop x y err
    )
  in
  loop (-r) 0 (2 - (2 * r))
;;

let circ_draw_outline xc yc x y pc =
  pset (xc + y) (yc + x) pc;
  pset (xc + x) (yc - y) pc;
  pset (xc - x) (yc + y) pc;
  pset (xc - y) (yc - x) pc
;;

let circ_draw_filled xc yc x y pc =
  line (xc - x) (yc + y) (xc + x) (yc + y) pc;
  line (xc - x) (yc - y) (xc + x) (yc - y) pc;
  line (xc - y) (yc + x) (xc + y) (yc + x) pc;
  line (xc - y) (yc - x) (xc + y) (yc - x) pc
;;

let circ xc yc r c = circ_core xc yc r c ~draw_step:circ_draw_outline
let circ_fill xc yc r c = circ_core xc yc r c ~draw_step:circ_draw_filled
