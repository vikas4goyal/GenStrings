#!/usr/bin/env xcrun -sdk macosx swift
//
//  main.swift
//  GenStrings
//
//  Created by Vikas Goyal on 02/06/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation

extension String {
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.characters.count))
        
        for match in matches{
            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            for i in 1...lastRangeIndex {
                let capturedGroupIndex = match.rangeAt(i)
                let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                results.append(matchedString)
            }
        }
        return results
    }
}
func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

private extension FileManager {
    
    func isDirectoryAtPath(path : String) -> Bool {
        let manager = FileManager.default
        do {
            let attribs: [FileAttributeKey : Any]? = try manager.attributesOfItem(atPath: path)
            if let attributes = attribs {
                let type = attributes[FileAttributeKey.type] as? String
                return type == FileAttributeType.typeDirectory.rawValue
            }
        } catch _ {
            return false
        }
    }
}

extension URL {
    var isDirectory: Bool {
        guard isFileURL else { return false }
        var directory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &directory) ? directory.boolValue : false
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
    var subFiles: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []
    }
}

func filterSwiftFiles(string:URL)->[URL]{
    var urls = [URL]()
    if(string.isDirectory){
        let subs = string.subFiles;
        for subDir in subs {
            let temp = filterSwiftFiles(string: subDir)
            urls.append(contentsOf: temp)
        }
        return urls
    }
    let name = string.lastPathComponent;
    if(name == "GenStrings.swift"){
        return urls
    }
    if(name.contains(".swift")){
        urls.append(string)
    }
    return urls
}

func filterxibStoryboardFiles(string:URL)->[URL]{
    var urls = [URL]()
    if(string.isDirectory){
        let subs = string.subFiles;
        for subDir in subs {
            let temp = filterxibStoryboardFiles(string: subDir)
            urls.append(contentsOf: temp)
        }
        return urls
    }
    let name = string.lastPathComponent;
    if(name == "GenStrings.swift"){
        return urls
    }
    if(name.contains(".storyboard") || name.contains(".xib")){
        urls.append(string)
    }
    return urls
}

func getAllSwiftStrings(rootUrl:URL)->Set<String>{
    let all = filterSwiftFiles(string: rootUrl)
    //    var allLocal = [String]()
    var keys = Set<String>()
    for item in all {
        let string = try! String(contentsOf: item)
        let matched = string.capturedGroups(withRegex:"\"(.*?)\".localized")
        //        keys.addObjects(from: matched)
        keys = keys.union(matched)
    }
    return keys
}

func getAllStringsForXibs(rootUrl:URL)->Set<String>{
    let all = filterxibStoryboardFiles(string: rootUrl)
    //    var allLocal = [String]()
    var keys = Set<String>()
    for item in all {
        let string = try! String(contentsOf: item)
        let matched = string.capturedGroups(withRegex: "keyPath=\"localizableString\" value=\"(.*?)\"")
        //        allLocal.append(contentsOf: matched)
        keys = keys.union(matched)
    }
    //    var keys = [String:String]()
    //    for strs in allLocal {
    //        let key = strs.replacingOccurrences(of: ".localized", with: "")
    //        keys[key] = key
    //    }
    return keys
}

func run(){
    //    let arguments = CommandLine.arguments
    let arguments = ["/Users/apple1/Desktop/bugs/New/Password Keeper/Password Keeper/GenStrings.swift","/Users/apple1/Desktop/bugs/New/Password Keeper/Password Keeper/","/Users/apple1/Desktop/bugs/New/Password Keeper/Password Keeper/Localization/Base.lproj/Localizable.strings"]
    
    let input = arguments[1]
    let output = arguments[2]
    
    if(FileManager.default.fileExists(atPath: output)){
        //  try! FileManager.default.removeItem(atPath: output);
    }
    let rootUrl = URL(fileURLWithPath: input)
    let stringsSwift = getAllSwiftStrings(rootUrl: rootUrl)
    let stringsXib = getAllStringsForXibs(rootUrl: rootUrl)
    let finalStrings = stringsSwift.union(stringsXib)
    print(finalStrings);
    
    FileManager.default.createFile(atPath: output, contents: nil, attributes: nil);
    guard let fileHandler = FileHandle(forWritingAtPath: output) else{
        print("filehandler is nil")
        return
    }
    for value in finalStrings{
        fileHandler.write("\"\(value)\" = \"\(value)\";\n".data(using: String.Encoding.utf8)!)
    }
    fileHandler.closeFile()
}
run()
