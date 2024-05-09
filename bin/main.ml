open Finalproject
open States
module SM1 = StateMachine.AddState (StateMachine.EmptyStateMachine) (PlayState)
module SM2 = StateMachine.AddState (SM1) (PauseState)
module SM3 = StateMachine.AddState (SM2) (TitleState)
module SM4 = StateMachine.AddState (SM3) (SettingsState)
module SM = StateMachine.AddState (SM4) (MusicSelectState)

let init () =
  let open Raylib in
  init_window Constants.width Constants.height "DanceDanceCamlution";
  set_target_fps Constants.target_fps;
  init_audio_device ();
  Random.init 69420;
  SM.init ()

let rec loop () =
  let open Raylib in
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
        | Some s ->
            SM.set_state s;
            SM.init ()
      end;
      loop ()

let () = () |> init |> loop
