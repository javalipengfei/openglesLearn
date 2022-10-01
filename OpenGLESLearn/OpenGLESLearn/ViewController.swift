//
//  ViewController.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2021/12/28.
//

import UIKit

class ViewController: UIViewController {

    let cellIden = "indexCellIden"
    var tableView: UITableView!
    var dataSource: [PageModel]!
    var nav: UINavigationController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "首页"
        self.view.backgroundColor = .white
        tableView = UITableView.init(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIden)
        self.view.addSubview(tableView)
        
        dataSource = [
            PageModel.init(name: "画一个2D图形吧", page: "Draw2DVC"),
            PageModel.init(name: "画一个3D图形吧", page: "Draw3DVC"),
            PageModel.init(name: "加载一个纹理吧", page: "TextureVC"),
            PageModel.init(name: "纹理混合", page: "TextureMixVC"),
            PageModel.init(name: "加载3D纹理贴图", page: "DrawTexture3DVC"),
            PageModel.init(name: "来一个光照吧", page: "LightVC"),
            PageModel.init(name: "做一个lut滤镜吧", page: "LutFilterVC"),
            PageModel.init(name: "做一个特效吧", page: "EffectVC"),
            PageModel.init(name: "获取视频信息", page: "VideoInfoVC"),
            
        ]
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIden)
        cell?.backgroundColor = .white
        cell?.selectionStyle = .none
        cell?.textLabel?.textColor = .black
        let pageModel = dataSource[indexPath.row]
        cell?.textLabel?.text = pageModel.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageModel = dataSource[indexPath.row]
        let className = pageModel.page
        let cls: AnyClass? = NSClassFromString("OpenGLESLearn.\(className)")
        let vcClass = cls as? UIViewController.Type
        if let vcClass = vcClass {
            let vc = vcClass.init()
            vc.title = pageModel.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class PageModel: NSObject {
    var name: String = ""
    var page: String = ""
    init(name: String, page: String) {
        self.name = name
        self.page = page
    }
}
