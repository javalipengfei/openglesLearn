//
//  TextureVC.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/28.
//

import UIKit

class TextureVC: UIViewController {

    var glView: TextureView!
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        glView = TextureView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
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
