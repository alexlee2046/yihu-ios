import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { createHash } from 'node:crypto';

// SYNTHETIC_EXAMPLE: source expressions and data invariants, not a JS model/identity engine.
const sourceFragments = {
  "func radarText(_ key: String)": {
    "path": "Apps/Collie/CollieRadarModel.swift",
    "text": "func radarText(_ key: String) -> String {\n    NSLocalizedString(key, tableName: \"Yihu\", comment: \"\")\n}",
    "sha256": "491af295f390ea8c23d04f621747e6b1cbffc5b007fad08a9682d526f72598af"
  },
  "struct CollieRadarSnapshot:": {
    "path": "Apps/Collie/CollieRadarModel.swift",
    "text": "struct CollieRadarSnapshot: Codable, Sendable {\n    struct Action: Codable, Identifiable, Sendable {\n        var project: String\n        var status: String?\n        var title: String\n        var next: String\n        var url: String\n        var timestamp: Double? = nil\n        var id: String? = nil\n        var priority: String? = nil\n        var evidence: String? = nil\n        var session: String? = nil\n        var window_status: String? = nil\n\n        var requiresMyAttention: Bool {\n            let trimmed = status?.trimmingCharacters(in: .whitespacesAndNewlines) ?? \"\"\n            return [\"等你决策\", \"等你验收\"].contains(trimmed) || next.localizedStandardContains(\"Alex\")\n        }\n\n        var safeEvidenceURLs: [URL] {\n            Self.parseSafeEvidenceURLs(evidence)\n        }\n\n        static func parseSafeEvidenceURLs(_ raw: String?) -> [URL] {\n            guard let raw, !raw.isEmpty else { return [] }\n            let separators = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: \";,，；|\"))\n            var seen = Set<String>()\n            var urls: [URL] = []\n            for token in raw.components(separatedBy: separators) {\n                let candidate = token.trimmingCharacters(in: CharacterSet(charactersIn: \"()[]<>\\\"'\"))\n                guard !candidate.isEmpty,\n                      let parts = URLComponents(string: candidate),\n                      parts.scheme?.lowercased() == \"https\",\n                      let host = parts.host, !host.isEmpty,\n                      parts.user == nil, parts.password == nil,\n                      parts.port.map({ (1...65535).contains($0) }) ?? true,\n                      let url = parts.url,\n                      seen.insert(url.absoluteString).inserted else { continue }\n                urls.append(url)\n            }\n            return urls\n        }\n    }\n\n    struct Project: Codable, Sendable {\n        var name: String\n        var path: String\n        var timestamp: Double\n        var message: String\n        // Optional explicit task state; legacy code-activity feeds omit it.\n        var status: String? = nil\n    }\n\n    var date_str: String\n    var decisions: [Action]\n    var active: [Project]\n    var stale: [Project]\n    var cold: [Project]\n    // New ledger exports contain all tasks; legacy snapshots remain compatible.\n    var tasks: [Action]? = nil\n    var reply_supported: Bool? = nil\n    var source_refreshing: Bool? = nil\n    var source_refresh_failed: Bool? = nil\n    var colab: CollieColabSnapshot? = nil\n    var colab_unavailable: Bool? = nil\n    var allTasks: [Action] { tasks ?? decisions }\n\n    var projects: [Project] { active + stale + cold }\n    var projectNames: [String] {\n        Array(Set(allTasks.map(\\.project) + projects.map(\\.path))).sorted()\n    }\n    func projectName(_ key: String) -> String {\n        projects.first(where: { $0.path == key })?.name ?? key\n    }\n    var allTaskStatuses: [String] {\n        Array(Set((projects.compactMap(\\.status) + allTasks.compactMap(\\.status))\n            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }\n            .filter { !$0.isEmpty })).sorted()\n    }\n\n    func taskStatuses(for key: String, display: CollieRadarDisplay? = nil) -> [String] {\n        let records = display.map { matchingActions(display: $0, includeAllTasks: true) } ?? allTasks\n        let activity = display.map { matchingProjects(display: $0, matchingTasks: records) } ?? projects\n        let explicit = activity.filter { $0.path == key }.compactMap(\\.status)\n        return Array(Set(explicit + records.filter { $0.project == key }.compactMap(\\.status)))\n            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.sorted()\n    }\n\n    /// Build once per filtered presentation instead of filtering/sorting the ledger per card.\n    func taskStatusesByProject(actions: [Action], activity: [Project]) -> [String: [String]] {\n        var statuses: [String: Set<String>] = [:]\n        for (key, status) in actions.map({ ($0.project, $0.status) }) + activity.map({ ($0.path, $0.status) }) {\n            guard let status, !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }\n            statuses[key, default: []].insert(status)\n        }\n        return statuses.mapValues { $0.sorted() }\n    }\n\n    func sortedProjectNames(newestFirst: Bool) -> [String] {\n        let timestamps = Dictionary(projects.map { ($0.path, $0.timestamp) } +\n                                    allTasks.map { ($0.project, $0.timestamp ?? 0) },\n                                    uniquingKeysWith: { max($0, $1) })\n        let names = Dictionary(projects.map { ($0.path, $0.name) }, uniquingKeysWith: { first, _ in first })\n        return projectNames.sorted { lhs, rhs in\n            if newestFirst, timestamps[lhs, default: 0] != timestamps[rhs, default: 0] {\n                return timestamps[lhs, default: 0] > timestamps[rhs, default: 0]\n            }\n            let order = (names[lhs] ?? lhs).localizedCompare(names[rhs] ?? rhs)\n            return order == .orderedSame ? lhs < rhs : order == .orderedAscending\n        }\n    }\n    func matchingActions(display: CollieRadarDisplay, includeAllTasks: Bool = false) -> [Action] {\n        let records = (includeAllTasks || display.onlyMentioningMe == true) ? allTasks : decisions\n        let names = Dictionary(projects.map { ($0.path, $0.name) }, uniquingKeysWith: { first, _ in first })\n        let filtered = records.enumerated().filter {\n            (display.project.isEmpty || $0.element.project == display.project) &&\n            matchesStatus($0.element.status, filter: display.status) &&\n            (display.showHistory == true || !isHistorical($0.element.status)) &&\n            (display.onlyMentioningMe != true || $0.element.requiresMyAttention) &&\n            (display.priority?.isEmpty != false || $0.element.priority == display.priority) &&\n            matches([names[$0.element.project] ?? $0.element.project, $0.element.project, $0.element.title,\n                     $0.element.status ?? \"\", $0.element.next, $0.element.priority ?? \"\",\n                     $0.element.evidence ?? \"\", $0.element.session ?? \"\", $0.element.window_status ?? \"\"],\n                    query: display.searchText)\n        }\n        let incompleteRanks = Set(filtered.filter { $0.element.timestamp == nil }.map {\n            display.priorityFirst != false ? priorityRank($0.element.priority) : 0\n        })\n        return filtered.sorted { lhs, rhs in\n            if display.priorityFirst != false {\n                let left = priorityRank(lhs.element.priority), right = priorityRank(rhs.element.priority)\n                if left != right { return left < right }\n            }\n            if display.newestFirst {\n                let rank = display.priorityFirst != false ? priorityRank(lhs.element.priority) : 0\n                guard !incompleteRanks.contains(rank) else { return lhs.offset < rhs.offset }\n                let left = lhs.element.timestamp ?? 0, right = rhs.element.timestamp ?? 0\n                return left == right ? lhs.offset < rhs.offset : left > right\n            }\n            let order = lhs.element.title.localizedCompare(rhs.element.title)\n            return order == .orderedSame ? lhs.offset < rhs.offset : order == .orderedAscending\n        }.map(\\.element)\n    }\n\n    func matchingProjects(display: CollieRadarDisplay, matchingTasks: [Action]? = nil) -> [Project] {\n        let actionProjects = Set((matchingTasks ?? matchingActions(display: display, includeAllTasks: true)).map(\\.project))\n        return projects.filter {\n            (display.project.isEmpty || $0.path == display.project) &&\n            (display.showHistory == true || !isHistorical($0.status)) &&\n            (display.onlyMentioningMe != true || actionProjects.contains($0.path)) &&\n            (display.priority?.isEmpty != false || actionProjects.contains($0.path)) &&\n            (matchesStatus($0.status, filter: display.status) || actionProjects.contains($0.path)) &&\n            matches([$0.name, $0.path, $0.message, $0.status ?? \"\"], query: display.searchText)\n        }\n    }\n\n    func matchingProjectNames(display: CollieRadarDisplay, matchingTasks: [Action]? = nil,\n                              matchingActivity: [Project]? = nil) -> [String] {\n        let tasks = matchingTasks ?? matchingActions(display: display, includeAllTasks: true)\n        let activity = matchingActivity ?? matchingProjects(display: display, matchingTasks: tasks)\n        let keys = Set(tasks.map(\\.project) + activity.map(\\.path))\n        return sortedProjectNames(newestFirst: display.newestFirst).filter { keys.contains($0) }\n    }\n\n    static let managementStatuses = [\"等你决策\", \"等你验收\", \"进行中\", \"待做\"]\n\n    var allPriorities: [String] {\n        Array(Set(allTasks.compactMap(\\.priority).filter { !$0.isEmpty })).sorted {\n            let lhs = priorityRank($0), rhs = priorityRank($1)\n            return lhs == rhs ? $0 < $1 : lhs < rhs\n        }\n    }\n\n    private func priorityRank(_ priority: String?) -> Int {\n        switch priority { case \"P0\": 0; case \"P1\": 1; case \"P2\": 2; default: 3 }\n    }\n\n    private func isHistorical(_ status: String?) -> Bool {\n        switch CollieRadarTaskState.classify(status ?? \"\") {\n        case .completed, .paused: true\n        default: false\n        }\n    }\n\n    private func matchesStatus(_ status: String?, filter: String?) -> Bool {\n        guard let filter, !filter.isEmpty else { return true }\n        return status?.trimmingCharacters(in: .whitespacesAndNewlines) == filter\n    }\n\n    private func matches(_ fields: [String], query: String?) -> Bool {\n        let query = (query ?? \"\").trimmingCharacters(in: .whitespacesAndNewlines)\n        return query.isEmpty || fields.contains { $0.localizedStandardContains(query) }\n    }\n\n    var generatedAt: Date? {\n        let formatter = DateFormatter()\n        formatter.locale = Locale(identifier: \"en_US_POSIX\")\n        formatter.calendar = Calendar(identifier: .gregorian)\n        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600)\n        formatter.dateFormat = \"yyyy-MM-dd HH:mm\"\n        formatter.isLenient = false\n        guard let date = formatter.date(from: date_str), formatter.string(from: date) == date_str else { return nil }\n        return date\n    }\n    var isFutureDated: Bool {\n        guard let generatedAt else { return false }\n        return generatedAt.timeIntervalSinceNow > 5 * 60\n    }\n    var isOutdated: Bool {\n        guard let generatedAt else { return true }\n        return Date().timeIntervalSince(generatedAt) > 24 * 3600\n    }\n\n    static let maximumBytes = 2 * 1024 * 1024\n    static func decode(_ data: Data) throws -> Self {\n        guard data.count <= maximumBytes else { throw CollieRadarError.tooLarge }\n        let snapshot = try JSONDecoder().decode(Self.self, from: data)\n        let validTimestamp: (Double) -> Bool = { $0.isFinite && (0...253_402_300_799).contains($0) }\n        let nonempty: (String) -> Bool = { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }\n        let identities = (snapshot.tasks ?? []).compactMap(\\.id)\n        guard snapshot.generatedAt != nil,\n              Set(identities).count == identities.count,\n              snapshot.projects.allSatisfy({ nonempty($0.path) && nonempty($0.name) && validTimestamp($0.timestamp) }),\n              (snapshot.decisions + snapshot.allTasks).allSatisfy({ nonempty($0.project) && nonempty($0.title) &&\n                  ($0.timestamp.map(validTimestamp) ?? true) }) else { throw CollieRadarError.invalidSnapshot }\n        guard snapshot.colab?.valid ?? true else { throw CollieRadarError.invalidSnapshot }\n        return snapshot\n    }\n}",
    "sha256": "56d96b815144f73978203067947cca526b3c66467dbd7e1891b4ee6decf02abd"
  },
  "enum CollieRadarTaskState": {
    "path": "Apps/Collie/CollieRadarModel.swift",
    "text": "enum CollieRadarTaskState {\n    case planned, progressing, waiting, blocked, completed, paused, unknown\n\n    static func classify(_ status: String) -> Self {\n        switch status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {\n        case \"待做\", \"待办\", \"todo\", \"not started\", \"not_started\": return .planned\n        case \"进行中\", \"推进中\", \"in progress\", \"in_progress\": return .progressing\n        case \"等你决策\", \"等你验收\", \"等你处理\", \"等人操作\", \"等待反馈\", \"待我处理\", \"waiting\", \"pending\": return .waiting\n        case \"真实阻塞\", \"阻塞\", \"已阻塞\", \"blocked\": return .blocked\n        case \"已完成\", \"完成\", \"done\", \"completed\": return .completed\n        case \"搁置\", \"已搁置\", \"paused\", \"on hold\": return .paused\n        default: return .unknown\n        }\n    }\n\n    var icon: String {\n        switch self {\n        case .planned: return \"circle.dashed\"\n        case .progressing: return \"arrow.right.circle\"\n        case .waiting: return \"hand.raised\"\n        case .blocked: return \"exclamationmark.octagon\"\n        case .completed: return \"checkmark.circle\"\n        case .paused: return \"pause.circle\"\n        case .unknown: return \"questionmark.circle\"\n        }\n    }\n}",
    "sha256": "94a11bceff105da2f0d501ddfdd41a39c45a9e576c511289d7c5eceb79e90ff9"
  },
  "struct CollieRadarDisplay:": {
    "path": "Apps/Collie/CollieRadarModel.swift",
    "text": "struct CollieRadarDisplay: Codable, Equatable {\n    enum Page: String, Codable, CaseIterable { case overview, projects, actions, tasks }\n    var page: Page = .overview\n    var project = \"\"\n    // Optional so existing saved views decode without a migration or reset.\n    var searchText: String? = nil\n    var status: String? = nil\n    var priority: String? = nil\n    var showHistory: Bool? = nil\n    var onlyMentioningMe: Bool? = nil\n    var priorityFirst: Bool? = nil\n    var compact = false\n    var showNext = true\n    var showStatus = true\n    var showActivity = true\n    var newestFirst = true\n}",
    "sha256": "f8cc271b4650ba38caf2a154207f42fa49bacafc32e78e9c4ab6e935cbb9b4bb"
  },
  "ui_status": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty\n            ? radarText(\"任务状态未提供\") : status",
    "sha256": "16e600e6dc589544aa49e540effe9c3c353388e795ef9805fae3b5f1529f8613"
  },
  "ui_priority": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.priority.flatMap { $0.isEmpty ? nil : $0 } ?? radarText(\"优先级待补\")",
    "sha256": "8eb3e0ca3a2cf921ff0ec6f0a9cfd55723b1fc519f77449b712e50b86bb6c8f9"
  },
  "ui_card_next": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.next.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty",
    "sha256": "0942de20e5f76f3a525c26b96409962d09c76467536c33cce0e011b8da8a6b11"
  },
  "ui_detail_next": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.next.isEmpty ? radarText(\"下一步待补\") : action.next",
    "sha256": "a065a36c12dfcb16bb651217bdb439e7ff2cbe73d329b53c1063fde997de3222"
  },
  "ui_session": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.session.flatMap { $0.isEmpty ? nil : $0 } ?? radarText(\"待补\")",
    "sha256": "a6dcd672eedcb089865f2d4d3d78ce4b0667e48d81ef70b25282be42263d809e"
  },
  "ui_window_status": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.window_status.flatMap { $0.isEmpty ? nil : $0 } ?? radarText(\"未提供\")",
    "sha256": "48924de581a77e81e9e6d856a95c2cdec02fc4b4a221abb0f1b7fe80a6960f8e"
  },
  "ui_evidence": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "action.evidence.flatMap { $0.isEmpty ? nil : $0 } ?? radarText(\"待补\")",
    "sha256": "28708a79ef8493fd2f7109a48b8e21a2344a655082a9f3d5d77b2e1001025a9b"
  },
  "ui_reply_visible": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "[\"等你决策\", \"等你验收\"].contains(action.status ?? \"\"), action.id != nil",
    "sha256": "1dad182f871ac0fc878ab7151bd1b44e160d85b3cd8ed6b98c529d888bfed5d5"
  },
  "ui_reply_disabled": {
    "path": "Apps/Collie/CollieRadarView.swift",
    "text": "snapshot.reply_supported != true || record?.source.isEmpty != false",
    "sha256": "83fcb7b8259e29364f6b1c148f770eed8b8ce69a99be611c3ef6f40215d31986"
  }
};
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => readFileSync(join(root, p), 'utf8');
const prefix = 'public/samples/p22-empty-field-display-defaults/';
const fixture = (lang) => JSON.parse(read(`${prefix}preflight.${lang}.json`));
const active = 'empty-field-display-defaults';
const retired = 'attention-filter-identity-boundaries';
const canonical = 'https://getyihu.com/';
const page = (lang, slug) => `src/pages/${lang === 'en' ? 'en/' : ''}guides/${slug}.md`;
const route = (lang, slug) => `${lang === 'en' ? 'en/' : ''}guides/${slug}/`;
const resources = ['preflight.zh.json', 'preflight.en.json', 'preflight-card.md'];

