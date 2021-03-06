# /*******************************************************************
#
# Part of the Fritzing project - http://fritzing.org
# Copyright (c) 2007-08 Fritzing
#
# Fritzing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Fritzing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Fritzing.  If not, see <http://www.gnu.org/licenses/>.
#
# ********************************************************************
#
# $Revision: 6960 $:
# $Author: irascibl@gmail.com $:
# $Date: 2013-04-10 12:15:14 +0200 (Mi, 10. Apr 2013) $
#
#********************************************************************/

# Fritzing requires two Qt-provided plugins in order to run correctly,
# however the QTPLUGIN syntax only seems to work if Qt is built statically,
# so QTPLUGIN is included here only for information purposes:
#
# QTPLUGIN  += qjpeg qsqlite


CONFIG += debug_and_release

win32 {
# release build using msvc 2010 needs to use Multi-threaded (/MT) for the code generation/runtime library option
# release build using msvc 2010 needs to add msvcrt.lib;%(IgnoreSpecificDefaultLibraries) to the linker/no default libraries option
        CONFIG -= embed_manifest_exe
        INCLUDEPATH += $$[QT_INSTALL_HEADERS]/QtZlib
        DEFINES += _CRT_SECURE_NO_DEPRECATE
        DEFINES += _WINDOWS
	RELEASE_SCRIPT = $$(RELEASE_SCRIPT)			# environment variable set from release script	

        message("target arch: $${QMAKE_TARGET.arch}")
        contains(QMAKE_TARGET.arch, x86_64) {
                RELDIR = ../release64
                DEBDIR = ../debug64
                DEFINES += WIN64
       }
       !contains(QMAKE_TARGET.arch, x86_64) {
                RELDIR = ../release32
                DEBDIR = ../debug32
        }
	
	Release:DESTDIR = $${RELDIR}
	Release:OBJECTS_DIR = $${RELDIR}
	Release:MOC_DIR = $${RELDIR}
	Release:RCC_DIR = $${RELDIR}
	Release:UI_DIR = $${RELDIR}

	Debug:DESTDIR = $${DEBDIR}
	Debug:OBJECTS_DIR = $${DEBDIR}
	Debug:MOC_DIR = $${DEBDIR}
	Debug:RCC_DIR = $${DEBDIR}
	Debug:UI_DIR = $${DEBDIR}
}
macx {
        RELDIR = ../release64
        DEBDIR = ../debug64
        Release:DESTDIR = $${RELDIR}
        Release:OBJECTS_DIR = $${RELDIR}
        Release:MOC_DIR = $${RELDIR}
        Release:RCC_DIR = $${RELDIR}
        Release:UI_DIR = $${RELDIR}

        Debug:DESTDIR = $${DEBDIR}
        Debug:OBJECTS_DIR = $${DEBDIR}
        Debug:MOC_DIR = $${DEBDIR}
        Debug:RCC_DIR = $${DEBDIR}
        Debug:UI_DIR = $${DEBDIR}


        CONFIG += x86_64 # x86 ppc
        QMAKE_INFO_PLIST = FritzingInfo.plist
        #DEFINES += QT_NO_DEBUG   		# uncomment this for xcode
        LIBS += -lz
        LIBS += /usr/lib/libz.dylib
        LIBS += /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
        LIBS += /System/Library/Frameworks/Carbon.framework/Carbon
        LIBS += /System/Library/Frameworks/IOKit.framework/Versions/A/IOKit
}
unix {
    !macx { # unix is defined on mac
        HARDWARE_PLATFORM = $$system(uname -m)
        contains( HARDWARE_PLATFORM, x86_64 ) {
            DEFINES += LINUX_64
        } else {
            DEFINES += LINUX_32
        }
        LIBS += -lz
    }

        isEmpty(PREFIX) {
                PREFIX = /usr
        }
        BINDIR = $$PREFIX/bin
        DATADIR = $$PREFIX/share
        PKGDATADIR = $$DATADIR/fritzing

        DEFINES += DATADIR=\\\"$$DATADIR\\\" PKGDATADIR=\\\"$$PKGDATADIR\\\"

        target.path =$$BINDIR

        desktop.path = $$DATADIR/applications
        desktop.files += fritzing.desktop

        manpage.path = $$DATADIR/man/man1
        manpage.files += Fritzing.1

        icon.path = $$DATADIR/icons
        icon.extra = install -D -m 0644 $$PWD/resources/images/fritzing_icon.png $(INSTALL_ROOT)$$DATADIR/icons/fritzing.png

        parts.path = $$PKGDATADIR
        parts.files += parts

        help.path = $$PKGDATADIR
        help.files += help

        sketches.path = $$PKGDATADIR
        sketches.files += sketches

        bins.path = $$PKGDATADIR
        bins.files += bins

        translations.path = $$PKGDATADIR/translations
        translations.extra = find $$PWD/translations -name "*.qm" -size +128c -exec cp -pr {} $(INSTALL_ROOT)$$PKGDATADIR/translations \\;

        syntax.path = $$PKGDATADIR/translations/syntax
        syntax.files += translations/syntax/*.xml

        INSTALLS += target desktop manpage icon parts sketches bins translations syntax help
}

ICON = resources/images/fritzing_icon.icns

macx {
    FILE_ICONS.files = resources/images/mac_fz_icon.icns resources/images/mac_fzz_icon.icns resources/images/mac_fzb_icon.icns resources/images/mac_fzp_icon.icns resources/images/mac_fzm_icon.icns resources/images/mac_fzpz_icon.icns
    FILE_ICONS.path = Contents/Resources
    QMAKE_BUNDLE_DATA += FILE_ICONS
}

QT += core gui svg xml network sql # opengl
greaterThan(QT_MAJOR_VERSION, 4) {
    QT += widgets printsupport concurrent serialport
} else {
    include($$QTSERIALPORT_PROJECT_ROOT/src/serialport/qt4support/serialport.prf)
}

RC_FILE = fritzing.rc
RESOURCES += phoenixresources.qrc


# Fritzing is using libgit2 since version 0.9.3

LIBGIT2INCLUDE = ../libgit2/include
exists($$LIBGIT2INCLUDE/git2.h) {
    message("found libgit2 include path at $$LIBGIT2INCLUDE")
}
else {
    message("Fritzing requires libgit2")
    message("Build it from the repo at https://github.com/libgit2")
    message("See https://github.com/fritzing/fritzing-app/wiki for details.")

    error("libgit2 include path not found in $$LIBGIT2INCLUDE")
}

INCLUDEPATH += $$LIBGIT2INCLUDE

win32 {
    contains(QMAKE_TARGET.arch, x86_64) {
            LIBGIT2LIB = ../libgit2/build64
    }
    else {
            LIBGIT2LIB = ../libgit2/build32
    }

    exists($$LIBGIT2LIB/git2.lib) {
        message("found libgit2 library in $$LIBGIT2LIB")
    }
    else {
        error("libgit2 library not found in $$LIBGIT2LIB")
    }
}

unix {
    LIBGIT2LIB = ../libgit2/build
    macx {
        exists($$LIBGIT2LIB/libgit2.dylib) {
            message("found libgit2 library in $$LIBGIT2LIB")
        }
        else {
            error("libgit2 library not found in $$LIBGIT2LIB")
        }
    }
    !macx {
        exists($$LIBGIT2LIB/libgit2.so) {
            message("found libgit2 library in $$LIBGIT2LIB")
        }
        else {
            error("libgit2 library not found in $$LIBGIT2LIB")
        }
    }
}

LIBS += -L$$LIBGIT2LIB -lgit2

include(pri/kitchensink.pri)
include(pri/mainwindow.pri)
include(pri/partsbinpalette.pri)
include(pri/partseditor.pri)
include(pri/referencemodel.pri)
include(pri/svg.pri)
include(pri/help.pri)
include(pri/version.pri)
include(pri/eagle.pri)
include(pri/utils.pri)
include(pri/dock.pri)
include(pri/items.pri)
include(pri/autoroute.pri)
include(pri/dialogs.pri)
include(pri/connectors.pri)
include(pri/infoview.pri)
include(pri/model.pri)
include(pri/sketch.pri)
include(pri/translations.pri)
include(pri/program.pri)
include(pri/qtsysteminfo.pri)

!contains(DEFINES, QUAZIP_INSTALLED) {
        include(pri/quazip.pri)
}
contains(DEFINES, QUAZIP_INSTALLED) {
        INCLUDEPATH += /usr/include/quazip /usr/include/minizip
        LIBS += -lquazip -lminizip
}

TARGET = Fritzing
TEMPLATE = app


message("libs $$LIBS")


