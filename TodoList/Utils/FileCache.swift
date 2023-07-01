//
//  FileCache.swift
//  TodoItem
//
//  Created by Daulet Ashikbayev on 15.06.2023.
//

import Foundation

enum FileCacheError: Error {
    case notFound
    case notSupported
    case failedToRead
    case failedToWrite
}

class FileCache {
    private enum Constants {
        static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    }

    private(set) var items: [String: TodoItem] = [:]

    init() {
        print(Constants.documentDirectory)
    }

    func add(_ item: TodoItem) {
        items[item.id] = item
    }

    func remove(_ id: String) {
        items[id] = nil
    }

    func saveToJSONFile() throws {
        let fileURL = Constants.documentDirectory[0].appendingPathComponent("Items.json")

        guard
            let jsonArray = items.values.map({ $0.json }) as? [Any],
            let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonArray,
                options: .prettyPrinted
            )
        else {
            throw FileCacheError.failedToWrite
        }

        try? jsonData.write(to: fileURL)
    }

    func load(from file: String) throws {
        guard let directory = Constants.documentDirectory.first else {
            throw FileCacheError.notFound
        }

        let path = directory.appendingPathComponent("\(file).json")
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = json as? [Any] else {
            throw FileCacheError.notSupported
        }

        let deserializeItems = json.compactMap { TodoItem.parse(json: $0) }
        items = deserializeItems.reduce(into: [:]) { res, item in
            res[item.id] = item
        }
    }

    func saveCSV(to file: String) throws {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.notFound
        }

        let path = directory.appendingPathComponent("\(file).csv")
        let csvString = items.values.map { $0.csv }.joined()
        try csvString.write(to: path, atomically: true, encoding: .utf8)
    }

    func loadCSV(from file: String) throws {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.notFound
        }

        let path = directory.appendingPathComponent("\(file).csv")
        let csvString = try String(contentsOf: path)
        let csvRows = csvString.components(separatedBy: .newlines)
        let csvItems = csvRows.compactMap { TodoItem.parse(csv: $0) }
        items = csvItems.reduce(into: [:]) { res, item in
            res[item.id] = item
        }
    }
}
