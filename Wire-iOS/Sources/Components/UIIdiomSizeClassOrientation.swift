//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

/// Struct for replacing IS_IPAD_FULLSCREEN, IS_IPAD_PORTRAIT_LAYOUT and IS_IPAD_LANDSCAPE_LAYOUT objc macros.
struct UIIdiomSizeClassOrientation {
    var idiom: UIUserInterfaceIdiom
    var horizontalSizeClass: UIUserInterfaceSizeClass?
    var orientation: UIInterfaceOrientation?

    init() {
        idiom = UIDevice.current.userInterfaceIdiom
        horizontalSizeClass = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass
        orientation = UIApplication.shared.statusBarOrientation
    }

    init(idiom: UIUserInterfaceIdiom, horizontalSizeClass: UIUserInterfaceSizeClass?, orientation: UIInterfaceOrientation? = nil) {
        self.idiom = idiom
        self.horizontalSizeClass = horizontalSizeClass
        self.orientation = orientation
    }

    static func current() -> UIIdiomSizeClassOrientation {
        return UIIdiomSizeClassOrientation()
    }
}

extension UIIdiomSizeClassOrientation: Equatable {}
func ==(lhs: UIIdiomSizeClassOrientation, rhs: UIIdiomSizeClassOrientation) -> Bool {

    // If one of the orientations is nil, return true
    var isOrientationEqual = false
    if let lhsOrientation = lhs.orientation, let rhsOrientation = rhs.orientation {
        isOrientationEqual = UIInterfaceOrientationIsLandscape(lhsOrientation) == UIInterfaceOrientationIsLandscape(rhsOrientation)
    }
    else {
        isOrientationEqual = true
    }

    return lhs.idiom == rhs.idiom && lhs.horizontalSizeClass == rhs.horizontalSizeClass && isOrientationEqual
}

extension UIIdiomSizeClassOrientation {
    static func isIPadRegular() -> Bool {
        return UIIdiomSizeClassOrientation.current() == UIIdiomSizeClassOrientation(idiom: .pad, horizontalSizeClass: .regular)
    }


    /// Notice: this two methods used in UIViewController.viewWillTransition. It returns the original orientation, not the new orientation
    ///
    /// - Returns:
    static func isIPadRegularLandscape() -> Bool {
        return UIIdiomSizeClassOrientation.current() == UIIdiomSizeClassOrientation(idiom: .pad, horizontalSizeClass: .regular, orientation: .landscapeLeft)
    }

    static func isIPadRegularPortrait() -> Bool {
        return !UIIdiomSizeClassOrientation.isIPadRegularLandscape()
    }

    static func isPortrait() -> Bool {
        return UIInterfaceOrientationIsPortrait(UIIdiomSizeClassOrientation.current().orientation!) /// FIXME: unwrap
    }

    static func isLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIIdiomSizeClassOrientation.current().orientation!)
    }
}

