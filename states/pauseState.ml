let name = "pause"
let set_default = false
let init () = ()

let update () =
  let open Raylib in
  if is_key_pressed Key.P then Some "play" else None

let render () =
  let open Raylib in
  draw_text "PAUSED" 190 200 50 Color.lightgray
