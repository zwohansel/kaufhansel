cmake_minimum_required(VERSION 3.17)
project(status-display VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

find_package(Qt5 COMPONENTS Core Widgets)

add_executable(status-display
    hello
    raspberrypi-gcc.cmake
    raspberrypi-clang.cmake
    QtCreatorDeployment.txt)

set_target_properties(status-display PROPERTIES
    CXX_STANDARD 17)

target_link_libraries(status-display
    Qt5::Core
    Threads::Threads
)

install(TARGETS status-display
    RUNTIME DESTINATION bin)


