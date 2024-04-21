open Finalproject

let width = 1280
let height = 720
let score = ref 0
let combo = ref 0
let valid_press = ref true
let play_game = ref false
let pause = ref false
let fps = 60
let button_frames = Sprite.create_sprites 80 160 6 4
let button_frame_num = ref 0

(* let counters = Array.make Constants.num_notes 0 *)

let spread_x_positions num_els el_width =
  let screen_width = Raylib.get_screen_width () |> float_of_int in
  let gap = el_width in
  num_els |> Utils.make_list |> List.map float_of_int
  |> List.map (fun value ->
         ((value -. ((float_of_int num_els /. 2.) +. 1.)) *. gap)
         +. (screen_width /. 2.))

let setupTitle () =
  let open Raylib in
  init_window width height "Title Screen";
  set_target_fps fps;
  let gif = load_image "data/ICU.gif" in
  let texture = load_texture_from_image gif in
  unload_image gif;
  texture

let rec title_loop image =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let open Raylib in
      begin_drawing ();
      clear_background Color.raywhite;
      draw_text "Welcome to DanceDanceCamlution" 0 0 50 Color.black;
      draw_text "Press Enter to Play, Space to Pause, or Exit Window to Quit" 90
        100 30 Color.gold;
      draw_texture image 400 250 Color.white;
      end_drawing ();
      if is_key_pressed Key.Enter then begin
        play_game := not !play_game
      end
      else title_loop image

let setupGame () =
  let open Raylib in
  init_window width height "DanceDanceCamlution";
  init_audio_device ();
  let music = load_music_stream "data/music/newer_wave.mp3" in
  play_music_stream music;

  let x_pos = spread_x_positions Constants.num_notes Constants.note_width in

  let notes = List.map (fun x -> Note.create_note x 40.) x_pos in

  let buttons_y = get_screen_height () * 3 / 4 |> float_of_int in
  let buttons =
    List.map (fun x -> Rectangle.create x buttons_y 80. 40.) x_pos
  in

  set_target_fps 60;

  (pause, notes, buttons, music)

let check_combo_break (note, break_combo) =
  if break_combo then combo := 0;
  note

let draw notes buttons =
  let open Raylib in
  let updated_notes = List.map check_combo_break (List.map Note.update notes) in
  let _ =
    List.map
      (fun note ->
        draw_rectangle_rec (Note.get_sprite note) (Color.create 200 120 20 255))
      updated_notes
  in
  ();

  let _ =
    List.map
      (fun key -> draw_rectangle_rec key (Color.create 60 30 130 250))
      buttons
  in
  ();

  let handle_key_press note button key =
    if is_key_down key then begin
      draw_rectangle_rec button (Color.create 110 80 180 250);
      if !button_frame_num < Sprite.num_frames button_frames then begin
        Sprite.draw_sprite button_frames "data/sprites/button_press.png"
          !button_frame_num (Rectangle.x button)
          (Rectangle.y button -. 120.);
        button_frame_num := !button_frame_num + 1
      end
      else
        Sprite.draw_sprite button_frames "data/sprites/button_press.png" 0
          (Rectangle.x button)
          (Rectangle.y button -. 120.);

      if !valid_press && not (Note.has_been_hit note) then
        let collision = get_collision_rec (Note.get_sprite note) button in
        let overlap =
          (collision |> Rectangle.height)
          /. (note |> Note.get_sprite |> Rectangle.height)
        in
        if overlap = 0. then valid_press := false
        else begin
          let hit = load_sound "data/sounds/hit_note.wav" in
          play_sound hit;
          score :=
            !score + (overlap |> Note.calc_accuracy |> Note.calc_score !combo);
          combo := !combo + 1;
          Note.hit note
        end
    end;
    if is_key_released key then begin
      valid_press := true;
      button_frame_num := 0
      (* let idx_opt = List.find_index (fun x -> x = key) Constants.bindings in
         let idx = match idx_opt with | None -> failwith "Cannot find key
         binding." | Some i -> i in counters.(idx) <- counters.(idx) + 1 *)
    end
  in

  let _ =
    Utils.map3 handle_key_press updated_notes buttons Constants.bindings
  in

  (* let _ = let x_positions = spread_x_positions Constants.num_notes 50. |>
     List.map int_of_float |> Array.of_list in let y_pos = (get_screen_height ()
     / 2) + 105 in Array.map2 (fun count x -> draw_text (string_of_int count) x
     y_pos 40 Color.black) counters x_positions in *)
  draw_text
    ("Score: " ^ string_of_int !score)
    ((get_screen_width () * 17 / 20)
    - (String.length (string_of_int !score) * (get_screen_width () / 200)))
    20 30 Color.lightgray;
  draw_fps 5 5

let draw_background () =
  let open Raylib in
  clear_background (Color.create 70 70 90 255);
  draw_rectangle
    ((get_screen_width () / 2)
    - (Constants.num_notes * int_of_float Constants.note_width / 2))
    0
    (Constants.num_notes * int_of_float Constants.note_width)
    (get_screen_height ())
    (Color.create 77 27 70 200);
  let y_val = get_screen_height () * 3 / 4 in
  ignore
    (List.map
       (fun x ->
         draw_rectangle (int_of_float x) y_val
           (int_of_float Constants.note_width)
           ~-(int_of_float Constants.note_height - get_screen_height ())
           (Color.create 47 17 40 200))
       (spread_x_positions Constants.num_notes Constants.note_width));
  ignore
    (List.map
       (fun x ->
         draw_rectangle
           (int_of_float (x -. 2.5))
           y_val 5
           ~-(int_of_float Constants.note_height - get_screen_height ())
           (Color.create 27 17 30 240))
       (List.tl (spread_x_positions Constants.num_notes Constants.note_width)));
  draw_rectangle
    ((get_screen_width () / 2)
    - (Constants.num_notes * int_of_float Constants.note_width / 2)
    - 5)
    0 5 (get_screen_height ()) Color.black;
  draw_rectangle
    ((get_screen_width () / 2)
    + (Constants.num_notes * int_of_float Constants.note_width / 2))
    0 5 (get_screen_height ()) Color.black

let draw_combo combo =
  let open Raylib in
  draw_text
    (string_of_int !combo ^ "x")
    (get_screen_width () - 90)
    (get_screen_height () - 50)
    40
    (if !combo = 0 then Color.red else Color.gray)

let rec loop (pause, notes, buttons, music) =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      pause :=
        if Raylib.is_key_pressed Raylib.Key.Space && not !pause then true
        else if Raylib.is_key_pressed Raylib.Key.Space && !pause then false
        else !pause;
      if not !pause then (
        let open Raylib in
        update_music_stream music;
        begin_drawing ();
        draw_background ();
        draw notes buttons;

        draw_combo combo;

        end_drawing ();

        loop (pause, notes, buttons, music))
      else
        let open Raylib in
        begin_drawing ();
        clear_background Color.raywhite;
        Raylib.draw_text "Paused" (width / 2) (height / 2) 40 Raylib.Color.red;
        end_drawing ();
        loop (pause, notes, buttons, music)

let () =
  setupTitle () |> title_loop;
  if !play_game then setupGame () |> loop else print_string "You ended the game"
