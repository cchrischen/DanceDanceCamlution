let width = 800
let height = 450

let setup () =
  let open Raylib in
  init_window width height "raylib [shapes] example - collision area";
  let box_a = ref (Rectangle.create 10.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_b = ref (Rectangle.create 250.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_c = ref (Rectangle.create 500.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  let box_d = ref (Rectangle.create 700.0 (Float.of_int 0) 50.0 200.0, 4.0) in
  set_target_fps 60;
  (false, box_a, box_b, box_c, box_d)

let reset_box_cond box =
  let open Raylib in
  Rectangle.(
    y (fst !box) +. height (fst !box) >= Float.of_int (get_screen_height ())
    || y (fst !box) <= 0.0)

let rec loop (pause, box_a, box_b, box_c, box_d) =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let open Raylib in
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
            ref (Rectangle.create 10.0 (Float.of_int 0) 50.0 200.0, 4.0)
          in
          !new_box
        else !box_a;
      box_b :=
        if reset_box_cond box_b then
          let new_box =
            ref (Rectangle.create 250.0 (Float.of_int 0) 50.0 200.0, 4.0)
          in
          !new_box
        else !box_b;
      box_c :=
        if reset_box_cond box_c then
          let new_box =
            ref (Rectangle.create 500.0 (Float.of_int 0) 50.0 200.0, 4.0)
          in
          !new_box
        else !box_c;
      box_d :=
        if reset_box_cond box_d then
          let new_box =
            ref (Rectangle.create 700.0 (Float.of_int 0) 50.0 200.0, 4.0)
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

      draw_fps 10 10;

      end_drawing ();

      loop (pause, box_a, box_b, box_c, box_d)

let () = setup () |> loop
