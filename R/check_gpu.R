#' Check if GPU is Available to PyTorch
#'
#' @return `TRUE` if GPU is available, `FALSE` otherwise.
#' @export
check_gpu <- function() {
  callr_exec(check_gpu_fun)
}

check_gpu_fun <- function(env_name = "pathml-r") {
  reticulate::use_condaenv(
    condaenv = env_name,
    conda = "auto",
    required = TRUE
  )
  if (!isTRUE(reticulate::py_module_available("torch"))) {
    return(FALSE)
  }
  x <- reticulate::import("torch")
  return(x$cuda$is_available())
}
