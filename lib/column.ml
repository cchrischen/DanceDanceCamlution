open Raylib
open Note
open Constants

type t = Note.t list * Rectangle.t

let create (pos : float) : t =
  let y = get_screen_height () * 3 / 4 |> float_of_int in
  let button = Rectangle.create pos y 80. 40. in
  ([], button)

let increment_notes (col : t) =
  let notes = fst col in
  let _ =
    List.map
      (fun note ->
        let sprite = Note.get_sprite note in
        Rectangle.set_y sprite (Rectangle.y sprite +. Constants.note_speed))
      notes
  in
  ()

let rec find_current_note (col : t) (index : int) =
  let button = snd col in
  match fst col with
  | [] -> -1
  | h :: t ->
      let collision = get_collision_rec (Note.get_sprite h) button in
      if
        (collision |> Rectangle.height)
        /. (h |> Note.get_sprite |> Rectangle.height)
        <> 0.
      then index
      else find_current_note (t, button) (index + 1)

let key_pressed (col : t) =
  let note_index = find_current_note col 0 in
  if note_index = -1 then Miss
  else
    let note = List.nth (fst col) note_index in
    let button = snd col in
    let collision = get_collision_rec (Note.get_sprite note) button in
    let overlap =
      (collision |> Rectangle.height)
      /. (note |> Note.get_sprite |> Rectangle.height)
    in
    begin
      let hit = load_sound "data/sounds/hit_note.wav" in
      play_sound hit;
      Note.hit note
    end;
    overlap |> Note.calc_accuracy
