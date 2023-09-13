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
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .systemBackground
        
        let firstVC = MenuView(factory: viewModelFactory)
        let firstNC = CustomNavigationController(rootViewController: firstVC)
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
        let thirdNC = CustomNavigationController(rootViewController: thirdVC)
        thirdVC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBarSettings"),
            image:  UIImage(systemName: "gearshape"),
            selectedImage:
                UIImage(systemName: "gearshape.fill")?.withTintColor(.black))
        
        
        tabBarController.setViewControllers([firstNC, secondNC, thirdNC], animated: true)
        tabBarController.tabBar.tintColor = .label
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.shadowImage = UIImage()
        tabBarController.tabBar.backgroundImage = UIImage()
        
        return tabBarController
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
        
    func observeLanguageChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
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

