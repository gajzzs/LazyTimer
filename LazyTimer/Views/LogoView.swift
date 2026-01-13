import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            // Background Container (App Icon Shape)
            RoundedRectangle(cornerRadius: 110, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#0f3460"), // Dark Blue
                            Color(hex: "#16213e"), // Darker Blue
                            Color(hex: "#533483")  // Purple accent
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 512, height: 512)
                .overlay(
                    RoundedRectangle(cornerRadius: 110, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 4)
                )
                .shadow(radius: 20)
            
            // THE STOPWATCH (Built Upright -> Then Rotated)
            ZStack {
                // 1. Top Button (Clicker) - Attached to top of circle
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 48, height: 24)
                    
                    Rectangle()
                        .fill(Color(white: 0.95))
                        .frame(width: 20, height: 16)
                }
                .offset(y: -178)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2) // Subtle button shadow
                
                // 2. Right Ear (Angled Button)
                Rectangle()
                    .fill(Color(white: 0.95))
                    .frame(width: 18, height: 24)
                    .offset(y: -160)
                    .rotationEffect(.degrees(45))
                
                // 3. Main Body
                ZStack {
                    // Outer rim shadow for 3D feel
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 320, height: 320)
                        .offset(y: 4)
                        .blur(radius: 4)
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 32)
                        .background(Circle().fill(Color.white.opacity(0.05)))
                        .frame(width: 320, height: 320)
                }
                
                // 4. Face Text
                VStack(spacing: -12) {
                    Text("25")
                        .font(.custom("DIN Alternate", size: 140)) // Reduced from 160
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                        .offset(x: -5)
                    
                    Text(":00")
                        .font(.custom("DIN Alternate", size: 60)) // Reduced from 70
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        .offset(x: 35)
                }
                .offset(y: 5) // Move slightly up (was 10)
            }
            .offset(y: 20)
            .rotationEffect(.degrees(20))
            // MATERIAL SHADOWS - The "Pop" Effect
            .shadow(color: .black.opacity(0.4), radius: 30, x: 10, y: 20) // Deep ambient shadow
            .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 5)   // Sharp contact shadow
            
            // "Zzz" Bubble
            VStack(spacing: -10) {
                Text("z")
                    .font(.system(size: 90, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5)
                    .offset(x: 40)
                                
                Text("z")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 3, y: 3)
                    .offset(x: 100, y: -20)
            }
            .rotationEffect(.degrees(20))
            .offset(x: 120, y: -160)
        }
        .frame(width: 512, height: 512)
    }
}



#Preview {
    LogoView()
        .preferredColorScheme(.dark)
}
