open Finalproject

let width = 1280
let height = 720
let score = ref 0
let valid_press = ref true
let play_game = ref false

(* delete later; here to confirm button presses work *)
let counters = Array.make Constants.num_notes 0

let spread_x_positions num_els el_width =
  let screen_width = Raylib.get_screen_width () |> float_of_int in
  let gap =
    (screen_width -. (float_of_int num_els *. el_width))
    /. (float_of_int num_els +. 1.)
  in
  num_els |> Utils.make_list |> List.map float_of_int
  |> List.map (fun value -> (value *. gap) +. ((value -. 1.) *. el_width))

let setupTitle () =
  let open Raylib in
  init_window width height "Title Screen";
  set_target_fps 60;
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
  init_window width height "Tile Game";
  init_audio_device ();
  let music = load_music_stream "data/country.mp3" in
  play_music_stream music;

  let x_pos = spread_x_positions Constants.num_notes Constants.note_width in

  let notes = List.map (fun x -> Note.create_note x 40.) x_pos in

  let buttons_y = (get_screen_height () / 2) + 80 |> float_of_int in
  let buttons =
    List.map (fun x -> Rectangle.create x buttons_y 80. 80.) x_pos
  in

  set_target_fps 60;

  (false, notes, buttons, music)

let draw notes buttons =
  let open Raylib in
  let updated_notes = List.map Note.update notes in
  let _ =
    List.map (fun note -> draw_rectangle_rec note Color.black) updated_notes
  in
  ();

  let _ = List.map (fun key -> draw_rectangle_rec key Color.blue) buttons in
  ();

  let handle_key_press note button key =
    (if is_key_down key then
       let () = draw_rectangle_rec button Color.red in
       if !valid_press then
         let collision = get_collision_rec note button in
         let points = collision |> Rectangle.width |> floor |> int_of_float in
         begin
           score := !score + points;
           if points = 0 then valid_press := false
         end);
    if is_key_released key then begin
      valid_press := true;
      let idx_opt = List.find_index (fun x -> x = key) Constants.bindings in
      let idx =
        match idx_opt with
        | None -> failwith "Cannot find key binding."
        | Some i -> i
      in
      counters.(idx) <- counters.(idx) + 1
    end
  in

  let _ =
    Utils.map3 handle_key_press updated_notes buttons Constants.bindings
  in

  let _ =
    let x_positions =
      spread_x_positions Constants.num_notes 50.
      |> List.map int_of_float |> Array.of_list
    in
    let y_pos = (get_screen_height () / 2) + 105 in
    Array.map2
      (fun count x -> draw_text (string_of_int count) x y_pos 40 Color.black)
      counters x_positions
  in
  draw_text
    ("Score: " ^ string_of_int !score)
    (get_screen_width () - 350)
    50 40 Color.black;
  draw_fps 5 5

let rec loop (_, notes, buttons, music) =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let pause =
        if Raylib.is_key_down Raylib.Key.Space then begin
          Raylib.draw_text "Paused" 300 200 40 Raylib.Color.red;
          true
        end
        else false
      in
      if not pause then (
        let open Raylib in
        update_music_stream music;
        begin_drawing ();
        clear_background Color.raywhite;

        draw notes buttons;

        end_drawing ();

        loop (pause, notes, buttons, music))
      else loop (pause, notes, buttons, music)

let () =
  setupTitle () |> title_loop;
  if !play_game then setupGame () |> loop else print_string "You ended the game"
