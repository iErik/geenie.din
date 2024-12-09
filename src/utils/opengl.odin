package utils

import      "core:os"
import      "core:fmt"
import      "core:reflect"
import      "core:strings"

import stb  "vendor:stb/image"
import gl   "vendor:OpenGL"

strjoin   :: strings.join
toCString :: strings.clone_to_cstring

/*--------------------------------------------------------/
// -> Texture utils                                      //
/--------------------------------------------------------*/

loadTexture :: proc (filename: cstring) -> (
  texture: u32,
  err: AppErr = .NONE
) {
  width, height, channels: i32
  anisoSetting: f32

  img := stb.load(filename, &width, &height, &channels, 0)
  defer stb.image_free(img)

  if size_of(img) == 0 {
    err = .ENOASS
    return
  }

  gl.GenTextures(1, &texture)
  gl.BindTexture(gl.TEXTURE_2D, texture)
  gl.TexImage2D(
    gl.TEXTURE_2D,
    0,
    gl.RGB,
    width,
    height,
    0,
    gl.RGB,
    gl.UNSIGNED_BYTE,
    img)

  gl.GenerateMipmap(gl.TEXTURE_2D)

  gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &anisoSetting)
  gl.TexParameterf(
    gl.TEXTURE_2D,
    gl.TEXTURE_MAX_ANISOTROPY,
    anisoSetting)

  gl.TexParameteri(
    gl.TEXTURE_2D,
    gl.TEXTURE_MIN_FILTER,
    gl.LINEAR_MIPMAP_LINEAR)

  gl.TexParameteri(
    gl.TEXTURE_2D,
    gl.TEXTURE_MAG_FILTER,
    gl.LINEAR)

  gl.TexParameteri(
    gl.TEXTURE_2D,
    gl.TEXTURE_WRAP_S,
    gl.REPEAT)

  gl.TexParameteri(
    gl.TEXTURE_2D,
    gl.TEXTURE_WRAP_T,
    gl.REPEAT)

  return
}

/*--------------------------------------------------------/
// -> Shader utils                                       //
/--------------------------------------------------------*/

readShader :: proc (
  shaderSrc: string,
  type: ShaderType
) -> (
  shaderId: ShaderID,
  success: bool
) {
  shader := os.read_entire_file_from_filename(
    shaderSrc) or_return
  shaderId = gl.CreateShader(u32(type))

  csShader := cstring(raw_data(shader))
  shaderLen := i32(len(shader))

  gl.ShaderSource(
    shaderId,       // Shader ID
    1,              // Count
    &csShader,      // Shader data (c-string pointer)
    &shaderLen      // Shader data length
  )
  gl.CompileShader(shaderId)

  checkOpenGLError()
  checkShaderError(shaderId)

  success = true
  return
}

createProgram :: proc (
  shaders: ..ShaderDef
) -> (
  programId: ShaderID,
  err: Err = .NONE
) {
  programId = gl.CreateProgram()

  for shader in shaders {
    shaderId, ok := readShader(shader.src, shader.type)
    checkOpenGLError()

    if !ok {
      fmt.eprintf(
        "Couldn't read shader at: {:v}\n",
        shader.src)
      err = .ENOASS
      return
    }

    gl.AttachShader(programId, shaderId)
  }

  gl.LinkProgram(programId)
  checkOpenGLError()
  checkLinkageError(programId)

  return
}

mkUIShader :: proc (shaders: ..ShaderDef) -> (
  shader: UIShader,
  err: Err
) {
  shader.id = createProgram(..shaders) or_return
  return
}

mkSceneShader :: proc (shaders: ..ShaderDef) -> (
  shader: SceneShader,
  err: Err
) {
  shader.id = createProgram(..shaders) or_return
  return
}


/*--------------------------------------------------------/
// -> Shader uniform utils                               //
/--------------------------------------------------------*/


setUniform1f :: proc (
  program: ShaderID,
  name: cstring,
  value: f32,
) {
  gl.Uniform1f(
    gl.GetUniformLocation(program, name),
    value
  )
}

setUniform2fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Vec2,
  count: i32 = 1
) {
  gl.Uniform2fv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}

setUniform3fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Vec3,
  count: i32 = 1
) {
  gl.Uniform3fv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}

setUniform4fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Vec4,
  count: i32 = 1
) {
  gl.Uniform4fv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}

setUniform1i :: proc (
  program: ShaderID,
  name: cstring,
  value: i32,
) {
  gl.Uniform1i(
    gl.GetUniformLocation(program, name),
    value
  )
}

setUniform2iv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^IVec2,
  count: i32 = 1
) {
  gl.Uniform2iv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value)
  )
}

setUniform3iv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^IVec3,
  count: i32 = 1
) {
  gl.Uniform3iv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value)
  )
}

setUniform4iv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^IVec4,
  count: i32 = 1
) {
  gl.Uniform4iv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}


setUniform1ui :: proc (
  program: ShaderID,
  name: cstring,
  value: u32,
) {
  gl.Uniform1ui(
    gl.GetUniformLocation(program, name),
    value
  )
}

setUniform2uiv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^UVec2,
  count: i32 = 1
) {
  gl.Uniform2uiv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}

setUniform3uiv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^UVec3,
  count: i32 = 1
) -> () {
  gl.Uniform3uiv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}

setUniform4uiv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^UVec4,
  count: i32 = 1
) {
  gl.Uniform4uiv(
    gl.GetUniformLocation(program, name),
    count,
    raw_data(value),
  )
}


