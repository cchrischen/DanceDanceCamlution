let width = 1280
let height = 720
let counter_a = ref 0
let counter_b = ref 0
let counter_c = ref 0
let counter_d = ref 0

let setup () =
  let open Raylib in
  init_window width height "raylib keyboard input";
  let box_a =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) - 240))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_b =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) - 120))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_c =
    Rectangle.create
      (Float.of_int (get_screen_width () / 2))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  let box_d =
    Rectangle.create
      (Float.of_int ((get_screen_width () / 2) + 120))
      (Float.of_int ((get_screen_height () / 2) + 80))
      80.0 80.0
  in
  set_target_fps 60;
  (box_a, box_b, box_c, box_d)

let rec loop (box_a, box_b, box_c, box_d) =
  match Raylib.window_should_close () with
  | true -> Raylib.close_window ()
  | false ->
      let open Raylib in
      begin_drawing ();
      clear_background Color.raywhite;

      draw_rectangle_rec box_a Color.blue;
      draw_rectangle_rec box_b Color.blue;
      draw_rectangle_rec box_c Color.blue;
      draw_rectangle_rec box_d Color.blue;

      if is_key_down Key.D then draw_rectangle_rec box_a Color.red;
      if is_key_released Key.D then counter_a := !counter_a + 1;
      if is_key_down Key.F then draw_rectangle_rec box_b Color.red;
      if is_key_released Key.F then counter_b := !counter_b + 1;
      if is_key_down Key.J then draw_rectangle_rec box_c Color.red;
      if is_key_released Key.J then counter_c := !counter_c + 1;
      if is_key_down Key.K then draw_rectangle_rec box_d Color.red;
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

      end_drawing ();

      loop (box_a, box_b, box_c, box_d)

let () = setup () |> loop
