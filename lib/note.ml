type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

(* [time] is the time that the note reaches the bar (i.e., the optimal time for
   the player to hit it). [base_score] is the default score value of this note,
   without combo applied. *)
type t = {
  time : int;
  base_score : int;
}
