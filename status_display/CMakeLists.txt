cmake_minimum_required(VERSION 3.17)
project(status-display VERSION 0.0.1 LANGUAGES CXX)

#set(CMAKE_AUTOMOC ON)
#find_package(Qt5 COMPONENTS Widgets REQURIED)

add_executable(status-display
    hello
    raspberrypi-gcc.cmake
    raspberrypi-clang.cmake
    QtCreatorDeployment.txt)

set_target_properties(status-display PROPERTIES
    CXX_STANDARD 17)

install(TARGETS status-display
    RUNTIME DESTINATION bin)


