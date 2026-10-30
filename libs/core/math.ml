let min = Float.min
let max = Float.max
let mid x y z = List.nth (List.sort Float.compare [ x; y; z ]) 1
let abs = Float.abs
let floor = Float.floor
let ceil = Float.ceil
let sin = Float.sin
let cos = Float.cos
let atan2 = Float.atan2
let rnd limit = Random.float limit
let rnd_list l = Random.int (List.length l) |> List.nth l
let srnd seed = Random.init seed
let sqrt = Float.sqrt
let sgn (n : float) = if n >= 0.0 then 1. else -1.
let band x y = x land y
let bor x y = x lor y
let bxor x y = x lxor y
let shl num bits = num lsl bits
let lshr num bits = num lsr bits
let ashr num bits = num asr bits

let rotl x n =
  let n = n mod 32 in
  let x32 = Int32.of_int x in
  Int32.logor (Int32.shift_left x32 n) (Int32.shift_right_logical x32 (32 - n))
  |> Int32.to_int
;;

let rotr x n =
  let n = n mod 32 in
  let x32 = Int32.of_int x in
  Int32.logor (Int32.shift_right_logical x32 n) (Int32.shift_left x32 (32 - n))
  |> Int32.to_int
;;

let time = Unix.time
