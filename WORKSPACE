workspace(name = "system_lib")

load("//:defs.bzl", "system_library")

system_library(
    name = "SDL2",
    hdrs = [
        "SDL2/SDL.h",
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
        "SDL2/_real_SDL_config.h",
        "SDL2/begin_code.h",
        "SDL2/close_code.h",
    ],
    includes = ["/usr/include/x86_64-linux-gnu"],
    lib_archive_names = ["SDL2"],
    lib_name = "SDL2",
)

system_library(
    name = "SDL2_image",
    hdrs = [
        "SDL2/SDL_image.h",
    ],
    lib_archive_names = ["SDL2_image"],
    lib_name = "SDL2_image",
    deps = ["SDL2"],
)

system_library(
    name = "jpeg",
    hdrs = [
        "jconfig.h",
        "jmorecfg.h",
        "jpeglib.h",
    ],
    includes = ["/usr/include/x86_64-linux-gnu"],
    lib_archive_names = ["jpeg"],
    lib_name = "jpeg",
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

rbe_autoconfig(name = "rbe_default")
# Creates a default toolchain config for RBE.
# Use this as is if you are using the rbe_ubuntu16_04 container,
# otherwise refer to RBE docs.
