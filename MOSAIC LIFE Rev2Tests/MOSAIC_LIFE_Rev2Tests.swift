//
//  MOSAIC_LIFE_Rev2Tests.swift
//  MOSAIC LIFE Rev2
//

import XCTest
@testable import MOSAIC_LIFE_Rev2

class MOSAIC_LIFE_Rev2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArchive() {
        let mainVC = MainViewController()
        mainVC.mainView.activityLog.archiveText()
    }

}
