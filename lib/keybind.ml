open Raylib

type keybind =
  | BUTTON1
  | BUTTON2
  | BUTTON3
  | BUTTON4
  | PAUSE

let keymap =
  [
    (BUTTON1, "Button 1");
    (BUTTON2, "Button 2");
    (BUTTON3, "Button 3");
    (BUTTON4, "Button 4");
    (PAUSE, "Pause");
  ]

let button1 = ref Key.D
let button2 = ref Key.F
let button3 = ref Key.J
let button4 = ref Key.K
let pause = ref Key.P

let match_keybind = function
  | BUTTON1 -> button1
  | BUTTON2 -> button2
  | BUTTON3 -> button3
  | BUTTON4 -> button4
  | PAUSE -> pause

let raylib_to_keybind raylib_key =
  if raylib_key = !button1 then BUTTON1
  else if raylib_key = !button2 then BUTTON2
  else if raylib_key = !button3 then BUTTON3
  else if raylib_key = !button4 then BUTTON4
  else PAUSE

let set_keybind keybind button =
  let key = match_keybind keybind in
  key := button

let get_keybind keybind = !(match_keybind keybind)
let play_keybinds () = [ BUTTON1; BUTTON2; BUTTON3; BUTTON4 ]
let all_keybinds () = play_keybinds () @ [ PAUSE ]

let to_string keybind =
  let key = !(match_keybind keybind) in
  let key_as_int = Raylib.Key.to_int key in
  let key_as_char = char_of_int key_as_int in

  let rec find_name keybind = function
    | [] -> None
    | (k, n) :: t -> if k = keybind then Some n else find_name keybind t
  in

  let name_opt = find_name keybind keymap in
  let keybind_name =
    match name_opt with
    | None -> failwith "Keybind cannot be found"
    | Some s -> s
  in

  (keybind_name, String.make 1 key_as_char)
