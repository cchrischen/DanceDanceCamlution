val read_beatmap_txt : string -> float array
(**[read_beatmap_txt path] is an array containing the onset - start time of each
   note in a song- of each note as declared in the beatmap file in [path].*)

(**[Song] is responsible for the playing of a song and tracking of the time*)
module Song : sig
  type song = {
    audio_source : Raylib.Music.t;
    beatmap : float array;
    mutable next_note_index : int;
  }

  val create_beatmap : string -> int
  (**[create_beatmap song_path] creates the beatmap from [song_path] in the same
     directory as specified song. Returns exit code from terminal*)

  val init : string -> song
  (**[init song_path] is the [song] created from the [song_path], including the
     [Raylib.Music.t] music object and beatmap. Also initializes the audio
     device and starts the playing of the song in [song_path]. Note that
     currently, [init song_path] requires the beatmap file and the mp3 file to
     be in the same directory. *)

  val is_on_next_note : song -> float -> bool
  (**[is_on_next_note s offset] checks whether the current time in the song
     minus [offset] is at the onset of the [s.next_note_index] note in
     [s.beatmap].Is [false] if [s.next_note_index] is >= length of [s.beatmap] *)

  val inc_note : song -> unit
  (**[inc_note s] increments the [s.next_note_index].*)

  val get_index : song -> int
  (**[get_index s] returns [s.next_note_index].*)
end
