find_package(Sanitizers)

if(NOT COMMAND add_sanitizers)
    message(WARNING "Sanitizers CMake module not found, sanitizer support is not available")
    # defining a no-op function to avoid CMake errors
    function(add_sanitizers ...)
    endfunction()
endif()

# the runtime build configuration is quite long, therefore it's managed in a separate CMake script
include(build-runtime.cmake)
