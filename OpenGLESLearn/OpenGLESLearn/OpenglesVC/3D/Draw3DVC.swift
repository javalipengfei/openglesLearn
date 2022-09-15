//
//  Draw3DVC.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/26.
//

import UIKit

class Draw3DVC: UIViewController {
    
    var esView: Draw3DView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        esView = Draw3DView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(esView)
        self.view.backgroundColor = .white
        
        let xBtn = UIButton.init(type: .custom)
        xBtn.frame = CGRect.init(x: 100, y: self.view.frame.height - 100, width: 50, height: 50)
        xBtn.setTitle("x", for: .normal)
        xBtn.addTarget(self, action: #selector(xAction), for: .touchUpInside)
        xBtn.backgroundColor = UIColor.red
        self.view.addSubview(xBtn)
        
        let yBtn = UIButton.init(type: .custom)
        yBtn.frame = CGRect.init(x: 200, y: self.view.frame.height - 100, width: 50, height: 50)
        yBtn.setTitle("y", for: .normal)
        yBtn.addTarget(self, action: #selector(yAction), for: .touchUpInside)
        yBtn.backgroundColor = .red
        self.view.addSubview(yBtn)
        
        let zBtn = UIButton.init(type: .custom)
        zBtn.frame = CGRect.init(x: 300, y: self.view.frame.height - 100, width: 50, height: 50)
        zBtn.setTitle("z", for: .normal)
        zBtn.addTarget(self, action: #selector(zAction), for: .touchUpInside)
        zBtn.backgroundColor = .red
        self.view.addSubview(zBtn)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func xAction() {
        
        esView.rotate(angle: 5, direction: .xDir)
    }
    
    @objc func yAction() {
        esView.rotate(angle: 5, direction: .yDir)
    }
    
    @objc func zAction() {
        esView.rotate(angle: 5, direction: .zDir)
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
