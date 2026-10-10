import SwiftUI
import UniformTypeIdentifiers

func radarText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

@MainActor
@Observable
final class CollieRadarPresentation {
    var importing = false
    var configuring = false
}

struct CollieRadarActions: View {
    let store: CollieRadarStore
    let item: CollieRadarWorkbench
    let presentation: CollieRadarPresentation

    var body: some View {
        Menu {
            Button(radarText("刷新"), systemImage: "arrow.clockwise") {
                Task { await store.refresh(item.id) }
            }.disabled(item.source.isEmpty || store.refreshing.contains(item.id))
            Button(radarText("导入快照"), systemImage: "square.and.arrow.down") { presentation.importing = true }
            Button(radarText("显示与数据源"), systemImage: "slider.horizontal.3") { presentation.configuring = true }
        } label: {
            Group {
                if store.refreshing.contains(item.id) { ProgressView() }
                else { Image(systemName: "ellipsis") }
            }.frame(width: 44, height: 44)
        }
        .accessibilityLabel(radarText("工作台操作"))
        .accessibilityIdentifier("collie-radar-actions")
    }
}

struct CollieRadarView: View {
    @Bindable var store: CollieRadarStore
    let id: UUID
    @Bindable var presentation: CollieRadarPresentation

    private var record: CollieRadarWorkbench? { store.workbenches.first { $0.id == id } }

