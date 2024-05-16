(* @authors Chris Chen (cc2785) Daniel Xie (dyx2) Nam Anh Dang (nd433) Shubham
   Mohole (sam588) Rishi Yennu (rry9) *)
open DDC
open States
open Raylib

module SM1 =
  StateMachine.AddState (StateMachine.EmptyStateMachine ()) (MusicSelectState)

module SM2 = StateMachine.AddState (SM1) (PauseState)
module SM3 = StateMachine.AddState (SM2) (PlayState)
module SM4 = StateMachine.AddState (SM3) (GameOverState)
module SM5 = StateMachine.AddState (SM4) (SettingsState)
module SM = StateMachine.AddState (SM5) (TitleState)

let init () =
  let open Raylib in
  init_window Constants.width Constants.height "DanceDanceCamlution";
  set_target_fps Constants.target_fps;
  init_audio_device ();
  Random.init 69420;
  SM.load ();
  SM.init ()

let rec loop () =
  match window_should_close () with
  | true -> close_window ()
  | false ->
      begin
        let transition = SM.update () in
        begin_drawing ();
        SM.render ();
        end_drawing ();
        match transition with
        | None -> ()
        | Some "reset" ->
            SM.reset ();
            SM.init ();
            SM.load ();
            SM.set_state "select"
        | Some "close" -> close_window ()
        | Some s ->
            SM.set_state s;
            SM.init ();
            SM.load ()
      end;
      loop ()

let () = () |> init |> loop
