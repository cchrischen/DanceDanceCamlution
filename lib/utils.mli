val make_list : int -> int list
(** [make_list n] creates a list with the positive integers up to [n] (including
    [n]) in ascending order starting at 1. Requires [n > 0]. *)

val map3 : ('a -> 'b -> 'c -> 'd) -> 'a list -> 'b list -> 'c list -> 'd list
(** [map3 f l1 l2 l3] is a list with the [i]th element of the list being [f]
    applied to the [i]th element of [l1], [l2], [l3]. Requires: the lengths of
    [l1], [l2], and [l3] are equal. *)

val array_to_string : ('a -> string) -> 'a array -> string
(** [array_to_string to_string arr] is [arr] represented as an array, where each
    element in [arr] is converted into a string specified in [to_string]. *)
    