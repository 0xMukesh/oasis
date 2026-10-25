val w : int
val h : int
val fb : bytes
val pset : int -> int -> Color.t -> unit
val pget : int -> int -> Color.t option
val cls : Color.t -> unit
val hline : int -> int -> int -> Color.t -> unit
val vline : int -> int -> int -> Color.t -> unit
val line : int -> int -> int -> int -> Color.t -> unit
val rect : int -> int -> int -> int -> Color.t -> unit
val rect_fill : int -> int -> int -> int -> Color.t -> unit
val circ : int -> int -> int -> Color.t -> unit
val circ_fill : int -> int -> int -> Color.t -> unit
