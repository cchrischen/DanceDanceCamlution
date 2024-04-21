type t

val create_sprites : int -> int -> int -> int -> t
val draw_sprite : t -> string -> int -> float -> float -> unit
val num_frames : t -> int
