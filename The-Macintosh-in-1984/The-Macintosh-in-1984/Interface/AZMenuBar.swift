//
//  AZMenuBar.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol AZMenuBarDataSource {
    
    /// The menu actions that will be displayed on the menubar.
    ///
    /// - Parameter menuBar: The menuBar instance.
    /// - Returns: An array of MenuAction
    func menuActions(_ menuBar: AZMenuBar) -> [MenuAction]
    
    
    /// The menu which displays the OS actions. (mostly applications)
    ///
    /// - Parameter menuBar: The menuBar instance.
    /// - Returns: An array of MenuAction
    func osMenuActions(_ menuBar: AZMenuBar) -> [MenuAction]
    
}

/// The OS's MenuBar.
class AZMenuBar: UIView {
    
    
    /// The height of the menu bar
    static var height: CGFloat = SystemSettings.menuBarHeight
    
    /// The primary menu button.
    var osMenuButton: UIButton!
    
    /// The stack that holds the horizontal menus,
    /// like under Finder, we have *File*,*Edit*,etc.
    var menuStackView: UIStackView!
    
    /// The current dropdown menu that is displayed
    var currentDropDownMenu: MenuDropDownView?
    
    /// The black line at the bottom of os menu bar
    var bottomLine: UIView!
    
    /// The data source which is implemented by the AZDesktop
    var dataSource: AZMenuBarDataSource?
    
    convenience init(inRect rect: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: rect.width, height: AZMenuBar.height)
        self.init(frame: rect)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        backgroundColor = .white
        
        //setup os menu button, the "" on the top-left corner
        osMenuButton = UIButton(type: .custom)
        osMenuButton.addTarget(self, action: #selector(didSelectOSMenu(sender:)), for: .touchUpInside)
        osMenuButton.setTitle("", for: .normal)
        osMenuButton.titleLabel?.font = SystemSettings.normalSizeFont
        osMenuButton.setTitleColor(.black, for: .normal)
        addSubview(osMenuButton)
        
        //setup action menus
        menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.alignment = .fill
        menuStackView.distribution = .fill
        menuStackView.spacing = 0
        menuStackView.isLayoutMarginsRelativeArrangement = true
        addSubview(menuStackView)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = .black
        addSubview(bottomLine)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = 10
        osMenuButton.frame = CGRect(x: spacing, y: 0, width: 30, height: AZMenuBar.height)
        menuStackView.frame.origin.x = osMenuButton.bounds.width + spacing * 2
        bottomLine.frame = CGRect(x: 0, y: frame.maxY, width: bounds.width, height: 1)
    }
    
