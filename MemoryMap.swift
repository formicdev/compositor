

//
//  Untitled.swift
//  Compositor
//
//  Created by formic on 9/20/25.
//

//

import Foundation
import SwiftUI
import SwiftData
import Combine
import UIKit

import CoreHaptics

class HapticFadeController {
    private var engine: CHHapticEngine?
    private var timer: Timer?
    private var intensity: Float = 0.6
    private var fadeStep: Float = 0.010
    private let interval: TimeInterval = 0.01 // time between pulses
    
    init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics engine error: \(error)")
        }
    }
    
    func startFadingHaptics() {
        intensity = 1.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.intensity <= 0 {
                self.stopHaptics()
                return
            }
            
            
            self.playHaptic(intensity: self.intensity)
            self.intensity *= 0.99
            
        }
    }
    
    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        engine?.stop(completionHandler: nil)
    }
    
    private func playHaptic(intensity: Float) {
        guard let engine = engine else { return }
        
        // Create haptic event with specified intensity
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}



//fade fliter into icon
//basically take the filter icon into the filter option user selected

struct MemoryView: View {
    @Binding var tabMinimized: Bool
    @State private var viewUnloader: Bool = false
    @State private var currentView: Bool = true
    //@State private var currentView: Int = 0
    
    init(_ tabMinimized: Binding<Bool>) {
            self._tabMinimized = tabMinimized
        }
    
