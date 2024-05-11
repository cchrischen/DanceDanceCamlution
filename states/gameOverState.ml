open Finalproject

type t = int

let name = "over"
let score_x = int_of_float (float_of_int Constants.width /. 2.)
let score_y = int_of_float (float_of_int Constants.height /. 2.)
let return_home_x = (float_of_int Constants.width /. 2.) -. 150.
let return_home_y = float_of_int Constants.height /. 2.
let sprite_map : (string, Sprite.t) Hashtbl.t ref = ref (Hashtbl.create 1)
let return_home_hit = ref false
let exit_hit = ref false
let set_default = false
let reset () = ()

let init () =
  sprite_map := Sprite.initialize_sprites "data/sprites/titlestatesprites.csv"

let buffer = ref (Some 0)
let set_buffer (t : t) = buffer := Some t
let update () = if !return_home_hit then Some "reset" else None

let render () =
  match !exit_hit with
  | true -> Raylib.close_window ()
  | false ->
      Sprite.draw_sprite (Hashtbl.find !sprite_map "titlescreen") 0 0. 0.;
      Raylib.draw_text "Score:" 100 120 100 Raylib.Color.raywhite;
      Raylib.draw_text
        (string_of_int (Option.get !buffer))
        500 120 100 Raylib.Color.white;
      Raylib.draw_text
        "Created by CamelCorp: Chris Chen, Daniel Xie, Shubham Mohole, Rishi \
         Yennu, Nam Anh Dang"
        15 (Constants.height - 30) 20 Raylib.Color.raywhite;
      let open Raygui in
      let rect_1 = Raylib.Rectangle.create 300.0 400.0 100. 50. in
      let rect_2 = Raylib.Rectangle.create 300.0 500.0 100. 50. in
      let return_home = button rect_1 "home" in
      let exit = button rect_2 "exit" in
      return_home_hit := return_home;
      exit_hit := exit
