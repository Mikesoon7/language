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
        let licence = Bundle(path: "DerivedData/Language-daobatilxvykmwbzbylpybzcnehc/SourcePackages/checkouts/Charts/LICENSE")
        UserDefaults.standard.set(licence, forKey: "licence")
        let string = String(localized: "", bundle: licence)
        print(string)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
    
}

