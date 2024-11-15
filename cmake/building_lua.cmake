include(GNUInstallDirs)
include(CheckFunctionExists)
include(CheckLibraryExists)

##
## Check for m lib
##

CHECK_FUNCTION_EXISTS(pow HAVE_POW)

if (NOT HAVE_POW)
    CHECK_LIBRARY_EXISTS(m pow "" HAVE_LIBM)

    if (HAVE_LIBM)
        list(APPEND CMAKE_REQUIRED_LIBRARIES m)
    endif()
endif()

##
## Check for readline
##

CHECK_FUNCTION_EXISTS(readline HAVE_READLINE)

set(_BSD_NAMES "FreeBSD;NetBSD;OpenBSD;DragonFly;MirBSD")

if ("${CMAKE_SYSTEM_NAME}" IN_LIST _BSD_NAMES)
    set(_BSD_LIKE ON)
    set(_READLINE_LIBNAME edit)
    find_path(READLINE_H_PARENT_INCLUDE_DIR "edit/readline/readline.h"
        REQUIRED)
    
    set(READLINE_H_INCLUDE_DIR "${READLINE_H_PARENT_INCLUDE_DIR}/edit")
else()
    set(_BSD_LIKE OFF)
    set(_READLINE_LIBNAME readline)
endif()

if (NOT HAVE_READLINE)

    CHECK_LIBRARY_EXISTS(${_READLINE_LIBNAME} readline "" HAVE_LIBREADLINE)

    if (HAVE_LIBREADLINE)
        list(APPEND CMAKE_REQUIRED_LIBRARIES ${_READLINE_LIBNAME})
    endif()
endif()

##
## Check for dl
##

CHECK_FUNCTION_EXISTS(dlopen HAVE_DLOPEN)

if (NOT HAVE_DLOPEN)
    CHECK_LIBRARY_EXISTS(dl dlopen "" HAVE_LIBDL)

    if (HAVE_LIBDL)
        list(APPEND CMAKE_REQUIRED_LIBRARIES dl)
    endif()
endif()

##
## Build Lua from the extracted source code directory
##

