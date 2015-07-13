(*
let () =
  Log.set_log_level Log.DEBUG;
  Log.set_time (fun () -> OS.Time.Monotonic.(to_seconds (time ())))
*)

open Lwt.Infix

let uri_str = "https://github.com/samoht/opam-repository.git"
let gri = Git.Gri.of_string uri_str

module Main (C: V1_LWT.CONSOLE) (S: V1_LWT.STACKV4) = struct

  let log_s c fmt = Printf.ksprintf (C.log_s c) fmt

  module Sync = Git_mirage.Sync.Make(Git.Memory)

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

  let start c stack =
    log_s c "Starting ..." >>= fun () ->
    ctx stack >>= fun ctx ->

    log_s c "Running 'git ls-remote %s'" uri_str >>= fun () ->
    Git.Memory.create () >>= fun t ->
    Sync.ls ~ctx t gri >>= fun map ->
    log_s c "Done!" >>= fun () ->

    let map = Git.Reference.Map.bindings map in
    let refs = List.map fst map in
    Lwt_list.iter_s (fun r -> log_s c "ref: %s" (Git.Reference.pretty r)) refs

end
