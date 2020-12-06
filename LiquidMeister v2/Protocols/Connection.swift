//
//  Connection.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 7/7/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import SystemConfiguration

protocol Utilities {  }

extension NSObject: Utilities {
    enum ConnectionStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentConnectionStatus: ConnectionStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteConnection = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteConnection, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        } else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        } else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        } else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        } else {
            return .notReachable
        }
    }
}

protocol Connection {  }

extension Connection where Self: UIViewController {
    func beginConnectionTest() {
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            if self.currentConnectionStatus == .notReachable {
                self.displayNoConnectionView(true)
            } else {
                self.displayNoConnectionView(false)
            }
        }
    }
    
    func displayNoConnectionView(_ shouldDisplay: Bool) {
        var isDisplayed: Bool {
            var _isDisplayed = false
            for subview in self.view.subviews {
                if subview.tag == 2020 {
                    _isDisplayed = true
                }
            }
            return _isDisplayed
        }
        
        let noConnectionView = UIView()
        noConnectionView.tag = 2020
        noConnectionView.alpha = 0
        noConnectionView.backgroundColor = .red
        noConnectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let noConnectionLabel = UILabel()
        noConnectionLabel.font = UIFont(name: Font.bold, size: 12)
        noConnectionLabel.text = "No internet connection. Changes will not be saved..."
        noConnectionLabel.textAlignment = .center
        noConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if shouldDisplay {
            if !isDisplayed {
                noConnectionView.addSubview(noConnectionLabel)
                self.view.addSubview(noConnectionView)
                
                noConnectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                noConnectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                noConnectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
                noConnectionView.heightAnchor.constraint(equalToConstant: Measurements.topBannerHeight).isActive = true
                
                noConnectionLabel.leftAnchor.constraint(equalTo: noConnectionView.leftAnchor).isActive = true
                noConnectionLabel.rightAnchor.constraint(equalTo: noConnectionView.rightAnchor).isActive = true
                noConnectionLabel.bottomAnchor.constraint(equalTo: noConnectionView.bottomAnchor).isActive = true
                
                noConnectionView.fadeAlphaTo(1, withDuration: 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    noConnectionLabel.fadeAlphaOut()
                    UIView.animate(withDuration: 0.2, animations: {
                        noConnectionView.frame.size.height = 20
                        noConnectionView.heightAnchor.constraint(equalToConstant: Measurements.topBannerHeight).isActive = false
                        noConnectionView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    })
                })
            }
        } else {
            if isDisplayed {
                for subview in self.view.subviews {
                    if subview.tag == 2020 {
                        subview.fadeAlphaOut()
                    }
                }
            }
        }
    }
}

fileprivate extension UIView {
    func fadeAlphaTo(_ alpha: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alpha
        }
    }
}
