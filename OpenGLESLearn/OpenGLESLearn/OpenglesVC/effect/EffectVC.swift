//
//  EffectVC.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2021/12/29.
//

import UIKit

enum EffectType: Int {
    case none
    case nightZone
    case scale
    case soulOut
    case shake
    case white
}
class EffectVC: UIViewController {
    
    var effectView: EffectView!
    var collectionView: UICollectionView!
    var dataArray: [(String, EffectType)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        effectView = EffectView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 200))
        self.view.addSubview(effectView)
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 70, height: 50)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: effectView.frame.size.height + 100, width: self.view.frame.width, height: 50), collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(Draw2DCell.self, forCellWithReuseIdentifier: Draw2DCell.description())
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        
        dataArray = [("无", .none), ("九宫格", .nightZone),("缩放", .scale),("灵魂出窍", .soulOut),("抖动", .shake), ("闪白", .white)]
        // Do any additional setup after loading the view.
    }
}

extension EffectVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Draw2DCell.description(), for: indexPath) as! Draw2DCell
        let name = dataArray[indexPath.row]
        cell.label.text = name.0
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        effectView.render(type: item.1)
    }
}
