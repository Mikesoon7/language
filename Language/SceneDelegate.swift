//
//  SceneDelegate.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.

// MARK: - - - -

//I've tried to use dependence injection in my project, since i'm planning to upgrade storage for iCloud synchronization.
//And it's just the right pattern to use.

// MARK: - - - - -


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var settingsModel: UserSettingsStorageProtocol!
    var dataModel: DictionaryFullAccess!
    var animationView: LaunchAnimation?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions){
        //1. Initializing settings and data model for futhe dependence injection.
        self.setUpDataModels()
                
        //2. Initializing window.
        guard let window = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: window.coordinateSpace.bounds)
        self.window?.windowScene = window
        self.window?.makeKeyAndVisible()
        
        
        //3. Applying theme and language settings for created window.
        self.validateInitialSettings(settings: settingsModel)
        
        //4. Creating tabBarController.
        self.window?.rootViewController = setUpTabBarController(viewModelFactory: configureViewModelFactoryWith(dataModel, settingsModel: settingsModel))
        
        //5. If it's the first launch, creating dictioanry with greeting card.
        self.validateFirstLaunch(settings: settingsModel, dataModel: dataModel)

        //6. Presenting view with launch aimation.
        self.launchAnimation(for: window)
        //7.Creating observers on language change for tabBar.
        self.postLaunchSetUp()
    }
    
    
    //MARK: TabBar SetUp
    private func setUpTabBarController(viewModelFactory: ViewModelFactory ) -> UITabBarController{
        
        let tabBarController: UITabBarController = {
            let controller = UITabBarController()
            controller.tabBar.tintColor = .label
            controller.tabBar.backgroundColor = .systemBackground
            controller.tabBar.isTranslucent = false
            controller.tabBar.shadowImage = UIImage()
            controller.tabBar.backgroundImage = UIImage()
            return controller
        }()
        
        let firstVC = MenuView(factory: viewModelFactory)
        let firstNC = CustomNavigationController(rootViewController: firstVC)
        firstNC.tabBarItem = UITabBarItem(
            title: LanguageChangeManager.shared.localizedString(forKey: "tabBar.dictionaries"),
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")?.withTintColor(.black))
        let secondVC = SearchView(factory: viewModelFactory)
        let secondNC = CustomNavigationController(rootViewController: secondVC)
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
                
        return tabBarController
    }
    
    //MARK: System
    private func configureViewModelFactoryWith(_ dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol) -> ViewModelFactory {
        return ViewModelFactory(dataModel: dataModel, settingsModel: settingsModel)
    }

    private func setUpDataModels(){
        settingsModel = UserSettings()
        dataModel = CoreDataHelper(settingsModel: settingsModel)
    }
    
    private func postLaunchSetUp(){
        self.observeLanguageChange()
        self.checkAppVersionAccessability()
    }
    private func launchAnimation(for window: UIWindowScene){
        let animationView: LaunchAnimation? = LaunchAnimation(window: window.keyWindow , bounds: window.coordinateSpace.bounds, interfaceStyle: settingsModel.appTheme.userInterfaceStyle, delegate: self)
        animationView?.animate()
        animationView?.makeKeyView()
        self.animationView = animationView
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            animationView?.animationView.removeFromSuperview()
//            animationView = nil
//        }
    }

    //MARK: Settings related customization
    private func checkAppVersionAccessability(){
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
               let versionAndBuild = version + "." + build
               UserDefaults.standard.set(versionAndBuild, forKey: "app_version")
               UserDefaults.standard.synchronize()
            }
    }
    private func validateFirstLaunch(settings: UserSettingsStorageProtocol, dataModel: DictionaryManaging){
        if settings.appLaunchStatus.isFirstLaunch {
            do {
                try dataModel.createDictionary(language: "tutorial.card.name".localized, text: "tutorial.card.title".localized + settings.appSeparators.value + "tutorial.card.message".localized)
            } catch {
                print("This is for the developers. It seems, that author checked to the inch, but failed at the very begining")
            }
        }
    }
    
    //Since user can change the language throught apps section in settings, we need to track this changes by comparing values in UserDefaults and custom settings storage class.
    private func validateInitialSettings(settings: UserSettingsStorageProtocol){
        let systemLangauge = UserDefaults.standard.array(forKey: "AppleLanguages")
        let languageKey = (systemLangauge?.first as? String)?.prefix(2)
        let languageCode = String(languageKey ?? "en")
        
        self.window?.overrideUserInterfaceStyle = settings.appTheme.userInterfaceStyle

        guard languageCode == settings.appLanguage.languageCode else {
            switch languageCode {
            case "tr": settings.reload(newValue: .language(.turkish))
            case "ua": settings.reload(newValue: .language(.ukrainian))
            case "ru": settings.reload(newValue: .language(.russian))
            default: settings.reload(newValue: .language(.english))
            }
            return
        }
        LanguageChangeManager.shared.changeLanguage(to: languageCode)
        
    }
        
    private func observeLanguageChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }
        
    //MARK: Actions
    @objc func languageDidChange(sender: Any){
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            if let tabBarItems = tabBarController.tabBar.items {
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
extension SceneDelegate: LaunchAnimationDelegate{
    func animationDidFinish(animationView: UIView?) {
        self.animationView?.animationView.removeFromSuperview()
        self.animationView = nil
        NotificationCenter.default.post(name: .appDidFinishLaunchAnimation, object: nil)
    }
}


