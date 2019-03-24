//
//  Datum.swift
//  Gisverter
//
//  Created by Aitam Bar-Sagi on 19/03/2019.
//  Copyright © 2019 Aitam Bar-Sagi. All rights reserved.
//

import Foundation

class Datum {
    var a:Double, b:Double, f:Double, esq:Double, e:Double, dX:Double, dY:Double, dZ:Double
    
    init(a:Double, b:Double, f:Double, esq:Double, e:Double, dX:Double, dY:Double, dZ:Double) {
        self.a = a
        self.b = b
        self.f = f
        self.esq = esq
        self.e = e
        self.dX = dX
        self.dY = dY
        self.dZ = dZ
    }
    
    static func getData(_ type:Int) -> Datum {
        switch type {
        case 0: //WGS84 data
            return Datum(a: 6378137.0, b: 6356752.3142, f: 0.00335281066474748, esq: 0.006694380004260807, e: 0.818191909289062, dX: 0.0, dY: 0.0, dZ: 0.0)
        case 1: //GRS80 data
            return Datum(a: 6378137.0, b: 6356752.3141, f: 0.0033528106811823, esq: 0.00669438002290272, e: 0.0818191910428276, dX: -48.0, dY: 55.0, dZ: 52.0)
        default: //Clark 1880 Modified Data
            return Datum(a: 6378300.789, b: 6356566.4116309, f: 0.003407549767264, esq: 0.006803488139112318, e: 0.08248325975076590, dX: -235.0, dY: -85.0, dZ: 264.0)
        }
    }
}
