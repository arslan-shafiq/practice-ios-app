//
//  CoreDataTalker.swift
//  xGallary
//
//  Created by Arslan on 12/07/2018.
//  Copyright © 2018 Arslan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTalker: NSObject {
    
    static let shared = CoreDataTalker()
    
    private override init() {
    }
    
    public func savePhoto(photo: PhotoDH) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPhoto = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context)
        newPhoto.setValue(photo.albumName, forKey: "albumName")
        newPhoto.setValue(photo.fileName, forKey: "fileName")
        if (photo.image != nil) {
            newPhoto.setValue(UIImagePNGRepresentation(photo.image!), forKey: "image")
        }
        newPhoto.setValue(photo.isLocked, forKey: "isLocked")
        newPhoto.setValue(photo.isThumbnail, forKey: "isThumbnail")
        do {
            try context.save()
        } catch {
            print("Error while saving photo")
        }
    }
    
    public func saveAlbum(album: AlbumDH) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAlbum = NSEntityDescription.insertNewObject(forEntityName: "Albums", into: context)
        newAlbum.setValue(album.albumName, forKey: "albumName")
        newAlbum.setValue(UIImagePNGRepresentation(album.thumnail), forKey: "thumnail")
        newAlbum.setValue(album.isLocked, forKey: "isLocked")
        do {
            try context.save()
        } catch {
            print("Error while saving photo")
        }
    }
    
    public func getAllAlbums() -> [AlbumDH] {
        var arr_albums = [AlbumDH]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Albums")
        request.returnsObjectsAsFaults = false
        
        
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for result in results as! [NSManagedObject]{
                    let albumName = result.value(forKey: "albumName") as? String
                    let isLocked = result.value(forKey: "isLocked") as? Bool
                    let thumbnail = result.value(forKey: "thumnail") as? Data
                    let img = UIImage(data:thumbnail!,scale:1.0)
                    let albumDH = AlbumDH()
                    albumDH.albumName = albumName!
                    albumDH.isLocked = isLocked!
                    albumDH.thumnail = img!
                    arr_albums.append(albumDH)
                }
            }
        } catch {
            return [AlbumDH]()
        }
        
        return arr_albums
    }
    
    public func getAlbumPhotos(albumName: String) -> [PhotoDH]{
        var arr_photoDH = [PhotoDH]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        // Where albumName = albumName
        request.predicate = NSPredicate(format: "albumName == %@", albumName)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                for result in results as! [NSManagedObject]{
                    let fileName = result.value(forKey: "fileName") as? String
                    let album = result.value(forKey: "albumName") as? String
                    let isLocked = result.value(forKey: "isLocked") as? Bool
                    let isThumbnail = result.value(forKey: "isThumbnail") as? Bool
                    let imageData = result.value(forKey: "image") as? Data
                    let img = UIImage(data:imageData!,scale:1.0)
                    let photoDH = PhotoDH()
                    photoDH.fileName = fileName!
                    photoDH.albumName = album!
                    photoDH.isLocked = isLocked!
                    photoDH.isThumbnail = isThumbnail!
                    photoDH.image = img
                    arr_photoDH.append(photoDH)
                }
            }
        } catch {
            return [PhotoDH]()
        }
        return arr_photoDH
        
    }
    
    public func isPhotoExist(albumName: String, fileName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        // Where albumName = albumName
        request.predicate = NSPredicate(format: "albumName == %@ AND fileName == %@", albumName, fileName)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                return true
                }
            return false
            
        } catch {
            return false
    
        }
        
    }
    
    public func isAlbumExist(albumName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Albums")
        // Where albumName = albumName
        request.predicate = NSPredicate(format: "albumName == %@ ", albumName)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                return true
            }
            return false
            
        } catch {
            return false
            
        }
        
    }
    
    public func updateAlbum(album: AlbumDH) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Albums")
        // Where albumName = albumName
        request.predicate = NSPredicate(format: "albumName == %@ ", album.albumName)
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                let object = results[0] as! NSManagedObject
                object.setValue(album.isLocked, forKey: "isLocked")
                try context.save()
            }
            
        } catch {
            print("CoreDataTalker: updateAlbum => Error")
        }
    }
    
    public func updatePhoto(photo: PhotoDH) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        // Where albumName = albumName
        request.predicate = NSPredicate(format: "albumName == %@ AND fileName == %@", photo.albumName, photo.fileName)
        do {
            let results = try context.fetch(request)
            if (results.count > 0) {
                let object = results[0] as! NSManagedObject
                object.setValue(photo.isLocked, forKey: "isLocked")
                try context.save()
            }
            
        } catch {
            print("CoreDataTalker: updateAlbum => Error")
        }
    }
    
    
    

}
