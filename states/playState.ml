open Finalproject

type t = string

let buffer = ref (Some "data/music/better-day.mp3")
let set_buffer (t : t) = buffer := Some t
let name = "play"
let set_default = true
let score = ref 0
let combo = ref 0
let valid_press = ref true
let counter_array = Array.make 4 0
let button_frame_num = ref 0
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let sound_map : (string, Raylib.Sound.t) Hashtbl.t = Hashtbl.create 10

let key_binding_map =
  let empty = Hashtbl.create 4 in
  let rec add_keys acc = function
    | [] -> empty
    | key :: t ->
        Hashtbl.add empty key ("K" ^ string_of_int acc);
        add_keys (acc + 1) t
  in
  add_keys 1 (Keybind.play_keybinds ())

let settings_button =
  ref (Button.make_circle_button (60, Constants.height - 60) 50)

let spread_x_positions num_els el_width =
  let screen_width = Constants.width |> float_of_int in
  let gap = el_width in
  num_els |> Utils.make_list |> List.map float_of_int
  |> List.map (fun value ->
         ((value -. ((float_of_int num_els /. 2.) +. 1.)) *. (gap +. 5.))
         +. (screen_width /. 2.))

let y_pos =
  let spread_y_positions num_els =
    let screen_height = Constants.height |> float_of_int in
    let gap = 64. in
    num_els |> Utils.make_list |> List.map float_of_int
    |> List.map (fun value ->
           ((value -. ((float_of_int num_els /. 2.) +. 1.)) *. (gap +. 5.))
           +. (screen_height /. 2.))
    |> Array.of_list
  in
  spread_y_positions Constants.num_columns

(* let notes = let x_pos = spread_x_positions Constants.num_columns
   Constants.note_width in List.map (fun x -> Note.create_note x 40.) x_pos

   let buttons = let x_pos = spread_x_positions Constants.num_columns
   Constants.note_width in let buttons_y = Constants.height * 3 / 4 |>
   float_of_int in List.map (fun x -> Raylib.Rectangle.create x buttons_y 80.
   40.) x_pos *)
let x_pos = spread_x_positions Constants.num_columns Constants.note_width
let columns = List.map (fun x -> Column.create x) x_pos
let time = ref 0
let music = ref None

let init () =
  Random.init 69420;
  music := Some (Beatmap.Song.init (Option.get !buffer));
  sprite_map := Sprite.initialize_sprites "data/sprites/playstatesprites.csv";
  Hashtbl.add sound_map "hit_sound"
    (Raylib.load_sound "data/sounds/hit_sound.wav");
  Hashtbl.add sound_map "hit_note"
    (Raylib.load_sound "data/sounds/hit_note.wav")

let check_combo_break break_combo = if break_combo then combo := 0

let draw_key_counter_text () =
  ignore
    (List.map
       (fun num ->
         let n = num - 1 in
         Raylib.draw_text
           (string_of_int counter_array.(n))
           (Constants.width - 57)
           (int_of_float y_pos.(n) + 40)
           20 Raylib.Color.white;
         Raylib.draw_text
           ("K" ^ string_of_int num)
           (Constants.width - 60)
           (int_of_float y_pos.(n) + 10)
           20 Raylib.Color.white)
       (Utils.make_list 4))

let handle_key_press col key =
  let open Raylib in
  let button = Column.get_button col in
  let counter_frames = Hashtbl.find !sprite_map "key_counter" in
  let button_frames = Hashtbl.find !sprite_map "button_press" in
  if is_key_down key then begin
    (match Hashtbl.find key_binding_map (Keybind.raylib_to_keybind key) with
    | "K1" ->
        Sprite.draw_sprite counter_frames 1
          (float_of_int (Constants.width - 80))
          y_pos.(0)
    | "K2" ->
        Sprite.draw_sprite counter_frames 1
          (float_of_int (Constants.width - 80))
          y_pos.(1)
    | "K3" ->
        Sprite.draw_sprite counter_frames 1
          (float_of_int (Constants.width - 80))
          y_pos.(2)
    | "K4" ->
        Sprite.draw_sprite counter_frames 1
          (float_of_int (Constants.width - 80))
          y_pos.(3)
    | _ -> ());
    draw_rectangle_rec button Constants.holding_button_color;

    if !button_frame_num < Sprite.num_frames button_frames then begin
      Sprite.draw_sprite button_frames !button_frame_num (Rectangle.x button)
        (Rectangle.y button -. 120.);
      button_frame_num := !button_frame_num + 1
    end
    else
      Sprite.draw_sprite button_frames 13 (Rectangle.x button)
        (Rectangle.y button -. 120.);

    if !valid_press then
      let acc = Column.key_pressed col in
      if acc = Miss then begin
        valid_press := false;
        play_sound (Hashtbl.find sound_map "hit_sound") (* combo := 0 *)
      end
      else begin
        score := !score + (acc |> Note.calc_score !combo);
        combo := !combo + 1;
        play_sound (Hashtbl.find sound_map "hit_note")
      end
  end;
  if is_key_released key then begin
    valid_press := true;
    button_frame_num := 0
  end;
  if is_key_pressed key then begin
    match Hashtbl.find key_binding_map (Keybind.raylib_to_keybind key) with
    | "K1" -> counter_array.(0) <- counter_array.(0) + 1
    | "K2" -> counter_array.(1) <- counter_array.(1) + 1
    | "K3" -> counter_array.(2) <- counter_array.(2) + 1
    | "K4" -> counter_array.(3) <- counter_array.(3) + 1
    | _ -> ()
  end

