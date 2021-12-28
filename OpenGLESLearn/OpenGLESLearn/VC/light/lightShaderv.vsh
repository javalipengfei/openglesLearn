#version 300 es
uniform mat4 modelViewMatrix;
uniform mat4 vprojection;

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexcoord;
layout (location = 2) in vec3 aNormal;

out vec3 Normal;
out vec3 FragPos;
out vec2 oTexcoord;

void main()
{
    FragPos = vec3(modelViewMatrix * vec4(aPos, 1.0));
    Normal = mat3(modelViewMatrix) * aNormal;
    oTexcoord = aTexcoord;
    gl_Position =  vec4(aPos, 1.0) * modelViewMatrix * vprojection;
}
