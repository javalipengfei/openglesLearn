//
//  TextureMixView.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2022/9/30.
//

import UIKit
import OpenGLES

class TextureMixView: UIView {
    
    var frameBuffer: GLuint = 0
    var renderBuffer: GLuint = 0
    var program: GLuint = 0
    var context: EAGLContext!
    var vbo: GLuint = 0
    var veo: GLuint = 0
    var textureID: GLuint = 0
    var mixTextureId: GLuint = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupContent()
        self.setupProgram()
        self.setupVerData()
        self.setupImageTexture()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clearBuffer()
        self.setupBuffer()
        self.render()
    }
    
    func setupContent() {
    
        self.contentScaleFactor = UIScreen.main.scale
        context = EAGLContext.init(api: .openGLES3)
        assert(context != nil, "content init fail ....")
        let isSuccess = EAGLContext.setCurrent(context)
        assert(isSuccess, "setup content fail ....")
    }
    
    func setupProgram() {
        if self.program != 0 {
            glDeleteProgram(self.program)
        }
        self.program = GLESTool.loadShader(vShaderName: "textureMixVsh", fShaderName: "textureMixFsh")
        assert(self.program != 0, "complie program fail ....")
        glUseProgram(self.program)
    }
    
    func setupVerData() {
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
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(GLsizei(MemoryLayout<GLubyte>.stride * 6)), indicate, GLenum(GL_STATIC_DRAW))
        
        let leftBottomIndex = glGetUniformLocation(self.program, "leftBottom")
        glUniform2f(leftBottomIndex, 0.3, 0.3)
        let rightTopIndex = glGetUniformLocation(self.program, "rightTop")
        glUniform2f(rightTopIndex, 0.6, 0.6)
    }
    
    func getMemorySize(count: Int) -> GLsizeiptr {
        return GLsizeiptr(GLsizei(MemoryLayout<CGFloat>.size * count))
    }
    
    func setupImageTexture() {
        self.textureID = self.setupImageTexture(name: "1", textureIndex: GLenum(GL_TEXTURE0))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), textureID)
        let tex1 = glGetUniformLocation(self.program, "outTexture")
        glUniform1i(tex1, 0)
        self.mixTextureId = self.setupImageTexture(name: "2", textureIndex: GLenum(GL_TEXTURE1))
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), mixTextureId)
        let tex2 = glGetUniformLocation(self.program, "outTexture1")
        glUniform1i(tex2, 1)
    }
    
    func setupImageTexture(name: String, textureIndex: GLenum) -> GLuint {
        let dataItem = getImageData(name: name)
        guard let dataItem = dataItem else {
            return 0
        }
        var textureID: GLuint = 0
        glGenTextures(1, &textureID)
        glActiveTexture(textureIndex)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureID)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(dataItem.1), GLsizei(dataItem.2), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), dataItem.0)
        return textureID
        
    }
    
    func clearBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        glDeleteRenderbuffers(1, &renderBuffer)
        frameBuffer = 0
        renderBuffer = 0
    }
    
//    if (textCoord.x > leftBottom.x && textCoord.y > leftBottom.y && textCoord.x < rightTop.x && textCoord.y < rightTop.y) {
//        vec2 texture1Coord = vec2((textCoord.x - leftBottom.x)/ (rightTop.x - leftBottom.x), (textCoord.y - leftBottom.y) / (rightTop.y - leftBottom.y));
//        fragColor = texture2D(outTexture1, texture1Coord);
//    } else {
//        fragColor = texture2D(outTexture, textCoord);
//    }
    
    func setupBuffer() {
        
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as? CAEAGLLayer)
        
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)
    }
    
    func getImageData(name: String) -> (UnsafeMutablePointer<GLubyte>?, Int, Int)? {
        guard let image = UIImage(named: name)?.cgImage else {
            return nil
        }
        let width = image.width
        let height = image.height
        let data: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        UIGraphicsBeginImageContext(CGSize.init(width: width, height: height))
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1, y: -1)
        context?.draw(image, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()
        return (data, width, height)
    }
    
    func resetViewPort() {
        glClearColor(0.0, 1.0, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.size.width * scale), GLsizei(self.frame.size.height * scale))
    }
    
    func render() {
        self.resetViewPort()
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_BYTE), nil)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

}
