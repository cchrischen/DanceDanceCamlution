let name = "title"
let set_default = true
let init () = ()

let update () =
  let open Raylib in
  if is_key_pressed Key.Enter then Some "play" else None

let render () =
  let open Raylib in
  clear_background Color.raywhite;
  draw_text "DDC" 190 200 75 Color.black
