//
//  BaseService.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation
import Alamofire
import RxSwift

class BaseService {
    private var baseHeader: HTTPHeaders
    init() {
        baseHeader = HTTPHeaders()
        if AuthService.isLoggedIn() {
            baseHeader.add(HTTPHeader(name: HeaderRequest.token.rawValue, value: "Bearer " + AuthService.getAuthInfo(info: KeyAuth.token)))
        }
    }
    
    func createRequest<Body: Codable, Response: Codable>(api: ApiConstants, method: HTTPMethod, parameters: Body, headers: [String: String]? = nil) -> Observable<Response> {
        let url = Base.url.rawValue + api.rawValue
        if headers != nil {
            for header in headers! {
                baseHeader.add(name: header.key, value: header.value)
            }
        }
        let request = AF.request(url, method: method, parameters: parameters, encoder: .json, headers: self.baseHeader)
        return performRequest(request: request)
    }

    func createRequest<Response: Codable>(api: ApiConstants, method: HTTPMethod, headers: [String: String]? = nil) -> Observable<Response> {
        let url = Base.url.rawValue + api.rawValue
        if headers != nil {
            for header in headers! {
                baseHeader.add(name: header.key, value: header.value)
            }
        }
        let request = AF.request(url, method: method, headers: self.baseHeader)
        return performRequest(request: request)
    }

    func request<Params: Encodable, Response: Codable>(api: ApiConstants, headers: [String: String] = [:], params: Params) -> Observable<Response> {
        let url = Base.url.rawValue + api.rawValue
        headers.forEach { baseHeader.add(name: $0.key, value: $0.value) }

        guard let methodSupport = HTTPMethod.convert(api.method) else {
            return Observable.create { response in
                Disposables.create {
                    return response.onError(ServiceError.invalidMethod)
                }
            }
        }
        if methodSupport == .get {
            return performRequest(request: AF.request(url, method: methodSupport, parameters: params, encoder: URLEncodedFormParameterEncoder.default, headers: self.baseHeader))
        } else {
            return performRequest(request: AF.request(url, method: methodSupport, parameters: params, encoder: .json, headers: self.baseHeader))
        }
    }

    func request<Response: Codable>(api: ApiConstants, headers: [String: String] = [:], params: Parameters? = nil) -> Observable<Response> {
        let url = Base.url.rawValue + api.rawValue
        headers.forEach { baseHeader.add(name: $0.key, value: $0.value) }
        guard let methodSupport = HTTPMethod.convert(api.method) else {
            return Observable.create { response in
                Disposables.create {
                    return response.onError(ServiceError.invalidMethod)
                }
            }
        }

        if methodSupport == .get {
            return performRequest(request: AF.request(url, method: methodSupport, encoding: URLEncoding.default, headers: self.baseHeader))
        }
        else {
            return performRequest(request: AF.request(url, method: methodSupport, parameters: params, encoding: JSONEncoding.default, headers: self.baseHeader))
        }
    }

    func request<Params: Encodable, Response: Codable>(api: String, method: HTTPMethodSupport, headers: [String: String] = [:], params: Params) -> Observable<Response> {
        let url = Base.url.rawValue + api
        headers.forEach { baseHeader.add(name: $0.key, value: $0.value) }
        guard let methodSupport = HTTPMethod.convert(method) else {
            return Observable.create { response in
                Disposables.create {
                    return response.onError(ServiceError.invalidMethod)
                }
            }
        }
        return performRequest(request: AF.request(url, method: methodSupport, parameters: params, encoder: .json, headers: self.baseHeader))
    }

    func request<Response: Codable>(api: String, method: HTTPMethodSupport, headers: [String: String] = [:], params: Parameters? = nil) -> Observable<Response> {
        let url = Base.url.rawValue + api
        headers.forEach { baseHeader.add(name: $0.key, value: $0.value) }
        guard let methodSupport = HTTPMethod.convert(method) else {
            return Observable.create { response in
                Disposables.create {
                    return response.onError(ServiceError.invalidMethod)
                }
            }
        }
        return performRequest(request: AF.request(url, method: methodSupport, parameters: params, encoding: JSONEncoding.default, headers: self.baseHeader))
    }

    private func performRequest<Response: Codable>(request: DataRequest) -> Observable<Response> {
        AF.sessionConfiguration.timeoutIntervalForRequest = 30
        AF.sessionConfiguration.timeoutIntervalForResource = 60
        return Observable.create { observer in
            request.responseDecodable(of: ResponseMain<Response>.self) { response in
                var error: Error? = nil
                if response.error != nil {
                    error = ServiceError.network
                } else if let data = response.value {
                    switch data.statusCode {
                    case StatusCode.OK:
                        if let payload = data.payload {
                            observer.onNext(payload)
                        }
                        observer.onCompleted()
                    case StatusCode.BAD_REQUEST:
                        error = ServiceError.badRequest(message: data.message)
                    case StatusCode.UNAUTHORIZED:
                        error = ServiceError.unauthorized(message: data.message)
                    case StatusCode.SERVER_ERROR:
                        error = ServiceError.serverError(message: data.message)
                    default:
                        error = ServiceError.unknown(message: "Unknown")
                    }
                } else {
                    error = ServiceError.unknown(message: "Unknown")
                }

            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

extension HTTPMethod {
    static func convert(_ methodSupport: HTTPMethodSupport) -> Self? {
        if methodSupport == .post { return .post }
        else if methodSupport == .get { return .get }
        else if methodSupport == .put { return .put }
        else if methodSupport == .patch { return .patch}
        else { return nil }
    }
}

