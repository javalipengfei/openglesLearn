#version 300 es
precision mediump float;
in vec2 textCoord;
out vec4 fragColor;
uniform sampler2D outTexture;
uniform sampler2D outTexture1;
uniform vec2 leftBottom;
uniform vec2 rightTop;
void main()
{
    if (textCoord.x > leftBottom.x && textCoord.y > leftBottom.y && textCoord.x < rightTop.x && textCoord.y < rightTop.y) {
        vec2 texture1Coord = vec2((textCoord.x - leftBottom.x)/ (rightTop.x - leftBottom.x), (textCoord.y - leftBottom.y) / (rightTop.y - leftBottom.y));
        vec4 source = texture(outTexture1, texture1Coord);
        fragColor = source * source.a + texture(outTexture, textCoord) * (1.0 - source.a);
    } else {
        fragColor = texture(outTexture, textCoord);
    }
}
