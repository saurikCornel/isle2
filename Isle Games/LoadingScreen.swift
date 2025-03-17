import SwiftUI

struct LoadingScreen: View {
    @State private var currentWheelImageIndex = 0
    @State private var isAnimating = true
    @State private var progress: Int = 0
    @State private var isActive = false
    @State private var urlToLoad: URL?
    @AppStorage("isNeeded") private var isNeeded: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    Image(.backgroundLoading)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.32)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .onAppear {
                Task {
                    let validURL = await NetworkManager.isURLValid()
                    print("URL Valid: \(validURL)") // Отладка
                    
                    if validURL, let validLink = URL(string: urlForValidation) {
                        self.urlToLoad = validLink
                        withAnimation {
                            isNeeded = true
                            isActive = true
                            AppNavigator.shared.currentScreen = .MENU
                            print("Set to MENU, isNeeded: \(isNeeded), isActive: \(isActive)")
                        }
                    } else {
                        self.urlToLoad = URL(string: urlForValidation)
                        withAnimation {
                            isNeeded = false
                            isActive = true
                            AppNavigator.shared.currentScreen = .PLEASURE
                            print("Set to PLEASURE, isNeeded: \(isNeeded), isActive: \(isActive)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoadingScreen()
}
