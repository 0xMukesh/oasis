let w, h = (256, 256)
let fb = Bytes.make (w * h) '\000'

module Color = Color

type color = Color.t

let pset (x, y) c =
  let enum = Color.to_enum c in
  let idx = (y * w) + x in
  if (x >= 0 && x < w) && (y >= 0 && y < h) && enum >= 0 && enum < Color.max then begin
    Bytes.set fb idx (Char.chr enum)
  end
;;

let hline x0 x1 y c =
  for x = x0 to x1 do
    pset (x, y) c
  done
;;

let vline y0 y1 x c =
  for y = y0 to y1 do
    pset (x, y) c
  done
;;

let rect (x0, y0) (x1, y1) c =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  hline x0 x1 y0 c;
  hline x0 x1 y1 c;
  vline y0 y1 x0 c;
  vline y0 y1 x1 c
;;

let rectfill (x0, y0) (x1, y1) c =
  let x0, x1 = (min x0 x1, max x0 x1) in
  let y0, y1 = (min y0 y1, max y0 y1) in
  for x = x0 to x1 do
    for y = y0 to y1 do
      pset (x, y) c
    done
  done
;;
