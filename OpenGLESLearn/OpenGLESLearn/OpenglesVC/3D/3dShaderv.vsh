#version 300 es
uniform mat4 vmatrix;
uniform mat4 vprojection;
layout (location = 0) in vec4 vPosition;
layout (location = 1) in vec4 vPositionColor;
out vec4 oPositionColor;

void main()
{
    oPositionColor = vPositionColor;
    gl_Position = vPosition * vmatrix * vprojection;
}
