(*
let () =
  Log.set_log_level Log.DEBUG;
  Log.set_time (fun () -> OS.Time.Monotonic.(to_seconds (time ())))
*)

open Lwt.Infix

let uri_str = "https://github.com/samoht/opam-repository.git"
let uri = Irmin.remote_uri uri_str


module Main (C: V1_LWT.CONSOLE) (Cl: V1.CLOCK) (S: V1_LWT.STACKV4) = struct

  module Context = Conduit_mirage.Context(OS.Time)(S)
  module Task = Irmin_mirage.Task(struct let name = "unikernel" end)(Cl)

  let log_s c fmt = Printf.ksprintf (C.log_s c) fmt

  let config = Irmin_mem.config ()

  let start c _ stack =
    log_s c "Starting ..." >>= fun ()  ->
    Context.create ~tls:true stack >>= fun ctx ->
    let module C = struct let v () = Lwt.return (Some ctx) end in
    let module M = Irmin_mirage.Irmin_git.Memory(C) in
    let module Store = Irmin.Basic(M)(Irmin.Contents.String) in
    let module Sync = Irmin.Sync(Store) in
    Store.create config Task.f >>= fun t ->
    Sync.pull_exn (t "cloning the remote repository") ~depth:1 uri `Update
    >>= fun () ->
    Store.read_exn (t "reading the README") ["README.md"] >>= fun readme ->
    Printf.printf "%s\n%!" readme;
    Lwt.return_unit

end
