open DDC

type t = int

let buffer = ref None
let set_buffer (t : t) = buffer := Some t
let name = "settings"
let set_default = false
let menu_width = 750
let menu_height = 500
let keybind_buttons = ref []
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let sound_map : (string, Raylib.Sound.t) Hashtbl.t = Hashtbl.create 10

let load () =
  sprite_map := Sprite.initialize_sprites "data/sprites/settingstatesprites.csv";
  Hashtbl.add sound_map "button_unselect"
    (Raylib.load_sound "data/sounds/button_unselect.wav")

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

let home_button = ref (Button.make_rect_button (675, 400) 300 100)

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
        if
          is_mouse_button_pressed MouseButton.Left
          && Button.check_click (mx, my) button
        then handle_click i)
      !keybind_buttons;
    if Button.check_click (mx, my) !settings_button then (
      Raylib.play_sound (Hashtbl.find sound_map "button_unselect");
      match !buffer with
      | Some 1 -> Some "title"
      | Some 0 -> Some "play"
      | _ -> None)
    else if Button.check_click (mx, my) !home_button then Some "select"
    else None
  end

let draw_keybind_grid () =
  let open Raylib in
  let all_keys = Keybind.all_keybinds () in
  ignore
    (List.map
       (fun button ->
         if Button.check_hover (get_mouse_x (), get_mouse_y ()) button then
           Button.draw button (Color.create 230 145 0 255)
         else Button.draw button Color.orange)
       !keybind_buttons);
  ignore
    (List.mapi
       (fun i key ->
         let name, key = Keybind.to_string key in
         let button = List.nth !keybind_buttons i in
         let x, y, _, _ = Button.get_dims button in
         draw_text name (x - 150) (y + 10) 30 Color.black;
         draw_text key (x + 15) (y + 10) 30 Color.black)
       all_keys)

let settings_sprite mx my =
  if Button.overlap_detect (mx, my) !settings_button then
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "settings")
      1 10.
      (float_of_int (Constants.height - 110))
  else
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "settings")
      0 10.
      (float_of_int (Constants.height - 110))

let render () =
  let open Raylib in
  Sprite.draw_sprite (Hashtbl.find !sprite_map "musicselectscreen") 0 0. 0.;
  draw_rectangle (fst menu_nw_corner) (snd menu_nw_corner) menu_width
    menu_height Color.gray;
  Button.draw !settings_button Color.gray;
  settings_sprite (get_mouse_x ()) (get_mouse_y ());
  if Button.check_hover (get_mouse_x (), get_mouse_y ()) !home_button then
    Button.draw !home_button Color.maroon
  else Button.draw !home_button Color.red;
  let is_waiting, _, _ = !waiting in
  let text = if is_waiting then "Press a key" else "Settings" in
  draw_text text
    ((Constants.width / 2) - 125)
    ((Constants.height / 2) - 200)
    60 Color.black;
  draw_text "Home" 760 425 50 Color.black;
  draw_keybind_grid ()

let reset () = ()
