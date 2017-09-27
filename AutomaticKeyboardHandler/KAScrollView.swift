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

var TextFieldsKey: UInt8 = 0
var ScrollPointKey: UInt8 = 1
var InitialScrollPointKey: UInt8 = 2
var KeypadGapKey: UInt8 = 3
var CurrentOrientationKey: UInt8 = 4

var DoneToolBarKey: UInt8 = 5
var DelegateKey: UInt8 = 6
var TextViewsDelegateKey: UInt8 = 7
var TopPaddingKey: UInt8 = 8
var ShowDoneToolbarKey: UInt8 = 9

var KeyboardHeightKey: UInt8 = 10


class KAScrollView: UIScrollView, UITextViewDelegate, UITextFieldDelegate
{
    
    var firstResponder : UIResponder?
    
    
    /*--------------------------------------------------------------------------------------------------------------
     * Associated objects declaration
     *------------------------------------------------------------------------------------------------------------*/
    
    var keyboardHeight:Int! {
        get {
            return objc_getAssociatedObject(self, &KeyboardHeightKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &KeyboardHeightKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var doneToolBar:UIToolbar! {
        get {
            return objc_getAssociatedObject(self, &DoneToolBarKey) as? UIToolbar
        }
        set {
            objc_setAssociatedObject(self, &DoneToolBarKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var showDoneToolbar:Bool! {
        get {
            return objc_getAssociatedObject(self, &ShowDoneToolbarKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &ShowDoneToolbarKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var textFieldDelegate:UITextFieldDelegate! {
        get {
            return objc_getAssociatedObject(self, &DelegateKey) as? UITextFieldDelegate
        }
        set {
            objc_setAssociatedObject(self, &DelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var textViewsDelegate:UITextViewDelegate! {
        get {
            return objc_getAssociatedObject(self, &TextViewsDelegateKey) as? UITextViewDelegate
        }
        set {
            objc_setAssociatedObject(self, &TextViewsDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var topPadding:CGPoint! {
        get {
            return objc_getAssociatedObject(self, &TopPaddingKey) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &TopPaddingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
    var textFields:NSMutableArray! {
        get {
            return objc_getAssociatedObject(self, &TextFieldsKey) as? NSMutableArray
        }
        set {
            objc_setAssociatedObject(self, &TextFieldsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var scrollPoint:CGPoint! {
        get {
            return objc_getAssociatedObject(self, &ScrollPointKey) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &ScrollPointKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var initialScrollPoint:CGPoint! {
        get {
            return objc_getAssociatedObject(self, &InitialScrollPointKey) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &InitialScrollPointKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var keypadGap:Int! {
        get {
            return objc_getAssociatedObject(self, &KeypadGapKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &KeypadGapKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var currentOrientation:CGPoint! {
        get {
            return objc_getAssociatedObject(self, &CurrentOrientationKey) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &CurrentOrientationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBAction func prevAction(_ sender: Any) {
        
        let prevField =  self.prevField(currentTextField: firstResponder)
        prevField?.becomeFirstResponder()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let nextField =  self.nextField(currentTextField: firstResponder)
        nextField?.becomeFirstResponder()
    }
    
    
    /*--------------------------------------------------------------------------------------------------------------
     * Starting point
     *------------------------------------------------------------------------------------------------------------*/
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.enableKeypadHandler(showToolbar: true)
    }
    func enableKeypadHandler(showToolbar: Bool)  {
        if showToolbar {
            doneToolBar = Bundle.main.loadNibNamed("doneToolbar", owner: nil, options: nil)?.first as! UIToolbar
            
        }
        keypadGap = 50
        keyboardHeight = 260
        scrollPoint = CGPoint(x: 0, y: 0)
        self.initialScrollPoint = self.contentOffset
        textFields = activeTextFields(parentView: self)
        let lastTextField = textFields.lastObject as? UITextField
        lastTextField?.returnKeyType = .done
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardDidChangeFrame, object: nil)
        
        
    }
    
    /*--------------------------------------------------------------------------------------------------------------
     * Other utily methods
     *------------------------------------------------------------------------------------------------------------*/
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
        if index - 1 < textFields.count
        {
            return textFields.object(at: index - 1) as? UIResponder
            
        }
        return nil
        
        
    }
    
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
                            textFieldDelegate = textField.delegate
                            textField.delegate = self
                        }
                        else if let textView : UITextView = view as? UITextView
                        {
                            textView.returnKeyType = .next
                            textView.inputAccessoryView = doneToolBar
                            textViewsDelegate = textView.delegate
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
        return array;
        
    }
    
    func getY(view: UIView!) -> CGFloat
    {
        if view == nil {
            return 0
        }
        if(view.superview?.isKind(of: UIScrollView.self))!
        {
            return view.frame.origin.y;
        }
        return view.frame.origin.y + getY(view:view.superview)
    }
    func moveToNext(fromTextField: UITextField!)
    {
        if fromTextField == nil  {
            self.setContentOffset(initialScrollPoint, animated: true)
            
        }
        else
        {
            let textFieldHeight : Int = Int(fromTextField.frame.size.height) + keypadGap;
            var calculatedY : Int = Int(self.frame.size.height) - (keyboardHeight + textFieldHeight);
            
            let textFieldY : Int  = Int(getY(view: fromTextField))
            calculatedY += keypadGap;
            let difference: Int = calculatedY - textFieldY;
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
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = Int(keyboardRectangle.height)
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
        moveToNext(fromTextField: textField)
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to: Selector(("textFieldShouldBeginEditing")))
            {
                return textFieldDelegate.textFieldShouldBeginEditing!(textField)
            }
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        firstResponder = textField
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textFieldDelegate != nil {
            if textFieldDelegate.responds(to: Selector(("textFieldShouldEndEditing")))
            {
                return textFieldDelegate.textFieldShouldBeginEditing!(textField)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            if textFieldDelegate.responds(to:  #selector(textFieldShouldReturn) )
            {
                return textFieldDelegate.textFieldShouldReturn!(textField)
            }
        }
        return true
    }
    
    /*--------------------------------------------------------------------------------------------------------------
     * UITextFieldDelegate methods
     *------------------------------------------------------------------------------------------------------------*/
    func textViewDidBeginEditing(_ textView: UITextView) {
        firstResponder = textView
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}
