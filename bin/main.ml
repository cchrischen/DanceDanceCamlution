<<<<<<< HEAD
let width = 800
let height = 450
=======
let width = 1280
let height = 720
let score = ref 0
let counter_a = ref 0
let counter_b = ref 0
let counter_c = ref 0
let counter_d = ref 0
let speed = 10.0
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa

let setup () =
  let open Raylib in
  init_window width height "raylib [shapes] example - collision area";
<<<<<<< HEAD
  let box_a = ref (Rectangle.create 10.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_b = ref (Rectangle.create 250.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_c = ref (Rectangle.create 500.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_d = ref (Rectangle.create 700.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  set_target_fps 60;
  (false, box_a, box_b, box_c, box_d)
=======
  init_audio_device ();
  let music = load_music_stream "data/country.mp3" in
  play_music_stream music;
  let box_a =
    ref
      ( Rectangle.create
          (Float.of_int ((get_screen_width () / 2) - 240))
          (Float.of_int 0) 80.0 200.0,
        speed )
  in
  let box_b =
    ref
      ( Rectangle.create
          (Float.of_int ((get_screen_width () / 2) - 120))
          (Float.of_int 0) 80.0 200.0,
        speed )
  in
  let box_c =
    ref
      ( Rectangle.create
          (Float.of_int (get_screen_width () / 2))
          (Float.of_int 0) 80.0 200.0,
        speed )
  in
  let box_d =
    ref
      ( Rectangle.create
          (Float.of_int ((get_screen_width () / 2) + 120))
          (Float.of_int 0) 80.0 200.0,
        speed )
  in
  let box_aa =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) - 240))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_bb =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) - 120))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_cc =
    Rectangle.create
      (Float.of_int (get_screen_width () / 2))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_dd =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) + 120))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  set_target_fps 60;
  (false, box_a, box_b, box_c, box_d, box_aa, box_bb, box_cc, box_dd, music)
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa

let reset_box_cond box =
  let open Raylib in
  Rectangle.(
    y (fst !box) +. height (fst !box) >= Float.of_int (get_screen_height ())
    || y (fst !box) <= 0.0)

<<<<<<< HEAD
let rec loop (pause, box_a, box_b, box_c, box_d) =
=======
let rec loop
    (pause, box_a, box_b, box_c, box_d, box_aa, box_bb, box_cc, box_dd, music) =
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let open Raylib in
<<<<<<< HEAD
=======
      update_music_stream music;
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
      (* Move box if not paused *)
      (if not pause then
         Rectangle.(set_y (fst !box_a) (y (fst !box_a) +. snd !box_a)));
      Rectangle.(set_y (fst !box_b) (y (fst !box_b) +. snd !box_b));
      Rectangle.(set_y (fst !box_c) (y (fst !box_c) +. snd !box_c));
      Rectangle.(set_y (fst !box_d) (y (fst !box_d) +. snd !box_d));

      (* Bounce box on x screen limits *)
      box_a :=
        if reset_box_cond box_a then
          let new_box =
<<<<<<< HEAD
            ref (Rectangle.create 10.0 (Float.of_int 0) 50.0 200.0, 4.0)
=======
            ref
              ( Rectangle.create
                  (Float.of_int ((get_screen_width () / 2) - 240))
                  (Float.of_int 0) 80.0 200.0,
                speed )
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
          in
          !new_box
        else !box_a;
      box_b :=
        if reset_box_cond box_b then
          let new_box =
<<<<<<< HEAD
            ref (Rectangle.create 250.0 (Float.of_int 0) 50.0 200.0, 4.0)
=======
            ref
              ( Rectangle.create
                  (Float.of_int ((get_screen_width () / 2) - 120))
                  (Float.of_int 0) 80.0 200.0,
                speed )
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
          in
          !new_box
        else !box_b;
      box_c :=
        if reset_box_cond box_c then
          let new_box =
<<<<<<< HEAD
            ref (Rectangle.create 500.0 (Float.of_int 0) 50.0 200.0, 4.0)
=======
            ref
              ( Rectangle.create
                  (Float.of_int (get_screen_width () / 2))
                  (Float.of_int 0) 80.0 200.0,
                speed )
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
          in
          !new_box
        else !box_c;
      box_d :=
        if reset_box_cond box_d then
          let new_box =
<<<<<<< HEAD
            ref (Rectangle.create 700.0 (Float.of_int 0) 50.0 200.0, 4.0)
=======
            ref
              ( Rectangle.create
                  (Float.of_int ((get_screen_width () / 2) + 120))
                  (Float.of_int 0) 80.0 200.0,
                speed )
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
          in
          !new_box
        else !box_d;
      (* Pause game *)
      let pause = if is_key_pressed Key.Space then not pause else pause in

      begin_drawing ();
      clear_background Color.raywhite;

      draw_rectangle_rec (fst !box_a) Color.black;
      draw_rectangle_rec (fst !box_b) Color.black;
      draw_rectangle_rec (fst !box_c) Color.black;
      draw_rectangle_rec (fst !box_d) Color.black;

<<<<<<< HEAD
=======
      draw_rectangle_rec box_aa Color.blue;
      draw_rectangle_rec box_bb Color.blue;
      draw_rectangle_rec box_cc Color.blue;
      draw_rectangle_rec box_dd Color.blue;

      (if is_key_down Key.D then
         let () = draw_rectangle_rec box_aa Color.red in
         let collision = get_collision_rec (fst !box_a) box_aa in
         score := !score + int_of_float (floor (Rectangle.width collision)));
      if is_key_released Key.D then counter_a := !counter_a + 1;
      (if is_key_down Key.F then
         let () = draw_rectangle_rec box_bb Color.red in
         let collision = get_collision_rec (fst !box_b) box_bb in
         score := !score + int_of_float (floor (Rectangle.width collision)));
      if is_key_released Key.F then counter_b := !counter_b + 1;
      (if is_key_down Key.J then
         let () = draw_rectangle_rec box_cc Color.red in
         let collision = get_collision_rec (fst !box_c) box_cc in
         score := !score + int_of_float (floor (Rectangle.width collision)));
      if is_key_released Key.J then counter_c := !counter_c + 1;
      (if is_key_down Key.K then
         let () = draw_rectangle_rec box_dd Color.red in
         let collision = get_collision_rec (fst !box_d) box_dd in
         score := !score + int_of_float (floor (Rectangle.width collision)));
      if is_key_released Key.K then counter_d := !counter_d + 1;

      draw_text (string_of_int !counter_a)
        ((get_screen_width () / 2) - 220)
        ((get_screen_height () / 2) + 105)
        40 Color.black;
      draw_text (string_of_int !counter_b)
        ((get_screen_width () / 2) - 100)
        ((get_screen_height () / 2) + 105)
        40 Color.black;
      draw_text (string_of_int !counter_c)
        ((get_screen_width () / 2) + 20)
        ((get_screen_height () / 2) + 105)
        40 Color.black;
      draw_text (string_of_int !counter_d)
        ((get_screen_width () / 2) + 140)
        ((get_screen_height () / 2) + 105)
        40 Color.black;
      draw_text
        ("Score: " ^ string_of_int !score)
        (get_screen_width () - 350)
        50 40 Color.black;

>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa
      draw_fps 10 10;

      end_drawing ();

<<<<<<< HEAD
      loop (pause, box_a, box_b, box_c, box_d)
=======
      loop
        ( pause,
          box_a,
          box_b,
          box_c,
          box_d,
          box_aa,
          box_bb,
          box_cc,
          box_dd,
          music )
>>>>>>> aba43111710060bfcce67ec7296f445a1f625faa

let () = setup () |> loop
