//
//  NSDate+MDLinking.swift
//  MDLinking
//
//  Created by Antwan van Houdt on 27/07/16.
//  Copyright © 2016 MDLinking.com B.V. All rights reserved.
//  For license see LICENSE in the repository this file originated from
//

import Foundation

///
/// This subclass is mostly intended for caching NSDateFormatter instances
/// with custom parameters as in most use cases they will be used rather often
/// ( For instance every UITableView reload )
///
class MDFormatter: NSDateFormatter
{
	static let shared        = MDFormatter()
	static let dayFormatter  = MDFormatter(isDay: true)
	static let dateFormatter = MDFormatter(isDay: false)
	
	override init()
	{
		super.init()
		self.dateStyle = .NoStyle
		self.timeStyle = .ShortStyle
		self.dateFormat = "HH:mm"
	}
	
	init(isDay: Bool)
	{
		super.init()
		self.dateStyle = .NoStyle
		self.timeStyle = .ShortStyle
		
		if( isDay ) {
			self.dateFormat = "EEEE"
		} else {
			self.dateFormat = "EE/MM/YY"
		}
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		return nil
	}
}

extension NSDate
{
	///
	/// Returns a short formatted datestring intended to be used very similarly
	/// to the date components shown in the WhatsApp Chat list
	/// If the current NSDate instance is more than 6 days behind the current day
	/// this method will return a regular date format.
	///
	/// - Returns: A simple timestamp, or the name of he day or a regular short date
	///
	func mdString() -> String
	{
		// Formats of the date are determined by the NSDateFormatter subclass MDFormatter
		// Determine whether its days behind today.
		if( self.isToday() == false ) {
			// if its a week behind we get a normal date string, otherwise we go for
			// the name of the day.
			if( isYesterday() ) {
				return "Yesterday"
			} else {
				// Determine whether we should do a normal date
				if NSDate().dateByAdding(-6).reduced().timeIntervalSince1970 >= self.reduced().timeIntervalSince1970 {
					return MDFormatter.dateFormatter.stringFromDate(self)
				}
				return MDFormatter.dayFormatter.stringFromDate(self)
			}
		}
		return MDFormatter.shared.stringFromDate(self)
	}
	
	// MARK: -
	// MARK: Factual macro's
	
	func isYesterday() -> Bool
	{
		if( NSDate().reduced().dateByAdding(-1).isEqualToDate(self.reduced()) ) {
			return true
		}
		return false
	}
	
	func isToday() -> Bool
	{
		if( self.reduced().isEqualToDate(NSDate().reduced()) ) {
			return true
		}
		return false
	}
	
	// MARK: -
	// MARK: Modification macro's
	
	func dateByAdding(days: Int) -> NSDate
	{
		return NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: days, toDate: self, options: []) ?? NSDate()
	}
	
	///
	/// Reduces the current NSDate instance to the start of the day allowing it to be more
	/// easily compared with other NSDate instances when the time is not of importance.
	///
	/// - Returns: Reduced NSDate instance or self on failure
	///
	func reduced() -> NSDate
	{
		let cal = NSCalendar.currentCalendar()
		let components = cal.components([.Era, .Year, .Month, .Day], fromDate: self)
		return cal.dateFromComponents(components) ?? self
	}
}
