//
//  LMPolymorphicButton
//  MTT
//
//  Created by jason akakpo on 15/05/2015.
//  Copyright (c) 2015 MTT. All rights reserved.
//

import Foundation
import UIKit

public enum LMPolymorphicAnimationStyle {
    case CornerRadiusFirst
    case ExpandFirst
}

// MARK :- Base Class


struct Task {
    let action: (String?) -> ()
    let title: String?
    
    init(action: (String?) -> (), title: String? = nil) {
        self.action = action
        self.title = title
    }
    
    func activate() {
        self.action(self.title)
    }
}

@IBDesignable
public class LMPolymorphicButton: UIButton {
    @IBInspectable var rotatorSpeed: CGFloat = 10.0
    @IBInspectable var rotatorSize: CGFloat = 8.0
    @IBInspectable var rotatorColor:UIColor = UIColor.darkGrayColor()
    @IBInspectable var rotatorPadding: CGFloat = 4.0
    @IBInspectable var animDuration:Double = 0.5
    @IBInspectable var activityTitle:String? = nil
    @IBInspectable var initialCornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.initialCornerRadius
        }
    }
    @IBInspectable var expandAtEnd: Bool = false
    
    // Value for the Aspect Ratio constraint when the Button is collapsed (in circle form)
    @IBInspectable var highConstraintPriority: Float = 800.0
    // Value for the Aspect Ratio constraint when the Button is expanded (in rectangular form)
    @IBInspectable var lowConstraintPriority: Float = 200.0
    
    // TODO: re-write it
    var nextTask: Task? = nil
    
    var isAnimationInFlux = false
    
    /** For Interface Builder, because an Enum cannot be @IbInspectable
    0 = Expand-CornerRadiusFirst / Collapse-CornerRadiusFirst
    1 = Expand-CornerRadiusFirst / Collapse-ExpandFirst
    2 = Expand-ExpandFirst / Collapse-CornerRadiusFirst
    3 = Expand-ExpandFirst / Collapse-ExpandFirst
    **/
    @IBInspectable var style: Int = 0 {
        didSet {
            switch style {
            case 0:
                expandAnimationStyle = .CornerRadiusFirst
                collapseAnimationStyle = .CornerRadiusFirst
            case 1:
                expandAnimationStyle = .CornerRadiusFirst
                collapseAnimationStyle = .ExpandFirst
                
            case 2:
                expandAnimationStyle = .ExpandFirst
                collapseAnimationStyle = .CornerRadiusFirst
                
            default:
                expandAnimationStyle = .ExpandFirst
                collapseAnimationStyle = .ExpandFirst
            }
        }
    }
    
    var expandAnimationStyle = LMPolymorphicAnimationStyle.CornerRadiusFirst
    var collapseAnimationStyle = LMPolymorphicAnimationStyle.ExpandFirst
    
    private var normalTitle: String? = nil
    private var isActivityRunning = false
    private var ratioConstraint: NSLayoutConstraint?
    private var activityViewArray = [UIView]()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.layer.cornerRadius = self.initialCornerRadius

        self.createRatioContraint()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.initialCornerRadius

        self.createRatioContraint()
    }
}

// MARK :- public methods

extension LMPolymorphicButton {
    
    public func startActivity(title: String? = nil) {
        if self.isAnimationInFlux {
            self.nextTask = Task(action: startActivity, title: title)
            return
        }
        
        self.userInteractionEnabled = true
        
        self.isAnimationInFlux = true
        
        let firstAnimIsToCircle = self.expandAnimationStyle == LMPolymorphicAnimationStyle.CornerRadiusFirst
        
        let firstAnim  =  firstAnimIsToCircle ? self.transformToCircle : self.transformToSquare
        let secondAnim = !firstAnimIsToCircle ? self.transformToCircle : self.transformToSquare
        
        
        firstAnim(true) {
            secondAnim(true) {
                
                self.normalTitle = self.titleForState(UIControlState.Normal)
                
                self.setTitle(title ?? self.activityTitle ?? self.titleLabel?.text, forState: UIControlState.Normal)
                
                self.userInteractionEnabled = true
                self.startRotators()
                self.isAnimationInFlux = false
                self.nextTask?.activate()
                self.nextTask = nil
            }
        }
    }
    
    public func expandActivity() {
        if self.isAnimationInFlux {
//            self.nextTask = Task(action: beginAnimation, title: animation)
            return
        }
        
        self.userInteractionEnabled = false
        
        self.isAnimationInFlux = true
        
        self.setTitle(nil, forState: UIControlState.Normal)

        self.transformExpand()
    }
    
