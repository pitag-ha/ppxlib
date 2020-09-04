type t = Ocaml_common.Location.t = {
  loc_start: Lexing.position;
  loc_end: Lexing.position;
  loc_ghost: bool;
}

val none : t

type 'a loc = 'a Ocaml_common.Location.loc = {
  txt : 'a;
  loc : t;
}

(** {1 Printing locations} *)

val print_loc: Format.formatter -> t -> unit

(** {1 Input info} *)

val input_name: string ref

type msg = (Format.formatter -> unit) loc

type report_kind =
  | Report_error
  | Report_warning of string
  | Report_warning_as_error of string
  | Report_alert of string
  | Report_alert_as_error of string

type report = {
  kind : report_kind;
  main : msg;
  sub : msg list;
}

(** {1 Reporting errors} *)

type error = report
(** An [error] is a [report] which [report_kind] must be [Report_error]. *)

val error_of_printer: ?loc:t -> ?sub:msg list ->
  (Format.formatter -> 'a -> unit) -> 'a -> error

(** {1 Automatically reporting errors for raised exceptions} *)

val register_error_of_exn: (exn -> error option) -> unit
(** Each compiler module which defines a custom type of exception
    which can surface as a user-visible error should register
    a "printer" for this exception using [register_error_of_exn].
    The result of the printer is an [error] value containing
    a location, a message, and optionally sub-messages (each of them
    being located as well). *)

val error_of_exn: exn -> [ `Ok of error | `Already_displayed ] option

val raise_errorf: ?loc:t -> ?sub:msg list ->
  ('a, Format.formatter, unit, 'b) format4 -> 'a

val report_exception: Format.formatter -> exn -> unit
(** Reraise the exception if it is unknown. *)

(** {1 Reporting alerts} *)

val deprecated: ?def:t -> ?use:t -> t -> string -> unit
(** Prints a deprecation alert. *)
