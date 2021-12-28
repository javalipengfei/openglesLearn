#version 300 es
uniform mat4 vmatrix;
uniform mat4 vprojection;
layout (location = 0) in vec4 vPosition;
layout (location = 1) in vec2 vTexcoord;
out vec2 oTexcoord;

void main()
{
    oTexcoord = vTexcoord;
    gl_Position = vPosition * vmatrix * vprojection;
}
