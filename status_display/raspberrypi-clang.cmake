set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

#set(CMAKE_SYSROOT /usr/arm-linux-gnueabihf)

set(triple arm-linux-gnueabihf)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER_TARGET ${triple})

set(CMAKE_CXX_FLAGS_INIT "-I/usr/arm-linux-gnueabihf/include/c++/7/arm-linux-gnueabihf -I/usr/arm-linux-gnueabihf/include")
set(CMAKE_C_FLAGS_INIT "-I/usr/arm-linux-gnueabihf/include/c++/7/arm-linux-gnueabihf -I/usr/arm-linux-gnueabihf/include")
