open Finalproject

type t = int

let buffer = ref None
let set_buffer (t : t) = buffer := Some t
let name = "settings"
let set_default = false
let is_menu_open = ref false
let menu_width = 750
let menu_height = 500
let keybind_buttons = ref []
let select_key_modal = ref false

let init () =
  let locations =
    [
      (425, 225, 50, 50);
      (425, 300, 50, 50);
      (425, 375, 50, 50);
      (425, 450, 50, 50);
      (425, 525, 50, 50);
    ]
  in
  let buttons =
    List.map (fun (x, y, w, h) -> Button.make_rect_button (x, y) w h) locations
  in
  keybind_buttons := buttons

let settings_button =
  ref (Button.make_circle_button (60, Constants.height - 60) 50)

let menu_nw_corner =
  ( (Constants.width / 2) - (menu_width / 2),
    (Constants.height / 2) - (menu_height / 2) )

let update () =
  if Button.check_click !settings_button then Some "play" else None

let draw_keybind_grid () =
  let open Raylib in
  let all_keys = Keybind.all_keybinds () in
  ignore
    (List.map (fun button -> Button.draw button Color.orange) !keybind_buttons);
  ignore
    (List.mapi
       (fun i key ->
         let name, key = Keybind.to_string key in
         let button = List.nth !keybind_buttons i in
         let x, y, _, _ = Button.get_dims button in
         draw_text name (x - 150) (y + 10) 30 Color.black)
       all_keys)

let render () =
  let open Raylib in
  draw_rectangle (fst menu_nw_corner) (snd menu_nw_corner) menu_width
    menu_height Color.gray;
  Button.draw !settings_button Color.gray;
  draw_text "Settings"
    ((Constants.width / 2) - 125)
    ((Constants.height / 2) - 200)
    60 Color.black;
  draw_keybind_grid ()
