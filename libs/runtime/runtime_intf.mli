module type Runtime = sig
  type t

  val create_vm : unit -> t
  val load_cart : t -> string -> unit
  val call_init : t -> unit
  val call_update : t -> unit
  val call_draw : t -> unit
end
