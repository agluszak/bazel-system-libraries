workspace(name = "system_lib")

load("//:defs.bzl", "system_library")

system_library(
    name = "SDL2",
    hdrs = [
        "SDL2/SDL.h",
    ],
    exec_properties = {"container-image": "docker://gcr.io/tensorflow-system-libraries/sdl-demo@sha256:e60e72c97bab92906abd9d8584772ab526bb49042683464343b007d7d9a92a30"},
    includes = [
        "/usr/include/SDL2/",
        "/usr/include/x86_64-linux-gnu/SDL2",
    ],
    shared_lib_names = ["libSDL2.so"],
    optional_hdrs = [
        "SDL2/SDL_assert.h",
        "SDL2/SDL_atomic.h",
        "SDL2/SDL_audio.h",
        "SDL2/SDL_blendmode.h",
        "SDL2/SDL_clipboard.h",
        "SDL2/SDL_config.h",
        "SDL2/SDL_cpuinfo.h",
        "SDL2/SDL_endian.h",
        "SDL2/SDL_error.h",
        "SDL2/SDL_events.h",
        "SDL2/SDL_filesystem.h",
        "SDL2/SDL_gamecontroller.h",
        "SDL2/SDL_gesture.h",
        "SDL2/SDL_haptic.h",
        "SDL2/SDL_hints.h",
        "SDL2/SDL_joystick.h",
        "SDL2/SDL_keyboard.h",
        "SDL2/SDL_keycode.h",
        "SDL2/SDL_loadso.h",
        "SDL2/SDL_log.h",
        "SDL2/SDL_main.h",
        "SDL2/SDL_messagebox.h",
        "SDL2/SDL_mouse.h",
        "SDL2/SDL_mutex.h",
        "SDL2/SDL_pixels.h",
        "SDL2/SDL_platform.h",
        "SDL2/SDL_power.h",
        "SDL2/SDL_quit.h",
        "SDL2/SDL_rect.h",
        "SDL2/SDL_render.h",
        "SDL2/SDL_rwops.h",
        "SDL2/SDL_scancode.h",
        "SDL2/SDL_sensor.h",
        "SDL2/SDL_shape.h",
        "SDL2/SDL_stdinc.h",
        "SDL2/SDL_surface.h",
        "SDL2/SDL_system.h",
        "SDL2/SDL_thread.h",
        "SDL2/SDL_timer.h",
        "SDL2/SDL_touch.h",
        "SDL2/SDL_version.h",
        "SDL2/SDL_video.h",
        "SDL2/SDL_metal.h",
        "SDL2/_real_SDL_config.h",
        "SDL2/begin_code.h",
        "SDL2/close_code.h",
    ],
)

system_library(
    name = "SDL2_image",
    hdrs = [
        "SDL2/SDL_image.h",
    ],
    exec_properties = {"container-image": "docker://gcr.io/tensorflow-system-libraries/sdl-demo@sha256:b57ca412f871fc11a9294c7d2b44e9d5f3c12c1ad8e56a7c2a05a0f807b3985c"},
    shared_lib_names = ["libSDL2_image.so"],
        includes = [
            "/usr/include/SDL2/",
            "/usr/include/x86_64-linux-gnu/SDL2",
        ],
    deps = ["SDL2"],
)

system_library(
    name = "jpeg",
    hdrs = [
        "jpeglib.h",
    ],
    exec_properties = {"container-image": "docker://gcr.io/tensorflow-system-libraries/sdl-demo@sha256:b57ca412f871fc11a9294c7d2b44e9d5f3c12c1ad8e56a7c2a05a0f807b3985c"},
    shared_lib_names = ["libjpeg.so"],
    static_lib_names = ["libjpeg.a"],
    optional_hdrs = [
        "jconfig.h",
        "jmorecfg.h",
    ],
)

system_library(
    name = "zlib",
    hdrs = [
        "zlib.h",
    ],
    exec_properties = {"container-image": "docker://gcr.io/tensorflow-system-libraries/sdl-demo@sha256:b57ca412f871fc11a9294c7d2b44e9d5f3c12c1ad8e56a7c2a05a0f807b3985c"},
    shared_lib_names = ["libz.so", "libz.so.1"],
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_toolchains",
    sha256 = "7ebb200ed3ca3d1f7505659c7dfed01c4b5cb04c3a6f34140726fe22f5d35e86",
    strip_prefix = "bazel-toolchains-3.4.1",
    urls = [
        "https://github.com/bazelbuild/bazel-toolchains/releases/download/3.4.1/bazel-toolchains-3.4.1.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/releases/download/3.4.1/bazel-toolchains-3.4.1.tar.gz",
    ],
)

load("@bazel_toolchains//rules:rbe_repo.bzl", "rbe_autoconfig")

rbe_autoconfig(
    name = "rbe_ubuntu1804_java11",
    detect_java_home = True,
    registry = "gcr.io",
    repository = "bazel-public/ubuntu1804-bazel-java11",
    tag = "latest",
)

rbe_autoconfig(
    name = "rbe_ubuntu1604_java8",
    detect_java_home = True,
    registry = "gcr.io",
    repository = "tensorflow-system-libraries/sdl-demo",
    tag = "latest",
)