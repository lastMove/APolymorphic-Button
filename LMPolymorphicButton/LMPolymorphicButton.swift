//
//  LMPolymorphicButton
//  MTT
//
//  Created by jason akakpo on 15/05/2015.
//  Copyright (c) 2015 MTT. All rights reserved.
//

import Foundation
import UIKit

public enum LMPolymorphicAnimationStyle
{
    case CornerRadiusFirst
    case ExpandFirst
}
//MARK:- Base Class
public class LMPolymorphicButton: UIButton
{
    @IBInspectable var rotatorSpeed: CGFloat = 10.0
    @IBInspectable var rotatorSize: CGFloat = 8.0
    @IBInspectable var rotatorColor:UIColor = UIColor.darkGrayColor()
    @IBInspectable var rotatorPadding: CGFloat = 4.0
    @IBInspectable var animDuration:Double = 0.5;
    @IBInspectable var activityTitle:String? = nil;
    
    // Value for the Aspect Ratio constraint when the Button is collapsed (in circle form)
    @IBInspectable var highConstraintPriority:Float = 800;
    // Value for the Aspect Ratio constraint when the Button is expanded (in rectangular form)
    @IBInspectable var lowConstraintPriority:Float = 200;
    var nextTask:(((String?) -> Void), title:String?)? = nil;
    
    var isAnimationInFlux:Bool = false;
    
    /** For Interface Builder, because an Enum cannot be @IbInspectable
    0 = Expand-CornerRadiusFirst / Collapse-CornerRadiusFirst
    1 = Expand-CornerRadiusFirst / Collapse-ExpandFirst
    2 = Expand-ExpandFirst / Collapse-CornerRadiusFirst
    3 = Expand-ExpandFirst / Collapse-ExpandFirst
    **/
    @IBInspectable var style:Int = 0 {
        didSet {
            
            switch (style)
            {
            case 0:
                expandAnimationStyle = LMPolymorphicAnimationStyle.CornerRadiusFirst;
                collapseAnimationStyle = LMPolymorphicAnimationStyle.CornerRadiusFirst;
            case 1:
                expandAnimationStyle = LMPolymorphicAnimationStyle.CornerRadiusFirst;
                collapseAnimationStyle = LMPolymorphicAnimationStyle.ExpandFirst;
                
            case 2:
                expandAnimationStyle = LMPolymorphicAnimationStyle.ExpandFirst;
                collapseAnimationStyle = LMPolymorphicAnimationStyle.CornerRadiusFirst;
            default:
                expandAnimationStyle = LMPolymorphicAnimationStyle.ExpandFirst;
                collapseAnimationStyle = LMPolymorphicAnimationStyle.ExpandFirst;
                
            }
        }
    };
    
    var expandAnimationStyle:LMPolymorphicAnimationStyle = .CornerRadiusFirst;
    var collapseAnimationStyle:LMPolymorphicAnimationStyle = .ExpandFirst;
    
    private var normalTitle:String? = nil;
    private var isActivityRunning = false;
    private var ratioConstraint:NSLayoutConstraint?;
    private let activityViewArray = NSMutableArray(capacity: 0)
    
    required public  init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder);
        self.createRatioContraint();
    }
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.createRatioContraint()
    }
    
}
//MARK:- public methods
extension LMPolymorphicButton
{
    public func startActivty(title:String? = nil)
    {
        if (self.isAnimationInFlux)
        {
            self.nextTask = (startActivty, title:title);
            return ;
        }
        self.isActivityRunning = true;
        self.userInteractionEnabled = true;
        
        self.isAnimationInFlux = true;
        
        let firstAnim = (self.expandAnimationStyle == LMPolymorphicAnimationStyle.CornerRadiusFirst) ? self.transformToCircle : self.transformToSquare ;
        let secondAnim = (self.expandAnimationStyle != LMPolymorphicAnimationStyle.CornerRadiusFirst) ? self.transformToCircle : self.transformToSquare ;
        
        
        firstAnim(true) {
            secondAnim(true, completion: { () -> Void in
                
                self.normalTitle = self.titleForState(UIControlState.Normal);
                
                self.setTitle(title ?? self.activityTitle ?? self.titleLabel?.text, forState: UIControlState.Normal);
                
                self.userInteractionEnabled = true;
                self.startRotators();
                self.isAnimationInFlux = false;
                self.nextTask?.0(self.nextTask?.title);
                self.nextTask = nil;
            })
        }
    }
    
