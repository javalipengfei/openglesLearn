#version 300 es
precision mediump float;
uniform sampler2D Texture;
in vec2 oTextcoord;
uniform float time;
out vec4 fragColor;

void main() {
    float duration = 1.0;
    float maxAlpha = 0.4;
    float maxScale = 1.6;
    
    float progress = mod(time, duration) / duration;
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    float x = 0.5 + (oTextcoord.x - 0.5) / scale;
    float y = 0.5 + (oTextcoord.y - 0.5) / scale;
    vec2 scaleTexcureCoords = vec2(x, y);
    vec4 scaleTexture = texture(Texture, scaleTexcureCoords);
    
    vec4 normalTexture = texture(Texture, oTextcoord);
    fragColor = normalTexture * (1.0 - alpha) + scaleTexture * alpha;
}
