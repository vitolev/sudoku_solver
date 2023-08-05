(* TODO: tip stanja ustrezno popravite, saj boste med reševanjem zaradi učinkovitosti
   želeli imeti še kakšno dodatno informacijo *)
type state = { 
  current_grid : int option Model.grid; 
  super_position : int list array array 
  }

let print_state (state : state) : unit =
  Model.print_grid
    (function None -> "?" | Some digit -> string_of_int digit)
    state.current_grid

type response = Solved of Model.solution | Unsolved of state | Fail of state

let initialize_state (problem : Model.problem) : state =
  let super_position : int list array array =
    Array.init 9 (fun i ->
      Array.init 9 (fun j ->
        match problem.initial_grid.(i).(j) with
        | Some a -> []
        | None -> (
          let possible = [1;2;3;4;5;6;7;8;9] in
          let row = Array.to_list (Model.get_row problem.initial_grid i) in
          let column = Array.to_list (Model.get_column problem.initial_grid j) in
          let box = Array.to_list (Model.get_flatten_box problem.initial_grid (i / 3 * 3 + j / 3)) in

          let connected_list = List.filter_map (fun x -> x) (row @ column @ box) in
          List.filter_map (fun x -> if List.mem x connected_list then None else Some x) possible
        )
      )
    )
  in
  { current_grid = Model.copy_grid problem.initial_grid; super_position }

  (* With using for loops:
  let super_position : int list array array = Array.make_matrix 9 9 [] in
  let possible_numbers (i:int) (j:int) : int list =
    let possible = [1;2;3;4;5;6;7;8;9] in
    let row = Array.to_list(Model.get_row problem.initial_grid i) in
    let coulum = Array.to_list(Model.get_column problem.initial_grid j) in
    let box = Array.to_list(Model.get_flatten_box problem.initial_grid (i / 3 * 3 + j / 3)) in

    let connected_list = List.filter_map (fun x -> x) (row @ coulum @ box) in
    List.filter_map (fun x -> if (List.mem x connected_list) then None else Some x) possible
  in

  for i = 0 to 8 do
    for j = 0 to 8 do
      super_position.(i).(j) <- possible_numbers i j
    done;
  done;
  { current_grid = Model.copy_grid problem.initial_grid; problem; super_position}
  *)

let validate_state (state : state) : response =
  let unsolved =
    Array.exists (Array.exists Option.is_none) state.current_grid
  in
  if unsolved then Unsolved state
  else
    (* Option.get ne bo sprožil izjeme, ker so vse vrednosti v mreži oblike Some x *)
    let solution = { Model.grid = Model.map_grid Option.get state.current_grid } in
    if Model.is_valid_solution solution then Solved solution
    else Fail state


type available = { pos : int * int; possible : int list }

let rec print_int_list_array_array arr i j =
  if i < Array.length arr then
    begin
      if j < Array.length arr.(i) then
        begin
          let lst = arr.(i).(j) in
          Printf.printf "[%s] " (String.concat "; " (List.map string_of_int lst));
          print_int_list_array_array arr i (j + 1)
        end
      else
        begin
          print_newline ();
          print_int_list_array_array arr (i + 1) 0
        end
    end

let find_best_position_to_explore (arr : int list array array) : available option =
  let min_length = ref max_int in
  let min_indices = ref (-1, -1) in

  for i = 0 to 8 do
    for j = 0 to 8 do
      let current_length = List.length arr.(i).(j) in
      if current_length < !min_length && current_length > 0 then begin
        min_length := current_length;
        min_indices := (i, j)
      end
    done;
  done;

  match !min_indices with
  | (-1,-1) -> None
  | (x,y) -> Some {pos = (x,y); possible = arr.(x).(y)}

let branch_state (state : state) : available option =
  let place = find_best_position_to_explore state.super_position in
  match place with
  | None -> None
  | Some c -> 
    place

(* pogledamo, če trenutno stanje vodi do rešitve *)
let rec solve_state (state : state) =
  (* uveljavimo trenutne omejitve in pogledamo, kam smo prišli *)
  (* TODO: na tej točki je stanje smiselno počistiti in zožiti možne rešitve *)
  match validate_state state with
  | Solved solution ->
      (* če smo našli rešitev, končamo *)
      Some solution
  | Fail fail ->
      (* prav tako končamo, če smo odkrili, da rešitev ni *)
      None
  | Unsolved state' ->
      (* če še nismo končali, raziščemo stanje, v katerem smo končali *)
      explore_state state'

and explore_state (state : state) =
  (* pri raziskovanju najprej pogledamo, ali lahko trenutno stanje razvejimo *)
  match branch_state state with
  | None ->
      (* če stanja ne moremo razvejiti, ga ne moremo raziskati *)
      None
  | Some place -> 
    let possible = place.possible in
    let x = fst place.pos in
    let y = snd place.pos in
    let rec solve_possible_state (candidate : int) (list_of_possibilities : int list)=
      let place_candidate_on_grid (grid : int option Model.grid) (candidate : int) : int option Model.grid = 
        let copy = Array.map Array.copy grid in
        copy.(x).(y) <- Some candidate;
        copy
      in

      let update_super_position_table (sup : int list array array) (candidate : int) : int list array array =
        let copy = Array.map Array.copy sup in
        (* Update the row *)
        for j = 0 to 8 do
          copy.(x).(j) <- List.filter ((<>) candidate) copy.(x).(j)
        done;
        (* Update the column *)
        for i = 0 to 8 do
          copy.(i).(y) <- List.filter ((<>) candidate) copy.(i).(y)
        done;
        (* Update the box *)
        for j = y / 3 * 3 to y / 3 * 3 + 2 do
          for i = x / 3 * 3 to x / 3 * 3 + 2 do
            copy.(i).(j) <- List.filter ((<>) candidate) copy.(i).(j)
          done;
        done;
        (* Sets the given cell to empty *)
        copy.(x).(y) <- [];
        copy
      in

      let possible_state = {
        current_grid = place_candidate_on_grid state.current_grid candidate;
        super_position = update_super_position_table state.super_position candidate;
        }
      in
      match solve_state possible_state with
      | Some solution -> Some solution
      | None -> 
        match list_of_possibilities with
        | [] -> None
        | x :: xs -> solve_possible_state x xs
        
    in 
    solve_possible_state (List.hd possible) (List.tl possible)

      (*
         match solve_state st1 with
      | Some solution ->
          (* če prva možnost vodi do rešitve, do nje vodi tudi prvotno stanje *)
          Some solution
      | None ->
          (* če prva možnost ne vodi do rešitve, raziščemo še drugo možnost *)
          solve_state st2 )
          *)

let solve_problem (problem : Model.problem) =
  problem |> initialize_state |> solve_state