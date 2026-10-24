module Color = Color

type color = Color.t

val w : int
val h : int
val fb : bytes
val pset : int -> int -> color -> unit
val pget : int -> int -> color option
val cls : color -> unit
val hline : int -> int -> int -> color -> unit
val vline : int -> int -> int -> color -> unit
val rect : int -> int -> int -> int -> color -> unit
val rect_fill : int -> int -> int -> int -> color -> unit
val line : int -> int -> int -> int -> color -> unit
val circ : int -> int -> int -> color -> unit
val circ_fill : int -> int -> int -> color -> unit
