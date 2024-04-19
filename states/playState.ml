open Finalproject

let name = "play"
let set_default = true
let note = Note.create_note 25. 25.
let init () = ()

let update () =
  let open Raylib in
  let _ = Note.update note in
  if is_key_pressed Key.P then Some "pause" else None

let render () =
  let open Raylib in
  clear_background Color.raywhite;
  draw_rectangle_rec (Note.get_sprite note) Color.black
