workspace(name = "system_lib")

load("//:defs.bzl", "system_library")

system_library(
    name = "SDL2",
    hdrs = [
        "SDL.h",
        "SDL_assert.h",
        "SDL_atomic.h",
        "SDL_audio.h",
        "SDL_blendmode.h",
        "SDL_clipboard.h",
        "SDL_config.h",
        "SDL_cpuinfo.h",
        "SDL_endian.h",
        "SDL_error.h",
        "SDL_events.h",
        "SDL_filesystem.h",
        "SDL_gamecontroller.h",
        "SDL_gesture.h",
        "SDL_haptic.h",
        "SDL_hints.h",
        "SDL_joystick.h",
        "SDL_keyboard.h",
        "SDL_keycode.h",
        "SDL_loadso.h",
        "SDL_log.h",
        "SDL_main.h",
        "SDL_messagebox.h",
        "SDL_mouse.h",
        "SDL_mutex.h",
        "SDL_pixels.h",
        "SDL_platform.h",
        "SDL_power.h",
        "SDL_quit.h",
        "SDL_rect.h",
        "SDL_render.h",
        "SDL_rwops.h",
        "SDL_scancode.h",
        "SDL_sensor.h",
        "SDL_shape.h",
        "SDL_stdinc.h",
        "SDL_surface.h",
        "SDL_system.h",
        "SDL_thread.h",
        "SDL_timer.h",
        "SDL_touch.h",
        "SDL_version.h",
        "SDL_video.h",
        "begin_code.h",
        "close_code.h",
    ],
    includes = ["/usr/include/x86_64-linux-gnu/SDL2"],
    lib_name = "SDL2",
)

system_library(
    name = "SDL2_image",
    hdrs = [
        "SDL_image.h",
    ],
    includes = [
        "/usr/include/SDL2",
    ],
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
    includes = ["/usr/include/x86_64-linux-gnu/"],
    lib_name = "jpeg",
)
