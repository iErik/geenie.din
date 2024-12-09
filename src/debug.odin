package geenie

import    "core:fmt"
import gl "vendor:OpenGL"

printShaderLog :: proc (shader: ShaderID) {
  len, chWrittn: i32
  log: [^]u8

  gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &len)

  if len > 0 {
    log = new(u8)
    gl.GetShaderInfoLog(shader, len, &chWrittn, log)
    fmt.println("Shader Info Log: ", log)
    free(log)
  }
}

printProgramLog :: proc (prog: ShaderID) {
  len, chWrittn: i32
  log: [^]u8

  if len > 0 {
    log = new(u8)
    gl.GetShaderInfoLog(prog, len, &chWrittn, log)
    fmt.println("Program info log: {}", log)
    free(log)
  }
}

checkOpenGLError :: proc () -> bool {
  foundError: bool
  glError: u32 = gl.GetError()

  for glError != gl.NO_ERROR {
    fmt.println("GL_ERROR: {}", glError)
    foundError = true
    glError = gl.GetError()
  }

  return foundError
}

checkShaderError :: proc (shader: ShaderID) -> bool {
  shaderCompiled: i32

  gl.GetShaderiv(shader, gl.COMPILE_STATUS, &shaderCompiled)

  if shaderCompiled != 1 {
    fmt.eprintln("Shader compilation failed")
    printShaderLog(shader)

    return true
  }

  return false
}

checkLinkageError :: proc (program: ShaderID) -> bool {
  linkedProg: i32

  gl.GetProgramiv(program, gl.LINK_STATUS, &linkedProg)

  if linkedProg != 1 {
    fmt.eprintln("Shader linkage failed")
    printProgramLog(program)

    return true
  }

  return false
}