let draw_key_counters () =
  let counter_frames = Hashtbl.find !sprite_map "key_counter" in
  let (x_pos : int) = Constants.width - 80 in
  ignore
    (Array.map
       (fun y -> Sprite.draw_sprite counter_frames 0 (float_of_int x_pos) y)
       y_pos)

let drop_notes columns music =
  let is_on_note_onset = Beatmap.Song.is_on_next_note music Constants.offset in
  if is_on_note_onset then (
    let note = Random.int 4 in
    print_endline "bruh";
    Beatmap.Song.inc_note music;
    Column.add_note (List.nth columns note))
  else ()

let update () =
  let open Raylib in
  ignore
    (List.map
       (List.map check_combo_break)
       (List.map (List.map Note.update) (List.map Column.get_notes columns)));
  time := !time + 1;
  let mx = get_mouse_x () in
  let my = get_mouse_y () in
  if is_key_pressed (Keybind.get_keybind Keybind.PAUSE) then Some "pause"
  else if Button.check_click (mx, my) !settings_button then Some "settings"
  else if Beatmap.Song.is_song_over (Option.get !music) then
    let _ = GameOverState.set_buffer !score in
    Some "over"
  else
    let _ = Raylib.update_music_stream (Option.get !music).audio_source in
    let _ = drop_notes columns (Option.get !music) in
    None

let draw_background () =
  let open Raylib in
  Sprite.draw_sprite (Hashtbl.find !sprite_map "background") 0 0. 0.;
  draw_rectangle
    ((get_screen_width () / 2)
    - (Constants.num_columns * int_of_float Constants.note_width / 2)
    - 15)
    0
    ((Constants.num_columns * int_of_float Constants.note_width) + 20)
    (get_screen_height ())
    (Color.create 42 15 71 250);
  let y_val = get_screen_height () * 3 / 4 in
  ignore
    (List.map
       (fun x ->
         draw_rectangle (int_of_float x) y_val
           (int_of_float Constants.note_width)
           ~-(int_of_float Constants.note_height - get_screen_height ())
           (Color.create 57 17 90 200))
       (spread_x_positions Constants.num_columns Constants.note_width));
  ignore
    (List.map
       (fun x ->
         draw_rectangle
           (int_of_float (x -. 5.))
           0 5 (get_screen_height ()) Color.black)
       (List.tl (spread_x_positions Constants.num_columns Constants.note_width)));

  draw_rectangle
    ((get_screen_width () / 2)
    - (Constants.num_columns * int_of_float Constants.note_width / 2)
    - 15)
    0 5 (get_screen_height ()) Color.black;
  draw_rectangle
    ((get_screen_width () / 2)
    + (Constants.num_columns * int_of_float Constants.note_width / 2)
    + 5)
    0 5 (get_screen_height ()) Color.black;
  draw_rectangle
    ((get_screen_width () / 2)
    - (Constants.num_columns * int_of_float Constants.note_width / 2)
    - 10)
    (y_val - 5)
    ((Constants.num_columns * int_of_float Constants.note_width) + 15)
    5 Color.raywhite

let draw_combo_and_score () =
  let open Raylib in
  draw_text
    (string_of_int !combo ^ "x")
    (get_screen_width () - 80
    - (String.length (string_of_int !combo) * (get_screen_width () / 100)))
    (get_screen_height () - 60)
    50
    (if !combo = 0 then Color.red else Color.gray);
  draw_text
    ("Score: " ^ string_of_int !score)
    ((get_screen_width () * 16 / 20)
    - (String.length (string_of_int !score) * (get_screen_width () / 200)))
    20 40 Color.lightgray

let render_col col index =
  let open Raylib in
  let notes = Column.get_notes col in
  let button = Column.get_button col in
  let _ = draw_rectangle_rec button Constants.button_color in
  let _ =
    List.map
      (fun note ->
        draw_rectangle_rec (Note.get_sprite note) Constants.note_color)
      notes
  in
  ();
  ignore
    (List.map
       (fun note ->
         draw_rectangle_rec (Note.get_sprite note) Constants.note_color)
       notes);
  let keys_buttons = Keybind.play_keybinds () in
  let raylib_key_buttons =
    List.map (fun key -> Keybind.get_keybind key) keys_buttons
  in
  ignore (handle_key_press col (List.nth raylib_key_buttons index))

let render () =
  let open Raylib in
  clear_background Constants.background_color;
  draw_background ();
  draw_combo_and_score ();
  draw_key_counters ();
  for i = 0 to 3 do
    render_col (List.nth columns i) i;
    Column.remove_dead_notes (List.nth columns i)
  done;
  Button.draw !settings_button Color.gray;
  draw_key_counter_text ();
  draw_fps 5 5
