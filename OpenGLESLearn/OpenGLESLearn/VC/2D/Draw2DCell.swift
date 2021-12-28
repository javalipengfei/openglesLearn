//
//  Draw2DCell.swift
//  OpenglESLab
//
//  Created by lipengfei17 on 2021/9/18.
//

import UIKit

class Draw2DCell: UICollectionViewCell {
    
    let label: UILabel = UILabel.init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = self.bounds
        self.addSubview(label)
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.cornerRadius = 2.0
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
