workspace(name = "system_lib")

load("//:defs.bzl", "system_library")

system_library(
    name = "SDL2",
    includes = [
        "/usr/include/SDL2",
        "/usr/include/x86_64-linux-gnu/SDL2",
    ],
    lib_archive_names = ["SDL2"],
    lib_name = "SDL2",
)

system_library(
    name = "SDL2_image",
    lib_archive_names = ["SDL2_image"],
    lib_name = "SDL2_image",
    deps = ["SDL2"],
)

system_library(
    name = "jpeg",
    lib_archive_names = ["jpeg"],
    lib_name = "jpeg",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_toolchains",
    sha256 = "caf516464966470c075c33fae53c33ada5f32f1d43dbeaaea7388fe6e006d001",
    strip_prefix = "bazel-toolchains-3.4.2",
    urls = [
        "https://github.com/bazelbuild/bazel-toolchains/releases/download/3.4.2/bazel-toolchains-3.4.2.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/releases/download/3.4.2/bazel-toolchains-3.4.2.tar.gz",
    ],
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

rbe_autoconfig(
    name = "rbe_default",
    )
# Creates a default toolchain config for RBE.
# Use this as is if you are using the rbe_ubuntu16_04 container,
# otherwise refer to RBE docs.
