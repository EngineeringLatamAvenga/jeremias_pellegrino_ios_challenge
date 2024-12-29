//
//  Storage.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import Foundation
import CryptoKit

class Storage {
    
    private let fileManager: FileManager = .default
    
    ///Naming obfuscation to improve security
    func encryptFilename(filename: String) -> String {
        return SHA512.hash(data: Data(filename.utf8)).description
    }
    
    private func makeURL(forFilename filename: String) throws -> URL {
        let url = try fileManager.url(for: .applicationSupportDirectory,
                                      in: .userDomainMask,
                                      appropriateFor: nil,
                                      create: true)
        let obfuscatedFilename = encryptFilename(filename: filename)
        return url.appendingPathComponent(obfuscatedFilename)
    }
    
    func store(data: Data, filename: String, overwrite: Bool = true) throws {
        let obfuscatedFilename = encryptFilename(filename: filename)
        let url = try makeURL(forFilename: obfuscatedFilename)
        if !overwrite && fileManager.fileExists(atPath: url.absoluteString) {
            throw NSError.init(domain: NSCocoaErrorDomain, code: NSFileWriteFileExistsError)
        }
        return try data.write(to: url)
    }
    
    func read(filename: String) throws -> Data {
        let obfuscatedFilename = encryptFilename(filename: filename)
        let url = try makeURL(forFilename: obfuscatedFilename)
        guard !fileManager.fileExists(atPath: url.absoluteString) else {
            throw NSError.init(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError)
        }
        return try Data(contentsOf: url)
    }
    
    func encodeAndSave(item: Codable, to key: String) throws {
        let encodedData = try JSONEncoder().encode(item)
        try store(data: encodedData, filename: key)
    }
    
    func loadAndDecode<T: Codable>(from key: String, to modelOfType: T.Type) throws -> T {
        let data = try read(filename: key)
        let res = try JSONDecoder().decode(modelOfType, from: data)
        return res
    }
}
