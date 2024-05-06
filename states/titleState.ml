open Finalproject

type t = int

let name = "title"
let play_button_x = (float_of_int Constants.width /. 2.) -. 150.
let play_button_y = (float_of_int Constants.height /. 2.) -. 100.
let play_hit = ref false
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let set_default = true
let sound_map : (string, Raylib.Sound.t) Hashtbl.t = Hashtbl.create 10

let init () =
  sprite_map := Sprite.initialize_sprites "data/sprites/titlestatesprites.csv";
  Hashtbl.add sound_map "title_music"
    (Raylib.load_sound "data/music/newer_wave.mp3");
  Hashtbl.add sound_map "start_game"
    (Raylib.load_sound "data/sounds/start_game.wav");
  Raylib.set_sound_volume (Hashtbl.find sound_map "title_music") 0.25;
  if not !play_hit then Raylib.play_sound (Hashtbl.find sound_map "title_music")

let buffer = ref None
let set_buffer (t : t) = buffer := Some t

let update () =
  if !play_hit then (
    Raylib.stop_sound (Hashtbl.find sound_map "title_music");
    Raylib.play_sound (Hashtbl.find sound_map "start_game");
    Raylib.wait_time 0.25;
    Some "musicSelect")
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
  let open Raylib in
  Sprite.draw_sprite (Hashtbl.find !sprite_map "titlescreen") 0 0. 0.;
  draw_text "DanceDanceCamlution" 100 120 100 Color.raywhite;
  draw_text
    "Created by CamelCorp: Chris Chen, Daniel Xie, Shubham Mohole, Rishi \
     Yennu, Nam Anh Dang"
    15 (Constants.height - 30) 20 Color.raywhite;
  play_button_logic (get_mouse_x ()) (get_mouse_y ()) MouseButton.Left
