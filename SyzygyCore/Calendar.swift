//
//  Calendar.swift
//  SyzygyCore
//
//  Created by Dave DeLong on 7/14/18.
//  Copyright © 2018 Syzygy. All rights reserved.
//

import Foundation

public extension Calendar {
    
    public enum Gregorian {
        
        public enum Weekday: Int {
            public static func ==(lhs: Int, rhs: Weekday) -> Bool { return lhs == rhs.rawValue }
            public static func ==(lhs: Weekday, rhs: Int) -> Bool { return lhs.rawValue == rhs }
            
            case sunday = 1
            case monday = 2
            case tuesday = 3
            case wednesdsay = 4
            case thursday = 5
            case friday = 6
            case saturday = 7
        }
        
    }
    
    func startOfWeek(for date: Date) -> Date {
        if let weekRange = dateInterval(of: .weekOfYear, for: date) {
            return weekRange.start
        }
        
        let weekday = component(.weekday, from: date)
        let calendricalStartOfWeek = self.firstWeekday
        
        let difference = abs(weekday - calendricalStartOfWeek)
        
        let startOfWeek = self.date(byAdding: .day, value: -difference, to: date) !! "Can't find start of week for \(date)"
        
        return startOfDay(for: startOfWeek)
    }
    
    func daysInWeek(containing: Date) -> Array<Date> {
        let weekday = component(.weekday, from: containing)
        let calendricalStartOfWeek = self.firstWeekday
        
        let difference = abs(weekday - calendricalStartOfWeek)
        
        let startOfWeek = date(byAdding: .day, value: -difference, to: containing) !! "Can't find start of week for \(containing)"
        
        var days = Array<DateInterval>()
        for i in 0 ..< 7 {
            let dayOfWeek = date(byAdding: .day, value: i, to: startOfWeek) !! "Can't add \(i) days to \(startOfWeek)"
            let range = dateInterval(of: .day, for: dayOfWeek) !! "Can't find range of day containing \(dayOfWeek)"
            days.append(range)
        }
        
        return days.map { $0.mid }
    }
    
    func isDate(_ date: Date, before: Date, granularity: Calendar.Component) -> Bool {
        let components = [Calendar.Component.era, .year, .month, .weekOfYear, .day, .hour, .minute, .second, .nanosecond]
        let componentSet = Set(components)
        Assert.that(componentSet.contains(granularity), because: "Cannot search for unit \(granularity)")
        
        let dateComponents = self.dateComponents(componentSet, from: date)
        let beforeComponents = self.dateComponents(componentSet, from: before)
        
        for unit in components {
            guard let dateValue = dateComponents.value(for: unit) else { return false }
            guard let beforeValue = beforeComponents.value(for: unit) else { return false }
            
            if dateValue < beforeValue { return true }
            if dateValue > beforeValue { break }
            if unit == granularity { break }
        }
        return false
    }
    
    func isDate(_ date: Date, after: Date, granularity: Calendar.Component) -> Bool {
        let isBefore = isDate(date, before: after, granularity: granularity)
        let isOn = isDate(date, equalTo: after, toGranularity: granularity)
        
        return (isBefore == false && isOn == false)
    }
    
}
