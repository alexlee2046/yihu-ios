import SwiftUI

struct CollieWorkbenchShortcutItem: Identifiable {
    let id: String
    let name: String
    let icon: String
}

struct CollieWorkbenchShortcutBar: View {
    let shortcuts: CollieWorkbenchShortcuts
    let items: [CollieWorkbenchShortcutItem]
    let selected: String?
    var select: (String) -> Void
    var openAll: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var visible: [CollieWorkbenchShortcutItem] {
        shortcuts.visible(available: items.map(\.id)).compactMap { id in items.first { $0.id == id } }
    }

    var body: some View {
        HStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        if !visible.contains(where: { $0.id == selected }),
                           let current = items.first(where: { $0.id == selected }) {
                            Text(current.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BenchsideStyle.ink)
                                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                                .frame(maxWidth: 180, minHeight: 44)
                                .padding(.horizontal, 8)
                        }
                        ForEach(visible) { item in
                            Button { select(item.id) } label: {
                                Text(item.name)
                                    .font(.subheadline.weight(selected == item.id ? .semibold : .regular))
                                    .foregroundStyle(selected == item.id ? BenchsideStyle.accent : BenchsideStyle.secondary)
                                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                                    .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? 240 : 200)
                                    .padding(.horizontal, 10)
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                                    .overlay(alignment: .bottom) {
                                        if selected == item.id {
                                            Capsule().fill(BenchsideStyle.accent).frame(height: 2)
                                                .padding(.horizontal, 10)
                                                .accessibilityHidden(true)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .id(item.id)
                            .accessibilityIdentifier("collie-shortcut-" + item.id)
                            .accessibilityAddTraits(selected == item.id ? .isSelected : [])
                        }
                    }
                }
                .onAppear { if let selected { proxy.scrollTo(selected, anchor: .center) } }
                .onChange(of: selected) { _, id in
                    if let id { proxy.scrollTo(id, anchor: .center) }
                }
                .onChange(of: visible.map(\.id)) { _, _ in
                    if let selected { proxy.scrollTo(selected, anchor: .center) }
                }
            }
            Button(action: openAll) {
                Image(systemName: "square.grid.2x2")
                    .font(.subheadline)
                    .foregroundStyle(BenchsideStyle.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(radarText("全部工作台"))
            .accessibilityIdentifier("collie-shortcuts-all")
        }
    }
}

private struct CollieWorkbenchShortcutSettings: View {
    let shortcuts: CollieWorkbenchShortcuts
    let items: [CollieWorkbenchShortcutItem]
    private var ids: [String] { shortcuts.visible(available: items.map(\.id)) }

