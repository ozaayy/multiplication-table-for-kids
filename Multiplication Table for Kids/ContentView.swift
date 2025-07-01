import SwiftUI

struct Question {
    let left: Int
    let right: Int
    var answer: Int { left * right }
    var choices: [Int] {
        var options = [answer]
        while options.count < 4 {
            let random = Int.random(in: 1...144)
            if !options.contains(random) {
                options.append(random)
            }
        }
        return options.shuffled()
    }
}

struct ContentView: View {
    @State private var currentQuestion: Question = ContentView.generateQuestion()
    @State private var score: Int = 0
    @State private var questionNumber: Int = 1
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var timeLeft: Int = 30
    @State private var timer: Timer? = nil
    @State private var quizFinished: Bool = false
    @State private var choices: [Int] = []
    @State private var totalTime: Double = 0
    @State private var questionStartTime: Date = Date()
    @State private var bestScore: Double = UserDefaults.standard.double(forKey: "BestScore")

    static func generateQuestion() -> Question {
        Question(left: Int.random(in: 1...12), right: Int.random(in: 1...12))
    }

    func startTimer() {
        timer?.invalidate()
        timeLeft = 30
        questionStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
                checkAnswer(timeout: true)
            }
        }
    }

    func checkAnswer(selected: Int? = nil, timeout: Bool = false) {
        timer?.invalidate()
        let timeSpent = Date().timeIntervalSince(questionStartTime)
        totalTime += timeSpent
        if !timeout, let selected = selected, selected == currentQuestion.answer {
            score += 1
            isCorrect = true
        } else {
            isCorrect = false
        }
        showResult = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextQuestion()
        }
    }

    func nextQuestion() {
        if questionNumber == 20 {
            quizFinished = true
            // Skor kaydı
            if bestScore == 0 || totalTime < bestScore {
                bestScore = totalTime
                UserDefaults.standard.set(bestScore, forKey: "BestScore")
            }
            return
        }
        questionNumber += 1
        currentQuestion = ContentView.generateQuestion()
        choices = currentQuestion.choices
        showResult = false
        startTimer()
    }

    func restartQuiz() {
        score = 0
        questionNumber = 1
        quizFinished = false
        totalTime = 0
        currentQuestion = ContentView.generateQuestion()
        choices = currentQuestion.choices
        showResult = false
        startTimer()
    }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        VStack(spacing: 30) {
            if quizFinished {
                Text("Quiz Bitti! Skorun: \(score)/20")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 130/255, green: 32/255, blue: 74/255))
                        .shadow(radius: 4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(String(format: "Toplam Süre: %.1f sn", totalTime))
                        .font(.title2)
                        .foregroundColor(Color(red: 76/255, green: 154/255, blue: 154/255))
                    if bestScore > 0 {
                        Text(String(format: "En iyi süren: %.1f sn", bestScore))
                            .font(.title3)
                            .foregroundColor(Color(red: 242/255, green: 108/255, blue: 167/255))
                    }
                    Button(action: restartQuiz) {
                        Text("Tekrar Başla")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color(red: 76/255, green: 154/255, blue: 154/255))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .padding(.top, 20)
            } else {
                Text("Soru \(questionNumber)/20")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 34/255, green: 62/255, blue: 67/255))
                        .padding(.top, 20)
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 76/255, green: 154/255, blue: 154/255))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text("\(currentQuestion.left)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                        Text("x")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 242/255, green: 108/255, blue: 167/255))
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 130/255, green: 32/255, blue: 74/255))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Text("\(currentQuestion.right)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                        Text("=")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 34/255, green: 62/255, blue: 67/255))
                    }
                Text("Kalan Süre: \(timeLeft) sn")
                    .font(.headline)
                        .foregroundColor(Color(red: 76/255, green: 154/255, blue: 154/255))
                    VStack(spacing: 16) {
                        ForEach(choices, id: \ .self) { choice in
                            Button(action: {
                                checkAnswer(selected: choice)
                            }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.9))
                                    .frame(height: 48)
                                    .overlay(
                                        Text("\(choice)")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 34/255, green: 62/255, blue: 67/255))
                                    )
                                    .shadow(radius: 1)
                            }
                            .disabled(showResult)
                        }
                    }
                if showResult {
                    Text(isCorrect ? "Doğru!" : "Yanlış! Doğru cevap: \(currentQuestion.answer)")
                            .foregroundColor(isCorrect ? Color(red: 76/255, green: 154/255, blue: 154/255) : Color(red: 242/255, green: 108/255, blue: 167/255))
                            .font(.title2)
                            .fontWeight(.bold)
                            .transition(.scale)
                }
            }
        }
        .padding()
        }
        .onAppear {
            choices = currentQuestion.choices
            startTimer()
        }
    }
}
