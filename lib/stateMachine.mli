exception Invalid_transition of string
(** [Invalid_transition str] is thrown when a state attempts to transition into
    a state that is not supported by the state machine. *)

exception Empty_state_machine
(** [Empty_state_machine] is thrown when attempting to update or render an empty
    state machine. *)

(** [State] is a state in a state machine. It is one of the input signatures for
    the functor [AddState]. *)
module type State = sig
  val name : string
  (** [name] is the name of the state. *)

  val set_default : bool
  (** [set_default] determines whether the state will override a StateMachine's
      current state when added to one. It will always be overrided if a
      StateMachine's [current_state] is [None]. *)

  val init : unit -> unit
  (** [init ()] initializes the proper graphics, textures, etc. necessary for
      this state. This should be called once per state. *)

  val update : unit -> string option
  (** [update ()] updates the state. This can include changing sprite positions,
      handling user input, etc. This function returns [Some state] to transition
      to state [state] or [None] to remain in the current state. *)

  val render : unit -> unit
  (** [render ()] draws the to GUI. *)
end

(** [StateMachine] is collection of states with distinct logic and supports
    transitions between them. It is one of the input signature and the output
    signature of the functor [AddState]. *)
module type StateMachine = sig
  val current_state : string option ref
  (** [current_state] is the current state of the state machine. *)

  val get_states : unit -> string array
  (** [get_states ()] is a an array of the supported states of the state
      machine. *)

  val get_state : unit -> string option
  (** [get_state ()] is the current state of the state machine. This is [None]
      if it is the empty state machine. *)

  val set_state : string -> unit
  (** [set_state state] changes the current state of the state machien to
      [state]. Requires: [set_state] is an element of [states]. Raises:
      [Invalid_transition] is [state] is not in [states]. *)

  val init : unit -> unit
  (** [init ()] initializes all states in the state machine. *)

  val update : unit -> string option
  (** [update ()] updates the state whose name matches [current_state] and
      returns the next state to transition to. This is [None] if the state
      machine remains in its current state. Raises: [Invalid_transition] if the
      function is ran while [current_state] is not an element of [states]. *)

  val render : unit -> unit
  (** [render ()] draws the state whose name matches [current_state]. Raises:
      [Invalid_transition] if the function is ran while [current_state] is not
      an element of [states]. *)
end

module EmptyStateMachine : StateMachine
(** [EmptyStateMachine] is a state machine with no states. [current_state] is
    [None]. Raises: [Empty_state_machine] if [init], [update], and [render] are
    called. *)

(** [AddState (M) (S)] is a functor that adds state [S] to state machine [M].
    The resulting state machine with have the state [S] as well as the states in
    [M.states]. The resulting current state will be [S.name] if and only if
    [S.set_default] is [true] or [M = EmptyStateMachine]. Requires: [S.name] is
    not in [M.states]. *)
module AddState : functor (_ : StateMachine) (_ : State) -> StateMachine
