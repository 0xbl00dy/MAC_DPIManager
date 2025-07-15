// Code of PrivilegedOperations.swift


import Foundation

class PrivilegedOperations {
    static func runCommand(command: String, arguments: [String], completion: @escaping (Bool, String) -> Void) {
        let script = "do shell script \"\(command) \(arguments.joined(separator: " "))\" with administrator privileges"
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            //completion(false, "Error: \(error)") - for debug
            completion(false, "Failed!")
        } else {
            completion(true, "Operation completed successfully")
        }
    }
}
