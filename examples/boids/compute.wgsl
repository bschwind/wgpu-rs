// This should match `NUM_PARTICLES` on the Rust side.
const NUM_PARTICLES: u32 = 100000;

const A: f32 = 0.95;
const B: f32 = 0.7;
const C: f32 = 0.6;
const D: f32 = 3.5;
const E: f32 = 0.25;
const F: f32 = 0.1;

const DT: f32 = 0.008;

[[block]]
struct Particle {
  pos : vec4<f32>;
};

[[block]]
struct SimParams {
  deltaT : f32;
};

[[block]]
struct Particles {
  particles: [[stride(16)]] array<Particle>;
};

[[group(0), binding(0)]] var<uniform> params : SimParams;
[[group(0), binding(1)]] var<storage> particlesSrc : [[access(read)]] Particles;
[[group(0), binding(2)]] var<storage> particlesDst : [[access(read_write)]] Particles;

[[builtin(global_invocation_id)]] var gl_GlobalInvocationID : vec3<u32>;

// https://github.com/austinEng/Project6-Vulkan-Flocking/blob/master/data/shaders/computeparticles/particle.comp
[[stage(compute), workgroup_size(64)]]
fn main() {
  const index : u32 = gl_GlobalInvocationID.x;
  if (index >= NUM_PARTICLES) {
    return;
  }

  // Increments calculation
  // float dx = (a * (y - x))   * timestep;
  // float dy = (x * (b-z) - y) * timestep;
  // float dz = (x*y - c*z)     * timestep;


  var vPos : vec4<f32> = particlesSrc.particles[index].pos;
  var x0: f32 = vPos.x;
  var y0: f32 = vPos.y;
  var z0: f32 = vPos.z;
  
  // // Jake's
  // vPos.x = sin(A * y0) + C * cos(A * x0);
  // vPos.y = sin(B * x0) + D * cos(B * y0);
  // vPos.z = sin(C * z0) + E * cos(C * z0);

  // dx = ((z-b) * x - d*y) * timestep;
  // dy = (d * x + (z-b) * y) *timestep;
  // dz = (c + a*z - ((z*z*z) /3) - (x*x) + f * z * (x*x*x)) * timestep;

  var dx: f32 = ((z0 - B) * x0 - D*y0) * DT;
  var dy: f32 = (D * x0 + (z0-B) * y0) * DT;
  var dz: f32 = (C + A*z0 - ((z0*z0*z0) / 3.0) - (x0*x0) + F * z0 * (x0*x0*x0)) * DT;

  // var dx: f32 = 0.01;
  // var dy: f32 = 0.0;
  // var dz: f32 = 0.0;

  // Aizawa
  var new_x: f32 = vPos.x + dx;
  var new_y: f32 = vPos.y + dy;
  var new_z: f32 = vPos.z + dz;

  // Write back
  particlesDst.particles[index].pos = vec4<f32>(new_x, new_y, new_z, 1.0);
}
