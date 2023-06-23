import SwiftUI
import RealityKit
import RealityKitContent
struct ContentView: View {
    @State var showImmersiveSpace = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @StateObject private var calculator = Calculator()
    let buttons: [[CalculatorButton]] = [
        [.clear, .flipSign, .percentage, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .factorial, .equals]
    ]
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text(calculator.display)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .font(.system(size: 64))
                        .padding(.horizontal)
                }
                    .padding()
                ForEach(buttons, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { button in
                            Button {
                                calculator.handleButtonPress(button)
                            } label: {
                                Text(button.rawValue)
                                    .font(.title)
                                    .frame(width: 150, height: 100)
                            }
                                .frame(width: 75, height: 75)
                        }
                    }
                }
            }
                .frame(maxWidth: .infinity)
                .padding(.all)
        }
            .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
}
enum CalculatorButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4", five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case decimal = ".", equals = "=", plus = "+", minus = "-", multiply = "X", divide = "÷"
    case clear = "AC", flipSign = "+/-", percentage = "%", factorial = "!"
}

class Calculator: ObservableObject {
    @Published var display = "0"

    private var firstOperand: Double = 0
    private var secondOperand: Double = 0
    private var currentOperation: CalculatorButton?
    private var shouldResetDisplay = false

    func handleButtonPress(_ button: CalculatorButton) {
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            handleNumericButtonPress(button)
        case .decimal:
            if !display.contains(".") {
                display += "."
            }
        case .plus, .minus, .multiply, .divide:
            handleOperationButtonPress(button)
        case .equals:
            calculateResult()
        case .clear:
            clearDisplay()
        case .flipSign:
            flipSign()
        case .percentage:
            calculatePercentage()
        case .factorial:
            calculateFactorial()
        }
    }
    private func handleNumericButtonPress(_ button: CalculatorButton) {
        let digit = button.rawValue
        if shouldResetDisplay {
            display = digit
            shouldResetDisplay = false
        } else {
            display += digit
        }
    }
    private func handleOperationButtonPress(_ button: CalculatorButton) {
        let value = Double(display)!
        if currentOperation != nil {
            calculateResult()
        }
        firstOperand = value
        currentOperation = button
        shouldResetDisplay = true
    }
    private func calculateResult() {
        if let operation = currentOperation {
            let value = Double(display)!
            switch operation {
            case .plus:
                display = String(firstOperand + value)
            case .minus:
                display = String(firstOperand - value)
            case .multiply:
                display = String(firstOperand * value)
            case .divide:
                display = String(firstOperand / value)
            default:
                break
            }
        }
        shouldResetDisplay = true
        currentOperation = nil
    }
    private func clearDisplay() {
        display = "0"
        firstOperand = 0
        secondOperand = 0
        currentOperation = nil
    }
    private func flipSign() {
        display = String(-Double(display)!)
    }
    private func calculatePercentage() {
        let value = Double(display)!
        display = String(value * 0.01)
        shouldResetDisplay = true
    }
    private func calculateFactorial() {
        let value = Int(display) ?? 0
        var result = 1
        for num in 1...value {
            result *= num
        }
        display = String(result)
        shouldResetDisplay = true
    }
}
#Preview {
    ContentView()
}
