type t = string
(** [t] is the type of data another state can send to the play state. *)

val name : string
(** [name] is ["play"]. *)

val set_default : bool
(** [set_default] is [false] because it is not the state the game starts. *)

val set_buffer : t -> unit
(** [set_buffer data] sets the buffer of play state. *)

val init : unit -> unit
(** [init ()] initializes the play state. *)

val update : unit -> string option
(** [update ()] updates the position of the notes in each column. It checks for
    keyboard input to detect timing and updates the score correspondingly. This
    state can transition to the pause state. *)

val render : unit -> unit
(** [render ()] draws the falling notes, current score, background, and columns
    of the game. *)

val reset : unit -> unit
(** [reset ()] resets the state to its initial state, particuarly the score. *)

val load : unit -> unit
(** [load ()] loads the sprites of the play state. *)
