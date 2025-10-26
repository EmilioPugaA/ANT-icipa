//
//  CustomTextField.swift
//  ANTicipa
//
//  Created by Emilio Puga on 25/10/25.
//


import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool
    var icon: String
    var toggleAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(BrandColors.textPrimary.opacity(0.7))

            HStack {
                if isSecure {
                    SecureField("", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                } else {
                    TextField("", text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                }

                if let toggle = toggleAction {
                    Button(action: toggle) {
                        Image(systemName: icon)
                            .foregroundColor(BrandColors.textPrimary.opacity(0.5))
                    }
                } else {
                    Image(systemName: icon)
                        .foregroundColor(BrandColors.textPrimary.opacity(0.5))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(BrandColors.textPrimary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CustomTextField(
        title: "Usuario",
        text: .constant("Emilio"),
        isSecure: false,
        icon: "person.fill"
    )
    .padding()
    .background(Color.white)
}
