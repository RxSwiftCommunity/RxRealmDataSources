////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private
import Realm.Dynamic
import RealmSwift
import XCTest

func inMemoryRealm(_ inMememoryIdentifier: String) -> Realm {
    return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: inMememoryIdentifier))
}

class TestCase: XCTestCase {
    var exceptionThrown = false
    var testDir: String! = nil

    let queue = DispatchQueue(label: "background")

    @discardableResult
    func realmWithTestPath(configuration: Realm.Configuration = Realm.Configuration()) -> Realm {
        var configuration = configuration
        configuration.fileURL = testRealmURL()
        return try! Realm(configuration: configuration)
    }

    override class func setUp() {
        super.setUp()
#if DEBUG || arch(i386) || arch(x86_64)
        // Disable actually syncing anything to the disk to greatly speed up the
        // tests, but only when not running on device because it can't be
        // re-enabled and we need it enabled for performance tests
        RLMDisableSyncToDisk()
#endif
        do {
            // Clean up any potentially lingering Realm files from previous runs
            try FileManager.default.removeItem(atPath: RLMRealmPathForFile(""))
        } catch {
            // The directory might not actually already exist, so not an error
        }
    }

    override class func tearDown() {
        RLMRealm.resetRealmState()
        super.tearDown()
    }

    override func invokeTest() {
        testDir = RLMRealmPathForFile(realmFilePrefix())

        do {
            try FileManager.default.removeItem(atPath: testDir)
        } catch {
            // The directory shouldn't actually already exist, so not an error
        }
        try! FileManager.default.createDirectory(at: URL(fileURLWithPath: testDir, isDirectory: true),
                                                     withIntermediateDirectories: true, attributes: nil)

        let config = Realm.Configuration(fileURL: defaultRealmURL())
        Realm.Configuration.defaultConfiguration = config

        exceptionThrown = false
        autoreleasepool { super.invokeTest() }

        if !exceptionThrown {
            XCTAssertFalse(RLMHasCachedRealmForPath(defaultRealmURL().path))
            XCTAssertFalse(RLMHasCachedRealmForPath(testRealmURL().path))
        }

        resetRealmState()

        do {
            try FileManager.default.removeItem(atPath: testDir)
        } catch {
            XCTFail("Unable to delete realm files")
        }

        // Verify that there are no remaining realm files after the test
        let parentDir = (testDir as NSString).deletingLastPathComponent
        for url in FileManager.default.enumerator(atPath: parentDir)! {
            let url = url as! NSString
            XCTAssertNotEqual(url.pathExtension, "realm", "Lingering realm file at \(parentDir)/\(url)")
            assert(url.pathExtension != "realm")
        }
    }

    func resetRealmState() {
        RLMRealm.resetRealmState()
    }

    func dispatchSyncNewThread(block: @escaping () -> Void) {
        queue.async {
            autoreleasepool {
                block()
            }
        }
        queue.sync { }
    }

    func assertThrows<T>(_ block: @autoclosure @escaping() -> T, named: String? = RLMExceptionName,
                         _ message: String? = nil, fileName: String = #file, lineNumber: UInt = #line) {
        exceptionThrown = true
        RLMAssertThrowsWithName(self, { _ = block() }, named, message, fileName, lineNumber)
    }

    func assertThrows<T>(_ block: @autoclosure () -> T, reason: String,
                         _ message: String? = nil, fileName: String = #file, lineNumber: UInt = #line) {
        exceptionThrown = true
        RLMAssertThrowsWithReason(self, { _ = block() }, reason, message, fileName, lineNumber)
    }

    func assertThrows<T>(_ block: @autoclosure () -> T, reasonMatching regexString: String,
                         _ message: String? = nil, fileName: String = #file, lineNumber: UInt = #line) {
        exceptionThrown = true
        RLMAssertThrowsWithReasonMatching(self, { _ = block() }, regexString, message, fileName, lineNumber)
    }

    func assertSucceeds(message: String? = nil, fileName: StaticString = #file,
                        lineNumber: UInt = #line, block: () throws -> Void) {
        do {
            try block()
        } catch {
            XCTFail("Expected no error, but instead caught <\(error)>.",
                file: fileName, line: lineNumber)
        }
    }

    func assertFails<T>(_ expectedError: Realm.Error.Code, _ message: String? = nil,
                        fileName: StaticString = #file, lineNumber: UInt = #line,
                        block: () throws -> T) {
        do {
            _ = try block()
            XCTFail("Expected to catch <\(expectedError)>, but no error was thrown.",
                file: fileName, line: lineNumber)
        } catch let e as Realm.Error where e.code == expectedError {
            // Success!
        } catch {
            XCTFail("Expected to catch <\(expectedError)>, but instead caught <\(error)>.",
                file: fileName, line: lineNumber)
        }
    }

    func assertFails<T>(_ expectedError: Error, _ message: String? = nil,
                        fileName: StaticString = #file, lineNumber: UInt = #line,
                        block: () throws -> T) {
        do {
            _ = try block()
            XCTFail("Expected to catch <\(expectedError)>, but no error was thrown.",
                file: fileName, line: lineNumber)
        } catch let e where e._code == expectedError._code {
            // Success!
        } catch {
            XCTFail("Expected to catch <\(expectedError)>, but instead caught <\(error)>.",
                file: fileName, line: lineNumber)
        }
    }

    func assertNil<T>(block: @autoclosure() -> T?, _ message: String? = nil,
                      fileName: StaticString = #file, lineNumber: UInt = #line) {
        XCTAssert(block() == nil, message ?? "", file: fileName, line: lineNumber)
    }

    func assertMatches(_ block: @autoclosure () -> String, _ regexString: String, _ message: String? = nil,
                       fileName: String = #file, lineNumber: UInt = #line) {
        RLMAssertMatches(self, block, regexString, message, fileName, lineNumber)
    }

    private func realmFilePrefix() -> String {
        let name: String? = self.name
        return name!.trimmingCharacters(in: CharacterSet(charactersIn: "-[]"))
    }

    internal func testRealmURL() -> URL {
        return realmURLForFile("test.realm")
    }

    internal func defaultRealmURL() -> URL {
        return realmURLForFile("default.realm")
    }

    private func realmURLForFile(_ fileName: String) -> URL {
        let directory = URL(fileURLWithPath: testDir, isDirectory: true)
        return directory.appendingPathComponent(fileName, isDirectory: false)
    }
}

#if !swift(>=3.2)
func XCTAssertEqual<F: FloatingPoint>(_ expression1: F, _ expression2: F, accuracy: F,
                                      file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualWithAccuracy(expression1, expression2, accuracy: accuracy, file: file, line: line)
}
func XCTAssertNotEqual<F: FloatingPoint>(_ expression1: F, _ expression2: F, accuracy: F,
                                         file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotEqualWithAccuracy(expression1, expression2, accuracy, file: file, line: line)
}
#endif
