import SwiftUI

struct PineTree: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let tierH = r.height * 0.34
        for i in 0..<5 {
            let topY = r.minY + CGFloat(i) * r.height * 0.14
            let bottomY = topY + tierH
            let halfW = r.width * (0.18 + 0.08 * CGFloat(i))
            p.move(to: CGPoint(x: r.midX, y: topY))
            p.addLine(to: CGPoint(x: r.midX + halfW, y: bottomY))
            p.addLine(to: CGPoint(x: r.midX - halfW, y: bottomY))
            p.closeSubpath()
        }
        p.addRect(CGRect(x: r.midX - r.width * 0.04, y: r.minY + r.height * 0.86,
                         width: r.width * 0.08, height: r.height * 0.14))
        return p
    }
}

struct SnowView: View {
    struct Flake {
        let x: Double, speed: Double, size: Double, phase: Double, drift: Double, opacity: Double
    }

    @State private var flakes: [Flake] = (0..<80).map { _ in
        Flake(x: .random(in: 0...1), speed: .random(in: 0.02...0.07), size: .random(in: 1.5...4.5),
              phase: .random(in: 0...1), drift: .random(in: 0.005...0.03), opacity: .random(in: 0.25...0.9))
    }

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for f in flakes {
                    let progress = (t * f.speed + f.phase).truncatingRemainder(dividingBy: 1.0)
                    let y = progress * (size.height + 20) - 10
                    let x = (f.x + sin(t * 0.5 + f.phase * 6.28) * f.drift) * size.width
                    let rect = CGRect(x: x, y: y, width: f.size, height: f.size)
                    ctx.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(f.opacity)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct VoltageBackdrop: View {
    var trees = true

    private let forest: [(x: CGFloat, h: CGFloat)] = [
        (0.04, 120), (0.16, 250), (0.31, 170), (0.50, 130), (0.66, 210), (0.80, 270), (0.95, 150),
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0B1329), Color(hex: 0x0E1A38), Color(hex: 0x050A14)],
                           startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: 0x1B2D66).opacity(0.45), .clear],
                           center: .center, startRadius: 10, endRadius: 360)
            SnowView()
            if trees {
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<forest.count, id: \.self) { i in
                            let t = forest[i]
                            PineTree().fill(Color.black)
                                .frame(width: t.h * 0.5, height: t.h)
                                .position(x: geo.size.width * t.x, y: geo.size.height - t.h / 2 + 10)
                        }
                        LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                            .frame(height: 90)
                            .position(x: geo.size.width / 2, y: geo.size.height - 35)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
