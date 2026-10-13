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

val palette : int array
val to_enum : t -> int
val of_enum : int -> t option
val min : int
val max : int
