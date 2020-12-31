# >= 3.2 required for ExternalProject_Add_StepDependencies
cmake_minimum_required(VERSION 3.2)


include(${PROJECT_SOURCE_DIR}/lib/libappimage/cmake/scripts.cmake)


# the names of the targets need to differ from the library filenames
# this is especially an issue with libcairo, where the library is called libcairo
# therefore, all libs imported this way have been prefixed with lib
import_pkgconfig_target(TARGET_NAME libfuse PKGCONFIG_TARGET fuse)


if(USE_CCACHE)
    message(STATUS "Using CCache to build dependencies")
    # TODO: find way to use find_program with all possible paths
    # (might differ from distro to distro)
    # these work on Debian and Ubuntu:
    set(CC "/usr/lib/ccache/gcc")
    set(CXX "/usr/lib/ccache/g++")
else()
    set(CC "${CMAKE_C_COMPILER}")
    set(CXX "${CMAKE_CXX_COMPILER}")
endif()

set(CFLAGS ${DEPENDENCIES_CFLAGS})
set(CPPFLAGS ${DEPENDENCIES_CPPFLAGS})
set(LDFLAGS ${DEPENDENCIES_LDFLAGS})
