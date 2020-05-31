var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera(
  75, //FOV
  window.innerWidth / window.innerHeight, // aspect ratio
  0.1, // near clipping view
  1000 // far  clipping view
);

function animate() {
  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