    var body: some View {
        Group {
            if let record {
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField(radarText("搜索项目与待办"), text: searchBinding)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("collie-radar-search")
                        if !(record.display.searchText ?? "").isEmpty {
                            Button { searchBinding.wrappedValue = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .frame(minWidth: 44, minHeight: 44)
                            }
                            .accessibilityLabel(radarText("清空搜索"))
                        }
                    }
                    .padding(12)
                    .background(BenchsideStyle.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    ScrollView {
                        VStack(alignment: .leading, spacing: record.display.compact ? 12 : 20) {
                            Picker(radarText("视图"), selection: pageBinding) {
                                Text(radarText("总览")).tag(CollieRadarDisplay.Page.overview)
                                Text(radarText("项目")).tag(CollieRadarDisplay.Page.projects)
                                Text(radarText("全部任务")).tag(CollieRadarDisplay.Page.tasks)
                                Text(radarText("待我处理")).tag(CollieRadarDisplay.Page.actions)
                            }
                            .pickerStyle(.segmented)
                            .accessibilityIdentifier("collie-radar-page")
                            if let error = store.errors[id] {
                                Label(error, systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.orange).font(.footnote)
                            }
                            if let snapshot = store.snapshots[id] {
                                snapshotContent(snapshot, display: record.display)
                            } else {
                                ContentUnavailableView {
                                    Label("PM Radar", systemImage: "scope")
                                } description: {
                                    Text(radarText("导入 pm-radar --json 快照，或设置你自己的 HTTPS JSON 数据源。不会自动连接开发者的私人台账。"))
                                } actions: {
                                    Button(radarText("导入快照")) { presentation.importing = true }
                                        .buttonStyle(.borderedProminent)
                                    Button(radarText("配置数据源")) { presentation.configuring = true }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(BenchsideStyle.canvas)
                    .refreshable { if !record.source.isEmpty { await store.refresh(id) } }
                }
                .sheet(isPresented: $presentation.configuring) { CollieRadarSettingsView(store: store, item: record) }
            }
        }
        .tint(BenchsideStyle.accent)
        .fileImporter(isPresented: $presentation.importing, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            do {
                guard let url = try result.get().first else { return }
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size <= CollieRadarSnapshot.maximumBytes else {
                    store.importSnapshot(Data(count: CollieRadarSnapshot.maximumBytes + 1), for: id)
                    return
                }
                let handle = try FileHandle(forReadingFrom: url)
                defer { try? handle.close() }
                let data = try handle.read(upToCount: CollieRadarSnapshot.maximumBytes + 1) ?? Data()
                store.importSnapshot(data, for: id)
            } catch {
                if (error as? CocoaError)?.code != .userCancelled { store.reportImportError(for: id) }
            }
        }
    }

    private var searchBinding: Binding<String> {
        Binding(get: { record?.display.searchText ?? "" }, set: { query in
            guard var item = record else { return }
            item.display.searchText = query.isEmpty ? nil : query
            store.update(item)
        })
    }

    private var pageBinding: Binding<CollieRadarDisplay.Page> {
        Binding(get: { record?.display.page ?? .overview }, set: { page in
            guard var item = record else { return }
            item.display.page = page
            store.update(item)
        })
    }

    @ViewBuilder
    private func snapshotContent(_ snapshot: CollieRadarSnapshot, display: CollieRadarDisplay) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(snapshot.date_str, systemImage: snapshot.isOutdated || snapshot.isFutureDated ? "clock.badge.exclamationmark" : "clock")
                .font(.caption).foregroundStyle(snapshot.isOutdated || snapshot.isFutureDated ? Color.orange : BenchsideStyle.secondary)
            if snapshot.isFutureDated {
                Text(radarText("快照时间在未来，请检查数据源的时间和时区。"))
                    .font(.footnote).foregroundStyle(.orange)
            }
            if snapshot.isOutdated {
                Text(radarText("快照已过期，请刷新或重新导入。"))
                    .font(.footnote).foregroundStyle(.orange)
            }
            if snapshot.tasks != nil {
                Text(radarText("任务状态来自台账原文；刷新重新读取配置的数据源。"))
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text(radarText("此快照未提供完整台账，只包含来源提供的待处理项。"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Text(radarText("代码更新时间仅供参考，不代表任务停工或完成。"))
                .font(.caption).foregroundStyle(.secondary)
        }
        Picker(radarText("筛选项目"), selection: projectBinding) {
            Text(radarText("所有项目")).tag("")
            ForEach(snapshot.projectNames, id: \.self) { key in
                Text(snapshot.projectName(key)).tag(key)
            }
            if !display.project.isEmpty, !snapshot.projectNames.contains(display.project) {
                Text(display.project).tag(display.project)
            }
        }
        .pickerStyle(.menu)
        Picker(radarText("筛选状态"), selection: statusBinding) {
            Text(radarText("所有状态")).tag("")
            ForEach(snapshot.allTaskStatuses, id: \.self) { status in
                Text(status).tag(status)
            }
            if let status = display.status, !status.isEmpty, !snapshot.allTaskStatuses.contains(status) {
                Text(status).tag(status)
            }
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("collie-radar-status-filter")
        if !display.project.isEmpty || !(display.status ?? "").isEmpty || !(display.searchText ?? "").isEmpty {
            Button(radarText("清空筛选")) {
                guard var item = record else { return }
                item.display.project = ""
                item.display.status = nil
                item.display.searchText = nil
                store.update(item)
            }
            .frame(minHeight: 44)
            .accessibilityIdentifier("collie-radar-clear-filters")
        }

        let tasks = snapshot.matchingActions(display: display, includeAllTasks: true)
        let actions = display.page == .tasks || display.page == .projects
            ? tasks : snapshot.matchingActions(display: display)
        let keys = snapshot.matchingProjectNames(display: display)
        let projects = snapshot.matchingProjects(display: display)
            .enumerated().sorted { lhs, rhs in
                if display.newestFirst, lhs.element.timestamp != rhs.element.timestamp {
                    return lhs.element.timestamp > rhs.element.timestamp
                }
                let order = lhs.element.name.localizedCompare(rhs.element.name)
                return order == .orderedSame ? lhs.offset < rhs.offset : order == .orderedAscending
            }.map(\.element)

        if display.page == .overview {
            HStack(spacing: 12) {
                metric(radarText("待我处理"), count: actions.count, icon: "hand.raised")
                metric(radarText("全部任务"), count: tasks.count, icon: "checklist")
                metric(radarText("项目"), count: keys.count, icon: "square.stack.3d.up")
            }
        }
        if display.page != .projects {
            Text(radarText(display.page == .tasks ? "全部任务" : "待我处理")).font(.headline)
            if actions.isEmpty {
                Text(radarText(display.page == .tasks ? "这份快照中没有匹配的任务。" : "这份快照中没有匹配的待处理项。"))
                    .foregroundStyle(.secondary)
            }
            LazyVStack(spacing: display.compact ? 8 : 12) {
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    actionCard(action, snapshot: snapshot, display: display)
                }
            }
        }
        if display.page == .projects {
            groupedProjects(snapshot, keys: keys, actions: actions, display: display)
        }
        if display.page == .overview, display.showActivity,
           snapshot.tasks == nil || !snapshot.projects.isEmpty {
            Text(radarText("代码动态")).font(.headline)
            if projects.isEmpty { Text(radarText("这份快照中没有匹配的项目记录。")).foregroundStyle(.secondary) }
            LazyVStack(spacing: display.compact ? 8 : 12) {
                ForEach(Array(projects.enumerated()), id: \.offset) { _, project in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(project.name).font(.headline)
                        if display.showStatus { projectTaskStatuses(snapshot, key: project.path) }
                        Text(project.message).font(.subheadline).foregroundStyle(.secondary)
                        Text(Date(timeIntervalSince1970: project.timestamp), style: .date)
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(display.compact ? 12 : 16)
                    .background(BenchsideStyle.surfaceRaised, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private func groupedProjects(_ snapshot: CollieRadarSnapshot, keys: [String],
                                 actions: [CollieRadarSnapshot.Action], display: CollieRadarDisplay) -> some View {
        let grouped = Dictionary(grouping: actions, by: \.project)
        let activity = Dictionary(snapshot.projects.map { ($0.path, $0) },
                                  uniquingKeysWith: { lhs, rhs in lhs.timestamp >= rhs.timestamp ? lhs : rhs })
        return LazyVStack(alignment: .leading, spacing: 16) {
            if keys.isEmpty { Text(radarText("这份快照中没有匹配的项目记录。")).foregroundStyle(.secondary) }
            ForEach(keys, id: \.self) { key in
                VStack(alignment: .leading, spacing: 12) {
                    Text(snapshot.projectName(key)).font(.title3.bold())
                    if display.showStatus { projectTaskStatuses(snapshot, key: key) }
                    if display.showActivity, let project = activity[key] {
                        Label(project.message, systemImage: "arrow.triangle.branch")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    let actions = grouped[key] ?? []
                    if actions.isEmpty { Text(radarText("这份快照中没有匹配的任务。")).font(.footnote).foregroundStyle(.secondary) }
                    ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                        actionCard(action, snapshot: snapshot, display: display)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(BenchsideStyle.accent.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    private var projectBinding: Binding<String> {
        Binding(get: { record?.display.project ?? "" }, set: { project in
            guard var item = record else { return }
            item.display.project = project
            store.update(item)
        })
    }

    private var statusBinding: Binding<String> {
        Binding(get: { record?.display.status ?? "" }, set: { status in
            guard var item = record else { return }
            item.display.status = status.isEmpty ? nil : status
            store.update(item)
        })
    }

    private func metric(_ title: String, count: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon).font(.caption).foregroundStyle(.secondary)
            Text(count, format: .number).font(.title.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(BenchsideStyle.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func projectTaskStatuses(_ snapshot: CollieRadarSnapshot, key: String) -> some View {
        let statuses = snapshot.taskStatuses(for: key)
        if statuses.isEmpty { taskStatus("") }
        ForEach(statuses, id: \.self) { taskStatus($0) }
    }

    private func taskStatus(_ status: String) -> some View {
        let state = CollieRadarTaskState.classify(status)
        let text = status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? radarText("任务状态未提供") : status
        return Label(text, systemImage: state.icon)
            .font(.caption)
            .foregroundStyle(state == .blocked ? Color.orange : state == .progressing ? BenchsideStyle.accent : BenchsideStyle.secondary)
    }

    private func actionCard(_ action: CollieRadarSnapshot.Action, snapshot: CollieRadarSnapshot,
                            display: CollieRadarDisplay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(snapshot.projectName(action.project)).font(.caption).foregroundStyle(.secondary)
                Spacer()
                if display.showStatus { taskStatus(action.status ?? "") }
            }
            Text(action.title).font(.headline)
            if display.showNext, !action.next.isEmpty { Text(action.next).font(.subheadline).foregroundStyle(.secondary) }
            if let priority = action.priority, !priority.isEmpty {
                Text(priority).font(.caption).foregroundStyle(.secondary)
            }
            if let window = action.window_status, !window.isEmpty {
                Label(radarText("窗口状态") + "：" + window, systemImage: "macwindow")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let session = action.session, !session.isEmpty, !display.compact {
                Text(radarText("负责会话") + "：" + session).font(.caption).foregroundStyle(.secondary)
            }
            if let evidence = action.evidence, !evidence.isEmpty, !display.compact {
                Text(radarText("证据") + "：" + evidence).font(.caption).foregroundStyle(.secondary)
            }
            if let parts = URLComponents(string: action.url), parts.scheme?.lowercased() == "https",
               parts.host?.isEmpty == false, parts.user == nil, parts.password == nil,
               let url = parts.url {
                Link(radarText("查看原条目"), destination: url).font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(display.compact ? 12 : 16)
        .background(BenchsideStyle.surfaceRaised, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CollieRadarSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let store: CollieRadarStore
    @State var item: CollieRadarWorkbench
    @State private var saveFailed = false

    var body: some View {
        NavigationStack {
            Form {
                Section(radarText("工作台")) {
                    TextField(radarText("名称"), text: $item.name)
                    Toggle(radarText("收藏工作台"), isOn: $item.favorite)
                }
                Section {
                    TextField("https://example.com/pm/radar.json", text: $item.source)
                        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                    if !item.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                       CollieRadarFeed.validate(item.source) == nil {
                        Text(radarText("请输入不含账号、参数或密钥的 HTTPS JSON 地址。"))
                            .foregroundStyle(.red).font(.footnote)
                    }
                } header: { Text(radarText("数据源")) } footer: {
                    Text(radarText("支持完整台账快照及旧 pm-radar --json 格式。可配置自己的 Tailnet HTTPS JSON 路径；需要手机登录的数据源暂请导出后导入。不会复制网页 Cookie 或转发凭据。"))
                }
                if saveFailed {
                    Section {
                        Text(store.errors[item.id] ?? radarText("设置未保存，请稍后重试。"))
                            .foregroundStyle(.orange)
                    }
                }
                Section(radarText("显示")) {
                    Toggle(radarText("紧凑布局"), isOn: $item.display.compact)
                    Toggle(radarText("显示状态"), isOn: $item.display.showStatus)
                    Toggle(radarText("显示下一步"), isOn: $item.display.showNext)
                    Toggle(radarText("显示代码动态"), isOn: $item.display.showActivity)
                    Toggle(radarText("最近更新优先"), isOn: $item.display.newestFirst)
                }
            }
            .navigationTitle(radarText("显示与数据源"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(radarText("取消")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(radarText("保存")) {
                        item.name = String(item.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(48))
                        if store.update(item) { dismiss() }
                        else { saveFailed = true }
                    }
                    .disabled(item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              (!item.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                               CollieRadarFeed.validate(item.source) == nil))
                }
            }
        }
    }
}
