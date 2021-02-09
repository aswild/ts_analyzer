# cmake build files for ts_analyzer
# Author: Allen Wild

cmake_minimum_required(VERSION 3.3)
project(ts_analyzer LANGUAGES C CXX)

# default to release with debug info, rather than no build type
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Set the build type" FORCE)
endif()

if ((CMAKE_CXX_COMPILER_ID STREQUAL "GNU") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    set(GCC_OR_CLANG TRUE)
endif()

# Ninja buffers output, so force-enable colors for GCC and Clang. Not necessary, but fun.
# This is the ONLY time we touch the global CMAKE_C_FLAGS and CMAKE_CXX_FLAGS variables.
# All other flags are target-specific.
if (CMAKE_GENERATOR STREQUAL "Ninja" AND GCC_OR_CLANG)
    list(APPEND CMAKE_C_FLAGS -fdiagnostics-color=always)
    list(APPEND CMAKE_CXX_FLAGS -fdiagnostics-color=always)
endif()

# includes
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
include(FindPackageMessage)
include(GNUInstallDirs)

# automatically handle moc, ui, and qrc files
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# dependencies
find_package(Qt5 COMPONENTS Core Gui Widgets REQUIRED)
find_package_message(Qt5 "Found Qt5 version ${Qt5_VERSION}" "${Qt5_VERSION}")

find_package(QtAV COMPONENTS Widgets REQUIRED)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libavcodec libavcodec REQUIRED IMPORTED_TARGET)
pkg_check_modules(libavformat libavformat REQUIRED IMPORTED_TARGET)
pkg_check_modules(libavutil libavutil REQUIRED IMPORTED_TARGET)

# project source files
set(ts_analyzer_SOURCES
    byte_view_text.cpp
    h264_avcc.c
    h264_sei.c
    h264_stream.c
    main.cpp
    mainwindow.cpp
    parse_thread.cpp
    playdialog.cpp
    proto_tree.cpp
    rightclickabletablewidget.cpp
    rightclickabletreewidget.cpp
    ts_parser.c
    tsstreamdevice.cpp
)

set(ts_analyzer_HEADERS
    bs.h
    byte_view_text.h
    h264_avcc.h
    h264_sei.h
    h264_stream.h
    mainwindow.h
    parse_thread.h
    playdialog.h
    proto_tree.h
    rightclickabletablewidget.h
    rightclickabletreewidget.h
    ts_parser.h
    tsstreamdevice.h
)

set(ts_analyzer_RESOURCES
    ts_analyzer.qrc
)

# project compile flags
if (GCC_OR_CLANG)
    set(WARN_FLAGS -Wall -Wextra -Wno-unused-parameter)
    # hide deprecated warnings in libav. TODO: they should be fixed instead
    list(APPEND WARN_FLAGS -Wno-deprecated-declarations)
endif()

# executable target
add_executable(ts_analyzer ${ts_analyzer_SOURCES} ${ts_analyzer_HEADERS} ${ts_analyzer_RESOURCES})
target_compile_options(ts_analyzer PRIVATE ${WARN_FLAGS})

# link libraries using cmake targets. This magically sets include paths too
target_link_libraries(ts_analyzer
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    QtAV::QtAV
    QtAV::Widgets
    PkgConfig::libavcodec
    PkgConfig::libavformat
    PkgConfig::libavutil
)

# the only thing to install is the binary
install(TARGETS ts_analyzer RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
