//
//  TextureView.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/28.
//

import UIKit
import CoreGraphics

class LutFilterView: UIView {

    var colorRenderBuffer: GLuint = 0
    var frameBuffer: GLuint = 0
    var context: EAGLContext!
    var program: GLuint = 0
    var outTexttureID: GLuint = 0
    var lookTexttureID: GLuint = 0
    var vbo: GLuint = 0
    var veo: GLuint = 0
    var iv: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupContext()
        self.setupProgram()
        self.setupData()
        self.setupTexture(imageName: "1", uniformName: "outTexture", index: 0)
        self.setupTexture(imageName: "lookup", uniformName: "lutTexture", index: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clearBuffer()
        self.setupBuffer()
        self.drawAction()
    }
     
    func setupContext() {
        self.contentScaleFactor = UIScreen.main.scale
        self.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
        if self.context == nil {
            debugPrint("create context fail ...")
            return
        }
        let isSuccess = EAGLContext.setCurrent(self.context)
        if !isSuccess {
            debugPrint("setup context fail")
        }
    }
    
    func clearBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        glDeleteRenderbuffers(1, &colorRenderBuffer)
        frameBuffer = 0
        colorRenderBuffer = 0
    }
    
    func setupBuffer() {
        
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    
    func setupProgram() {
        self.program = self.loadShader(vShader: "lutFiltervsh", fShader: "lutFilterfsh")
        if self.program != 0 {
            glUseProgram(program)
        } else {
            debugPrint("program init fail...")
        }
    }
    
    func setupData() {
        let attrArr:[GLfloat] = [
            0.5, 0.5, 0.0,
            -0.5, 0.5, 0.0,
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0.0
        ]
        
        let texturePosition:[GLfloat] = [
            1.0, 1.0,
            0.0, 1.0,
            0.0, 0.0,
            1.0, 0.0,
        ]
        
        let indicate:[GLubyte] = [
            0, 1, 2,
            0, 3, 2,
        ]
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size * attrArr.count + MemoryLayout<GLfloat>.size * texturePosition.count) ), nil, GLenum(GL_STATIC_DRAW))
        
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size * attrArr.count)), attrArr)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * attrArr.count, MemoryLayout<GLfloat>.size * texturePosition.count, texturePosition)
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 3), nil)
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 2), UnsafeMutablePointer(bitPattern: MemoryLayout<GLfloat>.size * attrArr.count))
        glEnableVertexAttribArray(1)
        
        glGenBuffers(1, &veo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), veo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLubyte>.stride * indicate.count)), indicate, GLenum(GL_STATIC_DRAW))
    }
    
    
    func drawAction() {
        self.resetViewPort()
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_BYTE), nil)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    
    func setupTexture(imageName: String, uniformName: String, index: GLint) {
        
        guard let image = UIImage(named: imageName)?.cgImage else {
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
        
        let loc = glGetUniformLocation(self.program, uniformName)
        if index == 0 {

            glGenTextures(1, &outTexttureID)
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), GLenum(outTexttureID))
            glUniform1i(loc, 0)
        } else {
            glGenTextures(1, &lookTexttureID)
            glActiveTexture(GLenum(GL_TEXTURE1))
            glBindTexture(GLenum(GL_TEXTURE_2D), GLenum(lookTexttureID))
            glUniform1i(loc, 1)
        }
        //设置纹理参数
        //缩小/放大过滤器
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), data)
//        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        free(data)
    }
    
    func resetViewPort() {
        glClearColor(0.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
    }
    func loadShader(vShader: String, fShader: String) -> GLuint {
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
        if veo != 0 {
            glDeleteBuffers(1, &veo)
        }
        if vbo != 0 {
            glDeleteBuffers(1, &vbo)
        }
        if program != 0 {
            glDeleteProgram(program)
        }
        if lookTexttureID != 0 {
            glDeleteTextures(1, &lookTexttureID)
        }
        if outTexttureID != 0 {
            glDeleteTextures(1, &outTexttureID)
        }
    }
}