test('P22: original model and UI predicates remain fingerprinted to source, not a mirrored default-value repairer', () => {
  for (const [name, f] of Object.entries(sourceFragments)) {
    const raw = read(`../${f.path}`); let text;
    if (name.startsWith('ui_')) { assert.ok(raw.includes(f.text)); text = f.text; }
    else {
      const start = raw.indexOf(name); assert.ok(start >= 0);
      let i = raw.indexOf('{', start) + 1; let depth = 1;
      while (depth) { if (raw[i] === '{') depth++; else if (raw[i] === '}') depth--; i++; }
      text = raw.slice(start, i);
    }
    assert.equal(createHash('sha256').update(text).digest('hex'), f.sha256, name);
  }
});

for (const lang of ['zh', 'en']) {
  test(`P22 ${lang}: synthetic nil/blank/literal placeholders, rank, capability and derived attention stay distinct`, () => {
    const j = fixture(lang);
    assert.equal(j.classification, 'SYNTHETIC_EXAMPLE'); assert.equal(j.batch, 'SYN-EFD-43'); assert.equal(j.language, lang);
    assert.equal(j.source_commit, '521ca77e1cf5d827617ae8963c2fc4f6cc232b3f'); assert.equal(j.source_tree, '6a0828bbc0d8a0abd3cdba9c9563d24ca83db21b');
    assert.equal(j.is_app_import_schema, false); assert.equal(j.is_production_capture, false); assert.deepEqual(Object.values(j.runtime_checks), Array(10).fill('not_run'));
    assert.equal(j.source_contract.unknown_priority_rank, 3); assert.equal(j.source_contract.priority_fallback_does_not_assign_P2, true);
    assert.equal(j.source_contract.display_placeholders_do_not_mutate_source, true); assert.equal(j.source_contract.attention_does_not_grant_reply, true);
    for (const [group, count] of [['field_cases', 4], ['attention_cases', 8], ['reply_gate_cases', 9], ['sort_filter_cases', 9], ['decode_cases', 14], ['boundary_reviews', 4]]) {
      assert.equal(j[group].length, count); assert.equal(new Set(j[group].map((x) => x.id)).size, count);
    }
    const f = Object.fromEntries(j.field_cases.map((x) => [x.id, x]));
    assert.equal(f.F1.evidence, null); assert.equal(f.F3.evidence, '待补'); assert.equal(f.F1.expected.evidence, f.F3.expected.evidence);
    assert.equal(f.F2.expected.priority, ' '); assert.equal(f.F2.expected.status, '任务状态未提供');
    assert.equal(f.F2.expected.card_next, '下一步待补'); assert.equal(f.F2.expected.detail_next, ' ');
    const g = Object.fromEntries(j.reply_gate_cases.map((x) => [x.id, x]));
    assert.equal(g.G1.reply_supported, null); assert.equal(g.G2.reply_supported, false); assert.equal(g.G1.expected.ui_enabled, g.G2.expected.ui_enabled);
    assert.equal(g.G3.expected.ui_enabled, true); assert.equal(g.G5.expected.visible, false);
    assert.equal(g.G7.item_id, ''); assert.equal(g.G7.expected.visible, true);
    assert.equal(g.G8.source, 'not a URL'); assert.equal(g.G8.expected.ui_enabled, true);
    const a = Object.fromEntries(j.attention_cases.map((x) => [x.id, x]));
    assert.equal(a.A2.expected, true); assert.equal(a.A5.expected, false); assert.equal(a.A7.expected, true);
    const s = Object.fromEntries(j.sort_filter_cases.map((x) => [x.id, x]));
    assert.deepEqual(s.S2.expected, ['older', 'missing', 'newer']); assert.deepEqual(s.S3.expected, ['newer', 'older']);
    assert.deepEqual(s.S6.expected, []); assert.deepEqual(s.S8.expected, []); assert.deepEqual(s.S9.expected, ['waiting']);
  });
}

