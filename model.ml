(* Pomožni tip, ki predstavlja mrežo *)

type 'a grid = 'a Array.t Array.t

(* Funkcije za prikaz mreže.
   Te definiramo najprej, da si lahko z njimi pomagamo pri iskanju napak. *)

(* Razbije seznam [lst] v seznam seznamov dolžine [size] *)
let chunkify size lst =
  let rec aux chunk chunks n lst =
    match (n, lst) with
    | _, [] when chunk = [] -> List.rev chunks
    | _, [] -> List.rev (List.rev chunk :: chunks)
    | 0, _ :: _ -> aux [] (List.rev chunk :: chunks) size lst
    | _, x :: xs -> aux (x :: chunk) chunks (n - 1) xs
  in
  aux [] [] size lst

let string_of_option_int cell =
  match cell with
  | None -> " "
  | Some c -> Int.to_string c

let string_of_int cell =
  Int.to_string cell

let string_of_list string_of_element sep lst =
  lst |> List.map string_of_element |> String.concat sep

let string_of_nested_list string_of_element inner_sep outer_sep =
  string_of_list (string_of_list string_of_element inner_sep) outer_sep

let string_of_row string_of_cell row =
  let string_of_cells =
    row |> Array.to_list |> chunkify 3
    |> string_of_nested_list string_of_cell "" "│"
  in
  "┃" ^ string_of_cells ^ "┃\n"

let print_grid string_of_cell grid =
  let ln = "───" in
  let big = "━━━" in
  let divider = "┠" ^ ln ^ "┼" ^ ln ^ "┼" ^ ln ^ "┨\n" in
  let row_blocks =
    grid |> Array.to_list |> chunkify 3
    |> string_of_nested_list (string_of_row string_of_cell) "" divider
  in
  Printf.printf "┏%s┯%s┯%s┓\n" big big big;
  Printf.printf "%s" row_blocks;
  Printf.printf "┗%s┷%s┷%s┛\n" big big big

(* Funkcije za dostopanje do elementov mreže *)

let get_row (grid : 'a grid) (row_ind : int) = 
  Array.init 9 (fun col_ind -> grid.(row_ind).(col_ind))

let rows grid = List.init 9 (get_row grid)

let get_column (grid : 'a grid) (col_ind : int) =
  Array.init 9 (fun row_ind -> grid.(row_ind).(col_ind))

let columns grid = List.init 9 (get_column grid)

(*┏━┯━┯━┓
  ┃0│1│2┃
  ┃3│4│5┃   The map of which index represent which sudoku box
  ┃6│7│8┃
  ┗━┷━┷━┛*)
let get_box (grid : 'a grid) (box_ind : int) = 
  let box_size = 3 in
  let box_row_start = (box_ind / box_size) * box_size in
  let box_col_start = (box_ind mod box_size) * box_size in

  let extract_row r = Array.sub r box_col_start box_size in
  let extract_subgrid subgrid =
    Array.map extract_row (Array.sub (Array.of_list (rows subgrid)) box_row_start box_size)
  in
  extract_subgrid grid

let get_flatten_box (grid : 'a grid) (box_ind : int) =
  let box = Array.to_list (get_box grid box_ind) in
  let rec aux (box : 'a array list) =
    match box with
    | [] -> []
    | x :: xs -> (Array.to_list x) @ aux xs 
  in
  Array.of_list (aux box)

let boxes grid = List.init 9 (get_box grid)
let flatten_boxes grid = List.init 9 (get_flatten_box grid)

(* Funkcije za ustvarjanje novih mrež *)

let map_grid (f : 'a -> 'b) (grid : 'a grid) : 'b grid = 
  let map_row row =
    Array.map f row
  in
  Array.map map_row (Array.of_list (rows grid))

let copy_grid (grid : 'a grid) : 'a grid = map_grid (fun x -> x) grid

let foldi_grid (f : int -> int -> 'a -> 'acc -> 'acc) (grid : 'a grid)
    (acc : 'acc) : 'acc =
  let acc, _ =
    Array.fold_left
      (fun (acc, row_ind) row ->
        let acc, _ =
          Array.fold_left
            (fun (acc, col_ind) cell ->
              (f row_ind col_ind cell acc, col_ind + 1))
            (acc, 0) row
        in
        (acc, row_ind + 1))
      (acc, 0) grid
  in
  acc

let row_of_string cell_of_char str =
  List.init (String.length str) (String.get str) |> List.filter_map cell_of_char

let grid_of_string cell_of_char str =
  let grid =
    str |> String.split_on_char '\n'
    |> List.map (row_of_string cell_of_char)
    |> List.filter (function [] -> false | _ -> true)
    |> List.map Array.of_list |> Array.of_list
  in
  if Array.length grid <> 9 then failwith "Wrong number of rows";
  if Array.exists (fun x -> x <> 9) (Array.map Array.length grid) then
    failwith "Wrong number of coulums";
  grid

(* Model za vhodne probleme *)

type problem = { initial_grid : int option grid }

let print_problem problem : unit = 
  print_grid string_of_option_int problem.initial_grid

let problem_of_string str =
  let cell_of_char = function
    | ' ' -> Some None
    | c when '1' <= c && c <= '9' -> Some (Some (Char.code c - Char.code '0'))
    | _ -> None
  in
  { initial_grid = grid_of_string cell_of_char str }

(* Model za izhodne rešitve *)

type solution = {grid : int grid}

let print_solution solution =
  print_grid string_of_int solution.grid

(*
   let is_valid_solution problem solution = 
  let initial_grid = map_grid (fun a -> match a with None -> 0 | Some c -> c) problem.initial_grid in
  let solved_grid = solution.grid in
  print_endline (string_of_bool (initial_grid = solved_grid));
  print_solution solution;
  initial_grid = solved_grid
*)

let has_duplicates arr =
  let seen = [] in
  let rec check_duplicates (list : int list) (seen : int list)= 
    match list with
    | [] -> false
    | x :: xs ->
      if List.mem x seen then
        true
      else
        check_duplicates xs (x :: seen)
  in
  check_duplicates (Array.to_list arr) seen

let is_valid_solution (solution : solution) = 
  let rows = rows solution.grid in
  let columns = columns solution.grid in 
  let boxes = flatten_boxes solution.grid in 
  if Array.exists has_duplicates (Array.of_list rows) 
    || Array.exists has_duplicates (Array.of_list columns) 
    || Array.exists has_duplicates (Array.of_list boxes) then 
      false
  else
    true
(* Not sure but I think it is pointless to check if a solution is valid. *)

