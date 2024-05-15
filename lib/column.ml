open Raylib
open Note

type t = Note.t list ref * Rectangle.t * float

let rec remove_from_list lst index =
  match lst with
  | [] -> []
  | h :: t -> if index = 0 then t else h :: remove_from_list t (index - 1)

let fst (a, _, _) = a
let snd (_, a, _) = a
let trd (_, _, a) = a
let get_notes (a, _, _) = !a
let get_button col = snd col

let create (pos : float) : t =
  let y = Constants.height * 3 / 4 |> float_of_int in
  let button = Rectangle.create pos y 80. 40. in
  (ref [], button, pos)

let add_note (col : t) =
  fst col := Note.create_note (trd col) 40. :: get_notes col

let increment_notes (col : t) =
  let notes = get_notes col in
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
  match get_notes col with
  | [] -> -1
  | h :: t ->
      let collision = get_collision_rec (Note.get_sprite h) button in
      if collision |> Rectangle.height <> 0. then index
      else find_current_note (ref t, button, trd col) (index + 1)

let key_pressed (col : t) =
  let note_index = find_current_note col 0 in
  if note_index = -1 then Miss
  else
    let note = List.nth (get_notes col) note_index in
    let button = snd col in
    let collision = get_collision_rec (Note.get_sprite note) button in
    let overlap =
      (collision |> Rectangle.height)
      /. (note |> Note.get_sprite |> Rectangle.height)
    in
    begin
      Note.hit note;
      fst col := remove_from_list (get_notes col) note_index
    end;
    overlap |> Note.calc_accuracy

let rec check_remove_notes notes index =
  match notes with
  | [] -> -1
  | h :: t ->
      if Rectangle.y h > 720. then index else check_remove_notes t (index + 1)

let remove_dead_notes (col : t) =
  let index = check_remove_notes (List.map Note.get_sprite (get_notes col)) 0 in
  if index = -1 then () else fst col := remove_from_list (get_notes col) index

let reset (col : t) = fst col := []
