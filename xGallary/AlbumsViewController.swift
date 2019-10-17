//
//  ViewController.swift
//  xGallary
//
//  Created by Arslan on 03/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit
import Photos
import MaterialComponents.MaterialBottomAppBar
import SmileLock
import CoreData
import MBProgressHUD

class AlbumsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PasswordResponseDelegate{
    
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var collectionGridImages: UICollectionView!
    
    var loadingNotification: MBProgressHUD? = nil
    
    var arr_albums: [AlbumDH] = []
    var currentIndex: Int = -1
    var button = UIButton()
    var currentFunction: Int = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionGridImages.delegate  = self
        self.collectionGridImages.dataSource = self
        
        setPassword()
        setupPermissions()
        initUI()
        loadViewManually()
    }
    
    private func setupPermissions() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized) {
            print("Authorized")
        } else if (status == .denied) {
            print("Permission denied")
        } else if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    print("Now permission authorized")
                    self.setupPhotos()
                    break
                case .denied:
                    print("Now permission denied")
                    break
                default:
                    print("Default")
                    break
                }
            })
        }
    }
    
    private func setPassword() {
        
        let password = UserDefaults.standard.string(forKey: kStrPasswordKey)
        if (password != nil) {
            kPassword = password!
        } else {
            print("Password not set")
            btnSettingsTapped()
        }
    }
    
    private func loadViewManually() {
        self.arr_albums = CoreDataTalker.shared.getAllAlbums()
        if (self.arr_albums.count < 1) {
            setupPhotos()
        } else {
            self.arr_albums = self.arr_albums.sorted(by: { $0.albumName < $1.albumName })
        }
    }
    
    //MARK: Initiating UI
    private func initUI() {
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
//        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let settings = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(btnSettingsTapped))
        let sync = UIBarButtonItem(image: #imageLiteral(resourceName: "sync"), style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [sync]
        navigationItem.leftBarButtonItems = [settings]
        
        // Transparent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @objc private func addTapped() {
        addNewPhotos()
    }
    
    @objc private func btnSyncTapped() {
        print ("sync tapped")
    }
    
    //MARK: Settings Action
    @objc private func btnSettingsTapped() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    //MARK: Adding Custom View From
    private func addCustomHeader() {
        let view = XHeaderView.instanceFromNib()
        let header = (view as! XHeaderView)
//        header.delegate = self
        header.setTitle(title: "Albums")
        header.setRightButtonLabel(strLabel: "Sync")
        
//        header.btnBack.setImage(UIImage(named: "setting"), for: .normal)
        header.btnBack.backgroundRect(forBounds: header.btnBack.bounds)
        header.btnBack.setImage(UIImage(named: "setting"), for: .normal)
        
        self.viewHeader.addSubview(view)
    }
    
    //MARK: Fetching All Albums
    private func setupPhotos() {
        self.performSelector(onMainThread: #selector(showLoadingDialog), with: nil, waitUntilDone: true)
        // Working fine
        PhotosHelper.getAlbums(completion: { albums in
            if (albums.count > 0) {
                for album in albums {
                    
                    let opt = PHFetchOptions()
                    let allPhotos = PHAsset.fetchAssets(in: album, options: opt)
                    
                    if (allPhotos.count > 0) {
                        let albumDH = AlbumDH()
                        albumDH.albumName = album.localizedTitle!
                        albumDH.isLocked = false
                        
                        for i in 0...allPhotos.count - 1 {
                            let img = PhotosHelper.getImageFromAsset(asset: allPhotos[i])
                            let fileName = PhotosHelper.getFileNameFromAsset(asset: allPhotos[i])
                            let photoDH = PhotoDH()
                            photoDH.image = img
                            photoDH.fileName = fileName
                            photoDH.albumName = album.localizedTitle!
                            photoDH.isLocked = false
                            if (i == 0) {
                                albumDH.thumnail = img
                            }
                            photoDH.isThumbnail = false
                            
                            CoreDataTalker.shared.savePhoto(photo: photoDH)
                        }
                        self.arr_albums.append(albumDH)
                        CoreDataTalker.shared.saveAlbum(album: albumDH)
                    }
                }
                self.performSelector(onMainThread: #selector(self.HideLoadingDialog), with: nil, waitUntilDone: true)
                DispatchQueue.main.async {
                    self.arr_albums = self.arr_albums.sorted(by: { $0.albumName < $1.albumName })
                    self.collectionGridImages.reloadData()
                    // This also works
                    // self.reloadMainThread()
                }
            }
        })
    }
    
    // Just for reference
    private func reloadMainThread() {
        self.performSelector(onMainThread: #selector(reloadCollection), with: nil, waitUntilDone: true)
    }
    
    @objc private func reloadCollection() {
        self.collectionGridImages.reloadData()
    }
    
    @objc private func showLoadingDialog() {
        self.showLoading()
    }
    
    @objc private func HideLoadingDialog() {
        self.hideLoading()
    }
    
    //MARK: whateverr
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionGridCell", for: indexPath) as! CollectionGridCell
        
        let album = arr_albums[indexPath.row]
        cell.setAlbumThumb(thumb: album.thumnail)
        cell.setAlbumTitle(title: album.albumName)
        let btnLock = cell.btnLock
        btnLock?.tag = indexPath.row
        btnLock?.addTarget(self, action: #selector(btnLockTap), for: .touchUpInside)
        
        var image: UIImage
        if (album.isLocked) {
            image = UIImage(named: "lock")!
            cell.blueView.isHidden = false
        } else {
            image = UIImage(named: "unlock")!
            cell.blueView.isHidden = true
        }
        btnLock?.setBackgroundImage(image, for: .normal)
        
        return cell
    }
    
    //MARK: Lock button on every Album
    @objc func btnLockTap(sender: UIButton!) {
        let index = sender.tag as Int
        
        let lockWithoutPassword = UserDefaults.standard.bool(forKey: kStrUsePasswordToLock)
        
        if (self.arr_albums[index].isLocked || !lockWithoutPassword) {
            self.currentIndex = index
            self.button = sender
            self.currentFunction = 0
            showPasswordScreen(strTitle: "Enter PIN")
        } else {
            self.lockAlbum(index: index)
        }
    }
    
    private func showPasswordScreen(strTitle: String) {
        let loginVCID = "BlurPasswordLoginViewController"
        present(loginVCID, strTitle)
    }
    
    func present(_ id: String, _ strTitle: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id) as! BlurPasswordLoginViewController
        loginVC.delegate = self
        loginVC.strTitle = strTitle
        loginVC.modalPresentationStyle = .overCurrentContext
        present(loginVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionGridImages.frame.size.width/2 - 2

        return CGSize(width: size, height: size)
    }
    
    private func showLoading() {
        if (self.loadingNotification == nil) {
            self.loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            self.loadingNotification!.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification!.label.text = "Loading"
        } else {
            self.loadingNotification?.show(animated: true)
        }
    }
    
    private func hideLoading() {
        if (self.loadingNotification != nil) {
            self.loadingNotification?.hide(animated: true)
        }
    }
    
    //MARK: Sync photos from Albums
    func addNewPhotos() {
        self.performSelector(onMainThread: #selector(showLoadingDialog), with: nil, waitUntilDone: true)
        var isUpdated = false
        PhotosHelper.getAlbums(completion: { albums in
            if (albums.count > 0) {
                for album in albums {
                    let opt = PHFetchOptions()
                    let allPhotos = PHAsset.fetchAssets(in: album, options: opt)
                    if (allPhotos.count > 0) {
                        for i in 0...allPhotos.count - 1 {
                            let fileName = (PHAssetResource.assetResources(for: allPhotos[i]).first?.originalFilename)!
                            if (!CoreDataTalker.shared.isPhotoExist(albumName: album.localizedTitle!, fileName: fileName)) {
                                isUpdated = true
                                
                                let img = PhotosHelper.getImageFromAsset(asset: allPhotos[i])
                                let photoDH = PhotoDH()
                                photoDH.image = img
                                photoDH.fileName = fileName
                                photoDH.albumName = album.localizedTitle!
                                photoDH.isLocked = false
                                photoDH.isThumbnail = false
                                
                                CoreDataTalker.shared.savePhoto(photo: photoDH)
                            }
                            
                        }
                        if (!CoreDataTalker.shared.isAlbumExist(albumName: album.localizedTitle!)) {
                            let albumDH = AlbumDH()
                            albumDH.albumName = album.localizedTitle!
                            albumDH.isLocked = false
                            let img = PhotosHelper.getImageFromAsset(asset: allPhotos[0])
                            albumDH.thumnail = img
                            CoreDataTalker.shared.saveAlbum(album: albumDH)
                            self.arr_albums.append(albumDH)
                        }
                    }
                    
                }
                self.performSelector(onMainThread: #selector(self.HideLoadingDialog), with: nil, waitUntilDone: true)
                if (isUpdated) {
                    DispatchQueue.main.async {
                       self.arr_albums = self.arr_albums.sorted(by: { $0.albumName < $1.albumName })
                        self.collectionGridImages.reloadData()
                    }
                }
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = self.arr_albums[indexPath.row]
        if (album.isLocked) {
            self.currentIndex = indexPath.row
            self.currentFunction = 1
            showPasswordScreen(strTitle: "Enter PIN")
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
            resultViewController.albumName = album.albumName
            self.navigationController?.pushViewController(resultViewController, animated: true)
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        print("input completed -> \(input)")
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            //authentication success
        } else {
            passwordContainerView.clearInput()
        }
    }
    
    func blurPasswordIsBeingDismissed() {
        AlertHelper.showOKAllert(title: "Warning", message: "Invalid Password", style: .default, VC: self)
    }
    
    func onResult(result: Bool) {
        if (!result) {
            return
        }
        if (self.currentFunction == 0) {
            self.lockAlbum(index: self.currentIndex)
        } else if (self.currentFunction == 1) {
            
            let index = self.currentIndex
            let album = arr_albums[index]
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
            resultViewController.albumName = album.albumName
            self.navigationController?.pushViewController(resultViewController, animated: true)
        }
        
    }
    
    private func lockAlbum(index: Int) {
        let album = self.arr_albums[index]
        if (album.isLocked) {
            album.isLocked = false
        } else {
            album.isLocked = true
        }
        CoreDataTalker.shared.updateAlbum(album: album)
        self.collectionGridImages.reloadData()
    }

}

