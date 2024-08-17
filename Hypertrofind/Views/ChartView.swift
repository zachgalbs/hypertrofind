import SwiftUI
import Charts

// Define your data model
struct LiftData: Identifiable {
    let id = UUID()
    let day: String
    let weight: Double
}

// Sample data
let workoutData = findVolume()

// Calculate average weight
let averageWeight = findAverageVolume(liftData: workoutData)

let currentDay = currentDayOfWeek()

var maxWeight = findMaxWeight(liftData: workoutData)

struct ChartView: View {
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea() // Set the background color
            
            ScrollView {
                VStack(spacing: 30) { // Adjusted spacing for better layout
                    HStack {
                        Text("Summary")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding([.horizontal, .top]) // Added padding to align with VStacks
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 5)
                            
                            VStack {
                                Text("Activity")
                                    .font(.title2)
                                    .padding(.top, 10) // Equal top padding for both VStacks
                                    .fontWeight(.semibold)
                                
                                // Determine the text based on current day's weight
                                let currentDayWeight = workoutData.first { $0.day == currentDay }?.weight ?? 0
                                Text(currentDayWeight > averageWeight ? "You're lifting more than average" : "You're lifting less than average")
                                    .font(.subheadline)
                                    .padding(.top, 20)
                                    .fontWeight(.light)
                                BarChart()
                            }
                            .padding()
                        }
                        .frame(height: 350)
                        .padding() // Padding around the ZStack
                        .background(Color.white.opacity(0.1)) // Subtle background for separation
                        .cornerRadius(10)
                    }
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(radius: 5)
                            
                            VStack {
                                Text("Fatigue")
                                    .font(.title2)
                                    .padding(.top, 10) // Equal top padding for both VStacks
                                    .fontWeight(.semibold)
                                FatigueDiagram()
                            }
                            .padding()
                        }
                        .frame(height: 375)
                        .padding() // Padding around the ZStack
                        .background(Color.white.opacity(0.1)) // Subtle background for separation
                        .cornerRadius(10)
                    }
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
    }
}

struct BarChart: View {
    var body: some View {
        Chart {
            ForEach(workoutData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Weight", data.weight)
                )
                .foregroundStyle(Color(white: 0.1 + (averageWeight - data.weight) / (2 * averageWeight)))
            }
            RuleMark(
                y: .value("Average Weight", averageWeight)
            )
            .foregroundStyle(Color.gray)
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
            .annotation(position: .top, alignment: .leading) {
                Text("Average Weight")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .bold()
            }
        }
        .frame(height: 200)
        .padding(.horizontal) // Horizontal padding for consistent layout
        .chartXScale(range: .plotDimension)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel() {
                    if let day = value.as(String.self) {
                        Text(day)
                            .bold(day == currentDay)
                            .foregroundStyle(day == currentDay ? Color.black : Color.gray)
                    }
                }
            }
        }
    }
}

struct FatigueDiagram: View {
    var body: some View {
        HStack(spacing: 50) {
            Image("Body black outline with white background")
                .resizable()
                .scaledToFit() // Changed to scaledToFit for better aspect ratio handling
                .frame(width: 100, height: 300)
            Image("Body black outline with white background Back")
                .resizable()
                .scaledToFit() // Changed to scaledToFit for better aspect ratio handling
                .frame(width: 100, height: 300)
        }
    }
}

#Preview {
    ChartView()
}
