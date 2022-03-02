open Core
open Disml
open Models

module Self = struct
  include Member

  let ( = ) (m1 : t) (m2 : t) =
    Int.(
      Guild_id.get_id m1.guild_id = Guild_id.get_id m2.guild_id
      && User_id.get_id m1.user.id = User_id.get_id m2.user.id)
end

module Set = Set.Make (Self)
module Map = Map.Make (Self)
module Hashtbl = Hashtbl.Make (Self)
include Self