setUniformMatrix2fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat2,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix2fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix3fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat3,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix3fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix4fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat4,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix4fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}


setUniformMatrix2x3fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat2x3,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix2x3fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix2x4fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat2x4,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix2x4fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix3x2fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat3x2,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix3x2fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix3x4fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat3x4,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix3x4fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix4x2fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat4x2,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix4x2fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformMatrix4x3fv :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Mat4x3,
  count: i32 = 1,
  transpose: bool = false
) {
  gl.UniformMatrix4x3fv(
    gl.GetUniformLocation(program, name),
    count,
    transpose,
    raw_data(value),
  )
}

setUniformPositionalLight :: proc (
  program: ShaderID,
  name: cstring,
  value: ^PositionalLight,
) {
  merge := proc (base: cstring, field: string) -> cstring {
    fullName := strjoin({string(base), field}, ".")
    return toCString(fullName)
  }

  setUniform(program,
    merge(name, "ambient"), &value.ambient)
  setUniform(program,
    merge(name, "diffuse"), &value.diffuse)
  setUniform(program,
    merge(name, "specular"), &value.specular)
  setUniform(program,
    merge(name, "position"), &value.position)
}

setUniformMaterial :: proc (
  program: ShaderID,
  name: cstring,
  value: ^Material
) {

  merge := proc (base: cstring, field: string) -> cstring {
    fullName := strjoin({string(base), field}, ".")
    return toCString(fullName)
  }

  setUniform(program,
    merge(name, "ambient"), &value.ambient)
  setUniform(program,
    merge(name, "diffuse"), &value.diffuse)
  setUniform(program,
    merge(name, "specular"), &value.specular)
  setUniform(program,
    merge(name, "shininess"), value.shininess)
}


setUniformStruct :: proc (
  program: ShaderID,
  name: cstring,
  value: $T,
) where
  T == ^PositionalLight ||
  T == ^Material
{

  structFields := reflect.struct_field_names(value)

  for field in structFields {
    fullName, _ := strjoin({ name, field }, ".")
    fieldValue := reflect.struct_field_by_name(field)
    setUniform(program, fullName, fieldValue)
  }
}

setUniformGeneric :: proc (
  program: ShaderID,
  name: cstring,
  uniform: UniformValue
) {
  switch type in uniform {
    case f32:
      value := uniform.(f32)
      setUniform1f(program, name, value)
    case u32:
      value := uniform.(u32)
      setUniform1ui(program, name, value)
    case i32:
      value := uniform.(i32)
      setUniform1i(program, name, value)

    case UVec2:
      value := uniform.(UVec2)
      setUniform2uiv(program, name, &value)
    case UVec3:
      value := uniform.(UVec3)
      setUniform3uiv(program, name, &value)
    case UVec4:
      value := uniform.(UVec4)
      setUniform4uiv(program, name, &value)

    case IVec2:
      value := uniform.(IVec2)
      setUniform2iv(program, name, &value)
    case IVec3:
      value := uniform.(IVec3)
      setUniform3iv(program, name, &value)
    case IVec4:
      value := uniform.(IVec4)
      setUniform4iv(program, name, &value)

    case Vec2:
      value := uniform.(Vec2)
      setUniform2fv(program, name, &value)
    case Vec3:
      value := uniform.(Vec3)
      setUniform3fv(program, name, &value)
    case Vec4:
      value := uniform.(Vec4)
      setUniform4fv(program, name, &value)

    case Mat2:
      value := uniform.(Mat2)
      setUniformMatrix2fv(program, name, &value)
    case Mat3:
      value := uniform.(Mat3)
      setUniformMatrix3fv(program, name, &value)
    case Mat4:
      value := uniform.(Mat4)
      setUniformMatrix4fv(program, name, &value)

    case Mat2x3:
      value := uniform.(Mat2x3)
      setUniformMatrix2x3fv(program, name, &value)
    case Mat2x4:
      value := uniform.(Mat2x4)
      setUniformMatrix2x4fv(program, name, &value)
    case Mat3x2:
      value := uniform.(Mat3x2)
      setUniformMatrix3x2fv(program, name, &value)
    case Mat3x4:
      value := uniform.(Mat3x4)
      setUniformMatrix3x4fv(program, name, &value)
    case Mat4x2:
      value := uniform.(Mat4x2)
      setUniformMatrix4x2fv(program, name, &value)
    case Mat4x3:
      value := uniform.(Mat4x3)
      setUniformMatrix4x3fv(program, name, &value)

    case PositionalLight:
      value := uniform.(PositionalLight)
      setUniformPositionalLight(program, name, &value)
    case Material:
      value := uniform.(Material)
      setUniformMaterial(program, name, &value)
  }
}

setUniform :: proc {
  setUniform1f,
  setUniform2fv,
  setUniform3fv,
  setUniform4fv,

  setUniform1i,
  setUniform2iv,
  setUniform3iv,
  setUniform4iv,

  setUniform1ui,
  setUniform2uiv,
  setUniform3uiv,
  setUniform4uiv,

  setUniformMatrix2fv,
  setUniformMatrix3fv,
  setUniformMatrix4fv,

  setUniformMatrix2x3fv,
  setUniformMatrix2x4fv,

  setUniformMatrix3x2fv,
  setUniformMatrix3x4fv,

  setUniformMatrix4x2fv,
  setUniformMatrix4x3fv,

  setUniformGeneric,
}
