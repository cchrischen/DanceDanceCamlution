type t
(** [t] is the type of the button. A button can be rectangular or circular. *)

val make_rect_button : int * int -> int -> int -> t
(** [make_rect_button (x, y) width height] is a button whose north west corner
    is at [(x, y)] and who has a width of [width] and height of [height]. *)

val make_circle_button : int * int -> int -> t
(** [make_circle_button (x, y) radius] is a circular button whose center is at
    [(x, y)] and who has a radius of [radius]. *)

val check_click : int * int -> t -> bool
(** [check_click (mx,my) button] is whether the mouse has clicked within the
    button. *)

val overlap_detect : int * int -> t -> bool
(** [overlap_detect (mx,my) button] calculates whether there is overlap between
    mouse and button. Non-interface facing function unlike [check_hover] *)

val draw : t -> Raylib.Color.t -> unit
(** [draw button color] draws [button] with color [color]. *)

val get_dims : t -> int * int * int * int
(** [get_dims button] returns a tuple where the first two coordinates represent
    the sprite's north west corner and the other two coordinates represent the
    width and height, respectively. *)
