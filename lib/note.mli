open Raylib

type accuracy =
  | Perfect
  | Great
  | Good
  | Miss
      (** The different categories of accuracy a player can achieve with each
          hit, depending on how well-timed the hit was. Perfect > Great > Good >
          Miss. *)

type t
(** The type underlying each note. *)

val create_note : float -> float -> t
(** [create_note x y] creates a note at the location specified by (x, y). The
    note's height, width, and speed are determined by their respective values in
    the Constants file. *)

val update : t -> bool
(** [update note] updates [note]'s position so that it falls down at a rate
    specified by [Constants.note_speed]. Returns whether the combo should be
    reset to 0; in other words, if the note reaches the bottom of the screen
    without being hit, returns true (meaning that the combo should be broken)
    else false. *)

val hit : t -> unit
(** [hit note] effectively causes [note] to be considered "hit". If the note has
    not yet been hit, the note disappears and [has_been_hit] is set to true. If
    the note has already been hit, does nothing. *)

val get_sprite : t -> Rectangle.t
(** [get_sprite note] returns the sprite field of the note *)

val has_been_hit : t -> bool
(** [has_been_hit note] returns the whether the note has been hit or not *)

val get_speed : t -> float
(** [get_speed note] returns the speed of the note *)

val calc_score : int -> accuracy -> int
(** Calculates the score for this note, given [combo] and [accuracy]. *)

val calc_accuracy : float -> accuracy
(** [calc_accuracy overlap] determines the accuracy with which this note was
    hit, given [overlap], which is the proportion of the note that overlaps with
    the button at the time of the keypress. Requires: 0 < [overlap] <= 1. *)
