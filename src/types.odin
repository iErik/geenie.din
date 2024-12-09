package geenie

import      "base:runtime"
import math "core:math/linalg/glsl"
import   gl "vendor:OpenGL"
import glfw "vendor:glfw"


/*--------------------------------------------------------/
/ -> Type Aliases                                         /
/--------------------------------------------------------*/

AllocatorErr :: runtime.Allocator_Error

BVec2 :: math.bvec2
BVec3 :: math.bvec3
BVec4 :: math.bvec4

UVec2 :: math.uvec2
UVec3 :: math.uvec3
UVec4 :: math.uvec4

IVec2 :: math.ivec2
IVec3 :: math.ivec3
IVec4 :: math.ivec4

DVec2 :: math.dvec2
DVec3 :: math.dvec3
DVec4 :: math.dvec4

Vec2 :: math.vec2
Vec3 :: math.vec3
Vec4 :: math.vec4

Mat2 :: math.mat2
Mat3 :: math.mat3
Mat4 :: math.mat4

Mat2x3 :: math.mat2x3
Mat2x4 :: math.mat2x4
Mat3x2 :: math.mat3x2
Mat3x4 :: math.mat3x4
Mat4x2 :: math.mat4x2
Mat4x3 :: math.mat4x3

Window   :: glfw.WindowHandle
Texture  :: u32
ShaderID :: u32
VAO      :: u32
VBO      :: u32
EBO      :: u32

FramebufferSizeProc :: glfw.FramebufferSizeProc
CursorEnterProc     :: glfw.CursorEnterProc
MouseButtonProc     :: glfw.MouseButtonProc
CursorPosProc       :: glfw.CursorPosProc
ScrollProc          :: glfw.ScrollProc
CharProc            :: glfw.CharProc
KeyProc             :: glfw.KeyProc

/*--------------------------------------------------------/
/ -> Common                                               /
/--------------------------------------------------------*/

AppErr :: enum {
  NONE,
  EGLINI,
  EWININI,
  ENOASS
}

Err :: enum {
  NONE,
  EGLINI,
  EWININI,
  ENOASS
}

PrimitiveType :: enum u32 {
  Points           = gl.POINTS,
  Patches          = gl.PATCHES,
  Lines            = gl.LINES,
  LineLoop         = gl.LINE_LOOP,

  Triangles        = gl.TRIANGLES,
  TriangleFan      = gl.TRIANGLE_FAN,
  TriangleStrip    = gl.TRIANGLE_STRIP,
  TriangleStripAdj = gl.TRIANGLE_STRIP_ADJACENCY,
  TrianglesAdj     = gl.TRIANGLES_ADJACENCY,

  Quads            = gl.QUADS,
  QuadStrip        = gl.QUAD_STRIP,
}

AttributeType :: enum u32 {
  Byte      = gl.BYTE,
  UByte     = gl.UNSIGNED_BYTE,
  Short     = gl.SHORT,
  UShort    = gl.UNSIGNED_SHORT,
  Int       = gl.INT,
  UInt      = gl.UNSIGNED_INT,

  HalfFloat = gl.HALF_FLOAT,
  Float     = gl.FLOAT,
  Double    = gl.DOUBLE,
  Fixed     = gl.FIXED,
}

ObjectAttribute :: struct {
  type       :AttributeType,
  index      :u32,
  size       :i32,
  stride     :i32,
  offset     :uintptr,
  normalized :bool
}

Mesh :: struct {
  primitive  :PrimitiveType,
  instances  :u32,
  buffer     :VBO,
  indices    :EBO,
  elements   :i32,
  attributes :[]ObjectAttribute,
}

/*--------------------------------------------------------/
/ -> Input Handling                                       /
/--------------------------------------------------------*/

EventType :: enum {
  MouseMove,
  MouseButton,
  MouseEnter,
  KeyEvent,
  CharEvent,
  ScrollEvent,
  FramebufferSize,
}

EventListenerProc :: union {
  XYEventHandler,
  MouseButtonHandler,
  MouseEnterHandler,
  KeyEventHandler,
  CharEventHandler,
  FramebufferSizeHandler
}

