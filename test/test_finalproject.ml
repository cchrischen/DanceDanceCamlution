open DDC.Utils
open DDC.Note
open DDC.Beatmap
open DDC.Sprite
open DDC.StateMachine
open OUnit2
open Raylib
open DDC.Constants
open DDC.Column
open DDC.Button
open DDC.Keybind
open QCheck2
open Batteries

let list_end_matches_size c =
  let list_util = make_list c in
  let list_standard_end_number = c in
  list_standard_end_number = List.nth list_util (c - 1)

let t_list_creation =
  QCheck.Test.make
    (QCheck.make (QCheck.Gen.int_range 1 100))
    list_end_matches_size

let array_to_string_tester c =
  let array_util = Array.make c 0 in
  let string_array = array_to_string string_of_int array_util in
  c + 4 = String.length string_array

let t_array_to_string =
  QCheck.Test.make
    (QCheck.make (QCheck.Gen.int_range 1 100))
    array_to_string_tester

let distance_tester c =
  let start_tuple = Gen.(generate ~n:2 small_int) in
  let distance =
    distance
      (List.hd start_tuple, List.hd (List.tl start_tuple))
      (c + List.hd start_tuple, c - List.hd (List.tl start_tuple))
  in
  let test_distance =
    let distance_test_x = c + List.hd start_tuple - List.hd start_tuple in
    let distance_test_y =
      c - List.hd (List.tl start_tuple) - List.hd (List.tl start_tuple)
    in
    (distance_test_x * distance_test_x) + (distance_test_y * distance_test_y)
    |> float_of_int |> sqrt
  in
  test_distance = distance

let t_distance =
  QCheck.Test.make (QCheck.make (QCheck.Gen.int_range 0 50)) distance_tester

let ounit_rnd_test_list_size = QCheck_runner.to_ounit2_test t_list_creation
let ounit_rnd_test_array_string = QCheck_runner.to_ounit2_test t_array_to_string
let ounit_rnd_test_distance = QCheck_runner.to_ounit2_test t_distance

