import SwiftUI

struct RootView: View {
    @State private var isSidebarPresented = false
    @State private var currentChat: Chat?

    var body: some View {
        ZStack(alignment: .leading) {
            ChatView(isSidebarPresented: $isSidebarPresented, currentChat: $currentChat)

            if isSidebarPresented {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { isSidebarPresented = false }
                    .transition(.opacity)

                SidebarView(isPresented: $isSidebarPresented, currentChat: $currentChat)
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeOut(duration: 0.25), value: isSidebarPresented)
    }
}
