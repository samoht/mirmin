open Mirage

let stack = direct_stackv4_with_default_ipv4 default_console tap0

let main = foreign "Unikernel.Main" @@ console @-> stackv4 @-> job

let () =
  add_to_ocamlfind_libraries [
    "conduit.lwt"; "conduit.mirage"; "dns.mirage"; "git.mirage"
  ];
  match Mirage.get_mode () with
  | `Xen -> add_to_ocamlfind_libraries ["zlib.xen"]
  | _    -> ()

let () =
  add_to_opam_packages [ "mirage-dns"; "conduit"; "git" ];
  match Mirage.get_mode () with
  | `Xen -> add_to_opam_packages ["zlib-xen"]
  | _    -> ()

let () =
  register "git" [ main $ default_console $ stack ]
