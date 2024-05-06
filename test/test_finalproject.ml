open Finalproject.Utils
open Finalproject.Note
open Finalproject.Beatmap
open Finalproject.Sprite
open Finalproject.StateMachine
open OUnit2
open Raylib
open Finalproject.Constants
open Finalproject.Column
open Finalproject.Button
open Finalproject.Keybind

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
           assert_equal 13.
             (let _ = update sample_note in
              Raylib.Rectangle.y (get_sprite sample_note)) );
         ( "note sprite update check - should continue past window since \n\
           \         going in garbage"
         >:: fun _ ->
           assert_equal 724.
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
           assert_equal 8.
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

let column_tests =
  "test suite for notes module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "create a column" >:: fun _ ->
           assert_equal
             (Rectangle.y (Rectangle.create 1.0 540. 80. 40.))
             (Rectangle.y (get_button (create 1.0))) );
         ( "get notes - empty" >:: fun _ ->
           assert_equal [] (get_notes (create 1.0)) );
         ( "get notes - filled iter1" >:: fun _ ->
           assert_equal 1
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 get_notes col)) );
         ( "get notes - filled iter2" >:: fun _ ->
           assert_equal 2
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = add_note col in
                 get_notes col)) );
         ( "get button" >:: fun _ ->
           assert_equal
             (Rectangle.y
                (let y = height * 3 / 4 |> float_of_int in
                 let button = Rectangle.create 1. y 80. 40. in
                 button))
             (Rectangle.y (get_button (create 1.0))) );
         ( "get notes after incrementing it" >:: fun _ ->
           assert_equal
             (Rectangle.y (Rectangle.create 1. 48. note_width note_height))
             (Rectangle.y
                (get_sprite
                   (List.hd
                      (let col = create 1.0 in
                       let _ = add_note col in
                       let _ = increment_notes col in
                       get_notes col)))) );
         ( "remove notes from a column - no removal" >:: fun _ ->
           assert_equal 2
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = add_note col in
                 let _ = remove_dead_notes col in
                 get_notes col)) );
         ( "remove notes from a column - yes removal" >:: fun _ ->
           assert_equal 0
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = increment_notes col in
                 let _ =
                   Rectangle.set_y (get_sprite (List.hd (get_notes col))) 750.
                 in
                 let _ = remove_dead_notes col in
                 get_notes col)) );
         ( "key accuracy test - miss" >:: fun _ ->
           assert_equal Miss (key_pressed (create 1.0)) );
         ( "key accuracy test - any other score" >:: fun _ ->
           assert_equal Miss
             (key_pressed
                (let col = create 1.0 in
                 let _ = add_note col in
                 col)) );
       ]

let rec_button = make_rect_button (5, 5) 10 10
let rec_button_zero = make_rect_button (0, 0) 0 0
let circ_button = make_circle_button (5, 5) 10
let circ_button_zero = make_circle_button (0, 0) 0

let button_tests =
  "test suite for button module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "get dimensions rectangle test" >:: fun _ ->
           assert_equal (5, 5, 10, 10) (get_dims rec_button) );
         ( "get dimensions rectangle test edge" >:: fun _ ->
           assert_equal (0, 0, 0, 0) (get_dims rec_button_zero) );
         ( "get dimensions circle test edge" >:: fun _ ->
           assert_equal (0, 0, 0, 0) (get_dims circ_button_zero) );
         ( "get dimensions circle test" >:: fun _ ->
           assert_equal (-5, -5, 10, 10) (get_dims circ_button) );
       ]

let key1 = BUTTON1
let key2 = BUTTON2
let key3 = BUTTON3
let key4 = BUTTON4
let pause = PAUSE

