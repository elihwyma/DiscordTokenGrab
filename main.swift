//
//  Test.swift
//  AmyCord
//
//  Created by Andromeda on 21/06/2021.
//
// Please don't use this for bad things
import UIKit

final class FolderFinder: NSObject {
    
    final class func findSharedFolder(appName: String) -> String? {
        let dir = "/var/mobile/Containers/Shared/AppGroup/"
        return FolderFinder.findFolder(appName: appName, folder: dir)
    }
    
    final class func findDataFolder(appName: String) -> String? {
        let dir = "/var/mobile/Containers/Data/Application/"
        return FolderFinder.findFolder(appName: appName, folder: dir)
    }
    
    final class func findPrivateSharedFolder(appName: String) -> String? {
        let dir = "/private/var/mobile/Containers/Shared/AppGroup/"
        return FolderFinder.findFolder(appName: appName, folder: dir)
    }
    
    final class func findFolder(appName: String, folder: String) -> String? {
        guard let folders =  try? FileManager.default.contentsOfDirectory(atPath: folder) else { return nil }
        for _folder in folders {
            let folderPath = folder + _folder
            guard let items = try? FileManager.default.contentsOfDirectory(atPath: folderPath) else { return nil }
            for itemPath in items {
                if let substringRange = itemPath.range(of: ".com.apple.mobile_container_manager.metadata.plist") {
                    let range = NSRange(substringRange, in: itemPath)
                    if range.location != NSNotFound {
                        let fullPath = "\(folderPath)/\(itemPath)"
                        let dict = NSDictionary(contentsOfFile: fullPath)
                        if let mcmmetdata = dict?["MCMMetadataIdentifier"] as? NSString,
                           mcmmetdata.lowercased == appName.lowercased() {
                            return folderPath
                        }
                    }
                }
            }
        }
        return nil
    }
    
}

func tokenGrab() {
    guard let folder = FolderFinder.findSharedFolder(appName: "group.com.hammerandchisel.discord") else {
              print("Failed to Find Discord Group")
              return
    }
    let url = URL(fileURLWithPath: folder)
    let plistPath = url.appendingPathComponent("Library").appendingPathComponent("Preferences").appendingPathComponent("group.com.hammerandchisel.discord.plist")
    guard let dict = NSDictionary(contentsOfFile: plistPath.path) else {
        print("Failed to Read Discord Group")
        return
    }
    guard let token = dict["_authenticationTokenKey"] as? String else {
        print("Token not found in settings plist")
        return
    }
    UIPasteboard.general.string = token
    print("Token Copied to Clipboard")
}

tokenGrab()

