open Finalproject.Utils
open Finalproject.Note
open Finalproject.Beatmap
open Finalproject.Sprite
open Finalproject.StateMachine
open OUnit2
open Raylib
open Finalproject.Constants

let util_tests =
  "test suite for utils module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "list creation" >:: fun _ ->
           assert_equal [ 1; 2; 3; 4; 5 ] (make_list 5) );
         ("list with one elem" >:: fun _ -> assert_equal [ 1 ] (make_list 1));
         ( "list with precond violate" >:: fun _ ->
           assert_raises (Failure "Illegal Argument") (fun () -> make_list 0) );
         ( "list with mapping" >:: fun _ ->
           assert_equal [ 5; 7; 8; 9 ]
             (map3
                (fun x y z -> x + y + z)
                [ 1; 2; 3; 2 ] [ 4; 0; 8; 1 ] [ 0; 5; -3; 6 ]) );
         ( "list with mapping edge case with empty lists" >:: fun _ ->
           assert_equal [] (map3 (fun _ _ _ -> 0) [] [] []) );
         ( "array to string test" >:: fun _ ->
           assert_equal "[|123|]" (array_to_string string_of_int [| 1; 2; 3 |])
         );
       ]

let sample_note = create_note 5. 5.
let close_to_edge = create_note 5. 716.

let note_tests =
  "test suite for notes module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "note sprite update check" >:: fun _ ->
           assert_equal 15.
             (let _ = update sample_note in
              Raylib.Rectangle.y (get_sprite sample_note)) );
         ( "note sprite update check - should reset" >:: fun _ ->
           assert_equal 0.
             (let _ = update close_to_edge in
              Raylib.Rectangle.y (get_sprite close_to_edge)) );
         ( "note sprite hit status check - should reset" >:: fun _ ->
           assert_equal false
             (let _ = update close_to_edge in
              has_been_hit close_to_edge) );
         ( "note sprite hit status check - should be hit now" >:: fun _ ->
           assert_equal true
             (let () = hit close_to_edge in
              has_been_hit close_to_edge) );
         ( "note sprite hit status check - should reset" >:: fun _ ->
           assert_equal true
             (let _ = update sample_note in
              let () = hit sample_note in
              has_been_hit sample_note) );
         ( "note sprite speed check" >:: fun _ ->
           assert_equal 10.
             (let _ = update sample_note in
              get_speed sample_note) );
         ( "note calcualtion of score check - Perfect" >:: fun _ ->
           assert_equal 120 (calc_score 3 Perfect) );
         ( "note\n            calcualtion of score check - Great" >:: fun _ ->
           assert_equal 80 (calc_score 3 Great) );
         ( "note calcualtion of score\n            check - Good" >:: fun _ ->
           assert_equal 40 (calc_score 3 Good) );
         ( "note calcualtion of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 3 Miss) );
         ( "note calcualtion of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 1 Miss) );
         ( "note calcualtion of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 2 Miss) );
         ( "note\n            calcualtion of accuracy check - Good" >:: fun _ ->
           assert_equal Good (calc_accuracy 0.1) );
         ( "note\n            calcualtion of accuracy check - Good" >:: fun _ ->
           assert_equal Good (calc_accuracy 0.2) );
         ( "note\n            calcualtion of accuracy check - Great" >:: fun _ ->
           assert_equal Great (calc_accuracy 0.3) );
         ( "note\n            calcualtion of accuracy check - Great" >:: fun _ ->
           assert_equal Great (calc_accuracy 0.5) );
         ( "note\n            calcualtion of accuracy check - Perfect"
         >:: fun _ -> assert_equal Perfect (calc_accuracy 0.7) );
         ( "note\n            calcualtion of accuracy check - Perfect"
         >:: fun _ -> assert_equal Perfect (calc_accuracy 1.0) );
       ]

let txt_to_array txt =
  let lines = BatList.of_enum (BatFile.lines_of txt) in
  let rec aux lines acc =
    match lines with
    | [] -> acc
    | h :: t ->
        let acc = Array.append acc [| float_of_string h |] in
        aux t acc
  in
  aux lines [||]

module type SongT = sig
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
end

module GeneralSongTester (S : SongT) = struct
  let tests =
    [
      ( "beatmap test" >:: fun _ ->
        assert_equal
          (txt_to_array "test/better-day_copy.mp3")
          (S.init "test/better-day_copy.mp3").beatmap );
      ( "check note_index incrementation p1-intialization" >:: fun _ ->
        assert_equal 1 (S.init "test/better-day_copy.mp3").next_note_index );
      ( "check note_index incrementation p2-stepping" >:: fun _ ->
        assert_equal 2
          (let song = S.(init "test/better-day_copy.mp3") in
           let _ = S.inc_note song in
           let _ = S.inc_note song in
           S.get_index song) );
      ( "check note accuracy step" >:: fun _ ->
        assert_equal false
          (let song = S.(init "test/better-day_copy.mp3") in
           S.is_on_next_note song 0.1) );
    ]
end

let beatmap_tests =
  "test suite for notes module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "a converting beatmap txt to a list" >:: fun _ ->
           assert_equal
             (txt_to_array "beatmapTest.txt")
             (read_beatmap_txt "beatmapTest.txt") );
       ]

