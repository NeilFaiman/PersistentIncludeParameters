#  Persistent Include Parameters

A utility for accessing parameters in a Swift script included from a BBEdit persistent include directive

## Purpose

BBEdit is the popular Mac text editor from [Barebones Software](http://www.barebones.com).

A “BBEdit persistent include” in an HTML file is a pair of special comments:

    <!-- #bbinclude "include file" [ #name#="value" ]... -->
    ...
    <!-- end bbinclude -->

When the BBEdit `update` command is applied to the file, any text between the comments is replaced. If the `include file` is a text file, then the replacement text is a copy of the include file, with  occurrences of the `#name#` strings replaced with the corresponding `value` strings from the `bbinclude` comment. If  the include file is an executable or a command line script file, then BBEdit runs it, passing the file path of the including HTML file as the first argument, and the parameter names and values as additional arguments. The standard output from the include file execution is used as the replacement text.

This project defines a structure which simplifies retrieving and accessing the parameters in a persistent include script written  in [Swift](http://www.swift.org).

## API

### Import

The product from this project is a framework file which defines a Swift module. To use it, you must import the module:

    import PersistentIncludeParameters

### Instantiate

To retrieve and parse the command line arguments, create an instance of the `PersistentIncludeParameters` structure type:

    let parameters = try PersistentIncludeParameters()

If there is a problem processing the argument list, the initializer will throw a `PersistentIncludeParameters.ArgumentsError`, which is a structure containing a single string component:

    public struct ArgumentsError : Error, CustomStringConvertible {
         /// Description of the error.
         public let errorText: String
     }

`ArgumentsError` can be directly converted to a `String` in a string interpolation or with `String(describing:)`, so if you want your script to provide useful information when something goes wrong in the parameter processing, you would do something like this:

    let parameters: PersistentIncludeParameters
    do {
        parameters = try PersistentIncludeParameters()
    } catch {
        print("Error in persistent include parameters: \(error)")
        exit(EXIT_FAILURE)
    }

You can simplify the code, at the expense of debugability when something goes wrong:

    guard let parameters = try? PersistentIncludeParameters() else {
        print("Error in persistent include parameters")
        exit(EXIT_FAILURE)
    }
    
### Access

Once you have instantiated a `PersistentIncludeParameters` structure, you can query it to obtain the information that was passed to your script.

#### Properties

  * `includer`: A string containing the file system path to the including HTML file  (the file that is being updated by BBEdit).
  * `script`: A string containing the file system path to this Swift file that is   being executed.
  * `count`: The number of name/value pairs in the parameter list.
  
  #### Parameters

Fetch the actual include parameters with subscript notation. For example, if the `bbinclude` comment in the HTML file contains `#display_style#="table"`, then in the script:
    
    parameters["display_style"] == "table"

Note that parameter names are case-insensitive, both as written in the HTML file and as accessed in the script. For example, the parameter in the HTML file could be written `#headerLevel#="2"` but could then be accessed as `parameters["HEADERLEVEL"]` in the script.

Parameter references return an  optional `String`. If the include in the HTML file does not contain a `#display_style#=` parameter, then

    parameters["display_style"] == nil

## Using the Project

### Downloading and Building

On the [project GitHub page](https://github.com/NeilFaiman/PersistentIncludeParameters), click the green “Code” download button, and from the dropdown menu, click “Open with Xcode.” Xcode will clone the repository to a location that you specify and build the project.

Alternatively, you can clone [the repository](https://github.com/NeilFaiman/PersistentIncludeParameters.git) from GitHub, open the `PersistentIncludeParameters.xcodeproj` file in Xcode, and build it.

In either case, you can run the unit tests (menu `Product ➤ Test` or ⌘U) to confirm that the build was successful.

### Deploying

The product of the build is the `PersistentIncludeParameters.framework` file, which you will find in the Xcode Project navigator sidebar (⌘1). You need to make it available to be include by your scripts. 

Right-click on it and choose “Reveal in Finder”. Then copy it to your user Frameworks folder, `~/Library/Frameoworks`. (You might need to create the folder if it doesn’t already exist.)

Note that you will need to repeat this step any time you modify and rebuild the framework.

### Creating a script

These instructions are the result of trial and error. There may well be a better way, but this seems to work, at least for me.

#### Coding

You are ultimately going to put your script file where BBEdit can find it: either in a BBEdit project “Templates and Includes” directory, or right in the web site folder with you HTML files. But I recommend _creating_ it in Xcode, where it will be easier to develop and test it. (If there are Swift errors in your include file, you you will just get a generic failure message when BBEdit tries to run it—no useful information at all. In theory, you should be able to test-run it in the Terminal, but that hasn’t worked for me. The strategy described here is a little awkward, but it works.)

  * Create a new project in Xcode and choose the Application ➤ Command Line Tool template. Give it any name you like and choose Swift for the language.
  * In the project’s source folder, create a Swift file named `main.swift`. (The name is mandatory. The top-level code in the source file named `main.swift` is defined to be the program entry point in a stand-alone Swift program, like the  `main()` function in a C program.)
  * Add the `PersistentIncludeParameters` framework to the project:
    * Click on the project name at the top of the Xcode Project navigator sidebar (⌘1). 
    * In the project editor, click the project name under “Targets” (_not_ under “Project”.) 
    * Select “General” from the categories at the top. 
    * Drag `PersistentIncludeParameters.framework` from the Finder into the  space labeled “Add frameworks and libraries here” in the “Frameworks and  Libraries” section.
    * Put these lines at the beginning of the program.

            import Foundation
            import PersistentIncludeParameters

        (You don’t need to import `Foundation` if you are coding purely against the Swift standard Library, but you will need it if you want to do anything else—work with the file system, for example.)
  * Write your script program. Use a `PersistentIncludeParameters` structure to get the include parameters. Use `print` calls to write the text that will be included in the HTML file.



#### Testing

Set up the command line arguments that would be passed by BBEdit if it was running the program as an include script:

  * Choose menu Product ➤ Scheme ➤ Edit scheme… (⌘<)
  * In the scheme editor dialog box, choose “Run” from the sidebar and “Arguments” at the top.
  * In the “Arguments Passed On Launch” panel, use the “+” button to add the arguments that will be passed by BBEdit when it runs the file as an include script:
      1. The full path of an HTML file.
      2. The first include parameter name (_without_ the hash marks).
      3. The first include parameter value (_without_ the qiuote marks).
      4. …
  * Close the scheme editor.

Run the program with menu Product  ➤ Run or ⌘R. The program program output will appear in the output pane, which will open at the bottom of the editor window. This should be the text that you would want as the persistent include text when you actually use the script.

#### Deploying

When you have the program working the way you want, it is time to turn it into an include script.

Add a “shebang” line as the first line of the program:
    
    #!/usr/bin/swift -F /Users/your-name/Library/Frameworks

This line is ignored where you are compiling and running the file in Xcode, but it is necessary when you want to run the file as a script. (The hash sign is not normally a valid Swift comment marker, but Swift has a special dispensation for shebang lines).

Now copy `main.swift` to the directory that BBEdit will expect to find it in—usually either the BBEdit project `Templates and Includes` directory, or the project directory that contains the including HTML file. (You can just option-drag it from the Xcode project navigator, or you can find it in the Finder and copy it from there.) Rename it to the name used in the `bbinclude` directive.

You should be good to go!
