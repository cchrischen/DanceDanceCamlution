type t = int
(** [t] is the type of data another state can send to the settings state. *)

val name : string
(** [name] is ["settings"]. *)

val set_default : bool
(** [set_default] is [false] because it is the state the game starts. *)

val set_buffer : t -> unit
(** [set_buffer data] sets the buffer of settings state. *)

val init : unit -> unit
(** [init ()] initializes the settings state. *)

val update : unit -> string option
(** [update ()] checks for keyboard input. This state can transition into the
    play and title state. *)

val render : unit -> unit
(** [render ()] draws the settings screen *)

val reset : unit -> unit
(** [reset ()] resets the state to its initial state. *)

val load : unit -> unit
(** [load ()] loads the sprites of the settings state. *)
