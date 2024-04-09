open Raylib

type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

type t = {
  sprite : Rectangle.t;
  time : int;
  base_score : int;
  has_been_hit : bool;
  speed : float;
}

(* [miss_window] is how much leeway the player has before the note counts as a
   miss (either early or late). *)
let miss_window = 600

let create_note x y =
  {
    sprite = Rectangle.create x y Constants.note_width Constants.note_heigth;
    time = 0;
    base_score = 10;
    has_been_hit = false;
    speed = Constants.note_speed;
  }

let update note =
  let sprite = note.sprite in
  Rectangle.(set_y sprite (y sprite +. note.speed));
  if Rectangle.y sprite > (get_screen_height () |> float_of_int) then
    Rectangle.set_y sprite 0.;
  sprite

let try_hit note time_hit =
  if note.has_been_hit then false
  else if abs (time_hit - note.time) <= miss_window then true
  else false

let calc_score note combo accuracy =
  note.base_score * combo
  *
  match accuracy with
  | Perfect -> 3
  | Great -> 2
  | Good -> 1
  | Miss -> 0

let calc_accuracy note time_hit =
  let time_diff = abs (time_hit - note.time) in
  if time_diff < 200 then Perfect
  else if time_diff < 400 then Great
  else if time_diff < miss_window then Good
  else Miss
