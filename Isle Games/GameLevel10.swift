import SwiftUI

struct GameLevel10: View {
    let gridRows = 6
    let gridCols = 6
    let plusPositions: Set<[Int]> = [[0, 2], [2, 1], [3, 4], [5, 3]]
    
    @State private var block1Position: CGPoint = CGPoint(x: 350, y: 50)
    @State private var block2Position: CGPoint = CGPoint(x: 370, y: 70)
    @State private var block3Position: CGPoint = CGPoint(x: 350, y: 90)
    @State private var block4Position: CGPoint = CGPoint(x: 370, y: 110)
    @State private var hasWon: Bool = false // Новый флаг для фиксации победы
    
    let cellSize: CGFloat = 50
    let fieldOffsetX: CGFloat = 50
    let fieldOffsetY: CGFloat = 50
    @AppStorage("currentSelectedCloseCard") private var currentSelectedCloseCard: String = "background1"
    
    let gridPattern: [[Bool]] = [
        [false, false, true, true, false, false], // 0
        [false, false, true, true, false, false], // 1
        [true, true, true, true, true, true],     // 2
        [true, true, true, true, true, true],     // 3
        [false, false, true, true, false, false], // 4
        [false, false, true, true, false, false]  // 5
    ]
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                        ZStack {
                            VStack {
                                HStack {
                                    Image("back")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding()
                                        .foregroundStyle(.white)
                                        .onTapGesture {
                                            AppNavigator.shared.currentScreen = .MENU
                                        }
                                    Spacer()
                                }
                                Spacer()
                            }
                            
                            // Игровое поле с узором "крест"
                            VStack(spacing: 0) {
                                ForEach(0..<gridRows, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<gridCols, id: \.self) { col in
                                            ZStack {
                                                if gridPattern[row][col] {
                                                    Image("cell")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: cellSize, height: cellSize)
                                                    if plusPositions.contains([row, col]) {
                                                        Image("plus")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                                                    }
                                                } else {
                                                    Color.clear
                                                        .frame(width: cellSize, height: cellSize)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .position(x: fieldOffsetX + CGFloat(gridCols) * cellSize / 2, y: fieldOffsetY + CGFloat(gridRows) * cellSize / 2)
                            
                            // Блок 1: Линия 2 горизонтальная
                            BlockView10(shape: [
                                [true, true]
                            ], plusPositions: [[0, 1]], position: $block1Position, cellSize: cellSize, cellImage: "greenCell")
                                .gesture(
                                    !hasWon ? DragGesture() // Отключаем перетаскивание после победы
                                        .onChanged { value in
                                            block1Position = value.location
                                        }
                                        .onEnded { _ in
                                            snapToGrid(position: &block1Position)
                                            if isWin() { hasWon = true }
                                        } : nil
                                )
                            
                            // Блок 2: Линия 2 вертикальная
                            BlockView10(shape: [
                                [true],
                                [true]
                            ], plusPositions: [[0, 0]], position: $block2Position, cellSize: cellSize, cellImage: "redCell")
                                .gesture(
                                    !hasWon ? DragGesture()
                                        .onChanged { value in
                                            block2Position = value.location
                                        }
                                        .onEnded { _ in
                                            snapToGrid(position: &block2Position)
                                            if isWin() { hasWon = true }
                                        } : nil
                                )
                            
                            // Блок 3: L-форма
                            BlockView10(shape: [
                                [true, false],
                                [true, true]
                            ], plusPositions: [[1, 1]], position: $block3Position, cellSize: cellSize, cellImage: "yellowCell")
                                .gesture(
                                    !hasWon ? DragGesture()
                                        .onChanged { value in
                                            block3Position = value.location
                                        }
                                        .onEnded { _ in
                                            snapToGrid(position: &block3Position)
                                            if isWin() { hasWon = true }
                                        } : nil
                                )
                            
                            // Блок 4: Квадрат 2x2
                            BlockView10(shape: [
                                [true, true],
                                [true, true]
                            ], plusPositions: [[0, 0]], position: $block4Position, cellSize: cellSize, cellImage: "redCell")
                                .gesture(
                                    !hasWon ? DragGesture()
                                        .onChanged { value in
                                            block4Position = value.location
                                        }
                                        .onEnded { _ in
                                            snapToGrid(position: &block4Position)
                                            if isWin() { hasWon = true }
                                        } : nil
                                )
                            
                            // Экран победы показывается только после победы и не исчезает
                            if hasWon {
                                WinView10()
                            }
                        }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    Image(currentSelectedCloseCard)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .scaleEffect(1.1)
                )
            }
        }
    }
    
    private func snapToGrid(position: inout CGPoint) {
        let x = round((position.x - fieldOffsetX) / cellSize) * cellSize + fieldOffsetX
        let y = round((position.y - fieldOffsetY) / cellSize) * cellSize + fieldOffsetY
        position = CGPoint(x: x, y: y)
        
        position.x = max(fieldOffsetX, min(position.x, fieldOffsetX + CGFloat(gridCols - 1) * cellSize))
        position.y = max(fieldOffsetY, min(position.y, fieldOffsetY + CGFloat(gridRows - 1) * cellSize))
    }
    
    private func isWin() -> Bool {
        let allBlocks = [
            (shape: [[true, true]], plus: [[0, 1]], pos: block1Position),
            (shape: [[true], [true]], plus: [[0, 0]], pos: block2Position),
            (shape: [[true, false], [true, true]], plus: [[1, 1]], pos: block3Position),
            (shape: [[true, true], [true, true]], plus: [[0, 0]], pos: block4Position)
        ]
        
        var coveredPlus = Set<[Int]>()
        
        for block in allBlocks {
            let gridX = Int((block.pos.x - fieldOffsetX) / cellSize)
            let gridY = Int((block.pos.y - fieldOffsetY) / cellSize)
            
            for row in 0..<block.shape.count {
                for col in 0..<block.shape[row].count where block.shape[row][col] {
                    let fieldRow = gridY + row
                    let fieldCol = gridX + col
                    
                    if fieldRow >= gridRows || fieldCol >= gridCols || fieldCol < 0 || !gridPattern[fieldRow][fieldCol] {
                        return false
                    }
                    
                    if block.plus.contains([row, col]) {
                        coveredPlus.insert([fieldRow, fieldCol])
                    }
                }
            }
        }
        
        print("Covered Plus: \(coveredPlus)")
        print("Expected Plus: \(plusPositions)")
        return coveredPlus == plusPositions
    }
}

