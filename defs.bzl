def _make_flags(array_of_strings, prefix):
    flags = []
    if array_of_strings:
        for s in array_of_strings:
            flags.append(prefix + s)
    return " ".join(flags)

def _execute_bash(repo_ctx, cmd):
    return repo_ctx.execute(["/bin/bash", "-c", cmd])

def _find_linker(repo_ctx):
    ld = _execute_bash(repo_ctx, "which ld").stdout.replace("\n", "")
    lld = _execute_bash(repo_ctx, "which lld").stdout.replace("\n", "")
    if ld:
        return ld
    elif lld:
        return lld
    else:
        fail("No linker found")

def _find_lib_path(repo_ctx, lib_name, archive_name, lib_path_hints):
    path_flags = _make_flags(lib_path_hints, "-L")
    linker = _find_linker(repo_ctx)
    cmd = """
          {} -verbose -l:{} {} | \\
          grep succeeded | \\
          sed -e 's/^\s*attempt to open //' -e 's/ succeeded\s*$//'
          """.format(
        linker,
        archive_name,
        path_flags,
    )
    result = repo_ctx.execute(["/bin/bash", "-c", cmd])

    # No idea where that newline comes from
    return result.stdout.replace("\n", "")

def _get_archive_name(lib_name, static):
    if static:
        return "lib" + lib_name + ".a"
    else:
        return "lib" + lib_name + ".so"

def system_library_impl(repo_ctx):
    repo_name = repo_ctx.attr.name
    lib_name = repo_ctx.attr.lib_name
    includes = repo_ctx.attr.includes
    deps = repo_ctx.attr.deps
    lib_path_hints = repo_ctx.attr.lib_path_hints
    linkstatic = repo_ctx.attr.linkstatic
    lib_archive_names = repo_ctx.attr.lib_archive_names

    archive_found_path = ""
    archive_fullname = ""
    for name in lib_archive_names:
        archive_fullname = _get_archive_name(name, linkstatic)
        archive_found_path = _find_lib_path(repo_ctx, lib_name, archive_fullname, lib_path_hints)
        if archive_found_path:
            break

    if not archive_found_path:
        fail("Library {} could not be found".format(lib_name))

    static_library_param = "static_library = \"{}\",".format(archive_fullname) if linkstatic else ""
    shared_library_param = "shared_library = \"{}\",".format(archive_fullname) if not linkstatic else ""
    repo_ctx.symlink(archive_found_path, archive_fullname)

    deps_names = []
    for dep in deps:
        dep_name = repr("@" + dep)
        deps_names.append(dep_name)
    deps_param = "deps = [{}],".format(",".join(deps_names))

    remote_archive_fullname = "remote/" + archive_fullname
    link_library_command = "ln -sf {} $(RULEDIR)/{}".format(archive_found_path, remote_archive_fullname)

    remote_library_param = "static_library = \"remote_link_archive\"," if linkstatic else "shared_library = \"remote_link_archive\","

    includes_param = "includes = {}".format(str(includes))

    repo_ctx.file(
        "BUILD",
        executable = False,
        content =
            """
load("@bazel_tools//tools/build_defs/cc:cc_import.bzl", "cc_import")
cc_import(
    name = "local_includes",
    {static_library}
    {shared_library}
    {deps}
    {includes}
)

genrule(
    name = "remote_link_archive",
    outs = ["{remote_archive_fullname}"],
    cmd = {link_library_command}
)

cc_import(
    name = "remote_includes",
    {remote_library_param}
    {deps}
    {includes}
)

alias(
    name = "{name}",
    actual = select({{
        "@bazel_tools//src/conditions:remote": "remote_includes",
        "//conditions:default": "local_includes",
    }}),
    visibility = ["//visibility:public"],
)
""".format(
                static_library = static_library_param,
                shared_library = shared_library_param,
                deps = deps_param,
                archive_fullname = archive_fullname,
                link_library_command = repr(link_library_command),
                remote_library_param = remote_library_param,
                name = lib_name,
                includes = includes_param,
                remote_archive_fullname = remote_archive_fullname,
            ),
    )

system_library = repository_rule(
    implementation = system_library_impl,
    local = True,
    remotable = True,
    environ = [],
    attrs = {
        "lib_name": attr.string(mandatory = True),
        "lib_archive_names": attr.string_list(),
        "lib_path_hints": attr.string_list(),
        "includes": attr.string_list(),
        "deps": attr.string_list(),
        "linkstatic": attr.bool(),
    },
)
