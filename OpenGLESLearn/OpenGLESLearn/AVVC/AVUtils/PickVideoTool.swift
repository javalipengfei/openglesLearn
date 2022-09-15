//
//  PickVideoTool.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2022/9/14.
//

import UIKit
import Photos
import PhotosUI
class PickVideoTool: NSObject {
    var callBack: ((Bool, URL?) -> Void)?
    func pickUpVideo(callback: @escaping (Bool, URL?) -> Void) {
        self.callBack = callback
        if #available(iOS 14, *) {
            var configer = PHPickerConfiguration.init()
            configer.selectionLimit = 5;
            configer.filter = .videos
            configer.preferredAssetRepresentationMode = .current
            let picker = PHPickerViewController.init(configuration: configer)
            picker.delegate = self
            if let window = UIApplication.shared.delegate?.window, let vc = window?.rootViewController {
                vc.present(picker, animated: true, completion: nil)
            }
        } else {
            assert(false, "相册选择只支持ios14以上，以下需要自行代码适配")
        }
        
        
    }

    func checkAuthoriza(callBack: @escaping ((Bool) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            callBack(false)
        } else if status == .notDetermined {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    if status == .authorized {
                        callBack(true)
                    } else {
                        callBack(false)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        callBack(true)
                    } else {
                        callBack(false)
                    }
                }
            }
        } else {
            callBack(true)
        }
    }
}

extension PickVideoTool : PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                //图片
            } else {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                    if let error = error {
                        print("picker video error: \(error)")
                        self?.callBack?(false, nil)
                        return
                    }
                    if let url = url {
                        let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                        let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                        try? FileManager.default.copyItem(at: url, to: newUrl)
                        DispatchQueue.main.async {
                            self?.callBack?(true, newUrl)
                        }
                    } else {
                        self?.callBack?(false, nil)
                    }
                    
                }
            }
        }
    }
    
    
}
