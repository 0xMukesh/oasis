let update () =
  Core.rect (20, 20) (100, 100) Core.Color.Green;
  Core.hline 200 300 150 Core.Color.Dark_purple
;;

let () = Renderer.render "oasis" ~scale:2.0 ~update
