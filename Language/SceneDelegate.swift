//
//  SceneDelegate.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var settingsModel: UserSettingsStorageProtocol!
    var dataModel: Dictionary_Words_LogsManager!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions){
        
        //Creating observer for changing tabBar string values
        self.observeLanguageChange()
        self.checkAppVersionAccessability()
        //Creating data model, which will be stored in viewModel factory class.
        settingsModel = UserSettings()
        dataModel = CoreDataHelper(settingsModel: settingsModel)
        
        
        //Initializing TabBarController
        guard let window = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: window.coordinateSpace.bounds)
        self.window?.windowScene = window
        self.window?.rootViewController = setUpTabBarController(viewModelFactory: configureViewModelFactoryWith(dataModel, settingsModel: settingsModel))
        //Method called at this point to apply changes to the existing UIScene
        
        
        self.validateInitialSettings(settings: settingsModel)
        self.validateFirstLaunch(settings: settingsModel, dataModel: dataModel)

        self.window?.makeKeyAndVisible()
        
        
        var animationView: LaunchAnimation? = LaunchAnimation(bounds: UIWindow().bounds, interfaceStyle: settingsModel.appTheme.userInterfaceStyle)
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
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBar.dictionaries"),
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")?.withTintColor(.black))
        let secondVC = SearchView(factory: viewModelFactory)
        let secondNC = UINavigationController(rootViewController: secondVC)
        secondNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBar.search"),
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage:
                UIImage(systemName: "magnifyingglass")?.withTintColor(.black))
        let thirdVC = SettingsVC(factory: viewModelFactory)
        let thirdNC = CustomNavigationController(rootViewController: thirdVC)
        thirdVC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBar.settings"),
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
    func checkAppVersionAccessability(){
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
               let versionAndBuild = version + "." + build
               UserDefaults.standard.set(versionAndBuild, forKey: "app_version")
               UserDefaults.standard.synchronize()
            }
    }
    func configureViewModelFactoryWith(_ dataModel: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol) -> ViewModelFactory {
        return ViewModelFactory(dataModel: dataModel, settingsModel: settingsModel)
    }
    func validateFirstLaunch(settings: UserSettingsStorageProtocol, dataModel: DictionaryManaging){
        if settings.appLaunchStatus.isFirstLaunch {
            do {
                try dataModel.createDictionary(language: "tutorial.card.name".localized, text: "tutorial.card.title".localized + settings.appSeparators.value + "tutorial.card.message".localized)
            } catch {
                print("This is for the developer. He checked every inch, but failed at the very begining")
            }
        }
    }
    func validateInitialSettings(settings: UserSettingsStorageProtocol){
        let systemLangauge = UserDefaults.standard.array(forKey: "AppleLanguages")
        let languageKey = (systemLangauge?.first as? String)?.prefix(2)
        let languageCode = String(languageKey ?? "en")
        
        self.window?.overrideUserInterfaceStyle = settings.appTheme.userInterfaceStyle

        guard languageCode == settings.appLanguage.languageCode else {
            switch languageCode {
            case "uk": settings.reload(newValue: .language(.ukrainian))
            case "ru": settings.reload(newValue: .language(.russian))
            default: settings.reload(newValue: .language(.english))
            }
            return
        }
        LanguageChangeManager.shared.changeLanguage(to: languageCode)
        
    }
        
    func observeLanguageChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }
        
    @objc func languageDidChange(sender: Any){
        print("recieved language notification in AppScene")
        settingsModel.reload(newValue: .notifications(settingsModel.appNotifications))
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            print("successfully extracted tabBarController")
            if let tabBarItems = tabBarController.tabBar.items {
                
                print("successfully extract barItems")
                for (index, item) in tabBarItems.enumerated(){
                    item.title = {
                        switch index {
                        case 0: return "tabBar.dictionaries".localized
                        case 1: return "tabBar.search".localized
                        case 2: return "tabBar.settings".localized
                        default: return ""
                        }
                    }()
                }
            }
        }
    }
}

