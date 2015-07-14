(*
let () =
  Log.set_log_level Log.DEBUG;
  Log.set_time (fun () -> OS.Time.Monotonic.(to_seconds (time ())))
*)

open Lwt.Infix

let uri_str = "https://github.com/samoht/opam-repository.git"
let gri = Git.Gri.of_string uri_str

module Main (C: V1_LWT.CONSOLE) (S: V1_LWT.STACKV4) = struct

  module Context = Conduit_mirage.Context(OS.Time)(S)
  module Sync = Git_mirage.Sync.Make(Git.Memory)

  let log_s c fmt = Printf.ksprintf (C.log_s c) fmt

  let start c stack =
    log_s c "Starting ..." >>= fun () ->
    Git.Memory.create () >>= fun t ->
    Context.create ~tls:true stack >>= fun ctx ->
    log_s c "Running 'git ls-remote %s'" uri_str >>= fun () ->
    Sync.ls ~ctx t gri >>= fun map ->
    log_s c "Done!" >>= fun () ->
    let map = Git.Reference.Map.bindings map in
    let refs = List.map fst map in
    Lwt_list.iter_s (fun r -> log_s c "ref: %s" (Git.Reference.pretty r)) refs

end