struct BlockView10: View {
    let shape: [[Bool]]
    let plusPositions: [[Int]]
    @Binding var position: CGPoint
    let cellSize: CGFloat
    let cellImage: String
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<shape.count, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<shape[0].count, id: \.self) { col in
                        ZStack {
                            if shape[row][col] {
                                Image(cellImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: cellSize, height: cellSize)
                                if plusPositions.contains([row, col]) {
                                    Image("plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                                }
                            } else {
                                Color.clear
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: CGFloat(shape[0].count) * cellSize, height: CGFloat(shape.count) * cellSize)
        .position(x: position.x + CGFloat(shape[0].count) * cellSize / 2,
                  y: position.y + CGFloat(shape.count) * cellSize / 2)
    }
}

struct WinView10: View {
    @AppStorage("level") var level: Int = 1
    @AppStorage("coinscore") var coinscore: Int = 10
    @AppStorage("starscore") var starscore: Int = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("winPlate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 380, height: 380)
                    .padding(.top, 60)
                
                VStack(spacing: -20) {
                    Button(action: {
                        level += 1
                        coinscore += 10
                        starscore += 3
                        AppNavigator.shared.currentScreen = .MENU
                    }) {
                        Image("nextBtn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 90)
                    }
                    
                    Image("menuBtn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 90)
                        .onTapGesture {
                            AppNavigator.shared.currentScreen = .MENU
                            level += 1
                        }
                }
                .padding(.top, 60)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}


#Preview {
    GameLevel10()
}
