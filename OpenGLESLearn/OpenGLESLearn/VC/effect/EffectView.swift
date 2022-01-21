//
//  EffectView.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2021/12/29.
//

import UIKit

class EffectView: UIView {

    var context: EAGLContext!
    var program: GLuint = 0
    var frameBuffer: GLuint = 0
    var renderBuffer: GLuint = 0
    var textureID: GLuint = 0
    var vbo: GLuint = 0
    var veo: GLuint = 0
    var displayLink: CADisplayLink?
    var currentTimeStamp: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupEsglEnv()
        self.setupProgram(vShader: "texturevsh", fShader: "texturefsh")
        self.setupVertureData()
        self.setupTexture(name: "1")
        
    }
    
    @objc public func timeAction() {
        
        if let displayLink = displayLink {
            if currentTimeStamp == 0 {
                currentTimeStamp = displayLink.timestamp
            }
            let currentTime = displayLink.timestamp - currentTimeStamp
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbo)
            let location = glGetUniformLocation(self.program, "time")
            glUniform1f(location, GLfloat(currentTime))
            self.render()
        }
    }
    
    func render(type: EffectType) {
        displayLink?.invalidate()
        switch type {
        case .none:
            self.renderNoneAction()
        case .nightZone:
            self.renderZoneAction()
        case .scale:
            self.renderScaleAction()
        case .soulOut:
            self.renderSoulOutAction()
        case .shake:
            self.renderShakeAction()
        case .white:
            self.renderWhiteAction()
        }
    }
    
    func renderNoneAction() {
        self.setupProgram(vShader: "texturevsh", fShader: "texturefsh")
        self.render()
    }
    
    func renderZoneAction() {
        self.setupProgram(vShader: "nightZone", fShader: "nightZone")
        self.render()
    }
    
    func renderScaleAction() {
        self.setupProgram(vShader: "scale", fShader: "scale")
        displayLink = CADisplayLink.init(target: self, selector: #selector(timeAction))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func renderSoulOutAction() {
        self.setupProgram(vShader: "soulOut", fShader: "soulOut")
        displayLink = CADisplayLink.init(target: self, selector: #selector(timeAction))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func renderShakeAction() {
        self.setupProgram(vShader: "shake", fShader: "shake")
        displayLink = CADisplayLink.init(target: self, selector: #selector(timeAction))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func renderWhiteAction() {
        self.setupProgram(vShader: "white", fShader: "white")
        displayLink = CADisplayLink.init(target: self, selector: #selector(timeAction))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        self.clearFrameAndRenderBuffer()
        self.setupFrameAndRenderBuffer()
        self.render()
    }
    
    func setupEsglEnv() {
        self.contentScaleFactor = UIScreen.main.scale
        self.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
        if self.context == nil {
            debugPrint("context init fail...")
        }
        let isSuccess = EAGLContext.setCurrent(context)
        if !isSuccess {
            debugPrint("set context fail...")
        }
    }
    
    func setupProgram(vShader: String, fShader: String) {
        if self.program != 0 {
            glDeleteProgram(self.program)
            self.program = 0
        }
        self.program = self.loadShader(vShader: vShader, fShader: fShader)
        if self.program == 0 {
            debugPrint("program init fail...")
        } else {
            glUseProgram(program)
        }
    }
    
    func setupVertureData() {
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
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size * (attrArr.count + texturePosition.count)) ), nil, GLenum(GL_STATIC_DRAW))
        
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, GLsizeiptr(GLsizei(MemoryLayout<GLfloat>.size * attrArr.count)), attrArr)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * attrArr.count, MemoryLayout<GLfloat>.size * texturePosition.count, texturePosition)
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 3), nil)
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 2), UnsafeMutablePointer(bitPattern: MemoryLayout<GLfloat>.size * attrArr.count))
        glEnableVertexAttribArray(1)

        glGenBuffers(1, &veo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), veo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLubyte>.stride * 6)), indicate, GLenum(GL_STATIC_DRAW))
    }
    
    func clearFrameAndRenderBuffer() {
        if frameBuffer != 0 {
            glDeleteFramebuffers(1, &frameBuffer)
            frameBuffer = 0
        }
        if renderBuffer != 0 {
            glDeleteRenderbuffers(1, &renderBuffer)
            renderBuffer = 0
        }
    }
    
    func setupFrameAndRenderBuffer() {
        if renderBuffer == 0 {
            glGenRenderbuffers(1, &renderBuffer)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
            self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        }
        if frameBuffer == 0 {
            glGenFramebuffers(1, &frameBuffer)
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
            glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
        }
    }
    
    func setupTexture(name: String) {
        guard let image = UIImage.init(named: name)?.cgImage else {
            debugPrint("load texture fail...")
            return
        }
        let width = image.width
        let height = image.height
        let data: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        UIGraphicsBeginImageContext(CGSize.init(width: width, height: height))
        let context = CGContext.init(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        context?.draw(image, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()
        
        glGenTextures(1, &textureID)
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), textureID)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), data)
        free(data)
    }
    
    func render() {
        self.resetViewPoint()
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_BYTE), nil)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func resetViewPoint() {
        glClearColor(0.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(0, 0, GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
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
        if self.veo != 0 {
            glDeleteBuffers(1, &veo)
        }
        if self.vbo != 0 {
            glDeleteBuffers(1, &vbo)
        }
        if self.program != 0 {
            glDeleteProgram(program)
        }
        glDeleteTextures(1, &textureID)
        displayLink?.invalidate()
    }

}
