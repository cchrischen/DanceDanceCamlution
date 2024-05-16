open Raylib

type t = Rectangle.t array * Texture2D.t

let initialize_sprite (file : string) =
  let image = load_image file in
  let texture = load_texture_from_image image in
  unload_image image;
  texture

let to_array (sprite_shape : Rectangle.t array) : Rectangle.t array =
  sprite_shape

let create_sprites (width : int) (height : int) (frames : int)
    (frames_per_row : int) =
  let rec add_frames i acc =
    if i = frames then acc
    else
      let sprite =
        Rectangle.create
          (float_of_int (i mod frames_per_row) *. float_of_int width)
          (float_of_int (i / frames_per_row) *. float_of_int height)
          (float_of_int width) (float_of_int height)
      in
      add_frames (i + 1) (Array.append acc [| sprite |])
  in
  let sprites = add_frames 0 [||] in
  sprites

let generate_sprite (width : int) (height : int) (frames : int)
    (frames_per_row : int) (file : string) : t =
  (create_sprites width height frames frames_per_row, initialize_sprite file)

let test_aux_generate_sprite (width : int) (height : int) (frames : int)
    (frames_per_row : int) =
  create_sprites width height frames frames_per_row

let draw_sprite (sprite : t) (frame_num : int) (x : float) (y : float) : unit =
  let sprites, sprite_texture = sprite in
  let frame = sprites.(frame_num) in
  draw_texture_rec sprite_texture frame (Vector2.create x y) Color.white

let num_frames ((arr, _) : t) = Array.length arr

let initialize_sprites_aux (table : (string, t) Hashtbl.t)
    (sprite_properties : string list) =
  let (a : string array) = Array.of_list sprite_properties in
  let sprite_sh =
    create_sprites
      (int_of_string a.(1))
      (int_of_string a.(2))
      (int_of_string a.(3))
      (int_of_string a.(4))
  in
  let sprite_texture = initialize_sprite ("data/sprites/" ^ a.(0) ^ ".png") in
  Hashtbl.add table a.(0) (sprite_sh, sprite_texture)

let initialize_sprites_aux_test (table : (string, Rectangle.t array) Hashtbl.t)
    (sprite_properties : string list) =
  let (a : string array) = Array.of_list sprite_properties in
  let sprite_sh =
    create_sprites
      (int_of_string a.(1))
      (int_of_string a.(2))
      (int_of_string a.(3))
      (int_of_string a.(4))
  in
  Hashtbl.add table a.(0) sprite_sh

let initialize_sprites (file : string) =
  let sprite_matrix : string list list = List.tl (Csv.load file) in
  let sprite_table = Hashtbl.create 10 in
  ignore (List.map (initialize_sprites_aux sprite_table) sprite_matrix);
  sprite_table

let initialize_sprites_test =
  let sprite_matrix : string list list =
    [
      [ "test1"; "1"; "1"; "1"; "1" ];
      [ "test2"; "1"; "1"; "2"; "2" ];
      [ "test3"; "1"; "1"; "1"; "1" ];
      [ "test4"; "1"; "1"; "1"; "1" ];
      [ "test5"; "1"; "1"; "1"; "1" ];
      [ "test6"; "1"; "1"; "1"; "1" ];
      [ "test7"; "1"; "1"; "1"; "1" ];
      [ "test8"; "1"; "1"; "1"; "1" ];
      [ "test9"; "1"; "1"; "1"; "1" ];
    ]
  in
  let sprite_table = Hashtbl.create 10 in
  ignore (List.map (initialize_sprites_aux_test sprite_table) sprite_matrix);
  sprite_table

let texture (sprite : t) = snd sprite
let sprite_sheet (sprite : t) = fst sprite
