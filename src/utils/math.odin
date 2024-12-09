package utils

import math "core:math/linalg/glsl"

// -> Math Helpers
// ---------------

asRad :: proc (angle: f32) -> f32 {
  return angle * (math.PI / 180)
}

phi :: proc (ring: int, rings: int) -> f32 {
  return math.PI * f32(ring) / f32(rings)
}

theta :: proc (slice: int, slices: int) -> f32 {
  return 2.0 * math.PI * f32(slice) / f32(slices)
}

cosT :: proc (section: int, sections: int) -> f32 {
  return cos(theta(section, sections))
}

sinT :: proc (section: int, sections: int) -> f32 {
  return sin(theta(section, sections))
}

cosP :: proc (section: int, sections: int) -> f32 {
  return cos(phi(section, sections))
}

sinP :: proc (section: int, sections: int) -> f32 {
  return sin(phi(section, sections))
}
