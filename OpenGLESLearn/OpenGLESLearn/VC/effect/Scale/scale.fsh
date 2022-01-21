#version 300 es
precision mediump float;
uniform sampler2D outTexture;
in vec2 oTexcoord;
out vec4 fragColor;

void main() {
    
    fragColor = texture(outTexture, oTexcoord);
}

