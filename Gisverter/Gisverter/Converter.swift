//
//  Converter.swift
//  Gisverter
//
//  Created by Aitam Bar-Sagi on 19/03/2019.
//  Copyright © 2019 Aitam Bar-Sagi. All rights reserved.
//

import Foundation

class Converter {
    let eWGS84 = 0, eGRS80 = 1, eCLARK80M = 2, gICS = 0, gITM = 1
    
    
    func ITM2WG84(N: Int, E: Int) -> [Double] {
        let latLon80 = grid2LatLon(N: N, E: E, from: gITM, to: eGRS80)
        var result = molodensky(inLat: latLon80[0], inLon: latLon80[1], from: eGRS80, to: eWGS84)
        
        result[0] *= 180.0 / Double.pi
        result[1] *= 180.0 / Double.pi
        
        return result
    }
    
    func ICS2WG84(N: Int, E: Int) -> [Double] {
        let clark80 = grid2LatLon(N: N, E: E, from: gICS, to: eCLARK80M)
        var result = molodensky(inLat: clark80[0], inLon: clark80[1], from: eCLARK80M, to: eWGS84)
        
        result[0] *= 180.0 / Double.pi
        result[1] *= 180.0 / Double.pi
        
        return result
    }
    
    func WG842ITM(lat: Double, lon: Double) -> [Int]{
        let latR = lat * Double.pi / 180.0
        let lonR = lon * Double.pi / 180.0
        let latLon80 = molodensky(inLat: latR, inLon: lonR, from: eWGS84, to: eGRS80)
        return latLon2Grid(lat: latLon80[0], lon: latLon80[1], from: eGRS80, to: gITM)
    }
    
    
    private func grid2LatLon(N:Int, E:Int, from:Int, to:Int) -> [Double]{
        var latLong:[Double] = [0,0]
        let grid = Grid.getData(from)
        let datum = Datum.getData(to)
        
        let y = Double(N) + grid.false_n
        let x = Double(E) - grid.false_e
        let M = y / grid.k0
        let mu = M / (datum.a * (1.0 - pow(datum.e,2.0) / 4.0 - 3.0 * pow(datum.e, 4.0) / 64.0 - 5.0 * pow(datum.e, 6.0) / 256.0))
        let ee = sqrt(1.0 - datum.esq)
        let e1 = (1.0 - ee) / (1.0 + ee)
        let j1 = 3.0 * e1 / 2.0 - 27.0 * pow(e1, 3.0) / 32.0
        let j2 = 21.0 * pow(e1, 2.0) / 16.0 - 55.0 * pow(e1, 4.0) / 32.0
        let j3 = 151.0 * pow(e1, 3.0) / 96.0
        let j4 = 1097.0 * pow(e1,4.0) / 512.0
        
        let fp = mu + j1 * sin(2.0 * mu) + j2 * sin(4.0 * mu) + j3 * sin(6.0 * mu) + j4 * sin(8.0 * mu)
        let sinFp = sin(fp)
        let cosFp = cos(fp)
        let tanFp = sinFp / cosFp
        let eg = (datum.e * datum.a / datum.b)
        let eg2 = pow(eg, 2.0)
        let C1 = eg2 * pow(cosFp, 2.0)
        let T1 = pow(tanFp, 2.0)
        let R1 = datum.a * (1.0 - pow(datum.e, 2.0)) / pow(1.0 - pow(datum.e * sinFp, 2.0), 1.5)
        let N1 = datum.a / sqrt(1.0 - pow (datum.e * sinFp, 2.0))
        let D = x / (N1 * grid.k0)
        let Q1 = N1 * tanFp / R1
        let Q2 = pow(D, 2.0) / 2.0
        let Q3 = (5.0 + 3.0 * T1 + 10 * C1 - 4.0 * pow(C1, 2.0) - 9.0 * pow(eg2, 2.0)) * pow(D, 4.0) / 24.0
        let Q4 = (61.0 + 90.0 * T1 + 298.0 * C1 + 45.0 * pow(T1, 2.0) - 3.0 * pow(C1, 2.0) - 252.0 * pow(eg2, 2.0)) * pow(D, 6.0) / 720.0
        latLong[0] = fp - Q1 * (Q2 - Q3 + Q4)
        
        let Q6 = (1.0 + 2.0 * T1 + C1) * pow(D, 3.0) / 6.0
        let Q7 = (5.0 - 2.0 * C1 + 28.0 * T1 - 3.0 * pow(C1, 2.0) + 8.0 * pow(eg2, 2.0) + 24.0 * pow(T1,2.0)) * pow(D, 5.0) / 120.0
        latLong[1] = grid.lon0 + (D - Q6 + Q7) / cosFp
        
        return latLong
    }
    
