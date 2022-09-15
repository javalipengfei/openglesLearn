#version 300 es
precision mediump float;
in vec4 oPositionColor;
out vec4 fragColor;
void main()
{
    fragColor = oPositionColor;
}
