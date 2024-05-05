open Raylib

type t = Rectangle.t array

let to_array (sprite : t) : Rectangle.t array = sprite

let create_sprites (width : int) (height : int) (frames : int)
    (frames_per_row : int) : t =
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

let draw_sprite (sprites : t) (file : string) (frame_num : int) (x : float)
    (y : float) : unit =
  let sprite = sprites.(frame_num) in
  let image = load_image file in
  let texture = load_texture_from_image image in
  draw_texture_rec texture sprite (Vector2.create x y) Color.white;
  unload_image image

let num_frames (arr : t) = Array.length arr