    var body: some View {
        ZStack(){
            FoundationBG()
            
                MemoryMap(showTab: $currentView)
                    .scaleEffect(currentView ? 0.74 : 1)
                    .opacity(currentView ? 0 : 1.0)
                    .blur(radius: currentView ? 10 : 0)
                //                .rotation3DEffect(
                //                    .degrees(currentView ? 50 : 0),
                //                    axis: (x: 1, y: 0, z: 0.0),
                //                    anchor: .bottom,
                //                    perspective: 0.5)
                    //.ignoresSafeArea(.keyboard)
                    
            
           
                ZStack(){
                    //FoundationBG()
                    if !viewUnloader { //FALSE, LOAD, CURRENT = TRUE LOAD
                        VStack(spacing: 15){
                            Spacer()
                                .frame(height: 70)
                            HStack(){
                                DefaultPillView(text: "Days", image: "", type: 0, padding: 20)
                                DefaultPillView(text: "Weeks", image: "", type: 0, padding: 20)
                                DefaultPillView(text: "Months", image: "", type: 0, padding: 20)
                                DefaultPillView(text: "Years", image: "", type: 0, padding: 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            BoundingPrimitiveView(.butter, radius: 30)
                                .frame(height: currentView ? 150 : 150)
                                .onTapGesture {
                                    currentView = false
                                }
                                .animation(.smooth, value: currentView)
                            //Text("\(currentView)")
                            ForEach(0..<3){ i in
                                BoundingPrimitiveView(.plain, radius: 30)
                                    .frame(height: 120)
                            }
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal, 18)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.keyboard)
                .opacity(currentView ? 1 : 0)
                .scaleEffect(currentView ? 1 : 1.25)
                .blur(radius: currentView ? 0 : 10)
            
            
            
        }
        .onChange(of: currentView){
            if(!currentView){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewUnloader = !currentView;
                }
            }
            else{
                viewUnloader = !currentView;
            }
        }
        .onChange(of: currentView){
            tabMinimized = !currentView
        }
        .ignoresSafeArea(.keyboard)
        .animation((currentView ? .smooth : .smooth), value: currentView)
        
    }
}


struct MemoryMap: View {
    @Binding var showTab: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var menuHeight: CGFloat = 0
    
    
    //Show sheet for adding composite
    @State private var showSheet = false //false
    //Show the expanded card view
    @State private var showExpanded: Bool = false
    @State private var expandedIndex: Int = 0
    @State private var showExpandedCards: Bool = false
    //context menu stuff
    @State private var showContext1: Bool = false
    @State private var showContext1c: Bool = false
    //more stuff
    @State private var showContext2: Bool = false
    @State private var showContext2c: Bool = false
    
    @State private var showExpandedProgress: Int = 0
    @State private var compositeCount: Int = 0
    @State private var showFilteredView: Bool = false
    @State private var showSearch: Bool = false
    @State private var showSearchbar: Bool = false
    @State private var showSearchElements: Bool = false
    @State private var showSearchProgress: Int = 0
    @State private var showSearchControl: Bool = false
    
    @State private var searchTinyBlur: Bool = false
    
    
    @FocusState private var searchFocused: Bool
    @State private var showToast: Bool = false
    @State private var hideAddition: Bool = false
    @State private var noteText: String = "My note goes here..."
    @State private var searchText: String = ""
    @State private var titletext: String = "Title Text"// Editable text storage
    
    @State private var createdNewComposite: Bool = false
    @State private var newCompositeDeveloped: Bool = false
    
    @State private var scale1: CGFloat = 1
    @State private var scale2: CGFloat = 1
    
    @State private var focusedComposite: Int = -1
    let composbrown = Color(red: 0.380, green: 0.325, blue: 0.231)
    @Query(sort: \Composite.sort, order: .forward)
    private var composites: [Composite]
    
    @State private var searchSuggestions: [String] = [
        "NYC trip",
        "George Orwell's ideas",
        "Jukebox project",
        "Shower thoughts",
        "Learning French"
    ]
    
    var systemDarkText = Color(red: 0.380, green: 0.325, blue: 0.231)
    var systemLightText = Color(red: 0.88, green: 0.82, blue: 0.72)
    
    func loadTestData(type: Int){
        let text = ["Who writes those messages you see in fortune cookies",
                    "Sleep is one of the only things that becomes easier the less you do it.",
                    "It's kind of nice going for a walk next a huge lake. Wind was terrible though.",
                    "The worst kind of AI art are food images. I want to see what the actual food looks like when I order it.",
                    "Humans when the Earth makes 1 rotation around the sun:",
                    "Studying for a test is strange. You're going to forget everything after it's over and it dilutes the purpose of it as a benchmark.",
                    "What happened to transparent phones? There was a huge craze about it last decade and now you hear nothing about it."]

        text.forEach{ index in
            modelContext.insert(Composite(textContent: index, classification: "neutral", latitude: 0, longitude: 0, sort: 1))
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new note: \(error)")
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background color for the top bar
            FoundationBG()
                .opacity(0)
                //.animation(.smooth, value: showTab)
            
            VStack(spacing: 0){
                Spacer()
                    .frame(height: 7)
                //buttons
                ZStack() {
                    HStack(){
                        ZStack() {
                            if(showExpanded){
                                Button(action: {
                                    showExpanded = false
                                    showExpandedCards = false
                                    hideAddition = false
                                    showExpandedProgress = 0
                                }) {
                                    DefaultPillView(text: " ", image: "checkmark", type: 1, padding: 20)
                                }
                                
                                .buttonStyle(.automatic)
                            }
                            else{
                                Button(action: {
                                    showTab = true
                                    showContext1 = false
                                    dismiss()
                                }) {
                                    DefaultPillView(text: " ", image: "arrow.left", type: 1, padding: 20)
                                }
                                
                                .buttonStyle(.automatic)
                                
                            }
                        }
                        .animation(.snappy, value: showExpanded)
                        .blur(radius: scale1 > 1 ? 2.2 : 0)
                        .scaleEffect(scale1, anchor: .center)
                        .onChange(of: showExpanded) {
                            withAnimation(.spring(bounce: 0.5)) { scale1 = 1.2 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(bounce: 0.5)) { scale1 = 1.0 }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showExpanded = false
                            dismiss()
                        }) {
                            ZStack() {
                                if(showContext1){
                                    Button(action: {
                                        showContext1 = false
                                    }) {
                                        DefaultPillView(text: " ", image: "xmark", type: 1, padding: 20)
                                    }
                                    
                                    .buttonStyle(.plain)
                                    .transition(.opacity)
                                }
                                else{
                                    Button(action: {
                                        
                                        showContext1 = true
                                    }) {
                                        DefaultPillView(text: "Days", image: "filter.lines", type: 1, padding: 20)
                                    }
                                    
                                    .buttonStyle(.plain)
                                    .transition(.opacity)
                                    
                                }
                            }
                            //.offset(x: scale2 > 1.14 ? -4.2 : 0, y: 0)
                            //.brightness(scale2 > 1 ? 0.25 : 0)
                            .animation(.snappy, value: showContext1)
                            .opacity(scale2 > 1.1 ? 0.8 : 1)
                            .blur(radius: scale2 > 1 ? 3 : 0)
                            .scaleEffect(scale2, anchor: .center)
                            .onChange(of: showContext1) {
                                
                                withAnimation(.spring(bounce: 0.5)) { scale2 = 1.2 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(bounce: 0.5)) { scale2 = 1.0 }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    VStack() {
                        Text("Memory Map")
                            .foundationText(.title)
                        
                        ZStack() {
                            if(showExpanded){
                                Text("This Week")
                                    .fontWeight(.semibold)
                                    .font(.callout)
                                    .opacity(0.8)
                                    .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .blendMode(.luminosity)
                                    .scaleEffect(showExpanded ? 1 : 0.9, anchor: .center)
                                
                            }
                        }
                        .blur(radius: showExpanded ? 0 : 3)
                        .animation(.bouncy(duration: 1), value: showExpanded)
                    }
                    .frame(height: 30)
                    .scaleEffect(scale1 > 1 && !showExpanded ? 1.02 : 1)
                    .padding(.top, showExpanded ? 10 : 0)
                    .animation(.bouncy(duration: 0.4, extraBounce: 0.1), value: showExpanded)
                }
                
                
                
                ZStack() {
                    // MARK: Normal Content
                    ZStack() {
                        ZStack(){
                            Rectangle()
                                .fill(.black)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .blur(radius: 42)
                        .opacity(focusedComposite != -1 ? 0.1 : 0)
                        .animation(.bouncy(duration: 0.4), value: focusedComposite)
                        .onTapGesture {
                            focusedComposite = -1
                        }
                        
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                
                                HStack(spacing: 0){
                                    VStack(alignment: .trailing){
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(colorScheme == .light ? composbrown : systemLightText)
                                            .frame(width: 8)
                                        
                                            .padding(.top, -180)
                                        
                                    }
                                    .frame(width: 40, alignment: .trailing)
                                    .padding(.bottom, 90)
                                    .frame(maxHeight: .infinity)
                                    .blendMode(.luminosity)
                                    .blur(radius: focusedComposite != -1 ? 20 : 0)
                                    .animation(.smooth, value: focusedComposite)
                                    .animation(.bouncy(duration: 0.5), value: composites.count)
                                    .onChange(of: createdNewComposite){
                                        if(!createdNewComposite){
                                            newCompositeDeveloped = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                newCompositeDeveloped = false
                                            }
                                        }
                                    }
                                    
                                    //.background(Color.green) //
                                    
                                    LazyVStack() {
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(height: 30)
                                        //ForEach(composites.indices, id: \.self) { i in
                                        ForEach(composites.indices, id: \.self) { i in
                                            let composite = composites[i]
                                            //let composite = composites[i]
                                            HStack(){
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .foregroundStyle(Color(colorScheme == .light ? composbrown : systemLightText))
                                                        .frame(width: 45)
                                                        .padding(.trailing, 12)
                                                        .frame(maxHeight: 8, alignment: .center)
                                                        .padding(.bottom, 10)
                                                    
                                                    Rectangle()
                                                        .foregroundStyle(Color(colorScheme == .light ? composbrown : systemLightText))
                                                        .frame(width: 30)
                                                        .padding(.trailing, 20)
                                                        .frame(maxHeight: 8, alignment: .center)
                                                        .padding(.bottom, 10)
                                                }
                                                .blur(radius: focusedComposite != -1 ? 20 : 0)
                                                .animation(.smooth, value: focusedComposite)
                                                //.rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                                                Spacer()
                                                VStack(spacing: 2) {
                                                        // MARK: hi
                                                        ZStack {
                                                            TextContainerView(text:"", height: 160)
                                                                .padding(.bottom, 38)
                                                                .scaleEffect(0.88)
                                                                .opacity(expandedIndex == i && showExpanded == true ? 0 : 1)
                                                            TextContainerView(text:"\(composite.textContent)", height: 160)
                                                                .rotation3DEffect(
                                                                    .degrees(expandedIndex == i && showExpanded && showExpandedCards ? 50 : 0),
                                                                    axis: (x: 1, y: 0, z: 0.0),
                                                                    perspective: 0.5)
                                                                .animation(.bouncy(duration: 0.7), value: expandedIndex == i && showExpanded == true)
                                                        }
                                                        //.rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                                                        .scaleEffect(i == composites.count - 1 && createdNewComposite ? 1.7 : expandedIndex == i && showExpanded == true ? 1.6 : 1)
                                                        .zIndex(focusedComposite == i ? 100 : 0)
                                                        .blur(radius: expandedIndex == i && showExpanded == true ? 10 : 0)
                                                        .opacity(i == composites.count - 1 && createdNewComposite ? 0 : expandedIndex == i && showExpanded == true ? 0 : 1)
                                                        .brightness(i == composites.count - 1 && createdNewComposite ? 0.2 : 0)
                                                        .rotation3DEffect(
                                                            .degrees(i == composites.count - 1 && createdNewComposite ? 45 : 0),
                                                            axis: (x: 1, y: 0.1, z: 0),
                                                            perspective: 0.5)
                                                        .animation(.smooth(duration: 0.54, extraBounce: 0.1), value: expandedIndex == i && showExpanded == true)
                                                        .animation(.bouncy, value: focusedComposite)
                                                        .onLongPressGesture(minimumDuration: 0.24) {
                                                            
                                                            focusedComposite = (focusedComposite != -1 ? -1 : i)
                                                            let generator = UIImpactFeedbackGenerator(style: .rigid)
                                                                generator.prepare()
                                                            generator.impactOccurred(intensity: 0.7)
                                                    }
                                                        .onTapGesture(){
                                                            // Your action here
                                                            if(focusedComposite == i){
                                                                focusedComposite = -1
                                                            }
                                                            else{
                                                                showExpanded = true
                                                                hideAddition = true
                                                                expandedIndex = i
                                                            }
                                                        }
                                                        
                                                        
                                                    
                                                    
                                                    
                                                    Text("Today, 6:07 AM")
                                                        .foundationText(.bodySecondary)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        //.offset(x: 0, y: i == composites.count - 1 && createdNewComposite ? -8 : 0)
                                                        .blur(radius: i == composites.count - 1 && createdNewComposite ? 12 : 0)
                                                        .brightness(i == composites.count - 1 && createdNewComposite ? 0.4 : 0)
                                                        .opacity(i == composites.count - 1 && createdNewComposite ? 0 : 1)
                                                }
                                                .scaleEffect(focusedComposite == i ? 1.2 : 1)
                                                .blur(radius: focusedComposite != i && focusedComposite != -1 ? 20 : 0)
                                                .animation(.bouncy, value: focusedComposite)
                                                
                                                //.background(.red)
                                                
                                            }
                                            //.frame(maxHeight: .infinity)
                                            
                                            //.background(Color.orange) ///
                                            Spacer()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 20)
                                                .padding()
                                            //.background(Color.orange.opacity(0.5))
                                            
                                        }
                                        Color.clear.frame(height: 1).id("bottom")
                                    }
                                    .frame(width: 290)
                                    //.background(Color.blue) ///
                                    .padding(.trailing, 20)
                                }
                                //.background(Color.red) ///
                                .padding(.horizontal, 20)
                            }
                            .defaultScrollAnchor(.bottom)
                            .ignoresSafeArea(edges: .bottom)
                            .padding(.bottom, 10)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black.opacity(showTab ? 0 : 0.8), location: showTab ? 0 : 0.14),
                                        .init(color: .black.opacity(showTab ? 0.02 : 1), location: showTab ? 0.08 : 0.2),
                                        .init(color: .black.opacity(showTab ? 0.0 : 1), location: showTab ? 0.1: createdNewComposite ? 0.8 : 0.89),
                                        .init(color: .black.opacity(showTab ? 0 : 0.1), location: showTab ? 0.2 : createdNewComposite ? 0.86 : 0.965),
                                        .init(color: .clear, location: showTab ? 0.3 : createdNewComposite ? 0.87 : 0.98)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .offset(x: 0, y: showTab ? 10 : 0)
                                .animation(.snappy(duration: 1.2), value: showTab)
                                .animation(.snappy(duration: createdNewComposite ? 0.1 : 1.4), value: createdNewComposite)
                            )
                            .onChange(of: composites.count) {
                                createdNewComposite = false
                                print("start")
                                DispatchQueue.main.async {
                                    createdNewComposite = true
                                }
                                    withAnimation(.smooth){
                                        proxy.scrollTo("bottom", anchor: .bottom)
                                    }
                                
                            }
                            .onChange(of: createdNewComposite) {
                                if(createdNewComposite){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.76) {
                                        print("timer")
                                        withAnimation(.smooth(duration: 0.6))  {
                                            createdNewComposite = false
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                            
                            .offset(x: 0, y: composites.count == 0 ? 380 : 0)
                            .opacity(composites.count == 0 ? 0 : 1)
                            .blur(radius: composites.count == 0 ? 10 : 0)
                            //.animation(.smooth(duration: 0.8), value: composites.isEmpty)
                        //do a bit more than tradition
                        Text("It's empty in here. \nLet's change that.")
                            .multilineTextAlignment(.center)
                            .foundationText(.title)
                            .opacity(composites.count == 0 ? 1 : 0)
                            .animation(.smooth(duration: 0.8), value: composites.isEmpty)
                        
                        
                        
                    }
                    .blur(radius: showExpanded || showSearch ? 9 : showContext1 ? 1 : 0)
                    .scaleEffect(showExpanded ? 0.97 : 1)
                    .animation(.smooth(duration: 0.6), value: showExpanded)
                    .animation(.smooth(duration: 0.6), value: showContext1)
                    //.animation(.smooth(duration: 0.1), value: composites.count)
                
                    
                    // MARK: Focused
                    //focus
                    if(true) {
                        ZStack() {
                            Rectangle()
                                .fill(Color(red: 1.0, green: 0.9608, blue: 0.8745).opacity(0.8))
                                //.blur(radius: showExpanded ? 0 : 20)
                                //.scaleEffect(showExpanded ? 1 : 0)
                                .animation(.snappy(duration: 1), value: showExpanded)
                                  .mask(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: !showExpanded ? 0.8 : 0),
                                            .init(color: .black.opacity(!showExpanded ? 0.1 : 1), location: !showExpanded ? 1 : 0.1),
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .animation(.snappy(duration: 2), value: showExpanded)
                                )
                                  
                        }
                        .opacity(showExpanded ? 1 : 0)
                        .animation(.smooth(duration: 0.6), value: showExpanded)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .onChange(of: showExpanded) {
                            if(showExpanded){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                                    showExpandedCards = true;
                                }
                            }
                        }
                        
                        ZStack() {
                            ScrollView {
                                LazyVStack(alignment:. center) {
                                        ForEach(0..<8) { i in
                                            
                                                //.rotationEffect(.degrees(CGFloat.random(in: -2...2)))
                                                
                                                VStack(spacing: 2) {
                                                    
                                                    TextContainerView(text:"Composite but in focused view so its better \(i)", height: 160)
                                                        .frame(width: 230)
                                                        
                                                        
                                                    


                                                    .buttonStyle(.plain)
                                                    
                                                    Spacer()
                                                        .frame(height: 12)
                                        
                                                    
                                                    Text("Today, 6:07 AM")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(.black))
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                }
                                                .rotation3DEffect(
                                                    .degrees(i <= 3 && showExpandedProgress > i ? 0 : i > 3 && showExpandedProgress > 3 ? 0 : showExpanded ? 30 : 0),
                                                    axis: (x: 1, y: 0, z: 0.0),
                                                    perspective: 0.5)
                                                .opacity(i <= 3 && showExpandedProgress > i ? 1 : i > 3 && showExpandedProgress > 3 ? 1 : 0)
                                                .blur(radius: i <= 3 && showExpandedProgress > i ? 0 : i > 3 && showExpandedProgress > 0 ? 0 : 5)
                                                .scaleEffect(i <= 3 && showExpandedProgress > i ? 1 : i > 3 && showExpandedProgress > 3 ? 1 : showExpanded ? 1.14 : 1)
                                                .onChange(of: showExpandedCards) {
                                                    if(showExpanded){
                                                        for i in 1...4 {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.08) {
                                                                showExpandedProgress = i;
                                                            }
                                                        }
                                                    }
                                                }
                                                .animation(.bouncy(extraBounce: 0.1), value: showExpandedProgress)
                                                
                                            
                                            //.frame(maxHeight: .infinity)
                                            
                                            //.background(Color.orange) ///
                                            Spacer()
                                                .frame(height: 35)

                                            //.background(Color.orange.opacity(0.5))
                                            
                                        }
                                    }
                                    .frame(width: 290)
                                    .padding(.top, 65)
                                    .padding(.bottom, 35)
                                    //.background(Color.blue) ///
                            }
                            .scrollIndicators(.never)
                            //.defaultScrollAnchor(.bottom)
                            .ignoresSafeArea(edges: .bottom)
                            .padding(.bottom, 0)
                            .scaleEffect(showExpandedCards ? 1 : 1.12)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0.01),
                                        .init(color: .black.opacity(showTab ? 0.3 : 1), location: showTab ? 0.05 : 0.12),
                                        .init(color: .black.opacity(showTab ? 0.3 : 1), location: showTab ? 0.1 : 0.88),
                                        .init(color: .clear, location: showTab ? 0.3 : 0.96)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .animation(.snappy(duration: 1.2), value: showTab)
                            )
                            
                            
                            
                        }
                        .blur(radius: showExpandedCards ? 0 : 8)
                        .opacity(showExpandedCards ? 1 : 0)
                        .animation(.snappy(duration: 0.5), value: showExpandedCards)
                    }
                    

