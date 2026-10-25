let () =
  if Array.length Sys.argv <> 2
  then invalid_arg "Usage: oasis <game>.lua"
  else Renderer.render "oasis" ~scale:2.0 ~runtime:(module Runtime.Lua) ~cart:Sys.argv.(1)
;;
