#' Get a list of all defined variables within the package
#' @param pkg target package (char/scalar)
pkg_vars <- function(pkg) {
  ls.str(paste0("package:", pkg), mode = "list")
}