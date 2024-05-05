open Raylib

type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

type t
(** The type underlying each note. *)

val create_note : float -> float -> t
(** Creates a note given [time], the time that the note reaches the bar (i.e.,
    the optimal time for the player to hit it), and [base_score], the default
    score value of this note without combo applied. *)

val update : t -> bool
(** [update note] updates [note] position based on the position of the note on
    the window (i.e if a note reaches end of window height resets position of
    the note and resets the hit status for note - otherwise it moves the note
    down in the window based on the speed of the note) *)

val hit : t -> unit
(** [hit note] if note has been hit then we reset the note at the top of the
    window, otherwise changes field of the note to be hit *)

val get_sprite : t -> Rectangle.t
(** [get_sprite note] returns the sprite field of the note *)

val has_been_hit : t -> bool
(** [has_been_hit note] returns the whether the note has been hit or not *)

val get_speed : t -> float
(** [get_speed note] returns the speed of the note *)

val calc_score : int -> accuracy -> int
(** Calculates the score for this note, given [combo] and [accuracy]. *)

val calc_accuracy : float -> accuracy
(** Determines the accuracy with which this note was hit, given [time_hit]. *)
