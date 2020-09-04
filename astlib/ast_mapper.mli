val add_ppx_context_sig:
    tool_name:string -> Parsetree.signature_item list -> Parsetree.signature_item list
(** Same as [add_ppx_context_str], but for signatures. *)

val drop_ppx_context_sig:
    restore:bool -> Parsetree.signature_item list -> Parsetree.signature_item list
(** Same as [drop_ppx_context_str], but for signatures. *)

val add_ppx_context_str:
    tool_name:string -> Parsetree.structure_item list -> Parsetree.structure_item list
(** Extract information from the current environment and encode it
    into an attribute which is prepended to the list of structure
    items in order to pass the information to an external
    processor. *)

val drop_ppx_context_str:
restore:bool -> Parsetree.structure_item list -> Parsetree.structure_item list
(** Drop the ocaml.ppx.context attribute from a structure.  If
    [restore] is true, also restore the associated data in the current
    process. *)

(** {1 A generic Parsetree mapper} *)

type mapper

val hft_mapper: (Parsetree.structure_item list -> Parsetree.structure_item list) -> (Parsetree.signature_item list -> Parsetree.signature_item list) -> mapper
(** Create a whole file transformation mapper that transforms a
    structure and a signature, without recursing through the AST. *)

(** {1 Apply mappers to compilation units} *)

val tool_name: unit -> string
(** Can be used within a ppx preprocessor to know which tool is
    calling it ["ocamlc"], ["ocamlopt"], ["ocamldoc"], ["ocamldep"],
    ["ocaml"], ...  Some global variables that reflect command-line
    options are automatically synchronized between the calling tool
    and the ppx preprocessor: {!Clflags.include_dirs},
    {!Load_path}, {!Clflags.open_modules}, {!Clflags.for_package},
    {!Clflags.debug}. *)

val apply: source:string -> target:string -> mapper -> unit
(** Apply a mapper (parametrized by the unit name) to a dumped
    parsetree found in the [source] file and put the result in the
    [target] file. The [structure] or [signature] field of the mapper
    is applied to the implementation or interface.  *)

val run_main: (string list -> mapper) -> unit
(** Entry point to call to implement a standalone -ppx rewriter from a
    mapper, parametrized by the command line arguments.  The current
    unit name can be obtained from {!Location.input_name}.  This
    function implements proper error reporting for uncaught
    exceptions. *)

val set_cookie: string -> Parsetree.expression -> unit
val get_cookie: string -> Parsetree.expression option