    var body: some View {
        List {
            Section {
                ForEach(ids, id: \.self) { id in
                    if let item = items.first(where: { $0.id == id }) {
                        Label(item.name, systemImage: item.icon).frame(minHeight: 44)
                    }
                }
                .onMove { shortcuts.move(from: $0, to: $1, available: items.map(\.id)) }
                .onDelete { offsets in
                    shortcuts.set(ids.enumerated().filter { !offsets.contains($0.offset) }.map(\.element))
                }
            } header: { Text(radarText("首页快捷入口")) } footer: {
                Text(radarText("拖动排序，移除只隐藏快捷入口，不删除工作台。"))
            }
            Section(radarText("可添加的工作台")) {
                ForEach(items.filter { !ids.contains($0.id) }) { item in
                    Button { shortcuts.set(ids + [item.id]) } label: {
                        Label(item.name, systemImage: "plus.circle").frame(minHeight: 44)
                    }
                }
            }
        }
        .accessibilityIdentifier("collie-shortcut-settings")
        .environment(\.editMode, .constant(.active))
        .navigationTitle(radarText("自定义快捷入口"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CollieWorkbenchPicker: View {
    @Environment(\.dismiss) private var dismiss
    let settings: CollieConnectionSettings
    let radar: CollieRadarStore
    let selectedRadar: UUID?
    var selectWeb: (URL) -> Bool
    var selectRadar: (UUID) -> Bool
    var addWeb: () -> Void
    var notice: String?
    var shortcuts: CollieWorkbenchShortcuts? = nil
    @State private var pendingDelete: UUID?
    @State private var renaming: URL?
    @State private var renameDraft = ""

    var body: some View {
        NavigationStack {
            List {
                if let notice { Text(notice).foregroundStyle(.orange).font(.footnote) }
                if let shortcuts {
                    Section {
                        NavigationLink {
                            CollieWorkbenchShortcutSettings(shortcuts: shortcuts,
                                items: settings.recentOrigins.map {
                                    CollieWorkbenchShortcutItem(id: $0.absoluteString, name: settings.name(for: $0), icon: "globe")
                                } + radar.workbenches.map {
                                    CollieWorkbenchShortcutItem(id: $0.id.uuidString, name: $0.name, icon: "scope")
                                })
                        } label: {
                            Label(radarText("自定义快捷入口"), systemImage: "slider.horizontal.3")
                                .frame(minHeight: 44)
                        }
                        .accessibilityIdentifier("collie-shortcuts-customize")
                    }
                }
                if !settings.favorites.isEmpty || radar.workbenches.contains(where: \.favorite) {
                    Section(radarText("收藏")) {
                        ForEach(settings.recentOrigins.filter { settings.favorites.contains($0) }, id: \.absoluteString) { origin in
                            Button {
                                if selectWeb(origin) { dismiss() }
                            } label: { Label(settings.name(for: origin), systemImage: "star.fill").frame(minHeight: 44) }
                        }
                        ForEach(radar.workbenches.filter(\.favorite)) { item in
                            Button {
                                if selectRadar(item.id) { dismiss() }
                            } label: { Label(item.name, systemImage: "star.fill").frame(minHeight: 44) }
                        }
                    }
                }
                Section(radarText("网页工作台")) {
                    ForEach(settings.recentOrigins, id: \.absoluteString) { origin in
                        Button {
                            if selectWeb(origin) { dismiss() }
                        } label: {
                            HStack {
                                Label(settings.name(for: origin), systemImage: settings.favorites.contains(origin) ? "star.fill" : "globe")
                                Spacer()
                                if selectedRadar == nil, origin == settings.currentOrigin {
                                    Image(systemName: "checkmark").foregroundStyle(BenchsideStyle.accent)
                                }
                            }.frame(minHeight: 44)
                        }
                        .contextMenu {
                            Button(radarText("重命名工作台")) {
                                renameDraft = settings.name(for: origin)
                                renaming = origin
                            }
                            Button(radarText(settings.favorites.contains(origin) ? "取消收藏" : "收藏")) {
                                settings.toggleFavorite(origin)
                            }
                        }
                    }
                    .onMove { settings.moveOrigins(from: $0, to: $1) }
                    Button(radarText("添加网页工作台"), systemImage: "plus") {
                        dismiss()
                        addWeb()
                    }
                }
                Section {
                    ForEach(radar.workbenches) { item in
                        Button {
                            if selectRadar(item.id) { dismiss() }
                        } label: {
                            HStack {
                                Label(item.name, systemImage: item.favorite ? "star.fill" : "scope")
                                Spacer()
                                if selectedRadar == item.id {
                                    Image(systemName: "checkmark").foregroundStyle(BenchsideStyle.accent)
                                }
                            }.frame(minHeight: 44)
                        }
                        .swipeActions {
                            Button(radarText("删除"), role: .destructive) { pendingDelete = item.id }
                            Button(radarText(item.favorite ? "取消收藏" : "收藏")) {
                                var next = item
                                next.favorite.toggle()
                                radar.update(next)
                            }.tint(.orange)
                        }
                    }
                    .onMove { radar.move(from: $0, to: $1) }
                    if let error = radar.configurationError { Text(error).foregroundStyle(.orange) }
                    Button(radarText("添加 PM Radar"), systemImage: "plus") {
                        if let id = radar.add(), selectRadar(id) { dismiss() }
                    }.disabled(radar.configurationError != nil)
                } header: { Text("PM Radar") } footer: {
                    Text(radarText("每个雷达工作台独立保存数据源、筛选和显示配置。"))
                }
            }
            .accessibilityIdentifier("collie-workbench-list")
            .navigationTitle(radarText("工作台"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(radarText("完成")) { dismiss() } }
                ToolbarItem(placement: .primaryAction) { EditButton() }
            }
            .alert(radarText("重命名工作台"), isPresented: Binding(
                get: { renaming != nil }, set: { if !$0 { renaming = nil } }
            )) {
                TextField(radarText("名称"), text: $renameDraft)
                Button(radarText("取消"), role: .cancel) { renaming = nil }
                Button(radarText("保存")) {
                    if let renaming { settings.rename(renaming, to: renameDraft) }
                    renaming = nil
                }
            }
            .alert(radarText("删除雷达工作台？"), isPresented: Binding(
                get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }
            )) {
                Button(radarText("取消"), role: .cancel) { pendingDelete = nil }
                Button(radarText("删除"), role: .destructive) {
                    if let pendingDelete { radar.remove(pendingDelete) }
                    pendingDelete = nil
                }
            } message: {
                Text(radarText("只删除本机配置和快照，不改变服务器台账。"))
            }
        }
        .tint(BenchsideStyle.accent)
    }
}
