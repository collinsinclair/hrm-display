import SwiftUI

struct HeartRateDisplayView: View {
    let title: String
    let value: Int
    var expandContent: Bool = false
    
    var body: some View {
        if expandContent {
            // Landscape version
            VStack {
                Text(title)
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("\(value)")
                    .font(.system(size: 96, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        } else {
            // Original portrait version
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(value)")
                    .font(.system(size: 48, weight: .bold))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

#Preview {
    HeartRateDisplayView(
        title: "Current BPM",
        value: 72
    )
}
