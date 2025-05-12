import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Photo Saving Completion Handler
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            print("Photo saved successfully")
        }
    }
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var shutterButton: UIButton!
    private var originalPhotos: [UIImage] = []
    private let maxPhotos = 12
    private let photoProcessor = PhotoProcessor()
    private var isRollReady = false
    private var processedPhotos: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
            setupUI()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                        self?.setupUI()
                    }
                } else {
                    self?.handleCameraPermissionDenied()
                }
            }
        case .denied, .restricted:
            handleCameraPermissionDenied()
        @unknown default:
            handleCameraPermissionDenied()
        }
    }

    private func handleCameraPermissionDenied() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Camera Access Required",
                message: "Please grant camera access in Settings to use this feature.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        do {
            guard let backCamera = AVCaptureDevice.default(for: .video) else {
                showAlert(title: "Camera Error", message: "Unable to access back camera.")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            configureSession(with: input)
        } catch {
            showAlert(title: "Camera Error", message: error.localizedDescription)
        }
    }
    
    private func configureSession(with input: AVCaptureDeviceInput) {
        photoOutput = AVCapturePhotoOutput()

        photoOutput = AVCapturePhotoOutput()

        guard captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) else {
            showAlert(title: "Camera Error", message: "Unable to configure camera session.")
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            
            if !(self?.captureSession.isRunning ?? false) {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Camera Error", message: "Failed to start camera session.")
                }
            }
        }
    }

    private func setupUI() {
        shutterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        shutterButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.maxY - 100)
        shutterButton.backgroundColor = .white
        shutterButton.layer.cornerRadius = 35
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        view.addSubview(shutterButton)
    }

    @objc private func shutterButtonTapped() {
        guard originalPhotos.count < maxPhotos else {
            print("Roll complete")
            shutterButton.isEnabled = false
            return
        }

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        originalPhotos.append(image)
        print("Photo captured: \(originalPhotos.count)/\(maxPhotos)")

        if originalPhotos.count >= maxPhotos {
            print("Roll complete")
            shutterButton.isEnabled = false
            developRoll()
        }
    }

    private func developRoll() {
        processedPhotos = originalPhotos.compactMap { photo in
            photoProcessor.processImage(photo)
        }
        
        if processedPhotos.count == maxPhotos {
            isRollReady = true
            showProcessedPhotos()
        }
    }

    private func showProcessedPhotos() {
        let alert = UIAlertController(
            title: "Roll Developed!",
            message: "Your photos are ready to view.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "View Photos", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let galleryVC = PhotoGalleryViewController(photos: self.processedPhotos)
            let navController = UINavigationController(rootViewController: galleryVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        })
        
        present(alert, animated: true)
    }
}