//
//  SplashView.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI

struct SplashView: View {
    
    @StateObject var authViewModel: AuthViewModel =  AuthViewModel(authService: FirebaseAuthenticationService())
    
    
    var body: some View {
        
        
        if authViewModel.isAuthenticated {
            HomeView().environmentObject(authViewModel)
        }else {
            LoginView().environmentObject(authViewModel)
        }
            
    }
}

#Preview {
    SplashView()
}
