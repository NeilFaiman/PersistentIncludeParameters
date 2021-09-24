//
//  PersistentIncludeParametersTests.swift
//  PersistentIncludeParametersTests
//
//  Created by Neil Faiman on 7/18/20.
//  Copyright © 2020 Neil Faiman. All rights reserved.
//

import XCTest
@testable import PersistentIncludeParameters

class PersistentIncludeParametersTests: XCTestCase {

    func testNoParameters() {
        let params: BBEditIncludeParameters
        do {
            params = try BBEditIncludeParameters(arguments:
                "scriptPath", "includerPath")
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
        XCTAssertEqual(params.script, "scriptPath")
        XCTAssertEqual(params.includer, "includerPath")
        XCTAssertEqual(params.count, 0)
        XCTAssertNil(params["foo"])
    }
    
    func testOneParameter() {
        let params: BBEditIncludeParameters
        do {
            params = try BBEditIncludeParameters(arguments:
                "scriptPath", "includerPath", "FOO", "foobar")
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
        XCTAssertEqual(params.script, "scriptPath")
        XCTAssertEqual(params.includer, "includerPath")
        XCTAssertEqual(params.count, 1)
        XCTAssertEqual(params["foo"], "foobar")
        XCTAssertEqual(params["FOO"], "foobar")     // case insensitive
        XCTAssertNil(params["baz"])
    }

    func testThreeParameters() {
        let params: BBEditIncludeParameters
        do {
            params = try BBEditIncludeParameters(arguments:
                "scriptPath", "includerPath", "FOO1", "BAR1",
                              "foo2", "bar2", "foo3", "bar3")
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
        XCTAssertEqual(params.script, "scriptPath")
        XCTAssertEqual(params.includer, "includerPath")
        XCTAssertEqual(params.count, 3)
        XCTAssertEqual(params["foo1"], "BAR1")
        XCTAssertEqual(params["FOO2"], "bar2")
        XCTAssertEqual(params["foo3"], "bar3")
    }
    
    func testTooFewArguments() {
        do {
            let _ = try BBEditIncludeParameters(arguments:
                [])
        } catch let error as BBEditIncludeParameters.ArgumentsError {
            XCTAssertEqual(error.errorText, """
                           Argument array must contain the script and includer \
                           file paths
                           """)
            return
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
        do {
            let _ = try BBEditIncludeParameters(arguments: "scriptPath")
        } catch let error as BBEditIncludeParameters.ArgumentsError {
            XCTAssertEqual(error.errorText, """
                           Argument array must contain the script and includer \
                           file paths
                           """)
            return
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
    }
    
    func testOddArgumentCount() {
        do {
            let _ = try BBEditIncludeParameters(arguments:
                "scriptPath", "includerPath", "FOO")
        } catch let error as BBEditIncludeParameters.ArgumentsError {
            XCTAssertEqual(error.errorText,
                    "Argument array must contain matched name / value pairs")
            return
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
    }

    func testDuplicateParameter() {
        do {
            let _ = try BBEditIncludeParameters(arguments:
                "scriptPath", "includerPath", "FOO", "bar", "foo", "baz")
        } catch let error as BBEditIncludeParameters.ArgumentsError {
            XCTAssertEqual(error.errorText,
                    "Two parameters have the same name")
            return
        } catch {
            XCTFail("Unexpected error \(error) thrown from PersistentIncludeParameters initializer")
            return
        }
    }
    
    func testCustomStringConvertibleError() {
        let error = BBEditIncludeParameters.ArgumentsError(errorText: "The error")
        XCTAssertEqual(String(describing:error), "The error")
        XCTAssertEqual("\(error)", "The error")
    }
    
    func testSimplifiedErrorReporting() {
        XCTAssertNil(try? BBEditIncludeParameters(arguments: "foo"),
                     "try? of failing initializer must return nil")
        guard let _ = try? BBEditIncludeParameters(arguments: "foo", "bar") else {
            XCTFail("try? of successful initializer must return non-nil")
            return
        }
    }

}
