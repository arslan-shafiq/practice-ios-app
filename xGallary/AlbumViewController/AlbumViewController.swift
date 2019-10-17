//
//  AlbumViewController.swift
//  xGallary
//
//  Created by Arslan on 05/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit
import ImageSlideshow

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PasswordResponseDelegate {
    
    public var arr_photos : [PhotoDH] = []
    public var albumName: String = ""
    var dictData = NSMutableDictionary()

    var currentIndex = -1
    var currentSelected = 0
    var selectTapped = false
    var lockFromToolbar = false
    
    
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var slideShow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        initUI()
        self.arr_photos = CoreDataTalker.shared.getAlbumPhotos(albumName: albumName)
        // Do any additional setup after loading the view.
    }
    
    private func initUI() {
//        addCustomHeader()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.title = self.albumName
    
        let select = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(btnSelectTapped))
        
        navigationItem.rightBarButtonItems = [select]
        
    }
    
    @objc private func btnSelectTapped() {
        let arr = navigationItem.rightBarButtonItems
        if (self.selectTapped == false) {
            self.selectTapped = true
            if (arr != nil) {
                arr![0].title = "Cancel"
                self.collectionView.reloadData()
            }
        } else {
            self.selectTapped = false
            if (self.currentSelected == 0) {
                if (arr != nil) {
                    arr![0].title = "Select"
                }
                self.collectionView.reloadData()
            } else {
                //here
                let lockWithoutPassword = UserDefaults.standard.bool(forKey: kStrUsePasswordToLock)
                self.lockFromToolbar = true
                if (self.arr_photos[self.currentIndex].isLocked || !lockWithoutPassword) {
                    showPasswordScreen()
                } else {
                    self.lockSelected()
                }
            }
        }
    }
    
    //MARK: Adding Custom View From
    private func addCustomHeader() {
        let view = XHeaderView.instanceFromNib()
        let header = (view as! XHeaderView)
//        header.delegate = self
        header.setTitle(title: self.albumName)
        header.setRightButtonLabel(strLabel: "Select")
        
        self.viewHeader.addSubview(view)
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! AlbumCollectionViewCell
        
        let photoDH = arr_photos[indexPath.row]
        cell.setImage(img: photoDH.image!)
        let btnLock = cell.btnLock
        let btnSelect = cell.btnSelect
        if (photoDH.isLocked) {
            cell.lockView.isHidden = false
            btnLock?.setImage(UIImage(named: "lock"), for: .normal)
            cell.blurView.isHidden = false
            cell.selectionView.isHidden = true
        } else {
            cell.lockView.isHidden = true
            btnLock?.setImage(UIImage(named: "unlock"), for: .normal)
            cell.blurView.isHidden = true
            
            if (self.selectTapped) {
                if (photoDH.isSelected) {
                    cell.btnSelect.setImage(UIImage(named: "selected-icon"), for: .normal)
                } else {
                    cell.btnSelect.setImage(UIImage(named: "not-selected-icon"), for: .normal)
                }
                cell.selectionView.isHidden = false
            } else {
                cell.selectionView.isHidden = true
            }
        }
        
        btnLock?.tag = indexPath.row
        btnLock?.addTarget(self, action: #selector(btnLockTap), for: .touchUpInside)
        
        btnSelect?.tag = indexPath.row
        btnSelect?.addTarget(self, action: #selector(btnSelectTap), for: .touchUpInside)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.collectionView.frame.size.width/3 - 2
        
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo = self.arr_photos[indexPath.row]
        if (photo.isLocked) {
            return
        }
        
        var skipCount = 0
        var arrImageSource :[ImageSource] = [ImageSource]()
        for i in 0...(self.arr_photos.count - 1) {
            if (!self.arr_photos[i].isLocked) {
                arrImageSource.append(ImageSource(image: self.arr_photos[i].image!))
            } else {
                if (i < indexPath.row) {
                    skipCount = skipCount + 1
                }
            }
        }
        self.slideShow.setImageInputs(arrImageSource)
        self.slideShow.setCurrentPage(indexPath.row - skipCount, animated: false)
        self.slideShow.presentFullScreenController(from: self)
        
    }
    
    //MARK: Lock button on every Album
    @objc func btnLockTap(sender: UIButton!) {
        self.currentIndex = sender.tag as Int
        
        let lockWithoutPassword = UserDefaults.standard.bool(forKey: kStrUsePasswordToLock)
        
        if (self.arr_photos[self.currentIndex].isLocked || !lockWithoutPassword) {
            showPasswordScreen()
        } else {
            lockSinglePhoto()
        }
    }
    
    //MARK: Cell Selection Action
    @objc func btnSelectTap(sender: UIButton!) {
        self.currentIndex = sender.tag as Int
        let photo = self.arr_photos[currentIndex]
        if (photo.isSelected) {
            self.currentSelected = self.currentSelected - 1
            photo.isSelected = false
            sender.setImage(UIImage(named: "not-selected-icon"), for: .normal)
        } else {
            self.currentSelected = self.currentSelected + 1
            photo.isSelected = true
            sender.setImage(UIImage(named: "selected-icon"), for: .normal)
        }
        
        let arr = navigationItem.rightBarButtonItems
        if (arr != nil) {
            if (self.currentSelected == 0) {
                arr![0].title = "Cancel"
            } else {
                arr![0].title = "Lock"
            }
        }
        
    }
    
    private func showPasswordScreen() {
        let passwordVC = "BlurPasswordLoginViewController"
        present(passwordVC)
    }
    
    func present(_ id: String) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: id) as! BlurPasswordLoginViewController
        loginVC.delegate = self
        loginVC.strTitle = "Enter PIN"
        // in iOS 10, the crossDissolve transtion is wired
        //        loginVC?.modalTransitionStyle = .crossDissolve
        loginVC.modalPresentationStyle = .overCurrentContext
        present(loginVC, animated: true, completion: nil)
    }
    
    func onResult(result: Bool) {
        if (!result) {
            return
        }
        
        if (!self.lockFromToolbar) {
            self.lockSinglePhoto()
        } else {
            self.lockSelected()
        }
    }
    
    private func lockSinglePhoto() {
        let index = self.currentIndex
        let photo = self.arr_photos[index]
        if (photo.isLocked) {
            photo.isLocked = false
        } else {
            photo.isLocked = true
        }
        CoreDataTalker.shared.updatePhoto(photo: photo)
        self.collectionView.reloadData()
    }
    
    private func lockSelected() {
        self.lockFromToolbar = false
        for i in 0...(self.arr_photos.count - 1) {
            
            let photo = self.arr_photos[i]
            if (photo.isSelected) {
                photo.isLocked = true
                photo.isSelected = false
                CoreDataTalker.shared.updatePhoto(photo: photo)
            }
        }
        self.collectionView.reloadData()
        let arr = navigationItem.rightBarButtonItems
        if (arr != nil) {
            arr![0].title = "Select"
        }
        self.selectTapped = false
        self.currentSelected = 0
    }
    
    private func resetPhotoSelection() {
        for i in 0...(self.arr_photos.count - 1) {
            if (self.arr_photos[i].isSelected) {
                self.arr_photos[i].isSelected = false
            }
        }
    }
    func blurPasswordIsBeingDismissed() {
        
    }
    

}
