import SwiftUI

// Datatype
struct TimeCycle {
    let progress: Double
    let count: Int
}

struct ContentView: View {
    
    @AppStorage("motivation") private var Motivation: String = "I can do it!"
    
    // MARK: Updater ______________
    @State private var now: Double = Date().timeIntervalSince1970
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: Progress ______________
    var overallProgress: Double {
        let total = timestampEnd - timestampStart
        let elapsed = now - timestampStart
        guard total > 0 else { return 1 }
        return min(max(elapsed / total, 0), 1)
    }
    var minuteCycle: TimeCycle { cycleProgress(period: 60) }
    var hourCycle: TimeCycle { cycleProgress(period: 3600) }
    var dayCycle: TimeCycle { cycleProgress(period: 86400) }
    var weekCycle: TimeCycle { cycleProgress(period: 604800) }
    var monthCycle: TimeCycle { cycleProgress(period: 2592000) }

    // MARK: Times ______________
    @AppStorage("timestampStart") private var timestampStart: Double = Date().timeIntervalSince1970
    @AppStorage("timestampEnd") private var timestampEnd: Double = Date().timeIntervalSince1970
    @State private var showInputSheet = false
    @State private var inputDays: String = "0"
    @State private var inputWeeks: String = "0"
    @State private var inputMonths: String = "0"
    var dateStart: Date {Date(timeIntervalSince1970: timestampStart)}
    var dateEnd: Date {Date(timeIntervalSince1970: timestampEnd)}
    
    // DISPLAY
    var body: some View {
        
        // MARK: Timestamps ______________
        Text(dateEnd, format: .dateTime
                    .year()
                    .month()
                    .day()
                    .hour()
                ).padding(.top).font(.system(size: 25))
        
        
        

        
        Spacer() // -------------------
        
        // MARK: Bars ______________
        VStack(spacing: 25) {
            ProgressRow(title: "GOAL", value: TimeCycle(progress: overallProgress, count: 0), color: .green, count: false)
                .padding(.vertical)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            ProgressRow(title: "Month", value: monthCycle, color: .accentColor, count: true)
            ProgressRow(title: "Week", value: weekCycle, color: .accentColor, count: true)
            ProgressRow(title: "Day", value: dayCycle, color: .accentColor, count: true)

        }.onReceive(timer) { _ in now = Date().timeIntervalSince1970}
            .padding(.bottom, 40)
        
        
        TextEditor(text: $Motivation)
            .font(.system(size: 20, weight: .regular))
            .frame(height: 100)
            .frame(width: 300)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.5), lineWidth: 2.5)
            )
            .cornerRadius(10)
            .multilineTextAlignment(.center)
        
        Spacer() // -------------------
        
        // MARK: Inputs ______________
        VStack {
                    Button(". . .") {
                        showInputSheet = true
                    }
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.gray)
                    .padding()
                }
                .sheet(isPresented: $showInputSheet) {

                    VStack() {
                        Text("Indtast tidsperiode")
                            .font(.system(size: 28, weight: .medium))
                            .padding(.bottom)
                            .padding(.top, 0)
                        HStack(spacing: 75) {
                            Text("Months").multilineTextAlignment(.center)
                            Text("Weeks").multilineTextAlignment(.center)
                            Text("Days").multilineTextAlignment(.center)
                        }.padding(.trailing)
                        
                        HStack(spacing: 10) {
                                TextField(inputMonths, text: $inputMonths)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100, height: 45)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .medium))
                            Text(":")
                                TextField(inputWeeks, text: $inputWeeks)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100, height: 45)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .medium))
                            
                            Text(":")
                                TextField(inputDays, text: $inputDays)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100, height: 45)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .medium))
                        }.padding(.bottom,20)
                        
                        Button("Extend") {
                            timestampEnd += Double(parseInputs())
                            showInputSheet = false
                            inputDays = "0"
                            inputWeeks = "0"
                            inputMonths = "0"
                        }
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                        Button("Restart") {
                            timestampStart = Date().timeIntervalSince1970
                            timestampEnd = timestampStart + Double(parseInputs())
                            showInputSheet = false
                            inputDays = "0"
                            inputWeeks = "0"
                            inputMonths = "0"
                        }
                        .padding(.top, 20)
                        .padding(.leading, 40)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .presentationDetents([.height(350)])
                }
    }
    
    
    // MARK: Funcs ______________

    // Tolk indtastede varigheder
    func parseInputs() -> Int {
        let m = Int(inputMonths) ?? 0
        let w = Int(inputWeeks) ?? 0
        let d = Int(inputDays) ?? 0

        return (m * 30 * 24 * 60 * 60) +
               (w * 7 * 24 * 60 * 60) +
               (d * 24 * 60 * 60)
    }
    
    // udregn tid gået og antal af perioden
    func cycleProgress(period: Double) -> TimeCycle {
        let elapsed = max(0, now - timestampStart)
        let rawProgress = (elapsed.truncatingRemainder(dividingBy: period)) / period
        let clampedProgress = min(max(rawProgress, 0), 1)
        
        return TimeCycle(
            progress: clampedProgress,
            count: Int(elapsed / period)
        )
    }
}


// MARK: Progress Views ______________
struct ProgressRow: View {
    let title: String
    let value: TimeCycle
    let color: Color
    let count: Bool

    var body: some View {
        GridRow {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black) // or .black depending on color
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                
                HStack(){
                    if count{
                        Text("\(value.count)")
                            .frame(width: 25, alignment: .leading)
                            .font(.system(size: 20))
                            .padding(.leading, 10)}
                    
                    ProgressView(value: value.progress)
                        .tint(color)
                        .scaleEffect(x: 1, y: 10, anchor: .center)
                        .frame(height: 20)
                    
                    if count{
                        Text("\(value.count + 1)")
                            .frame(width: 25, alignment: .trailing)
                            .font(.system(size: 20))
                            .padding(.trailing, 10)}
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
