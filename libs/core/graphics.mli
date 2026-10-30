(* -- GLOBAL CONSTANTS -- *)
val w : int
val h : int
val fb : bytes
val fps : int ref

(* -- DRAW STATE -- *)
val pen_color : Color.packed_color

(* -- DRAW STATE MODIFIERS -- *)
val set_color : Color.t -> Color.t -> unit
val set_fill_pattern : int -> bool -> unit
val set_fps : int -> unit

(* -- GRAPHIC FUNCTIONS -- *)
val cls : Color.t -> unit
val pset : int -> int -> Color.packed_color -> unit
val pget : int -> int -> Color.t
val line : int -> int -> int -> int -> Color.packed_color -> unit
val rect : int -> int -> int -> int -> Color.packed_color -> unit
val rect_fill : int -> int -> int -> int -> Color.packed_color -> unit
val circ : int -> int -> int -> Color.packed_color -> unit
val circ_fill : int -> int -> int -> Color.packed_color -> unit
