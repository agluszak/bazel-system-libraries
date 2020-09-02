cmake_minimum_required(VERSION 3.10)

project(system_lib)

add_executable(system_lib main.cpp)

find_package(JPEG REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS} ${SDL2_IMAGE_INCLUDE_DIRS} ${JPEG_INCLUDE_DIRS})
target_link_libraries(system_lib ${SDL2_LIBRARIES} ${SDL2_IMAGE_LIBRARIES} ${JPEG_LIBRARIES})