    private func latLon2Grid(lat: Double, lon: Double, from: Int, to: Int) -> [Int]{
        var metric: [Int] = [0,0]
        let grid = Grid.getData(to)
        let datum = Datum.getData(from)
        
        let sLat1 = sin(lat)
        let cLat1 = cos(lat)
        let cLat1sq = cLat1 * cLat1
        let tanLat1sq = sLat1 * sLat1 / cLat1sq
        let e2 = datum.e * datum.e
        let e4 = e2 * e2
        let e6 = e4 * e2
        let eg = (datum.e * datum.a / datum.b)
        let eg2 = eg * eg
        let l1 = 1.0 - e2 / 4.0 - 3.0 * e4 / 64.0 - 5.0 * e6 / 256.0
        let l2 = 3.0 * e2 / 8.0 + 3.0 * e4 / 32.0 + 45.0 * e6 / 1024.0
        let l3 = 15.0 * e4 / 256.0 + 45 * e6 / 1024.0
        let l4 = 35.0 * e6 / 3072.0
        
        let M = datum.a * (l1 * lat - l2 * sin(2.0 * lat) + l3 * sin (4.0 * lat) - l4 * sin (6.0 * lat))
        let nu = datum.a / sqrt(1.0 - (datum.e * sLat1) * (datum.e * sLat1))
        let p = lon - grid.lon0
        let K1 = M * grid.k0
        let K2 = grid.k0 * nu * sLat1 * cLat1 / 2.0
        let K3 = (grid.k0 * nu * sLat1 * cLat1 * cLat1sq / 24.0) * (5.0 - tanLat1sq + 9.0 * eg2 * cLat1sq + 4.0 * eg2 * eg2 * cLat1sq * cLat1sq)
        let Y = K1 + K2 * p * p + K3 * p * p * p * p - grid.false_n
        let K4 = grid.k0 * nu * cLat1
        let K5 = (grid.k0 * nu * cLat1 * cLat1sq / 6.0) * (1.0 - tanLat1sq + eg2 * cLat1 * cLat1)
        let X = K4 * p + K5 * p * p * p + grid.false_e
        
        metric[1] = Int(X + 0.5)
        metric[0] = Int(Y + 0.5)
        return metric
    }
    
    private func molodensky(inLat: Double, inLon: Double, from: Int, to: Int) -> [Double]{
        var latLon: [Double] = [0,0]
        let datumFrom = Datum.getData(from)
        let datumTo = Datum.getData(to)
        
        let dX = datumFrom.dX - datumTo.dX
        let dY = datumFrom.dY - datumTo.dY
        let dZ = datumFrom.dZ - datumTo.dZ
        
        let sLat = sin(inLat)
        let cLat = cos(inLat)
        let sLon = sin(inLon)
        let cLon = cos(inLon)
        let ssqLat = pow(sLat, 2.0)
        
        let from_f = datumFrom.f
        let df = datumTo.f - from_f
        let from_a = datumFrom.a
        let da = datumTo.a - from_a
        let from_esq = datumFrom.esq
        let adb = 1.0 / (1.0 - from_f)
        let rn = from_a / sqrt(1.0 - from_esq * ssqLat)
        let rm = from_a * (1.0 - from_esq) / pow((1.0 - from_esq * ssqLat),1.5)
        let from_h = 0.0
        
        let dLat = (-dX * sLat * cLon - dY * sLat * sLon + dZ * cLat + da * rn * from_esq * sLat * cLat / from_a + df * (rm * adb + rn / adb) * sLat * cLat) / (rm + from_h)
        
        latLon[0] = inLat + dLat
        
        let dLon = (-dX * sLon + dY * cLon) / ((rn + from_h) * cLat)
        
        latLon[1] = inLon + dLon
        
        return latLon
    }
    
}
