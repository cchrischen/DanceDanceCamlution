open Finalproject

let name = "pause"
let set_default = false
let init () = ()

let update () =
  let open Raylib in
  if is_key_pressed Key.P then Some "play" else None

let render () =
  let open Raylib in
  draw_text "Paused" (Constants.width / 2) (Constants.height / 2) 40 Color.red
