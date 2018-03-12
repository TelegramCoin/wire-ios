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

import XCTest
@testable import Wire

final class MockConversationRootViewController: UIViewController, NetworkStatusBarDelegate {
    var isViewDidAppear: Bool = true
    
    var networkStatusViewController: NetworkStatusViewController!
    
    var shouldShowNetworkStatusUIInIPadRegularLandscape: Bool {
        get {
            return false
        }
    }
    
    var shouldShowNetworkStatusUIInIPadRegularPortrait: Bool {
        get {
            return true
        }
    }
}

final class MockConversationListViewController: UIViewController, NetworkStatusBarDelegate {
    var isViewDidAppear: Bool = true
    
    var networkStatusViewController: NetworkStatusViewController!
    
    var shouldShowNetworkStatusUIInIPadRegularLandscape: Bool {
        get {
            return true
        }
    }
    
    var shouldShowNetworkStatusUIInIPadRegularPortrait: Bool {
        get {
            return false
        }
    }
}

final class NetworkStatusViewControllerTests: XCTestCase {
    var sutRoot: NetworkStatusViewController!
    var sutList: NetworkStatusViewController!
    
    var mockDevice: MockDevice!
    var mockConversationRoot: MockConversationRootViewController!
    var mockConversationList: MockConversationListViewController!
    
    override func setUp() {
        super.setUp()
        mockDevice = MockDevice()
        
        mockConversationList = MockConversationListViewController()
        sutList = NetworkStatusViewController(device: mockDevice)
        mockConversationList.networkStatusViewController = sutList
        mockConversationList.addChildViewController(sutList)
        sutList.delegate = mockConversationList
        
        mockConversationRoot = MockConversationRootViewController()
        sutRoot = NetworkStatusViewController(device: mockDevice)
        mockConversationRoot.networkStatusViewController = sutRoot
        mockConversationRoot.addChildViewController(sutRoot)
        sutRoot.delegate = mockConversationRoot
    }
    
    override func tearDown() {
        sutList = nil
        sutRoot = nil
        mockDevice = nil
        
        ///TODO
        super.tearDown()
    }
    
    /// check for networkStatusView state is updated after device properties are changed
    ///
    /// - Parameters:
    ///   - userInterfaceIdiom: updated idiom
    ///   - horizontalSizeClass: updated size class
    ///   - orientation: updated orientation
    ///   - listState: expected networkStatusView state in conversation list
    ///   - rootState: expected networkStatusView state in conversation root
    ///   - file: optional, for XCTAssert logging error source
    ///   - line: optional, for XCTAssert logging error source
    fileprivate func setUpSut(userInterfaceIdiom: UIUserInterfaceIdiom,
                              horizontalSizeClass: UIUserInterfaceSizeClass,
                              orientation: UIDeviceOrientation) {
        sutList.update(state: .offlineExpanded)
        sutRoot.update(state: .offlineExpanded)
        
        mockDevice.userInterfaceIdiom = userInterfaceIdiom
        mockDevice.orientation = orientation
        
        let traitCollection = UITraitCollection(horizontalSizeClass: horizontalSizeClass)
        mockConversationList.setOverrideTraitCollection(traitCollection, forChildViewController: sutList)
        mockConversationRoot.setOverrideTraitCollection(traitCollection, forChildViewController: sutRoot)
        
    }
    
    fileprivate func checkResult(listState: NetworkStatusViewState,
                                 rootState: NetworkStatusViewState,
                                 file: StaticString = #file, line: UInt = #line) {
        
        XCTAssertEqual(sutList.networkStatusView.state, listState, "List's networkStatusView.state should be equal to \(listState)", file: file, line: line)
        XCTAssertEqual(sutRoot.networkStatusView.state, rootState, "Root's networkStatusView.state should be equal to \(rootState)", file: file, line: line)
    }
    
    /// check for networkStatusView state is updated after device properties are changed
    ///
    /// - Parameters:
    ///   - userInterfaceIdiom: updated idiom
    ///   - horizontalSizeClass: updated size class
    ///   - orientation: updated orientation
    ///   - listState: expected networkStatusView state in conversation list
    ///   - rootState: expected networkStatusView state in conversation root
    ///   - file: optional, for XCTAssert logging error source
    ///   - line: optional, for XCTAssert logging error source
    fileprivate func checkForNetworkStatusViewState(userInterfaceIdiom: UIUserInterfaceIdiom,
                                                    horizontalSizeClass: UIUserInterfaceSizeClass,
                                                    orientation: UIDeviceOrientation,
                                                    listState: NetworkStatusViewState,
                                                    rootState: NetworkStatusViewState,
                                                    file: StaticString = #file, line: UInt = #line) {
        // GIVEN & WHEN
        setUpSut(userInterfaceIdiom: userInterfaceIdiom, horizontalSizeClass: horizontalSizeClass, orientation: orientation)

        // THEN
        checkResult(listState: listState, rootState: rootState)
    }
    
    func testThatNetworkStatusViewShowsOnListButNotRootWhenDevicePropertiesIsIPadLandscapeRegularMode() {
        checkForNetworkStatusViewState(userInterfaceIdiom: .pad,
                                       horizontalSizeClass: .regular,
                                       orientation: .landscapeLeft,
                                       listState: .offlineExpanded,
                                       rootState: .online)
    }
    
    func testThatNetworkStatusViewShowsOnRootButNotListWhenDevicePropertiesIsIPadPortraitRegularMode() {
        checkForNetworkStatusViewState(userInterfaceIdiom: .pad,
                                       horizontalSizeClass: .regular,
                                       orientation: .portrait,
                                       listState: .online,
                                       rootState: .offlineExpanded)
    }
    
    func testThatNetworkStatusViewShowsOnListButNotRootWhenDevicePropertiesIsIPadLandscapeCompactMode() {
        checkForNetworkStatusViewState(userInterfaceIdiom: .pad,
                                       horizontalSizeClass: .compact,
                                       orientation: .landscapeLeft,
                                       listState: .offlineExpanded,
                                       rootState: .offlineExpanded)
    }
    
    func testThatNetworkStatusViewShowsOnBothWhenDevicePropertiesIsIPhonePortraitCompactMode() {
        checkForNetworkStatusViewState(userInterfaceIdiom: .phone,
                                       horizontalSizeClass: .compact,
                                       orientation: .portrait,
                                       listState: .offlineExpanded,
                                       rootState: .offlineExpanded)
    }
    
    func testThatNotifyWhenOfflineShowsNetworkStatusView() {
        // GIVEN
        let userInterfaceIdiom: UIUserInterfaceIdiom = .pad
        let horizontalSizeClass: UIUserInterfaceSizeClass = .regular
        let orientation: UIDeviceOrientation = .landscapeLeft
        
        let listState = NetworkStatusViewState.offlineExpanded
        let rootState = NetworkStatusViewState.online
        
        setUpSut(userInterfaceIdiom: userInterfaceIdiom, horizontalSizeClass: horizontalSizeClass, orientation: orientation)
        // WHEN
        _ = NetworkStatusViewController.notifyWhenOffline()
        
        // THEN
        checkResult(listState: listState, rootState: rootState)
    }
}

