#version 300 es
precision mediump float;
in vec2 oTexcoord;
uniform sampler2D outTexture;
out vec4 fragColor;

void main()
{
    fragColor = texture(outTexture, oTexcoord);
}
