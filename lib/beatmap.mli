val read_beatmap_txt : string -> float list
(**[read_beatmap_txt path] is a list containing the onset - start time of each
   note in a song- of each note as declared in the beatmap file in [path].*)

val print_float_list : float list -> unit

(**[Music] is responsible for the playing of music and tracking of the time*)
module Music : sig
  val init : string -> Raylib.Music.t
  (**[init song_path] initializes the audio device and starts the playing of the
     music in [song_path]. Returns the music stream for the music in [song_path]*)
end
