val w : int
val h : int
val fb : bytes
val pen_color : Color.t ref
val color : Color.t -> unit
val cls : Color.t -> unit
val pset : int -> int -> Color.t -> unit
val pget : int -> int -> Color.t option
val hline : int -> int -> int -> Color.t -> unit
val vline : int -> int -> int -> Color.t -> unit
val line : int -> int -> int -> int -> Color.t -> unit
val rect : int -> int -> int -> int -> Color.t -> unit
val rect_fill : int -> int -> int -> int -> Color.t -> unit
val circ : int -> int -> int -> Color.t -> unit
val circ_fill : int -> int -> int -> Color.t -> unit
