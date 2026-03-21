//
//  Onboarding1.swift
//  testing
//
//  Created by Formic on 6/16/25.
//

import Foundation
import SwiftUI
import UserNotifications
import SwiftData
import Combine



/*
 
 RoundedRectangle(cornerRadius: 25)
     .fill(animationStage == 2 ? Color(red: 1, green: 0.955, blue: 0.89) : Color(red: 1, green: 0.902, blue: 0.586, opacity: 1))
     .frame(width: animationStage == 2 ? 130 : 40, height: animationStage == 2 ? 80 : 40)
     .opacity(animationStage >= 2 ? 1 : 0)
     .blur(radius: animationStage == 2 ? 0 : animationStage == 3 ? 6 : 15)
     //.shadow(color: Color(red: 0.928, green: 0.824, blue: 0.694).opacity(animationStage == 2 ? 0.8 : 0), radius: 11, y: 3)
     .overlay(
         RoundedRectangle(cornerRadius: 25)
             .innerOuterStroke(
                 outerColor: Color(red: 0.878, green: 0.8, blue: 0.694),
                 outerWidth: animationStage == 2 ? 2.5 : 0,
                 outerBlend: .luminosity,
                 innerColor: .white,
                 innerWidth: animationStage == 2 ? 2 : 0,
                 innerBlend: .luminosity
             )
     )
     .scaleEffect(animationStage >= 2 ? 1 : 0.2)
     .padding(.bottom, 50)
 
 */


struct loadingView: View{
    @State private var animationStage = 0
    @State private var isSpinning = false
    @State private var compressed = false
    
    func toggleCompressed() {
        withAnimation(.easeOut(duration: 0.5)) {
            compressed.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            toggleCompressed()
        }
    }
    
    var body: some View{
        ZStack(){
            ZStack(){
                VStack(){
                    
                    VStack(){
                        RoundedRectangle(cornerRadius: 25)
                        //.fill(animationStage == 2 ? Color(red: 1, green: 0.955, blue: 0.89) : Color(red: 1, green: 0.902, blue: 0.586, opacity: 1))
                            .fill(Color(red: 1, green: 0.852, blue: 0.486, opacity: 1))
                            .frame(width: 60, height: 60)
                            .padding(.bottom, compressed ? -85 : 45)
                            .onAppear {
                                // Start toggling compressed repeatedly
                                toggleCompressed()
                            }
                        
                        
                        
                        
                        RoundedRectangle(cornerRadius: 25)
                        //.fill(animationStage == 2 ? Color(red: 1, green: 0.955, blue: 0.89) : Color(red: 1, green: 0.902, blue: 0.586, opacity: 1))
                            .fill(Color(red: 1, green: 0.852, blue: 0.486, opacity: 1))
                            .frame(width: 60, height: 60)
                    }
                    .opacity(animationStage >= 2 ? 1 : 0)
                    .blur(radius: compressed ? 20 : animationStage == 3 ? 8 : 15)
                    //.shadow(color: Color(red: 0.928, green: 0.824, blue: 0.694).opacity(animationStage == 2 ? 0.8 : 0), radius: 11, y: 3)
                    .scaleEffect(animationStage >= 3 ? 1 : 2)
                    
                    
                    
                    
                }
                .animation(.easeInOut(duration: 0.5), value: isSpinning)
                //.background(.red)
                //.rotationEffect(.degrees(animationStage == 2 ? 180 : 0))
                .rotationEffect(.degrees(isSpinning && animationStage >= 2 ? 720 : 0), anchor: .center)
                .animation(
                    isSpinning && animationStage == 3
                    ? .easeInOut(duration: 1.05).repeatForever(autoreverses: true)
                    : .default,
                    value: isSpinning
                )
                
                
            }
            
            
            .rotationEffect(.degrees(isSpinning && animationStage >= 2 ? 360 : 0), anchor: .center)
            .animation(
                isSpinning && animationStage == 3
                ? .easeInOut(duration: 25).repeatForever(autoreverses: false)
                : .default,
                value: isSpinning
            )
            .onAppear {
                if animationStage == 0 {
                    animationStage = 1
                }
            }
            .onChange(of: animationStage){
                if(animationStage == 1){
                    withAnimation(.bouncy(duration: 0.5)){
                        animationStage = 2
                    }
                    
                }
                if(animationStage == 2){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.bouncy(duration: 0.5)){
                            animationStage = 3
                        }
                    }
                }
                if(animationStage == 2){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.bouncy(duration: 0.1)){
                            //animationStage = 2
                            isSpinning = true
                            compressed = true
                        }
                    }
                }
            }
            
        }
        .frame(width: 200, height: 200)
        //.background(.red)

        
    }
}

