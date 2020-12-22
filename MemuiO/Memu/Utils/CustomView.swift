//
//  CustomView.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/28/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

/// typealias class for CustomView. Needed for quick mapping.
open class BorderView: CustomView {}

@IBDesignable open class CustomView: UIView {

    /// flag: true - will show bottom line, false - else
    @IBInspectable public var showBottomLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show top line, false - else
    @IBInspectable public var showTopLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show left line, false - else
    @IBInspectable public var showLeftLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// flag: true - will show right line, false - else
    @IBInspectable public var showRightLine: Bool = false { didSet { self.setNeedsDisplay() } }

    /// the border color
    @IBInspectable public var borderColor: UIColor = UIColor.lightGray { didSet { self.setNeedsDisplay() } }

    /// the height of the line
    @IBInspectable public var lineHeight: CGFloat = 1 { didSet { self.setNeedsDisplay() } }

    /// the radius of the corners
    @IBInspectable public var cornerRaduis: CGFloat = 0 { didSet { self.setNeedsDisplay() } }

    /// the main color
    @IBInspectable public var mainColor: UIColor = UIColor.white { didSet { self.setNeedsLayout() } }

    /// flag: true - will add shadow, false - else
    @IBInspectable public var addShadow: Bool = false { didSet { self.setNeedsDisplay() } }

    @IBInspectable public var shadowSize: CGFloat = 2 { didSet { self.setNeedsDisplay() } }

    /// flag: true - will add border, false - else
    @IBInspectable public var addBorder: Bool = false { didSet { self.setNeedsDisplay() } }

    /// the inner views
    private var shadowView: UIView!
    private var cornersView: UIView!

    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        borderColor.set()
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.setLineWidth(lineHeight)
        if showBottomLine {
            currentContext?.move(to: CGPoint(x: 0, y: self.bounds.height - lineHeight/2))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - lineHeight/2))
            currentContext?.strokePath()
        }
        if showTopLine {
            currentContext?.move(to: CGPoint(x: 0, y: lineHeight/2))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: lineHeight/2))
            currentContext?.strokePath()
        }
        if showLeftLine {
            currentContext?.move(to: CGPoint(x: lineHeight/2, y: 0))
            currentContext?.addLine(to: CGPoint(x: lineHeight/2, y: self.bounds.height))
            currentContext?.strokePath()
        }
        if showRightLine {
            currentContext?.move(to: CGPoint(x: self.bounds.width - lineHeight/2, y: 0))
            currentContext?.addLine(to: CGPoint(x: self.bounds.width - lineHeight/2, y: self.bounds.height))
            currentContext?.strokePath()
        }
    }

    /// Layout subview
    open override func layoutSubviews() {
        super.layoutSubviews()

        if cornerRaduis > 0 {
            addRoundCorners()
            self.backgroundColor = UIColor.clear
            if addBorder {
                cornersView.addBorder(color: borderColor, borderWidth: lineHeight)
            }
            else {
                cornersView.layer.borderWidth = 0
            }
        }
        else {
            cornersView?.isHidden = true
            if addBorder {
                self.addBorder(color: borderColor, borderWidth: lineHeight)
            }
            else {
                self.layer.borderWidth = 0
            }
        }

        if addShadow {
            addShadowView(size: shadowSize)
        }
        else {
            shadowView?.isHidden = true
        }
        self.setNeedsDisplay()
    }

    /// Add shadow view
    ///
    /// - Parameters:
    ///   - size: the size of the shadow
    ///   - shift: the shift
    ///   - opacity: the opacity
    private func addShadowView(size: CGFloat = 2, shift: CGFloat = 1, opacity: Float = 0.19, color: UIColor = UIColor.black) { // %19 black is the same as %50 "A0A0A0", but makes better shadow on all backgrounds
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRaduis).cgPath
        if shadowView == nil && opacity > 0 {
            shadowView = UIView()
            self.addSubview(shadowView)
            self.sendSubviewToBack(shadowView)
            shadowView.backgroundColor = UIColor.black
        }
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: shift)
        shadowView.layer.shadowOpacity = opacity
        shadowView.layer.shadowRadius = size
        shadowView.layer.shadowPath = shadowPath
        shadowView.isHidden = false
    }

    /// Add view with corners
    private func addRoundCorners() {
        if cornersView == nil {
            cornersView = UIView()
            cornersView.isUserInteractionEnabled = false
            self.addSubview(cornersView)
            self.sendSubviewToBack(cornersView)
        }
        cornersView.backgroundColor = mainColor
        cornersView.frame = bounds
        cornersView.roundCorners(cornerRaduis)
        cornersView?.isHidden = false
        self.layer.masksToBounds = false
    }
}
