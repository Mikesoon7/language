//
//  Menu VC.swift
//  Language
//
//  Created by Star Lord on 10/02/2023.
//

import UIKit

class MenuVC: UIViewController {
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(TableViewCell .self, forCellReuseIdentifier: "dictCell")
        tableView.register(TableViewAddCell.self, forCellReuseIdentifier: "addCell")
        tableView.rowHeight = 104
        tableView.backgroundColor = .systemBackground
        tableView.selectionFollowsFocus = true
        return tableView
    }()
    var statisticButton : UIButton = {
        let button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(string: "Statisctic", bold: true, size: 18), for: .normal)
        return button
    }()
    
    var randomButton : UIButton = {
        let button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(string: "Random mode", bold: true, size: 18), for: .normal)
        return button
    }()
    
    var animationMainView = UIView()
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    /*
     var leftToolbarButton = UIBarButtonItem()
     var rightToolbarButton = UIBarButtonItem()
     */

    
//MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        bottomButtonCustomization()
        tableViewCustomization()
        strokeCustomization()
        setUpAnimationViews()
        runAnimation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
//MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                self.bottomStroke.strokeColor = UIColor.white.cgColor
                self.topStroke.strokeColor = UIColor.white.cgColor
            } else {
                self.bottomStroke.strokeColor = UIColor.black.cgColor
                self.topStroke.strokeColor = UIColor.black.cgColor
            }
        }
    }
//MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
//MARK: - Animation SetUp
    func setUpAnimationViews(){
        navigationController?.navigationBar.isOpaque = false
        navigationController?.navigationBar.layer.opacity = 0
        animationMainView = UIView(frame: view.bounds)
        animationMainView.backgroundColor = .systemBackground
        
        let animationView : UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            view.layer.cornerRadius = 9
            view.layer.masksToBounds = true
            return view
        }()
        
        let label: UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString().fontWithString(string: "Learny", bold: true, size: 20)
            return label
        }()
        
        view.addSubview(animationMainView)
        animationMainView.addSubview(animationView)
        animationView.addSubview(label)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 3),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width / 3),
            animationView.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor),
            
            label.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: animationView.centerXAnchor)
        ])
        
    }
    func runAnimation(){
        
        func strokeLayerFrom(_ startPoint: CGPoint, to endPoint: CGPoint, secondPoint: CGPoint?, strokeWidth: CGFloat , with color: UIColor) -> (CAShapeLayer) {
            let layer = CAShapeLayer()
            layer.strokeColor = color.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = strokeWidth
            
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            if secondPoint != nil{
                path.addLine(to: secondPoint!)
            }
            layer.path = path.cgPath
            return layer
        }
        //Screen dimentions
        let widthPont = view.bounds.width / 3
        let heightPoint = view.bounds.height / 3
        let maxY = view.bounds.maxY
        let maxX = view.bounds.maxX
        //Black to draw
        let topLeft = strokeLayerFrom(CGPoint(x: widthPont ,y: 0 ),
                                      to: CGPoint(x: widthPont, y: maxY - 109),
                                      secondPoint: CGPoint(x: view.bounds.maxX, y: maxY - 109),
                                      strokeWidth: 3,
                                      with: .label)
        let topRight = strokeLayerFrom(CGPoint(x: widthPont * 2, y: 0),
                                       to: CGPoint(x: widthPont * 2, y: maxY - 109),
                                       secondPoint: CGPoint(x: 0, y: maxY - 109),
                                       strokeWidth: 3,
                                       with: .label)
        let rightTop = strokeLayerFrom(CGPoint(x: 0, y: heightPoint),
                                       to: CGPoint(x: maxX, y: heightPoint),
                                       secondPoint: nil,
                                       strokeWidth: 3,
                                       with: .label)
        let rightBottom = strokeLayerFrom(CGPoint(x: 0, y: heightPoint + widthPont ),
                                          to: CGPoint(x: maxX , y: heightPoint + widthPont),
                                          secondPoint: nil,
                                          strokeWidth: 3,
                                          with: .label)
        
        //White to vanish
        let topLeftV = strokeLayerFrom(CGPoint(x: widthPont , y: 0 ),
                                       to: CGPoint(x: widthPont, y: maxY - 110.5),
                                       secondPoint: nil,
                                       strokeWidth: 6,
                                       with: .systemBackground)
        let topRightV = strokeLayerFrom(CGPoint(x: widthPont * 2, y: 0),
                                        to: CGPoint(x: widthPont * 2, y: maxY - 110.5),
                                        secondPoint: nil,
                                        strokeWidth: 6,
                                        with: .systemBackground)
        let rightTopV = strokeLayerFrom(CGPoint(x: 0, y: heightPoint),
                                        to: CGPoint(x: maxX, y: heightPoint),
                                        secondPoint: nil,
                                        strokeWidth: 6,
                                        with: .systemBackground)
        let rightBottomV = strokeLayerFrom(CGPoint(x: 0, y: heightPoint + widthPont ),
                                           to: CGPoint(x: maxX , y: heightPoint + widthPont),
                                           secondPoint: nil,
                                           strokeWidth: 6,
                                           with: .systemBackground)
        
        CATransaction.begin()
        
        func strokeAnimation(from: CGFloat, to: CGFloat, inSec: CFTimeInterval) -> CABasicAnimation{
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = from
            animation.toValue = to
            animation.duration = inSec
            return animation
        }
        topLeft.add(strokeAnimation(from: 0, to: 3, inSec: 4), forKey: "myStroke")
        topRight.add(strokeAnimation(from: 0, to: 3, inSec: 4), forKey: "myStroke")
        rightTop.add(strokeAnimation(from: 0, to: 3, inSec: 4), forKey: "myStroke")
        rightBottom.add(strokeAnimation(from: 0, to: 3, inSec: 4), forKey: "myStroke")
        
        topLeftV.add(strokeAnimation(from: 0, to: 1.5, inSec: 4), forKey: "myStroke")
        topRightV.add(strokeAnimation(from: 0, to: 1.5, inSec: 4), forKey: "myStroke")
        rightTopV.add(strokeAnimation(from: 0, to: 1.2, inSec: 3.78), forKey: "myStroke")
        rightBottomV.add(strokeAnimation(from: 0, to: 1.2, inSec: 3.78), forKey: "myStroke")
        
        
        CATransaction.setCompletionBlock{ [weak self] in
            UIView.animate(withDuration: 1, delay: 2.5) {
                self!.animationMainView.alpha = 0.0
                self!.navigationController?.navigationBar.layer.opacity = 0.8
            }
        }
        
        
        CATransaction.commit()
        animationMainView.layer.addSublayer(topRight)
        animationMainView.layer.addSublayer(topRightV)
        animationMainView.layer.addSublayer(rightTop)
        animationMainView.layer.addSublayer(rightTopV)
        animationMainView.layer.addSublayer(rightBottom)
        animationMainView.layer.addSublayer(rightBottomV)
        animationMainView.layer.addSublayer(topLeft)
        animationMainView.layer.addSublayer(topLeftV)
        
        }


    
