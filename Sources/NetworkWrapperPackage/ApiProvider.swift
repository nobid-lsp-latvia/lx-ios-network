// SPDX-License-Identifier: EUPL-1.2

//
//  ApiProvider.swift
//  NetworkWrapperPackage
//
//  Created by Matīss Mamedovs on 21/11/2024.
//

import Foundation
import Moya

open class ApiProvider {
        
    public init() {}
    
    fileprivate func getTargetName() -> String {
        guard let target = Bundle.main.object(forInfoDictionaryKey: "Backend") as? String else {
            return ""
        }
        
        return target
    }
    
    fileprivate func getInfoFile() -> NSDictionary? {
        if let path = Bundle.main.path(forResource: getTargetName(), ofType: "plist") {
            guard let dictionary = NSDictionary(contentsOfFile: path) else {
                return nil
            }
            
            return dictionary
        }
        
        return nil
    }
}

public class RefreshbleMoyaProvider<T: TargetType>: MoyaProvider<T> {
    
    public weak var delegate: CommonServiceManagerProtocol?
    
    @discardableResult
    public override func request(_ target: T,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               completion: @escaping Completion) -> Cancellable {
        
        return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                if response.statusCode == 401 || response.statusCode == 403 {
                    self.delegate?.unauthorizedError()
                } else if response.statusCode == 406 {
                    self.delegate?.versionUpdateError(code: String(response.statusCode))
                } else if response.statusCode == 500 {
                    self.delegate?.criticalError()
                } else if response.statusCode == 200 || response.statusCode == 404 {
                    self.delegate?.requestCompleted()
                } else {
                    self.delegate?.unrecognizedError(code: String(response.statusCode))
                }
                completion(result)
            case let .failure(error):
                let response : Response? = error.response
                let statusCode : Int? = response?.statusCode
                
                if statusCode == 401 || statusCode == 403 {
                    self.delegate?.unauthorizedError()
                } else if statusCode == 500 {
                    self.delegate?.criticalError()
                } else {
                    if response == nil && statusCode == nil {
                        break
                    } else {
                        self.delegate?.unrecognizedError(code: String(statusCode ?? 404))
                    }
                }
                print(error)
            }
        })
    }
}
