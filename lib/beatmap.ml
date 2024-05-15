open Batteries

let read_beatmap_txt path =
  let file_lines = File.lines_of path in
  let beatmap_lst =
    List.rev (Enum.fold (fun acc x -> float_of_string x :: acc) [] file_lines)
  in
  Array.of_list
    (List.filteri (fun i _ -> i mod !Constants.diff = 0) beatmap_lst)

let rec print_float_list = function
  | [] -> print_endline ""
  | h :: t ->
      print_float h;
      print_endline "";
      print_float_list t

module Song = struct
  type song = {
    audio_source : Raylib.Music.t;
    beatmap : float array;
    mutable next_note_index : int;
  }

  let create_beatmap song_path =
    if
      not
        (Sys.file_exists
           (String.sub song_path 0 (String.length song_path - 3) ^ "beatmap.txt"))
    then
      Sys.command ("python lib/beatmap_python/generate_beatmap.py " ^ song_path)
    else 0

  let init song_path =
    let song = Raylib.load_music_stream song_path in
    Raylib.play_music_stream song;
    let beatmap_path =
      String.sub song_path 0 (String.length song_path - 3) ^ "beatmap.txt"
    in
    let beatmap =
      Array.filter (fun x -> x > 0.7) (read_beatmap_txt beatmap_path)
    in
    { audio_source = song; beatmap; next_note_index = 0 }

  let reset_note (s : song) : unit = s.next_note_index <- 0

  let is_on_next_note (s : song) (offset : float) : bool =
    if s.next_note_index <> Array.length s.beatmap then
      let onset_next_note = Array.get s.beatmap s.next_note_index in
      let time_in_song = Raylib.get_music_time_played s.audio_source in
      Float.abs (time_in_song -. onset_next_note) < offset
    else
      let _ = if Constants.repeat_song then reset_note s else () in
      false

  let inc_note (s : song) : unit = s.next_note_index <- s.next_note_index + 1
  let get_index (s : song) = s.next_note_index

  let is_song_over (s : song) =
    Float.abs
      (Raylib.get_music_time_played s.audio_source
      -. Raylib.get_music_time_length s.audio_source)
    < 0.1
end
