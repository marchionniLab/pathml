#' Install pathml System Dependencies
#'
#' This function installs the system dependencies for pathml.
#'   It is recommended to run this function before using pathml.
#'   This function will install the system dependencies into a
#'   conda environment called `pathml-r`.
#' @param env_name (optional) name of conda environment to install
#'  dependencies into. Default is `pathml-r`.
#' @param rebuild (optional) rebuild the conda environment. Default is `FALSE`.
#'
#' @export
install_deps <- function(env_name = "pathml-r", rebuild = FALSE) {
  withr::local_options(list(reticulate.conda_binary = NULL))
  withr::local_envvar(list(RETICULATE_CONDA = NULL))
  withr::local_envvar(list(RETICULATE_PYTHON = NULL))
  withr::local_envvar(list(RETICULATE_MINICONDA_PATH = NULL))

  # Check if conda is installed
  if (!fs::file_exists(
    fs::path(reticulate::miniconda_path(), "bin", "conda")
  )) {
    callr::r(
      func = \() {
        withr::local_options(list(reticulate.conda_binary = NULL))
        withr::local_envvar(list(RETICULATE_CONDA = NULL))
        withr::local_envvar(list(RETICULATE_MINICONDA_PATH = NULL))
        withr::local_envvar(list(RETICULATE_PYTHON = NULL))
        reticulate::install_miniconda(
          update = TRUE,
          force = TRUE
        )
      },
      show = TRUE
    )
  }

  # Check if environment exists
  env_list <- reticulate::conda_list()
  if (!isTRUE(rebuild) && any(env_list$name %in% env_name)) {
    return(invisible(FALSE))
  }

  # TODO: @luciorq Add check for Windows,
  # + Check for WSL or Docker
  if (isTRUE(
    Sys.info()["machine"] %in% "arm64" &&
      Sys.info()["sysname"] %in% "Darwin"
  )) {
    cli::cli_abort(
      message =
        "{.pkg pathml} does not support Apple Silicon yet (ARM64 architecture)."
    )
  }
  callr_exec(
    func = \(env_name) {
      reticulate::conda_create(
        envname = env_name,
        packages = "python=3.8",
        forge = TRUE
      )
    }
  )
}
# TODO: @luciorq This dependencies do not work on Apple Silicon,
# + Need to check arm64 on Linux
if (!Sys.info()["machine"] %in% "arm64") {
  callr_exec(
    func = \(env_name) {
      reticulate::conda_install(
        envname = env_name,
        packages = c(
          "pip==21.3.1",
          "python==3.8",
          "numpy==1.19.5",
          "scipy==1.7.3",
          "scikit-image==0.18.3",
          "matplotlib==3.5.1",
          "python-spams==2.6.1",
          "openjdk==8.0.152",
          "pytorch==1.10.1",
          "h5py==3.1.0",
          "dask==2021.12.0",
          "pydicom==2.2.2",
          "pytest==6.2.5",
          "pre-commit==2.16.0",
          "coverage==5.5",
          "openslide==3.4.1"
        ),
        channel = c(
          "conda-forge",
          "bioconda",
          "pytorch"
        )
      )
    }
  )

  # Install Python Dependencies
  callr_exec(
    func = \(env_name) {
      reticulate::py_install(
        packages = c(
          "python-bioformats==4.0.0",
          "python-javabridge==4.0.0",
          "deepcell==0.11.0",
          "opencv-contrib-python==4.5.3.56",
          "openslide-python==1.1.2",
          "scanpy==1.8.2",
          "anndata==0.7.8",
          "tqdm==4.62.3",
          "loguru==0.5.3"
        ),
        envname = env_name,
        pip = TRUE,
        conda = "auto"
      )
      reticulate::py_install(
        packages = c(
          "pathml"
        ),
        envname = env_name,
        pip = TRUE,
        conda = "auto"
      )
    }
  )

  # install CUDA toolkit if available
  install_cuda()

  pathml_available <- callr_exec(
    func = \() {
      reticulate::use_condaenv(
        condaenv = env_name,
        conda = "auto",
        required = TRUE
      )
      reticulate::py_module_available("pathml")
    }
  )
  return(pathml_available)
}
