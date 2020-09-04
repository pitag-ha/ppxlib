include Ocaml_common.Syntaxerr

let variable_in_scope_error loc name = Variable_in_scope (loc, name)
