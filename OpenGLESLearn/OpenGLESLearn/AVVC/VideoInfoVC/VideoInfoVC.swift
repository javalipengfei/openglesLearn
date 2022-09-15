//
//  VideoInfoVC.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2022/9/14.
//

import UIKit
import AVFoundation

class VideoInfoVC: UIViewController {
    let pickVideoUtil = PickVideoTool.init()
    var asset: AVAsset!
    var playItem: AVPlayerItem!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var textView = UITextView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        let url = Bundle.main.url(forResource: "1", withExtension: "MOV")
        if let url = url {
            self.createPlayer(url: url)
        }
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        
        let infoBtn = UIButton.init(type: .custom)
        infoBtn.addTarget(self, action: #selector(getVideoInfo), for: .touchUpInside)
        infoBtn.frame = CGRect.init(x: SCREENWIDTH / 2 - 50 , y: self.view.frame.size.height - 100, width: 100, height: 50)
        infoBtn.setTitle("获取视频信息", for: .normal)
        infoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        infoBtn.backgroundColor = .red
        self.view.addSubview(infoBtn)
        
        textView.frame = CGRect.init(x: 0, y: 300, width: SCREENWIDTH, height: 300)
        textView.isEditable = false
        textView.backgroundColor = UIColor.white
        textView.textColor = .black
        self.view.addSubview(textView)
    }
    
    @objc public func pickVideoAction() {
        pickVideoUtil.checkAuthoriza { [weak self] isAuthor in
            if isAuthor {
                self?.pickVideo()
            } else {
                debugPrint("未授权")
            }
        }
    }
    
    @objc public func getVideoInfo() {
        
        textView.text = ""
        let keys = ["duration","metaData","tracks"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError?
            let status = self.asset.statusOfValue(forKey: "tracks", error: &error)
            guard error == nil else {
                return
            }
            switch status {
            case .unknown:
                debugPrint("unknow")
            case .loading:
                debugPrint("loading")
            case .loaded:
                debugPrint("loaded \(self.asset.tracks)")
                self.parseVideoInfo()
                debugPrint("loaded \(self.asset.duration)")
            case .failed:
                debugPrint("failed")
            case .cancelled:
                debugPrint("cancelled")
            @unknown default:
                debugPrint("error")
            }
        }
    }
    
    func parseVideoInfo() {
        let duration = asset.duration.value / Int64(asset.duration.timescale)
        appendInfo(info: "时间 : \(duration) 秒")
        for track in asset.tracks {
            var info = "轨道 \(track.trackID) 类别：\(trackType(track: track)) "
            if track.mediaType == .video || track.mediaType == .audio {
                info.append(contentsOf: "帧率 \(ceil(track.nominalFrameRate))")
                if track.minFrameDuration.timescale != 0 {
                    let minFrameDuration = Float(track.minFrameDuration.value) / Float(track.minFrameDuration.timescale)
                    info.append(contentsOf: "最小时间间隔 \(minFrameDuration)")
                }
            }
            appendInfo(info: info)
        }
        
        for mateFormat in asset.metadata {
            appendInfo(info: "meta信息： \(mateFormat.value)")
        }
        
    }
    
    func trackType(track: AVAssetTrack) -> String {
        let type = track.mediaType
        if type == .video {
            return "视频轨道"
        } else if type == .audio {
            return "音频轨道"
        } else if type == .text {
            return "字幕轨道"
        } else if type == .subtitle {
            return "字幕轨道"
        } else if type == .metadata {
            return "元数据轨道"
        } else {
            return "未知"
        }
    }
    
    func appendInfo(info: String) {
        var text = textView.text + "\n"
        text.append(contentsOf: info)
        textView.text = text
    }
    
    func pickVideo() {
        pickVideoUtil.pickUpVideo { [weak self](isSuccess, url) in
            if let url = url {
                self?.createPlayer(url: url)
            }
        }
    }
    
    func createPlayer(url: URL) {
        asset = AVAsset.init(url: url)
        playItem = AVPlayerItem.init(asset: asset)
        avPlayer = AVPlayer.init(playerItem: playItem)
        avPlayerLayer = AVPlayerLayer.init(player: avPlayer)
        avPlayerLayer?.frame = CGRect.init(x: 0, y: STATUSBARHEIGHT + BAR_HEIGHT, width: SCREENWIDTH, height: 200)
        avPlayerLayer.videoGravity = .resize
        self.view.layer.addSublayer(avPlayerLayer)
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
