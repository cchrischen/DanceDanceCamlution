open Raylib

type accuracy =
  | Perfect
  | Great
  | Good
  | Miss

type t = {
  sprite : Rectangle.t;
  mutable has_been_hit : bool;
  speed : float;
}

let create_note x y =
  {
    sprite = Rectangle.create x y Constants.note_width Constants.note_height;
    has_been_hit = false;
    speed = Constants.note_speed;
  }

let update note =
  let break_combo = ref false in
  let sprite = note.sprite in
  Rectangle.(set_y sprite (y sprite +. note.speed));
  if Rectangle.y sprite > (Constants.height |> float_of_int) then begin
    if not note.has_been_hit then break_combo := true
  end;
  !break_combo

let hit note =
  if not note.has_been_hit then Rectangle.set_height note.sprite 0.;
  note.has_been_hit <- true

let get_sprite note = note.sprite
let has_been_hit note = note.has_been_hit
let get_speed note = note.speed

let calc_score combo accuracy =
  Constants.base_score * (combo + 1)
  *
  match accuracy with
  | Perfect -> 3
  | Great -> 2
  | Good -> 1
  | Miss -> 0

let calc_accuracy overlap =
  if overlap < 0.3 then Good else if overlap < 0.7 then Great else Perfect
