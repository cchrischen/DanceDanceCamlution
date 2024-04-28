open Finalproject

let name = "settings"
let set_default = true
let init () = ()
let is_menu_open = ref false
let menu_width = 750
let menu_height = 500

let menu_nw_corner =
  ( (Constants.width / 2) - (menu_width / 2),
    (Constants.height / 2) - (menu_height / 2) )

let update () =
  let open Raylib in
  if is_key_pressed Keybind.(get_keybind PAUSE) then Some "play" else None

let render () =
  let open Raylib in
  draw_rectangle (fst menu_nw_corner) (snd menu_nw_corner) menu_width
    menu_height Color.gray;
  draw_text "Settings"
    ((Constants.width / 2) - 100)
    ((Constants.height / 2) - 200)
    60 Color.black
