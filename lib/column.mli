open Note

type t
(** The type underlying the column's representation. *)

val create : float -> t
(** Creates a new column where [pos] is the horizontal position of the column. *)

val increment_notes : t -> unit
(** Causes all notes to fall by an amount specified in [constants.ml]. *)

val key_pressed : t -> accuracy
(** Checks whether the keypress is timed well, and awards a certain score as a
    result. Requires: the keypress is valid (it is not a keypress held down
    after hitting a different note), as determined by [main.ml]. *)
