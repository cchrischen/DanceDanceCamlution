open Finalproject.Utils

(* open Finalproject.Note *)
(* open Finalproject.Beatmap *)
open OUnit2

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
       ]

(* let sample_note = create_note 5. 5. let close_to_edge = create_note 5.
   716. *)

let note_tests =
  "test suite for notes module "
  >::: [
         ("a trivial test" >:: fun _ -> assert_equal 0 0);
         (*Cant check the note sprite update because the screen height is 0*)
         (*( "note sprite update check" >:: fun _ -> assert_equal 15.
           (Raylib.Rectangle.y (update sample_note)) );*)
         (* ( "note sprite update check - should reset" >:: fun _ ->
            assert_equal 0. (Raylib.Rectangle.y (update close_to_edge)) ); *)
         (* ( "note calcualtion of score check - Perfect" >:: fun _ ->
            assert_equal 90 (calc_score sample_note 3 Perfect) ); ( "note
            calcualtion of score check - Great" >:: fun _ -> assert_equal 60
            (calc_score sample_note 3 Great) ); ( "note calcualtion of score
            check - Good" >:: fun _ -> assert_equal 30 (calc_score sample_note 3
            Good) ); ( "note calcualtion of score check - Miss" >:: fun _ ->
            assert_equal 0 (calc_score sample_note 3 Miss) ); ( "note
            calcualtion of accuracy check - Perfect" >:: fun _ -> assert_equal
            Perfect (calc_accuracy sample_note 10) ); ( "note calcualtion of
            accuracy check - Great" >:: fun _ -> assert_equal Great
            (calc_accuracy sample_note 300) ); ( "note calcualtion of accuracy
            check - Good" >:: fun _ -> assert_equal Good (calc_accuracy
            sample_note 500) ); ( "note calcualtion of accuracy check - Miss"
            >:: fun _ -> assert_equal Miss (calc_accuracy sample_note 1000) ); (
            "note try_hit - true" >:: fun _ -> assert_equal true (try_hit
            sample_note 400) ); ( "note try_hit - false" >:: fun _ ->
            assert_equal false (try_hit sample_note 1000) ); *)
       ]

let beatmap_tests =
  "test suite for notes module "
  >::: [ (* ("a trivial test" >:: fun _ -> assert_equal 0 0); ( "a converting
            beatmap txt to a list" >:: fun _ -> assert_equal [ 12.0867; 2.42978;
            2.39154; 3.31294; 3.732412; 4.15222; 4.3611; 4.57307; 0.4313;
            0.84338; 1.25890; ] (read_beatmap_txt "beatmapTest.txt") ); *) ]

let suite = "test suite" >::: [ util_tests; note_tests; beatmap_tests ]
let _ = run_test_tt_main suite
