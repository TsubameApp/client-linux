cmake_minimum_required(VERSION 3.29)

project(Tsubame LANGUAGES C CXX Swift)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_Swift_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/swift-modules")

include(FetchContent)

# ---------------------------------------------------------------------------
# Qt Bridge
# ---------------------------------------------------------------------------

FetchContent_Declare(
    QtBridge
    GIT_REPOSITORY https://github.com/qt/qtbridge-swift.git
    GIT_TAG 0.2.0-beta
)

FetchContent_MakeAvailable(QtBridge)

# ---------------------------------------------------------------------------
# TsubameCore
#
# Local development:
#
#   cmake ... -DTSUBAME_CORE_SOURCE_DIR=/path/to/Core
#
# CI / standalone checkout:
#   fetch Core from GitHub.
# ---------------------------------------------------------------------------

set(
    TSUBAME_CORE_SOURCE_DIR
    ""
    CACHE PATH
    "Path to a local TsubameCore checkout"
)

if(TSUBAME_CORE_SOURCE_DIR)
    if(NOT EXISTS "${TSUBAME_CORE_SOURCE_DIR}/CMakeLists.txt")
        message(
            FATAL_ERROR
            "TsubameCore CMakeLists.txt not found at "
            "${TSUBAME_CORE_SOURCE_DIR}"
        )
    endif()

    message(
        STATUS
        "Using local TsubameCore: ${TSUBAME_CORE_SOURCE_DIR}"
    )

    add_subdirectory(
        "${TSUBAME_CORE_SOURCE_DIR}"
        "${CMAKE_BINARY_DIR}/_deps/tsubame-core-build"
    )
else()
    message(STATUS "Fetching TsubameCore from GitHub")

    FetchContent_Declare(
        TsubameCoreSource
        GIT_REPOSITORY https://github.com/TsubameApp/Core.git
        GIT_TAG ec979e7cb87daa324fba80598e4540f15bf23754
    )

    FetchContent_MakeAvailable(TsubameCoreSource)
endif()

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------

add_executable(
    Tsubame
    Sources/MyApp.swift
    Sources/MyModel.swift
)

target_link_libraries(
    Tsubame
    PRIVATE
        QtBridge
        Tsubame::Core
)

# ---------------------------------------------------------------------------
# QML
# ---------------------------------------------------------------------------

set(
    TSUBAME_QML_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/Resources/main.qml"
)

if(APPLE)
    set_target_properties(
        Tsubame
        PROPERTIES
            MACOSX_BUNDLE TRUE
    )

    target_sources(
        Tsubame
        PRIVATE
            "${TSUBAME_QML_FILE}"
    )

    set_source_files_properties(
        "${TSUBAME_QML_FILE}"
        PROPERTIES
            MACOSX_PACKAGE_LOCATION Resources
    )
else()
    add_custom_command(
        TARGET Tsubame
        POST_BUILD

        COMMAND
            ${CMAKE_COMMAND} -E copy
            "${TSUBAME_QML_FILE}"
            "$<TARGET_FILE_DIR:Tsubame>/main.qml"

        COMMENT
            "Copying QML file next to executable"
    )
endif()
