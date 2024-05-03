type t = int

let name = "title"
let set_default = true

let texture =
  "/data/ICU.gif" |> Raylib.load_image |> Raylib.load_texture_from_image

let init () = ()
let buffer = ref None
let set_buffer (t : t) = buffer := Some t

let update () =
  let open Raylib in
  if is_key_pressed Key.Enter then Some "play" else None

let render () =
  let open Raylib in
  clear_background Color.raywhite;
  draw_text "Welcome to DanceDanceCamlution" 0 0 50 Color.black;
  draw_text "Press Enter to Play, Space to Pause, or Exit Window to Quit" 90 100
    30 Color.gold;
  draw_texture texture 400 250 Color.white
