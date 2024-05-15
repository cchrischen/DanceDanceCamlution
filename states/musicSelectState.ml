open DDC
open Raylib
open Raygui

type t = int

type music_gui_state = {
  mutable is_open : bool;
  mutable list_view_ex_active : int;
  mutable list_view_ex_focus : int;
  mutable list_view_ex_index : int;
}

let gui_state : music_gui_state =
  {
    is_open = true;
    list_view_ex_active = 0;
    list_view_ex_focus = 0;
    list_view_ex_index = 0;
  }

let directory = "data/music"
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let files_list = ref []
let name = "select"
let set_default = false
let home_button = Button.make_circle_button (1100, 400) 80
let buffer = ref None
let set_buffer (t : t) = buffer := Some t

let load () =
  sprite_map :=
    Sprite.initialize_sprites "data/sprites/musicselectscreensprites.csv"

let home_button_logic () =
  if
    Button.overlap_detect
      (Raylib.get_mouse_x (), Raylib.get_mouse_y ())
      home_button
  then (
    draw_circle 1100 400 85. Raylib.Color.darkgray;
    Button.draw home_button Raylib.Color.raywhite)
  else (
    draw_circle 1100 400 85. Raylib.Color.black;
    Button.draw home_button Raylib.Color.gray);
  draw_text "Home" 1065 390 30 Raylib.Color.black

let init () = ()

let update () =
  let files = Raylib.load_directory_files_ex directory ".mp3" false in
  files_list := Raylib.FilePathList.files files;
  Raylib.unload_directory_files files;
  if
    Button.check_click
      (Raylib.get_mouse_x (), Raylib.get_mouse_y ())
      home_button
  then (
    Raylib.play_sound (Raylib.load_sound "data/sounds/start_game.wav");
    Some "title")
  else if gui_state.is_open || gui_state.list_view_ex_active = -1 then None
  else
    let _ =
      Beatmap.Song.create_beatmap
        (List.nth !files_list gui_state.list_view_ex_active)
    in
    let () =
      PlayState.set_buffer (List.nth !files_list gui_state.list_view_ex_active)
    in
    Some "play"

let difficulty_select () =
  draw_text "Select Difficulty:" 40 210 30 Color.raywhite;
  let easy = button (Rectangle.create 120. 300.0 100. 50.0) "Easy" in
  let medium = button (Rectangle.create 120. 400.0 100. 50.0) "Medium" in
  let hard = button (Rectangle.create 120. 500.0 100. 50.0) "Hard" in
  if easy then Constants.diff := 3;
  if medium then Constants.diff := 2;
  if hard then Constants.diff := 1

let render () =
  Sprite.draw_sprite (Hashtbl.find !sprite_map "musicselectscreen") 0 0. 0.;
  draw_text "Song Select" ((Constants.width / 2) - 300) 50 100 Color.raywhite;
  difficulty_select ();
  home_button_logic ();
  let rect =
    Rectangle.create
      ((float_of_int Constants.width /. 2.) -. 300.)
      ((float_of_int Constants.height /. 2.) -. 150.)
      600. 400.0
  in
  let list_view_ex_active, list_view_ex_focus, list_view_ex_index =
    list_view_ex rect !files_list gui_state.list_view_ex_focus
      gui_state.list_view_ex_index gui_state.list_view_ex_active
  in
  let is_open =
    not
      (button
         (Rectangle.create
            ((float_of_int Constants.width /. 2.) -. 300.)
            600.0 600. 50.0)
         "Done")
  in
  gui_state.is_open <- is_open;
  gui_state.list_view_ex_index <- list_view_ex_index;
  gui_state.list_view_ex_focus <- list_view_ex_focus;
  gui_state.list_view_ex_active <- list_view_ex_active;
  ()

let reset () =
  gui_state.list_view_ex_index <- 0;
  gui_state.list_view_ex_focus <- 0;
  gui_state.list_view_ex_index <- 0;
  gui_state.is_open <- true;
  files_list := [];
  buffer := None
