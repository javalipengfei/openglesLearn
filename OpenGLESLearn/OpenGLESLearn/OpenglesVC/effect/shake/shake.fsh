#version 300 es
precision mediump float;
uniform sampler2D Texture;
uniform float time;
in vec2 oTextcoords;
out vec4 fragColor;

void main() {
    
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;
    
    float progress = mod(time, duration) / 0.7;
    vec2 offsetCoords = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    vec2 scaleTextCoord = vec2(0.5, 0.5) + (oTextcoords - vec2(0.5, 0.5)) / scale;
    vec4 maskR = texture(Texture, scaleTextCoord - offsetCoords);
    vec4 maskB = texture(Texture, scaleTextCoord + offsetCoords);
    vec4 mask = texture(Texture, scaleTextCoord);
    fragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}

