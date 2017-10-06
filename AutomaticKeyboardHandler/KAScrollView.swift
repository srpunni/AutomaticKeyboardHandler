//
//  KAScrollView.swift
//  Child
//
//  Created by Sukhpal.singh on 7/6/17.
//  Copyright © 2017 SS. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

public class KAScrollView: UIScrollView, UITextViewDelegate, UITextFieldDelegate
{
    
    
    
    /*--------------------------------------------------------------------------------------------------------------
     * Instance variables declaration
     *------------------------------------------------------------------------------------------------------------*/
    
    var keyboardHeight:Int!
    var firstResponder:UIResponder?
    var doneToolBar:UIToolbar!
    var showDoneToolbar:Bool!
    var textFieldDelegate:UITextFieldDelegate!
    var textViewsDelegate:UITextViewDelegate!
    public var topPadding:CGPoint!
    var textFields:NSMutableArray!
    var scrollPoint:CGPoint!
    var initialScrollPoint:CGPoint!
    var keypadGap:Int!
    var currentOrientation:CGPoint!
    
    /*--------------------------------------------------------------------------------------------------------------
     * Intialisation and configuration for automatic keyboard handling
     *------------------------------------------------------------------------------------------------------------*/
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        self.enableKeypadHandler(showToolbar: true)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func enableKeypadHandler(showToolbar: Bool)  {
        if showToolbar {
            let bundle = Bundle(for: self.classForCoder)
            doneToolBar = bundle.loadNibNamed("doneToolbar", owner: nil, options: nil)?.first as! UIToolbar
            doneToolBar.isTranslucent = false
            doneToolBar.barTintColor = UIColor(red: 200/255.0, green: 203/255.0, blue: 211/255.0, alpha: 1.0)
            doneToolBar.sizeToFit()
        }
        keypadGap = 50
        keyboardHeight = 0
        scrollPoint = CGPoint(x: 0, y: 0)
        self.initialScrollPoint = self.contentOffset
        textFields = activeTextFields(parentView: self)
        let lastTextField = textFields.lastObject as? UITextField
        lastTextField?.returnKeyType = .done
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardDidChangeFrame, object: nil)
        
