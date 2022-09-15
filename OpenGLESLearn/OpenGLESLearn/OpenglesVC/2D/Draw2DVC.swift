//
//  DrawTriangle.swift
//  OpenglEsLab
//
//  Created by lipengfei17 on 2021/9/16.
//

import UIKit

class Draw2DVC: UIViewController {
    let cellIden = "2dcellIden"
    var collection: UICollectionView!
    var glView: Draw2DView!
    let dataArray:[(String, GraphType)] = [("点", .point),("线", .line),("线带", .lineStrip),("线环", .lineLoop),("三角形", .angle), ("三角形带", .angleStrip),("三角形扇", .angleFan), ("正方形", .square),]
    override func viewDidLoad() {
        super.viewDidLoad()
        glView = Draw2DView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 100))
        self.view.addSubview(glView)
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 70, height: 50)
        layout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.init(x: 0, y: glView.frame.size.height + 10, width: self.view.frame.width, height: 50), collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.register(Draw2DCell.self, forCellWithReuseIdentifier: cellIden)
        collection.delegate = self
        collection.dataSource = self
        self.view.addSubview(collection)
    }
}

extension Draw2DVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIden, for: indexPath) as! Draw2DCell
        let item = dataArray[indexPath.row]
        cell.label.text = item.0
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataArray[indexPath.row]
        glView.drawGraph(type: item.1)
    }
}

