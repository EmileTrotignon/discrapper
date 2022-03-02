open Core
open Disml
open Models
open Common
open Matplotlib
module IntTbl = Hashtbl.Make (Int)

let channel_copypasta = `Channel_id 819672908820381706

let channel_complaining = `Channel_id 816685416983298058

let display_ratio data =
  let react_ratios = UserTbl.create () in
  ChannelTbl.iteri
    ~f:(fun ~key ~data ->
      let _ = key in
      MessageTbl.iteri
        ~f:(fun ~key ~data ->
          let _ = key in
          Message.(
            let message = data in
            let author = message.author in
            let n_reactions =
              message.reactions
              |> List.fold_left
                   ~f:(fun acc reaction -> Reaction.(reaction.count + acc))
                   ~init:0
            in
            UserTbl.update react_ratios author ~f:(function
              | None ->
                  (n_reactions, 1)
              | Some (n_reactions', n_messages) ->
                  (n_reactions + n_reactions', n_messages + 1) )) )
        data )
    data ;
  let scatter_data =
    react_ratios
    |> UserTbl.mapi ~f:(fun ~key ~data ->
           let _ = key in
           let nreact, nmes = data in
           (Float.of_int nmes, Float.of_int nreact) )
    |> UserTbl.to_alist |> Array.of_list_map ~f:snd
  in
  Out_channel.(flush stdout) ;
  let _fig, ax = Fig.create_with_ax () in
  Ax.scatter ax scatter_data ;
  UserTbl.iteri
    ~f:(fun ~key ~data ->
      let y, x = data in
      let y = float_of_int y and x = float_of_int x in
      let text = sprintf "%s %.2f" key.username (y /. x) in
      Ax.annotate ax text x y )
    react_ratios ;
  (* Ax.scatter ax (dist |> Mo_ppl.Continuous.Dist.support) ; *)
  Ax.set_xlabel ax "Number of messages" ;
  Ax.set_ylabel ax "Number of reactions" ;
  Mpl.show ()

let display_ratio_channel data channel =
  let react_ratios = UserTbl.create () in
  MessageTbl.iteri
    ~f:(fun ~key ~data ->
      let _ = key in
      Message.(
        let message = data in
        let author = message.author in
        let n_reactions =
          message.reactions
          |> List.fold_left
               ~f:(fun acc reaction -> Reaction.(reaction.count + acc))
               ~init:0
        in
        UserTbl.update react_ratios author ~f:(function
          | None ->
              (n_reactions, 1)
          | Some (n_reactions', n_messages) ->
              (n_reactions + n_reactions', n_messages + 1) )) )
    (ChannelTbl.find_exn data channel) ;
  let scatter_data =
    react_ratios
    |> UserTbl.mapi ~f:(fun ~key ~data ->
           let _ = key in
           let nreact, nmes = data in
           (Float.of_int nmes, Float.of_int nreact) )
    |> UserTbl.to_alist |> Array.of_list_map ~f:snd
  in
  Out_channel.(flush stdout) ;
  let _fig, ax = Fig.create_with_ax () in
  Ax.scatter ax scatter_data ;
  UserTbl.iteri
    ~f:(fun ~key ~data ->
      let y, x = data in
      let y = float_of_int y and x = float_of_int x in
      let text = sprintf "%s %.2f" key.username (y /. x) in
      Ax.annotate ax text x y )
    react_ratios ;
  (* Ax.scatter ax (dist |> Mo_ppl.Continuous.Dist.support) ; *)
  Ax.set_title ax (sprintf "Channel #%i" (Channel_id.get_id (channel))) ;
  Ax.set_xlabel ax "Number of messages" ;
  Ax.set_ylabel ax "Number of reactions" ;
  Mpl.show ()

let () =
  let arg = Sys.get_argv () in
  if Array.length arg > 1 then (
    let filename = arg.(1) in
    let sexp = Sexp.input_sexp (In_channel.create filename) in
    (* Sexp.output_hum (Out_channel.create "data.hum.sexp") sexp ; *)
    let data =
      ChannelTbl.t_of_sexp (MessageTbl.t_of_sexp Message.t_of_sexp) sexp
    in
    display_ratio data ;
    display_ratio_channel data channel_complaining ;
    display_ratio_channel data channel_complaining ;
    let channel_number =
      let i = ref 0 in
      ChannelTbl.map
        ~f:(fun _channel ->
          let r = !i in
          i := !i + 1 ;
          r )
        data
    in
    let _channel_number chan = ChannelTbl.find_exn channel_number chan in
    let members = MemberTbl.create () in
    let _member_number =
      let i = ref 0 in
      fun member ->
        match MemberTbl.find members member with
        | None ->
            let r = !i in
            i := !i + 1 ;
            MemberTbl.add_exn members ~key:member ~data:r ;
            r
        | Some n ->
            n
    in
    let timed_message =
      data |> ChannelTbl.to_alist
      |> List.map ~f:(fun (_key, data) ->
             data |> MessageTbl.to_alist
             |> List.map ~f:(fun (_, message) ->
                    Message.
                      (message.timestamp |> ISO8601.Permissive.date, message) ) )
      |> List.concat
      |> List.sort ~compare:(fun (t, _) (t', _) -> Float.compare t t')
    in
    let members_timed_messages = UserTbl.create () in
    List.iter
      ~f:(fun (time, message) ->
        UserTbl.update members_timed_messages
          Message.(message.author)
          ~f:(function None -> [time] | Some li -> time :: li) )
      timed_message ;
    let members_timed_messages =
      UserTbl.map ~f:Array.of_list members_timed_messages
    in
    let _channel_n_messages =
      ChannelTbl.iteri data ~f:(fun ~key ~data ->
          printf "Channel %i has %i messages\n" (Channel_id.get_id key)
            (MessageTbl.length data) )
    in
    Mpl.style_use "ggplot" ;
    let times_message =
      members_timed_messages |> UserTbl.to_alist |> List.map ~f:snd
    in
    let label =
      members_timed_messages |> UserTbl.to_alist
      |> List.map ~f:(fun (u, _) -> User.(u.username))
      |> List.stable_dedup |> String.concat ~sep:"\n"
    in
    (* let times = timed_message |> Array.of_list_map ~f:fst in *)
    let t = List.hd_exn times_message in
    let times = List.tl_exn times_message in
    print_endline label ;
    let _fig, ax = Fig.create_with_ax () in
    Ax.hist ax ~label ~histtype:`barstacked ~xs:times t ~bins:200 ;
    (* Ax.scatter ax (dist |> Mo_ppl.Continuous.Dist.support) ; *)
    Ax.set_title ax "Messages over time for every user" ;
    Ax.set_xlabel ax "Messages" ;
    Ax.set_ylabel ax "Time" ;
    Mpl.show () )
  else failwith "No argument given"
