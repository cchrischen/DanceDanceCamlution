open Raylib

type keybind =
  | BUTTON1
  | BUTTON2
  | BUTTON3
  | BUTTON4
  | PAUSE

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

let set_keybind keybind button =
  let key = match_keybind keybind in
  key := button

let get_keybind keybind = !(match_keybind keybind)
let play_buttons () = [ !button1; !button2; !button3; !button4 ]
let all_buttons () = play_buttons () @ [ !pause ]
