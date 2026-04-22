import SwiftUI

/// Reusable press-effect button style matching the Apple Health aesthetic.
/// Provides subtle scale change on press using spring animation.
struct PressableCardButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}
