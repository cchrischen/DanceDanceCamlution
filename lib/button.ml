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

let check_click button =
  let open Raylib in
  if is_mouse_button_pressed MouseButton.Left then begin
    let mx = get_mouse_x () in
    let my = get_mouse_y () in
    match button with
    | Rect { x; y; width; height } ->
        (mx >= x && mx <= x + width) && my >= y && my <= y + height
    | Circle { center; radius } ->
        Utils.distance center (mx, my) <= float_of_int radius
  end
  else false