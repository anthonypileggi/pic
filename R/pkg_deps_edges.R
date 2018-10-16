#' Get all package dependencies/dependents
#' @param pkg package name
#' @param direction dependency direction (in/out)
pkg_deps_edges <- function(pkg, direction = c("in", "out")) {

  reverse <- switch(direction[1], "in" = FALSE, "out" = TRUE)

  # initialize variables
  pkgs <- pkg
  pkgs_diff <- TRUE
  edges <- tibble::tibble(from = character(), to = character())

  # iterate to find all sub-dependencies
  pkg_db <- available.packages(repos = "http://cran.us.r-project.org")
  while (pkgs_diff) {
    d <- tools::package_dependencies(pkgs, reverse = reverse, db = pkg_db)
    for (p in pkgs) {
      if (length(d[[p]]) > 0)
        edges <- rbind(edges, tibble::tibble(from = p, to = d[[p]]))
    }
    pkgs_old <- pkgs
    pkgs <- setdiff(unique(edges$to), unique(edges$from))
    pkgs_diff <- !identical(pkgs, pkgs_old)
  }
  edges
}