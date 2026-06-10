//
//  ChatView.swift
//  LeapPlan
//
//  Created by student on 10/06/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("kodok_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.messages) { msg in
                                ChatBubble(message: msg)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(12)
                                        .background(Color.gray.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("LoadingIndicator")
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        withAnimation { proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom) }
                    }
                    .onChange(of: viewModel.isLoading) { loading in
                        if loading {
                            withAnimation { proxy.scrollTo("LoadingIndicator", anchor: .bottom) }
                        }
                    }
                }
                
                HStack(alignment: .bottom, spacing: 10) {
                    TextField("Tanya destinasi wisata...", text: $viewModel.inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                        .focused($isFocused)
                    
                    Button(action: {
                        isFocused = false
                        Task { await viewModel.sendMessage() }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(viewModel.inputText.isEmpty ? Color.gray : Color.leapPrimary)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding()
            }
            }
            .navigationTitle("LeapBot AI")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                isFocused = false
            }
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var isUser: Bool { return message.role == "user" }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(message.content)
                .padding(14)
                .background(isUser ? Color.leapPrimary : Color.gray.opacity(0.15))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(isUser ? Color.leapPrimary : Color.gray.opacity(0.15))
                        .rotationEffect(.degrees(isUser ? -45 : 45))
                        .offset(x: isUser ? 5 : -5, y: 5)
                    , alignment: isUser ? .bottomTrailing : .bottomLeading
                )
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ChatView()
}
