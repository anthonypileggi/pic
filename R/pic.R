#' Take a pic of your package
#' @param pkg target package (char/scalar)
#' @export
pic <- function(pkg, type = c("selfie", "friends", "followers")) {
  out <- list(
    pkg = pkg,
    selfie = selfie(pkg),
    friends = pkg_deps_pic(pkg, "in"),
    followers = pkg_deps_pic(pkg, "out")
    )
  as_pic(out)
}


# Helpers =========================================================

#' Take a package selfie
#' @param pkg target package (char/scalar)
selfie <- function(pkg) {

  # install/load package
  library(pkg, character.only = TRUE)

  # get a list of all functions
  funs <- pkg_funs(pkg)

  # parse function code as a string; capture all edges
  edge_list <- purrr::map_df(funs, pkg_fun_edges, funs)

  # node/edge list
  list(
    pkg = pkg,
    nodes = tibble::tibble(id = paste(funs)),
    edges = dplyr::filter(edge_list, to != from)
  )
}


#' Take a package dependency (i.e., friend/follower) pic
#' @param pkg package name
#' @param direction dependency direction (in/out)
pkg_deps_pic <- function(pkg, direction) {
  edges <- pkg_deps_edges(pkg, direction)
  list(
    pkg = pkg,
    nodes = tibble::tibble(id = unique(c(edges$to, edges$from))),
    edges = dplyr::filter(edges, to != from)
  )
}


# Constructors ===================================================

#' Assign to the 'pic' class
#' @param x an object containing pic data
#' @export
as_pic <- function(x) {
  if (!is_pic(x))
    class(x) <- append("pic", class(x))
  x
}

#' Check if an object is of the `pic` class
#' @param x an R object to check
#' @export
is_pic <- function(x) {
  inherits(x, "pic")
}

# Methods ==========================================================

#' Print a pic
#' @param x pic object
#' @export
print.pic <- function(x) {
  cat(paste0("The `", x$pkg, "` package is cool!\n"))
}

#' Summarize a pic object
#' @param x pic object
#' @export
summary.pic <- function(x) {
  cat(paste0("Wow, `", x$pkg, "` is such a cool package!\n"))
  cat(paste0("It has at least ", nrow(x$selfie$nodes), " functions.  Cool!\n"))
  cat(paste0("Oh, and did you know there are at least ", nrow(x$selfie$edges), " intra-function dependencies? That's crazy!\n"))
  cat(paste0("Friends are cool and dependable!  This package has ", nrow(x$friends$nodes), " of them!\n"))
  cat(paste0("And there are ", nrow(x$followers$nodes), " followers depending on `", x$pkg, "`.  What a cool package!\n"))
  cat(paste0("Want to see something cool?\n"))
  cat(paste0("\tSelfie:                          plot(x, type = 'selfie')\n"))
  cat(paste0("\tFriends (i.e., dependencies):    plot(x, type = 'friends')\n"))
  cat(paste0("\tFollowers (i.e., dependents):    plot(x, type = 'followers')\n"))
}

#' Draw a package pic
#' @param x pic object
#' @param type pic type (selfie/friends/followers)
#' @param show_names show names (logical/scalar)
#' @param show_edges show dependencies (logical/scalar)
#' @export
plot.pic <- function(x,
                     type = c("selfie", "friends", "followers"),
                     show_names = TRUE,
                     show_edges = TRUE) {
  library(ggplot2)
  library(ggraph)

  type <- type[1]
  df <- tidygraph::tbl_graph(nodes = x[[type]]$nodes, edges = x[[type]]$edges)

  g <- ggraph(df, layout = "fr") +
    theme_graph() +
    ggtitle(paste(x$pkg, type))

  if (show_names) {
    g <- g +
      geom_node_label(aes(label = id), color = "blue") +
      geom_edge_diagonal(
        arrow = arrow(length = unit(2, "mm"), type = "closed"),
        start_cap = circle(8, "mm"),
        end_cap = circle(8, "mm")
      )
  } else {
    g <- g +
      geom_node_point(aes(label = id), color = "blue") +
      geom_edge_diagonal(
        arrow = arrow(length = unit(2, "mm"), type = "closed")
      )
  }
  g
}
