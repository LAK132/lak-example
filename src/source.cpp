#include "source.h"

void update(std::atomic_bool *const running, userData_t *const data)
{
    for (SDL_Event event; SDL_PollEvent(&event);)
    {
        switch (event.type)
        {
            case SDL_QUIT: {
                *running = false;
            } break;
        }
    }
}

void draw(std::atomic_bool *const running, userData_t *const data)
{
    withWindowContext(data->window, context)
    {
        glViewport(0, 0, data->window.view.w, data->window.view.h);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // BEGIN RENDER CODE

        // END RENDER CODE

        SDL_GL_SwapWindow(data->window.window);
    }
}

int main()
{
    userData_t data;
    atomic_bool running = true;

    data.window.view.w = 1280;
    data.window.view.h = 720;

    data.window.open(0);
    withWindowContext(data.window, context)
    {
        if (gl3wInit()) { assert(false); throw; };
        glViewport(0, 0, data.window.view.w, data.window.view.h);
        glClearColor(0.0f, 0.3125f, 0.3125f, 1.0f);
        glEnable(GL_DEPTH_TEST);
    }

    update(&running, &data);
    draw(&running, &data);

    shared_ptr<thread> drawt = lak::draw_thread(&running, &data);
    lak::update_loop(&running, &data);
    drawt->join();

    data.window.close();

    SDL_Quit();
}
