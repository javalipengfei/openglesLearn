//
//  TextureMix.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2022/9/30.
//

import UIKit

class TextureMixVC: UIViewController {

    var glView: TextureMixView = TextureMixView.init(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        glView.frame = self.view.bounds
        self.view.addSubview(glView)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
