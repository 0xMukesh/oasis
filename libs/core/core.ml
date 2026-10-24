let w, h = (256, 256)
let fb = Bytes.make (w * h) '\000'

module Color = Color

type color = Color.t

let is_in_bounds x y = (x >= 0 && x < w) && y >= 0 && y < h
let fb_idx_of_coords x y = (y * w) + x

let pset x y c =
  let enum = Color.to_enum c in
  let idx = (y * w) + x in
  if is_in_bounds x y && enum >= 0 && enum < Color.max
  then Bytes.set fb idx (Char.chr enum)
;;

let pget x y =
  let idx = fb_idx_of_coords x y in
  if is_in_bounds x y then idx |> Bytes.get fb |> Char.code |> Color.of_enum else None
;;

let cls c =
  let b = c |> Color.to_enum |> Char.chr in
  Bytes.fill fb 0 (Bytes.length fb) b
;;

let hline x1 x2 y c =
  let x1, x2 = (min x1 x2, max x1 x2) in
  for x = x1 to x2 do
    pset x y c
  done
;;

let vline y1 y2 x c =
  let y1, y2 = (min y1 y2, max y1 y2) in
  for y = y1 to y2 do
    pset x y c
  done
;;

let rect x0 y0 x1 y1 c =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  hline x0 x1 y0 c;
  hline x0 x1 y1 c;
  vline y0 y1 x0 c;
  vline y0 y1 x1 c
;;

let rect_fill x0 y0 x1 y1 c =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  for x = x0 to x1 do
    for y = y0 to y1 do
      pset x y c
    done
  done
;;

let line x0 y0 x1 y1 c =
  let dx = abs (x1 - x0) in
  let dy = -abs (y1 - y0) in
  let sx = if x0 < x1 then 1 else -1 in
  let sy = if y0 < y1 then 1 else -1 in
  let rec loop x y err =
    pset x y c;
    if x = x1 && y = y1
    then ()
    else (
      let e2 = 2 * err in
      let x, err = if e2 >= dy then (x + sx, err + dy) else (x, err) in
      let y, err = if e2 <= dx then (y + sy, err + dx) else (y, err) in
      loop x y err
    )
  in
  loop x0 y0 (dx + dy)
;;

let circ_core xc yc r c ~draw_step =
  let rec loop x y err =
    if x >= 0
    then ()
    else (
      draw_step xc yc x y c;
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

let circ_draw_outline xc yc x y c =
  (* upper right *)
  pset (xc + y) (yc + x) c;
  (* upper left *)
  pset (xc + x) (yc - y) c;
  (* lower right *)
  pset (xc - x) (yc + y) c;
  (* lower left *)
  pset (xc - y) (yc - x) c
;;

let circ_draw_filled xc yc x y c =
  hline (xc - x) (xc + x) (yc + y) c;
  hline (xc - x) (xc + x) (yc - y) c;
  hline (xc - y) (xc + y) (yc + x) c;
  hline (xc - y) (xc + y) (yc - x) c
;;

let circ xc yc r c = circ_core xc yc r c ~draw_step:circ_draw_outline
let circ_fill xc yc r c = circ_core xc yc r c ~draw_step:circ_draw_filled
