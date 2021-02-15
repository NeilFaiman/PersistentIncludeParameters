//
//  PersistentIncludeParameters.swift
//  PersistentIncludeParameters
//
//  Created by Neil Faiman on 7/17/20.
//  Copyright © 2020 Neil Faiman. All rights reserved.
//

import Foundation

/// Access the parameters from a script or program called from a BBEdit
/// persistent include construct.
///
/// BBEdit is the popular Mac text editor from
/// [Barebones Software](www.barebones.com).
///
/// A “persistent include” in a BBEdit HTML file is a pair of comments:
///
///     <!-- #bbinclude "include file" [ #name#="value" ]... -->
///     ...
///     <!-- end bbinclude -->
///
/// When the HTML file is updated, BBEdit replaces the text between the
/// comments. If the `include file` is a text file, then the replacement text
/// is a copy of the include file, with  occurrences of the `#name#` strings
/// replaced with the corresponding `value` strings from the `bbinclude`
/// comment. If the include file is an executable, then BBEdit runs it, passing
/// the file path of the including HTML file as the first command line argument,
/// and the parameter names and values as additional arguments. The standard
/// output from the include file execution becomes the replacement text.
///
/// The `PersistentIncludeParameters` struct provides a consistent
/// way of accessing the parameters in a Swift script that is included by a
/// persistent include. To use it, just create one:
///
///         let params = PersistentIncludeParameters()
///
/// Then
///
///  - `params.script` is the path to the script file.
///  - `params.includer` is the path to the HTML file that contains the
///     `bbinclude` directive.
///  - `params.count` is the number of `#name#="value"` pairs in the
///    include directive.
///  - If the include directive specified `#name#="value"`, then
///       `params["name"]` returns `"value"`.
///
public struct PersistentIncludeParameters {
    
    /// The file path of the script.
    public let script : String
    
    /// The file path of the including HTML file.
    public let includer: String
    
    /// Values of named parameters.
    ///
    /// persistentIncludeParameters["name"] == "value" if the persistent
    /// include contains the parameter `#name#="value"`.
    ///
    /// - Parameter name: A string that was specified as a parameter name
    ///   (enclosed in # marks) in the persistent include.
    ///
    /// - Returns: The string that was specified as the value of the parameter
    ///    with the specified name, or `nil` if the include did not have a
    ///    parameter with the specified name.
    ///
    /// - Note: Parameter names are case-insensitive.
    ///
    public subscript(name: String) -> String? {
        return parameters[name.uppercased()]
    }
    
    /// The number of parameters.
    public var count: Int {
        return parameters.count
    }
    
    private let parameters: [String: String]
    
    /// Error type thrown if an initializer argument array doesn’t
    /// match the expected format.
    public struct ArgumentsError : Error, CustomStringConvertible {
        /// Description of the error.
        public let errorText: String
        /// `CustomStringConvertible` conformance.
        public var description: String { errorText }
    }
    
    /// Initialize from the commmand line arguments.
    ///
    /// - Throws: ArgumentsError
    ///
    public init() throws {
        try self.init(arguments: CommandLine.arguments)
    }
    
    /// Initialize from an array of arguments (beginning with the path to the
    /// script or program).
    ///
    /// - Throws: ArgumentsError
    ///
    init(arguments: [String]) throws {
        guard arguments.count >= 2 else {
            throw ArgumentsError(errorText: """
                Argument array must contain the script and includer \
                file paths
                """)
        }
        script = arguments[0]
        includer = arguments[1].replacingOccurrences(of: "\\ ", with: " ")
        guard arguments.count % 2 == 0 else {
            throw ArgumentsError(errorText:
                "Argument array must contain matched name / value pairs")
        }
        let keys = stride(from: 2, to: arguments.count, by: 2)
            .map { arguments[$0].uppercased() }
        let values = stride(from: 3, to: arguments.count, by: 2)
            .map { arguments[$0] }
        try parameters = [String:String](zip(keys, values)) { _, _ in
            throw ArgumentsError(errorText:
                "Two parameters have the same name")
        }
    }

    /// Initializee from a list of arguments (beginning with the path to the
    /// script or program).
    ///
    /// - Throws: ArgumentsError
    ///
    init(arguments: String...) throws {
        try self.init(arguments: arguments)
    }

}
