(* reference: https://lospec.com/palette-list/pico-8 *)
type t =
  | Black
  | Dark_blue
  | Dark_purple
  | Dark_green
  | Brown
  | Dark_gray
  | Light_gray
  | White
  | Red
  | Orange
  | Yellow
  | Green
  | Blue
  | Lavender
  | Pink
  | Peach
[@@deriving show { with_path = false }, enum]

type packed_color =
  { mutable primary : t (* used for drawing off bits *)
  ; mutable secondary : t (* used for drawing on bits *)
  }
[@@deriving show, make]

let default = Black

let palette =
  [| 0x000000
   ; 0x1D2B53
   ; 0x7E2553
   ; 0x008751
   ; 0xAB5236
   ; 0x5F574F
   ; 0xC2C3C7
   ; 0xFFF1E8
   ; 0xFF004D
   ; 0xFFA300
   ; 0xFFEC27
   ; 0x00E436
   ; 0x29ADFF
   ; 0x83769C
   ; 0xFF77A8
   ; 0xFFCCAA
  |]
;;

let packed_color_of_int i =
  let c = i land 0xff in
  let lower = c land 0x0f in
  let upper = (c lsr 4) land 0x0f in
  make_packed_color
    ~primary:(Option.get @@ of_enum lower)
    ~secondary:(Option.get @@ of_enum upper)
;;

let int_of_packed_color pc =
  let lower = to_enum pc.primary in
  let upper = to_enum pc.secondary in
  (upper lsr 4) lor lower
;;
