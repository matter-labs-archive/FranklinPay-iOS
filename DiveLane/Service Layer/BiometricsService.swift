//
//  BiometricsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import LocalAuthentication

typealias SuccessCallback = (() -> Void)
typealias FailureCallback = ((LocAError) -> Void)

public enum LocAError {
    case userCancelled, failed, systemCancelled, biometryNotAvailable, biometryLockedOut, other

    static func initError(_ error: LAError) -> LocAError {
        switch Int32(error.errorCode) {
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return userCancelled
        case kLAErrorSystemCancel:
            return systemCancelled
        case kLAErrorBiometryLockout:
            return biometryLockedOut
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
        default: return other
        }
    }

    func getErrorMessage() -> String {
        switch self {
        case .biometryNotAvailable: return biometricsNotAvailableReason
        case .biometryLockedOut: return biometricsPincodeAuthenticationStringReason
        case .userCancelled, .systemCancelled: return ""
        default: return defaultBiometricsAuthenticationStringReason
        }
    }
}

let biometricsAuthenticationStringReason = "Confirm your biometrics to authenticate."

let biometricsPincodeAuthenticationStringReason = "Your biometrics locked. You did too many attempts, enter pincode for order to unlock biometrics"

let defaultBiometricsAuthenticationStringReason = "Biometrics do not recognize you, please try again"

let biometricsNotAvailableReason = "Authentication not available on your devaice "

public class BiometricsManager: NSObject {

    public static let shared = BiometricsManager()

    class func canAuth() -> Bool {
        var isAvailableAuthentication = false
        var error: NSError?

        isAvailableAuthentication = LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return error == nil ? isAvailableAuthentication : false
    }

    /// Check for authentication
    class func authenticateBioMetrics(reason: String, cancelString: String? = nil, fallbackString: String? = "", success: @escaping SuccessCallback, failure: @escaping FailureCallback) {

        let stringReason: String = reason.isEmpty ? BiometricsManager.shared.defaultReason() : reason

        let context = LAContext()

        context.localizedFallbackTitle = fallbackString

        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = cancelString
        }

        BiometricsManager.shared.evaluate(context: context, reason: stringReason, policy: LAPolicy.deviceOwnerAuthenticationWithBiometrics, sucess: success, failure: failure)
    }

    class func authenticatePasscode(reason: String, cancelTitle: String? = "", success: @escaping SuccessCallback, failure: @escaping FailureCallback) {
        let stringReason = reason.isEmpty ? BiometricsManager.shared.defaultPincodeReason() : reason

        let context = LAContext()

        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = cancelTitle
        }

        if #available(iOS 9.0, *) {
            BiometricsManager.shared.evaluate(context: context, reason: stringReason, policy: LAPolicy.deviceOwnerAuthentication, sucess: success, failure: failure)
        } else {
            BiometricsManager.shared.evaluate(context: context, reason: stringReason, policy: LAPolicy.deviceOwnerAuthenticationWithBiometrics, sucess: success, failure: failure)
        }

    }

    /// Get authentication reason
    private func defaultReason() -> String {
        return biometricsAuthenticationStringReason
    }

    private func defaultPincodeReason() -> String {
        return biometricsPincodeAuthenticationStringReason
    }

    ///Evaluate with policy
    private func evaluate(context: LAContext,
                          reason: String,
                          policy: LAPolicy,
                          sucess successBlock: @escaping SuccessCallback,
                          failure failBlock: @escaping FailureCallback) {
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    successBlock()
                } else {
                    DispatchQueue.main.async {
                        guard let error = error as? LAError else {
                            return
                        }
                        let typeError = LocAError.initError(error)
                        failBlock(typeError)
                    }
                }
            }
        }
    }

}
