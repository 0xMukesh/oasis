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

let default = White

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
