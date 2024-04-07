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

val update : t -> t
val hit : t -> unit
val get_sprite : t -> Rectangle.t

val calc_score : t -> int -> accuracy -> int
(** Calculates the score for this note, given [combo] and [accuracy]. *)

val calc_accuracy : t -> int -> accuracy
(** Determines the accuracy with which this note was hit, given [time_hit]. *)
