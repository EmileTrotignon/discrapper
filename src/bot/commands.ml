open Async
open Core
open Disml
module TmpMember = Member
open Models
module Member = TmpMember
open Common

let guild_of_id (guild_id : Guild_id.t) =
  Cache.(
    let cache = Mvar.peek_exn cache in
    GuildMap.find_exn cache.guilds guild_id)

let data_from_history_channel add_data (channel : Channel.guild_text) =
  let title = Channel.(channel.name) in
  MLog.info {%eml|Getting messages of channel <%-title%>|} ;
  let%map () = Message_history.iter_deferred ~f:add_data (`GuildText channel) in
  MLog.info {%eml|Messages of channel <%-title%> got.|}

let data_from_history file guild_id =
  don't_wait_for
  @@
  let guild = guild_of_id guild_id in
  let channels = guild.channels in
  let data = ChannelTbl.create () in
  let%map () =
    Deferred.List.iter
      ~f:(fun channel ->
        match channel with
        | `GuildText tchannel ->
            let channel_data = MessageTbl.create () in
            let add_data message =
              let _ =
                MessageTbl.add channel_data
                  ~key:Message.(message.id)
                  ~data:message
              in
              Deferred.return ()
            in
            let%map () = data_from_history_channel add_data tchannel in
            let _ =
              ChannelTbl.add data ~key:Channel.(tchannel.id) ~data:channel_data
            in
            ()
        | _ ->
            Deferred.return () )
      channels
  in
  let data =
    ChannelTbl.sexp_of_t (MessageTbl.sexp_of_t Message.sexp_of_t) data
  in
  Sexp.output_mach file data ; exit 0

let data_from_history file message =
  data_from_history file Message.(Option.value_exn message.guild_id)

(* let distribute_roles guild_id =
   let%bind members = MCache.get_members guild_id in
   let%map members =
     members |> Member.Set.elements
     |> Deferred.List.map ~f:(fun member ->
            Deferred.both (Deferred.return member)
              (Data.score_of_user guild_id Member.(member.user)) )
     |> Deferred.map
          ~f:(List.sort ~compare:(fun (_, s1) (_, s2) -> compare s1 s2))
   in
*)