let keybind_tests =
  "test suite for button module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         ( "raylib to keybind - button 1" >:: fun _ ->
           assert_equal key1 (raylib_to_keybind Raylib.Key.D) );
         ( "raylib to keybind - button 2" >:: fun _ ->
           assert_equal key2 (raylib_to_keybind Raylib.Key.F) );
         ( "raylib to keybind - button 3" >:: fun _ ->
           assert_equal key3 (raylib_to_keybind Raylib.Key.J) );
         ( "raylib to keybind - button 4" >:: fun _ ->
           assert_equal key4 (raylib_to_keybind Raylib.Key.K) );
         ( "raylib to keybind - button 5" >:: fun _ ->
           assert_equal pause (raylib_to_keybind Raylib.Key.P) );
         ( "get keybind button 1" >:: fun _ ->
           assert_equal
             (Raylib.Key.to_int Raylib.Key.D)
             (Raylib.Key.to_int (get_keybind BUTTON1)) );
         ( "get keybind button 2" >:: fun _ ->
           assert_equal
             (Raylib.Key.to_int Raylib.Key.F)
             (Raylib.Key.to_int (get_keybind BUTTON2)) );
         ( "get keybind button 3" >:: fun _ ->
           assert_equal
             (Raylib.Key.to_int Raylib.Key.J)
             (Raylib.Key.to_int (get_keybind BUTTON3)) );
         ( "get keybind button 4" >:: fun _ ->
           assert_equal
             (Raylib.Key.to_int Raylib.Key.K)
             (Raylib.Key.to_int (get_keybind BUTTON4)) );
         ( "get keybind button 5" >:: fun _ ->
           assert_equal
             (Raylib.Key.to_int Raylib.Key.P)
             (Raylib.Key.to_int (get_keybind PAUSE)) );
         ( "play keybinds test" >:: fun _ ->
           assert_equal [ key1; key2; key3; key4 ] (play_keybinds ()) );
         ( "all keybinds test" >:: fun _ ->
           assert_equal [ key1; key2; key3; key4; pause ] (all_keybinds ()) );
         ( "keybind to string test - button 1" >:: fun _ ->
           assert_equal ("Button 1", "D") (to_string BUTTON1) );
         ( "keybind to string test - button 2" >:: fun _ ->
           assert_equal ("Button 2", "F") (to_string BUTTON2) );
         ( "keybind to string test - button 3" >:: fun _ ->
           assert_equal ("Button 3", "J") (to_string BUTTON3) );
         ( "keybind to string test - button 4" >:: fun _ ->
           assert_equal ("Button 4", "K") (to_string BUTTON4) );
         ( "keybind to string test - button 5" >:: fun _ ->
           assert_equal ("Pause", "P") (to_string PAUSE) );
         ( "raylib to keybind - changed key - button 1" >:: fun _ ->
           assert_equal key1
             (let _ = set_keybind key1 Raylib.Key.A in
              raylib_to_keybind Raylib.Key.A) );
         ( "raylib to keybind - changed key - button 2" >:: fun _ ->
           assert_equal key2
             (let _ = set_keybind key2 Raylib.Key.S in
              raylib_to_keybind Raylib.Key.S) );
         ( "raylib to keybind - changed key - button 3" >:: fun _ ->
           assert_equal key3
             (let _ = set_keybind key3 Raylib.Key.L in
              raylib_to_keybind Raylib.Key.L) );
         ( "raylib to keybind - changed key - button 4" >:: fun _ ->
           assert_equal key4
             (let _ = set_keybind key4 Raylib.Key.W in
              raylib_to_keybind Raylib.Key.W) );
         ( "raylib to keybind - changed key - button 5" >:: fun _ ->
           assert_equal pause
             (let _ = set_keybind pause Raylib.Key.Q in
              raylib_to_keybind Raylib.Key.Q) );
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
          (txt_to_array "better-day.mp3")
          (S.init "better-day.mp3").beatmap );
      ( "check note_index incrementation p1-intialization" >:: fun _ ->
        assert_equal 1 (S.init "better-day.mp3").next_note_index );
      ( "check note_index incrementation p2-stepping" >:: fun _ ->
        assert_equal 2
          (let song = S.(init "better-day.mp3") in
           let _ = S.inc_note song in
           let _ = S.inc_note song in
           S.get_index song) );
      ( "check note accuracy step" >:: fun _ ->
        assert_equal false
          (let song = S.(init "better-day.mp3") in
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
           assert_equal 10
             (num_frames
                (generate_sprite 10 10 10 5 "test/titlescreen_test.png")) );
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
           assert_equal 10
             (num_frames
                (generate_sprite 10 10 10 5 "test/titlescreen_test.png")) );
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
module DoubleStateTest = StateMachineTestLink (StateMachineTestModDouble)
module BeatMapTest = GeneralSongTester (Song)

let mod_tests = List.flatten []
let mod_suite = "module operations test suite" >::: mod_tests

let suite =
  "test suite"
  >::: [
         util_tests;
         note_tests;
         beatmap_tests;
         sprite_tests;
         column_tests;
         button_tests;
         keybind_tests;
         state_machine_tests;
         mod_suite;
       ]

let _ = run_test_tt_main suite
