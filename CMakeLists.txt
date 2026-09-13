cmake_minimum_required(VERSION 3.29)

project(Tsubame LANGUAGES CXX Swift)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_Swift_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/swift-modules")

add_executable(Tsubame
    Sources/MyApp.swift
    Sources/MyModel.swift
)

include(FetchContent)

FetchContent_Declare(
    QtBridge
    GIT_REPOSITORY https://github.com/qt/qtbridge-swift.git
    GIT_TAG 0.2.0-beta
)

FetchContent_MakeAvailable(QtBridge)


target_link_libraries(Tsubame
    PRIVATE
        QtBridge
)

set(TSUBAME_QML_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Resources/main.qml")

if(APPLE)
    # Create an app bundle
    set_target_properties(Tsubame PROPERTIES
        MACOSX_BUNDLE TRUE
    )
    # Copy QML to Resources
    target_sources(Tsubame PRIVATE "${TSUBAME_QML_FILE}")
    set_source_files_properties("${TSUBAME_QML_FILE}" PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources
    )
else()
    add_custom_command(
        TARGET Tsubame POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            "${TSUBAME_QML_FILE}"
            "$<TARGET_FILE_DIR:Tsubame>/main.qml"
        COMMENT "Copying QML file next to executable"
    )
endif()
