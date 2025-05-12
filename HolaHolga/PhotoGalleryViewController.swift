import UIKit

class PhotoGalleryViewController: UICollectionViewController {
    private var photos: [UIImage]
    private let cellIdentifier = "PhotoCell"
    
    init(photos: [UIImage]) {
        self.photos = photos
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 2, height: UIScreen.main.bounds.width / 3 - 2)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .black
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func setupNavigationBar() {
        title = "Developed Photos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save All",
            style: .plain,
            target: self,
            action: #selector(saveAllPhotos)
        )
    }
    
    @objc private func saveAllPhotos() {
        var savedCount = 0
        
        photos.forEach { photo in
            UIImageWriteToSavedPhotosAlbum(photo, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            savedCount += 1
        }
        
        let alert = UIAlertController(
            title: "Saving Photos",
            message: "Saving \(savedCount) photos to your library...",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving photo: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = photos[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewController = PhotoViewController(image: photos[indexPath.item])
        navigationController?.pushViewController(photoViewController, animated: true)
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.delegate = self
        
        scrollView.addSubview(imageView)
        imageView.frame = scrollView.bounds
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}