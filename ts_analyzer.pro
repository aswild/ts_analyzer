#-------------------------------------------------
#
# Project created by QtCreator 2017-08-23T14:36:28
#
#-------------------------------------------------

QT       += core widgets gui avwidgets

TARGET = ts_analyzer
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    ts_parser.c \
    parse_thread.cpp \
    h264_avcc.c \
    h264_sei.c \
    h264_stream.c \
    playdialog.cpp \
    tsstreamdevice.cpp \
    rightclickabletreewidget.cpp \
    rightclickabletablewidget.cpp \
    proto_tree.cpp \
    byte_view_text.cpp

HEADERS  += mainwindow.h \
    ts_parser.h \
    parse_thread.h \
    bs.h \
    h264_avcc.h \
    h264_sei.h \
    h264_stream.h \
    playdialog.h \
    tsstreamdevice.h \
    rightclickabletreewidget.h \
    rightclickabletablewidget.h \
    proto_tree.h \
    byte_view_text.h

FORMS    += mainwindow.ui \
    playdialog.ui

QMAKE_CFLAGS += -Wno-deprecated-declarations
QMAKE_CXXFLAGS += -Wno-deprecated-declarations

LIBS += -lavformat -lavcodec -lavutil -lQtAVWidgets -lQtAV

RESOURCES += ts_analyzer.qrc
