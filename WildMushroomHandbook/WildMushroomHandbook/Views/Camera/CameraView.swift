//
//  CameraView.swift
//  WildMushroomHandbook
//
//  相机视图 - 拍摄野生菌
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: View {
    @State private var isProcessing = false
    @State private var currentIdentification: MushroomIdentification?
    @State private var showReport = false
    @State private var mockType: MockIdentificationType = .random

    // 真实相机相关状态
    @State private var showCameraPicker = false
    @State private var capturedImage: UIImage?
    @State private var cameraPermissionGranted = false
    @State private var showPermissionAlert = false

    private let cameraService = CameraService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if isProcessing {
                    // 处理中状态
                    ProcessingView()
                } else if showReport, let identification = currentIdentification {
                    // 识别报告页
                    IdentificationReportView(
                        identification: identification,
                        onAddToHandbook: {
                            addToHandbook(identification)
                            showReport = false
                        },
                        onDismiss: {
                            showReport = false
                        }
                    )
                } else {
                    // 相机界面
                    cameraInterface
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(
                    image: $capturedImage,
                    sourceType: .constant(.camera)
                )
                .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { newImage in
                if let image = newImage {
                    processCapturedImage(image)
                }
            }
            .alert("相机权限", isPresented: $showPermissionAlert) {
                Button("去设置") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("请在设置中允许访问相机以拍摄野生菌照片")
            }
            .onAppear {
                checkCameraPermission()
            }
        }
    }

    // MARK: - 相机界面

    private var cameraInterface: some View {
        VStack(spacing: 0) {
            // 顶部区域
            HStack {
                Text("MOO-菇拍摄")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer()

                // Mock 类型选择器（开发调试用）
                Menu {
                    Button("随机") { mockType = .random }
                    Button("普通（牛肝菌）") { mockType = .normal }
                    Button("警告（毒蝇伞）") { mockType = .warning }
                    Button("危险（白毒伞）") { mockType = .critical }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("模拟类型")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()

            Spacer()

            // 取景框
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: 280, height: 280)

                // 角标
                VStack {
                    HStack {
                        CornerView(position: .topLeft)
                        Spacer()
                        CornerView(position: .topRight)
                    }
                    Spacer()
                    HStack {
                        CornerView(position: .bottomLeft)
                        Spacer()
                        CornerView(position: .bottomRight)
                    }
                }
                .frame(width: 280, height: 280)

                // 提示文字
                VStack {
                    Spacer()
                    Text("将野生菌对准取景框")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
                .frame(width: 280, height: 280)

                // 已拍摄图片预览
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 280, height: 280)
                        .clipped()
                        .cornerRadius(20)
                }
            }

            Spacer()

            // 底部控制区
            VStack(spacing: 20) {
                // 快门按钮
                Button {
                    openCamera()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)

                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
                }

                Text("点击拍摄")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - 相机权限检查

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            cameraService.requestCameraPermission { granted in
                cameraPermissionGranted = granted
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
        @unknown default:
            cameraPermissionGranted = false
        }
    }

    // MARK: - 打开相机

    private func openCamera() {
        if cameraPermissionGranted {
            capturedImage = nil
            showCameraPicker = true
        } else {
            showPermissionAlert = true
        }
    }

    // MARK: - 处理拍摄的图片

    private func processCapturedImage(_ image: UIImage) {
        isProcessing = true

        // 目前使用 Mock 数据，后续接入真实 API
        // TODO: 将 image 发送到后端识别 API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentIdentification = MockDataService.shared.simulateIdentification(type: mockType)
            isProcessing = false
            showReport = true
        }
    }

    private func addToHandbook(_ identification: MushroomIdentification) {
        HandbookStorageService.shared.addEntry(from: identification)
    }
}

// MARK: - 角标视图

struct CornerView: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    let position: Position

    var body: some View {
        Path { path in
            let size: CGFloat = 20
            switch position {
            case .topLeft:
                path.move(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
            case .topRight:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
            case .bottomLeft:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.addLine(to: CGPoint(x: size, y: size))
            case .bottomRight:
                path.move(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: size, y: size))
                path.addLine(to: CGPoint(x: 0, y: size))
            }
        }
        .stroke(Color.green, lineWidth: 3)
        .frame(width: 20, height: 20)
    }
}

// MARK: - 处理中视图

struct ProcessingView: View {
    @State private var dots = ""
    @State private var currentStep = 0

    private let steps = [
        "分析图像中...",
        "识别物种特征...",
        "评估风险等级...",
        "正在抠图并封装手帐资产...",
        "生成贴纸样式..."
    ]

    var body: some View {
        VStack(spacing: 24) {
            // 加载动画
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.green, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .rotationAnimation()

                Image(systemName: "leaf.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }

            // 当前步骤
            VStack(spacing: 8) {
                Text(steps[currentStep])
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("请稍候\(dots)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .onAppear {
            animateDots()
            animateSteps()
        }
    }

    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            dots = dots.count >= 3 ? "" : dots + "."
        }
    }

    private func animateSteps() {
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if currentStep < steps.count - 1 {
                currentStep += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - 旋转动画扩展

extension View {
    func rotationAnimation() -> some View {
        self.onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                // 动画由 SwiftUI 自动处理
            }
        }
    }
}

#Preview {
    CameraView()
}