                    // MARK: Toolbar
                    ZStack(){
                        HStack() {
                            
                            if(showTab){
                                Spacer()
                                    .frame(width: 50)
                            }
                            
                            
                            Button() {
                                showSheet = true
                            } label: {
                                ZStack(){
                                    BoundingPrimitiveView(height: 0, radius: 50)
                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(colorScheme == .light ? systemDarkText: systemLightText)
                                        .padding(.horizontal, showTab ? 40 : 0)
                                }
                                .frame(width: 56)
                                .frame(height: 56)
                                
                            }
                            .shadow(color: colorScheme == .light ? .white : .black, radius: 15, x: 0, y: -15)
                            .blur(radius: showTab ? 5 : hideAddition ? 6 : 0)
                            .scaleEffect(showTab ? 1.4 : hideAddition ? 1.3 : 1)
                            .opacity(showTab ? 0.2 : hideAddition ? 0 : 1)
                            .padding(.leading, 30)
                            .animation(.bouncy(duration: 0.5, extraBounce: 0.1), value: hideAddition)
                            
                            if(showTab){
                                Spacer()
                            }
                            
                        }
                        .animation(.bouncy(duration: 0.5, extraBounce: 0.1), value: showTab)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        //.background(.red)
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 0)
                    
                    
                    // MARK: Context
                    ZStack(alignment: .top){
                        Button() {
                            showContext1 = false
                        } label: {
                            Rectangle()
                                .fill(Color.black.opacity(colorScheme == .light ? 0.1 : 0.5))
                                .blur(radius: 42)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                
                        }
                        .opacity(showContext1 ? 1 : 0)
                        .animation(.snappy, value: showContext1)
                        .ignoresSafeArea()
                        .buttonStyle(.plain)
                                                    
                        
                        ZStack(){
                            ZStack(){
                                BoundingPrimitiveView(height: 0, radius: 28)
                                    .frame(height: showContext1 ? nil : 40)
                                    .frame(width: showContext1 ? nil : 50)
                                    .animation(.snappy(duration: 0.43, extraBounce: 0.08), value: showContext1)
                                VStack(){
                                    VStack(alignment: .leading){
                                        Spacer()
                                            .frame(height: 20)
                                        HStack(){
                                            Button(){
                                                modelContext.insert(Composite(textContent: "This is a test", classification: "neutral", latitude: 0, longitude: 0, sort: 1))
                                                print("Number of composites: \(composites.count)")
                                                
                                                do {
                                                    try modelContext.save()
                                                } catch {
                                                    print("Failed to save new note: \(error)")
                                                }
                                            } label: {
                                                Text("Sort & Filter")
                                                    .foundationText(.labelBold)
                                                    .drawingGroup()
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        
                                        HStack(){
                                            Button(){
                                                showContext2 = true
                                            } label: {
                                                Text("Weeks")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                                
                                        }
                                        .padding(.bottom, 10)
                                        Button() {
                                            showToast = true
                                            showContext1 = false
                                        } label: {
                                            HStack(){
                                                Text("All")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        
                                        HStack(){
                                            Capsule()
                                                .frame(height: 2)
                                                .opacity(0.08)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.bottom, 10)
                                        
                                        Button() {
                                            showContext1 = false
                                            showSearch.toggle()
                                            searchFocused.toggle()
                                            hideAddition.toggle()
                                        } label: {
                                            HStack(){
                                                Text("Search")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                        }
                                        
                                        
                                        Spacer()
                                            .frame(height: 20)
                                        
                                    }
                                    
                                    .padding(.horizontal, 20)
                                    .opacity(showContext1c ? 1 : 0)
                                    //.brightness(showContext1c ? 0 : 0.7)
                                    .scaleEffect(showContext1c ? 1 : 1.26)
                                    .blur(radius: showContext1c ? 0 : 22)
                                    .animation(.snappy(duration: showContext1c ? 0.46 : 0.1), value: showContext1c)
                                    //.transition(.blurReplace)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear { menuHeight = geo.size.height }
                                        }
                                    )
                                    .clipped()
                                    .animation(.snappy, value: showContext1)
                                    .onChange(of: showContext1) {
                                        if(showContext1){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                                                showContext1c = true
                                            }
                                        }
                                        else{
                                            showContext1c = false
                                            showContext2 = false
                                        }
                                    }
                                    
                                    
                                }
                                //.background(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity, alignment: .top)
                                
                                Rectangle()
                                    .fill(.black)
                                    .opacity(showContext2 ? 0.01 : 0)
                                
                                    .onTapGesture(count: 1){
                                        showContext2 = false
                                    }
                                
                            }
                            //.fixedSize(horizontal: false, vertical: true)
                            .frame(width: showContext1 ? 160 : 30)
                            .frame(height: showContext1 ? menuHeight : 0)
                            .scaleEffect(showContext2 ? 0.9 : showContext1 ? 1 : 0.75, anchor: showContext2 ? .trailing : .center)
                            .rotationEffect(Angle(degrees: showContext1 ? 0 : 5))
                            .opacity(showContext1 ? 1 : 0)
                            .brightness(showContext2 ? -0.05 : showContext1 ? 0 : 0.03)
                            .compositingGroup()
                            .blur(radius: showContext2 ? 1 : showContext1 ? 0 : 5)
                            .animation(.snappy(duration: showContext1 ? 0.5 : 0.44, extraBounce: 0.12), value: showContext1)
                            .animation(.snappy(duration: 0.5, extraBounce: 0.12), value: showContext2)
                            .offset(x: showContext1 ? 0 : 0, y: showContext1 ? 0 : -85)
                            
                            ZStack(){
                                BoundingPrimitiveView(height: 0, radius: 28)
                                    .frame(height: showContext2 ? nil : 80)
                                    .frame(width: showContext2 ? nil : 20)
                                    .animation(.snappy(duration: 0.43, extraBounce: 0.08), value: showContext1)
                                VStack(){
                                    VStack(alignment: .leading){
                                        Spacer()
                                            .frame(height: 20)
                                        HStack(){
                                            Button(){
                                                loadTestData(type: 1)
                                            } label: {
                                                Text("Sort & Filter")
                                                    .foundationText(.labelBold)
                                                    .drawingGroup()
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        
                                        HStack(){
                                            Button(){
                                                showContext2 = true
                                            } label: {
                                                Text("Weeks")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                                
                                        }
                                        .padding(.bottom, 10)
                                        Button() {
                                            showToast = true
                                            showContext1 = false
                                        } label: {
                                            HStack(){
                                                Text("All")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        
                                        HStack(){
                                            Capsule()
                                                .fill(getSystemColor(colorScheme))
                                                .frame(height: 2)
                                                .opacity(0.08)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.bottom, 10)
                                        
                                        Button() {
                                            showContext1 = false
                                            showSearch.toggle()
                                            searchFocused.toggle()
                                            hideAddition.toggle()
                                        } label: {
                                            HStack(){
                                                Text("Search")
                                                    .foundationText(.label)
                                                    .drawingGroup()
                                            }
                                        }
                                        
                                        
                                        Spacer()
                                            .frame(height: 20)
                                        
                                    }
                                    
                                    .padding(.horizontal, 20)
                                    .opacity(showContext2c ? 1 : 0)
                                    //.brightness(showContext1c ? 0 : 0.7)
                                    .scaleEffect(showContext2c ? 1 : 1.26)
                                    .blur(radius: showContext2c ? 0 : 22)
                                    .animation(.snappy(duration: showContext2c ? 0.46 : 0.1), value: showContext2c)
                                    //.transition(.blurReplace)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onAppear { menuHeight = geo.size.height }
                                        }
                                    )
                                    .clipped()
                                    .animation(.snappy, value: showContext2)
                                    .onChange(of: showContext2) {
                                        if(showContext2){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                                                showContext2c = true
                                            }
                                        }
                                        else{
                                            showContext2c = false
                                        }
                                    }
                                    
                                    
                                }
                                //.background(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity, alignment: .top)
                                
                                
                                
                            }
                           
                            .frame(width: !showContext1 ? 10 : 160)
                            .frame(height: !showContext1 ? 0 : menuHeight)
                            .offset(x: showContext2 ? -100 : 0, y: showContext2 ? 0 : 0)
                            .opacity(showContext2 ? 1 : 0)
                            .blur(radius: showContext2 ? 0 : 15)
                            .scaleEffect(showContext2 ? 1 : 0.8, anchor: .leading)
                            .animation(.snappy(duration: !showContext1 ? 0.01 : showContext2 ? 0.5 : 0.44, extraBounce: 0.12), value: showContext2)
                            
                            /*
                            .frame(width: showContext1 ? 160 : 80)
                            .frame(height: showContext1 ? 180: 50)
                            .scaleEffect(showContext1 ? 1 : 0.85, anchor: .center)
                            .rotationEffect(Angle(degrees: showContext1 ? 0 : 4.4))
                            .opacity(showContext1 ? 1 : 0)
                            .blur(radius: showContext1 ? 0 : 1)
                            .animation(.snappy(duration: 0.4, extraBounce: 0.1), value: showContext1)
                            .padding(.top, -60)
                             */
                            //.offset(x: 0, y: showContext1 ? 0 : -60)
                           
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 13)
                        .padding(.horizontal, 20)
                        
                        
                    }
                    .background(.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    
                    // MARK: Search
                    ZStack(alignment: .top){
                        Button() {
                            showSearch = false
                            hideAddition = false
                            searchFocused = false
                        } label: {
                            Rectangle()
                                .fill(colorScheme == .light ? Color(red: 1.0, green: 0.9608, blue: 0.8745).opacity(0.8) : Color(.black).opacity(0.8))
                                .blur(radius: 42)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                              
                        }
                        .opacity(showSearch ? 1 : 0)
                        .animation(.snappy, value: showSearch)
                        .ignoresSafeArea()
                        .buttonStyle(.plain)
                        
                        VStack(){
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(){
                                    ForEach(searchSuggestions.indices, id: \.self) { i in

                                        ZStack(){
                                            BoundingPrimitiveView(radius: 26)
                                                .frame(height: 40)
                                                
                                            Text("\(searchSuggestions[i])")
                                                .foundationText(.label)
                                                .padding(.horizontal, 18)
                                        }
                                        .fixedSize()
                                        .opacity(showSearchElements && showSearchProgress >= i ? 1 : 0)
                                        .offset(x: 0, y: showSearchElements && showSearchProgress >= i ? 0 : 50)
                                    }
                                    .opacity(showSearchElements ? 1 : 0)
                                    
                                    
                                }
                            }
                            .scrollClipDisabled()
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .id(showSearch ? "reset" : "normal")

                            
                            .onChange(of: showSearchElements) {
                                searchTinyBlur = true

                                if(showSearchElements){
                                    showSearchProgress = 0
                                    for i in 1...9 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)*0.1) {
                                            withAnimation(.bouncy(duration: 0.5)){
                                                showSearchProgress = i
                                            }
                                        }
                                    }
                                }
                                else{
                                    showSearchProgress = 0
                                }
                            }
                            .onChange(of: showSearch) {
                                if(showSearch){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                        withAnimation(.bouncy(duration: 0.5)){
                                            showSearchElements = true
                                        }
                                    }
                                }
                                else{
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                        withAnimation(.linear(duration: 0.1)){
                                            showSearchElements = false
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                                .frame(height: 15)
                            
                            ZStack() {
                                ZStack(){
                                    
                                    BoundingPrimitiveView(height: 0, radius: 44)
                                    
                                    Image("checkmark")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .foregroundStyle(getSystemColor(colorScheme))
                                        .frame(height: 30)
                                        .brightness(showSearchControl ? 0 : 0.95)
                                    
                                }
                                .frame(width: showSearchControl ? 53 : 155, height: 50)
                                .opacity(showSearchControl ? 1 : 0)
                                .scaleEffect(showSearchControl ? 1 : 0.0)
                                .offset(x: showSearchControl ? 0 : -50, y: 0)
                                .blur(radius: showSearchControl ? 0 : 26)
                                .animation(.bouncy(duration: showSearchControl ? 0.55 : showSearch ? 0.91 : 0.3, extraBounce: 0.0), value: showSearchControl)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                HStack(spacing: 12){
                                    ZStack(alignment: .leading){
                                        BoundingPrimitiveView(radius: 44)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .padding(0)
                                        
                                        ZStack(){
                                            BoundingPrimitiveView(radius: 48)
                                                .frame(width: 90)
                                                .mask(
                                                    Capsule()
                                                        .frame(width: 60)
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                    .contentMargins(8)
                                                )
                                        }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                            .blur(radius: searchTinyBlur ? 0.4 : 0)
                                            .scaleEffect(searchTinyBlur ? 1.08 : 1)
                                            .opacity(searchTinyBlur ? 0 : 0)
                                        
                                        if(searchText.isEmpty) {
                                            Text("What are you looking for?")
                                                .foundationText(.body)
                                                .opacity(0.6)
                                                .padding(.leading, 20)
                                            
                                        }
                                        
                                        TextField("", text: $searchText)
                                            .focused($searchFocused)
                                            .submitLabel(.search)
                                            .foundationText(.body)
                                            .padding(.vertical, 10)
                                        //.background(Color.blue)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .padding(.horizontal, 20)
                                        
                                        
                                    }
                                    .onChange(of: showSearchControl){
                                        searchTinyBlur = true
                                        
                                    }
                                    .onChange(of: searchTinyBlur){
                                        if(searchTinyBlur){
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                                                searchTinyBlur = false
                                            }
                                        }
                                    }
                                    .blur(radius: searchTinyBlur ? 0.7 : 0)
                                    .scaleEffect(searchTinyBlur ? 1.045 : 1)
                                    .animation(.bouncy(duration: 0.37), value: searchTinyBlur)
                                    .animation(.bouncy(duration: showSearchControl ? 0.4 : 0.35, extraBounce: 0.1), value: showSearchControl)
                                    
                                    
                                    if(showSearchControl){
                                        BoundingPrimitiveView(height: 0, radius: 44)
                                            .opacity(0)
                                            .frame(width: 50, height: 50)
                                    }
                                    
                                    
                                    
                                }

                                
                                
                            }
                            .frame(height: 50)
                            //.safeAreaPadding(.keyboard)
                            
                            .opacity(showSearchbar ? 1 : 0)
                            .offset(x: 0, y: showSearchbar ? 0 : 70)
                            .blur(radius: showSearchbar ? 0 : 10)
                            .scaleEffect(showSearchbar ? 1 : 0.85, anchor: .center)
                            .animation(.snappy(duration: 0.45), value: showSearchbar)
                            .onChange(of: showSearch) {
                                if(showSearch){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                        showSearchbar = true
                                    }
                                }
                                else{
                                    showSearchbar = false
                                    searchText = ""
                                }
                            }
                            .onChange(of: searchText.isEmpty) {
                                if(!searchText.isEmpty){
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        showSearchControl = true
                                    }
                                }
                                else{
                                    showSearchControl = false
                                }
                            }
                            
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 18 + 300)
                        //.background(.red)
                        .padding(.horizontal, 15)
                        
                    }
                    .background(.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // MARK: Toast
                    //responsiveToast($showToast, "Unavailable item", "Try again later.", duration: 2.0)
                    responsiveToast($showToast, "Composite Logged", "", duration: 2.0)
                    
                    
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
                
                .sheet(isPresented: $showSheet) {
                    NewCompositeView()
                        .presentationDetents([.large])
                        .presentationCornerRadius(34)
                        .interactiveDismissDisabled(true)
                        .presentationBackgroundInteraction(.enabled)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}



struct responsiveToast: View {
    @Binding var show: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showToast: Bool = false
    @State private var progress: Double = 0.99
    @State private var timer: Timer? = nil
    
    let primaryText: String
    let secondaryText: String
    let duration: Double
    
    init(_ show: Binding<Bool>, _ primaryText: String, _ secondaryText: String, duration: Double = 2.0){
        self._show = show
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.duration = duration
    }
    
    var body: some View {
        ZStack(alignment: .top){

                Rectangle()
                    .fill(.red.opacity(0.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onChange(of: show) {
                        if(show){
                            DispatchQueue.main.asyncAfter(deadline: .now() + (duration)) {
                                show = false
                            }
                        }
                    }
                    
            
            Rectangle()
                .fill(colorScheme == .light ? .white : .black)
                .frame(maxWidth: .infinity, maxHeight: 140)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .blur(radius: 50)
                .ignoresSafeArea()
            ZStack(){
                BoundingPrimitiveView(height: 60, radius: 55)
               
                
                ZStack(){
                   
                    Image("toastasset.question")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .scaleEffect(0.71)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: showToast ? .leading : .center)
                .padding(.leading, showToast ? -0.8 : 0)
                
                ZStack(){
                    if(showToast){
                        VStack(spacing: 1){
                            Text(primaryText)
                                .foundationText(.labelSecondaryBold)
                            
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            if(secondaryText != ""){
                                Text(secondaryText)
                                    .font(.footnote)
                                    .opacity(0.6)
                                    .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.black))
                                    .blendMode(.luminosity)
                                    .fontWeight(.bold)
                                
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                        }
                        .padding(.leading, 60)
                    }
                }
                .opacity(showToast ? 1 : 0.0)
                .blur(radius: showToast ? 0 : 8)
                .animation(.linear(duration: show ? 0.4 : 0.2), value: showToast)
                
            }
                .frame(height: showToast ? 60 : show ? 60 : 10)
                .scaleEffect(showToast ? 1 : show ? 1 : 0.3)
                .frame(width: showToast ? 220 : show ? 60 : 10)
                .blur(radius: show ? 0 : 14)
                .animation(.bouncy(duration: 0.56, extraBounce: 0.05), value: show)
                .offset(x: 0, y: show ? -30 : 10)
                //.animation(.easeIn(duration: 0.73), value: stage1 == true)
                //.animation(.bouncy(duration: 0.53, extraBounce: 0.08), value: showToast)
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
                //.padding(.bottom, stage1 || showToast ? 0 : show ? 5 : 0)
            
        }
        .ignoresSafeArea()
        .opacity(show ? 1 : 0)
        .animation(.bouncy(duration: 0.4, extraBounce: 0.1), value: show)
        .background(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: show) {
            if(show){
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.snappy(duration: 0.54, extraBounce: 0.08)) {
                        showToast = true
                        }
                    
                }
            }
            else{
                withAnimation(.bouncy(duration: 0.6)) {
                    showToast = false
                    }
            }
        }
    }
}

struct responsiveToast2: View {
    let show: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var stage1: Bool = false
    @State private var showToast: Bool = false
    @State private var progress: Double = 0.99
    @State private var timer: Timer? = nil
    var body: some View {
        ZStack(alignment: .top){

                Rectangle()
                    .fill(.red.opacity(0.0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    
            
            Rectangle()
                .fill(.white.opacity(1))
                .frame(maxWidth: .infinity, maxHeight: 140)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .blur(radius: 50)
                .ignoresSafeArea()
            ZStack(){
                BoundingPrimitiveView(height: 60, radius: 55)
               
                
                
                Gauge(value: showToast ? progress : 0.97) {
                     // optional label
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .scaleEffect(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: showToast ? .leading : .center)
                .tint(.brown)
                .blur(radius: 0)
                .opacity(showToast ? 1 : 0)
                .animation(.linear(duration: 0.2), value: showToast)
                .onChange(of: showToast) {
                    if(showToast){
                        progress = 1
                        //print(progress)
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
                            if progress > 0 {
                                withAnimation(.linear(duration: 0.1)) {
                                    progress = max(0, progress - 0.052)
                                    
                                }
                            } else {
                                t.invalidate()
                                withAnimation(.linear(duration: 0.1)) {
                                    progress = 0
                                }
                            }
                        }
                    }
                }
                
                ZStack(){
                    Circle()
                        .stroke(.brown, lineWidth: 3)
                        .scaleEffect(0.7)
                        .opacity(showToast ? 0 : stage1 ? 1 : show ? 0.6 : 0.0)
                        .animation(.linear(duration: 0.2), value: stage1)
                    Image("toastasset.question")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .scaleEffect(0.68)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: showToast ? .leading : .center)
                .padding(.leading, showToast ? -0.8 : 0)
                
                ZStack(){
                    if(showToast){
                        VStack(spacing: 1){
                            Text("Unavailable item")
                                .font(.subheadline)
                                .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.black))
                                .blendMode(.luminosity)
                                .fontWeight(.bold)
                            
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 64)
                            
                            Text("Try again later.")
                                .font(.footnote)
                                .opacity(0.6)
                                .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.black))
                                .blendMode(.luminosity)
                                .fontWeight(.bold)
                            
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 64)
                        }
                    }
                }
                .opacity(showToast ? 1 : 0.0)
                .blur(radius: showToast ? 0 : 3)
                .animation(.linear(duration: show ? 0.5 : 0.2), value: showToast)
                
            }
                .frame(height: showToast ? 60 : show ? 60 : 20)
                .scaleEffect(stage1 || showToast ? 1 : show ? 1.45 : 0.5)
                .frame(width: showToast ? 220 : show ? 60 : 20)
                .blur(radius: show ? 0 : 10)
                .animation(.timingCurve(0.1, 0.3, 0.15, 1.0, duration: 0.6), value: show)
                .offset(x: 0, y: -30)
                //.animation(.easeIn(duration: 0.73), value: stage1 == true)
                //.animation(.bouncy(duration: 0.53, extraBounce: 0.08), value: showToast)
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
                //.padding(.bottom, stage1 || showToast ? 0 : show ? 5 : 0)
            
        }
        .ignoresSafeArea()
        .opacity(show ? 1 : 0)
        .animation(.bouncy(extraBounce: 0.1), value: show)
        .background(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: show) {
            if(show){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.timingCurve(0.5, 0.0, 0.8, 1.0, duration: 0.35)) {
                        stage1 = true
                        }
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                    withAnimation(.snappy(duration: 0.54, extraBounce: 0.1)) {
                        showToast = true
                        }
                    
                    stage1 = false
                }
            }
            else{
                withAnimation(.bouncy(duration: 0.6)) {
                    showToast = false
                    }
            }
        }
    }
}

