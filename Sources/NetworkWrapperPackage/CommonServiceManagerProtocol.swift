// SPDX-License-Identifier: EUPL-1.2

//
//  CommonServiceManagerProtocol.swift
//  NetworkWrapperPackage
//
//  Created by Matīss Mamedovs on 21/11/2024.
//

import Foundation

public protocol CommonServiceManagerProtocol: AnyObject {
    func requestCompleted()
    func requestFailed()
    func unauthorizedError()
    func criticalError()
    func unrecognizedError(code: String)
    func versionUpdateError(code: String)
}
