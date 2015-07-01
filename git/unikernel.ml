(*
let () =
  Log.set_log_level Log.DEBUG;
  Log.set_time (fun () -> OS.Time.Monotonic.(to_seconds (time ())))
*)

let (>>=) = Lwt.bind
let uri_str = "git://github.com/samoht/opam-repository.git"
let gri = Git.Gri.of_string uri_str

let git_service = {
    Resolver.name = "git"; port = 9418; tls = false
  }

let service = function
  | "git"  -> Lwt.return (Some git_service)
  | _      -> Lwt.return_none

module Main (C: V1_LWT.CONSOLE) (S: V1_LWT.STACKV4) = struct

  module DNS = Dns_resolver_mirage.Make(OS.Time)(S)
  module RES = Resolver_mirage.Make(DNS)

  module Mirage_sync = Git_mirage.Sync
  module Sync = Mirage_sync.Make(Git.Memory)

  let log_s c fmt = Printf.ksprintf (C.log_s c) fmt

  let conduit = Conduit_mirage.empty
  let stackv4 = Conduit_mirage.stackv4 (module S)

  let start c stack =
    log_s c "Starting ..." >>= fun () ->
    OS.Time.sleep 3. >>= fun () ->
    log_s c "Starting ..." >>= fun () ->
    let res = Resolver_lwt.init ~service () in
    RES.register ~stack res;
    Conduit_mirage.with_tcp conduit stackv4 stack >>= fun conduit ->
    Conduit_mirage.with_tls conduit               >>= fun conduit ->
    let ctx = res, conduit in

    log_s c "Running 'git ls-remote %s'" uri_str >>= fun () ->
    Git.Memory.create () >>= fun t ->
    Sync.ls ~ctx t gri >>= fun map ->
    log_s c "Done!" >>= fun () ->

    let map = Git.Reference.Map.bindings map in
    let refs = List.map fst map in
    Lwt_list.iter_s (fun r -> log_s c "ref: %s" (Git.Reference.pretty r)) refs

end
