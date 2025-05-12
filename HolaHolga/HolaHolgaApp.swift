//
//  HolaHolgaApp.swift
//  HolaHolga
//
//  Created by Sergio Camalich on 12/05/25.
//

import SwiftUI

@main
struct HolaHolgaApp: App {
    var body: some Scene {
        WindowGroup {
            CameraViewControllerRepresentable()
        }
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

