import SwiftUI

struct MessageBubble: View {
    var message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.role == "model" {
                // 🐜 Mensaje de Capi
                Image(message.imageName ?? "hormigaWha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.senderName ?? "Capi")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(message.text)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                        .foregroundColor(.black.opacity(0.85))
                }
                Spacer(minLength: 40)
            } else {
                // 👤 Mensaje del usuario
                Spacer(minLength: 40)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.senderName ?? "Tú")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(message.text)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                        .foregroundColor(.black.opacity(0.85))
                }
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding(.horizontal, 18)
    }
}
