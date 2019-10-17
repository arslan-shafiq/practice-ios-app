//
//  PhotosHelper.swift
//

import Photos

/**
 Enum containing results of `getAssets(...)`, `getImages(...)` etc. calls. Depending on options can contain an array of assets or a single asset. Contains an empty error if something goes wrong.
 
 - Assets: Contains an array of assets. Will be called only once.
 - Asset:  Contains a single asset. If options.synchronous is set to `false` can be called multiple times by the system.
 - Error:  Error fetching images.
 */
public enum AssetFetchResult<T> {
    case Assets([T])
    case Asset(T)
    case Error
}

/**
 *  A set of methods to create albums, save and retrieve images using the Photos Framework.
 */
public struct PhotosHelper {
    
    /**
     *  Define order, amount of assets and - if set - a target size. When count is set to zero all assets will be fetched. When size is not set original assets will be fetched.
     */
    public struct FetchOptions {
        public var count: Int
        public var newestFirst: Bool
        public var size: CGSize?
        
        public init() {
            self.count = 0
            self.newestFirst = true
            self.size = nil
        }
    }
    
    /// Default options to pass when fetching images. Fetches only images from the device (not from iCloud), synchronously and in best quality.
    public static var defaultImageFetchOptions: PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = false
        options.isSynchronous = true
        
        return options
    }
    
    
    
    /**
     Try to retrieve images from a Photos album with a specified name.
     
     - parameter named:        Name of the album.
     - parameter options:      Define how the images will be fetched.
     - parameter fetchOptions: Define order and amount of images.
     - parameter completion:   Called in the background when images were retrieved or in case of any error.
     */
    public static func getImagesFromAlbum(named: String, options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<UIImage>) -> ()) {
        DispatchQueue.global().async() {
            let albumFetchOptions = PHFetchOptions()
            albumFetchOptions.predicate = NSPredicate(format: "(estimatedAssetCount > 0) AND (localizedTitle == %@)", named)
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: albumFetchOptions)
            guard let album = albums.firstObject else { return completion(.Error) }
            
            PhotosHelper.getImagesFromAlbum(album: album, options: options, completion: completion)
        }
    }
    
    
    /**
     Try to retrieve images from a Photos album.
     
     - parameter options:      Define how the images will be fetched.
     - parameter fetchOptions: Define order and amount of images.
     - parameter completion:   Called in the background when images were retrieved or in case of any error.
     */
    public static func getImagesFromAlbum(album: PHAssetCollection, options: PHImageRequestOptions = defaultImageFetchOptions, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<UIImage>) -> ()) {
        DispatchQueue.global().async() {
            PhotosHelper.getAssetsFromAlbum(album: album, fetchOptions: fetchOptions, completion: { result in
                switch result {
                case .Asset: ()
                case .Error: completion(.Error)
                case .Assets(let assets):
                    let imageManager = PHImageManager.default()
                    
                    assets.forEach { asset in
                        
                        imageManager.requestImage(
                            for: asset,
                            targetSize: fetchOptions.size ?? CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                            contentMode: .aspectFill,
                            options: options,
                            resultHandler: { image, _ in
                                guard let image = image else { return }
                                completion(.Asset(image))
                        })
                    }
                }
            })
        }
    }
    
    
    
    /**
     Try to retrieve assets from a Photos album.
     
     - parameter options:      Define how the assets will be fetched.
     - parameter fetchOptions: Define order and amount of assets. Size is ignored.
     - parameter completion:   Called in the background when assets were retrieved or in case of any error.
     */
    public static func getAssetsFromAlbum(album: PHAssetCollection, fetchOptions: FetchOptions = FetchOptions(), completion: @escaping (_ result: AssetFetchResult<PHAsset>) -> ()) {
        DispatchQueue.global().async() {
            let assetsFetchOptions = PHFetchOptions()
            assetsFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !fetchOptions.newestFirst)]
            
            var assets = [PHAsset]()
            
            let fetchedAssets = PHAsset.fetchAssets(in: album, options: assetsFetchOptions)
            
            let rangeLength = min(fetchedAssets.count, fetchOptions.count)
            let range = NSRange(location: 0, length: fetchOptions.count != 0 ? rangeLength : fetchedAssets.count)
            let indexes = NSIndexSet(indexesIn: range)
            
            fetchedAssets.enumerateObjects(at: indexes as IndexSet, options: []) { asset, index, stop in
                guard let asset = asset as? PHAsset else { return completion(.Error) }
                assets.append(asset)
            }
            
            completion(.Assets(assets))
        }
    }
    
    
    /**
     Retrieve all albums from the Photos app.
     
     - parameter completion: Called in the background when all albums were retrieved.
     */
    public static func getAlbums(completion: @escaping (_ albums: [PHAssetCollection]) -> ()) {
        DispatchQueue.global().async() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
            
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            
            var result = Set<PHAssetCollection>()
            
            [albums, smartAlbums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    guard let album = collection as? PHAssetCollection else { return }
                    result.insert(album)
                }
            }
            
            completion(Array<PHAssetCollection>(result))
        }
    }
    
    public static func isImageExist(albumName: String, fileName: String) -> Bool {
        let directoryPath =  NSHomeDirectory().appending("/Documents/")
        let filePath = directoryPath + "/" + albumName + "/" + fileName
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    public static func isFileExistInDocuments(fileName: String) -> Bool {
        let finalFileName = NSHomeDirectory().appending("/Documents/") + "/" + fileName
        return FileManager.default.fileExists(atPath: finalFileName)
    }
    
    public static func saveImageToDocumentDirectory(_ chosenImage: UIImage, albumName: String, fileName: String) -> String {
        var directoryPath =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        directoryPath = directoryPath + "/" + albumName + "/"
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
//        let filename = NSDate().string(withDateFormatter: yyyytoss).appending(".jpg")
        let filepath = directoryPath.appending(fileName)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try UIImageJPEGRepresentation(chosenImage, 1.0)?.write(to: url, options: .atomic)
            
//            let photo = PhotoDH()
//            photo.albumName = albumName
//            photo.fileName = fileName
//            photo.image = nil
//            photo.isLocked = false
//            CoreDataTalker.shared.savePhoto(photo: photo)
            
            return String.init("/Documents/\(fileName)")
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return filepath
        }
        
        
        
    }
    
    
    
    public static func getUIImageFromAsset(asset: PHAsset, albumName: String) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        let fileName: String = (PHAssetResource.assetResources(for: asset).first?.originalFilename)!
        
        PhotosHelper.saveImageToDocumentDirectory(img!, albumName: albumName, fileName: fileName)
        return img
    }
    
    
    public static func getImageFromAsset(asset: PHAsset) -> UIImage{
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img!
        
    }
    
    public static func getFileNameFromAsset(asset: PHAsset) -> String {
        let fileName: String = (PHAssetResource.assetResources(for: asset).first?.originalFilename)!
        return fileName
    }
    
}
