#include <iostream>
#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <QCoreApplication>

#include <memory>

int main(int argc, char** args) {
    QCoreApplication app(argc, args);

    std::cout << "Hello, Pi!" << std::endl;

    int fbfd = open("/dev/fb1", O_RDWR);
    if (fbfd < 0) {
        std::cerr << "Error: cannot open frambuffer device /dev/fb1" << std::endl;
        return 1;
    }

    std::cout << "framebuffer device /dev/fb1 opened successfully" << std::endl;

    struct fb_fix_screeninfo finfo;
    if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo) < 0) {
        std::cerr << "Error reading fixed information of /dev/fb1" << std::endl;
        return 2;
    }

    std::cout << "id: " << finfo.id << std::endl;
    std::cout << "smem_start: " << finfo.smem_start << std::endl;
    std::cout << "line_length: " << finfo.line_length << std::endl;

    struct fb_var_screeninfo vinfo;
    if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo) < 0) {
        std::cerr << "Error reading variable information of /dev/fb1" << std::endl;
        return 3;
    }

    std::cout << "xres: " << vinfo.xres << std::endl;
    std::cout << "yres: " << vinfo.yres << std::endl;
    std::cout << "bits per pixel: " << vinfo.bits_per_pixel << std::endl;
    std::cout << "grayscale: " << vinfo.grayscale << std::endl;

    uint32_t framebufferSize = finfo.line_length * vinfo.yres;

    std::cout << "framebufferSize: " << framebufferSize << std::endl;


    char* fbp = reinterpret_cast<char*>(mmap(0, framebufferSize,
        PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0));

    if (fbp == MAP_FAILED) {
        std::cerr << "Error mapping dev/fb1 into memory" << std::endl;
        return 4;
    }

    std::cout << "Successfully mapped /dev/fb1 into memory" << std::endl;

    uint32_t bytePerPixel = vinfo.bits_per_pixel/8;

    for (uint32_t y = 0; y < vinfo.yres; y++) {
        for (uint32_t x = 0; x < vinfo.xres; x++) {

            uint32_t location = (x+vinfo.xoffset) * bytePerPixel +
                (y+vinfo.yoffset) * finfo.line_length;

            char* memAddress = fbp + location;
            //*(reinterpret_cast<uint16_t*>(memAddress)) = x * 65000 / vinfo.xres;
            *(reinterpret_cast<uint16_t*>(memAddress)) = 13;
        }
    }

    munmap(fbp, framebufferSize);
    close(fbfd);
    return 0;

}
