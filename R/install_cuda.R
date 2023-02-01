#' Install CUDA GPU Dependencies
#'
#' Install the version of cudatoolkit that matches the version of CUDA
#'   installed on the system.
#' @export
install_cuda <- function() {
  callr_exec(install_cuda_fun)
}

install_cuda_fun <- function(env_name = "pathml-r") {
  if (isTRUE(check_gpu())) {
    return(FALSE)
  }
  nv_smi_bin <- Sys.which("nvidia-smi")
  if (isTRUE(nv_smi_bin == "")) {
    return(FALSE)
  }
  sys_output <- system(
    glue::glue(
      "{nv_smi_bin} -q"
    ),
    intern = TRUE,
    ignore.stderr = TRUE
  )
  # TODO: @luciorq Check if nvidia-smi output is actually correct,
  # + if system fails.
  cuda_version <- sys_output |>
    stringr::str_extract("CUDA Version\\s+:\\s+[0-9]+\\.[0-9]+") |>
    stats::na.omit() |>
    as.character() |>
    utils::head(1) |>
    stringr::str_extract("[0-9]+\\.[0-9]+")
  reticulate::conda_install(
    envname = env_name,
    packages = glue::glue("cudatoolkit={cuda_version}")
  )
  return(TRUE)
}
