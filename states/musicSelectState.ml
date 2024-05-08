open Finalproject

type t = int

type music_gui_state = {
  mutable is_open : bool;
  mutable list_view_ex_active : int;
  mutable list_view_ex_focus : int;
  mutable list_view_ex_index : int;
}

let gui_state : music_gui_state =
  {
    is_open = true;
    list_view_ex_active = 0;
    list_view_ex_focus = 0;
    list_view_ex_index = 0;
  }

let directory = "data/music"
let files_list = ref []
let name = "musicSelect"
let set_default = false
let buffer = ref None
let set_buffer (t : t) = buffer := Some t
let init () = ()

let update () =
  let files = Raylib.load_directory_files_ex directory ".mp3" false in
  files_list := Raylib.FilePathList.files files;
  Raylib.unload_directory_files files;
  if gui_state.is_open then None
  else
    let _ =
      Beatmap.Song.create_beatmap
        (List.nth !files_list gui_state.list_view_ex_active)
    in
    let () =
      PlayState.set_buffer (List.nth !files_list gui_state.list_view_ex_active)
    in
    Some "play"

let render () =
  let open Raygui in
  let rect = Raylib.Rectangle.create 300.0 300.0 300. 300.0 in
  let list_view_ex_active, list_view_ex_focus, list_view_ex_index =
    list_view_ex rect !files_list gui_state.list_view_ex_focus
      gui_state.list_view_ex_index gui_state.list_view_ex_active
  in
  let is_open =
    not (button (Raylib.Rectangle.create 300.0 600.0 60.0 20.0) "done")
  in
  gui_state.is_open <- is_open;
  gui_state.list_view_ex_index <- list_view_ex_index;
  gui_state.list_view_ex_focus <- list_view_ex_focus;
  gui_state.list_view_ex_active <- list_view_ex_active;
  ()
