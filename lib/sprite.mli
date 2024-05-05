type t

open Raylib

val create_sprites : int -> int -> int -> int -> t
val draw_sprite : t -> string -> int -> float -> float -> unit
val num_frames : t -> int
val to_array : t -> Rectangle.t array
