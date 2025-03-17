import SwiftUI

struct GameLevel3: View {
    let gridRows = 6
    let gridCols = 5
    let plusPositions: Set<[Int]> = [[1, 1], [3, 2], [4, 4]]
    
    @State private var block1Position: CGPoint = CGPoint(x: -100, y: 0)
    @State private var block2Position: CGPoint = CGPoint(x: -100, y: 100)
    @State private var block3Position: CGPoint = CGPoint(x: -100, y: 200)
    @State private var hasWon: Bool = false // Новый флаг для фиксации победы
    
    @AppStorage("currentSelectedCloseCard") private var currentSelectedCloseCard: String = "background1"
    
    let cellSize: CGFloat = 50
    
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
                            
                            // Игровое поле 6x5
                            VStack(spacing: 0) {
                                ForEach(0..<gridRows, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<gridCols, id: \.self) { col in
                                            ZStack {
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
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Блок 1: Г-образная форма с greenCell
                            BlockView3(shape: [
                                [true, false],
                                [true, true],
                                [true, false]
                            ], plusPositions: [[1, 0]], position: $block1Position, cellSize: cellSize, cellImage: "greenCell")
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
                            
                            // Блок 2: Линия 3 с redCell
                            BlockView3(shape: [
                                [true, true, true]
                            ], plusPositions: [[0, 1]], position: $block2Position, cellSize: cellSize, cellImage: "redCell")
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
                            
                            // Блок 3: Угловой блок с yellowCell
                            BlockView3(shape: [
                                [true, true],
                                [false, true]
                            ], plusPositions: [[0, 1]], position: $block3Position, cellSize: cellSize, cellImage: "yellowCell")
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
                            
                            // Экран победы показывается только после победы и не исчезает
                            if hasWon {
                                WinView3()
                            }
                        }
                        .frame(width: CGFloat(gridCols) * cellSize, height: CGFloat(gridRows) * cellSize)
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
        let x = round(position.x / cellSize) * cellSize
        let y = round(position.y / cellSize) * cellSize
        position = CGPoint(x: x, y: y)
        
        position.x = max(0, min(position.x, CGFloat(gridCols - 1) * cellSize))
        position.y = max(0, min(position.y, CGFloat(gridRows - 1) * cellSize))
    }
    
    private func isWin() -> Bool {
        let allBlocks = [
            (shape: [[true, false], [true, true], [true, false]], plus: [[1, 0]], pos: block1Position),
            (shape: [[true, true, true]], plus: [[0, 1]], pos: block2Position),
            (shape: [[true, true], [false, true]], plus: [[0, 1]], pos: block3Position)
        ]
        
        var coveredPlus = Set<[Int]>()
        
        for block in allBlocks {
            let gridX = Int(block.pos.x / cellSize)
            let gridY = Int(block.pos.y / cellSize)
            
            for row in 0..<block.shape.count {
                for col in 0..<block.shape[row].count where block.shape[row][col] {
                    let fieldRow = gridY + row
                    let fieldCol = gridX + col
                    
                    if fieldRow >= gridRows || fieldCol >= gridCols {
                        return false
                    }
                    
                    if block.plus.contains([row, col]) {
                        coveredPlus.insert([fieldRow, fieldCol])
                    }
                }
            }
        }
        
        return coveredPlus == plusPositions
    }
}

struct BlockView3: View {
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
        .position(x: position.x + CGFloat(shape[0].count) * cellSize / 2,
                  y: position.y + CGFloat(shape.count) * cellSize / 2)
    }
}

struct WinView3: View {
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
                        AppNavigator.shared.currentScreen = .LEVEL4
                        coinscore += 10
                        starscore += 3
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
    GameLevel3()
}