//MARK: - TableView SetUP
    func tableViewCustomization(){
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.randomButton.topAnchor, constant: -11).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

//MARK: - NavigationBar SetUp
    func navBarCustomization(){
        // Title adjustment.
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        // Buttons
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }

//MARK: - BottomBut SetUp
    func bottomButtonCustomization(){
        view.addSubview(statisticButton)
        view.addSubview(randomButton)

        statisticButton.translatesAutoresizingMaskIntoConstraints = false
        randomButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            statisticButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            statisticButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            statisticButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 20 - 10) / 2),
            statisticButton.heightAnchor.constraint(equalToConstant: 55),
            
            randomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            randomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            randomButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 20 - 10) / 2),
            randomButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        statisticButton.addTargetTouchBegin()
        statisticButton.addTargetOutsideTouchStop()
        statisticButton.addTargetInsideTouchStop()
        statisticButton.addTarget(self, action: #selector(statiscticButTap(sender:)), for: .touchUpInside)
        
        randomButton.addTargetTouchBegin()
        randomButton.addTargetOutsideTouchStop()
        randomButton.addTargetInsideTouchStop()
        randomButton.addTarget(self, action: #selector(randomButTap(sender:)), for: .touchUpInside)
    }
//MARK: - ToolBar SetUp
    /*
    func toolBarCustomization(){
        
        leftToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "View Statistics"))
        leftToolbarButton.width = 166
        rightToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "Choose Randomly"))
        rightToolbarButton.width = 166
        
        navigationController?.setToolbarHidden(false, animated: false)
        
        self.navigationController?.toolbar.setItems([
            leftToolbarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            rightToolbarButton], animated: true)
        
        self.navigationController?.toolbar.backgroundColor = .systemBackground
        self.navigationController?.toolbar.isUserInteractionEnabled = true
        self.toolbarItems = navigationController?.toolbar.items

//Action Register
        leftToolbarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftToolBarButTap(sender:))))
        rightToolbarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightToolBarButTap(sender:))))
            }
    
    func standartToolbarButton(withText: String) -> UIView {
        
        let customLabel : UILabel = {
            let label = UILabel()
            label.isUserInteractionEnabled = true
            label.attributedText = NSAttributedString(
                string: withText,
                attributes: [NSAttributedString.Key.font:
                                UIFont(name: "Georgia-Italic", size: 15) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor:
                                UIColor.label
                            ])
            return label
        }()
        
        let customView: UIView = {
            let view = UIView()
            view.isUserInteractionEnabled = true
            view.backgroundColor = UIColor.systemGray4
            view.layer.cornerRadius = 9
            view.clipsToBounds = true
            
            view.addSubview(customLabel)
            return view
        }()
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            customLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            customLabel.leadingAnchor.constraint(greaterThanOrEqualTo: customView.leadingAnchor, constant: 10),
            customLabel.trailingAnchor.constraint(lessThanOrEqualTo: customView.trailingAnchor, constant: -10),
            customLabel.topAnchor.constraint(greaterThanOrEqualTo: customView.topAnchor, constant: 10),
            customLabel.bottomAnchor.constraint(lessThanOrEqualTo: customView.bottomAnchor, constant: -10)
        ])
        return customView
        
    }
    */
    
//MARK: - Actions
    @objc func settingsButTap(sender: Any){
        navigationController?.showDetailViewController(AddDictionaryVC(), sender: self.navigationController)
    }
    @objc func randomButTap(sender: UIButton){
        let allertMessage = UIAlertController(title: "Nothing to randomize", message: "Please, add card stack to start learning.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .cancel)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        allertMessage.addAction(action)
        
        if AppData.shared.availableDictionary.count == 0{
            self.present(allertMessage, animated: true)
        } else {
            let vc = DetailsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    @objc func statiscticButTap(sender: UIButton){
        let vc = StatisticVC()
        navigationController?.present(vc, animated: true)
        }

    /*
    @objc func leftToolBarButTap(sender: Any){
//        Tap animation.
        if leftToolbarButton.customView != nil{
            UIView.animate(withDuration: 0.1, animations: {
                self.leftToolbarButton.customView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.leftToolbarButton.customView!.transform = CGAffineTransform.identity
                })
            })
        }
        let vc = StatisticVC()
        print("the problem isn't here")
        navigationController?.present(vc, animated: true)
    }
    @objc func rightToolBarButTap(sender: Any){
//        Tap animation.
        if rightToolbarButton.customView != nil{
            UIView.animate(withDuration: 0.1, animations: {
                self.rightToolbarButton.customView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.rightToolbarButton.customView!.transform = CGAffineTransform.identity
                })
            })
        }
        
        let allertMessage = UIAlertController(title: "Nothing to randomize", message: "Please, add card stack to start learning.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .cancel)
        action.setValue(UIColor.black, forKey: "titleTextColor")
        allertMessage.addAction(action)
        if AppData.shared.availableDictionary.count < 1{
            self.present(allertMessage, animated: true)
        } else {
            let vc = DetailsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
     */
        
}
//MARK: - UITableViewDelegate
extension MenuVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AppData.shared.availableDictionary.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1{
            self.navigationController?.pushViewController(AddDictionaryVC(), animated: true)
        } else {
            let vc = DetailsVC()
            vc.dictionary = AppData.shared.availableDictionary[indexPath.section]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictionary = AppData.shared.availableDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictCell", for: indexPath) as? TableViewCell
        let addCell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? TableViewAddCell
        
        if indexPath.section == tableView.numberOfSections - 1{
            return addCell!
        } else {
            cell?.languageResultLabel.text = dictionary[indexPath.section].language
            cell?.cardsResultLabel.text =  dictionary[indexPath.section].numberOfCards
            return cell!
        }
    }
}

extension MenuVC: UIToolbarDelegate{
    
}

