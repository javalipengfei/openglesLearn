#version 300 es
layout(location = 0) in vec4 vPosition;
layout(location = 1) in float pointWidth;
void main(){
    gl_Position = vPosition;
    gl_PointSize = pointWidth;
}
