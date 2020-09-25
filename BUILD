load("@bazel_tools//tools/build_defs/cc:cc_import.bzl", "cc_import")

exports_files(["defs.bzl"])

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    deps = [
        "@SDL2_image",
        "@jpeg",
        "@zlib"
    ],
)

cc_library(
    name = "main_lib",
    srcs = ["main.cpp"],
        deps = [
            "@SDL2_image",
            "@jpeg",
            "@zlib"
        ],
)


constraint_setting(name = "machine_size")

# A machine with "high cpu count".
constraint_value(
    name = "highcpu_machine",
    constraint_setting = ":machine_size",
    visibility = ["//visibility:public"],
)

platform(
    name = "default_host_platform",
    constraint_values = [
        ":highcpu_machine",
    ],
    parents = ["@local_config_platform//:host"],
)

REMOTE_PLATFORMS = ("rbe_ubuntu1604_java8", "rbe_ubuntu1804_java11")

[
    platform(
        name = platform_name + "_platform",
        parents = ["@" + platform_name + "//config:platform"],
        remote_execution_properties = """
            {PARENT_REMOTE_EXECUTION_PROPERTIES}
            properties: {
                name: "dockerNetwork"
                value: "standard"
            }
            properties: {
                name: "dockerPrivileged"
                value: "true"
            }
            """,
    )
    for platform_name in REMOTE_PLATFORMS
]

[
    # The highcpu RBE platform where heavy actions run on. In order to
    # use this platform add the highcpu_machine constraint to your target.
    platform(
        name = platform_name + "_highcpu_platform",
        constraint_values = [
            "//:highcpu_machine",
        ],
        parents = ["//:" + platform_name + "_platform"],
        remote_execution_properties = """
            {PARENT_REMOTE_EXECUTION_PROPERTIES}
            properties: {
                name: "gceMachineType"
                value: "n1-highcpu-32"
            }
            """,
    )
    for platform_name in REMOTE_PLATFORMS
]

