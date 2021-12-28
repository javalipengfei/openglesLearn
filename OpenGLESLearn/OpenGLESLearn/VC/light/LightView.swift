//
//  Draw3DView.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/26.
//

import UIKit
import OpenGLES
import GLKit


class LightView: UIView {
    var context: EAGLContext!
    var myFrameBuffer: GLuint = 0
    var myColorRenderBuffer: GLuint = 0
    var program: GLuint = 0
    var verBuffer: GLuint = 0
    var texTureID: GLuint = 0
    var xAngle:Float = 5.0
    var yAngle:Float = 15.0
    var zAngle:Float = 0.0
    var rotateDirection: Direction = .xDir
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupEsglEnv()
        self.setupProgram()
        self.setupData()
        self.setupTexture(name: "1")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.clearBuffer()
        self.setBuffer()
        self.render()
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
    
    func setupEsglEnv() {
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
    
    func setupProgram() {
        program = self.loadShader(vShader: "lightShaderv", fShader: "lightShaderf")
        if program != 0 {
            glUseProgram(program)
        } else {
            debugPrint("program init fail....")
        }
    }
    
    func setupData() {
        let attrArr:[GLfloat] = [
            // 正面 0,1,2, 0,2,3,
            0.5, 0.5, 0.5,      1.0, 1.0,       0.0, 0.0, 1.0,
            -0.5, 0.5, 0.5,     0.0, 1.0,       0.0, 0.0, 1.0,
            -0.5,-0.5, 0.5,     0.0, 0.0,       0.0, 0.0, 1.0,
            0.5, 0.5, 0.5,      1.0, 1.0,       0.0, 0.0, 1.0,
            -0.5,-0.5, 0.5,     0.0, 0.0,       0.0, 0.0, 1.0,
            0.5, -0.5, 0.5,     1.0, 0.0,       0.0, 0.0, 1.0,
            
            //右面  0,3,4, 3,7,4,
            0.5, 0.5, 0.5,      0.0,1.0,        -1.0, 0.0, 0.0,
            0.5, -0.5, 0.5,     0.0,0.0,        -1.0, 0.0, 0.0,
            0.5, 0.5, -0.5,     1.0,1.0,        -1.0, 0.0, 0.0,
            0.5, -0.5, 0.5,      0.0,0.0,       -1.0, 0.0, 0.0,
            0.5, -0.5, -0.5,     1.0,0.0,       -1.0, 0.0, 0.0,
            0.5, 0.5, -0.5,      1.0,1.0,       -1.0, 0.0, 0.0,
            
            //0,4,5, 0,5,1,  //顶部
            0.5, 0.5, 0.5,        1.0,0.0,      0.0, 1.0, 0.0,
            0.5, 0.5, -0.5,       1.0,1.0,      0.0, 1.0, 0.0,
            -0.5, 0.5, -0.5,      0.0,1.0,      0.0, 1.0, 0.0,
            0.5, 0.5, 0.5,        1.0,0.0,      0.0, 1.0, 0.0,
            -0.5, 0.5, -0.5,      0.0, 1.0,     0.0, 1.0, 0.0,
            -0.5, 0.5, 0.5,       0.0, 0.0,     0.0, 1.0, 0.0,
            //3,2,6, 3,6,7,   //底部
            0.5, -0.5, 0.5,       1.0, 0.0,     0.0, -1.0, 0.0,
            -0.5,-0.5, 0.5,       0.0,0.0,      0.0, -1.0, 0.0,
            -0.5, -0.5, -0.5,     0.0,1.0,      0.0, -1.0, 0.0,
            0.5, -0.5, 0.5,       1.0, 0.0,     0.0, -1.0, 0.0,
            -0.5, -0.5, -0.5,     0.0,1.0,      0.0, -1.0, 0.0,
            0.5, -0.5, -0.5,      1.0, 1.0,     0.0, -1.0, 0.0,
            //6,5,4, 6,4,7, //背面
            -0.5, -0.5, -0.5,      0.0,0.0,     0.0, 0.0, -1.0,
            -0.5, 0.5, -0.5,       0.0,1.0,     0.0, 0.0, -1.0,
            0.5, 0.5, -0.5,        1.0,1.0,     0.0, 0.0, -1.0,
            -0.5, -0.5, -0.5,      0.0,0.0,     0.0, 0.0, -1.0,
            0.5, 0.5, -0.5,        1.0,1.0,     0.0, 0.0, -1.0,
            0.5, -0.5, -0.5,       1.0,0.0,     0.0, 0.0, -1.0,
            //2,1,6, 1,5,6, //左面
            -0.5,-0.5, 0.5,       0.0,0.0,      1.0, 0.0, 0.0,
            -0.5, 0.5, 0.5,        0.0,1.0,     1.0, 0.0, 0.0,
            -0.5, -0.5, -0.5,       1.0,0.0,    1.0, 0.0, 0.0,
            -0.5, 0.5, 0.5,        0.0,1.0,     1.0, 0.0, 0.0,
            -0.5, 0.5, -0.5,       1.0,1.0,     1.0, 0.0, 0.0,
            -0.5, -0.5, -0.5,      1.0,0.0,     1.0, 0.0, 0.0,
        ]
        
        glGenBuffers(1, &verBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), verBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size*attrArr.count)), attrArr, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), verBuffer)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), nil)
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 8), UnsafeMutablePointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3))
        glEnableVertexAttribArray(1)
        
        glVertexAttribPointer(2, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.stride * 8), UnsafeMutablePointer.init(bitPattern: MemoryLayout<GLfloat>.size * 5))
        glEnableVertexAttribArray(2)
    }
    func clearBuffer() {
        glDeleteFramebuffers(1, &myFrameBuffer)
        glDeleteRenderbuffers(1, &myColorRenderBuffer)
        myFrameBuffer = 0
        myColorRenderBuffer = 0
    }
    
    func setBuffer() {
        var buffer: GLuint = 0
        glGenRenderbuffers(1, &buffer)
        myColorRenderBuffer = buffer
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        
        glGenFramebuffers(1, &buffer)
        myFrameBuffer = buffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), myFrameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
    }
    
    func render(){
        self.clearAndResetView()
        let projectionLoc = glGetUniformLocation(self.program, "vprojection")
        var projectionMatrix: KSMatrix4 = KSMatrix4()
        ksMatrixLoadIdentity(&projectionMatrix)
        let apect: Float = Float(self.frame.size.width / self.frame.size.height )
        ksPerspective(&projectionMatrix, 0.0, apect, 0.10, 1000.0)
        glUniformMatrix4fv(projectionLoc, 1, GLboolean(GL_FALSE), &projectionMatrix.m.0.0)

        let modelViewLoc = glGetUniformLocation(self.program, "modelViewMatrix")
        var modelViewMatrix: KSMatrix4 = KSMatrix4()
        ksMatrixLoadIdentity(&modelViewMatrix)
        
        ksRotate(&modelViewMatrix, xAngle, 1, 0, 0)
        ksRotate(&modelViewMatrix, yAngle, 0, 1, 0)
        ksRotate(&modelViewMatrix, zAngle, 0, 0, 1)

        glUniformMatrix4fv(modelViewLoc, 1, GLboolean(GL_FALSE), &modelViewMatrix.m.0.0)
        
        var lightColor:[GLfloat] = [1.0, 1.0, 1.0]
        let lightLoc = glGetUniformLocation(self.program, "lightColor")
        glUniform3fv(lightLoc, 1, &lightColor)

        var lightPos:[GLfloat] = [1.2, 1.0, 1.5]
        let lightPosLoc = glGetUniformLocation(self.program, "lightPos")
        glUniform3fv(lightPosLoc, 1, &lightPos)
//
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_DEPTH_EXT))
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func setupTexture(name: String) {
        
        guard let image = UIImage(named: name)?.cgImage else {
            debugPrint("load texture fail ...")
            return
        }
        let width = image.width
        let height =  image.height
        let data: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        UIGraphicsBeginImageContext(CGSize.init(width: width, height: height))
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        context?.translateBy( x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()
        
        glActiveTexture(texTureID)
        glBindTexture(GLenum(GL_TEXTURE_2D), texTureID)
        //设置纹理参数
        //缩小/放大过滤器
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), data)
        
        free(data)
        
    }
    
    private func clearAndResetView(){
        glClearColor(0.0, 1.0 , 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
    }
    
    private func loadShader(vShader: String, fShader: String) -> GLuint {
        let verPath = Bundle.main.path(forResource: vShader, ofType: "vsh")
        let fragPath = Bundle.main.path(forResource: fShader, ofType: "fsh")
        guard verPath != nil else {
            debugPrint("get verPath fail")
            return 0
        }
        guard fragPath != nil else {
            debugPrint("get fragPath fail")
            return 0
        }
        let program = GLESTool.loadShader(vShader: verPath!, fShader: fragPath!)
        return program
    }
    
    deinit {
        if verBuffer != 0 {
            glDeleteBuffers(1, &verBuffer)
            verBuffer = 0
        }
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
        glDeleteTextures(1, &texTureID)
    }

}
