open Finalproject

let width = 1280
let height = 720
let score = ref 0
let combo = ref 0
let valid_press = ref true

(* delete later; here to confirm button presses work *)
let counters = Array.make Constants.num_notes 0

(**[buttons_y] is the y position of the top left of the buttons. Is screen width
   / 2 + 80*)
let buttons_y = 440.

(* let time_travel_note_to_button = (buttons_y -. Constants.note_heigth) /.
   Constants.note_speed /. float_of_int Constants.target_fps *)

let spread_x_positions num_els el_width =
  let screen_width = Raylib.get_screen_width () |> float_of_int in
  let gap =
    (screen_width -. (float_of_int num_els *. el_width))
    /. (float_of_int num_els +. 1.)
  in
  num_els |> Utils.make_list |> List.map float_of_int
  |> List.map (fun value -> (value *. gap) +. ((value -. 1.) *. el_width))

let setup () =
  let open Raylib in
  init_window width height "Tile Game";

  let music = Beatmap.Song.init "data/better-day.mp3" in

  let x_pos = spread_x_positions Constants.num_notes Constants.note_width in

  let notes = List.map (fun x -> Note.create_note x 40.) x_pos in
  let buttons =
    List.map (fun x -> Rectangle.create x buttons_y 80. 80.) x_pos
  in
  set_target_fps Constants.target_fps;
  (false, notes, buttons, music)

let check_combo_break (note, break_combo) =
  if break_combo then combo := 0;
  note

let draw notes buttons =
  let open Raylib in
  let updated_notes = List.map check_combo_break (List.map Note.update notes) in
  let _ =
    List.map
      (fun note -> draw_rectangle_rec (Note.get_sprite note) Color.black)
      updated_notes
  in
  ();

  let _ = List.map (fun key -> draw_rectangle_rec key Color.blue) buttons in
  ();

  let handle_key_press note button key =
    (if is_key_down key then
       let () = draw_rectangle_rec button Color.red in
       if !valid_press && not (Note.has_been_hit note) then
         let collision = get_collision_rec (Note.get_sprite note) button in
         let overlap =
           (collision |> Rectangle.height)
           /. (note |> Note.get_sprite |> Rectangle.height)
         in
         if overlap = 0. then valid_press := false
         else begin
           score :=
             !score + (overlap |> Note.calc_accuracy |> Note.calc_score !combo);
           combo := !combo + 1;
           Note.hit note
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


let draw_combo combo =
  let open Raylib in
  draw_text
    (string_of_int !combo ^ "x")
    (get_screen_width () - 125)
    (get_screen_height () - 100)
    40
    (if !combo = 0 then Color.red else Color.black)

let rec loop (pause, notes, buttons, (music : Beatmap.Song.song)) =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let open Raylib in
      update_music_stream music.audio_source;
      let pause = if is_key_pressed Key.Space then not pause else pause in
      let is_on_note_onset = Beatmap.Song.is_on_next_note music 0. in
      begin_drawing ();
      clear_background Color.raywhite;

      draw notes buttons;

      draw_combo combo;

      end_drawing ();
      let _ =
        if is_on_note_onset then
          let _ = draw_text "Note detected" ((width / 2) - 50) 0 20 Color.red in
          Beatmap.Song.inc_note music
        else ()
      in

      loop (pause, notes, buttons, music)

let () = setup () |> loop
