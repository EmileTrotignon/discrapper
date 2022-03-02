open Core
open Disml
module TmpMember = Member
open Models
module Member = TmpMember
open Async

(* Create a function to handle message_create. *)

let started : (bool, read_write) Mvar.t = Mvar.create ()

let check_command (message : Message.t) =
  if
    (not @@ Mvar.peek_exn started)
    && String.(Message.(message.content) = Config.command)
  then (
    Mvar.set started true ;
    Commands.data_from_history (Out_channel.create "data.sexp") message )

let main () =
  (* Register the event handler *)
  Mvar.set started false ;
  Client.message_create := check_command ;
  Async.Deferred.don't_wait_for
  @@ let%map _client = Client.start Config.token in
     MLog.info "Connected successfully"

let _ =
  (* Launch the Async scheduler. You must do this for anything to work. *)
  Scheduler.go_main ~main ()
