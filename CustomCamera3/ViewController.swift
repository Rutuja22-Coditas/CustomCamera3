

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var shutterButton: UIImageView!
    @IBOutlet weak var clickedImgView: UIImageView!
    @IBOutlet weak var baseView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var imgToShow : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        let shutterImgTap = UITapGestureRecognizer(target: self, action: #selector(shutterImgTapped))
        shutterButton.addGestureRecognizer(shutterImgTap)
        shutterButton.isUserInteractionEnabled = true
        
        let clickedImgPreview = UITapGestureRecognizer(target: self, action: #selector(showImg))
        clickedImgView.addGestureRecognizer(clickedImgPreview)
        clickedImgView.isUserInteractionEnabled = true
    }

    @objc func shutterImgTapped(){
        print("button clicked")
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func showImg(){
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as? PhotoPreviewViewController
        newVC?.selectedImageView.image = imgToShow
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        clickedImgView.image = image
        imgToShow = image
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
           
           videoPreviewLayer.videoGravity = .resizeAspect
           videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraView.bounds
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
}

