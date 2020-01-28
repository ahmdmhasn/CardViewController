//
//  CardViewController.swift
//  TabBarDemo
//
//  Created by Ahmed M. Hassan on 1/28/20.
//  Copyright © 2020 Ahmed M. Hassan. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var handleView: UIView!
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    enum CardViewState {
        case expanded
        case normal
    }
    
    // default card view state is normal
    var cardViewState : CardViewState = .normal
    
    // to store the card view top constraint value before the dragging start
    // default is 30 pt from safe area top
    var cardPanStartingTopConstant : CGFloat = 30.0
        
    // Child view controller which injected in the constructor
    private var childViewController: UIViewController!

    // MARK: View Lifecycle
    /**
     Create a Card View Controller instance with and UIViewController inside it
     - parameter viewController: The view controller you woulf like to inject
     */
    init(viewController: UIViewController) {
        super.init(nibName: String(describing: CardViewController.self), bundle: nil)
        self.childViewController = viewController
        
        // set the modal presentation to full screen, in iOS 13, its no longer full screen by default
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round the top left and top right corner of card view
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // round the handle view
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0

        // hide the card view at the bottom when the View first load
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = keyWindow?.safeAreaInsets.bottom {
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        // set dimmerview to transparent
        dimmerView.alpha = 0.0
        
        // dimmerViewTapped() will be called when user tap on the dimmer view
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        
        // by default iOS will delay the touch before recording the drag/pan information
        // we want the drag gesture to be recorded down immediately, hence setting no delay
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        
        self.view.addGestureRecognizer(viewPan)
        
        // Setup child view controller inside CardView
        setupChildViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showCard()
    }
    
    // Setup Child View Controller
    private func setupChildViewController() {
        addChild(childViewController)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(childViewController.view)

        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: cardView.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])

        childViewController.didMove(toParent: self)
    }
    
    // @IBAction is required in front of the function name due to how selector works
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideCardAndGoBack()
    }
    
    // this function will be called when user pan/drag the view
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        // how much has user dragged
        let translation = panRecognizer.translation(in: self.view)
        
        // how fast the user drag
        let velocity = panRecognizer.velocity(in: self.view)

        switch panRecognizer.state {
        case .began:
            cardPanStartingTopConstant = cardViewTopConstraint.constant
        case .changed :
            if self.cardPanStartingTopConstant + translation.y > 30.0 {
                self.cardViewTopConstraint.constant = self.cardPanStartingTopConstant + translation.y
            }
            
            // change the dimmer view alpha based on how much user has dragged
            dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraint.constant)

        case .ended :
            // if user drag down with a very fast speed (ie. swipe)
            if velocity.y > 1500.0 {
              // hide the card and dismiss current view controller
              hideCardAndGoBack()
              return
            }

            if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
                let bottomPadding = keyWindow?.safeAreaInsets.bottom {
                
                if self.cardViewTopConstraint.constant < (safeAreaHeight + bottomPadding) * 0.25 {
                  // show the card at expanded state
                  showCard(atState: .expanded)
                } else if self.cardViewTopConstraint.constant < (safeAreaHeight) - 70 {
                  // show the card at normal state
                  showCard()
                } else {
                  // hide the card and dismiss current view controller
                  hideCardAndGoBack()
                }
            }
        default:
            break
        }
    }
    
    //MARK: Animations
    private func showCard(atState: CardViewState = .normal) {
        // ensure there's no pending layout changes before animation runs
        self.view.layoutIfNeeded()
        
        // set the new top constraint value for card view
        // card view won't move up just yet, we need to call layoutIfNeeded()
        // to tell the app to refresh the frame/position of card view
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = keyWindow?.safeAreaInsets.bottom {
            
            if atState == .expanded {
                // if state is expanded, top constraint is 30pt away from safe area top
                cardViewTopConstraint.constant = 30.0
            } else {
                // when card state is normal, its top distance to safe area is
                // (safe area height + bottom inset) / 2.0
                cardViewTopConstraint.constant = (safeAreaHeight + bottomPadding) / 2.0
            }

            cardPanStartingTopConstant = cardViewTopConstraint.constant
        }
        
        // move card up from bottom by telling the app to refresh the frame/position of view
        // create a new property animator
        let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
            self.view.layoutIfNeeded()
        }
        
        // show dimmer view
        // this will animate the dimmerView alpha together with the card move up animation
        showCard.addAnimations({
            self.dimmerView.alpha = 0.7
        })
        
        // run the animation
        showCard.startAnimation()
        
    }
    
    private func hideCardAndGoBack() {
        
        // ensure there's no pending layout changes before animation runs
        self.view.layoutIfNeeded()
        
        // set the new top constraint value for card view
        // card view won't move down just yet, we need to call layoutIfNeeded()
        // to tell the app to refresh the frame/position of card view
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
            let bottomPadding = keyWindow?.safeAreaInsets.bottom {
            
            // move the card view to bottom of screen
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        // move card down to bottom
        // create a new property animator
        let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        
        // hide dimmer view
        // this will animate the dimmerView alpha together with the card move down animation
        hideCard.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        
        // when the animation completes, (position == .end means the animation has ended)
        // dismiss this view controller (if there is a presenting view controller)
        hideCard.addCompletion({ position in
            if position == .end {
                if(self.presentingViewController != nil) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        })
        
        // run the animation
        hideCard.startAnimation()
    }
    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
      let fullDimAlpha : CGFloat = 0.7
      
      // ensure safe area height and safe area bottom padding is not nil
      guard let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = keyWindow?.safeAreaInsets.bottom else {
        return fullDimAlpha
      }
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is dimmest (0.7)
      let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is lightest (0.0)
      let noDimPosition = safeAreaHeight + bottomPadding
      
      // if card view top constraint is lesser than fullDimPosition
      // it is dimmest
      if value < fullDimPosition {
        return fullDimAlpha
      }
      
      // if card view top constraint is more than noDimPosition
      // it is dimmest
      if value > noDimPosition {
        return 0.0
      }
      
      // else return an alpha value in between 0.0 and 0.7 based on the top constraint value
      return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
    }

}
