open Mirage

let stack = direct_stackv4_with_default_ipv4 default_console tap0

let main = foreign "Unikernel.Main" @@ console @-> stackv4 @-> job

let () =
  add_to_ocamlfind_libraries [ "zlib"; "conduit.lwt"; "conduit.mirage"; "dns.mirage"; "git.mirage" ];
  add_to_opam_packages [ "mirage-dns"; "conduit"; "git" ];
  register "git" [ main $ default_console $ stack ]
