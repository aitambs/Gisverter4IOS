//
//  Grid.swift
//  Gisverter
//
//  Created by Aitam Bar-Sagi on 19/03/2019.
//  Copyright © 2019 Aitam Bar-Sagi. All rights reserved.
//

import Foundation

class Grid {
    var lon0:Double, k0:Double, false_e:Double, false_n:Double
    
    init(lon0:Double, k0:Double, false_e:Double, false_n:Double) {
        self.lon0 = lon0
        self.k0 = k0
        self.false_e = false_e
        self.false_n = false_n
    }
    
    static func getData(_ type:Int) -> Grid{
        switch type {
        case 0: //ICS data
            return Grid(lon0: 0.6145667421719, k0: 1.00000, false_e: 170251.555, false_n: 2385259.0)
        default: //ITM data
            return Grid(lon0: 0.61443473225468920, k0: 1.0000067, false_e: 219529.584, false_n: 2885516.9488)
        }
    }
}
