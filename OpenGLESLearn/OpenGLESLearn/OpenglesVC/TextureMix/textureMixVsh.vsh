#version 300 es
layout (location = 0) in vec4 vPosition;
layout (location = 1) in vec2 aTexcoord;

out vec2 textCoord;
out vec2 mixTexCoord;
void main()
{
    gl_Position = vPosition;
    textCoord = aTexcoord;
}
