def _find_lib_path(repo_ctx, lib_name, lib_path_hints, static):
    archive_name = _get_archive_name(lib_name, static)
    hint_params = []
    for hint in lib_path_hints:
        hint_params.append("-L" + hint)

    cmd = "ld -verbose -l:{} {} | grep succeeded | sed -e 's/^\s*attempt to open //' -e 's/ succeeded\s*$//'".format(
        archive_name,
        " ".join(hint_params),
    )
    result = repo_ctx.execute(["/bin/bash", "-c", cmd])

    # No idea where that newline comes from
    return result.stdout.replace("\n", "")

def _get_archive_name(lib_name, static):
    if static:
        return "lib" + lib_name + ".a"
    else:
        return "lib" + lib_name + ".so"

def _system_library_impl(repo_ctx):
    lib_name = repo_ctx.attr.lib_name
    includes = repo_ctx.attr.includes
    lib_path_hints = repo_ctx.attr.lib_path_hints
    static_lib_path = _find_lib_path(repo_ctx, lib_name, lib_path_hints, True)
    shared_lib_path = _find_lib_path(repo_ctx, lib_name, lib_path_hints, False)
    if not static_lib_path and not shared_lib_path:
        fail("Library {} could not be found".format(lib_name))

    static_library_param = ""
    if static_lib_path:
        repo_ctx.symlink(static_lib_path, "lib.a")
        static_library_param = "static_library = \"lib.a\","
    shared_library_param = ""
    if shared_lib_path:
        repo_ctx.symlink(shared_lib_path, "lib.so")
        static_library_param = "shared_library = \"lib.so\","

    include_names = []
    for include in includes:
        include_name = include.lstrip("/").replace("/", "-")
        include_names.append(repr(include_name))
        repo_ctx.symlink(include, include_name)
    includes_param = "includes = [{}],".format(", ".join(include_names))

    repo_ctx.file(
        "BUILD",
        executable = False,
        content =
            """
load("@bazel_tools//tools/build_defs/cc:cc_import.bzl", "cc_import")
cc_library(
    name = "includes",
    {static_library}
    {shared_library}
    {includes}
    visibility = ["//visibility:public"],
)
""".format(
                static_library = static_library_param,
                shared_library = shared_library_param,
                includes = includes_param,
            ),
    )

system_library = repository_rule(
    implementation = _system_library_impl,
    local = True,
    attrs = {
        "lib_name": attr.string(mandatory = True),
        "lib_path_hints": attr.string_list(),
        "includes": attr.string_list(),
    },
)
