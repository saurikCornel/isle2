import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let imageName: String
    var isFlipped = false
    var isMatched = false
}


struct CardGame: View {
    @StateObject private var soundChecker = CheckingSound() // Добавляем доступ к настройкам звука
    @State private var cards: [Card] = []
    @State private var selectedCards: [Int] = []
    @State private var matchedPairs = 0
    @State private var mistakes = 0
    @State private var isGameOver = false
    
    init() {
        let baseCards = ["card1", "card2", "card3", "card4", "card5", "card6"]
        let shuffledCards = (baseCards + baseCards).shuffled().map { Card(imageName: $0) }
        _cards = State(initialValue: shuffledCards)
    }
    
    func flipCard(at index: Int) {
        guard !cards[index].isFlipped, selectedCards.count < 2 else { return }
        
        cards[index].isFlipped.toggle()
        selectedCards.append(index)
        
        // Воспроизводим звук, соответствующий карточке
        if soundChecker.soundEnabled {
            let cardName = cards[index].imageName // Например, "card1"
            let soundName = "sound\(cardName.dropFirst(4))" // Преобразуем "card1" в "sound1"
            SoundManager.shared.playSound(soundName)
        }
        
        if selectedCards.count == 2 {
            checkForMatch()
        }
    }
    
    func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if cards[selectedCards[0]].imageName == cards[selectedCards[1]].imageName {
                cards[selectedCards[0]].isMatched = true
                cards[selectedCards[1]].isMatched = true
                matchedPairs += 1
                
                if matchedPairs == cards.count / 2 {
                    isGameOver = true
                }
            } else {
                cards[selectedCards[0]].isFlipped = false
                cards[selectedCards[1]].isFlipped = false
                mistakes += 1
                
                if mistakes >= 1000 {
                    isGameOver = true
                }
            }
            selectedCards.removeAll()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                VStack {
                    HStack {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.top, 60)
                            .padding()
                            .foregroundStyle(.white)
                            .onTapGesture {
                                AppNavigator.shared.currentScreen = .MENU
                            }
                        Spacer()
                    }
                    Spacer()
                }
                    if isGameOver {
                        if matchedPairs == cards.count / 2 {
                            WinViewLevel3()
                        }
                    } else {
                        VStack {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                                ForEach(cards.indices, id: \.self) { index in
                                    CardView(card: cards[index])
                                        .onTapGesture {
                                            flipCard(at: index)
                                        }
                                }
                            }
                            .padding()
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.background3)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        Image(card.isFlipped || card.isMatched ? card.imageName : "closeCard")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 100)
            .cornerRadius(10)
    }
}

struct WinViewLevel3: View {
    @AppStorage("currentLevel") var currentLevel = 1
    @AppStorage("starscore") var starscore: Int = 10
    @AppStorage("coinscore") var coinscore: Int = 10

    var body: some View {
        ZStack {
            Image(.winPlate2)
                .resizable()
                .scaledToFit()
                .frame(width: 550)
                .onTapGesture {
                    currentLevel += 1
                    starscore += 3
                    coinscore += 10
                    AppNavigator.shared.currentScreen = .MENU
                }
        }
    }
}

#Preview {
    CardGame()
}
