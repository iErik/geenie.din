package ui

import "geenie"

DVec2 :: geenie.DVec2
Mesh  :: geenie.Mesh
Vec3  :: geenie.Vec3
Mat4  :: geenie.Mat4
UniformValue :: geenie.UniformValue

/*--------------------------------------------------------/
/ -> Types                                                /
/--------------------------------------------------------*/

UISize :: struct { width  :i32, height :i32, }

// 320-bits / 40-bytes
MousePosition :: struct {
  xPos, yPos   :f64,
  xPrev, yPrev :f64,
  delta        :DVec2
}

ElementId :: distinct u32

// 160-bits
UIElement :: struct {
  using mesh :Mesh,
  id         :ElementId,
  parentId   :ElementId,
  position   :Vec3,
  mvMatrix   :Mat4,
}

ElementStyles :: struct {
  backgroundColor :Vec3,
  width  :u32,
  height :u32,

  x :i32,
  y :i32,
  z :i32,

  borderRadius :u32,
}

// 128-bits
WindowProperties :: struct {
  width    :i32,
  height   :i32,
}

OrthoCam :: struct {
  near: f32,
  far:  f32,
}

UIContext :: struct {
  elements    :[dynamic]^UIElement,
  mousePos    :MousePosition,
  size        :UISize,
  windowProps :WindowProperties,
  projection  :Mat4,
  hover       :ElementId,
  shader      :UIShader,
  scale       :f32,
  lastId      :ElementId,
  elementMap  :map[ElementId]^UIElement,
  cam         :OrthoCam
}

UIUniformValProc :: #type proc (
  ctx :^UIContext,
  el  :^UIElement) -> UniformValue
UIUniform :: BaseUniform(UIUniformValProc)
UIShader  :: ShaderProgram(UIUniform)

