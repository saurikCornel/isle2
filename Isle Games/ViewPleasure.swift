import SwiftUI

struct ViewPleasure: View {
    let pageURL: URL

    var body: some View {
        GeometryReader { geo in
            ZStack {
                BrowserView(pageURL: pageURL)
            }
        }
    }
}


