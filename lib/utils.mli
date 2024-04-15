val make_list : int -> int list
(** [make_list n] creates a list with the positive integers up to [n] (including
    [n]) in ascending order starting at 1. Requires [n > 0]. *)

val map3 : ('a -> 'b -> 'c -> 'd) -> 'a list -> 'b list -> 'c list -> 'd list
(** [map3 f l1 l2 l3] is a list with the [i]th element of the list being [f]
    applied to the [i]th element of [l1], [l2], [l3]. Requires: the lengths of
    [l1], [l2], and [l3] are equal. *)

(**a concern of mine would be that if for each frame update we only want a list
   of one note because currently, we have to have all 4 notes appear at once.*)
