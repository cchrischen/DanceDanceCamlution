let make_list n =
  if n <= 0 then failwith "Illegal Argument"
  else
    let rec make_aux i n =
      match i with
      | -1 -> []
      | _ -> (n - i) :: make_aux (i - 1) n
    in
    make_aux (n - 1) n

let map3 f lst1 lst2 lst3 =
  let combined = List.map2 (fun x y -> (x, y)) lst1 lst2 in
  List.map2 (fun (x, y) z -> f x y z) combined lst3

let array_to_string f arr =
  "[|" ^ Array.fold_left (fun acc x -> acc ^ f x) "" arr ^ "|]"

let distance (x1, y1) (x2, y2) =
  let dx = x1 - x2 in
  let dy = y1 - y2 in
  (dx * dx) + (dy * dy) |> float_of_int |> sqrt

(* let note_offset = *)
