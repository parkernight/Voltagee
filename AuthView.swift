import SwiftUI

struct AuthView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var creating = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var busy = false
    @State private var note: String?
    @State private var noteIsError = true

    private let fieldBg = Color(hex: 0x10141F)
    private let fieldBorder = Color(hex: 0x1E3A52)
    private let blue = Color(hex: 0x52B2D8)

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0C1730), Color(hex: 0x050A14)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    Text("VOLTAGE").font(.vTitle(54)).tracking(12).foregroundColor(Color(hex: 0xD6E8FF))
                    Text("STREAM EVERYTHING").font(.outfit(13, .medium)).tracking(5)
                        .foregroundColor(Color(hex: 0x3B7191))

                    HStack(spacing: 0) {
                        tab("SIGN IN", on: !creating) { creating = false; note = nil }
                        tab("CREATE ACCOUNT", on: creating) { creating = true; note = nil }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(fieldBorder, lineWidth: 1))

                    if creating {
                        field { TextField("Name", text: $name).textInputAutocapitalization(.words) }
                    }
                    field {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    field {
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye").foregroundColor(.vMuted)
                            }
                        }
                    }

                    if !creating {
                        HStack {
                            Spacer()
                            Button("Forgot password?") { forgot() }
                                .font(.outfit(14)).foregroundColor(Color(hex: 0x3B7191))
                        }
                    }

                    if let note = note {
                        Text(note).font(.outfit(14))
                            .foregroundColor(noteIsError ? Color(hex: 0xFF6B6B) : Color(hex: 0x2EE6B8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button { submit() } label: {
                        Group {
                            if busy { ProgressView().tint(.black) }
                            else { Text(creating ? "CREATE ACCOUNT" : "SIGN IN").font(.outfit(17, .heavy)).tracking(3) }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(LinearGradient(colors: [blue, Color(hex: 0x3E8FB0)], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(busy)
                }
                .padding(24)
                .background(Color(hex: 0x060B14))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color(hex: 0x12263A), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 90)
                .padding(.bottom, 40)
            }
        }
    }

    private func tab(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.outfit(14, .bold)).tracking(2)
                .foregroundColor(on ? .black : .vMuted)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(on ? blue : Color.clear)
        }
    }

    private func field<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .font(.outfit(18)).foregroundColor(.white)
            .padding(.horizontal, 18).frame(minHeight: 58)
            .background(fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(fieldBorder, lineWidth: 1))
    }

    private func submit() {
        let e = email.trimmingCharacters(in: .whitespaces)
        guard !e.isEmpty, !password.isEmpty else { note = "Enter your email and password."; noteIsError = true; return }
        busy = true
        note = nil
        Task {
            let err: String?
            if creating {
                err = await auth.signUp(name: name.trimmingCharacters(in: .whitespaces), email: e, password: password)
            } else {
                err = await auth.signIn(email: e, password: password)
            }
            busy = false
            if let err = err { note = err; noteIsError = true }
        }
    }

    private func forgot() {
        let e = email.trimmingCharacters(in: .whitespaces)
        guard !e.isEmpty else { note = "Enter your email above first."; noteIsError = true; return }
        Task {
            let err = await auth.resetPassword(email: e)
            note = err ?? "Password reset email sent."
            noteIsError = err != nil
        }
    }
}
