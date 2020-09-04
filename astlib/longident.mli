type t
= Ocaml_common.Longident.t
= Lident of string
| Ldot of t * string
| Lapply of t * t

val flatten: t -> string list

val parse: string -> t
[@@deprecated "this function may misparse its input,\n\
use \"Parse.longident\" or \"Longident.unflatten\""]
(**

   This function is broken on identifiers that are not just "Word.Word.word";
   for example, it returns incorrect results on infix operators
   and extended module paths.

   If you want to generate long identifiers that are a list of
   dot-separated identifiers, the function {!unflatten} is safer and faster.
   {!unflatten} is available since OCaml 4.06.0.

   If you want to parse any identifier correctly, use the long-identifiers
   functions from the {!Parse} module, in particular {!Parse.longident}.
   They are available since OCaml 4.11, and also provide proper
   input-location support.

*)
