type t = int
(** [t] is the type of data another state can send to the pause state. *)

val name : string
(** [name] is ["pause"]. *)

val set_default : bool
(** [set_default] is [false] because it is not the state the game starts. *)

val set_buffer : t -> unit
(** [set_buffer data] sets the buffer of pause state. *)

val init : unit -> unit
(** [init ()] initializes the pause state. *)

val update : unit -> string option
(** [update ()] checks for keyboard input. This state can transition into the
    play state. *)

val render : unit -> unit
(** [render ()] draws a paused sign in the middle of the screen. *)

val reset : unit -> unit
(** [reset ()] resets the state to its initial state. *)

val load : unit -> unit
(** [load ()] loads the sprites for the pause state. *)
