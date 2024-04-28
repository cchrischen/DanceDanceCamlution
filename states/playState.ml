open Finalproject

type t = int

let buffer = ref None
let set_buffer (t : t) = buffer := Some t
let name = "play"
let set_default = true
let score = ref 0
let combo = ref 0
let valid_press = ref true
let button_frames = Sprite.create_sprites 80 160 6 4
let button_frame_num = ref 0

let spread_x_positions num_els el_width =
  let screen_width = Constants.width |> float_of_int in
  let gap = el_width in
  num_els |> Utils.make_list |> List.map float_of_int
  |> List.map (fun value ->
         ((value -. ((float_of_int num_els /. 2.) +. 1.)) *. gap)
         +. (screen_width /. 2.))

let notes =
  let x_pos = spread_x_positions Constants.num_notes Constants.note_width in
  List.map (fun x -> Note.create_note x 40.) x_pos

let buttons =
  let x_pos = spread_x_positions Constants.num_notes Constants.note_width in
  let buttons_y = Constants.height * 3 / 4 |> float_of_int in
  List.map (fun x -> Raylib.Rectangle.create x buttons_y 80. 40.) x_pos

let music = Beatmap.Song.init "data/better-day.mp3"
let init () = ()
let check_combo_break break_combo = if break_combo then combo := 0

let handle_key_press note button key =
  let open Raylib in
  if is_key_down key then begin
    draw_rectangle_rec button Constants.holding_button_color;
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
  end

let update () =
  let open Raylib in
  ignore (List.map check_combo_break (List.map Note.update notes));
  Raylib.update_music_stream music.audio_source;
  let mouse_pos = (get_mouse_x (), get_mouse_y ()) in
  let dist = Utils.distance mouse_pos (60, (Constants.height - 60)) in
  if is_key_pressed Key.P then Some "pause"
  else if is_mouse_button_pressed MouseButton.Left && dist <= 50. then
    Some "settings"
  else None

let draw_background () =
  let open Raylib in
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

let draw_combo () =
  let open Raylib in
  draw_text
    (string_of_int !combo ^ "x")
    (get_screen_width () - 90)
    (get_screen_height () - 50)
    40
    (if !combo = 0 then Color.red else Color.gray)

let render () =
  let open Raylib in
  clear_background Constants.background_color;
  draw_background ();
  draw_combo ();
  ignore
    (List.map
       (fun key -> draw_rectangle_rec key Constants.button_color)
       buttons);
  ignore
    (List.map
       (fun note ->
         draw_rectangle_rec (Note.get_sprite note) Constants.note_color)
       notes);
  ignore (Utils.map3 handle_key_press notes buttons Constants.bindings);
  draw_circle 60 (Constants.height - 60) 50. Color.gray;
  draw_text
    ("Score: " ^ string_of_int !score)
    ((get_screen_width () * 17 / 20)
    - (String.length (string_of_int !score) * (get_screen_width () / 200)))
    20 30 Color.lightgray;
  draw_fps 5 5
