package ui

import "geenie"


/*--------------------------------------------------------/
/ -> Methods                                              /
/--------------------------------------------------------*/

attachUI :: proc (ren: ^Renderer) -> (
  ctx: ^UIContext,
  err: Err
) {
  ctx = mkUIContext(ren) or_return

  ren->addHook(RendererHook {
    dataPtr = ctx,
    stage   = .Render,
    handler = cast(RendererHookProc) renderElements
  })

  ren->addListener(EventListener {
    dataPtr = ctx,
    event   = .MouseMove,
    handler = cast(XYEventHandler) updateUIMousePos
  })
  ren->addListener(EventListener {
    dataPtr = ctx,
    event   = .MouseButton,
    handler = cast(MouseButtonHandler) updateUIMouseClick
  })
  ren->addListener(EventListener {
    dataPtr = ctx,
    event   = .FramebufferSize,
    handler = cast(FramebufferSizeHandler) updateScreenSize
  })

  return
}

mkUIContext :: proc (ren: ^Renderer) -> (
  ctx :^UIContext,
  err :Err
) {
  w, h       := glfw.GetFramebufferSize(ren.window)
  xPos, yPos := glfw.GetCursorPos(ren.window)

  ctx            = new(UIContext)
  ctx.scale      = 1.0
  ctx.elementMap = make(map[ElementId]^UIElement)
  ctx.size       = UISize{ width = w, height = h }
  ctx.shader     = uiShader() or_return
  ctx.mousePos   = MousePosition{ xPos = xPos, yPos = yPos }
  ctx.lastId     = 0

  // Notice that this can cause issue with child element's
  // whose parents are close to 999
  ctx.cam = OrthoCam{ near = -999.0, far = 0.0 }

  ctx.projection = math.mat4Ortho3d(
    0.0, f32(w), f32(h), 0.0, ctx.cam.near, ctx.cam.far)

  ctx.windowProps = WindowProperties {
    width     = w,
    height    = h,
  }

  return
}

renderElement :: proc (ctx: ^UIContext, el: ^UIElement) {
  gl.BindBuffer(gl.ARRAY_BUFFER, el.buffer)

  for uniform in ctx.shader.uniforms do setUniform(
    ctx.shader.id,
    uniform.name,
    uniform.value(ctx, el))

  for attr in el.attributes {
    gl.VertexAttribPointer(
      attr.index,
      attr.size,
      u32(attr.type),
      attr.normalized,
      attr.stride,
      attr.offset)

    gl.EnableVertexAttribArray(attr.index)
  }

  if el.indices != 0 {
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, el.indices)

    gl.DrawElements(
      u32(el.primitive),
      el.elements,
      gl.UNSIGNED_SHORT,
      rawptr(uintptr(0)))
  } else {
    gl.DrawArrays(u32(el.primitive), 0, el.elements)
  }
}

renderElements :: proc (ctx: ^UIContext) {
  gl.Disable(gl.DEPTH_TEST)
  gl.Disable(gl.CULL_FACE)
  gl.DepthFunc(gl.NEVER)

  if ctx.shader.id != 0 {
    gl.UseProgram(ctx.shader.id)
  }

  for el in ctx.elements {
    renderElement(ctx, el)
  }
}

addElement :: proc (ctx: ^UIContext, el: ^UIElement) {
  append(&ctx.elements, el)
  ctx.elementMap[el.id] = el
}

/*--------------------------------------------------------/
/ -> Event Callbacks                                      /
/--------------------------------------------------------*/

updateScreenSize :: proc (
  ctx: ^UIContext,
  win: Window,
  w, h: i32
) {
  ctx.windowProps.width  = w
  ctx.windowProps.height = h

  ctx.projection = math.mat4Ortho3d(
    0.0, f32(w), f32(h), 0.0, ctx.cam.near, ctx.cam.far)
}

updateUIMousePos :: proc (
  ctx: ^UIContext,
  win: Window,
  xPos, yPos: f64
) {
  ctx.mousePos.xPrev = ctx.mousePos.xPos
  ctx.mousePos.yPrev = ctx.mousePos.yPos

  ctx.mousePos.xPos = xPos
  ctx.mousePos.yPos = yPos

  ctx.mousePos.delta = DVec2{
    ctx.mousePos.xPos - ctx.mousePos.xPrev,
    ctx.mousePos.yPos - ctx.mousePos.yPrev,
  }
}

