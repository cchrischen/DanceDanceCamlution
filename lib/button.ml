type t =
  | Rect of {
      x : int;
      y : int;
      width : int;
      height : int;
    }
  | Circle of {
      center : int * int;
      radius : int;
    }

let make_rect_button (x, y) w h = Rect { x; y; width = w; height = h }
let make_circle_button center radius = Circle { center; radius }

let check_click (mx, my) button =
  let open Raylib in
  if is_mouse_button_pressed MouseButton.Left then begin
    match button with
    | Rect { x; y; width; height } ->
        (mx >= x && mx <= x + width) && my >= y && my <= y + height
    | Circle { center; radius } ->
        Utils.distance center (mx, my) <= float_of_int radius
  end
  else false

let check_hover (mx, my) button =
  match button with
  | Rect { x; y; width; height } ->
      (mx >= x && mx <= x + width) && my >= y && my <= y + height
  | Circle { center; radius } ->
      Utils.distance center (mx, my) <= float_of_int radius

let draw button color =
  let open Raylib in
  match button with
  | Rect { x; y; width; height } ->
      let rect =
        Rectangle.create (x |> float_of_int) (y |> float_of_int)
          (width |> float_of_int) (height |> float_of_int)
      in
      draw_rectangle_rec rect color
  | Circle { center; radius } ->
      let x = fst center in
      let y = snd center in
      draw_circle x y (radius |> float_of_int) color

let get_dims = function
  | Rect { x; y; width; height } -> (x, y, width, height)
  | Circle { center; radius } ->
      let cx = fst center in
      let cy = snd center in
      (cx - radius, cy - radius, radius, radius)
