import SwiftUI

// MARK: - Data Model

struct TimeCycle {
    let progress: Double
    let count: Int
}

// MARK: - Main View

struct ContentView: View {

    // MARK: Storage

    @AppStorage("motivation")
    private var motivation: String = "I can do it!"

    @AppStorage("timestampStart")
    private var timestampStart: Double = Date().timeIntervalSince1970

    @AppStorage("timestampEnd")
    private var timestampEnd: Double = Date().timeIntervalSince1970

    // MARK: State

    @State private var now = Date()

    @State private var showInputSheet = false
    @FocusState private var isMotivationFocused: Bool
    
    @State private var inputDays = 0
    @State private var inputWeeks = 0
    @State private var inputMonths = 0

    // MARK: Timer

    let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: Dates

    var startDate: Date {
        Date(timeIntervalSince1970: timestampStart)
    }

    var endDate: Date {
        Date(timeIntervalSince1970: timestampEnd)
    }

    // MARK: Progress

    var overallProgress: Double {

        let total = timestampEnd - timestampStart
        let elapsed = now.timeIntervalSince1970 - timestampStart

        guard total > 0 else { return 1 }

        return min(max(elapsed / total, 0), 1)
    }

    var monthCycle: TimeCycle {
        cycleProgress(period: 2592000)
    }

    var weekCycle: TimeCycle {
        cycleProgress(period: 604800)
    }

    var dayCycle: TimeCycle {
        cycleProgress(period: 86400)
    }

    // MARK: Body

    var body: some View {

        NavigationStack {

            GeometryReader { geo in

                ScrollView {

                    VStack(spacing: 28) {

                        progressSection

                        motivationSection

//                        Spacer(minLength: 10)

                        controlsSection
                    }
                    .padding()
                    .frame(minHeight: geo.size.height)
                }
            }
//            .navigationTitle("Progress")
            .onReceive(timer) { _ in
                now = Date()
            }
            .sheet(isPresented: $showInputSheet) {
                durationSheet
            }
        }
    }
}

// MARK: - Sections

extension ContentView {

    var progressSection: some View {

        VStack(spacing: 50) {

            VStack(spacing:20){
                GoalRow(
                    value: TimeCycle(
                        progress: overallProgress,
                        count: 0
                    )
                )

                Text(
                    endDate,
                    format: .dateTime
                        .year()
                        .month()
                        .day()
                        .hour()
                        .minute()
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            VStack(spacing: 30) {

                ProgressRow(
                    title: "Month",
                    value: monthCycle,
                    color: .indigo,
                    showCount: true
                )

                ProgressRow(
                    title: "Week",
                    value: weekCycle,
                    color: .blue,
                    showCount: true
                )

                ProgressRow(
                    title: "Day",
                    value: dayCycle,
                    color: .teal,
                    showCount: true
                )
            }
        }
        .padding()
//        .background(.thinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    var motivationSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Motivation")
                .font(.headline)

            TextEditor(text: $motivation)
                .focused($isMotivationFocused)
                .font(.body)
                .frame(minHeight: 110)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.gray.opacity(0.4), lineWidth: 1.5)
                ).toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isMotivationFocused = false
                        }
                    }
                }
        }
    }

    var controlsSection: some View {

        VStack {
            Button("· · ·") {
                showInputSheet = true
            }
            .font(.system(size: 50, weight: .bold))
            .foregroundColor(.gray)
            .padding()
        }
    }

    var durationSheet: some View {

        NavigationStack {

            VStack(spacing: 30) {

                Text("Duration")
                    .font(.largeTitle.bold())

                HStack(spacing: 24) {

                    TimeStepperView(
                        title: "Months",
                        value: $inputMonths
                    )

                    TimeStepperView(
                        title: "Weeks",
                        value: $inputWeeks
                    )

                    TimeStepperView(
                        title: "Days",
                        value: $inputDays
                    )
                }

                VStack(spacing: 16) {

                    Button("Extend") {

                        timestampEnd += Double(parseInputs())

                        resetInputs()

                        showInputSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.largeTitle.bold())

                    Button("Restart") {

                        timestampStart = Date().timeIntervalSince1970

                        timestampEnd =
                            timestampStart + Double(parseInputs())

                        resetInputs()

                        showInputSheet = false
                    }
                    .foregroundStyle(.gray)
                }

                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Functions

extension ContentView {

    func parseInputs() -> Int {

        let monthSeconds = inputMonths * 30 * 24 * 60 * 60
        let weekSeconds = inputWeeks * 7 * 24 * 60 * 60
        let daySeconds = inputDays * 24 * 60 * 60

        return monthSeconds + weekSeconds + daySeconds
    }

    func resetInputs() {

        inputDays = 0
        inputWeeks = 0
        inputMonths = 0
    }

    func cycleProgress(period: Double) -> TimeCycle {

        let elapsed =
            max(0, now.timeIntervalSince1970 - timestampStart)

        let progress =
            (elapsed.truncatingRemainder(dividingBy: period)) / period

        return TimeCycle(
            progress: min(max(progress, 0), 1),
            count: Int(elapsed / period)
        )
    }
}

// MARK: - Goal Row

struct GoalRow: View {

    let value: TimeCycle

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {
            
            Text("Goal")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .center)

                ProgressView(value: value.progress)
                .tint(.green)
                    .scaleEffect(y: 7)
        }
    }
}

// MARK: - Progress Row

struct ProgressRow: View {

    let title: String
    let value: TimeCycle
    let color: Color
    let showCount: Bool

    var body: some View {

        VStack(alignment: .leading, spacing: 15) {

            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack() {

                if showCount {

                    Text("\(value.count)")
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 35, alignment: .leading)
                }

                ProgressView(value: value.progress)
                    .tint(color)
                    .scaleEffect(y: 7)

                if showCount {

                    Text("\(value.count + 1)")
                        .font(.subheadline.monospacedDigit())
                        .frame(width: 35, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Stepper View

struct TimeStepperView: View {

    let title: String

    @Binding var value: Int

    var body: some View {

        VStack(spacing: 10) {

            Text(title)
                .font(.headline)

            Text("\(value)")
                .font(.largeTitle.bold())
                .monospacedDigit()

            Stepper(
                "",
                value: $value,
                in: 0...999
            )
            .labelsHidden()
        }
        .frame(maxWidth: .infinity)
    }
}
