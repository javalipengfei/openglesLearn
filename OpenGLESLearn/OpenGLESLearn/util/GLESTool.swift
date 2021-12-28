//
//  GLESTool.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/16.
//

import UIKit
import OpenGLES

class GLESTool: NSObject {
     class func loadShader(vShader: String, fShader: String) -> GLuint {
        var infoLog = [GLchar](repeating: 0, count: 512)
        var success: GLint = 0
        let verShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        let fragShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        let program = glCreateProgram()
        self.compileShader(shader: verShader, type: GLenum(GL_VERTEX_SHADER), file: vShader)
        self.compileShader(shader: fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fShader)
        
        glAttachShader(program, verShader)
        glAttachShader(program, fragShader)
        glLinkProgram(program)
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
        guard success == GL_TRUE else {
            glGetProgramInfoLog(program, 512, nil, &infoLog)
            debugPrint(String(cString: infoLog))
            return GLuint(0)
        }
        glDeleteShader(verShader)
        glDeleteShader(fragShader)
        return program
    }
    class func compileShader(shader: GLuint, type: GLenum, file: String) {
        var infoLog = [GLchar](repeating: 0, count: 512)
        var success: GLint = 0
        var fileStr = ""
        do{
            fileStr = try String.init(contentsOfFile: file)
        } catch {
            debugPrint("get shader fail...: \(error)")
            return
        }
        let shaderStringUTF8 = fileStr.cString(using: String.defaultCStringEncoding)
        var shaderStringUTF8Pointer = UnsafePointer<GLchar>(shaderStringUTF8)
        glShaderSource(shader, GLsizei(1), &shaderStringUTF8Pointer, nil)
        glCompileShader(shader)
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
        if success == GL_FALSE {
            glGetShaderInfoLog(shader, 512, nil, &infoLog)
            debugPrint("\(String(cString: &infoLog))")
        }
    }
}
