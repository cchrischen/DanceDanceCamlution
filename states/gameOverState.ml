open Finalproject

type t = int * float

let name = "over"
let return_home_x = (float_of_int Constants.width /. 2.) -. 100.
let return_home_y = (float_of_int Constants.height /. 2.) +. 100.
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let return_home_hit = ref false
let exit_hit = ref false
let set_default = true
let grade = ref ""
let buffer = ref (Some (0, 0.))

let color_map =
  [
    ("A", Raylib.Color.green);
    ("B", Raylib.Color.blue);
    ("C", Raylib.Color.orange);
    ("D", Raylib.Color.brown);
    ("F", Raylib.Color.red);
    ("S", Raylib.Color.gold);
  ]

let init () =
  sprite_map :=
    Sprite.initialize_sprites "data/sprites/musicselectscreensprites.csv";
  match snd (Option.get !buffer) with
  | x when x >= 0.9 -> grade := "S"
  | x when x >= 0.8 -> grade := "A"
  | x when x >= 0.7 -> grade := "B"
  | x when x >= 0.6 -> grade := "C"
  | x when x >= 0.5 -> grade := "D"
  | _ -> grade := "F"

let set_buffer (t : t) = buffer := Some t
let update () = if !return_home_hit then Some "reset" else None
let reset () = ()

let render () =
  match !exit_hit with
  | true -> Raylib.close_window ()
  | false ->
      Sprite.draw_sprite (Hashtbl.find !sprite_map "musicselectscreen") 0 0. 0.;
      Raylib.draw_text
        ("Score: " ^ string_of_int (fst (Option.get !buffer)))
        (450
        - String.length (string_of_int (fst (Option.get !buffer)))
          * (Constants.width / 50))
        50 100 Constants.holding_button_color;

      Raylib.draw_text
        ("Accuracy: "
        ^ Printf.sprintf "%.2f" (snd (Option.get !buffer) *. 100.)
        ^ "%")
        250 200 100 Constants.holding_button_color;
      Raylib.draw_text !grade
        ((Constants.width / 2) - 25)
        350 100
        (snd (List.hd (List.filter (fun x -> fst x = !grade) color_map)));
      let open Raygui in
      let rect_1 =
        Raylib.Rectangle.create return_home_x return_home_y 200. 50.
      in
      let rect_2 =
        Raylib.Rectangle.create return_home_x (return_home_y +. 100.) 200. 50.
      in
      let return_home = button rect_1 "Select Screen" in
      let exit = button rect_2 "Exit" in
      return_home_hit := return_home;
      exit_hit := exit
