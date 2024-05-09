val width : int
(** [width] is the width of the screen. *)

val height : int
(** [height] is the height of the screen. *)

val num_columns : int
(** [num_columns] is the number of columns in the game. *)

val note_width : float
(** [note_width] is the width of a note. *)

val note_height : float
(** [note_height] is the height of a note. *)

val note_speed : float
(** [note_speed] is the number of pixels a note is moved vertically every time a
    frame updates. *)

val repeat_song : bool
(** [repeat_song] is whether the song repeats once it has ended. *)

val target_fps : int
(** [target_fps] is the maximum frames per second. *)

val base_score : int
(** [base_score] is the base score. *)

val background_color : Raylib.Color.t
(** [background_color] is the background color. *)

val note_color : Raylib.Color.t
(** [note_color] is the color of the notes. *)

val button_color : Raylib.Color.t
(** [button_color] is the color of the buttons. *)

val holding_button_color : Raylib.Color.t
(** [holding_button_color] is the color when a player holds a button. *)

val offset : float
(** [offset] is the time between a note appearing in a song and a note added to
    a column. Calculated using the "time" of a note as stated in
    [Note.create_note] which I assume is the number of frames (60 per seconds)
    for the note to reach the hitbox. [offset = 1/time * 60.] *)

val diff : int
(** [diff] is the difficulty of the game. It means the frequency with which the
    notes in the beatmap is read. [diff = 1] means every note in beatmap is read
    while [diff = 3] means one in three notes are read. *)