test('P22: bilingual machines preserve raw optional values and expectations, not translated protocol keys', () => {
  const normalize = (j) => { const v = structuredClone(j); delete v.language; for (const x of v.boundary_reviews) delete x.label; return v; };
  assert.deepEqual(normalize(fixture('zh')), normalize(fixture('en')));
});

test('P22: only active pair gets three public resources and accessible cases;180/150/30 and retirement preserved', () => {
  const walk = (dir) => readdirSync(join(root, dir), { withFileTypes: true }).flatMap((x) => x.isDirectory() ? walk(`${dir}/${x.name}`) : [`${dir}/${x.name}`]);
  const pages = walk('src/pages').filter((p) => /\.(astro|md)$/.test(p)); assert.equal(pages.length, 180);
  assert.equal(pages.filter((p) => /^---\n[\s\S]*?\nindexable: false\n[\s\S]*?---/.test(read(p))).length, 30);
  assert.deepEqual(readdirSync(join(root, prefix)).sort(), [...resources].sort()); const sitemap = read('public/sitemap.xml'); assert.equal((sitemap.match(/<loc>/g) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const a = read(page(lang, active)); const r = read(page(lang, retired));
    assert.ok(!a.split('---')[1].includes('indexable: false')); assert.ok(r.split('---')[1].includes('indexable: false'));
    assert.ok(sitemap.includes(canonical + route(lang, active))); assert.ok(!sitemap.includes(canonical + route(lang, retired)));
    assert.ok(a.includes('SYNTHETIC_EXAMPLE') && a.includes('SYN-EFD-43') && a.includes('role="region"') && a.includes('tabindex="0"'));
    for (const name of resources) assert.ok(a.includes(`/samples/p22-empty-field-display-defaults/${name}`));
    for (const group of ['field_cases', 'attention_cases', 'reply_gate_cases', 'sort_filter_cases', 'decode_cases', 'boundary_reviews']) for (const row of fixture(lang)[group]) assert.ok(a.includes(`| ${row.id} |`));
    assert.ok(r.includes(`](/${route(lang, active)})`)); assert.ok(!r.includes('/samples/p22-empty-field-display-defaults/'));
  }
});

test('P22: built sample bytes and original-generator LLMs include real active URLs, not retired standalone exports', { skip: !existsSync(join(root, 'dist/index.html')) }, () => {
  for (const name of resources) assert.equal(read(`dist/samples/p22-empty-field-display-defaults/${name}`), read(`${prefix}${name}`));
  const short = read('public/llms.txt'); const full = read('public/llms-full.txt'); assert.equal((full.match(/^Canonical: https:\/\/getyihu\.com\//gm) || []).length, 150);
  for (const lang of ['zh', 'en']) {
    const html = read(`dist/${route(lang, active)}index.html`); for (const name of resources) assert.ok(html.includes(`/samples/p22-empty-field-display-defaults/${name}`));
    for (const text of [short, full]) assert.ok(text.includes(`/samples/p22-empty-field-display-defaults/preflight.${lang}.json`));
    assert.ok(full.includes(`Canonical: ${canonical}${route(lang, active)}\n`)); assert.ok(!full.includes(`Canonical: ${canonical}${route(lang, retired)}\n`));
    assert.ok(!short.includes(`](${canonical}${route(lang, retired)})\n`)); const retiredHtml = read(`dist/${route(lang, retired)}index.html`);
    assert.ok(retiredHtml.includes('noindex,follow')); assert.ok(!retiredHtml.includes('/samples/p22-empty-field-display-defaults/'));
  }
});