    public func stopActivity(title: String? = nil) {
        if self.isAnimationInFlux {
            self.nextTask = Task(action: stopActivity, title: title)
            return
        }
        
        self.isAnimationInFlux = true
        self.userInteractionEnabled = false
        
        dispatch_async(dispatch_get_main_queue()) {
            self.stopRotators()
        }
        
        let isFirstIsToCircle = self.collapseAnimationStyle == LMPolymorphicAnimationStyle.CornerRadiusFirst
        
        let firstAnim  =  isFirstIsToCircle ? self.transformToCircle : self.transformToSquare
        let secondAnim = !isFirstIsToCircle ? self.transformToCircle : self.transformToSquare
        
        firstAnim(false) {
            secondAnim(false) {
                self.setTitle(title ?? self.normalTitle, forState: UIControlState.Normal)
            }
            self.userInteractionEnabled = true
            self.isAnimationInFlux = false
            self.nextTask?.activate()
            self.nextTask = nil
        }
    }
    
    public func toggleActivity() {
        if self.isActivityRunning {
            if self.expandAtEnd {
                self.expandActivity()
                self.stopRotators()
            } else {
                stopActivity()
            }
        } else {
            startActivity()
        }
        self.isActivityRunning = !self.isActivityRunning
    }
}


// MARK :- activity Indicator
extension LMPolymorphicButton {
    private func createRatioContraint() {
        ratioConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1, constant: 0)
        ratioConstraint!.priority = 250
        
        self.addConstraint(ratioConstraint!)
    }
    
    private func transformToSquare(toSquare: Bool, completion:(() -> Void)? = nil) {
        UIView.animateWithDuration(self.animDuration * 0.8, animations: { () -> Void in
            self.ratioConstraint?.priority = toSquare ? self.highConstraintPriority : self.lowConstraintPriority;
            self.layoutIfNeeded()
        }, completion: { completed in
            completion?()
        })
    }
    
    private func transformToCircle(toCircle: Bool, completion:(() -> Void)? = nil) {
        var newCornerRadius: CGFloat = self.initialCornerRadius
        
        if toCircle {
            newCornerRadius = min(self.frame.height, self.frame.width) / 2
        }
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.fromValue = self.layer.cornerRadius
        self.layer.cornerRadius = newCornerRadius
        
        animation.toValue = newCornerRadius
        animation.duration = animDuration * 0.2
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            self.layer.cornerRadius = newCornerRadius
            completion?()
        }
        self.layer.addAnimation(animation, forKey: "cornerRadius")
        CATransaction.commit()
    }
    
    private func transformExpand(completion: (() -> ())? = nil) {
        
        UIView.animateWithDuration(2.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options:[UIViewAnimationOptions.CurveEaseInOut], animations: {
            self.transform = CGAffineTransformMakeScale(100.0, 100.0)

        }, completion: { completed in
                completion?()
        })
    }
}

// MARK :- Rotators

extension LMPolymorphicButton {
    private func startRotators() {
        for var i = 1; i <= Int(self.rotatorSpeed * 1.5); ++i {
            let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: rotatorSize, height: rotatorSize))
            activityView.layer.cornerRadius = activityView.frame.size.height / 2
            activityView.backgroundColor = self.rotatorColor
            activityView.alpha = 1.0 / (CGFloat(i) + 0.05)
            
            self.activityViewArray.append(activityView)
        }
        
        for (index, view) in self.activityViewArray.enumerate() {
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.calculationMode = kCAAnimationLinear
            pathAnimation.fillMode = kCAFillModeForwards
            pathAnimation.removedOnCompletion = false
            pathAnimation.repeatCount = HUGE
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            pathAnimation.duration = CFTimeInterval(300.0) / CFTimeInterval(self.rotatorSpeed)
                
            let curvedPath = CGPathCreateMutable()
            self.addSubview(view)
            
            let padding = self.frame.size.height / 2
            let startAngle: CGFloat = 270.0 - (CGFloat(index) * 4)
            CGPathAddArc(curvedPath, nil, self.bounds.origin.x + padding, self.bounds.origin.y + padding, padding + self.rotatorPadding, startAngle / 180.0 * CGFloat(M_PI), 360, false)
            pathAnimation.path = curvedPath
                
            view.layer.addAnimation(pathAnimation, forKey: "myCircleAnimation")
        }
    }
    
    private func stopRotators() {
        for view in self.activityViewArray {
            view.layer.removeAllAnimations()
            view.removeFromSuperview()
        }
        
        self.activityViewArray.removeAll()
    }
}