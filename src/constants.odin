package geenie

// Materials

Gold :: Material{
  ambient   = Vec4{ 0.2473, 0.1995, 0.0745, 1.0 },
  diffuse   = Vec4{ 0.7516, 0.6065, 0.2265, 1.0 },
  specular  = Vec4{ 0.6283, 0.5558, 0.3661, 1.0 },
  shininess = 51.200
}

Silver :: Material{
  ambient   = Vec4{ 0.1923, 0.1923, 0.1923, 1.0 },
  diffuse   = Vec4{ 0.5075, 0.5075, 0.5075, 1.0 },
  specular  = Vec4{ 0.5083, 0.5083, 0.5083, 1.0 },
  shininess = 51.200
}

Jade :: Material{
  ambient   = Vec4{ 0.1350, 0.2225, 0.1575, 0.95 },
  diffuse   = Vec4{ 0.5400, 0.8900, 0.6300, 0.95 },
  specular  = Vec4{ 0.3162, 0.3162, 0.3162, 0.95 },
  shininess = 12.800
}

Pearl :: Material{
  ambient   = Vec4{ 0.2500, 0.2073, 0.2073, 0.922 },
  diffuse   = Vec4{ 1.0000, 0.8290, 0.8290, 0.922 },
  specular  = Vec4{ 0.2966, 0.2966, 0.2966, 0.922 },
  shininess = 11.264
}
