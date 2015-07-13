(*
let () =
  Log.set_log_level Log.DEBUG;
  Log.set_time (fun () -> OS.Time.Monotonic.(to_seconds (time ())))
*)

open Lwt.Infix

let uri_str = "https://github.com/samoht/opam-repository.git"
let uri = Irmin.remote_uri uri_str


module Main (C: V1_LWT.CONSOLE) (S: V1_LWT.STACKV4) = struct

  let log_s c fmt = Printf.ksprintf (C.log_s c) fmt

  let ctx stack =
    let module DNS = Dns_resolver_mirage.Make(OS.Time)(S) in
    let module RES = Resolver_mirage.Make(DNS) in
    let conduit = Conduit_mirage.empty in
    let stackv4 = Conduit_mirage.stackv4 (module S) in
    let res = Resolver_lwt.init () in
    RES.register ~stack res;
    Conduit_mirage.with_tcp conduit stackv4 stack >>= fun conduit ->
    Conduit_mirage.with_tls conduit               >|= fun conduit ->
    res, conduit

  (* TODO: move to irmin.mirage *)
  let task msg =
    let date = Int64.of_float (Sys.time ()) in
    let owner =
      (* XXX: get "git config user.name" *)
      Printf.sprintf "Irmin %s.[%d]" (Unix.gethostname()) (Unix.getpid())
    in
    Irmin.Task.create ~date ~owner msg

  let config = Irmin_mem.config ()

  let start c stack =
    log_s c "Starting ..." >>= fun ()  ->
    ctx stack              >>= fun ctx ->
    let module Context = struct let v = Some ctx end in
    let module Memory = Irmin_mirage.Irmin_git.Memory(Context) in
    let module Store = Irmin.Basic(Memory)(Irmin.Contents.String) in
    let module Sync = Irmin.Sync(Store) in
    Store.create config task >>= fun t ->
    Sync.pull_exn (t "cloning the remote repository") ~depth:1 uri `Update
    >>= fun () ->
    Store.read_exn (t "reading the README") ["README.md"] >>= fun readme ->
    Printf.printf "%s\n%!" readme;
    Lwt.return_unit

end
