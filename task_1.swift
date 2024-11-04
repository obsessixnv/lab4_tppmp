// Клас для представлення раціональних чисел
class Rational: CustomStringConvertible, Equatable, Comparable {
    private var numerator: Int
    private var denominator: Int
    
    var description: String {
        return "\(numerator)/\(denominator)"
    }
    
    init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
        self.normalize()
    }
    
    // Копіювання об'єкту
    func copy() -> Rational {
        return Rational(numerator: self.numerator, denominator: self.denominator)
    }
    
    private func normalize() {
        if denominator < 0 {
            numerator = -numerator
            denominator = -denominator
        }
        let gcd = findGCD(abs(numerator), abs(denominator))
        numerator /= gcd
        denominator /= gcd
    }
    
    private func findGCD(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
    
    // Арифметичні операції
    func multiply(_ other: Rational) -> Rational {
        return Rational(
            numerator: self.numerator * other.numerator,
            denominator: self.denominator * other.denominator
        )
    }
    
    func divide(_ other: Rational) -> Rational {
        return Rational(
            numerator: self.numerator * other.denominator,
            denominator: self.denominator * other.numerator
        )
    }
    
    static func add(_ lhs: Rational, _ rhs: Rational) -> Rational {
        let newNumerator = lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator
        let newDenominator = lhs.denominator * rhs.denominator
        return Rational(numerator: newNumerator, denominator: newDenominator)
    }
    
    static func subtract(_ lhs: Rational, _ rhs: Rational) -> Rational {
        let newNumerator = lhs.numerator * rhs.denominator - rhs.numerator * lhs.denominator
        let newDenominator = lhs.denominator * rhs.denominator
        return Rational(numerator: newNumerator, denominator: newDenominator)
    }
    
    // Оператори порівняння
    static func < (lhs: Rational, rhs: Rational) -> Bool {
        return lhs.numerator * rhs.denominator < rhs.numerator * lhs.denominator
    }
    
    static func == (lhs: Rational, rhs: Rational) -> Bool {
        return lhs.numerator * rhs.denominator == rhs.numerator * lhs.denominator
    }
}

// Калькулятор - Singleton
class Calculator {
    static let shared = Calculator()
    private init() {}
    
    private var currentResult: Rational?
    private var pendingOperand: Rational?
    private var pendingOperator: String?
    
    // Методи класу для додавання та віднімання
    class func add(_ lhs: Rational, _ rhs: Rational) -> Rational {
        return Rational.add(lhs, rhs)
    }
    
    class func subtract(_ lhs: Rational, _ rhs: Rational) -> Rational {
        return Rational.subtract(lhs, rhs)
    }
    
    // Методи екземпляра для множення та ділення
    func multiply(_ lhs: Rational, _ rhs: Rational) -> Rational {
        return lhs.multiply(rhs)
    }
    
    func divide(_ lhs: Rational, _ rhs: Rational) -> Rational {
        return lhs.divide(rhs)
    }
    
    // Метод для обробки виразу з урахуванням пріоритету операцій
    func evaluate(_ expression: [String]) -> Rational? {
        var numbers: [Rational] = []
        var operators: [String] = []
        
        func performOperation() {
            guard let op = operators.popLast(),
                  numbers.count >= 2 else { return }
            
            let rhs = numbers.removeLast()
            let lhs = numbers.removeLast()
            
            let result: Rational
            switch op {
            case "+":
                result = Calculator.add(lhs, rhs)
            case "-":
                result = Calculator.subtract(lhs, rhs)
            case "*":
                result = multiply(lhs, rhs)
            case "/":
                result = divide(lhs, rhs)
            default:
                return
            }
            numbers.append(result)
        }
        
        for token in expression {
            if let number = parseRational(token) {
                numbers.append(number)
            } else {
                while !operators.isEmpty &&
                      getPriority(operators.last!) >= getPriority(token) {
                    performOperation()
                }
                operators.append(token)
            }
        }
        
        while !operators.isEmpty {
            performOperation()
        }
        
        return numbers.last
    }
    
    private func parseRational(_ str: String) -> Rational? {
        let components = str.split(separator: "/")
        guard components.count == 2,
              let num = Int(components[0]),
              let den = Int(components[1]) else {
            return nil
        }
        return Rational(numerator: num, denominator: den)
    }
    
    private func getPriority(_ op: String) -> Int {
        switch op {
        case "+", "-": return 1
        case "*", "/": return 2
        default: return 0
        }
    }
}

// Демонстрація роботи
func demonstrateCalculator() {
    let calc = Calculator.shared
    
    // Створення раціональних чисел
    let a = Rational(numerator: 1, denominator: 2)
    let b = Rational(numerator: 2, denominator: 3)
    let c = Rational(numerator: 3, denominator: 4)
    
    print("Числа для операцій:")
    print("a =", a)
    print("b =", b)
    print("c =", c)
    
    // Демонстрація базових операцій
    print("\nБазові операції:")
    print("a + b =", Calculator.add(a, b))
    print("b - c =", Calculator.subtract(b, c))
    print("a * c =", calc.multiply(a, c))
    print("b / c =", calc.divide(b, c))
    
    print("a == a.copy():", a == a.copy())
    
    // Демонстрація обчислення виразу з пріоритетами
    let expression = ["1/2", "*", "2/3", "+", "3/4", "*", "1/2"]
    print("\nОбчислення виразу", expression.joined(separator: " "))
    if let result = calc.evaluate(expression) {
        print("Результат =", result)
    }
}

// Запуск демонстрації
demonstrateCalculator()
