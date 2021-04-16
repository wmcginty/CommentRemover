//
//  SourceEditorCommand.swift
//  CommentRemover
//
//  Created by Will McGinty on 4/15/21.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    private let singleLineComment = "//"
    private let multiLineCommentStart = "/*"
    private let multiLineCommentEnd = "*/"
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let lines = invocation.buffer.lines
        
        var emptyLines = IndexSet()
        var inMultiLineComment = false
        
        for (index, line) in lines.enumerated() {
            guard var lineString = (line as? String).map({ $0[...] }),
                  !lineString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            // Look for a single-line comment
            if let range = lineString.range(of: singleLineComment) {
                lineString = lineString[..<range.lowerBound]
            }
            
            // If in the midst of a mult-line comment, check for the end of it
            if inMultiLineComment {
                if let endRange = lineString.range(of: multiLineCommentEnd) {
                    inMultiLineComment = false
                    lineString = lineString[endRange.upperBound...]
                    
                } else {
                    lineString = ""
                }
                
            } else if let startRange = lineString.range(of: multiLineCommentStart) {
                
                if let endRange = lineString.range(of: multiLineCommentEnd) {
                    lineString = lineString[..<startRange.lowerBound] + lineString[endRange.upperBound...]
                } else {
                    inMultiLineComment = true
                    lineString = lineString[..<startRange.lowerBound]
                }
            }
            
            
            lines[index] = String(lineString)
            if lineString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                emptyLines.insert(index)
            }
        }
        
        lines.removeObjects(at: emptyLines)
        completionHandler(nil)
    }
    
}
