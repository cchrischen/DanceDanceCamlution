type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

type t
(** The type underlying each note. *)

val create_note : int -> int -> t
(** Creates a note given [time], the time that the note reaches the bar (i.e.,
    the optimal time for the player to hit it), and [base_score], the default
    score value of this note without combo applied. *)

val try_hit : t -> int -> bool
(** Attempt to hit the note, at time [hit_time]. The hit may or may not be valid
    depending on if the time window to hit the note is open, and if the note has
    already been hit. Returns true if the hit is valid, otherwise, returns
    false. *)

val calc_score : t -> int -> accuracy -> int
(** Calculates the score for this note, given [combo] and [accuracy]. *)

val calc_accuracy : t -> int -> accuracy
(** Determines the accuracy with which this note was hit, given [time_hit]. *)