    // without this, the menu on the menu bar will be werid
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let spacing: CGFloat = 10
        let size = bounds.size
        menuStackView.frame = CGRect(x: osMenuButton.bounds.width + spacing, y: 0, width: size.width - size.width/3, height: AZMenuBar.height)
    }

    
    
    /// Select the OS Menu.
    /// Both this didSelectOSMenu(sender:) and didSelectItemMenu(sender:) use function `showMenuDropDown(sender: _, isPrimary: _)`
    ///
    /// - Parameter sender: UIButton, "" button
    @objc func didSelectOSMenu(sender: UIButton) {
        showMenuDropDown(sender: sender, isPrimary: true)
    }
    
    
    /// Select item menu.
    ///
    /// - Parameter sender: UIButton, other item, like under Finder: File,View,etc...
    @objc func didSelectItemMenu(sender: UIButton) {
        showMenuDropDown(sender: sender, isPrimary: false)
    }
    
    
    
    /// Called by didSelectOSMenu/didSelectItemMenu.
    ///
    /// - Parameters:
    ///   - sender: UIButton
    ///   - primary: Bool
    func showMenuDropDown(sender: UIButton, isPrimary primary: Bool) {
        let id = sender.tag
        
        for view in menuStackView.arrangedSubviews {
            (view as! UIButton).isSelected = false
        }
        
        // if we click the current menu, then we close the dropdownMenu trigged by this menu
        if let current = currentDropDownMenu {
            current.removeFromSuperview()
            if current.tag == id {
                currentDropDownMenu = nil
                return
            }
        }
        
        if primary {
            // create the OS drop down menu
            let action = MenuAction.init(title: "", action: nil, subMenus: dataSource?.osMenuActions(self))
            currentDropDownMenu = MenuDropDownView(action: action)
            currentDropDownMenu?.delegate = self
            currentDropDownMenu?.tag = id
            let senderRect = sender.convert(sender.bounds, to: self.superview)
            currentDropDownMenu?.frame.origin = senderRect.origin
            currentDropDownMenu?.frame.origin.y = currentDropDownMenu!.frame.origin.y + AZMenuBar.height
            superview?.insertSubview(currentDropDownMenu!, aboveSubview: self)
        } else {
            // here we use [id-1] because button = menuButtonFrom(action: actions[i-1], index: i)
            if let action = dataSource?.menuActions(self)[id - 1]{
                if let _ = action.subMenus {
                    sender.isSelected = true
                    currentDropDownMenu = MenuDropDownView(action: action)
                    currentDropDownMenu?.delegate = self
                    currentDropDownMenu?.tag = id
                    let senderRect = sender.convert(sender.bounds, to: self.superview)
                    currentDropDownMenu?.frame.origin = senderRect.origin
                    currentDropDownMenu?.frame.origin.y = currentDropDownMenu!.frame.origin.y + AZMenuBar.height
                    superview?.insertSubview(currentDropDownMenu!, aboveSubview: self)
                } else if let funAction = action.action {
                    funAction()
                }
            }
            
        }
    }
    
    
    /// Request from the menu bar to close all open menus.
    func closeAllMenus() {
        for view in menuStackView.arrangedSubviews {
            (view as! UIButton).isSelected = false
        }
        
        if let current = currentDropDownMenu {
            current.removeFromSuperview()
            currentDropDownMenu = nil
        }
    }
    
    
    /// Request from the menu bar to refresh it's menus (if needed)
    func applicationMenuUpdate() {
        if let buttonStack = self.menuStackView {
            
            // remove old menu buttons
            buttonStack.subviews.forEach { $0.removeFromSuperview() }
            
            //
            var stackWidth: CGFloat = 0
            let spacing: CGFloat = 20
            
            // add new items
            if let actions = dataSource?.menuActions(self) {
                for i in 1...actions.count {
                    let button = menuButtonFrom(action: actions[i-1], index: i)
                    buttonStack.addArrangedSubview(button)
                    
                    let buttonNeededWidth = Utils.widthForView(button.currentTitle!, font: SystemSettings.normalSizeFont, height: AZMenuBar.height)
                    button.widthAnchor.constraint(equalToConstant: buttonNeededWidth + spacing).isActive = true
                    stackWidth += (buttonNeededWidth + spacing)
                }
            }
            
            buttonStack.bounds.size.width = stackWidth
            buttonStack.removeConstraints(buttonStack.constraints)
            buttonStack.layoutIfNeeded()
        }
    }
    
    
    /// Create menu bar button
    ///
    /// - Parameters:
    ///   - action: MenuAction
    ///   - index: Int, note the 'index' is very important, we'll link it with tag and use it.
    /// - Returns: UIButton
    func menuButtonFrom(action: MenuAction, index: Int) -> UIButton {
        
        let button = UIButton(type: .custom)
        
        button.tag = index
        
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = SystemSettings.normalSizeFont
        
        button.setTitle(action.title, for: [])
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        
        button.setBackgroundImage(UIImage(color: .clear), for: [])
        button.setBackgroundImage(UIImage(color: .black), for: .highlighted)
        button.setBackgroundImage(UIImage(color: .black), for: .selected)
        
        button.addTarget(self, action: #selector(didSelectItemMenu(sender:)), for: .touchUpInside)
        
        return button
    }
    
    
}

extension AZMenuBar: MenuDropDownDelegate {
    func menuDropDown(_ menuDropDown: MenuDropDownView, didSelectActionAtIndex index: Int) {
        closeAllMenus()
    }
    
}
