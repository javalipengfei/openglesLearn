//
//  DrawTriangleView.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/16.
//

import UIKit
import OpenGLES

enum GraphType {
    case point
    case line
    case lineStrip
    case lineLoop
    case angle
    case angleStrip
    case angleFan
    case square
}

class Draw2DView: UIView {
    
    var program: GLuint!
    var context: EAGLContext!
    var myColorFrameBuffer:GLuint = 0
    var myColorRenderBuffer:GLuint = 0
    var type: GraphType = .point
    override func layoutSubviews() {
        self.configEaglEnv()
        self.destoryRenderAndFrameBuffer()
        self.setupBuffer()
        self.render()
    }

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    
    func drawGraph(type: GraphType) {
        self.type = type
        self.render()
    }
    
    func configEaglEnv() {
        
        self.contentScaleFactor = UIScreen.main.scale
//        layer.isOpaque = true
//        layer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking:false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
        let context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
        if context == nil {
            debugPrint("create context fail...")
            return
        }
        let isSuccess = EAGLContext.setCurrent(context)
        if !isSuccess {
            debugPrint("set context fial ....")
        }
        self.context = context
    }
    
    func render() {
        
        switch type {
        case .point:
            drawPoint()
        case .line:
            drawLine()
        case .lineLoop:
            drawLineLoop()
        case .lineStrip:
            drawLineTrip()
        case .angle:
            drawAngle()
        case .angleFan:
            drawAngleFan()
        case .angleStrip:
            drawAngleTrip()
        case .square:
            drawSquare()
        }
        
    }
    
    func drawPoint(){
        self.clearAndResetView()
        self.loadShader(vShader: "pointShader", fShader: "shaderf")
        let attrArr: [GLfloat] = [
            0, 0.0, 0,
        ]
        let width = 100.0
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<CGFloat>.stride * 3), attrArr)
        glEnableVertexAttribArray(0)
        glVertexAttrib1f(GLuint(1), GLfloat(width))
        glDrawArrays(GLenum(GL_POINTS), 0, 1)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawLine(){
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attArr: [GLfloat] = [
            0.25, 0.25, 0.0,
            -0.25, -0.25, 0.0,
            -0.25, 0.25, 0.0,
            0.25, -0.25, 0.0,
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3) , attArr)
        glEnableVertexAttribArray(0)
        glLineWidth(10.0)
        glDrawArrays(GLenum(GL_LINES), 0, 4)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawLineTrip() {
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attArr: [GLfloat] = [
            0.25, 0.25, 0.0,
            -0.25, -0.25, 0.0,
            0.25, -0.25, 0.0,
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3) , attArr)
        glEnableVertexAttribArray(0)
        glLineWidth(10.0)
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, 3)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawLineLoop() {
        
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attArr: [GLfloat] = [
            0.25, 0.25, 0.0,
            -0.25, -0.25, 0.0,
            0.25, -0.25, 0.0,
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3) , attArr)
        glEnableVertexAttribArray(0)
        glLineWidth(10.0)
        glDrawArrays(GLenum(GL_LINE_LOOP), 0, 3)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawAngle() {
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        
        let attrArr: [GLfloat] = [
            0, 0.5, 0,
            -0.5, -0.5, 0,
            0.5, -0.5, 0
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3) , attrArr)
        glEnableVertexAttribArray(0)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawAngleFan() {
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attrArr:[GLfloat] = [
            0.0, 0.0, 0.0,
            -0.25, 0.25, 0.0,
            -0.25, -0.25, 0.0,
            0.25, -0.25, 0.0,
            0.25, 0.25, 0.0
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3), attrArr)
        glEnableVertexAttribArray(0)
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, 5)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawAngleTrip() {
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attrArr:[GLfloat] = [
            0.0, 0.0, 0.0,
            -0.25, 0.25, 0.0,
            -0.25, -0.25, 0.0,
            0.25, -0.25, 0.0,
            0.25, 0.25, 0.0
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3), attrArr)
        glEnableVertexAttribArray(0)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 5)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func drawSquare (){
        self.clearAndResetView()
        self.loadShader(vShader: "shaderv", fShader: "shaderf")
        let attrArr:[GLfloat] = [
            0.0, 0.0, 0.0,
            -0.5, 0.0, 0.0,
            -0.5, -0.25, 0.0,
            0.0, -0.25, 0.0,
        ]
        glVertexAttribPointer(GLuint(0), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 3), attrArr)
        glEnableVertexAttribArray(0)
        glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, 4)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    private func clearAndResetView(){
        glClearColor(0.0, 1.0 , 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
    }
    
    private func loadShader(vShader: String, fShader: String) {
        let verPath = Bundle.main.path(forResource: vShader, ofType: "vsh")
        let fragPath = Bundle.main.path(forResource: fShader, ofType: "fsh")
        guard verPath != nil else {
            debugPrint("get verPath fail")
            return
        }
        guard fragPath != nil else {
            debugPrint("get fragPath fail")
            return
        }
        program = GLESTool.loadShader(vShader: verPath!, fShader: fragPath!)
        glUseProgram(program)
    }
    
    fileprivate func destoryRenderAndFrameBuffer() {
       
        glDeleteFramebuffers(1, &myColorFrameBuffer)
        myColorFrameBuffer = 0
        glDeleteRenderbuffers(1, &myColorRenderBuffer)
        myColorRenderBuffer = 0
    }
    
    fileprivate func setupBuffer() {
        var buffer:GLuint = 0
        glGenRenderbuffers(1, &buffer)
        myColorRenderBuffer = buffer
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
        // 为 颜色缓冲区 分配存储空间
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        
        glGenFramebuffers(1, &buffer)
        myColorFrameBuffer = buffer
        // 设置为当前 framebuffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), myColorFrameBuffer)
        // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
    }

}
