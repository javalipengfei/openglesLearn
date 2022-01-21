#version 300 es
precision mediump float;
uniform sampler2D Texture;
in vec2 oTextcoords;
out vec4 fragColor;
void main() {
    vec2 tcd = oTextcoords;
    if (tcd.x < 1.0 / 3.0) {
        tcd.x = tcd.x * 3.0;
    } else if (tcd.x < 2.0 / 3.0) {
        tcd.x = (tcd.x - 1.0 / 3.0) * 3.0;
    } else {
        tcd.x = (tcd.x - 2.0 / 3.0) * 3.0;
    }
    if (tcd.y <= 1.0 / 3.0) {
        tcd.y = tcd.y * 3.0;
    } else if (tcd.y < 2.0 / 3.0) {
        tcd.y = (tcd.y - 1.0 / 3.0) * 3.0;
    } else {
        tcd.y = (tcd.y - 2.0 / 3.0) * 3.0;
    }
    fragColor = texture(Texture, tcd);
}

