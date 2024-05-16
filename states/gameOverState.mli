type t = int * float
(** [t] is the type of data another state can send to the music select state. *)

val name : string
(** [name] is ["over"]. *)

val set_default : bool
(** [set_default] is [false] because it is not the state the game starts. *)

val set_buffer : t -> unit
(** [set_buffer data] sets the buffer of game over state. *)

val init : unit -> unit
(** [init ()] initializes the game over state. *)

val update : unit -> string option
(** [update ()] checks for keyboard input. This state can transition into the
    play state. *)

val render : unit -> unit
(** [render ()] draws the game over state. *)

val reset : unit -> unit
(** [reset ()] resets the state to its initial state. *)

val load : unit -> unit
(** [load ()] loads all sprites for the game over state. *)
