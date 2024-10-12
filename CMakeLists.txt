cmake_minimum_required(VERSION 3.22.1)

project(LuaCMake
    VERSION 1.1.0
    LANGUAGES C
)

option(DOWNLOAD_LUA_SOURCES "Download Lua sources during the installation process." OFF)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "The build type.")

include(${PROJECT_SOURCE_DIR}/cmake/building_lua.cmake)

##
## Main body
##

if (DOWNLOAD_LUA_SOURCES)
    if (NOT DEFINED LUA_VERSION)
        message(FATAL_ERROR "You must define a Lua version to download and build.")
    endif()

    if (DEFINED LUA_SOURCE_CODE_DIR)
        message(FATAL_ERROR "Unexpected LUA_SOURCE_CODE_DIR")
    endif()

    if (DEFINED FROM_ARCHIVE)
        message(FATAL_ERROR "Unexpected FROM_ARCHIVE")
    endif()

    if (${LUA_VERSION} MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")

        set(LUA_MAJOR_VERSION ${CMAKE_MATCH_1})
        set(LUA_MINOR_VERSION ${CMAKE_MATCH_2})
        set(LUA_RELEASE_VERSION ${CMAKE_MATCH_3})
        
        set(LUA_SOURCE_CODE_DIR "${CMAKE_BINARY_DIR}/lua-${LUA_VERSION}")
        
        if (NOT EXISTS ${LUA_SOURCE_CODE_DIR})
            set(lua_archive_dest "${CMAKE_BINARY_DIR}/lua-${LUA_VERSION}.tar.gz")
            
            if (NOT EXISTS ${lua_archive_dest})
                set(LUA_DOWNLOAD_URL "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz")

                message(STATUS "Downloading Lua sources from ${LUA_DOWNLOAD_URL}")

                file(DOWNLOAD ${LUA_DOWNLOAD_URL} ${lua_archive_dest}
                    SHOW_PROGRESS
                )

                if (NOT EXISTS ${lua_archive_dest})
                    message(FATAL_ERROR "Failed to download Lua sources from ${LUA_DOWNLOAD_URL}")
                endif()
            endif()

            message(STATUS "Extracting Lua sources from ${lua_archive_dest}")

            file(ARCHIVE_EXTRACT INPUT ${lua_archive_dest}
                DESTINATION ${CMAKE_BINARY_DIR} VERBOSE
            )

            if (NOT EXISTS ${LUA_SOURCE_CODE_DIR})
                message(FATAL_ERROR "Failed to extract ${lua_archive_dest}")
            endif()
        endif()
        
        process_lua_from_source_code_dir(${LUA_SOURCE_CODE_DIR} ${LUA_MAJOR_VERSION} ${LUA_MINOR_VERSION} ${LUA_RELEASE_VERSION})

    else()
        message(FATAL_ERROR "Invalid Lua version")
    endif()
elseif (DEFINED FROM_ARCHIVE)

    if (DEFINED LUA_VERSION)
        message(FATAL_ERROR "Unexpected LUA_VERSION")
    endif()

    if (DEFINED LUA_SOURCE_CODE_DIR)
        message(FATAL_ERROR "Unexpected LUA_SOURCE_CODE_DIR")
    endif()

    process_lua_from_archive(${FROM_ARCHIVE})
else()
    if (DEFINED LUA_VERSION)
        message(FATAL_ERROR "Unexpected LUA_VERSION")
    endif()

    if (NOT DEFINED LUA_SOURCE_CODE_DIR)
        message(FATAL_ERROR "You must define a path to the Lua sources for the building process")
    endif()

    if (NOT EXISTS ${LUA_SOURCE_CODE_DIR})
        message(FATAL_ERROR "Directory does not exist")
    endif()

    if (${LUA_SOURCE_CODE_DIR} MATCHES "lua-([0-9]+)\\.([0-9]+)\\.([0-9]+)$")

        set(LUA_MAJOR_VERSION ${CMAKE_MATCH_1})
        set(LUA_MINOR_VERSION ${CMAKE_MATCH_2})
        set(LUA_RELEASE_VERSION ${CMAKE_MATCH_3})

        process_lua_from_source_code_dir(${LUA_SOURCE_CODE_DIR} ${LUA_MAJOR_VERSION} ${LUA_MINOR_VERSION} ${LUA_RELEASE_VERSION})
    else()
        message(FATAL_ERROR "Invalid Lua version")
    endif()
endif()
