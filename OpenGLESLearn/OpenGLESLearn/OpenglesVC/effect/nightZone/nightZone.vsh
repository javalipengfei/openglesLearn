#version 300 es
precision mediump float;
layout(location = 0 ) in vec4 vPosition;
layout(location = 1) in vec2 textcoords;
out vec2 oTextcoords;

void main() {
    gl_Position = vPosition;
    oTextcoords = textcoords;
}

