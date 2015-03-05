open Mirage

let stack =
  let direct () = direct_stackv4_with_dhcp default_console tap0 in
  let static () = direct_stackv4_with_default_ipv4 default_console tap0 in
  try
    match Sys.getenv "NET" with
    | "static" -> static ()
    | _        -> direct ()
  with Not_found -> direct ()

let main = foreign "Unikernel.Main" @@ console @-> stackv4 @-> job

let () =
  add_to_ocamlfind_libraries [
    "conduit.lwt"; "conduit.mirage"; "dns.mirage"; "git.mirage"
  ];
  match Mirage.get_mode () with
  | `Xen -> add_to_ocamlfind_libraries ["zlib-xen.xen"]
  | _    -> ()

let () =
  add_to_opam_packages [ "mirage-dns"; "conduit"; "git" ];
  match Mirage.get_mode () with
  | `Xen -> add_to_opam_packages ["zlib-xen"]
  | _    -> ()

let () =
  register "git" [ main $ default_console $ stack ]
