type keybind =
  | BUTTON1
  | BUTTON2
  | BUTTON3
  | BUTTON4
  | PAUSE  (** [keybind] is all keybinds that are supported to be changed. *)

val raylib_to_keybind : Raylib.Key.t -> keybind
(** [raylib_to_keybind key] is the keybind type representing the raylib key. *)

val set_keybind : keybind -> Raylib.Key.t -> unit
(** [set_keybind keybind key] sets [keybind] to [key]. *)

val get_keybind : keybind -> Raylib.Key.t
(** [get_keybind keybind] is the raylib key equivalent of a keybind type. *)

val play_keybinds : unit -> keybind list
(** [play_keybinds ()] is the list of [[BUTTON1; BUTTON2; BUTTON3; BUTTON4]]. *)

val all_keybinds : unit -> keybind list
(** [all_keybinds ()] is the list of all constructors of [keybind]. *)

val to_string : keybind -> string * string
(** [to_string keybind] is a tuple of the button name and the character bound to
    that keybind. *)
