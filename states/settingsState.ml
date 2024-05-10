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

let waiting = ref (false, Keybind.BUTTON1, Raylib.Key.Null)

let handle_click index =
  let open Raylib in
  let all_keybinds = Keybind.all_keybinds () in
  let key = get_key_pressed () in
  let keyfind = List.nth all_keybinds index in
  waiting := (true, keyfind, key)

let update () =
  let open Raylib in
  let is_waiting, button, _ = !waiting in
  if is_waiting then begin
    let k = get_key_pressed () in
    if k <> Key.Null then begin
      Keybind.set_keybind button k;
      waiting := (false, button, k)
    end;
    None
  end
  else begin
    let mx = get_mouse_x () in
    let my = get_mouse_y () in
    List.iteri
      (fun i button ->
        if Button.check_click (mx, my) button then handle_click i)
      !keybind_buttons;
    if Button.check_click (mx, my) !settings_button then Some "play" else None
  end

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
         draw_text name (x - 150) (y + 10) 30 Color.black;
         draw_text key (x + 15) (y + 10) 30 Color.black)
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

let reset () = ()
