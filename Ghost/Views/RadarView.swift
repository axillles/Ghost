//
//  RadarView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import SwiftUI

struct CenterDot: View {
    let size: CGSize

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 8, height: 8)
            .position(
                x: size.width / 2,
                y: size.height / 2
            )
    }
}

struct RadarDotView: View {
    let dot: GhostDot
    let size: CGSize
    
    var body: some View {
        Circle()
            .fill(Color(hex: "7AFD91").opacity(dot.intensity))
            .frame(width: 12, height: 12)
            .position(
                x: dot.position.x * size.width,
                y: dot.position.y * size.height
            )
            .blur(radius: 2)
    }
}


struct RadarView: View {
    @ObservedObject var radarService = RadarService.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadarGrid()

                ForEach(radarService.dots) { dot in
                    RadarDotView(
                        dot: dot,
                        size: geometry.size
                    )
                }

                CenterDot(size: geometry.size)
            }
        }
    }
}

struct RadarLine: View {
    let index: Int
    let center: CGPoint
    let radius: CGFloat

    var body: some View {
        let angle = Double(index) * .pi / 4

        Path { path in
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            ))
        }
        .stroke(Color(hex: "7AFD91").opacity(0.2), lineWidth: 1)
    }
}

struct RadarGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
            let radius = min(geometry.size.width, geometry.size.height) / 2

            ZStack {
                // Кольца
                ForEach(1..<4, id: \.self) { index in
                    Circle()
                        .stroke(Color(hex: "7AFD91").opacity(0.3), lineWidth: 1)
                        .frame(
                            width: radius * 2 * CGFloat(index) / 3,
                            height: radius * 2 * CGFloat(index) / 3
                        )
                        .position(center)
                }

                // Линии
                ForEach(0..<8, id: \.self) { index in
                    RadarLine(
                        index: index,
                        center: center,
                        radius: radius
                    )
                }
            }
        }
    }
}


#Preview {
    RadarView()
        .background(Color.black)
}
