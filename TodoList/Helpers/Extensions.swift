//
//  Extensions.swift
//  TodoList
//
//  Created by Daulet Ashikbayev on 26.06.2023.
//

import UIKit

extension UIViewController {
    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView() {
        view.endEditing(true)
    }
}

extension URLSession {
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await dataTask(for: URLRequest(url: url))
    }
    
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        let onCancel: @Sendable () -> Void = { [weak task] in
            task?.cancel()
        }
        
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    task = self.dataTask(with: urlRequest) { data, response, error in
                        guard let data, let response else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }
                        
                        continuation.resume(returning: (data, response))
                    }
                    
                    task?.resume()
                }
            },
            onCancel: {
                onCancel()
            })
    }
}
