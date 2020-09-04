include Ocaml_common.Ast_mapper

let hft_mapper non_recursive_structure non_recursive_sig =
  let structure _ str = non_recursive_structure str in
  let signature _ sign = non_recursive_sig sign in
  { default_mapper with structure; signature }
