open DDC
open Raylib

type t = int

let settings_button =
  ref
    (Button.make_circle_button
       ((Constants.width / 2) - 25, Constants.height - 125)
       50)

let name = "title"
let play_button_x = (float_of_int Constants.width /. 2.) -. 150.
let play_button_y = (float_of_int Constants.height /. 2.) -. 100.
let play_hit = ref false
let music_play = ref true
let settings_hit = ref false
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let set_default = true
let sound_map : (string, Raylib.Sound.t) Hashtbl.t = Hashtbl.create 10

let load () =
  sprite_map := Sprite.initialize_sprites "data/sprites/titlestatesprites.csv";
  Hashtbl.add sound_map "title_music"
    (Raylib.load_sound "data/music/newer_wave.mp3");
  Hashtbl.add sound_map "start_game"
    (Raylib.load_sound "data/sounds/start_game.wav");
  Raylib.set_sound_volume (Hashtbl.find sound_map "title_music") 0.25;
  if !music_play && not !settings_hit then
    Raylib.play_sound (Hashtbl.find sound_map "title_music")

let init () = ()
let buffer = ref None
let set_buffer (t : t) = buffer := Some t

let settings_sprite mx my =
  if Button.overlap_detect (mx, my) !settings_button then
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "settings")
      1
      (float_of_int ((Constants.width / 2) - 75))
      (float_of_int (Constants.height - 175))
  else
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "settings")
      0
      (float_of_int ((Constants.width / 2) - 75))
      (float_of_int (Constants.height - 175))

let update () =
  let mx = get_mouse_x () in
  let my = get_mouse_y () in
  if !play_hit then (
    play_hit := false;
    music_play := false;
    Raylib.stop_sound (Hashtbl.find sound_map "title_music");
    Raylib.play_sound (Hashtbl.find sound_map "start_game");
    Raylib.wait_time 0.25;
    Some "select")
  else if Button.check_click (mx, my) !settings_button then (
    settings_hit := true;
    music_play := false;
    Raylib.stop_sound (Hashtbl.find sound_map "title_music");
    Raylib.play_sound (Hashtbl.find sound_map "start_game");
    SettingsState.set_buffer 1;
    Some "settings")
  else None

let play_button_logic (mouse_x : int) (mouse_y : int)
    (mouse_button : Raylib.MouseButton.t) =
  let play_button_center_x, play_button_center_y =
    (play_button_x +. 128., play_button_y +. 128.)
  in
  let distance =
    sqrt
      (float_of_int
         ((mouse_x - int_of_float play_button_center_x)
          * (mouse_x - int_of_float play_button_center_x)
         + (mouse_y - int_of_float play_button_center_y)
           * (mouse_y - int_of_float play_button_center_y)))
  in
  if distance < 128. then (
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "play_button")
      1 play_button_x play_button_y;
    if Raylib.is_mouse_button_pressed mouse_button then play_hit := true)
  else
    Sprite.draw_sprite
      (Hashtbl.find !sprite_map "play_button")
      0 play_button_x play_button_y

let render () =
  Sprite.draw_sprite (Hashtbl.find !sprite_map "titlescreen") 0 0. 0.;
  draw_text "DanceDanceCamlution" 100 120 100 Color.raywhite;
  draw_text
    "Created by CamelCorp: Chris Chen, Daniel Xie, Shubham Mohole, Rishi \
     Yennu, Nam Anh Dang"
    15 (Constants.height - 30) 20 Color.raywhite;
  Button.draw !settings_button Color.gray;
  settings_sprite (get_mouse_x ()) (get_mouse_y ());
  play_button_logic (get_mouse_x ()) (get_mouse_y ()) MouseButton.Left

let reset () =
  sprite_map := Hashtbl.create 1;
  buffer := None
