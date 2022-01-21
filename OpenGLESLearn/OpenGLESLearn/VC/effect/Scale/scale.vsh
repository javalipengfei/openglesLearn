#version 300 es
precision mediump float;

layout(location = 0) in vec4 vPosition;
layout(location = 1) in vec2 vTexcoord;
out vec2 oTexcoord;
uniform float time;
const float PI = 3.141592654;

void main() {
    float duration = 0.8;
    float maxScale = 0.5;
    float timeZone = mod(time , duration);
    float scale = 1.0 + maxScale * abs(sin(timeZone * (PI / duration)));
    gl_Position = vec4(vPosition.x * scale, vPosition.y * scale, vPosition.zw);
    oTexcoord = vTexcoord;
    
}