let sprite_tests =
  "test suite for sprites module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "creating a sprite array" >:: fun _ ->
           assert_equal
             (let sprite =
                Rectangle.create
                  (float_of_int (0 mod 5) *. float_of_int 10)
                  (float_of_int (0 / 5) *. float_of_int 10)
                  (float_of_int 10) (float_of_int 10)
              in
              Rectangle.y sprite)
             (Rectangle.y (Array.get (to_array (create_sprites 10 10 1 5)) 0))
         );
         ( "frame rate check" >:: fun _ ->
           assert_equal 10 (num_frames (create_sprites 10 10 10 5)) );
       ]

module ExampleState : State = struct
  type t = int

  let name = "ex"
  let set_default = false
  let init () = ()
  let update () = Some "ex2"
  let render () = ()
  let buffer = ref None
  let set_buffer (t : t) = buffer := Some t
  let set_default = true
  let score = ref 0
  let combo = ref 0
  let valid_press = ref true
  let button_frame_num = ref 0
  let spread_x_positions num_els el_width = ()
  let notes = ()
  let buttons = ()
  let init () = ()
  let check_combo_break break_combo = ()
  let handle_key_press note button key = ()
  let draw_background () = ()
  let draw_combo () = ()
end

module ExampleDummyState : State = struct
  type t = int

  let name = "ex"
  let set_default = false
  let init () = ()
  let update () = Some "ex2"
  let render () = ()
  let buffer = ref None
  let set_buffer (t : t) = buffer := Some t
  let set_default = true
  let score = ref 0
  let combo = ref 0
  let valid_press = ref true
  let button_frame_num = ref 0
  let spread_x_positions num_els el_width = ()
  let notes = ()
  let buttons = ()
  let init () = ()
  let check_combo_break break_combo = ()
  let handle_key_press note button key = ()
  let draw_background () = ()
  let draw_combo () = ()
end

let state_machine_tests =
  "test suite for sprites module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "creating a sprite array - empty" >:: fun _ ->
           assert_equal [||] (to_array (create_sprites 10 10 0 5)) );
         ( "frame rate check" >:: fun _ ->
           assert_equal 10 (num_frames (create_sprites 10 10 10 5)) );
       ]

module ExState : State = struct
  type t = int

  let name = "shubMap"
  let set_default = false
  let init () = ()
  let update () = Some "xie"
  let render () = ()
  let buffer = ref None
  let set_buffer (t : t) = buffer := Some t
  let set_default = true
  let score = ref 0
  let combo = ref 0
  let valid_press = ref true
  let button_frame_num = ref 0
  let spread_x_positions num_els el_width = ()
  let notes = ()
  let buttons = ()
  let init () = ()
  let check_combo_break break_combo = ()
  let handle_key_press note button key = ()
  let draw_background () = ()
  let draw_combo () = ()
end

module StateMachineTestMod = AddState (EmptyStateMachine) (ExampleState)

module StateMachineTestModDummy =
  AddState (EmptyStateMachine) (ExampleDummyState)

module StateMachineTestModDouble = AddState (StateMachineTestModDummy) (ExState)

module StateMachineTest (S : StateMachine) = struct
  let tests =
    [
      "test suite for state machine "
      >::: [
             ("a trivial test" >:: fun _ -> assert_equal 0 0);
             ( "test state array" >:: fun _ ->
               assert_equal [| "ex" |] (S.get_states ()) );
             ( "test current state - single" >:: fun _ ->
               match S.get_state () with
               | None -> print_endline "NONE"
               | Some s ->
                   print_endline (s ^ "\n\n\n");
                   assert_equal (Some "ex") (S.get_state ()) );
             ( "test state array" >:: fun _ ->
               assert_equal (Some "main") (S.get_state (S.set_state "main")) );
           ];
    ]
end

module StateMachineTestLink (S : StateMachine) = struct
  let tests =
    [
      "test suite for state machine "
      >::: [
             ("a trivial test" >:: fun _ -> assert_equal 0 0);
             ( "test current state" >:: fun _ ->
               assert_equal (Some "ex") (S.get_state ()) );
             ( "test state array" >:: fun _ ->
               assert_equal [| "ex"; "shubMap" |] (S.get_states ()) );
             ( "test state array - changed" >:: fun _ ->
               assert_equal (Some "mainCh") (S.get_state (S.set_state "mainCh"))
             );
             ( "test switching the states with no states to go" >:: fun _ ->
               assert_raises
                 (Invalid_transition
                    "Attempted to transition to state main, but only have \
                     states [||]")
                 (let _ = S.update () in
                  fun () -> S.update ()) );
           ];
    ]
end

module SingleTest = StateMachineTest (StateMachineTestMod)
(* module DoubleStateTest = StateMachineTestLink (StateMachineTestModDouble)
   module BeatMapTest = GeneralSongTester (Song) *)

let mod_tests = List.flatten []
let mod_suite = "module operations test suite" >::: mod_tests

let suite =
  "test suite"
  >::: [
         util_tests;
         note_tests;
         beatmap_tests;
         sprite_tests;
         state_machine_tests;
         mod_suite;
       ]

let _ = run_test_tt_main suite
