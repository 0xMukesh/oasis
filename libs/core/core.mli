module Color = Color

type color = Color.t

val w : int
val h : int
val fb : bytes
val pset : int * int -> color -> unit
val hline : int -> int -> int -> color -> unit
val vline : int -> int -> int -> color -> unit
val rect : int * int -> int * int -> color -> unit
