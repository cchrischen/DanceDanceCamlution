open Note
open Raylib

type t
(** The type underlying the column's representation. *)

val create : float -> t
(** [create pos] creates a new column where [pos] is the horizontal position of
    the column. *)

val get_notes : t -> Note.t list
(** Returns a list of the active notes in the column. *)

val get_button : t -> Rectangle.t
(** Returns the corresponding button (where the user's keypress occurs) of the
    column. *)

val add_note : t -> unit
(** Adds a note to the column, which begins falling from the top of the screen. *)

val increment_notes : t -> unit
(** Causes all notes to fall by an amount specified by [Constants.note_speed]. *)

val key_pressed : t -> accuracy
(** Checks whether the keypress is timed well, and awards a certain accuracy as
    a result. Requires: the keypress is valid (it is not a keypress held down
    after hitting a different note or after hitting too early). *)

val remove_dead_notes : t -> unit
(** Removes notes which are below the bottom of the screen. *)

val reset : t -> unit
(** [reset col] deletes all notes from the column.*)