let util_tests =
  "test suite for utils module "
  >::: [
         ( "list creation" >:: fun _ ->
           assert_equal [ 1; 2; 3; 4; 5; 6 ] (make_list 6) );
         ("list with one elem" >:: fun _ -> assert_equal [ 1 ] (make_list 1));
         ( "list with precond violate of zero elems" >:: fun _ ->
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
         ( "distance test - edge case 0" >:: fun _ ->
           assert_equal 0. (distance (0, 0) (0, 0)) );
         ( "distance test - from origin" >:: fun _ ->
           assert_equal 5. (distance (0, 0) (3, 4)) );
         ( "distance test - between two points" >:: fun _ ->
           assert_equal 5. (distance (1, 1) (4, 5)) );
         ( "distance test - between positive and negative points" >:: fun _ ->
           assert_equal 5. (distance (0, 0) (-3, -4)) );
       ]

module type SongT = sig
  type song = {
    audio_source : Raylib.Music.t;
    beatmap : float array;
    mutable next_note_index : int;
  }

  val init : string -> song
  val inc_note : song -> unit
  val get_index : song -> int
end

module GeneralBeatmapTester (S : SongT) = struct
  let tests =
    "tests for beatmap module"
    >::: [
           ( "reading/converting empty beatmap" >:: fun _ ->
             assert_equal [||] (read_beatmap_txt "emptyBeatmapTest.txt") );
           ( "reading/converting non-empty beatmap" >:: fun _ ->
             assert_equal
               [|
                 12.0867;
                 2.42978;
                 2.39154;
                 3.31294;
                 3.732412;
                 4.15222;
                 4.3611;
                 4.57307;
                 0.4313;
                 0.84338;
                 1.25890;
               |]
               (read_beatmap_txt "beatmapTest.txt") );
           ( "check 0 for get initial index of song" >:: fun _ ->
             assert_equal 0
               (S.get_index
                  (Raylib.init_audio_device ();
                   S.init "better-day.mp3")) );
           ( "check that song.beatmap matches read_beatmap_txt" >:: fun _ ->
             assert_equal
               (Raylib.init_audio_device ();
                S.init "better-day.mp3")
                 .beatmap
               (Array.filter
                  (fun x -> x > DDC.Constants.offset)
                  (read_beatmap_txt "better-day.beatmap.txt")) );
           ( "check next_note_index incrementation" >:: fun _ ->
             Raylib.init_audio_device ();
             let song = S.init "better-day.mp3" in
             let _ = S.inc_note song in
             assert_equal 1 song.next_note_index );
           ( "check get_index incrementation" >:: fun _ ->
             assert_equal 2
               (Raylib.init_audio_device ();
                let song = S.(init "better-day.mp3") in
                let _ = S.inc_note song in
                let _ = S.inc_note song in
                S.get_index song) );
         ]
end

module BeatMapTest = GeneralBeatmapTester (Song)

let sample_note = create_note 5. 5.
let close_to_edge = create_note 5. 716.

let note_tests =
  "test suite for notes module "
  >::: [
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
         ( "note calculation of score check - Perfect" >:: fun _ ->
           assert_equal 120 (calc_score 3 Perfect) );
         ( "note\n            calculation of score check - Great" >:: fun _ ->
           assert_equal 80 (calc_score 3 Great) );
         ( "note calculation of score\n            check - Good" >:: fun _ ->
           assert_equal 40 (calc_score 3 Good) );
         ( "note calculation of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 3 Miss) );
         ( "note calculation of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 1 Miss) );
         ( "note calculation of score check - Miss" >:: fun _ ->
           assert_equal 0 (calc_score 2 Miss) );
         ( "note\n            calculation of accuracy check - Good" >:: fun _ ->
           assert_equal Good (calc_accuracy 0.1) );
         ( "note\n            calculation of accuracy check - Good" >:: fun _ ->
           assert_equal Good (calc_accuracy 0.2) );
         ( "note\n            calculation of accuracy check - Great" >:: fun _ ->
           assert_equal Great (calc_accuracy 0.3) );
         ( "note\n            calculation of accuracy check - Great" >:: fun _ ->
           assert_equal Great (calc_accuracy 0.5) );
         ( "note\n            calculation of accuracy check - Perfect"
         >:: fun _ -> assert_equal Perfect (calc_accuracy 0.7) );
         ( "note\n            calculation of accuracy check - Perfect"
         >:: fun _ -> assert_equal Perfect (calc_accuracy 1.0) );
       ]

let column_tests =
  "test suite for column module "
  >::: [
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
         ( "reset column check - empty edge case" >:: fun _ ->
           assert_equal 0
             (List.length
                (let col = create 1.0 in
                 let _ = reset col in
                 get_notes col)) );
         ( "reset column check - add one note case" >:: fun _ ->
           assert_equal 0
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = reset col in
                 get_notes col)) );
         ( "reset column check - add one note then remove then reset case"
         >:: fun _ ->
           assert_equal 0
             (List.length
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = increment_notes col in
                 let _ =
                   Rectangle.set_y (get_sprite (List.hd (get_notes col))) 750.
                 in
                 let _ = remove_dead_notes col in
                 let _ = reset col in
                 get_notes col)) );
         ( "reset column check - make sure button is not reset for its \
            attributes"
         >:: fun _ ->
           assert_equal
             (Rectangle.y
                (let y = height * 3 / 4 |> float_of_int in
                 let button = Rectangle.create 1. y 80. 40. in
                 button))
             (Rectangle.y
                (let col = create 1.0 in
                 let _ = add_note col in
                 let _ = increment_notes col in
                 let _ =
                   Rectangle.set_y (get_sprite (List.hd (get_notes col))) 750.
                 in
                 let _ = remove_dead_notes col in
                 let _ = reset col in
                 get_button col)) );
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
         ( "overlap test with rectangle button center test " >:: fun _ ->
           assert_equal true (overlap_detect (5, 5) rec_button) );
         ( "overlap test with rectangle button off-right QUAD 1 test"
         >:: fun _ -> assert_equal true (overlap_detect (6, 6) rec_button) );
         ( "overlap test with rectangle button  off right EDGE TEST "
         >:: fun _ -> assert_equal false (overlap_detect (-5, 4) rec_button) );
         ( "overlap test with rectangle button QUAD 2 Test " >:: fun _ ->
           assert_equal true (overlap_detect (6, 10) rec_button) );
         ( "overlap test with rectangle button OPP EDGE " >:: fun _ ->
           assert_equal true (overlap_detect (15, 15) rec_button) );
         ( "overlap test with rectangle button BOTTOM TEST " >:: fun _ ->
           assert_equal false (overlap_detect (1, 1) rec_button) );
         ( "overlap test with rectangle button QUAD 3 TEST - OUTSIDE BOUND "
         >:: fun _ -> assert_equal false (overlap_detect (-1, -1) rec_button) );
         ( "overlap test with rectangle button OUTSIDE TEST " >:: fun _ ->
           assert_equal false (overlap_detect (2, 2) rec_button) );
         ( "overlap FALSE on RECTANGLE " >:: fun _ ->
           assert_equal false (overlap_detect (-16, 16) rec_button) );
         ( "overlap NEG CORDS OUTSIDE" >:: fun _ ->
           assert_equal false (overlap_detect (-18, 16) rec_button) );
         ( "overlap test with OUTSIDE ON QUAD 2" >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) rec_button) );
         ( "overlap test with rectangle button QUAD 4" >:: fun _ ->
           assert_equal false (overlap_detect (30, 20) rec_button) );
         ( "overlap test with rectangle button NON_EXISTENT BUTTON\n\
           \         - CHECK BUTTON TEST NOT WINDOW OVERLAP"
         >:: fun _ ->
           assert_equal false (overlap_detect (15, 15) rec_button_zero) );
         ( "overlap test with CIRCLE button" >:: fun _ ->
           assert_equal true (overlap_detect (5, 5) circ_button) );
         ( "overlap test with circle button OFF_RIGHT CIRCLE" >:: fun _ ->
           assert_equal true (overlap_detect (-2, 2) circ_button) );
         ( "overlap test with circle button OFF_LEFT CIRCLE" >:: fun _ ->
           assert_equal true (overlap_detect (7, 8) circ_button) );
         ( "overlap test with button CIRCLE BUTTON EDGE" >:: fun _ ->
           assert_equal true (overlap_detect (12, 12) circ_button) );
         ( "overlap test with button CIRCLE BUTTON TRUE NEAR EDGE" >:: fun _ ->
           assert_equal true (overlap_detect (10, 12) circ_button) );
         ( "overlap test with circle button OUTSIDE EDGE CASE HIT FALSE"
         >:: fun _ -> assert_equal false (overlap_detect (13, 12) circ_button)
         );
         ( "overlap test with circle button OUTSIDE EDGE CASE HIT FALSE \
            OPPOSITE SIDE"
         >:: fun _ -> assert_equal false (overlap_detect (15, 15) circ_button)
         );
         ( "overlap test with circle button WAY OUTSIDE" >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) circ_button) );
         ( "overlap test with rectangle button NON_EXISTENT BUTTON\n\
           \         - CHECK BUTTON TEST NOT WINDOW"
         >:: fun _ ->
           assert_equal false (overlap_detect (-15, 15) circ_button_zero) );
         ( "overlap test with rectangle button NON_EXISTENT BUTTON\n\
           \         - CHECK BUTTON TEST NOT WINDOW EDGE"
         >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) circ_button_zero) );
       ]

