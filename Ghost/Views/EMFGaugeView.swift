//
//  EMFGaugeView.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct EMFGaugeView: View {
    var value: Double // 0 to 300
    
    private let gaugeWidth: CGFloat = 25
    // Для верхней арки: старт на 180° (слева) и конец на 0° (справа)
    // При clockwise: false это нарисует верхнюю дугу
    
    var body: some View {
        ZStack {
            // 1. Фоновая серая дуга (пунктир)
            Circle()
                .trim(from: 0.5, to: 1.0) // Берем только верхнюю половину круга
                .stroke(Color.gray.opacity(0.2),
                        style: StrokeStyle(lineWidth: gaugeWidth, lineCap: .butt, dash: [3, 3]))
                .rotationEffect(.degrees(0))
            
            // 2. Цветная градиентная дуга
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                        center: .center,
                        startAngle: .degrees(180),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: gaugeWidth, lineCap: .butt, dash: [3, 3])
                )
            
            // 3. Метки цифр (0, 100, 200, 300)
            GaugeLabelsView()
            
            // 4. Стрелка
            NeedleView(value: value)
            
            // 5. Текст с текущим значением
            VStack(spacing: 0) {
                Text(String(format: "%.0f", value))
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .foregroundColor(valueColor)
                Text("mG")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
            }
            .offset(y: 40) // Положение цифр чуть ниже центра вращения стрелки
        }
        .frame(width: 200, height: 200) // Фиксированный размер контейнера
    }
    
    private var valueColor: Color {
        if value < 80 { return .green }
        if value < 160 { return .yellow }
        if value < 240 { return .orange }
        return .red
    }
}

// MARK: - Вспомогательные компоненты

struct GaugeLabelsView: View {
    let labels = ["0", "100", "200", "300"]
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = geo.size.width / 2 + 25 // Выносим цифры за радиус дуги
            
            ForEach(0..<labels.count, id: \.self) { i in
                // Распределяем метки от 180° до 0°
                let angle = Double(i) * (180.0 / Double(labels.count - 1))
                let rad = (180.0 - angle) * .pi / 180.0
                
                let x = center.x + cos(rad) * radius
                let y = center.y - sin(rad) * radius
                
                Text(labels[i])
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white.opacity(0.8))
                    .position(x: x, y: y)
            }
        }
    }
}

struct NeedleView: View {
    var value: Double
    private let needleLength: CGFloat = 90 // Длина стрелки
    private let needleWidth: CGFloat = 4    // Толщина стрелки

    var body: some View {
        // Угол: 0 mG = -90°, 300 mG = +90°
        let angle = (value / 300.0) * 180.0 - 90.0

        return ZStack {
            // Сама игла
            Capsule()
                .fill(Color.white)
                .frame(width: needleWidth, height: needleLength)
                // Сдвигаем иглу вверх на половину её длины.
                // Теперь её НИЖНИЙ край находится ровно в центре ZStack.
                .offset(y: -needleLength / 2)

            // Основание стрелки (кружок)
            // Он уже в центре ZStack по умолчанию
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
        }
        // Теперь anchor: .center — это ровно центр кружка и нижний край иглы
        .rotationEffect(.degrees(angle), anchor: .center)
    }
}
