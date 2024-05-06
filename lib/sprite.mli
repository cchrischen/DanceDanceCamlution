open Raylib

type t
(** [t] is the type of a Sprite which is a tuple of the frame array and the
    raylib texture. *)

val create_sprites : int -> int -> int -> int -> Raylib.Rectangle.t array
(** [create_sprites width height frames frames_per_row] generates a Rectangle
    array with each Rectangle in the array representing a section of the
    spritesheet for each frame. *)

val draw_sprite : t -> int -> float -> float -> unit
(** [draw_sprite sprite frame x y] draws [sprite] at the given frame [frame] at
    the x position [x] and y position [y] *)

val num_frames : t -> int
(** [num_frames sprite] returns the number of frames of [sprite]. *)

val initialize_sprite : string -> Raylib.Texture2D.t
(** [initialize_sprite file] returns a Raylib.Texture2D of the image from the
    given file directory [file] . *)

val initialize_sprites : string -> (string, t) Hashtbl.t
(** [initialize_sprites file] returns a HashTbl of the sprites with the names of
    the sprites as the keys and a Sprite as the value. Requires: [file] is a
    valid csv file following the format of adding sprites given in the file.
    This format has 5 parameters for a sprite: sprite name, frame width, frame
    height, total frames, and frames per row. *)

val texture : t -> Raylib.Texture2D.t
(** [texture sprite] returns the Raylib.Texture2D of the given sprite [sprite].*)

val sprite_sheet : t -> Raylib.Rectangle.t array
(** [sprite_sheet sprite] returns the array of frames given sprite [sprite].*)

val to_array : Rectangle.t array -> Rectangle.t array
(** [to_array sprite] returns the array of Rectangles embedded in [sprite].*)

val generate_sprite : int -> int -> int -> int -> string -> t
(** [generate_sprite width height frames frames_per_row file] returns a sprite
    with its rectangle and texture attributes.*)
