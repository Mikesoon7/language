//
//  AppDelegate.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCoreDataObserver()
        DispatchQueue.main.async {
            let _ = UIReferenceLibraryViewController(term: "preloading")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    //MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
//        let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("LearnyLocal.sqlite")
//
//            do {
//                try FileManager.default.removeItem(at: url)
//            } catch {
//                print("Could not clear old persistent store: \(error)")
//            }
        let container = NSPersistentContainer(name: "LearnyLocal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func setupCoreDataObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(coreDataObjectsDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: persistentContainer.viewContext)
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
        UserSettings.shared.save()
    }
    @objc func coreDataObjectsDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let insert = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insert.isEmpty {
            NotificationCenter.default.post(name: .appDataDidChange, object: nil, userInfo: ["changeType": NSManagedObject.ChangeType.insert])
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updates.isEmpty {
            NotificationCenter.default.post(name: .appDataDidChange, object: nil, userInfo: ["changeType": NSManagedObject.ChangeType.update])
        }


        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deletes.isEmpty {
            NotificationCenter.default.post(name: .appDataDidChange, object: nil, userInfo: ["changeType": NSManagedObject.ChangeType.delete])
        }
    }
}

