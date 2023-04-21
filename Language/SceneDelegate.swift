//
//  SceneDelegate.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UserSettings.shared.use()
        //Initializing TabBarController
        guard let window = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: window.coordinateSpace.bounds)
        self.window?.windowScene = window
        self.window?.rootViewController = setUpTabBarController()
        self.window?.makeKeyAndVisible()
        UserSettings.shared.use()
        var animationView: LaunchAnimation? = LaunchAnimation(bounds: UIWindow().bounds)
        animationView?.animate()
        animationView?.makeKeyView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            animationView?.animationView.removeFromSuperview()
            animationView = nil
        }
        self.window?.makeKeyAndVisible()
    }
    //MARK: - TabBar SetUp
    func setUpTabBarController() -> UITabBarController{
        let tabBArController = UITabBarController()
        
        let firstVC = MenuVC()
        let firstNC = UINavigationController(rootViewController: firstVC)
        firstNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarDictionaries"),
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")?.withTintColor(.black))
        let secondVC = SearchVC()
        let secondNC = UINavigationController(rootViewController: secondVC)
        secondNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarSearch"),
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage:
                UIImage(systemName: "magnifyingglass")?.withTintColor(.black))
        let thirdVC = SettingsVC()
        let thirdNC = UINavigationController(rootViewController: thirdVC)
        thirdVC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarSettings"),
            image:  UIImage(systemName: "gearshape"),
            selectedImage:
                UIImage(systemName: "gearshape.fill")?.withTintColor(.black))
        
        
        tabBArController.setViewControllers([firstNC, secondNC, thirdNC], animated: true)
        tabBArController.tabBar.tintColor = .label
        return tabBArController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

