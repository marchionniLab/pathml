#' Run Function in R Session
#' @export
callr_exec <- function(func, env_name = "pathml-r") {
  callr::r(
    func = \(func_name, env_name) {
      withr::local_options(list(reticulate.conda_binary = NULL))
      withr::local_envvar(list(RETICULATE_CONDA = NULL))
      withr::local_envvar(list(RETICULATE_MINICONDA_PATH = NULL))
      withr::local_envvar(list(RETICULATE_PYTHON = NULL))
      withr::local_envvar(list(RETICULATE_PYTHON = NULL))
      rlang::exec(.fn = func_name, env_name)
    },
    args = list(func_name = func, env_name = env_name),
    show = TRUE
  )
}
