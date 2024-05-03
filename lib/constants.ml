open Raylib

let num_notes = 4
let note_width = 80.
let note_height = 40.

(**[note_speed] is the number of pixels a note is moved horizontally every time
   a frame updates.*)
let note_speed = 5.

(**[repeat_song] is whether the song repeats once it has ended.*)
let repeat_song = true

let target_fps = 60
let base_score = 10
let bindings = [ Key.D; Key.F; Key.J; Key.K ]
