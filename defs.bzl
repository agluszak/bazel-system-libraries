def _find_lib_path(repo_ctx, archive_name, lib_path_hints):
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

def _find_header_path(repo_ctx, header_name, includes):
    include_params = []
    for include in includes:
        include_params.append("-I" + include)

    # taken from https://stackoverflow.com/questions/63052707/which-header-exactly-will-c-preprocessor-include/63052918#63052918
    cmd = "f=\"{}\"; echo | gcc -E {} -Wp,-v - 2>&1 | sed '\\~^ /~!d; s/ //' | while IFS= read -r path; do if [[ -e \"$path/$f\" ]]; then echo \"$path/$f\"; break; fi; done".format(
        header_name,
        " ".join(include_params),
    )
    result = repo_ctx.execute(["/bin/bash", "-c", cmd])
    return result.stdout.replace("\n", "")

def _get_archive_name(lib_name, static):
    if static:
        return "lib" + lib_name + ".a"
    else:
        return "lib" + lib_name + ".so"

def _system_library_impl(repo_ctx):
    lib_name = repo_ctx.attr.lib_name
    includes = repo_ctx.attr.includes
    hdrs = repo_ctx.attr.hdrs
    deps = repo_ctx.attr.deps
    lib_path_hints = repo_ctx.attr.lib_path_hints

    static_archive_name = _get_archive_name(lib_name, True)
    static_lib_path = _find_lib_path(repo_ctx, static_archive_name, lib_path_hints)
    shared_archive_name = _get_archive_name(lib_name, False)
    shared_lib_path = _find_lib_path(repo_ctx, shared_archive_name, lib_path_hints)
    if not static_lib_path and not shared_lib_path:
        fail("Library {} could not be found".format(lib_name))

    static_library_param = ""
    if static_lib_path:
        repo_ctx.symlink(static_lib_path, "lib.a")
        static_library_param = "static_library = \"{}\",".format(static_archive_name)
    shared_library_param = ""
    if shared_lib_path:
        repo_ctx.symlink(shared_lib_path, shared_archive_name)
        static_library_param = "shared_library = \"{}\",".format(shared_archive_name)

#    include_names = []
#    for include in includes:
#        include_name = include.lstrip("/").replace("/", "-")
#        include_names.append(repr(include_name))
#        repo_ctx.symlink(include, include_name)
#    includes_param = "includes = [{}],".format(", ".join(include_names))

    hdr_names = []
    for hdr in hdrs:
        hdr_path = _find_header_path(repo_ctx, hdr, includes)
        if not hdr_path:
            fail("Could not find header {}".format(hdr))
        repo_ctx.symlink(hdr_path, hdr)
        hdr_names.append(repr(hdr))
    hdrs_param = "hdrs = [{}],".format(", ".join(hdr_names))

    deps_names = []
    for dep in deps:
        dep_name = repr("@" + dep + "//:includes")
        deps_names.append(dep_name)
    deps_param = "deps = [{}],".format(",".join(deps_names))

    repo_ctx.file(
        "BUILD",
        executable = False,
        content =
            """
load("@bazel_tools//tools/build_defs/cc:cc_import.bzl", "cc_import")
cc_import(
    name = "includes",
    {static_library}
    {shared_library}
    {hdrs}
    {deps}
    visibility = ["//visibility:public"],
)
""".format(
                static_library = static_library_param,
                shared_library = shared_library_param,
                hdrs = hdrs_param,
                deps = deps_param),
    )

system_library = repository_rule(
    implementation = _system_library_impl,
    local = True,
    attrs = {
        "lib_name": attr.string(mandatory = True),
        "lib_path_hints": attr.string_list(),
        "includes": attr.string_list(),
        "hdrs": attr.string_list(),
        "deps": attr.string_list()
    },
)