    public func stopActivity(title:String? = nil)
    {
        if (self.isAnimationInFlux)
        {
            self.nextTask = (stopActivity, title:title);
            return ;
        }
        
        self.isAnimationInFlux = true;
        self.isActivityRunning = false;
        self.userInteractionEnabled = false;
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stopRotators();
            
            
        });
        let firstAnim = (self.collapseAnimationStyle == LMPolymorphicAnimationStyle.CornerRadiusFirst) ? self.transformToCircle : self.transformToSquare ;
        let secondAnim = (self.collapseAnimationStyle != LMPolymorphicAnimationStyle.CornerRadiusFirst) ? self.transformToCircle : self.transformToSquare ;
        
        firstAnim(false, completion: { () -> Void in
            secondAnim(false, completion: { () -> Void in
                self.setTitle(title ?? self.normalTitle, forState: UIControlState.Normal);
            })
            self.userInteractionEnabled = true
            self.isAnimationInFlux = false;
            self.nextTask?.0(self.nextTask?.title);
            self.nextTask = nil;
            
        })
    }
    public func toggleActivity()
    {
        if self.isActivityRunning
        {
            stopActivity();
            self.isActivityRunning = false;
        }
        else
        {
            
            startActivty();
            self.isActivityRunning = true;
        }
    }
    
    
}


//MARK:- activity Indicator
extension LMPolymorphicButton
{
    private  func createRatioContraint()
    {
        ratioConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1, constant: 0);
        ratioConstraint?.priority = 250;
        self.addConstraint(ratioConstraint!);
    }
    private  func transformToSquare(toSquare:Bool, completion:(() -> Void)? = nil)
    {
        UIView.animateWithDuration(self.animDuration * 0.8, animations: { () -> Void in
            self.ratioConstraint?.priority = toSquare ? self.highConstraintPriority : self.lowConstraintPriority;
            self.layoutIfNeeded()
            }, completion: { completed in
                completion?();
        });
        
    }
    
    private func transformToCircle(toCircle:Bool, completion:(() -> Void)? = nil)
    {
        var newCornerRadius:CGFloat = 0;
        
        newCornerRadius = toCircle ?  min(self.frame.height, self.frame.width) / 2 : 0;
        
        
        let animation = CABasicAnimation(keyPath: "cornerRadius");
        animation.fromValue = self.layer.cornerRadius;
        self.layer.cornerRadius = newCornerRadius;
        
        animation.toValue = newCornerRadius;
        animation.duration = animDuration * 0.2;
        
        CATransaction.begin()
        CATransaction.setDisableActions(true);
        CATransaction.setCompletionBlock { () -> Void in
            self.layer.cornerRadius = newCornerRadius;
            completion?();
        }
        self.layer.addAnimation(animation, forKey: "cornerRadius");
        CATransaction.commit();
    }
}
// MARK: - Rotators

extension LMPolymorphicButton
{
    private func startRotators() {
        var i: Int
        for i=1; i<=Int(self.rotatorSpeed * 1.5); ++i {
            var activityView = UIView(frame: CGRectMake(0.0, 0.0, rotatorSize, rotatorSize))
            activityView.layer.cornerRadius = activityView.frame.size.height / 2
            activityView.backgroundColor = self.rotatorColor
            activityView.alpha = 1.0 / (CGFloat(i) + 0.05)
            
            self.activityViewArray.addObject(activityView)
        }
        
        for view: AnyObject in self.activityViewArray {
            if let activityView = view as? UIView {
                
                var pathAnimation = CAKeyframeAnimation(keyPath: "position")
                pathAnimation.calculationMode = kCAAnimationLinear
                pathAnimation.fillMode = kCAFillModeForwards
                pathAnimation.removedOnCompletion = false
                pathAnimation.repeatCount = HUGE
                pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                pathAnimation.duration = CFTimeInterval(300.0) / CFTimeInterval(self.rotatorSpeed)
                
                let curvedPath = CGPathCreateMutable()
                
                self.addSubview(activityView)
                let index = self.activityViewArray.indexOfObject(activityView)
                
                let padding = self.frame.size.height / 2;
                let startAngle: CGFloat = 270.0 - (CGFloat(index) * 4)
                CGPathAddArc(curvedPath, nil, self.bounds.origin.x+padding, self.bounds.origin.y+padding, padding + self.rotatorPadding, startAngle / 180.0 * CGFloat(M_PI), 360, false)
                pathAnimation.path = curvedPath
                
                activityView.layer.addAnimation(pathAnimation, forKey: "myCircleAnimation")
            }
        }
    }
    
    private func stopRotators() {
        for view: AnyObject in self.activityViewArray {
            if let activityView = view as? UIView {
                activityView.layer.removeAllAnimations()
                activityView.removeFromSuperview()
            }
        }
        self.activityViewArray.removeAllObjects();
    }
    
}