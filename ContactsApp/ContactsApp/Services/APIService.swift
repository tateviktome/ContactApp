//
//  APIService.swift
//  ContactsApp
//
//  Created by STDev on 8/2/19.
//  Copyright © 2019 STDev. All rights reserved.
//

import Foundation

typealias Callback<T: Codable> = (T?, Error?) -> ()
typealias ArrayCallback<T: Codable> = ([T]?, Error?) -> ()
typealias DataCallback = (Data?, Error?) -> ()

class APIService {
    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }
    
    static let shared = APIService()
    
    @discardableResult
    func getContacts(callback: @escaping ArrayCallback<Contact>) -> URLSessionDataTask? {
        return self.requestArray(endpoint: APIEndpoints.contacts, method: .get, callback: callback)
    }
    
    @discardableResult
    func getImage(id: String, callback: @escaping DataCallback) -> URLSessionDataTask? {
        return self.requestData(endpoint: APIEndpoints.media + "/" + id, method: .get, callback: callback)
    }
    
    @discardableResult
    func addContact(details: [String: Any], callback: @escaping DataCallback) -> URLSessionDataTask? {
        return self.requestData(endpoint: APIEndpoints.contacts, method: .post, body: details, callback: callback)
    }
    
    @discardableResult
    func updateContact(details: [String: Any], id: String, callback: @escaping DataCallback) -> URLSessionDataTask? {
        return self.requestData(endpoint: APIEndpoints.contacts + "/" + id, method: .put, body: details, callback: callback)
    }
    
    @discardableResult
    func getContact(id: String, callback: @escaping Callback<Contact>) -> URLSessionDataTask? {
        return self.request(endpoint: APIEndpoints.contacts + "/" + id, method: .get, callback: callback)
    }
    
    @discardableResult
    func deleteContact(id: String, callback: @escaping DataCallback) -> URLSessionDataTask? {
        return self.requestData(endpoint: APIEndpoints.contacts + "/" + id, method: .delete, callback: callback)
    }
}

//MARK: generic methods
extension APIService {
    private func getRequestURL(endpoint: String, method: RequestMethod, body: [String: Any]? = [:]) -> URLRequest? {
        guard let url = URL(string: endpoint) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("a5b39dedacbffd95e1421020dae7c8b5ac3cc", forHTTPHeaderField: "x-apikey")
        
        if let body = body, !body.isEmpty {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body,
                                                          options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch (let error) {
                print(error)
            }
        }
        return request
    }
    
    fileprivate func request<T: Codable>(endpoint: String, method: RequestMethod, callback: @escaping Callback<T>) -> URLSessionDataTask? {
        guard let request = getRequestURL(endpoint: endpoint, method: method) else { return nil }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                callback(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode(T.self, from: data)
                callback(value, nil)
            } catch let err {
                print("Err: ", err)
            }
        }
        task.resume()
        return task
    }
    
    fileprivate func requestArray<T: Codable>(endpoint: String, method: RequestMethod, callback: @escaping ArrayCallback<T>) -> URLSessionDataTask? {
        guard let request = getRequestURL(endpoint: endpoint, method: method) else { return nil }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                callback(nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let values = try decoder.decode([T].self, from: data)
                callback(values, nil)
            } catch let err {
                print("Err: ", err)
            }
        }
        task.resume()
        return task
    }
    
    fileprivate func requestData(endpoint: String, method: RequestMethod, body: [String: Any]? = nil, callback: @escaping DataCallback) -> URLSessionDataTask? {
        guard let request = getRequestURL(endpoint: endpoint, method: method, body: body) else { return nil }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                callback(nil, error)
                return
            }
            callback(data, nil)
        }
        task.resume()
        return task
    }
}
