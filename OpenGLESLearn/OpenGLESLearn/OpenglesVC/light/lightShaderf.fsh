#version 300 es
precision mediump float;
in vec3 Normal;
in vec3 FragPos;
in vec2 oTexcoord;

out vec4 fragColor;

uniform vec3 lightPos;
uniform vec3 lightColor;
uniform sampler2D outTexture;

void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;
    
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    vec4 textureColor = texture(outTexture, oTexcoord);
    vec4 result = vec4(ambient + diffuse, 1.0) * textureColor;
    fragColor = result;
}
