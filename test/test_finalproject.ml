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

let util_tests =
  "test suite for utils module "
  >::: [
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
         ( "distance test - edge case 0" >:: fun _ ->
           assert_equal 0. (distance (0, 0) (0, 0)) );
         ( "distance test - from origin" >:: fun _ ->
           assert_equal 5. (distance (0, 0) (3, 4)) );
         ( "distance test - between two points" >:: fun _ ->
           assert_equal 5. (distance (1, 1) (4, 5)) );
         ( "distance test - between positive and negative points" >:: fun _ ->
           assert_equal 5. (distance (0, 0) (-3, -4)) );
       ]

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
         ( "overlap test with rectangle button  1 " >:: fun _ ->
           assert_equal true (overlap_detect (5, 5) rec_button) );
         ( "overlap test with rectangle button iter 2 " >:: fun _ ->
           assert_equal true (overlap_detect (6, 6) rec_button) );
         ( "overlap test with rectangle button  3 - closer to edge " >:: fun _ ->
           assert_equal true (overlap_detect (10, 10) rec_button) );
         ( "overlap test with rectangle button  3 - mixed cords " >:: fun _ ->
           assert_equal true (overlap_detect (6, 10) rec_button) );
         ( "overlap test with rectangle button  4 - edge testd " >:: fun _ ->
           assert_equal true (overlap_detect (15, 15) rec_button) );
         ( "overlap test with rectangle button 2 " >:: fun _ ->
           assert_equal false (overlap_detect (1, 1) rec_button) );
         ( "overlap test with rectangle button 3 " >:: fun _ ->
           assert_equal false (overlap_detect (-1, -1) rec_button) );
         ( "overlap test with rectangle button 4 " >:: fun _ ->
           assert_equal false (overlap_detect (2, 2) rec_button) );
         ( "overlap p1" >:: fun _ ->
           assert_equal false (overlap_detect (16, 16) rec_button) );
         ( "overlap p2 neg" >:: fun _ ->
           assert_equal false (overlap_detect (-16, 16) rec_button) );
         ( "overlap test with rectangle button - false" >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) rec_button) );
         ( "overlap test with rectangle button - false" >:: fun _ ->
           assert_equal false (overlap_detect (30, 20) rec_button) );
         ( "overlap test with rectangle button - zero case" >:: fun _ ->
           assert_equal false (overlap_detect (15, 15) rec_button_zero) );
         ( "overlap test with circle button" >:: fun _ ->
           assert_equal true (overlap_detect (5, 5) circ_button) );
         ( "overlap test with circle button iter 2" >:: fun _ ->
           assert_equal true (overlap_detect (6, 6) circ_button) );
         ( "overlap test with circle button iter 3 - closer to edge" >:: fun _ ->
           assert_equal true (overlap_detect (7, 8) circ_button) );
         ( "overlap test with circle button - edge case" >:: fun _ ->
           assert_equal true (overlap_detect (12, 12) circ_button) );
         ( "overlap test with circle button - edge case mixed true" >:: fun _ ->
           assert_equal true (overlap_detect (10, 12) circ_button) );
         ( "overlap test with circle button - edge case mixed false" >:: fun _ ->
           assert_equal false (overlap_detect (13, 12) circ_button) );
         ( "overlap test with circle button - edge case" >:: fun _ ->
           assert_equal false (overlap_detect (15, 15) circ_button) );
         ( "overlap test with circle button - false" >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) circ_button) );
         ( "overlap test with rectangle button - zero case" >:: fun _ ->
           assert_equal false (overlap_detect (15, 15) circ_button_zero) );
         ( "overlap test with rectangle button - zero case" >:: fun _ ->
           assert_equal false (overlap_detect (20, 20) circ_button) );
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
  val init : string -> song
  val is_on_next_note : song -> float -> bool
  val inc_note : song -> unit
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
         ( "a converting beatmap txt to a list" >:: fun _ ->
           assert_equal
             (txt_to_array "beatmapTest.txt")
             (read_beatmap_txt "beatmapTest.txt") );
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
         ( "frame rate check" >:: fun _ ->
           assert_equal 10
             (num_frames
                (generate_sprite 10 10 10 5 "test/titlescreen_test.png")) );
         ( "get texture check" >:: fun _ ->
           assert_equal
             (Texture2D.height (initialize_sprite "test/titlescreen_test.png"))
             (Texture2D.height
                (texture
                   (generate_sprite 10 10 10 5 "test/titlescreen_test.png"))) );
         ( "get sprite_sheet check" >:: fun _ ->
           assert_equal
             (Array.length (create_sprites 10 10 10 5))
             (Array.length
                (sprite_sheet
                   (generate_sprite 10 10 10 5 "test/titlescreen_test.png"))) );
         ( "initialzing hashtable sprite check" >:: fun _ ->
           assert_equal 2
             (Array.length
                (sprite_sheet
                   (Hashtbl.find
                      (initialize_sprites "test/testsprites.csv")
                      (let arr =
                         Array.of_list
                           (List.tl (Csv.load "test/testsprites.csv"))
                       in
                       List.nth arr.(0) 0)))) );
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

module State2 : State = struct
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

module State3 : State = struct
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

module BeatMapTest = GeneralSongTester (Song)

let mod_tests = List.flatten []
let mod_suite = "module operations test suite" >::: mod_tests

let suite =
  "test suite"
  >::: [
         util_tests;
         note_tests;
         sprite_tests;
         column_tests;
         button_tests;
         keybind_tests;
         mod_suite;
         empty_statemachine_tests;
         one_state_state_machine_tests;
         multi_state_state_machine_tests;
       ]

let _ = run_test_tt_main suite
