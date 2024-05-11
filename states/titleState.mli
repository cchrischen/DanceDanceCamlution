type t = int
(** [t] is the type of data another state can send to the title state. *)

val name : string
(** [name] is ["title"]. *)

val set_default : bool
(** [set_default] is [true] because it is the state the game starts. *)

val set_buffer : t -> unit
(** [set_buffer data] sets the buffer of title state. *)

val init : unit -> unit
(** [init ()] initializes the title state. *)

val update : unit -> string option
(** [update ()] checks for keyboard input. This state can transition into the
    music select state. *)

val render : unit -> unit
(** [render ()] draws the title screen *)

val reset : unit -> unit
(** [reset ()] resets the state to its initial state. *)

val load : unit -> unit
(** [load ()] loads the sprites for the title state. *)
