import AVFoundation
import AVKit
import MediaAccessibility
import React
import Foundation

#if os(iOS)
class RCTPictureInPicture: NSObject, AVPictureInPictureControllerDelegate {
    private var _onPictureInPictureStatusChanged: RCTDirectEventBlock?
    private var _onRestoreUserInterfaceForPictureInPictureStop: RCTDirectEventBlock?
    private var _restoreUserInterfaceForPIPStopCompletionHandler:((Bool) -> Void)? = nil
    private var _pipController:AVPictureInPictureController?
    private var _isActive:Bool = false

    init(_ onPictureInPictureStatusChanged: RCTDirectEventBlock?, _ onRestoreUserInterfaceForPictureInPictureStop: RCTDirectEventBlock?) {
        _onPictureInPictureStatusChanged = onPictureInPictureStatusChanged
        _onRestoreUserInterfaceForPictureInPictureStop = onRestoreUserInterfaceForPictureInPictureStop
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        guard let _onPictureInPictureStatusChanged = _onPictureInPictureStatusChanged else { return }
        
        _onPictureInPictureStatusChanged([ "isActive": NSNumber(value: true)])
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        guard let _onPictureInPictureStatusChanged = _onPictureInPictureStatusChanged else { return }
        
        _onPictureInPictureStatusChanged([ "isActive": NSNumber(value: false)])
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        assert(_restoreUserInterfaceForPIPStopCompletionHandler == nil, "restoreUserInterfaceForPIPStopCompletionHandler was not called after picture in picture was exited.")
        
        guard let _onRestoreUserInterfaceForPictureInPictureStop = _onRestoreUserInterfaceForPictureInPictureStop else { return }
        
        _onRestoreUserInterfaceForPictureInPictureStop([:])
        
        _restoreUserInterfaceForPIPStopCompletionHandler = completionHandler
    }
    
    func setRestoreUserInterfaceForPIPStopCompletionHandler(_ restore:Bool) {
        guard let _restoreUserInterfaceForPIPStopCompletionHandler = _restoreUserInterfaceForPIPStopCompletionHandler else { return }
        _restoreUserInterfaceForPIPStopCompletionHandler(restore)
        self._restoreUserInterfaceForPIPStopCompletionHandler = nil
    }
    
    func setupPipController(_ playerLayer: AVPlayerLayer?) {
        debugPrint("RCTVideo: well..")
        debugPrint("RCTVideo: playerLayer \(playerLayer)")
        debugPrint("RCTVideo: playerLayer boolean \(playerLayer != nil)")
        debugPrint("RCTVideo: supported..\(AVPictureInPictureController.isPictureInPictureSupported())")
        debugPrint("RCTVideo: _isActive..\(_isActive)")

        let willEnterPictureInPicture = ( playerLayer != nil ) && AVPictureInPictureController.isPictureInPictureSupported()

        debugPrint("RCTVideo: willEnterPictureInPicture \(willEnterPictureInPicture)")

        guard willEnterPictureInPicture else { return }

        debugPrint("RCTVideo: it is supported")
        // Create new controller passing reference to the AVPlayerLayer
        _pipController = AVPictureInPictureController(playerLayer:playerLayer!)
        _pipController?.delegate = self
    }
    
    func setPictureInPicture(_ isActive:Bool) {
        debugPrint("RCTVideo: setPictureInPicture: isActive \(isActive)")
        if _isActive == isActive {
            return
        }
        _isActive = isActive
        
        guard let _pipController = _pipController else { return }
        
        if _isActive && !_pipController.isPictureInPictureActive {
            DispatchQueue.main.async(execute: {
                _pipController.startPictureInPicture()
            })
        } else if !_isActive && _pipController.isPictureInPictureActive {
            DispatchQueue.main.async(execute: {
                _pipController.stopPictureInPicture()
            })
        }
    }
}
#endif
