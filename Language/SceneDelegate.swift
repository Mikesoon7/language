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

        //Creating observer for changing tabBar string values
        self.observeLanguageChange()
        //Creating data model, which will be stored in viewModel factory class.
        let dataModel: Dictionary_Words_LogsManager = CoreDataHelper.shared
        let settingsModel: UserSettings = UserSettings.shared
        
        
        //Initializing TabBarController
        guard let window = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: window.coordinateSpace.bounds)
        self.window?.windowScene = window
        self.window?.rootViewController = setUpTabBarController(viewModelFactory: configureViewModelFactoryWith(dataModel, settingsModel: settingsModel))
        //Method called at this point to apply changes to the existing UIScene
        
        self.use(theme: settingsModel.appTheme, language: settingsModel.appLanguage)
        self.window?.makeKeyAndVisible()
        
        var animationView: LaunchAnimation? = LaunchAnimation(bounds: UIWindow().bounds, interfaceStyle: UserSettings.shared.appTheme.userInterfaceStyle)
        animationView?.animate()
        animationView?.makeKeyView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            animationView?.animationView.removeFromSuperview()
            animationView = nil
        }
        
        self.window?.makeKeyAndVisible()
    }
    //MARK: - TabBar SetUp
    func setUpTabBarController(viewModelFactory: ViewModelFactory ) -> UITabBarController{
        let tabBArController = UITabBarController()
        tabBArController.tabBar.backgroundColor = .systemBackground
        
        let firstVC = MenuView(factory: viewModelFactory)
        let firstNC = UINavigationController(rootViewController: firstVC)
        firstNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarDictionaries"),
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")?.withTintColor(.black))
        let secondVC = SearchView(factory: viewModelFactory)
        let secondNC = UINavigationController(rootViewController: secondVC)
        secondNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarSearch"),
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage:
                UIImage(systemName: "magnifyingglass")?.withTintColor(.black))
        let thirdVC = SettingsVC(factory: viewModelFactory)
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
    func configureViewModelFactoryWith(_ dataModel: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol) -> ViewModelFactory {
        return ViewModelFactory(dataModel: dataModel, settingsModel: settingsModel)
    }
    func configureUserStorage(with storage: UserSettings? = nil){
        if let settings = storage {
            UserSettings.shared = settings
        }
    }
    func use(theme: AppTheme, language: AppLanguage){
        LanguageChangeManager.shared.changeLanguage(to: language.languageCode)
        self.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
    }
    

//    func configureStorage(with storage: UserSettingsStorageProtocol = UserSettings1(manager: UserSettingsManager())) -> UserSettingsStorageProtocol{
//        return storage
//    }
    
    func observeLanguageChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
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
    
    @objc func languageDidChange(sender: Any){
        print("recieved language notification in AppScene")
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            print("successfully extracted tabBarController")
            if let tabBarItems = tabBarController.tabBar.items {
                
                print("successfully extract barItems")
                for (index, item) in tabBarItems.enumerated(){
                    item.title = {
                        switch index {
                        case 0: return "tabBarDictionaries".localized
                        case 1: return "tabBarSearch".localized
                        case 2: return "tabBarSettings".localized
                        default: return ""
                        }
                    }()
                }
            }
        }
    }
}

