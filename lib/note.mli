type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

type t
(** The type underlying each note. *)

val calc_score : t -> int -> accuracy -> int
(** Calculates the score for this note, given [combo] and [accuracy]. *)

val calc_accuracy : t -> int -> accuracy
(** Determines the accuracy with which this note was hit, given [time_hit]. *)