// MARK: - List

enum WithAccessory{
    case none
    case withToggle
}

struct Row: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    let accessory: WithAccessory
    
    init(
            title: String,
            subtitle: String = "",
            icon: String = "",
            accessory: WithAccessory = .none,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.accessory = accessory
            self.action = action
        }
    
}

struct Primativelist: View {
    var color: Color? = nil       // optional color parameter
    @Environment(\.colorScheme) var colorScheme
    private var rows: [Row] = []
    let composbrown = Color(red: 0.380, green: 0.325, blue: 0.231)
    var coloredIcons = ["burst", "circle.rounded", "pentagon", "square.rounded", "star.4", "triangle.rounded"]
    
    init(color: Color? = nil){
        self.color = color
    }
    
    func item(
        title: String,
        subtitle: String = "",
        icon: String = "",
        accessory: WithAccessory = .none,
        action: @escaping () -> Void
    ) -> Self {
        var newSelf = self
        let newRow = Row(title: title, subtitle: subtitle, icon: icon, accessory: accessory, action: action)
        newSelf.rows.append(newRow)
        return newSelf
    }
    
    var body: some View {
        ScrollView() {
            ZStack {
                BoundingPrimitiveView(height: 0, radius: 24)
                    .padding(.top, 1)
                
                VStack(spacing: 0) {
                    ForEach(rows.indices, id: \.self) { index in
                        let row = rows[index]
                        VStack(spacing: 0) {
                            Button(action: row.action) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.title)
                                            .foundationText(.body)
                                        if(!row.subtitle.isEmpty){
                                            Text(row.subtitle)
                                                .foundationText(.bodySecondary)
                                                .opacity(0.8)
                                                
                                        }
                                    }
                                    Spacer()
                                    
                                    if(row.accessory == .none){
                                        if let color = color {
                                            Image(row.icon)
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .foregroundColor(color)
                                                .frame(height: 30)
                                        } else {
                                            // Original colors
                                            Image(row.icon)
                                                .resizable()
                                                .renderingMode(.original)
                                                .scaledToFit()
                                                .frame(height: 30)
                                        }
                                    }
                                    else{
                                        ResponsiveToggle()
                                            .scaleEffect(0.85)
                                            .padding(.trailing, -12)
                                        
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.clear)
                                )
                            }
                            
                            if index != rows.count - 1 {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(getSystemColor(colorScheme)))
                                    .opacity(0.16)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                
            }
            //.fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 18)
            
        }
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
        .scrollClipDisabled()

        
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

struct PurplePrimitiveView: View {
    @Environment(\.colorScheme) var colorScheme
    let height: CGFloat
    let radius: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color(hex: "EAE3FF"))
            .shadow(color: Color(hex: "BDA8EA").opacity(0.7), radius: 11, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .innerOuterStroke(
                        outerColor: Color(hex: "C2B5E7"),
                        outerWidth: 2.5,
                        outerBlend: .luminosity,
                        innerColor: .white.opacity(0.7),
                        innerWidth: 2,
                        innerBlend: .luminosity
                    )
            )
            .frame(height: height == 0 ? nil : height)
            //.padding(.horizontal, 18)
    }
}

