#define APP_NAME "lak-example"

#include <iostream>
using std::cout;
#include <atomic>
using std::atomic_bool;
#include <memory>
using std::shared_ptr;
#include <thread>
using std::thread;

#include <lak/runtime/mainloop.h>
#include <lak/runtime/window.h>
#include <lak/types/shader.h>
#include <lak/types/mesh.h>

struct userData_t
{
    float clearColor[4] = {0.0f, 0.3125f, 0.3125f, 1.0f};
    lak::window_t window;
};