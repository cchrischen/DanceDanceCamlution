open Finalproject

type t = int

let buffer = ref None
let set_buffer (t : t) = buffer := Some t
let name = "settings"
let set_default = false
let init () = ()
let is_menu_open = ref false
let menu_width = 750
let menu_height = 500

let settings_button =
  ref (Button.make_circle_button (60, Constants.height - 60) 50)

let menu_nw_corner =
  ( (Constants.width / 2) - (menu_width / 2),
    (Constants.height / 2) - (menu_height / 2) )

let update () =
  if Button.check_click !settings_button then Some "play" else None

let draw_keybind_grid () =
  (* let open Raylib in *)
  let _ = Keybind.all_buttons () in
  ()
(* ignore (List.mapi (fun i key -> let key_as_string = key |> Key.to_int |>
   char_of_int |> String.make 1 in let x_pos = i % 3 Raylib.draw_text
   key_as_string) all_keys) *)

let render () =
  let open Raylib in
  draw_rectangle (fst menu_nw_corner) (snd menu_nw_corner) menu_width
    menu_height Color.gray;
  Button.draw !settings_button Color.gray;
  draw_text "Settings"
    ((Constants.width / 2) - 125)
    ((Constants.height / 2) - 200)
    60 Color.black;
  draw_keybind_grid ()
