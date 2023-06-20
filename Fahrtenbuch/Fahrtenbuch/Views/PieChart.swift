//
//  PieChart.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 20.06.23.
//

import Foundation
import SwiftUI

struct PieChartView: View {
    let percentages: [Double]
    let colors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let lineWidth: CGFloat = 40.0
            let gap: CGFloat = 5.0
            
            ZStack {
                ForEach(0..<percentages.count, id: \.self) { index in
                    let startAngle = index == 0 ? Angle(degrees: -90) : computeEndAngle(index: index - 1)
                    let endAngle = computeEndAngle(index: index)
                    let sector = Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    
                    sector
                        .fill(colors[index].gradient)
                                            .rotationEffect(.degrees(-90), anchor: .center)
                                            .animation(.easeInOut(duration: 1.0))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func computeEndAngle(index: Int) -> Angle {
        var sum: Double = 0.0
        for i in 0...index {
            sum += percentages[i]
        }
        return Angle(degrees: -90 + (sum * 360 / 100))
    }
}
