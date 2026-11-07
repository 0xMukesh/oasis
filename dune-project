(lang dune 3.24)

(name oasis)

(generate_opam_files true)

(source
 (github 0xmukesh/oasis))

(authors "Mukesh <mukesh@0xc84.fyi>")

(maintainers "Mukesh <mukesh@0xc84.fyi>")

(license MIT)

(documentation https://github.com/0xmukesh/oasis)

(package
 (name oasis)
 (synopsis "An OCaml based fantasy console built with Raylib")
 (description "An OCaml based fantasy console built with Raylib")
 (depends
  ocaml
  ocaml-lsp-server
  ocamlformat
  ppx_deriving
  raylib
  ocaml-lua)
 (tags
  ("fantasy-console" "raylib")))
