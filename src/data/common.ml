open Disml
open Models
module ChannelTbl = Core.Hashtbl.Make (Channel_id)
module MessageTbl = Core.Hashtbl.Make (Message_id)
module MemberTbl = Core.Hashtbl.Make (Member)
module UserTbl = Core.Hashtbl.Make (User)
