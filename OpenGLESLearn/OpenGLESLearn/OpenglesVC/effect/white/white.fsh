#version 300 es
precision mediump float;
in vec2 oTextcoords;
uniform sampler2D Texture;
uniform float time;
out vec4 fragColor;
const float PI = 3.1415926;
void main() {
    float duration = 1.6;
    float rTime = mod(time, duration);
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(sin(rTime * (PI / duration)));
    
    vec4 mask = texture(Texture, oTextcoords);
    fragColor = mask * (1.0 - amplitude) + whiteMask * amplitude;
}