EventListener :: struct {
  dataPtr :rawptr,
  event   :EventType,
  handler :EventListenerProc
}

EventListeners :: [dynamic]EventListener

MouseButton :: enum i32 {
  Button1 = glfw.MOUSE_BUTTON_1,
  Button2 = glfw.MOUSE_BUTTON_2,
  Button3 = glfw.MOUSE_BUTTON_3,
  Button4 = glfw.MOUSE_BUTTON_4,
  Button5 = glfw.MOUSE_BUTTON_5,
  Button6 = glfw.MOUSE_BUTTON_6,
  Button7 = glfw.MOUSE_BUTTON_7,
  Button8 = glfw.MOUSE_BUTTON_8,

  Last    = glfw.MOUSE_BUTTON_LAST,
  Left    = glfw.MOUSE_BUTTON_LEFT,
  Right   = glfw.MOUSE_BUTTON_RIGHT,
  Middle  = glfw.MOUSE_BUTTON_MIDDLE,
}

ButtonAction :: enum i32 {
  Release    = glfw.RELEASE,
  Press      = glfw.PRESS,
  Repeat     = glfw.REPEAT,
  KeyUnknown = glfw.KEY_UNKNOWN
}

KeyMod :: enum i32 {
  Shift    = glfw.MOD_SHIFT,
  Control  = glfw.MOD_CONTROL,
  Alt      = glfw.MOD_ALT,
  Super    = glfw.MOD_SUPER,
  CapsLock = glfw.MOD_CAPS_LOCK,
  NumLock  = glfw.MOD_NUM_LOCK,
}

KeyModSet :: bit_set[KeyMod]


MouseMoveHandler :: #type proc (
  dataPtr    :rawptr,
  win        :Window,
  xPos, yPos :f64)

MouseButtonHandler :: #type proc (
  dataPtr :rawptr,
  win     :Window,
  button  :MouseButton,
  action  :ButtonAction,
  mods    :i32)

MouseEnterHandler :: #type proc (
  dataPtr :rawptr,
  win     :Window,
  entered :bool)

KeyEventHandler :: #type proc (
  dataPtr :rawptr,
  win     :Window,
  key, scancode, action, mods: i32)

CharEventHandler :: #type proc (
  dataPtr   :rawptr,
  win       :Window,
  codepoint :rune)

ScrollHandler :: #type proc (
  dataPtr :rawptr,
  win     :Window,
  xOffset, yOffset: f64)

FramebufferSizeHandler :: #type proc (
  dataPtr       :rawptr,
  win           :Window,
  width, height :i32)

// Odin's compiler thinks that ScrollHandler and
// MouseMoveHandler are the same thing thanks to the
// function signature of both types... So that's the only
// way I can think of solving this, having a single type for
// both.
XYEventHandler :: #type proc(
  dataPtr :rawptr,
  win     :Window,
  x, y    :f64)

/*--------------------------------------------------------/
/ -> Shader                                               /
/--------------------------------------------------------*/

ShaderType :: enum u32 {
  Vertex   = gl.VERTEX_SHADER,
  TessCtrl = gl.TESS_CONTROL_SHADER,
  TessEval = gl.TESS_EVALUATION_SHADER,
  Geometry = gl.GEOMETRY_SHADER,
  Fragment = gl.FRAGMENT_SHADER,
}

ShaderDef :: struct {
  src  :string,
  type :ShaderType
}

UniformValue :: union {
  f32,
  u32,
  i32,

  UVec2,
  UVec3,
  UVec4,

  IVec2,
  IVec3,
  IVec4,

  Vec2,
  Vec3,
  Vec4,

  Mat2,
  Mat3,
  Mat4,

  Mat2x3,
  Mat2x4,
  Mat3x2,
  Mat3x4,
  Mat4x2,
  Mat4x3,

  PositionalLight,
  Material,
}

BaseUniform :: struct ($T: typeid) {
  name  :cstring,
  value :T
}

ShaderProgram :: struct ($T: typeid) {
  id       :ShaderID,
  uniforms :[dynamic](T)
}