updateUIMouseClick :: proc (
  ctx: ^UIContext,
  win: Window,
  button: MouseButton,
  action: ButtonAction,
  mod: c.int
) {
  buttonStr :string
  actionStr :string

  if button == .Left { buttonStr = "Left Button" }
  if button == .Right { buttonStr = "Right Button" }
  if button == .Middle { buttonStr = "Middle Button" }

  if action == .Release { actionStr = "Release" }
  if action == .Press { actionStr = "Press" }

  fmt.printfln(
    "Mouse Button Press:\n" +
    "Button: %v\n" +
    "Action: %v\n" +
    "Mods: %v\n",
    buttonStr, actionStr, mod)

  fmt.printfln(
    "\nBitwise OPs:\n" +
    "mod AND .Shift: %v\n" +
    "mod AND .Control: %v\n" +
    "mod AND .Alt: %v\n" +
    "mod AND .Super: %v\n" +
    "mod AND .CapsLock: %v\n",
    mod & glfw.MOD_SHIFT,
    mod & glfw.MOD_CONTROL,
    mod & glfw.MOD_ALT,
    mod & glfw.MOD_SUPER,
    mod & glfw.MOD_CAPS_LOCK
  )
}

/*--------------------------------------------------------/
/ -> Shader                                               /
/--------------------------------------------------------*/

uiShader :: proc () -> (
  shader: UIShader,
  err: Err
) {
  shader, err = mkUIShader(
    ShaderDef{
      src  = "./shaders/flat/vertex.glsl",
      type = ShaderType.Vertex
    },
    ShaderDef{
      src  = "./shaders/flat/pixel.glsl",
      type = ShaderType.Fragment
    }
  )

  append(&shader.uniforms,
    UIUniform{
      name  = "projMatrix",
      value = proc (
        ctx: ^UIContext,
        el: ^UIElement
      ) -> UniformValue { return ctx.projection }
    },
    UIUniform{
      name  = "mvMatrix",
      value = proc (
        ctx: ^UIContext,
        el: ^UIElement
      ) -> UniformValue { return el.mvMatrix }
    })

  return
}

/*--------------------------------------------------------/
/ -> Guilty Corner                                        /
/--------------------------------------------------------*/

ElementProps :: struct ($T: typeid) {
  using meshProps :T,

  position  :Vec3,
  mvMatrix  :Mat4,
  parentId  :ElementId,
  id        :ElementId,
}

CubeEl      :: ElementProps(CubeProps)
PyramidEl   :: ElementProps(PyramidProps)
SphereEl    :: ElementProps(SphereProps)
TorusEl     :: ElementProps(TorusProps)
SquareEl    :: ElementProps(SquareProps)
TriangleEl  :: ElementProps(TriangleProps)
RectangleEl :: ElementProps(RectangleProps)
CircleEl    :: ElementProps(CircleProps)


mkElement :: proc (
  ctx: ^UIContext,
  props: $T/ElementProps
) -> ^UIElement {
  el := new(UIElement)

  el.position  = props.position
  el.mvMatrix  = props.mvMatrix
  el.parentId  = props.parentId
  el.id        = ctx.lastId + 1
  ctx.lastId   = el.id

  parentEl := ctx.elementMap[el.parentId]
  if parentEl != nil {
    el.mvMatrix = parentEl.mvMatrix
      * math.mat4Translate(el.position)
  } else {
    el.mvMatrix = math.mat4Translate(el.position)
  }

  return el
}

cubeElement :: proc (
  ctx: ^UIContext,
  props: CubeEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genCube(props.meshProps)

  return element
}

pyramidElement :: proc (
  ctx: ^UIContext,
  props: PyramidEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genPyramid(props.meshProps)

  return element
}

sphereElement :: proc (
  ctx: ^UIContext,
  props: SphereEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genSphere(props.meshProps)

  return element
}

torusElement :: proc (
  ctx: ^UIContext,
  props: TorusEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genTorus(props.meshProps)

  return element
}

squareElement :: proc (
  ctx: ^UIContext,
  props: SquareEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genSquare(props.meshProps)

  return element
}

triangleElement :: proc (
  ctx: ^UIContext,
  props: TriangleEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genTriangle(props.meshProps)

  return element
}

rectangleElement :: proc (
  ctx: ^UIContext,
  props: RectangleEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element .mesh = genRectangle(props.meshProps)

  return element
}

circleElement :: proc (
  ctx: ^UIContext,
  props: CircleEl
) -> ^UIElement {
  element := mkElement(ctx, props)
  element.mesh = genCircle(props.meshProps)

  return element
}

element :: proc {
  cubeElement,
  pyramidElement,
  sphereElement,
  torusElement,
  squareElement,
  triangleElement,
  rectangleElement,
  circleElement
}
