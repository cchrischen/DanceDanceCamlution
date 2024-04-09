open Raylib

let num_notes = 4
let note_width = 80.
let note_heigth = 80.

(**[note_speed] is the number of pixels a note is moved horizontally every time
   a frame updates.*)
let note_speed = 10.

(**[repeat_song] is whether the song repeats once it has ended.*)
let repeat_song = true

let target_fps = 60
let bindings = [ Key.D; Key.F; Key.J; Key.K ]
