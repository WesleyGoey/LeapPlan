//
//  ChatViewModelTests.swift
//  LeapPlanTests
//
//  Created by student on 11/06/26.
//

import XCTest
import Combine
@testable import LeapPlan

@MainActor
final class ChatViewModelTests: XCTestCase {
    var viewModel: ChatViewModel!
    var mockGroqService: MockGroqService!

    override func setUp() {
        super.setUp()
        mockGroqService = MockGroqService()
        viewModel = ChatViewModel(groqService: mockGroqService)
    }

    override func tearDown() {
        viewModel = nil
        mockGroqService = nil
        super.tearDown()
    }

    func testInitialization_AddsWelcomeMessage() {
        // Assert
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.role, "assistant")
        XCTAssertFalse(viewModel.messages.first?.content.isEmpty ?? true)
    }

    func testSendMessage_IgnoresEmptyInput() async {
        viewModel.inputText = "   "
        
        // Act
        await viewModel.sendMessage()

        // Assert
        XCTAssertEqual(viewModel.messages.count, 1) // Only welcome message
        XCTAssertFalse(mockGroqService.didCallSendMessage)
    }

    func testSendMessage_Success() async {
        // Arrange
        viewModel.inputText = "Hello there"
        mockGroqService.mockResponse = "Hi, how can I help?"

        // Act
        await viewModel.sendMessage()

        // Assert
        XCTAssertEqual(viewModel.messages.count, 3) // Welcome, User, Assistant
        XCTAssertEqual(viewModel.messages[1].role, "user")
        XCTAssertEqual(viewModel.messages[1].content, "Hello there")
        
        XCTAssertEqual(viewModel.messages[2].role, "assistant")
        XCTAssertEqual(viewModel.messages[2].content, "Hi, how can I help?")
        
        XCTAssertTrue(mockGroqService.didCallSendMessage)
        XCTAssertTrue(viewModel.inputText.isEmpty) // Input should be cleared
        XCTAssertFalse(viewModel.isLoading) // Should stop loading
    }

    func testSendMessage_Failure() async {
        // Arrange
        viewModel.inputText = "Trigger error"
        mockGroqService.shouldThrowError = true

        // Act
        await viewModel.sendMessage()

        // Assert
        XCTAssertEqual(viewModel.messages.count, 3) // Welcome, User, Assistant (Error)
        XCTAssertEqual(viewModel.messages[2].role, "assistant")
        XCTAssertTrue(viewModel.messages[2].content.contains("ERROR TEKNIS"))
        
        XCTAssertTrue(mockGroqService.didCallSendMessage)
        XCTAssertTrue(viewModel.inputText.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
}
