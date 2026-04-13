import SwiftUI
import FoundationModels

struct foundationClass{
 
// MARK: - App Entry Point
 
@main
struct NeuraChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 
// MARK: - Root Tab View
 
struct ContentView: View {
    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.sparkles")
                }
            SummarizeView()
                .tabItem {
                    Label("Summarize", systemImage: "doc.text.magnifyingglass")
                }
        }
    }
}
 
// MARK: - Data Models
 
struct Message: Identifiable {
    let id = UUID()
    let role: Role
    var text: String
 
    enum Role { case user, assistant }
}
 
// MARK: - View Model
 
@Observable
class ChatViewModel {
    var messages: [Message] = []
    var isStreaming = false
    var inputText = ""
    private var session = LanguageModelSession()
 
    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
 
        messages.append(Message(role: .user, text: text))
        messages.append(Message(role: .assistant, text: ""))
        isStreaming = true
 
        do {
            var reply = ""
            for try await chunk in session.streamResponse(to: text) {
                reply += chunk
                messages[messages.endIndex - 1].text = reply
            }
        } catch {
            messages[messages.endIndex - 1].text = "⚠️ \(error.localizedDescription)"
        }
 
        isStreaming = false
    }
 
    func clear() {
        messages = []
        session = LanguageModelSession()
    }
}
 
// MARK: - Chat View
 
struct ChatView: View {
    @State private var viewModel = ChatViewModel()
 
    var body: some View {
        ZStack {
            MeshGradientBackground()
                .ignoresSafeArea()
 
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NeuraChat")
                            .font(.title2.bold())
                        Text("On-device · Private · Instant")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: { viewModel.clear() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
 
                // Message list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.messages.isEmpty {
                                EmptyStateView()
                                    .padding(.top, 60)
                            }
                            ForEach(viewModel.messages) { msg in
                                MessageBubble(message: msg)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation(.spring(duration: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
 
                // Input bar
                InputBar(
                    text: $viewModel.inputText,
                    isStreaming: viewModel.isStreaming
                ) {
                    Task { await viewModel.send() }
                }
            }
        }
    }
}
 
// MARK: - Message Bubble
 
struct MessageBubble: View {
    let message: Message
    var isUser: Bool { message.role == .user }
 
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }
 
            if !isUser {
                ZStack {
                    Circle()
                        .fill(.purple.gradient)
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
 
            Text(message.text.isEmpty ? "●●●" : message.text)
                .font(.body)
                .foregroundStyle(isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if isUser {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
 
            if !isUser { Spacer(minLength: 60) }
        }
        .animation(.spring(duration: 0.35), value: message.text)
    }
}
 
// MARK: - Input Bar
 
struct InputBar: View {
    @Binding var text: String
    let isStreaming: Bool
    let onSend: () -> Void
 
    var body: some View {
        HStack(spacing: 10) {
            TextField("Message", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .onSubmit { onSend() }
 
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(text.isEmpty ? Color.secondary.opacity(0.3) : Color.purple)
                        .frame(width: 44, height: 44)
                    Image(systemName: isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse, isActive: isStreaming)
                }
            }
            .disabled(text.isEmpty && !isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
 
// MARK: - Animated Mesh Gradient Background
 
struct MeshGradientBackground: View {
    @State private var phase: CGFloat = 0
 
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5],
                [Float(0.5 + 0.1 * sin(phase)), Float(0.5)],
                [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                .purple.opacity(0.6), .blue.opacity(0.4), .cyan.opacity(0.3),
                .indigo.opacity(0.3), .purple.opacity(0.2), .blue.opacity(0.3),
                .black, .indigo.opacity(0.5), .purple.opacity(0.4)
            ]
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                phase = .pi
            }
        }
    }
}
 
// MARK: - Empty State
 
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.purple.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(.purple.gradient)
                    .symbolEffect(.pulse)
            }
            VStack(spacing: 6) {
                Text("NeuraChat is ready")
                    .font(.headline)
                Text("100% on-device. Zero data leaves your phone.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
 
// MARK: - Structured Output Model
 
@Generable
struct ArticleSummary {
    @Guide(description: "One sentence summary of the text")
    var headline: String
 
    @Guide(description: "Up to 3 key bullet points from the text")
    var bullets: [String]
 
    @Guide(description: "Overall sentiment: positive, neutral, or negative")
    var sentiment: String
}
 
// MARK: - Summarize View
 
struct SummarizeView: View {
    @State private var inputText = ""
    @State private var summary: ArticleSummary?
    @State private var isLoading = false
    @State private var errorMessage: String?
 
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradientBackground()
                    .ignoresSafeArea()
 
                Form {
                    Section("Paste your text") {
                        TextEditor(text: $inputText)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
 
                    Section {
                        Button {
                            Task { await summarize() }
                        } label: {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Label("Summarize with AI", systemImage: "sparkles")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(inputText.isEmpty || isLoading
                                      ? Color.secondary.opacity(0.4)
                                      : Color.purple)
                        )
                        .disabled(inputText.isEmpty || isLoading)
                    }
 
                    if let error = errorMessage {
                        Section {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                        .listRowBackground(Color.white.opacity(0.08))
                    }
 
                    if let s = summary {
                        Section("Headline") {
                            Text(s.headline)
                                .fontWeight(.semibold)
                        }
                        .listRowBackground(Color.white.opacity(0.08))
 
                        Section("Key points") {
                            ForEach(s.bullets, id: \.self) { point in
                                Label(point, systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.primary)
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.08))
 
                        Section("Sentiment") {
                            HStack {
                                Circle()
                                    .fill(sentimentColor(s.sentiment))
                                    .frame(width: 10, height: 10)
                                Text(s.sentiment.capitalized)
                                    .foregroundStyle(sentimentColor(s.sentiment))
                                    .fontWeight(.medium)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.08))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Summarizer")
            .navigationBarTitleDisplayMode(.large)
        }
    }
 
    func summarize() async {
        isLoading = true
        errorMessage = nil
        summary = nil
        let session = LanguageModelSession()
        do {
            summary = try await session.respond(
                to: "Summarize this text concisely: \(inputText)",
                generating: ArticleSummary.self
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
 
    func sentimentColor(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "positive": return .green
        case "negative": return .red
        default: return .secondary
        }
    }
}
 
}
