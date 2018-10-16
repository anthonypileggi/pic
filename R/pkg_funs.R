#' Get a list of all functions within the package
#' @param pkg target package (char/scalar)
pkg_funs <- function(pkg) {
  lsf.str(paste0("package:", pkg))
}