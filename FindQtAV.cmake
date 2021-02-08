# based on https://github.com/wang-bin/QtAV/blob/dfb3425db1c2658abb65c3ce795fdcde31f17052/cmake/FindQtAV.cmake
#
# - Try to find the QtAV library
#
# Standard find_package output variables are set, including QtAV_FOUND, QtAV_INCLUDE_DIRS, and
# QtAV_LIBRARIES.  If the Widgets component is requested, also set QtAV_Widgets_FOUND,
# QtAVWidgets_INCLUDE_DIRS, and QtAVWidgets_LIBRARIES
#
# Also create imported library targets QtAV::QtAV and QtAV::Widgets which can be used with
# target_link_libraries.
#
# TODO: support user-defined cache variables

include(FindPackageMessage)
include(FindPackageHandleStandardArgs)

# find common Qt paths using qmake
find_package(Qt5 QUIET REQUIRED NO_MODULE COMPONENTS Core)
get_target_property(qmake Qt5::qmake LOCATION)
execute_process(
    COMMAND ${qmake} -query QT_INSTALL_HEADERS
    OUTPUT_VARIABLE QT_INSTALL_HEADERS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${qmake} -query QT_INSTALL_LIBS
    OUTPUT_VARIABLE QT_INSTALL_LIBS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# find core library
find_path(QTAV_INCLUDE_DIR NAMES QtAV.h
    HINTS ${QT_INSTALL_HEADERS}
    PATH_SUFFIXES QtAV
)
find_library(QTAV_LIBRARY NAMES QtAV QtAV1
    HINTS ${QT_INSTALL_LIBS}
)

# set output variables
set(QtAV_INCLUDE_DIRS ${QTAV_INCLUDE_DIR})
set(QtAV_LIBRARIES ${QTAV_LIBRARY})
mark_as_advanced(QtAV_INCLUDE_DIRS QtAV_LIBRARIES)

# create imported target for QtAV
add_library(QtAV::QtAV UNKNOWN IMPORTED)
set_property(TARGET QtAV::QtAV PROPERTY IMPORTED_LOCATION  ${QtAV_LIBRARIES})
target_include_directories(QtAV::QtAV INTERFACE ${QtAV_INCLUDE_DIRS})

# do the same for QtAVWidgets, if requested
if ("Widgets" IN_LIST QtAV_FIND_COMPONENTS)
    # find paths
    find_path(QTAVWIDGETS_INCLUDE_DIR NAMES QtAVWidgets.h
        HINTS ${QT_INSTALL_HEADERS}
        PATH_SUFFIXES QtAVWidgets
    )
    find_library(QTAVWIDGETS_LIBRARY NAMES QtAVWidgets QtAVWidgets1
        HINTS ${QT_INSTALL_LIBS}
    )

    # check if found
    if ((NOT QTAVWIDGETS_INCLUDE_DIR MATCHES "QTAVWIDGETS_INCLUDE_DIR-NOTFOUND")
        AND (NOT QTAVWIDGETS_LIBRARY MATCHES "QTAVWIDGETS_LIBRARY-NOTFOUND"))
        # set output variables
        set(QtAV_Widgets_FOUND TRUE)
        set(QtAVWidgets_INCLUDE_DIRS ${QTAVWIDGETS_INCLUDE_DIR})
        set(QtAVWidgets_LIBRARIES ${QTAVWIDGETS_LIBRARY})
        mark_as_advanced(QtAVWidgets_INCLUDE_DIRS QtAVWidgets_LIBRARIES)

        # create import target
        add_library(QtAV::Widgets UNKNOWN IMPORTED)
        set_property(TARGET QtAV::Widgets PROPERTY IMPORTED_LOCATION ${QtAVWidgets_LIBRARIES})
        target_include_directories(QtAV::Widgets INTERFACE ${QtAVWidgets_INCLUDE_DIRS})
        target_link_libraries(QtAV::Widgets INTERFACE QtAV::QtAV)

        find_package_message(QtAVWidgets "Found QtAVWidgets: ${QtAVWidgets_LIBRARIES}"
                             "[${QtAVWidgets_INCLUDE_DIRS}][${QtAVWidgets_LIBRARIES}]")
    endif()
endif()

# check that the main library was found, and the Widgets component, if requested
find_package_handle_standard_args(QtAV
    REQUIRED_VARS QTAV_LIBRARY QTAV_INCLUDE_DIR
    HANDLE_COMPONENTS
)
