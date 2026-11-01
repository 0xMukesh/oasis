type button =
  | Up
  | Left
  | Down
  | Right
  | A
  | B
[@@deriving show { with_path = false }, enum]

(* State *)
let button_state = Array.make (max_button + 1) false
let previous_button_state = Array.make (max_button + 1) false

(* Modifiers *)
let set_button button pressed = button_state.(button_to_enum button) <- pressed

let update_button_state ~mapping ~f =
  Array.blit button_state 0 previous_button_state 0 (Array.length button_state);
  List.iter (fun (button, key) -> set_button button (f key)) mapping
;;

(* Queriers *)
let is_pressed button = button_state.(button_to_enum button)

let is_just_pressed button =
  let i = button_to_enum button in
  button_state.(i) && not previous_button_state.(i)
;;

let button_state_mask () =
  let arr = Array.mapi (fun i pressed -> (i, pressed)) button_state in
  Array.fold_left
    (fun mask (i, pressed) -> if pressed then mask lor (1 lsl i) else mask)
    0
    arr
;;
