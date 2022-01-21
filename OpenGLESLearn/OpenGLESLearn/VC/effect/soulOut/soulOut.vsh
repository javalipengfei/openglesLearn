#version 300 es
precision mediump float;
layout(location = 0) in vec4 vposition;
layout(location = 1) in vec2 vTextcoord;
out vec2 oTextcoord;

void main() {
    gl_Position = vposition;
    oTextcoord = vTextcoord;
}
