ENV_VAR_PREFIX = "bazel_"
ENV_VAR_LIB_PREFIX = "lib_"
ENV_VAR_INCLUDE_PREFIX = "include_"
ENV_VAR_SEPARATOR = ";"

def _make_flags(array_of_strings, prefix):
    flags = []
    if array_of_strings:
        for s in array_of_strings:
            flags.append(prefix + s)
    return flags.join(" ")

def _split_env_var(repo_ctx, var_name):
    value = repo_ctx.os.environ[var_name]
    if value:
        return value.split(ENV_VAR_SEPARATOR)
    else:
        return []

def _find_lib_path(repo_ctx, lib_name, archive_name, lib_path_hints):
    override_paths_var_name = ENV_VAR_PREFIX + ENV_VAR_LIB_PREFIX + lib_name + "_override_paths"
    override_paths = _split_env_var(repo_ctx, override_paths_var_name)
    path_flags = _make_flags(override_paths + lib_path_hints, "-L")

    cmd = """
          ld -verbose -l:{} {} | \\
          grep succeeded | \\
          sed -e 's/^\s*attempt to open //' -e 's/ succeeded\s*$//'
          """.format(
        archive_name,
        path_flags,
    )
    result = repo_ctx.execute(["/bin/bash", "-c", cmd])

    # No idea where that newline comes from
    return result.stdout.replace("\n", "")

def _find_header_path(repo_ctx, lib_name, header_name, includes):
    override_paths_var_name = ENV_VAR_PREFIX + ENV_VAR_INCLUDE_PREFIX + lib_name + "_override_paths"
    additional_paths_var_name = ENV_VAR_PREFIX + ENV_VAR_INCLUDE_PREFIX + lib_name + "_paths"
    override_paths = _split_env_var(repo_ctx, override_paths_var_name)
    additional_paths = _split_env_var(repo_ctx, additional_paths_var_name)

    # See https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html
    override_include_flags = _make_flags(override_paths, "-I")
    standard_include_flags = _make_flags(includes, "-isystem")
    additional_include_flags = _make_flags(additional_paths, "-idirafter")

    # Taken from https://stackoverflow.com/questions/63052707/which-header-exactly-will-c-preprocessor-include/63052918#63052918
    cmd = """
          f=\"{}\"; \\
          echo | \\
          gcc -E {} {} {} -Wp,-v - 2>&1 | \\
          sed '\\~^ /~!d; s/ //' | \\
          while IFS= read -r path; \\
              do if [[ -e \"$path/$f\" ]]; \\
                  then echo \"$path/$f\";  \\
                  break; \\
              fi; \\
          done
          """.format(
        header_name,
        override_include_flags,
        standard_include_flags,
        additional_include_flags,
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
    linkstatic = repo_ctx.attr.linkstatic
    lib_archive_names = repo_ctx.attr.lib_archive_names

    archive_found_path = ""
    archive_fullname = ""
    for name in lib_archive_names:
        archive_fullname = _get_archive_name(name, linkstatic)
        archive_found_path = _find_lib_path(repo_ctx, lib_name, archive_fullname, lib_path_hints)
        if found_path:
            break

    if not archive_found_path:
        fail("Library {} could not be found".format(lib_name))

    static_library_param = "static_library = \"{}\",".format(archive_fullname) if linkstatic else ""
    shared_library_param = "shared_library = \"{}\",".format(archive_fullname) if not linkstatic else ""
    repo_ctx.symlink(archive_found_path, archive_fullname)

    hdr_names = []
    hdr_paths = []
    for hdr in hdrs:
        hdr_path = _find_header_path(repo_ctx, lib_name, hdr, includes)
        if hdr_path:
            repo_ctx.symlink(hdr_path, hdr)
            hdr_names.append(repr(hdr))
            hdr_paths.append(hdr_path)
        else:
            print("Could not find header {}".format(hdr))

    hdrs_param = "hdrs = [{}],".format(", ".join(hdr_names))

    deps_names = []
    for dep in deps:
        dep_name = repr("@" + dep + "//:includes")
        deps_names.append(dep_name)
    deps_param = "deps = [{}],".format(",".join(deps_names))

    link_hdrs_command = ""
    for path, hdr in zip(hdr_paths, hdr_names):
        link_hdrs_command += "ln -sf {} $(@D)/{}".format(path, hdr)

    link_library_command = "ln -sf {} $(@D)/{}".format(archive_found_path, archive_fullname)

    remote_library_param = "static_library = \"remote_link_archive\"," if linkstatic else "shared_library = \"remote_link_archive\","

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
                {hdrs}
                {deps}
            )

            genrule(
                name = "remote_link_headers",
                outs = {hdr_names},
                cmd = {link_hdrs_command}
            )

            genrule(
                name = "remote_link_archive",
                outs = [{archive_fullname}],
                cmd = {link_library_command}
            )

            cc_import(
                name = "remote_includes",
                hdrs = [":remote_link_headers"],
                {remote_library_param}
                {deps}
            )

            alias(
                name = "includes",
                actual = select({
                    "@bazel_tools//src/conditions:remote": "remote_includes",
                    "//conditions:default": "local_includes",
                })
                visibility = ["//visibility:public"],
            )
            """.format(
                static_library = static_library_param,
                shared_library = shared_library_param,
                hdrs = hdrs_param,
                deps = deps_param,
                hdr_names = str(hdr_names),
                link_hdrs_command = link_hdrs_command,
                link_library_command = link_library_command,
                remote_library_param = remote_library_param,
            ),
    )

system_library = repository_rule(
    implementation = _system_library_impl,
    local = True,
    attrs = {
        "lib_name": attr.string(mandatory = True),
        "lib_archive_names": attr.string_list(),
        "lib_path_hints": attr.string_list(),
        "includes": attr.string_list(),
        "hdrs": attr.string_list(),
        "deps": attr.string_list(),
        "linkstatic": attr.bool(),
    },
)
