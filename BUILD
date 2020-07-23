load("@bazel_tools//tools/build_defs/cc:cc_import.bzl", "cc_import")

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    linkstatic = 1,
    deps = [
        "@SDL2//:includes",
        "@SDL2_image//:includes",
        "@jpeg//:includes",
    ],
)