// MARK: Start

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var profileData: ProfileData
    @Query var composites: [Composite]
    @Environment(\.colorScheme) var colorScheme
    @State private var showSheet = false
    @State private var showContentView = false
    @State private var showLoader = false
    @State private var showOnboarding = true
    
    @State private var animationStage = 0
    let composbrown = Color(red: 0.380, green: 0.325, blue: 0.231)

    var body: some View {
        ZStack(){
                
                ContentView()
                    .opacity(!showContentView ? 0 : 1)
                    .blur(radius: !showContentView ? 24 : 0)
                    .scaleEffect(!showContentView ? 1.8 : 1)
                    .animation(.smooth(duration: 0.7), value: showContentView)
                    .modelContainer(for: [Composite.self])
                    .task {
                        if composites.isEmpty {
                            // Insert your default data here
                            let defaultComposite = Composite(
                                textContent: "Welcome to Compositor!",
                                classification: "General",
                                latitude: 0,
                                longitude: 0,
                                sort: 0
                            )
                            modelContext.insert(defaultComposite)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to save default data: \(error)")
                            }
                        }
                    }
                    .onChange(of: showContentView){
                        if(showContentView){
                            profileData.didCompleteOnboarding = true
                        }
                    }
                    .onAppear(){
                        if(profileData.didCompleteOnboarding){
                            showOnboarding = false
                            showContentView = true
                        }
                    }
                
            
            if (showOnboarding) {
                ZStack(){
                    /*
                     LinearGradient(
                     gradient: Gradient(colors: [
                     Color(red: 1, green: 0.902, blue: 0.686, opacity: 1),
                     Color(red: 1, green: 0.902, blue: 0.686, opacity: 0.8)
                     ]),
                     startPoint: .top,
                     endPoint: .bottom
                     )
                     .edgesIgnoringSafeArea(.all)
                     */
                    FoundationBG()
                    
                    
                    ZStack(){
                        ZStack(){
                            loadingView()
                        }
                        .scaleEffect(0.2)
                        .padding(.trailing, -60)
                        .padding(.top, -40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        
                        .opacity(animationStage == 0 ? 1 : 0)
                        
                        VStack {
                            Spacer()
                                .frame(height: 200)
                            
                            ZStack(){
                                
                                Image("compositoriconios")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .mask(
                                        Rectangle()
                                            .cornerRadius(45)
                                            .frame(width: 180, height: 180)
                                    )
                            }
                            .frame(width: 180, height: 180)
                            
                            Spacer()
                                .frame(height: 200)
                            
                            VStack(spacing: 8){
                                Text("Welcome to Compositor")
                                    .font(.title)
                                    .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .fontWeight(.bold)
                                
                                Text("Let's get started.")
                                    .font(.title3)
                                    .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .fontWeight(.bold)
                                    .opacity(0.8)
                            }
                            
                            
                            Spacer()
                            
                            
                            
                            Button() {
                                sendNotification()
                                animationStage = 1
                                //showSheet = true
                            } label: {
                                ZStack(){
                                    BoundingPrimitiveView(height: 0, radius: 25)
                                    Text("Continue")
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .light ? Color(composbrown) : Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 60)
                                .padding(.horizontal, 40)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                
                            }
                            .sheet(isPresented: $showSheet) {
                                SheetView(showContentView: $showContentView)
                                    .presentationDetents([.large])
                                //.interactiveDismissDisabled(true)
                                
                            }
                            
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(animationStage >= 1 ? 0 : 1)
                        .blur(radius: animationStage >= 1 ? 15 : 0)
                        .scaleEffect(animationStage >= 1 ? 1.8 : 1)
                        .animation(.smooth, value: animationStage)
                        
                        RoundedRectangle(cornerRadius: 25)
                            .fill(animationStage == 3 ? Color(red: 1, green: 0.955, blue: 0.89) : Color(red: 1, green: 0.902, blue: 0.586, opacity: 1))
                            .frame(width: animationStage == 3 ? 250 : 50, height: animationStage == 3 ? 150: 50)
                            .opacity(animationStage >= 2 ? 1 : 0)
                            .blur(radius: animationStage == 3 ? 0 : animationStage == 2 ? 4 : 15)
                            .scaleEffect(animationStage >= 2 ? 1 : 0.2)
                            .shadow(color: Color(red: 0.928, green: 0.824, blue: 0.694).opacity(animationStage == 3 ? 0.8 : 0), radius: 11, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .innerOuterStroke(
                                        outerColor: Color(red: 0.878, green: 0.8, blue: 0.694),
                                        outerWidth: animationStage == 3 ? 2.5 : 0,
                                        outerBlend: .luminosity,
                                        innerColor: .white,
                                        innerWidth: animationStage == 3 ? 2 : 0,
                                        innerBlend: .luminosity
                                    )
                            )
                        //.animation(.smooth(duration: 0.9), value: animationStage == 2)
                    }
                    .onChange(of: animationStage){
                        if(animationStage == 1){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.smooth(duration: 0.9)){
                                    animationStage = 2
                                }
                            }
                        }
                        if(animationStage == 2){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.bouncy(duration: 0.5)){
                                    animationStage = 3
                                }
                            }
                        }
                        if(animationStage == 3){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                animationStage = 0
                                //showSheet = true
                                showLoader = true
                            }
                        }
                    }
                    
                    
                }
            }
            
            
            fullscreenLoaderView()
                .opacity(showLoader ? 1 : 0)
                .opacity(!showLoader ? 0 : 1)
                .blur(radius: !showLoader ? 15 : 0)
                .scaleEffect(!showLoader ? 1.8 : 1)
                .animation(.smooth, value: showLoader)
                .onChange(of: showLoader){
                    showOnboarding = false
                    
                    if(showLoader){
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            showLoader = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55){
                                showContentView = true
                                let hapticController = HapticFadeController()
                                hapticController.startFadingHaptics()
                                
                                // Optionally stop after some time:
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    hapticController.stopHaptics()
                                }
                            }
                            
                        }
                    }
                    
                }
            
            
        }
    }
    
    func sendNotification() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Notifications allowed")
            } else {
                print("Notifications denied")
            }
        }
    }
    
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showContentView: Bool

    var body: some View {
        VStack {
            
            Image("Appicon")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .mask(
                    Rectangle()
                        .cornerRadius(45)
                        .frame(width: 150, height: 150)
                )
                .padding(.top, 40)

            Text("Welcome to Compositor.")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            Text("Your notetaking sidekick. \nFor the thinkers.")
                .font(.title2)
                .padding(.top, 3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                
                
                
                Button("Close") {
                    dismiss()
                    showContentView = true
                }
                .padding()
                .fontWeight(.bold)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct fullscreenLoaderView: View {
    
    var body: some View{
        ZStack(){
            FoundationBG()
            ZStack(){
                VStack(){
                    Spacer()
                        .frame(height: 240)
                    
                    loadingView()
                        .scaleEffect(0.4)
                        //.background(Color.red)
                    
                    Text("Adding the finishing touches. \n This won't take long.")
                        .foundationText(.title)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                        .frame(height: 100)
                    
                    Text("“Guard well your thoughts when alone and your words when accompanied.” ― Roy T. Bennett")
                        .foundationText(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(0.5)
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            
        }
    }
    
}



#Preview {
    PreviewWrapper{
        //fullscreenLoaderView()
        OnboardingView()
    }
}