function(process_lua_from_source_code_dir source_code_dir major_version minor_version release_version)
    set(LUA_V "${major_version}.${minor_version}")
    set(LUA_R ${LUA_V}.${release_version})
    set(LUA_SUFFIX "${major_version}${minor_version}")
    set(LUA_LIBRARY_NAME "lua${LUA_SUFFIX}")
    
    if (WIN32)
        if (${LUA_R} VERSION_LESS_EQUAL "5.2.4")
            set(LUA_LDIR "${CMAKE_INSTALL_BINDIR}/lua")
            set(LUA_CDIR "${CMAKE_INSTALL_BINDIR}")
        else()
            set(LUA_LDIR "${CMAKE_INSTALL_DATAROOTDIR}/lua/${LUA_V}")
            set(LUA_CDIR "${CMAKE_INSTALL_LIBDIR}/lua/${LUA_V}")
        endif()
    else()
        set(LUA_LDIR "${CMAKE_INSTALL_DATAROOTDIR}/lua/${LUA_V}")
        set(LUA_CDIR "${CMAKE_INSTALL_LIBDIR}/lua/${LUA_V}")
    endif()

    message(STATUS "Building Lua version: ${LUA_R}")

    string(REPLACE "\\" "/" LUA_SOURCE_CODE_ESCAPED_DIR ${source_code_dir})

    set(LUA_SOURCE_CODE_SRC_DIR "${LUA_SOURCE_CODE_ESCAPED_DIR}/src")
    set(LUA_SOURCE_CODE_DOC_DIR "${LUA_SOURCE_CODE_ESCAPED_DIR}/doc")
    
    file(STRINGS "${LUA_SOURCE_CODE_SRC_DIR}/Makefile" lua_src_makefile_content REGEX " -DLUA_COMPAT_[a-zA-Z0-9_]+ ")
    
    if (${lua_src_makefile_content} MATCHES " -D(LUA_COMPAT_[a-zA-Z0-9_]+) ")
        set(LUA_COMPAT ${CMAKE_MATCH_1})
        message(STATUS "Lua compatibility mode: ${LUA_COMPAT}")
    else()
        set(LUA_COMPAT "")
        message(STATUS "Lua compatibility mode not found. Building with compatibility disabled.")
    endif()
    
    file(GLOB LUA_LIBRARY_SOURCE_FILES ${LUA_SOURCE_CODE_SRC_DIR}/*.c)
    list(FILTER LUA_LIBRARY_SOURCE_FILES EXCLUDE REGEX "luac?\\.c$")

    # Building Lua shared library (luaXY.dll on Windows and libluaXY.so on Unix)

    set(lua_shared_lib "lua${LUA_SUFFIX}_shared")

    add_library(${lua_shared_lib} SHARED ${LUA_LIBRARY_SOURCE_FILES})
    target_compile_definitions(${lua_shared_lib} PRIVATE ${LUA_COMPAT})
    
    if (WIN32)
        target_compile_definitions(${lua_shared_lib} PRIVATE LUA_BUILD_AS_DLL)
    elseif (_BSD_LIKE)
        target_include_directories(${lua_shared_lib} PRIVATE "${READLINE_H_INCLUDE_DIR}")
        target_compile_definitions(${lua_shared_lib} PRIVATE "LUA_USE_LINUX" "LUA_USE_READLINE")
    elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        target_compile_definitions(${lua_shared_lib} PRIVATE "LUA_USE_LINUX")
    elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
        target_compile_definitions(${lua_shared_lib} PRIVATE "LUA_USE_MACOSX" "LUA_USE_READLINE")
    elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS")
        target_compile_definitions(${lua_shared_lib} PRIVATE "LUA_USE_IOS")
    endif()
    
    target_include_directories(${lua_shared_lib} PRIVATE ${LUA_SOURCE_CODE_SRC_DIR})

    if (HAVE_LIBM)
        target_link_libraries(${lua_shared_lib} PRIVATE m)
    endif()

    if (HAVE_LIBREADLINE)
        target_link_libraries(${lua_shared_lib} PRIVATE ${_READLINE_LIBNAME})
    endif()

    if (HAVE_LIBDL)
        target_link_libraries(${lua_shared_lib} PRIVATE dl)
    endif()

    if (WIN32 AND NOT CYGWIN)
        set_target_properties(${lua_shared_lib}
            PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            PREFIX ""
            OUTPUT_NAME ${LUA_LIBRARY_NAME}
        )
    else()
        set_target_properties(${lua_shared_lib}
            PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            OUTPUT_NAME ${LUA_LIBRARY_NAME}
        )
    endif()

    # On Unix: Building Lua static library (luaXY.a)
    
    if (UNIX)
        set(lua_static_lib "lua${LUA_SUFFIX}_static")

        add_library(${lua_static_lib} STATIC ${LUA_LIBRARY_SOURCE_FILES})
        target_compile_definitions(${lua_static_lib} PRIVATE ${LUA_COMPAT})

        if (_BSD_LIKE)
            target_include_directories(${lua_static_lib} PRIVATE "${READLINE_H_INCLUDE_DIR}")
            target_compile_definitions(${lua_static_lib} PRIVATE "LUA_USE_LINUX" "LUA_USE_READLINE")
        elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
            target_compile_definitions(${lua_static_lib} PRIVATE "LUA_USE_LINUX")
        elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
            target_compile_definitions(${lua_static_lib} PRIVATE "LUA_USE_MACOSX" "LUA_USE_READLINE")
        elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "iOS")
            target_compile_definitions(${lua_static_lib} PRIVATE "LUA_USE_IOS")
        endif()

        target_include_directories(${lua_static_lib} PRIVATE ${LUA_SOURCE_CODE_SRC_DIR})

        if (HAVE_LIBM)
            target_link_libraries(${lua_static_lib} PRIVATE m)
        endif()

        if (HAVE_LIBREADLINE)
            target_link_libraries(${lua_static_lib} PRIVATE ${_READLINE_LIBNAME})
        endif()

        if (HAVE_LIBDL)
            target_link_libraries(${lua_static_lib} PRIVATE dl)
        endif()

        set_target_properties(${lua_static_lib}
            PROPERTIES
            OUTPUT_NAME ${LUA_LIBRARY_NAME}
        )
    endif()

    # Building Lua interpreter (lua)

    set(lua_interpreter "lua")

    add_executable(${lua_interpreter} ${LUA_SOURCE_CODE_SRC_DIR}/lua.c)
    target_compile_definitions(${lua_interpreter} PRIVATE ${LUA_COMPAT})

    target_include_directories(${lua_interpreter} PRIVATE ${LUA_SOURCE_CODE_SRC_DIR})

    if (WIN32)
        target_link_libraries(${lua_interpreter} PRIVATE ${lua_shared_lib})
    elseif (UNIX)
        target_link_libraries(${lua_interpreter} PRIVATE ${lua_static_lib})
        target_link_options(${lua_interpreter} PRIVATE "LINKER:-E")
    else()
        message(FATAL_ERROR "Unsupported Operating System.")
    endif()

    if (HAVE_LIBM)
        target_link_libraries(${lua_interpreter} PRIVATE m)
    endif()

    if (HAVE_LIBREADLINE)
        target_link_libraries(${lua_interpreter} PRIVATE ${_READLINE_LIBNAME})
    endif()

    if (HAVE_LIBDL)
        target_link_libraries(${lua_interpreter} PRIVATE dl)
    endif()

    # Building Lua compiler (luac)

    set(lua_compiler "luac")

    if (WIN32)
        add_executable(${lua_compiler} ${LUA_LIBRARY_SOURCE_FILES} ${LUA_SOURCE_CODE_SRC_DIR}/luac.c)
    elseif (UNIX)
        add_executable(${lua_compiler} ${LUA_SOURCE_CODE_SRC_DIR}/luac.c)
        target_link_libraries(${lua_compiler} PRIVATE ${lua_static_lib})
        target_link_options(${lua_compiler} PRIVATE "LINKER:-E")
    else()
        message(FATAL_ERROR "Unsupported Operating System.")
    endif()

    target_compile_definitions(${lua_compiler} PRIVATE ${LUA_COMPAT})

    target_include_directories(${lua_compiler} PRIVATE ${LUA_SOURCE_CODE_SRC_DIR})

    if (HAVE_LIBM)
        target_link_libraries(${lua_compiler} PRIVATE m)
    endif()

    if (HAVE_LIBREADLINE)
        target_link_libraries(${lua_compiler} PRIVATE ${_READLINE_LIBNAME})
    endif()

    if (HAVE_LIBDL)
        target_link_libraries(${lua_compiler} PRIVATE dl)
    endif()

    # Installation
	
    file(STRINGS "${LUA_SOURCE_CODE_ESCAPED_DIR}/Makefile" lua_makefile_to_inc_content REGEX "TO_INC=[a-zA-Z0-9_\\. ]+")

    foreach (to_inc_content ${lua_makefile_to_inc_content})
        if (${to_inc_content} MATCHES "^TO_INC= *( |(.*\\.h)|(.*\\.hpp))+ *$")
            set(lua_headers "")

            STRING(REGEX REPLACE " +" ";" lua_header_file_names "${CMAKE_MATCH_2} ${CMAKE_MATCH_3}")
            
            foreach(lua_header_file ${lua_header_file_names})
                list(APPEND lua_headers "${LUA_SOURCE_CODE_SRC_DIR}/${lua_header_file}")
            endforeach()

            # Install shared library
            install(TARGETS ${lua_shared_lib}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
            if (UNIX)
                # Install static library on Unix
                install(TARGETS ${lua_static_lib}
                    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
                )
            endif()
            # Install Lua interpreter
            install(TARGETS ${lua_interpreter}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            )
            # Install Lua compiler
            install(TARGETS ${lua_compiler}
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            )
            install(FILES ${lua_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

            set(pkg_config_file ${CMAKE_CURRENT_BINARY_DIR}/lua${LUA_SUFFIX}.pc)
            set(LUA_PKG_CONFIG_PRIVATE_LIBS_LIST "")

            if (HAVE_LIBM)
                list(APPEND LUA_PKG_CONFIG_PRIVATE_LIBS_LIST "-lm")
            endif()

            if (HAVE_LIBREADLINE)
                list(APPEND LUA_PKG_CONFIG_PRIVATE_LIBS_LIST "-l${_READLINE_LIBNAME}")
            endif()

            if (HAVE_LIBDL)
                list(APPEND LUA_PKG_CONFIG_PRIVATE_LIBS_LIST "-ldl")
            endif()

            list(JOIN LUA_PKG_CONFIG_PRIVATE_LIBS_LIST " " LUA_PKG_CONFIG_PRIVATE_LIBS)

            if ("${LUA_COMPAT}" STREQUAL "")
                set(LUA_PKG_CONFG_COMPAT_DEFINITION "")
            else()
                set(LUA_PKG_CONFG_COMPAT_DEFINITION "-D${LUA_COMPAT}")
            endif()

            if (_BSD_LIKE)
                set(LUA_EXTRA_INC_DIR "-I${READLINE_H_INCLUDE_DIR}")
            else()
                set(LUA_EXTRA_INC_DIR "")
            endif()

            configure_file(${PROJECT_SOURCE_DIR}/cmake/lua.pc.in ${pkg_config_file} @ONLY)

            # Install luaXY.pc
            install(FILES ${pkg_config_file} DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

            break()
        endif()
    endforeach()
endfunction()

##
## Build Lua from the compressed .tar.gz
##

function(process_lua_from_archive archive_file)
	if (NOT EXISTS ${archive_file})
        message(FATAL_ERROR "The archive file ${archive_file} does not exist")
    endif()

    if (${archive_file} MATCHES "lua-([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.tar\\.gz$")
        set(LUA_MAJOR_VERSION ${CMAKE_MATCH_1})
        set(LUA_MINOR_VERSION ${CMAKE_MATCH_2})
        set(LUA_RELEASE_VERSION ${CMAKE_MATCH_3})

        set(LUA_VERSION "${LUA_MAJOR_VERSION}.${LUA_MINOR_VERSION}.${LUA_RELEASE_VERSION}")
        set(LUA_SOURCE_CODE_DIR "${CMAKE_BINARY_DIR}/lua-${LUA_VERSION}")

        message(STATUS "Extracting Lua sources from ${archive_file}")

        file(ARCHIVE_EXTRACT INPUT ${archive_file}
            DESTINATION ${CMAKE_BINARY_DIR} VERBOSE
        )

        if (NOT EXISTS ${LUA_SOURCE_CODE_DIR})
            message(FATAL_ERROR "Failed to extract ${archive_file}")
        endif()
        
        process_lua_from_source_code_dir(${LUA_SOURCE_CODE_DIR} ${LUA_MAJOR_VERSION} ${LUA_MINOR_VERSION} ${LUA_RELEASE_VERSION})
    else()
        message(FATAL_ERROR "The archive name was modified")
    endif()
endfunction()
