type command =
  { name : string
  ; description : string
  ; run : string array -> unit
  }

let commands : command list =
  [ { name = "run"; description = "Execute an oasis cartridge"; run = Commands.run_cmd }
  ; { name = "gen-lua-defs"
    ; description = "Generate Lua definitions"
    ; run = Commands.gen_lua_defs_cmd
    }
  ]
;;

let usage_msg =
  let lines =
    commands
    |> List.map (fun c -> Printf.sprintf "%-14s %s" c.name c.description)
    |> String.concat "\n"
  in
  Printf.sprintf "oasis <command> [options]\n\nCommands:\n%s\n" lines
;;

let handle_cmd cmd argv =
  try cmd.run argv with
  | Arg.Bad msg ->
    prerr_string (msg ^ "\n");
    exit 2
  | Arg.Help msg -> print_string msg
;;

let () =
  if Array.length Sys.argv < 2
  then (
    print_string usage_msg;
    exit 2
  );

  match Sys.argv.(1) with
  | "--help" | "help" -> print_string usage_msg
  | name ->
    ( match List.find_opt (fun c -> c.name = name) commands with
      | None ->
        Printf.eprintf "unknown command '%s'\n" name;
        exit 2
      | Some cmd ->
        let sub_argv = Array.sub Sys.argv 1 (Array.length Sys.argv - 1) in
        handle_cmd cmd sub_argv
    )
;;
