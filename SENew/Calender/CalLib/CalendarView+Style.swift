//
//  CalendarView+Style.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 17/01/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

extension CalendarView {
    
    public struct Style {
        
        public enum CellShapeOptions {
            case round
            case square
            case bevel(CGFloat)
            var isRound: Bool {
                switch self {
                case .round:
                    return true
                default:
                    return false
                }
            }
        }
        
        public enum FirstWeekdayOptions{
            case sunday
            case monday
        }
        
        //Event
        public static var cellEventColor = UIColor.green
        
        //Header
        public static var headerHeight: CGFloat = 130.0
        public static var headerTextColor = UIColor.white
        public static var headerFontName: String = "Helvetica"
        public static var headerFontSize: CGFloat = 20.0

        //Common
        public static var cellShape                 = CellShapeOptions.bevel(4.0)
        
        public static var firstWeekday              = FirstWeekdayOptions.monday
        
        //Default Style
        public static var cellColorDefault          = UIColor.white
        public static var cellTextColorDefault      = UIColor.black
        public static var cellBorderColor           = UIColor.clear
        public static var cellBorderWidth           = CGFloat(0.0)
        
        //Today Style
        public static var cellTextColorToday        = UIColor.black
        public static var cellColorToday            = UIColor.white
        
        //Selected Style
        public static var cellSelectedBorderColor   = UIColor.black
        public static var cellSelectedBorderWidth   = CGFloat(2.0)
        public static var cellSelectedColor         = APPBLUECOLOR
        public static var cellSelectedTextColor     = UIColor.white
        
        //Weekend Style
        public static var cellTextColorWeekend      = UIColor.black
        //Locale Style
        public static var locale                    = Locale.current
        
        //TimeZone Calendar Style
        public static var timeZone                  = TimeZone(abbreviation: "UTC")!
        
        //Calendar Identifier Style
        public static var identifier                = Calendar.Identifier.gregorian
        
        //Hide/Alter Cells Outside Date Range
        public static var hideCellsOutsideDateRange = false
        public static var changeCellColorOutsideRange = false
        public static var cellTextColorOutsideRange = UIColor.red
    }
}