let key1 = BUTTON1
let key2 = BUTTON2
let key3 = BUTTON3
let key4 = BUTTON4
let pause = PAUSE

let keybind_tests =
  "test suite for button module "
  >::: [
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

let sprite_tests =
  "test suite for sprites module "
  >::: [
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
       ]

module EmptySM = EmptyStateMachine ()

let empty_statemachine_tests =
  "test suite for empty state machine"
  >::: [
         ( "current state of an empty state machine is none" >:: fun _ ->
           assert_equal None !EmptySM.current_state );
         ( "getting state of an empty state machine is same as current state"
         >:: fun _ -> assert_equal None (EmptySM.get_state ()) );
         ( "the list of states of an empty state machine is the empty array"
         >:: fun _ -> assert_equal [||] (EmptySM.get_states ()) );
         ( "attempting to transition state of an empty state machine should \
            raise an error"
         >:: fun _ ->
           assert_bool ""
             (try
                EmptySM.set_state "a";
                false
              with Invalid_transition _ -> true) );
         ( "updating an empty state machine should raise an error" >:: fun _ ->
           assert_bool ""
             (try
                let _ = EmptySM.update () in
                false
              with Invalid_transition _ -> true) );
         ( "rendering an empty state machine should raise an error" >:: fun _ ->
           assert_bool ""
             (try
                EmptySM.render ();
                false
              with Invalid_transition _ -> true) );
         ( "init should not raise an error" >:: fun _ ->
           assert_bool ""
             (EmptySM.init ();
              true) );
       ]

module State1 : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 1"
  let set_default = false
  let set_buffer d = buffer := Some d
  let init () = ()
  let update () = Some "State 2"
  let render () = ()
  let reset () = ()
  let load () = ()
end

module State2 : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 2"
  let set_default = true
  let init () = ()
  let set_buffer d = buffer := Some d
  let update () = Some "State 3"
  let render () = ()
  let reset () = ()
  let load () = ()
end

module State3 : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 3"
  let set_default = false
  let init () = ()
  let set_buffer d = buffer := Some d
  let update () = Some "State 1"
  let render () = ()
  let reset () = ()
  let load () = ()
end

module OneStateSM : StateMachine = AddState (EmptyStateMachine ()) (State1)
module OneStateSMCopy : StateMachine = AddState (EmptyStateMachine ()) (State1)
module TwoStateSM : StateMachine = AddState (OneStateSM) (State2)

module TwoStateSMCopy : StateMachine =
  AddState (AddState (EmptyStateMachine ()) (State1)) (State2)

module ThreeStateSM : StateMachine = AddState (TwoStateSM) (State3)

let one_state_state_machine_tests =
  "test suite for a state machine with one state"
  >::: [
         ( "the current state should be the state of the added state even when \
            set default is set to false"
         >:: fun _ ->
           assert_equal (Some "State 1") (OneStateSMCopy.get_state ()) );
         ( "get state should return the current state" >:: fun _ ->
           assert_equal (Some "State 1") (OneStateSMCopy.get_state ()) );
         ( "setting the state and rendering to an invalid state should raise \
            an error"
         >:: fun _ ->
           assert_bool ""
             (try
                OneStateSMCopy.set_state "State 2";
                OneStateSMCopy.render ();
                false
              with Invalid_transition _ -> true) );
         ( "the states array should only contain the name of the state that \
            was added"
         >:: fun _ ->
           assert_equal [| "State 1" |] (OneStateSMCopy.get_states ()) );
         ( "init should not raise an error" >:: fun _ ->
           assert_bool ""
             (OneStateSMCopy.init ();
              true) );
       ]

let multi_state_state_machine_tests =
  "test suite for state machines with multiple states"
  >::: [
         ( "if set_default is true, then it should override the state of the \
            state machine"
         >:: fun _ ->
           assert_equal (Some "State 2") (TwoStateSMCopy.get_state ()) );
         ( "adding another state should append the state to the list of states"
         >:: fun _ ->
           assert_equal [| "State 1"; "State 2" |]
             (TwoStateSMCopy.get_states ()) );
         ( "if set_default is false, then it should not override the state of \
            the state machine"
         >:: fun _ -> assert_equal (Some "State 2") (ThreeStateSM.get_state ())
         );
         ( "updating a state machine, setting the state to the returned state, \
            and updating again should return the transition of the \
            transitioned state"
         >:: fun _ ->
           assert_equal (Some "State 1")
             (let () = ThreeStateSM.set_state "State 2" in
              let transition = ThreeStateSM.update () in
              let () =
                match transition with
                | None -> ()
                | Some s -> ThreeStateSM.set_state s
              in
              ThreeStateSM.update ()) );
         ( "updating and transitioning the state machine multiple times should \
            return the right transition"
         >:: fun _ ->
           assert_equal (Some "State 1")
             (let () = ThreeStateSM.set_state "State 1" in
              let () =
                for _ = 0 to 50 do
                  let transition = ThreeStateSM.update () in
                  match transition with
                  | None -> ()
                  | Some s -> ThreeStateSM.set_state s
                done
              in
              ThreeStateSM.get_state ()) );
       ]

let check_buff_1 = ref 1
let check_buff_2 = ref 2
let check_buff_3 = ref 3

module State1_copy : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 1"
  let set_default = false
  let set_buffer d = buffer := Some d
  let init () = ()

  let update () =
    check_buff_1 := Option.get !buffer;
    Some "State 2"

  let render () = ()
  let reset () = buffer := Some 69
  let load () = ()
end

module State2_copy : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 2"
  let set_default = true
  let init () = ()
  let set_buffer d = buffer := Some d

  let update () =
    check_buff_2 := Option.get !buffer;
    Some "State 3"

  let render () = ()
  let reset () = buffer := Some 420
  let load () = ()
end

module State3_copy : State with type t = int = struct
  type t = int

  let buffer = ref None
  let name = "State 3"
  let set_default = false
  let init () = ()
  let set_buffer d = buffer := Some d

  let update () =
    check_buff_3 := Option.get !buffer;
    Some "State 1"

  let render () = ()
  let reset () = buffer := Some 69420
  let load () = ()
end

module OneStateSMCopy2 : StateMachine =
  AddState (EmptyStateMachine ()) (State1_copy)

module TwoStateSMCopy2 : StateMachine = AddState (OneStateSMCopy2) (State2_copy)

module ThreeStateSMCopy2 : StateMachine =
  AddState (TwoStateSMCopy2) (State3_copy)

let reset_test =
  "reset test"
  >::: [
         ( "3 States : when reseting, all buffers of the states should have \
            their default values"
         >:: fun _ ->
           assert_equal (69, 420, 69420)
             (let () = ThreeStateSMCopy2.reset () in
              let () = ThreeStateSMCopy2.set_state "State 1" in
              let () =
                for _ = 0 to 3 do
                  let transition = ThreeStateSMCopy2.update () in
                  match transition with
                  | None -> ()
                  | Some s -> ThreeStateSMCopy2.set_state s
                done
              in
              (!check_buff_1, !check_buff_2, !check_buff_3)) );
       ]

let mod_tests = List.flatten []
let mod_suite = "module operations test suite" >::: mod_tests

let suite =
  "test suite"
  >::: [
         util_tests;
         note_tests;
         sprite_tests;
         column_tests;
         BeatMapTest.tests;
         button_tests;
         keybind_tests;
         mod_suite;
         empty_statemachine_tests;
         one_state_state_machine_tests;
         multi_state_state_machine_tests;
         ounit_rnd_test_list_size;
         ounit_rnd_test_array_string;
         ounit_rnd_test_distance;
         reset_test;
       ]

let _ = run_test_tt_main suite
