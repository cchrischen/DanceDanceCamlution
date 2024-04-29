open Raylib

let width = 1280
let height = 720
let num_notes = 4
let note_width = 80.
let note_height = 40.

(**[note_speed] is the number of pixels a note is moved horizontally every time
   a frame updates.*)
let note_speed = 10.

(**[repeat_song] is whether the song repeats once it has ended.*)
let repeat_song = true

let target_fps = 60
let base_score = 10
let background_color = Color.create 70 70 90 255
let note_color = Color.create 200 120 20 255
let button_color = Color.create 60 30 130 250
let holding_button_color = Color.create 110 80 180 250
let bindings = [ Key.D; Key.F; Key.J; Key.K ]
