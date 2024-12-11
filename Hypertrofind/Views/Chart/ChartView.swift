import SwiftUI
import Charts


struct ChartView: View {
    // Referencing the Observable HypertrofindData class
    @Environment(HypertrofindData.self) var data
    var body: some View {
        // Only used to check if we have any completed routines
        let completedRoutines = data.completedRoutines
        ZStack {
            Color.gray.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) { // Adjusted spacing for better layout
                    HStack {
                        Text("Summary")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding([.horizontal, .top]) // Added padding to align with VStacks
                    
                    if (completedRoutines.isEmpty) {
                        ZStack {
                            ActivityView()
                                .opacity(0.5)
                            Text("Complete a routine for statistics")
                                .bold()
                                .font(.title3)
                        }
                    } else {
                        ActivityView()
                    }
                    
                    FatigueView()
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
    }
}
struct FatigueView: View {
    var body: some View {
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
}
struct ActivityView: View {
    @Environment(HypertrofindData.self) var data
    var body: some View {
        // This time we want to have access to things like the average weight, the current day, and the max weight, so we instantiate ChartData, a class that takes a list of completedRoutines and returns a list of variables
        let chartData = ChartData(completedRoutines: data.completedRoutines)
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 5)
                
                VStack {
                    Text("Volume")
                        .font(.title2)
                        .padding(.top, 10) // Equal top padding for both VStacks
                        .fontWeight(.semibold)
                    
                    // Determine the text based on current day's weight
                    let currentDayWeight = chartData.workoutData.first { $0.day == chartData.currentDay }?.weight ?? 0
                    if currentDayWeight != chartData.averageWeight {
                        Text(currentDayWeight > chartData.averageWeight ? "You're lifting more than average" : "You're lifting less than average")
                            .font(.subheadline)
                            .padding(.top, 20)
                            .fontWeight(.light)
                    }
                    BarChart()
                }
                .padding()
            }
            .frame(height: 350)
            .padding() // Padding around the ZStack
            .background(Color.white.opacity(0.1)) // Subtle background for separation
            .cornerRadius(10)
        }
    }
}

struct BarChart: View {
    @Environment(HypertrofindData.self) var data
    var body: some View {
        Text("something")
        let chartData = ChartData(completedRoutines: data.completedRoutines)
        VStack {
            Chart {
                // For each workout, get the data and list it.
                ForEach(chartData.workoutData) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Pounds", data.weight)
                    )
                    .foregroundStyle(Color(white: 0.1 + (chartData.averageWeight - data.weight) / (2 * chartData.averageWeight)))
                }
                RuleMark(
                    y: .value("Average Weight", chartData.averageWeight)
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
            .padding(.horizontal)
            .chartXScale(range: .plotDimension)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let day = value.as(String.self) {
                            Text(day)
                                .bold(day == chartData.currentDay)
                                .foregroundStyle(day == chartData.currentDay ? Color.black : Color.gray)
                        }
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
