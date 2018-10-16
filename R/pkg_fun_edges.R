#' Get dependent functions within the package
#' @param fun function to find dependents for
#' @param funs list of possible dependents
pkg_fun_edges <- function(fun, funs) {
  # get `fun`ction contents (as string)
  x <- capture.output(eval(parse(text = paste0("`", fun, "`"))))
  x <- paste(x, collapse = " ")

  # capture all edges with `funs`
  id <- stringr::str_detect(x, paste0(funs, "\\("))
  tibble::tibble(from = fun, to = funs[id])
}
