#version 300 es
precision mediump float;
in vec2 textCoord;
out vec4 fragColor;
uniform sampler2D outTexture;
void main()
{
    fragColor = texture(outTexture, textCoord);
}