// MARK: - Creation Sheet

struct NewCompositeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var composites: [Composite]
    @State private var scale: CGFloat = 1.0
    @State private var classType: String = ""
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showEditWarning: Bool = false
    let composbrown = Color(red: 0.380, green: 0.325, blue: 0.231)
    @State private var compositeText: String = ""
    @State private var currentPage: Int = 0
    
    @State private var showMoodPicker: Bool = false
    @State private var showMoodPicker2: Bool = false
    @State private var showMoodPickerContent: Bool = false
    @State private var currentEmotion: Int = 3
    @State private var sliderState: CGFloat = 3
    @FocusState private var mainEditorFocused: Bool
    @State private var loop1: Bool = false
    @State private var moodStage: Int = 0
    //Happiness Sadness Fearful Surprise Calm Anger Disgust
    //Anger Fearful Calm Happiness Surprise Sadness Neutral
    @State private var balloonColors: [Color] = [
        Color(hex: "E63943"), //1
        Color(hex: "8F4EA3"), //2
        Color(hex: "68D5B8"), //3
        Color(hex: "FFB319"), //4
        Color(hex: "E4658F"), //5
        Color(hex: "3235DF"), //6
        Color(hex: "DDDDDD")  //7
    ]
    
    
    
    @State private var isDragged1: Bool = false
    @State var dragValue1: CGFloat = 0.5
    
    @State private var balloonBrightness: [CGFloat] = [
        -0.15, //1
         -0.1, //2
         0.0, //3
         0.12, //4
         0.0, //5
         -0.17, //6
         0.0  //7
    ]
    
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    
    
    var body: some View {
        
        ZStack(){
            ZStack(){
                
                ZStack(){
                    ZStack(alignment: .top) {
                        // Background color for the top bar
                        FoundationBG()
                        //.frame(height: 700)
                        
                        ZStack(){
                            // MARK: Default View
                            ZStack(){
                                VStack(){
                                    ZStack() {
                                        HStack() {
                                            ZStack() {
                                                if(currentPage == 0) {
                                                    ZStack() {
                                                        Button() {
                                                            dismiss()
                                                        } label: {
                                                            DefaultPillView(text: "Cancel", image: "", type: 0, padding: 20)
                                                            
                                                        }
                                                        .padding(.horizontal, 15)
                                                        
                                                        .buttonStyle(.automatic)
                                                    }
                                                    
                                                }
                                                else{
                                                    ZStack() {
                                                        Button() {
                                                            if compositeText.isEmpty {
                                                                currentPage = 0
                                                            }
                                                            else{
                                                                showEditWarning = true
                                                            }
                                                        } label: {
                                                            DefaultPillView(text: " ", image: "arrow.left", type: 1, padding: 20)
                                                        }
                                                        .padding(.horizontal, 15)
                                                        .buttonStyle(.automatic)
                                                        .alert("Discard unsaved edits?", isPresented: $showEditWarning) {
                                                            Button("Cancel", role: .cancel) {
                                                            }
                                                            Button("Discard", role: .destructive) {
                                                                currentPage = 0                        }
                                                        } message: {
                                                            Text("You cannot undo this action.")
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            .blur(radius: scale == 1.18 ? 2.2 : 0)
                                            .animation(.snappy, value: currentPage)
                                            .scaleEffect(scale, anchor: .center)
                                            .onChange(of: currentPage) {
                                                withAnimation(.bouncy) { scale = 1.18 }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                    withAnimation(.bouncy) { scale = 1.0 }
                                                }
                                            }
                                            
                                            
                                            Spacer()
                                            
                                            ZStack(){
                                                if(currentPage == 0){
                                                    Button(action: {
                                                        
                                                    }) {
                                                        DefaultPillView(text: " ", image: "checkmark", type: 1, padding: 20)
                                                    }
                                                    .padding(.horizontal, 15)
                                                    .buttonStyle(.automatic)
                                                    .opacity(0.4)
                                                }
                                                else{
                                                    // MARK: data
                                                    Button(action: {
                                                        modelContext.insert(Composite(textContent: "\(compositeText)", classification: "neutral", latitude: 0, longitude: 0, sort: 1))
                                                        print("Number of composites: \(composites.count)")
                                                        
                                                        do {
                                                            try modelContext.save()
                                                        } catch {
                                                            print("Failed to save new note: \(error)")
                                                        }
                                                        
                                                        dismiss()
                                                    }) {
                                                        DefaultPillView(text: " ", image: "checkmark", type: 1, padding: 20)
                                                    }
                                                    .padding(.horizontal, 15)
                                                    .buttonStyle(.automatic)
                                                }
                                            }
                                            .animation(.snappy, value: currentPage)
                                            .scaleEffect(scale, anchor: .center)
                                            .onChange(of: currentPage) {
                                                withAnimation(.spring(bounce: 0.5)) { scale = 1.2 }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                    withAnimation(.spring(bounce: 0.5)) { scale = 1.0 }
                                                }
                                            }
                                            
                                        }
                                        Text("Create Composite")
                                            .fontWeight(.semibold)
                                            .font(.title3)
                                            .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                            .blendMode(.luminosity)
                                        
                                        
                                    }
                                    .padding(.top, 16)
                                    
                                    if(currentPage == 1) {
                                        Spacer()
                                            .frame(height: 14)
                                        
                                        Text(classType)
                                            .fontWeight(.semibold)
                                            .font(.headline)
                                            .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                            .blendMode(.luminosity)
                                            .transition(.blurReplace)
                                    }
                                    
                                    // MARK: - Content
                                    if(currentPage == 0) {
                                        
                                        VStack(){
                                            
                                            Spacer()
                                                .frame(height: 14)
                                            
                                            Text("Select a classification")
                                                .foundationText(.caption)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 24)
                                            
                                            Spacer()
                                                .frame(height: 10)
                                            
                                            
                                            Primativelist()
                                                .item(title: "Reflection", subtitle: "Look back on the past", icon: "triangle.rounded") {
                                                    classType = "Reflection";
                                                    currentPage = 1;
                                                }
                                                .item(title: "Moment", subtitle: "Your thoughts in the moment", icon: "pentagon") {
                                                    classType = "Moment";
                                                    currentPage = 1;
                                                }
                                                .item(title: "Realization", subtitle: "Epiphanies and revelations", icon: "star.4") {
                                                    classType = "Realization";
                                                    currentPage = 1;
                                                }
                                                .item(title: "Goal", subtitle: "Your plans for the future", icon: "circle.rounded") {
                                                    classType = "Goal";
                                                    currentPage = 1;
                                                }
                                                .item(title: "General", subtitle: "Your miscellaneous thoughts", icon: "square.rounded") {
                                                    //classType = "General";
                                                    //currentPage = 1;
                                                    showMoodPicker = true;
                                                }
                                            
                                            
                                            Spacer()
                                                .frame(height: 40)
                                            
                                            Text("More composite types")
                                                .foundationText(.caption)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 24)
                                            
                                            Spacer()
                                                .frame(height: 10)
                                            
                                            
                                            Primativelist(color: getSystemColor(colorScheme))
                                                .item(title: "Coming Soon!", subtitle: "", icon: "xmark") {
                                                    
                                                }
                                            
                                            
                                            
                                        }
                                        .frame(maxHeight: .infinity, alignment: .top)
                                        .transition(.move(edge: .leading))
                                    }
                                    
                                    else {
                                        VStack {
                                            
                                            Spacer()
                                                .frame(height: 0)
                                            
                                            Image("Composition.NewComposite")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(.horizontal, 15)
                                                .padding(.top, 10)
                                            
                                            Spacer()
                                                .frame(height: 20)
                                            
                                        }
                                        .frame(maxHeight: .infinity, alignment: .top)
                                        .transition(.move(edge: .trailing))
                                        //.ignoresSafeArea(.keyboard, edges: .bottom)
                                    }
                                    
                                }
                                .opacity(showMoodPicker ? 0.3 : 1)
                                .animation(.snappy(duration: 0.44), value: currentPage)
                                .animation(.snappy(duration: 0.3), value: showMoodPicker)
                            }
                            //.background(.red)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            
                            
                            
                            // MARK: Emotion Picker View
                            ZStack(){
                                ZStack(){
                                    LinearGradient(colors: [
                                        //Color(red: 0.905, green: 0.874, blue: 1),
                                        //Color(red: 0.825, green: 0.727, blue: 1) ],
                                        Color(red: 0.9, green: 0.9, blue: 0.9),
                                        Color(red: 0.8, green: 0.7, blue: 1) ],
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                    .grayscale(1)
                                    .brightness(currentEmotion == 3 ? 0.05 : currentEmotion == 5 || currentEmotion == 0 ? -0.06 : 0)
                                    .animation(.smooth(duration: 0.7), value: currentEmotion)
                                    Rectangle()
                                        .fill(balloonColors[currentEmotion])
                                        .opacity(currentEmotion == 2 ? 0.5 : 1)
                                        .blendMode(.color)
                                        .animation(.smooth(duration: 0.7), value: currentEmotion)
                                    
                                }
                                .mask(
                                    RoundedRectangle(cornerRadius: showMoodPickerContent ? 0 : showMoodPicker2 ? 60 : 80)
                                )
                                //.brightness(!showMoodPicker && showMoodPicker2 ? -1 : 0)
                                .scaleEffect(showMoodPicker ? 1 : 0.1)
                                .blur(radius: !showMoodPicker && showMoodPicker2 ? 20 : showMoodPicker2 ? 0 : 20)
                                .frame(maxWidth: showMoodPicker2 && showMoodPicker ? .infinity : 80, maxHeight: showMoodPicker2 && showMoodPicker ? .infinity : 120)
                                
                                
                                VStack(){
                                    
                                    //content
                                    ZStack(alignment: .top){
                                        VStack(){
                                            ZStack() {
                                                HStack() {
                                                    ZStack() {
                                                        Button() {
                                                            showMoodPicker = false
                                                        } label: {
                                                            ZStack(alignment:.leading){
                                                                ZStack(){
                                                                    BoundingPrimitiveView(height: 0, radius: 26)
                                                                        .grayscale(1)
                                                                        .brightness(currentEmotion == 2 ? 0.02 : -0.004)
                                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                    //.padding(2)
                                                                    RoundedRectangle(cornerRadius: 26)
                                                                        .fill(balloonColors[currentEmotion])
                                                                        .blendMode(.color)
                                                                    
                                                                }
                                                                .animation(.linear, value: currentEmotion)
                                                                .frame(maxWidth: .infinity)
                                                                .frame(height: 41)
                                                                Text("Cancel")
                                                                    .foundationText(.bodySecondary, color: balloonColors[currentEmotion])
                                                                    .brightness(-0.72)
                                                                    .padding(.horizontal, 18)
                                                                    .frame(maxHeight: .infinity, alignment: .center)
                                                                
                                                            }
                                                            //.frame(height: 42)
                                                            .fixedSize()
                                                            
                                                            
                                                        }
                                                        .padding(.horizontal, 15)
                                                        
                                                        .buttonStyle(.automatic)
                                                    }
                                                    
                                                    
                                                    
                                                    Spacer()
                                                    
                                                    ZStack(){
                                                        
                                                        Button(action: {
                                                            showMoodPicker = false
                                                        }) {
                                                            ZStack(alignment:.leading){
                                                                ZStack(){
                                                                    BoundingPrimitiveView(height: 0, radius: 26)
                                                                        .grayscale(1)
                                                                        .brightness(currentEmotion == 2 ? 0.02 : -0.004)
                                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                                    //.padding(2)
                                                                    RoundedRectangle(cornerRadius: 26)
                                                                        .fill(balloonColors[currentEmotion])
                                                                        .blendMode(.color)
                                                                    
                                                                }
                                                                .animation(.linear, value: currentEmotion)
                                                                .frame(maxWidth: .infinity)
                                                                .frame(height: 41)
                                                                Image("checkmark")
                                                                    .resizable()
                                                                    .renderingMode(.template)
                                                                    .scaledToFit()
                                                                    .foregroundStyle(balloonColors[currentEmotion])
                                                                    .brightness(-0.72)
                                                                    .padding(.horizontal, 20)
                                                                    .frame(height: 29)
                                                                
                                                            }
                                                            //.frame(height: 42)
                                                            .fixedSize()
                                                        }
                                                        .padding(.horizontal, 15)
                                                        .buttonStyle(.automatic)
                                                    }
                                                    
                                                }
                                                Text("Emotion")
                                                    .fontWeight(.semibold)
                                                    .font(.title3)
                                                    .foregroundStyle(Color(hex:"412E7A"))
                                                    .blendMode(.luminosity)
                                                
                                                
                                            }
                                            .padding(.top, 16)
                                            
                                            ZStack(){
                                                
                                                VStack(){
                                                    
                                                    Spacer()
                                                        .frame(height: 140)
                                                    
                                                    VStack(){
                                                        ScrollView(.horizontal, showsIndicators: false) {
                                                            HStack(){
                                                                ForEach(0..<7){ i in
                                                                    ZStack(){
                                                                        ZStack(){
                                                                            Image("emotionballoon")
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .grayscale(1)
                                                                                .brightness(balloonBrightness[i])
                                                                            Image("emotionballoon")
                                                                                .resizable()
                                                                                .renderingMode(.template)
                                                                                .scaledToFit()
                                                                                .foregroundColor(Color(balloonColors[i]))
                                                                                .blendMode(.color)
                                                                            
                                                                        }
                                                                        .compositingGroup() //Prevents stutters with blur
                                                                        
                                                                    }
                                                                    .frame(width: 130, height: 130)
                                                                    .padding(.top, currentEmotion-i == 1 || currentEmotion-i == -1 ? 80 : currentEmotion != i ? 240 : 0)
                                                                    .rotationEffect(Angle(degrees: CGFloat((i - currentEmotion) * 16)))
                                                                    .opacity(currentEmotion-i == 1 || currentEmotion-i == -1 ? 0.22 : currentEmotion != i ? 0.14 : 1)
                                                                    .blur(radius: currentEmotion-i == 1 || currentEmotion-i == -1 ? 2 : currentEmotion != i ? 3 : 0)
                                                                    .scaleEffect(currentEmotion == i && loop1 ? 1.45 : currentEmotion == i ? 1.55 : 1)
                                                                    .animation(.snappy(duration: 0.4, extraBounce: 0.03), value: currentEmotion) //ANIMATION CONTROLLER
                                                                    
                                                                }
                                                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: loop1)
                                                                .onAppear(){
                                                                    loop1.toggle()
                                                                }
                                                                .onChange(of: currentEmotion) {
                                                                    loop1.toggle()
                                                                }
                                                            }
                                                            //.frame(maxWidth: .infinity, alignment: .center)
                                                            //.scaleEffect(0.5)
                                                            //.background(.red)
                                                            .offset(x: 138 - 138 * CGFloat(currentEmotion), y: 0)
                                                            .animation(.snappy, value: currentEmotion) //ANIMATION CONTROLLER
                                                            .onChange(of: currentEmotion){
                                                                selectionFeedback.prepare()
                                                                selectionFeedback.selectionChanged()
                                                            }
                                                            
                                                            
                                                        }
                                                        .ignoresSafeArea(edges: .horizontal)
                                                        .scrollDisabled(true)
                                                        //.background(.blue)
                                                        .padding(0)
                                                        .frame(height: 300)
                                                        .blur(radius: showMoodPickerContent ? 0 : 8)
                                                        
                                                        Spacer()
                                                            .frame(height: 40)
                                                        
                                                        Text(
                                                            currentEmotion == 0 ? "Anger" :
                                                                currentEmotion == 1 ? "Fearful" :
                                                                currentEmotion == 2 ? "Calm" :
                                                                currentEmotion == 3 ? "Happiness" :
                                                                currentEmotion == 4 ? "Surprise" :
                                                                currentEmotion == 5 ? "Sadness" :
                                                                "Neutral"
                                                        )
                                                        .foundationText(.title, color: balloonColors[currentEmotion])
                                                        .brightness(-0.52)
                                                        .transition(.blurReplace)
                                                        .onChange(of: sliderState){
                                                            currentEmotion = Int(sliderState.rounded(.toNearestOrEven))
                                                        }
                                                        //.animation(.linear(duration: 0.1), value: currentEmotion)
                                                        
                                                        Spacer()
                                                            .frame(height: 45)
                                                        
                                                        /*
                                                         ResponsiveSlider($sliderState, 0, 6)
                                                         .padding(.horizontal, 30)
                                                         
                                                         .grayscale(1)
                                                         */
                                                        
                                                        // MARK: slider
                                                        ZStack() {
                                                            GeometryReader { geo in
                                                                let width = geo.size.width
                                                                
                                                                ZStack(alignment: .leading) {
                                                                    
                                                                    ZStack(){
                                                                        Color(.white.opacity(0.4))
                                                                            .mask(
                                                                                Capsule()
                                                                            )
                                                                            .frame(height: 48)
                                                                            .animation(.smooth, value: currentEmotion)
                                                                        
                                                                        HStack(){
                                                                            ForEach(0..<7){ i in
                                                                                Spacer()
                                                                                Capsule()
                                                                                    .fill(.black.opacity(0.07))
                                                                                    .frame(width: 6, height: 6)
                                                                                    .compositingGroup()
                                                                                    .saturation(1)
                                                                                Spacer()
                                                                            }
                                                                        }
                                                                        .frame(width: .infinity)
                                                                        .scaleEffect(0.92)
                                                                    }
                                                                    .padding(.horizontal, -13)
                                                                    .padding(.leading, -5)
                                                                    
                                                                    
                                                                    ZStack {
                                                                        Circle()
                                                                            .fill(.white)
                                                                        
                                                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                                                            .opacity(isDragged1 ? 1 : 0.9)
                                                                        
                                                                        Circle()
                                                                            .fill(balloonColors[currentEmotion])
                                                                            .scaleEffect(isDragged1 ? 1.423 : 1)
                                                                            .opacity(isDragged1 ? 0.77 : 0)
                                                                            .compositingGroup()
                                                                            .brightness(currentEmotion == 6 ? -0.2 : 0)
                                                                        //.opacity(isDragged1 ? 0 : 1)
                                                                            .animation(.smooth, value: currentEmotion)
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        Circle()
                                                                            .fill(Color(.clear))
                                                                            .strokeBorder(
                                                                                LinearGradient(
                                                                                    colors: [
                                                                                        Color.white,        // top-left
                                                                                        Color.clear,       // mid
                                                                                        Color.white       // bottom-right
                                                                                    ],
                                                                                    startPoint: .topLeading,
                                                                                    endPoint: .bottomTrailing
                                                                                ),
                                                                                lineWidth: 1.2
                                                                            )
                                                                            .scaleEffect(isDragged1 ? 1.42 : 1)
                                                                            .opacity(isDragged1 ? 0.9 : 0)
                                                                            .blur(radius: 0.5)
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        ZStack(){
                                                                            Capsule()
                                                                                .fill(balloonColors[currentEmotion])
                                                                                .padding(5)
                                                                                .opacity(isDragged1 ? 0 : 0.7)
                                                                            //.shadow(color: .black.opacity(0.3), radius: 6)
                                                                                .blur(radius: isDragged1 ? 3 : 0)
                                                                                .compositingGroup()
                                                                                .brightness(currentEmotion == 6 ? -0.2 : 0)
                                                                                .animation(.smooth, value: currentEmotion)
                                                                        }
                                                                        .scaleEffect(isDragged1 ? 1.8 : 1)
                                                                        
                                                                        ZStack{
                                                                            Circle()
                                                                                .foregroundStyle(balloonColors[currentEmotion])
                                                                                .mask(
                                                                                    ZStack(){
                                                                                        VStack(){
                                                                                            Ellipse()
                                                                                                .fill(.black)
                                                                                                .brightness(0.1)
                                                                                                .padding(.top, 1)
                                                                                            Spacer()
                                                                                                .padding(4)
                                                                                            Ellipse()
                                                                                                .fill(.black)
                                                                                                .brightness(0.1)
                                                                                                .padding(.bottom, 1)
                                                                                        }
                                                                                        .padding(.horizontal, dragValue1 < 0.01 || dragValue1 > 0.99 ? 12 : 14)
                                                                                        .animation(.smooth(duration: 0.2), value: dragValue1)
                                                                                        Capsule()
                                                                                            .strokeBorder(.black, lineWidth: 6)
                                                                                            .opacity(dragValue1 < 0.01 || dragValue1 > 0.99 ? 0.45 : 0)
                                                                                            .padding(.horizontal, -25)
                                                                                            .offset(x: dragValue1 < 0.01 ? 25 : dragValue1 > 0.99 ? -25 : 0, y: 0)
                                                                                            .animation(.smooth(duration: 0.3), value: dragValue1)
                                                                                        
                                                                                        
                                                                                    }
                                                                                        .opacity(isDragged1 ? 0.35 : 0)
                                                                                    
                                                                                )
                                                                        }
                                                                        .brightness(currentEmotion == 6 ? 0.2 : 0.6)
                                                                        .animation(.smooth, value: currentEmotion)
                                                                        .scaleEffect(1.423)
                                                                        .blur(radius: 4)
                                                                        //.animation(.bouncy(duration: 0.34), value: isDragged1)
                                                                        
                                                                        
                                                                        
                                                                        
                                                                    }
                                                                    .shadow(color: .black.opacity(0.06), radius: 8)
                                                                    .frame(width: 42, height: 42)
                                                                    .offset(x: dragValue1 * width - (36 * (0.4 + 0.5 * dragValue1)))
                                                                    .gesture(
                                                                        DragGesture()
                                                                            .onChanged { drag in
                                                                                let x = drag.location.x
                                                                                dragValue1 = max(0, min(1, x / width))
                                                                                sliderState = dragValue1 * 6
                                                                            }
                                                                    )
                                                                    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                                                                        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.12)) {
                                                                            isDragged1 = pressing
                                                                        }
                                                                    }, perform: {})
                                                                }
                                                            }
                                                            .frame(height: 36)
                                                            .onAppear {
                                                                dragValue1 = sliderState / 6
                                                            }
                                                            
                                                        }
                                                        .padding(.horizontal, 30)
                                                        
                                                        
                                                        
                                                        
                                                        ZStack(){
                                                            ZStack(){
                                                                BoundingPrimitiveView(height: 0, radius: 25)
                                                                    .grayscale(1)
                                                                    .brightness(currentEmotion == 2 ? 0.01 : -0.008)
                                                                RoundedRectangle(cornerRadius: 26)
                                                                    .fill(balloonColors[currentEmotion])
                                                                
                                                                    .blendMode(.color)
                                                                
                                                                
                                                            }
                                                            .compositingGroup()
                                                            .animation(.linear, value: currentEmotion)
                                                            Text("Next")
                                                                .foundationText(.label, color: balloonColors[currentEmotion])
                                                                .brightness(-0.72)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: 60)
                                                        .padding(.horizontal, 40)
                                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                                        .onTapGesture(){
                                                            moodStage = 1
                                                        }
                                                        
                                                    }
                                                    .scaleEffect(moodStage == 1 ? 0.9 : showMoodPickerContent ? 1 : 0.9)
                                                    .opacity(moodStage == 1 ? 0.2 : 1)
                                                    .blur(radius: moodStage == 1 ? 18 : 0)
                                                    .animation(.smooth(duration: 0.8), value: moodStage)
                                                    
                                                    
                                                }
                                                
                                                
                                                VStack(){
                                                    
                                                    Spacer()
                                                        .frame(height: 30)
                                                    
                                                    Text("How would you describe this feeling?")
                                                        .foundationText(.caption, color: balloonColors[currentEmotion])
                                                        .brightness(-0.52)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding(.horizontal, 24)
                                                        .compositingGroup()

                                                        
                                                    Spacer()
                                                        .frame(height: 14)
                                                    ZStack(){
                                                        Primativelist()
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .item(title: "im an emoiton", subtitle: "", icon: "") {
                                                                moodStage = 0
                                                            }
                                                            .grayscale(1)
                                                            .overlay(){
                                                                RoundedRectangle(cornerRadius: 26)
                                                                    .fill(balloonColors[currentEmotion])
                                                                    .blendMode(.color)
                                                                    .padding(.horizontal, 17)
                                                                    .opacity(0.7)
                                                                    .allowsHitTesting(false)
                                                            }
                                                            .compositingGroup()
                                                    }
                                                        
                                                }
                                                .frame(maxHeight: .infinity, alignment: .top)
                                                .scaleEffect(moodStage != 1 ? 1.14 : showMoodPickerContent ? 1 : 0.9)
                                                .opacity(moodStage != 1 ? 0 : 1)
                                                .blur(radius: moodStage != 1 ? 12 : 0)
                                                //.offset(x: 0, y: moodStage != 1 ? -10)
                                                .animation(.smooth(duration: 0.45), value: moodStage)
                                                
                                                
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    .opacity(showMoodPickerContent ? 1 : showMoodPicker2 ? 0 : 0)
                                    
                                    .onChange(of: showMoodPicker){
                                        if(showMoodPicker){
                                            moodStage = 0
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                                                withAnimation(.spring(duration: 0.6, bounce: 0)) { showMoodPickerContent.toggle() } //ANIMATION CONTROLLER
                                            }
                                            
                                        }
                                        else{
                                            withAnimation(.spring(duration: 0.1)) { showMoodPickerContent.toggle() } //ANIMATION CONTROLLER
                                        }
                                    }
                                    //.animation(.bouncy(duration: 1), value: showMoodPicker)
                                    //Spacer()
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.bottom, 30)
                                //.background(.red)
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .clipped()
                            .ignoresSafeArea()
                            .opacity(showMoodPicker ? 1 : 0)
                            .offset(x: 0, y: showMoodPicker ? 0 : 450)
                            .animation(.spring(duration: 0.5), value: showMoodPicker)
                            .onChange(of: showMoodPicker){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(duration: 0.4, bounce: 0.25)) { showMoodPicker2.toggle() }
                                }
                                
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                        
                 

            }
            }
            //.background(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
            
            /*
            ZStack(){
                ZStack(alignment: .topLeading){
                    BoundingPrimitiveView(height: 0, radius: 24)
                    
                    
                    
                    if(compositeText.isEmpty) {
                        Text("What's on your mind?")
                            .foundationText(.body)
                            .opacity(0.6)
                            .padding(.leading, 15)
                            .padding(.top, 18)
                    }
                    
                    TextEditor(text: $compositeText)
                        .focused($mainEditorFocused)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
                .frame(height: 170)
                .padding(.horizontal, 15)
                .padding(.bottom, 10)
                .frame(maxHeight: .infinity, alignment: .bottom)
                //.animation(.snappy, value: mainEditorFocused)
            }
            */
        }
        
        
        
    }
}



