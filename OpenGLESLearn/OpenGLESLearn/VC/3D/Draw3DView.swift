//
//  Draw3DView.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/26.
//

import UIKit
import OpenGLES
import GLKit

enum Direction{
    case xDir
    case yDir
    case zDir
}

class Draw3DView: UIView {
    var context: EAGLContext!
    var myFrameBuffer: GLuint = 0
    var myColorRenderBuffer: GLuint = 0
    var program: GLuint = 0
    var xAngle:Float = 0.0
    var yAngle:Float = 0.0
    var zAngle:Float = 0.0
    var rotateDirection: Direction = .xDir
    var verBuffer: GLuint = 0
    var eleBuffer: GLuint = 0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.configEsglEnv()
        self.setupProgram()
        self.setupVAO()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.clearBuffer()
        self.setBuffer()
        self.render()
        
    }
    
    func setupProgram() {
        self.loadShader(vShader: "3dShaderv", fShader: "3dShaderf")
    }
    
    func setupVAO(){
        if verBuffer == 0 {
            let attrArr:[GLfloat] = [
                0.5, 0.5, 0.5,    1.0, 0.0, 1.0,
                -0.5, 0.5, 0.5,   1.0, 0.0, 1.0,
                -0.5,-0.5, 0.5,   1.0, 0.0, 1.0,
                0.5, -0.5, 0.5,   1.0, 0.0, 1.0,

                0.5, 0.5, -0.5,   0.0, 0.0, 1.0,
                -0.5, 0.5, -0.5,  0.0, 1.0, 0.0,
                -0.5, -0.5, -0.5, 0.5, 1.0, 0.5,
                0.5, -0.5, -0.5,  1.0, 0.5 , 1.0,
            ]

            glGenBuffers(1, &verBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), verBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size*attrArr.count)), attrArr, GLenum(GL_STATIC_DRAW))
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), verBuffer)
            glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 6), nil)
            glEnableVertexAttribArray(0)
            
            glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 6), UnsafeMutablePointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3))
            glEnableVertexAttribArray(1)

        }
        
        if eleBuffer == 0 {
            let indicate:[GLuint] = [
                0,1,2, 0,2,3,  //??????
                0,3,4, 3,7,4,  //??????
                0,4,5, 0,5,1,  //??????
                3,2,6, 3,6,7,   //??????
                6,5,4, 6,4,7, //??????
                2,1,6, 1,5,6, //??????
            ]
            glGenBuffers(1, &eleBuffer)
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), eleBuffer)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLuint>.size*36)), indicate, GLenum(GL_STATIC_DRAW))
        }
    }
    
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    
    func rotate(angle: Float, direction: Direction) {
        switch direction {
        case .xDir:
            xAngle += angle
        case .yDir:
            yAngle += angle
        case .zDir:
            zAngle += angle
        }
        self.render()
    }
    
    func configEsglEnv() {
        self.contentScaleFactor = UIScreen.main.scale
        context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
        if context == nil {
            debugPrint("context create fail .....")
        }
        let isSuccess = EAGLContext.setCurrent(context)
        if !isSuccess {
            debugPrint("set context fail .....")
        }
    }
    
    func clearBuffer() {
        glDeleteFramebuffers(1, &myFrameBuffer)
        glDeleteRenderbuffers(1, &myColorRenderBuffer)
        myFrameBuffer = 0
        myColorRenderBuffer = 0
    }
    
    func setBuffer() {
        if myColorRenderBuffer == 0 {
            var buffer: GLuint = 0
            glGenRenderbuffers(1, &buffer)
            myColorRenderBuffer = buffer
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
            self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        }
        
        if myFrameBuffer == 0 {
            var buffer: GLuint = 0
            glGenFramebuffers(1, &buffer)
            myFrameBuffer = buffer
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), myFrameBuffer)
            glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
        }
    }
    
    @objc func render(){
        self.clearAndResetView()
        let projectionLoc = glGetUniformLocation(self.program, "vprojection")
        var projectionMatrix: KSMatrix4 = KSMatrix4()
        ksMatrixLoadIdentity(&projectionMatrix)
        let apect: Float = Float(self.frame.size.width / self.frame.size.height )
        ksPerspective(&projectionMatrix, 0.0, apect, 0.10, 1000.0)
        glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), &projectionMatrix.m.0.0)


        let mvlocation = glGetUniformLocation(self.program, "vmatrix")
        var modelViewMatrix: KSMatrix4 = KSMatrix4()
        ksMatrixLoadIdentity(&modelViewMatrix)
        
        ksRotate(&modelViewMatrix, xAngle, 1, 0, 0)
        ksRotate(&modelViewMatrix, yAngle, 0, 1, 0)
        ksRotate(&modelViewMatrix, zAngle, 0, 0, 1)

        glUniformMatrix4fv(mvlocation, 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0)
//
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_DEPTH_EXT))
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(36), GLenum(GL_UNSIGNED_INT), nil)
                
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    private func clearAndResetView(){
        glClearColor(0.0, 1.0 , 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
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
    
    deinit {
        if verBuffer != 0 {
            glDeleteBuffers(1, &verBuffer)
        }
        if eleBuffer != 0 {
            glDeleteBuffers(1, &eleBuffer)
        }
    }
}
