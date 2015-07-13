open Mirage

let ipv4 = {
  Mirage.address = Ipaddr.V4.of_string_exn "192.168.33.11";
  netmask        = Ipaddr.V4.of_string_exn "255.255.255.0";
  gateways       = [Ipaddr.V4.of_string_exn "192.168.33.10"];
}

let stack =
  let direct () = direct_stackv4_with_dhcp default_console tap0 in
  let static () = direct_stackv4_with_static_ipv4 default_console tap0 ipv4 in
  let socket () = socket_stackv4 default_console [] in
  try
    match Sys.getenv "NET" with
    | "static" -> static ()
    | "socket" -> socket ()
    | _        -> direct ()
  with Not_found -> direct ()

let main = foreign "Unikernel.Main" @@ console @-> stackv4 @-> job

let () =
  add_to_ocamlfind_libraries [ "conduit.lwt"; "conduit.mirage"; "irmin.mirage"];
  add_to_opam_packages [
    "conduit"; "mirage-git"; "irmin"; "mirage-flow"; "mirage-http"
  ]

let () =
  register "irmin" [ main $ default_console $ stack ]