struct DefaultPillView: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    let image: String
    let type: Int
    let padding: CGFloat
    //let ContainerWidth: CGFloat
    
    var body: some View {
        ZStack(alignment:.leading){
        BoundingPrimitiveView(height: 0, radius: 26)
                .frame(maxWidth: .infinity)
                .frame(height: 41)
            if(type == 0) {
                Text(text)
                    .foundationText(.bodySecondary)
                    .transition(.blurReplace)
                    .padding(.horizontal, 18)
                    .frame(maxHeight: .infinity, alignment: .center)
                    
            }
            else{
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(getSystemColor(colorScheme))
                    .padding(.horizontal, padding)
                    .frame(height: 29)
                
            }
            
        }
        //.frame(height: 42)
        .fixedSize()
        //.background(Color.red)
    }
}


struct TextContainerView: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    let height: CGFloat
    var body: some View {
        ZStack(alignment: .leading) {
            BoundingPrimitiveView(height: 0, radius: 28)
                .frame(maxWidth: .infinity)
                .frame(height: height != 0 ? height : .infinity)
            
            Text(text)
                .foundationText(.body)
                .padding(.horizontal, 18)
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 20)
            
            
            
        }
        .frame(maxHeight: .infinity)
        
        
    }
}


#Preview {
    // Create a local state just for the preview
    @Previewable @State var showTabPreview = true
    PreviewWrapper{
        return MemoryView($showTabPreview)
            .modelContainer(for: Composite.self, inMemory: true)
        
//        return MemoryMap(showTab: $showTabPreview)
//            .modelContainer(for: Composite.self, inMemory: true)
    }
}
/*
 Text("Notes")
 .frame(maxWidth: .infinity, alignment: .leading)
 .font(.largeTitle)
 .bold()
 .padding([.top, .leading], 18)
 
 VStack() {
 ShareLink(item: noteText) {
 HStack {
 Image(systemName: "square.and.arrow.up")
 .fontWeight(.bold)
 .foregroundStyle(Color(red: 0.412, green: 0.29, blue: 0.055))
 .imageScale(.medium)
 }
 .contentShape(Circle())
 .fixedSize(horizontal: true, vertical: true)
 .foregroundColor(.white)
 .padding(14)
 .background(Color(red: 1, green: 0.9, blue: 0.8))
 .cornerRadius(40)
 .frame(maxWidth: .infinity, alignment: .bottomTrailing)
 
 
 }
 .padding(.horizontal, 18)
 .padding(.top, 20)
 
 }
 */


/*
 
 START E8 D7 D9 0S D9 D8 S7 D6 H9 H3 J6 G2 J1 G6 S9 A0 D6 F7 G3 H2 S7 H3
 RETURN H5 H2 K7 J3 H0 F5 H3 J7 S2 G3 G9 J3 H5
 
 */

