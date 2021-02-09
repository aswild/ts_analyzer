# Try to find the QtAV library
# Author: Allen Wild
#
# based on [1] and incorporating advice from [2]
#
# [1] https://github.com/wang-bin/QtAV/blob/dfb3425db1c2658abb65c3ce795fdcde31f17052/cmake/FindQtAV.cmake
# [2] https://dev.to/slurpsmadrips/how-to-find-packages-with-cmake-the-basics-ikk
#
# OUTPUTS:
# Imported library targets QtAV::QtAV and QtAV::QtAVWidgets that can be used with
# target_link_library.  QtAV::QtAVWidgets is only available when requesting the Widgets
# component with find_package, and depends on QtAV::QtAV.
#
# CACHE VARIABLES (advanced, for user-defined paths):
#   QTAV_INCLUDE_DIR        - Include path for QtAV headers
#   QTAV_LIBRARY            - Path to libQtAV library file
#   QTAVWIDGETS_INCLUDE_DIR - Include path for QtAVWidgets headers
#   QTAVWIDGETS_LIBRARY     - Path to libQtAVWidgets library file
#
# Users of this module should prefer the imported library targets, don't rely on the bare
# include_dir and library variables.

include(FindPackageMessage)
include(FindPackageHandleStandardArgs)

# find common Qt paths using qmake
find_package(Qt5 QUIET REQUIRED NO_MODULE COMPONENTS Core)
get_target_property(qmake Qt5::qmake LOCATION)
execute_process(
    COMMAND ${qmake} -query QT_INSTALL_HEADERS
    OUTPUT_VARIABLE _QT_INSTALL_HEADERS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${qmake} -query QT_INSTALL_LIBS
    OUTPUT_VARIABLE _QT_INSTALL_LIBS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# find core library
find_path(QTAV_INCLUDE_DIR
    NAMES QtAV.h
    HINTS ${_QT_INSTALL_HEADERS}
    PATH_SUFFIXES QtAV
)
find_library(QTAV_LIBRARY
    NAMES QtAV QtAV1
    HINTS ${_QT_INSTALL_LIBS}
)

# find widgets library, only if component is requested
if ("Widgets" IN_LIST QtAV_FIND_COMPONENTS)
    find_path(QTAVWIDGETS_INCLUDE_DIR
        NAMES QtAVWidgets.h
        HINTS ${_QT_INSTALL_HEADERS}
        PATH_SUFFIXES QtAVWidgets
    )
    find_library(QTAVWIDGETS_LIBRARY
        NAMES QtAVWidgets QtAVWidgets1
        HINTS ${_QT_INSTALL_LIBS}
    )
endif()

# unset temporary vars
unset(_QT_INSTALL_HEADERS)
unset(_QT_INSTALL_LIBS)

if (QTAVWIDGETS_INCLUDE_DIR AND QTAVWIDGETS_LIBRARY)
    # print a message manually for widgets. fphsa will print one for the main QtAV
    find_package_message(QtAVWidgets "Found QtAVWidgets: ${QTAVWIDGETS_LIBRARY}"
                         "[${QTAVWIDGETS_INCLUDE_DIR}][${QTAVWIDGETS_LIBRARY}]")
    set(QtAV_Widgets_FOUND TRUE)
endif()


# fail if required things weren't found, and set QtAV_FOUND and other variables.
# depends on component found variables (QtAV_Widgets_FOUND) already being set
find_package_handle_standard_args(QtAV
    REQUIRED_VARS QTAV_LIBRARY QTAV_INCLUDE_DIR
    HANDLE_COMPONENTS
)

# Mark these cache variables as advanced. Before CMP0102 (cmake 3.17), this can only be
# done if they've been already set
if (QtAV_FOUND)
    mark_as_advanced(QTAV_INCLUDE_DIR QTAV_LIBRARY)
endif()
if (QtAV_Widgets_FOUND)
    mark_as_advanced(QTAVWIDGETS_INCLUDE_DIR QTAVWIDGETS_LIBRARY)
endif()

# create imported library targets
if (QtAV_FOUND AND NOT TARGET QtAV::QtAV)
    add_library(QtAV::QtAV UNKNOWN IMPORTED)
    set_property(TARGET QtAV::QtAV PROPERTY IMPORTED_LOCATION ${QTAV_LIBRARY})
    target_include_directories(QtAV::QtAV INTERFACE ${QTAV_INCLUDE_DIR})
endif()

if (QtAV_Widgets_FOUND AND NOT TARGET QtAV::Widgets)
    add_library(QtAV::Widgets UNKNOWN IMPORTED)
    set_property(TARGET QtAV::Widgets PROPERTY IMPORTED_LOCATION ${QTAVWIDGETS_LIBRARY})
    target_include_directories(QtAV::Widgets INTERFACE ${QTAVWIDGETS_INCLUDE_DIR})
    target_link_libraries(QtAV::Widgets INTERFACE QtAV::QtAV)
endif()
