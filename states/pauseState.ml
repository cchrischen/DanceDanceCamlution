open DDC

type t = int

let name = "pause"
let set_default = false
let init () = ()
let buffer = ref None
let set_buffer (t : t) = buffer := Some t

let update () =
  let open Raylib in
  if is_key_pressed (Keybind.get_keybind Keybind.PAUSE) then Some "play"
  else None

let render () =
  let open Raylib in
  draw_text "Paused" (Constants.width / 2) (Constants.height / 2) 40 Color.red

let reset () = ()
let load () = ()
