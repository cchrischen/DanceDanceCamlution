open Batteries

let read_beatmap_txt path =
  let file_lines = File.lines_of path in
  List.rev (Enum.fold (fun acc x -> float_of_string x :: acc) [] file_lines)

let rec print_float_list = function
  | [] -> print_endline ""
  | h :: t ->
      print_float h;
      print_endline "";
      print_float_list t

module Music = struct
  let init song_path =
    Raylib.init_audio_device ();
    let song = Raylib.load_music_stream song_path in
    Raylib.play_music_stream song;
    song
end
