//
//  ContentView.swift
//  GlassMorphism
//
//  Created by Павел Курзо on 15.10.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
