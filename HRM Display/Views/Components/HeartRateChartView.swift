import SwiftUI
import Charts

struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let instantaneous: Int
    let average: Int
}

struct HeartRateChartView: View {
    let data: [HeartRateDataPoint]
    
    private var yAxisBounds: (min: Int, max: Int) {
        guard !data.isEmpty else { return (60, 100) }  // Default range if no data
        
        let allValues = data.flatMap { [$0.instantaneous, $0.average] }
        let minValue = Double(allValues.min() ?? 60)
        let maxValue = Double(allValues.max() ?? 100)
        
        // Calculate bounds with 10% padding
        let minBound = Int((minValue * 0.9).rounded(.down))
        let maxBound = Int((maxValue * 1.1).rounded(.up))
        
        return (minBound, maxBound)
    }
    
    private var xAxisBounds: (min: Date, max: Date) {
        guard !data.isEmpty else { return (Date(), Date()) }
        
        let firstTimestamp = data[0].timestamp
        let now = Date()
        
        return (firstTimestamp, now)
    }
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                // Instantaneous heart rate series
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("BPM", point.instantaneous)
                )
                .foregroundStyle(by: .value("Series", "Instantaneous"))
                
                // 60-second average series
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("BPM", point.average)
                )
                .foregroundStyle(by: .value("Series", "60s Average"))
            }
        }
        .chartForegroundStyleScale([
            "Instantaneous": Color.red,
            "60s Average": Color.blue
        ])
        .chartYScale(domain: yAxisBounds.min...yAxisBounds.max)
        .chartXScale(domain: xAxisBounds.min...xAxisBounds.max)
        .chartXAxis {
            AxisMarks(values: .stride(by: 30)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: .dateTime.hour().minute())
                    }
                }
                AxisTick()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let v = value.as(Int.self) {
                    AxisValueLabel("\(v)")
                    AxisTick()
                    AxisGridLine()
                }
            }
        }
        .chartLegend(position: .bottom)
    }
}

#Preview {
    HeartRateChartView(data: [
        HeartRateDataPoint(timestamp: Date().addingTimeInterval(-300), instantaneous: 72, average: 75),
        HeartRateDataPoint(timestamp: Date().addingTimeInterval(-240), instantaneous: 75, average: 75),
        HeartRateDataPoint(timestamp: Date().addingTimeInterval(-180), instantaneous: 78, average: 76),
        HeartRateDataPoint(timestamp: Date().addingTimeInterval(-120), instantaneous: 73, average: 75),
        HeartRateDataPoint(timestamp: Date().addingTimeInterval(-60), instantaneous: 71, average: 74),
        HeartRateDataPoint(timestamp: Date(), instantaneous: 74, average: 74)
    ])
}
