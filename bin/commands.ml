let subcommand_usage name = Printf.sprintf "oasis %s [options]\nOptions:" name
let error_on_unknown_arg arg = raise @@ Arg.Bad ("unexpected argument: " ^ arg)

let run_cmd argv =
  let scale = ref 2.0 in
  let cart = ref "" in
  let speclist =
    [ ("--scale", Arg.Set_float scale, "<f> Display scale (default 2.0)")
    ; ("--cart", Arg.Set_string cart, "<path> Path to the cartridge")
    ]
    |> Arg.align
  in
  Arg.parse_argv argv speclist error_on_unknown_arg (subcommand_usage "run");
  if !cart = "" then raise @@ Arg.Bad "missing required option --cart";
  Renderer.render "oasis" ~scale:!scale ~runtime:(module Runtime.Lua) ~cart:!cart
;;
