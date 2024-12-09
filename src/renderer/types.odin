package renderer

import gl   "vendor:OpenGL"
import glfw "vendor:glfw"

// A Renderer is for rendering graphics (duh) using OpenGL.
// It is the "root" of our little engine

/*--------------------------------------------------------/
/ -> Types                                                /
/--------------------------------------------------------*/

RendererStage :: enum {
  Init,
  Update,
  Render,
  Cleanup
}

/*
 * All of the render hook functions will receive a single
 * argument: the pointer containing a reference to the data
 * registered in the hook object.
 */
RendererHookProc :: #type proc (dataPtr  :rawptr)

/*
 * A render hook is simply a function "scheduled" to run
 * at a particular stage of the Renderer process, be it
 * the initialization process, draw (update/render) process
 * or teardown (cleanup) process.
 *
 * The dataPtr can be used to bind any value or object that
 * the hook will need access to during it's execution, and
 * I hate it.
 */
RendererHook :: struct {
  dataPtr :rawptr,
  stage   :RendererStage,
  handler :RendererHookProc,
}

RendererHooks :: [dynamic]RendererHook

/*
 * The base structure of our game engine, the Vertex Array
 * is used to bind Vertex Buffers and other mesh data so
 * that we can use it to transfer that data to the GPU.
 * Essentially it seems to work like a "pipe" or a channel,
 * for now we have only one for the whole renderer, I'm not
 * sure if we should need more than that.
 *
 * The listeners prop is a list of EventListener objects,
 * which are called whenever a particular event matching
 * the EventListener's trigger is well, triggered.
 */
Renderer :: struct {
  using vtable :RendererVTable,
  window       :Window,
  listeners    :EventListeners,
  hooks        :RendererHooks,
  vertexArray  :VAO,

  width   :i32,
  height  :i32,
}

/*
 * Options to be passed to mkRenderer
 */
RendererOpts :: struct {
  title       :cstring,
  width       :i32,
  height      :i32,

  decorated   :bool,
  transparent :bool,
  resizable   :bool,
}

RendererVTable :: struct {
  init    :proc (ren: ^Renderer),
  run     :proc (ren: ^Renderer),
  destroy :proc (ren: ^Renderer),

  addHook  :proc (ren: ^Renderer, hook: RendererHook),
  runHooks :proc (ren: ^Renderer, stage: RendererStage),

  addListener    :proc (ren: ^Renderer, lis: EventListener),
  removeListener :proc (ren: ^Renderer)
}

RendererVTable_Default :: RendererVTable {
  init           = initRenderer,
  run            = renderLoop,
  destroy        = destroyRenderer,

  addHook        = addHook,
  runHooks       = runHooks,

  addListener    = addListener,
  removeListener = removeListener
}
