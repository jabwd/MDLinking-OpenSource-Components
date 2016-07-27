//
//  SCNetworkReachability.swift
//  MDLinking
//
//  Created by Antwan van Houdt on 09/06/16.
//  Copyright © 2016 MDLinking.com B.V. All rights reserved.
//

import Foundation
import SystemConfiguration

enum NetworkStatus
{
	case unreachable
	case reachableWiFi
	case reachableCellular
}

protocol NetworkReachabilityDelegate
{
	func networkStatusChanged(reachability: NetworkReachability, newStatus: NetworkStatus)
}

func callback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, context: UnsafeMutablePointer<Void>)
{
	let reach = unsafeBitCast(context, NetworkReachability.self)
	reach.parseFlags(flags)
}

class NetworkReachability
{
	let reachability: SCNetworkReachability
	var delegate: NetworkReachabilityDelegate?
	var currentStatus: NetworkStatus = .unreachable
	
	init?()
	{
		guard let ref = SCNetworkReachabilityCreateWithName(nil, "airwave1.exurion.com") else {
			print("[Network] Unable to set up network reachability")
			return nil
		}
		reachability = ref
	}
	
	deinit
	{
		
	}
	
	func startObserving()
	{
		var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
		context.info = UnsafeMutablePointer(unsafeAddressOf(self))
		SCNetworkReachabilitySetCallback(reachability, callback, &context)
		
		SCNetworkReachabilitySetDispatchQueue(reachability, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
	}
	
	func parseFlags(flags: SCNetworkReachabilityFlags)
	{
		var status = NetworkStatus.unreachable
		if flags.contains(.Reachable) {
			if !flags.contains(.ConnectionOnTraffic) {
				status = NetworkStatus.reachableWiFi
				if flags.contains(.IsWWAN) {
					status = NetworkStatus.reachableCellular
				}
			}
		}
		statusChanged(status)
	}
	
	func statusChanged(status: NetworkStatus)
	{
		currentStatus = status
		delegate?.networkStatusChanged(self, newStatus: status)
	}
}