        self.keyboardDismissMode = .onDrag
    }
    
    //MARK: IBAction
    /*--------------------------------------------------------------------------------------------------------------
     * IBActions
     *------------------------------------------------------------------------------------------------------------*/
    
    @IBAction func prevAction(_ sender: Any) {
        
        let prevField =  self.prevField(currentTextField: firstResponder)
        prevField?.becomeFirstResponder()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let nextField =  self.nextField(currentTextField: firstResponder)
        nextField?.becomeFirstResponder()
        if nextField == nil {
            reset()
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        reset()
    }
    
    /*--------------------------------------------------------------------------------------------------------------
     * Other utily methods
     *------------------------------------------------------------------------------------------------------------*/
    func activeTextFields(parentView : UIView!) -> NSMutableArray
    {
        let array = NSMutableArray()
        if (parentView.subviews.count > 0) {
            for  view in parentView.subviews {
                
                if(!view.isHidden && view.isUserInteractionEnabled )
                {
                    if view is UITextInput
                    {
                        array.add(view)
                        if let textField : UITextField = view as? UITextField
                        {
                            textField.returnKeyType = .next
                            textField.inputAccessoryView = doneToolBar
                            if  textField.delegate != nil
                            {
                                textFieldDelegate = textField.delegate
                                
                            }
                            textField.delegate = self
                        }
                        else if let textView : UITextView = view as? UITextView
                        {
                            textView.returnKeyType = .next
                            textView.inputAccessoryView = doneToolBar
                            if  textView.delegate != nil
                            {
                                textViewsDelegate = textView.delegate
                                
                            }
                            textView.delegate = self
                        }
                        
                    }
                    else if view.isKind(of: UIView.self)
                    {
                        array.addObjects(from: (activeTextFields(parentView: view) as NSArray) as! [Any])
                    }
                }
                
                
            }
        }
        sortWithY(array: array)
        return array;
        
    }
    
    func sortWithY(array : NSMutableArray)
    {
        array.sort(comparator: { (object1, object2) -> ComparisonResult in
            let view1 = object1 as! UIView
            let view2 = object2 as! UIView
            var result : ComparisonResult = .orderedSame
            if calculateY(view: view1) < calculateY(view: view2) || (calculateY(view: view1) == calculateY(view: view2) && calculateX(view:view1) < calculateX(view:view2))
            {
                result = .orderedAscending
            }
            else
            {
                result = .orderedDescending
            }
            return result
        })
    }
    
    func reset()
    {
        self.setContentOffset(initialScrollPoint, animated: true)
        firstResponder?.resignFirstResponder()
        firstResponder = nil
    }
    
    func calculateY(view: UIView!) -> CGFloat
    {
        if view == nil {
            return 0
        }
        if(view.superview?.isKind(of: UIScrollView.self))!
        {
            return view.frame.origin.y;
        }
        return view.frame.origin.y + calculateY(view:view.superview)
    }
    
    func calculateX(view: UIView!) -> CGFloat
    {
        if view == nil {
            return 0
        }
        if(view.superview?.isKind(of: UIScrollView.self))!
        {
            return view.frame.origin.x;
        }
        return view.frame.origin.x + calculateX(view:view.superview)
    }
    
    func nextField(currentTextField : UIResponder!) -> UIResponder?
    {
        if currentTextField == nil {
            return textFields.firstObject as? UIResponder
        }
        var nextField : UIResponder? = nil
        let index = textFields.index(of: currentTextField)
        if(index < textFields.count - 1)
        {
            nextField = textFields.object(at: index + 1) as? UIResponder
            
        }
        return nextField
        
    }
    
    func prevField(currentTextField : UIResponder!) -> UIResponder?
    {
        if currentTextField == nil {
            return textFields.firstObject as? UIResponder
        }
        let index = textFields.index(of: currentTextField)
        if index - 1 < textFields.count && index > 0
        {
            return textFields.object(at: index - 1) as? UIResponder
            
        }
        return nil
        
        
    }
    func scrollToShow(textField: UITextField!)
    {
        if textField == nil  {
            self.setContentOffset(initialScrollPoint, animated: true)
            
        }
        else
        {
            let textFieldHeight : Int = Int(textField.frame.size.height) + keypadGap;
            var calculatedY : Int = Int(self.frame.size.height) - (keyboardHeight + textFieldHeight);
            
            let textFieldY : Int  = Int(calculateY(view: textField))
            calculatedY += keypadGap;
            let difference: Int = calculatedY - textFieldY;
            print("DIFFERENCE =========  \(difference)")
            if(difference < 0)
            {
                scrollPoint = CGPoint(x: Int(scrollPoint.x), y: -difference);
                self.setContentOffset(scrollPoint, animated: true)
                
            }
            else {
                self.setContentOffset(initialScrollPoint, animated: true)
                
            }
            
        }
        
    }
    @objc func keyboardDidHide()
    {
        firstResponder?.resignFirstResponder()
        firstResponder = nil
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let newKeyboardHeight = Int(keyboardRectangle.height) + 25
        if keyboardHeight != newKeyboardHeight {
            keyboardHeight = Int(keyboardRectangle.height) + 25
            if let textFied = firstResponder as? UITextField
            {
                scrollToShow(textField: textFied)
            }
        }
        keyboardHeight = newKeyboardHeight
    }
    
    
    /*--------------------------------------------------------------------------------------------------------------
     * UITextFieldDelegate methods
     *------------------------------------------------------------------------------------------------------------*/
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textFieldDelegate != nil {
            return textFieldDelegate.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        scrollToShow(textField: textField)
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to: #selector(textFieldShouldBeginEditing(_:)))
            {
                return textFieldDelegate.textFieldShouldBeginEditing!(textField)
            }
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        firstResponder = textField
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to: #selector(textFieldDidBeginEditing(_:)))
            {
                return textFieldDelegate.textFieldDidBeginEditing!(textField)
            }
        }
    }
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to: #selector(textFieldShouldEndEditing(_:)))
            {
                return textFieldDelegate.textFieldShouldEndEditing!(textField)
            }
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextField = self.nextField(currentTextField: textField)
        nextField?.becomeFirstResponder()
        if nextField == nil {
            //
            firstResponder = nil
            self.setContentOffset(initialScrollPoint, animated: true)
            textField.resignFirstResponder()
            //  enableKeypadHandler(showToolbar: true)
        }
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to:  #selector(textFieldShouldReturn(_:)) )
            {
                return textFieldDelegate.textFieldShouldReturn!(textField)
            }
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textFieldDelegate != nil && textFieldDelegate.responds(to: #selector(textFieldDidEndEditing(_:))) {
            textFieldDelegate.textFieldDidEndEditing!(textField)
        }
    }
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textFieldDelegate != nil && textFieldDelegate.responds(to: #selector(textFieldShouldClear(_:))) {
            return textFieldDelegate.textFieldShouldClear!(textField)
        }
        return true
    }
    
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textFieldDelegate != nil && textFieldDelegate.responds(to: #selector(textFieldDidEndEditing(_:reason:))) {
            textFieldDelegate.textFieldDidEndEditing!(textField, reason: reason)
        }
    }
    
    
    /*--------------------------------------------------------------------------------------------------------------
     * UITextFieldDelegate methods
     *------------------------------------------------------------------------------------------------------------*/
    public func textViewDidBeginEditing(_ textView: UITextView) {
        firstResponder = textView
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewDidBeginEditing(_:))) {
            textViewsDelegate.textViewDidBeginEditing!(textView)
        }
        
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewDidEndEditing(_:))) {
            textViewsDelegate.textViewDidEndEditing!(textView)
        }
    }
    public func textViewDidChange(_ textView: UITextView) {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewDidChange(_:))) {
            textViewsDelegate.textViewDidChange!(textView)
        }
        
    }
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewDidChangeSelection(_:))) {
            textViewsDelegate.textViewDidChangeSelection!(textView)
        }
    }
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewShouldEndEditing(_:))) {
            return textViewsDelegate.textViewShouldEndEditing!(textView)
        }
        return true
    }
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textViewShouldBeginEditing(_:))) {
            return textViewsDelegate.textViewShouldBeginEditing!(textView)
        }
        return true
    }
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textView(_:shouldChangeTextIn:replacementText:))) {
            return   textViewsDelegate.textView!(textView, shouldChangeTextIn: range, replacementText: text)
        }
        return true
    }
    //    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    //        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textView(_:shouldInteractWith:in:interaction:))) {
    //            return textViewsDelegate.textViewShouldBeginEditing!(textView)
    //        }
    //        return true
    //    }
    //    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    //        if textViewsDelegate != nil && textViewsDelegate.responds(to: #selector(textView(_:shouldInteractWith textAttachment:in:interaction:))) {
    //            return textViewsDelegate.textViewShouldBeginEditing!(textView)
    //        }
    //        return true
    //    }
    
}

