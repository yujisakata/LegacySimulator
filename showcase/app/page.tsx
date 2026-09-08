'use client';

import { ReactNode, useEffect, useMemo, useState } from 'react';

type EvidenceLine = { number: number; text: string };
type Evidence = {
  id: string;
  stage: string;
  label: string;
  path: string;
  start: number;
  actualEnd: number;
  note: string;
  viewType: 'code' | 'document';
  lines: EvidenceLine[];
};
type Constraint = { kind: string; text: string };
type DecisionOption = {
  id: string;
  label: string;
  benefit: string;
  concern: string;
  status: 'selected' | 'rejected';
  reason?: string;
};
type DecisionGroup = {
  title: string;
  question: string;
  options: DecisionOption[];
};
type VersionDetail = {
  headline: string;
  background: string;
  adoptionSummary: string;
  decisionGroups: DecisionGroup[];
};
type Version = {
  id: string;
  label: string;
  year: string;
  title: string;
  eyebrow: string;
  releaseWindow: string;
  testSummary: string;
  implementation: string;
  event: string;
  decision: string;
  rationale: string;
  impact: string;
  artifactState: string;
  knowledgeRisk: string;
  detail: VersionDetail;
  constraints: Constraint[];
  evidence: Evidence[];
};
type TestDefinition = { id: string; label: string; command: string };
type RoadmapRow = {
  id: string;
  version: string;
  year: string;
  businessRequirement: string;
  additionalRequirements: string[];
  summary: string;
  status: 'implemented' | 'scenario';
};
type ConstraintRoadmapRow = {
  id: string;
  version: string;
  year: string;
  technicalConstraints: string[];
  developmentState: string;
  developmentEnvironment: string;
  deliveryOperations: string;
};
type ComplexityEffects = {
  locate: number;
  analyze: number;
  modify: number;
  validate: number;
  confidence: number;
};
type ComplexityRoadmapRow = {
  id: string;
  version: string;
  year: string;
  featureCount: number;
  mdi: number;
  edgeHealth: number;
  targetEdgeHealth?: number;
  effects: ComplexityEffects;
  changeReason: string;
};
type DemoData = {
  generatedAt: string;
  repository: string;
  artifactCount: number;
  title: string;
  subtitle: string;
  roadmap: RoadmapRow[];
  constraintRoadmap: ConstraintRoadmapRow[];
  complexityRoadmap: ComplexityRoadmapRow[];
  versions: Version[];
  tests: TestDefinition[];
};
type TestResponse = {
  ok: boolean;
  exitCode: number;
  output: string;
  elapsedSeconds: number;
  label: string;
};

const tourSteps = [
  { label: '全体像', version: 'v1', target: 'story', evidence: '' },
  { label: '制約と判断', version: 'v2', target: 'constraints', evidence: '' },
  { label: '局所追加の実物', version: 'v2', target: 'evidence', evidence: 'v2-code-layout' },
  { label: '商品別複製', version: 'v3', target: 'evidence', evidence: 'v3-code-age' },
  { label: '動く証拠', version: 'v3', target: 'validation', evidence: '' },
];

const effectMetrics: { key: keyof ComplexityEffects; short: string; label: string }[] = [
  { key: 'locate', short: 'L', label: '特定' },
  { key: 'analyze', short: 'A', label: '分析' },
  { key: 'modify', short: 'M', label: '修正' },
  { key: 'validate', short: 'V', label: '検証' },
  { key: 'confidence', short: 'C', label: '確信' },
];

function lineClass(text: string) {
  if (text.includes(' ADD ') || text.includes('ADD START')) return 'source-add';
  if (text.includes(' DEL ') || text.includes('DEL ')) return 'source-del';
  if (/^\s*#|^\s*\*|^\s*\/\//.test(text)) return 'source-comment';
  if (/FR-V|BR-V|NFR-V|AC-V/.test(text)) return 'source-id';
  return '';
}

function formatGeneratedAt(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat('ja-JP', {
        dateStyle: 'medium',
        timeStyle: 'short',
      }).format(date);
}

function inlineContent(text: string): ReactNode[] {
  const tokens = text.split(/(\*\*[^*]+\*\*|`[^`]+`|\[[^\]]+\]\([^)]+\))/g);
  return tokens.filter(Boolean).map((token, index) => {
    if (token.startsWith('**') && token.endsWith('**')) {
      return <strong key={index}>{token.slice(2, -2)}</strong>;
    }
    if (token.startsWith('`') && token.endsWith('`')) {
      return <code key={index}>{token.slice(1, -1)}</code>;
    }
    const link = token.match(/^\[([^\]]+)\]\(([^)]+)\)$/);
    if (link) return <span className="doc-link" key={index}>{link[1]}</span>;
    return token;
  });
}

function DocumentView({ evidence }: { evidence: Evidence }) {
  const rows = evidence.lines.map((line) => line.text);
  const content: ReactNode[] = [];
  let index = 0;

  while (index < rows.length) {
    const raw = rows[index];
    const trimmed = raw.trim();
    if (!trimmed || /^---+$/.test(trimmed)) {
      index += 1;
      continue;
    }

    if (trimmed.startsWith('```')) {
      const code: string[] = [];
      index += 1;
      while (index < rows.length && !rows[index].trim().startsWith('```')) {
        code.push(rows[index]);
        index += 1;
      }
      index += 1;
      content.push(<pre className="doc-code" key={'code-' + index}>{code.join('\n')}</pre>);
      continue;
    }

    const heading = trimmed.match(/^(#{1,4})\s+(.+)$/);
    if (heading) {
      const level = heading[1].length;
      const label = heading[2].replace(/\*\*/g, '');
      if (level === 1) content.push(<h1 key={'h-' + index}>{label}</h1>);
      else if (level === 2) content.push(<h2 key={'h-' + index}>{label}</h2>);
      else content.push(<h3 key={'h-' + index}>{label}</h3>);
      index += 1;
      continue;
    }

    if (trimmed.startsWith('|') && rows[index + 1]?.includes('---')) {
      const tableRows: string[][] = [];
      while (index < rows.length && rows[index].trim().startsWith('|')) {
        const cells = rows[index].trim().replace(/^\||\|$/g, '').split('|').map((cell) => cell.trim());
        if (!cells.every((cell) => /^:?-+:?$/.test(cell))) tableRows.push(cells);
        index += 1;
      }
      const [header, ...body] = tableRows;
      content.push(
        <div className="doc-table-wrap" key={'table-' + index}>
          <table>
            <thead><tr>{header.map((cell, cellIndex) => <th key={cellIndex}>{inlineContent(cell)}</th>)}</tr></thead>
            <tbody>{body.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, cellIndex) => <td key={cellIndex}>{inlineContent(cell)}</td>)}</tr>)}</tbody>
          </table>
        </div>,
      );
      continue;
    }

    if (/^[*-]\s+/.test(trimmed)) {
      const items: string[] = [];
      while (index < rows.length && /^\s*[*-]\s+/.test(rows[index])) {
        items.push(rows[index].replace(/^\s*[*-]\s+/, ''));
        index += 1;
      }
      content.push(<ul key={'list-' + index}>{items.map((item, itemIndex) => <li key={itemIndex}>{inlineContent(item)}</li>)}</ul>);
      continue;
    }

    const paragraph: string[] = [trimmed];
    index += 1;
    while (
      index < rows.length && rows[index].trim() &&
      !/^(#{1,4})\s+/.test(rows[index].trim()) &&
      !rows[index].trim().startsWith('|') &&
      !/^\s*[*-]\s+/.test(rows[index]) &&
      !rows[index].trim().startsWith('```')
    ) {
      paragraph.push(rows[index].trim());
      index += 1;
    }
    content.push(<p key={'p-' + index}>{inlineContent(paragraph.join(' '))}</p>);
  }

  return <article className="document-view"><div className="document-paper">{content}</div></article>;
}

export default function Home() {
  const [data, setData] = useState<DemoData | null>(null);
  const [selectedId, setSelectedId] = useState('v2');
  const [detailVersionId, setDetailVersionId] = useState('');
  const [evidence, setEvidence] = useState<Evidence | null>(null);
  const [tourIndex, setTourIndex] = useState(-1);
  const [runningTest, setRunningTest] = useState('');
  const [testResult, setTestResult] = useState<TestResponse | null>(null);
  const [loadError, setLoadError] = useState('');

  useEffect(() => {
    fetch('/demo-data.json', { cache: 'no-store' })
      .then((response) => {
        if (!response.ok) throw new Error('証拠データを読み込めませんでした。');
        return response.json() as Promise<DemoData>;
      })
      .then(setData)
      .catch((error: Error) => setLoadError(error.message));
  }, []);

  const selected = useMemo(
    () => data?.versions.find((version) => version.id === selectedId),
    [data, selectedId],
  );
  const detailVersion = useMemo(
    () => data?.versions.find((version) => version.id === detailVersionId),
    [data, detailVersionId],
  );

  function selectVersion(id: string) {
    setSelectedId(id);
    setEvidence(null);
  }

  function openVersionDetail(id: string) {
    setSelectedId(id);
    setDetailVersionId(id);
    setEvidence(null);
    window.setTimeout(() => {
      document.getElementById('timeline-detail')?.scrollIntoView({
        behavior: 'smooth',
        block: 'center',
      });
    }, 80);
  }

  function runTourStep(index: number) {
    if (!data) return;
    const normalized = Math.max(0, Math.min(index, tourSteps.length - 1));
    const step = tourSteps[normalized];
    setTourIndex(normalized);
    setSelectedId(step.version);
    setEvidence(null);
    window.setTimeout(() => {
      const version = data.versions.find((item) => item.id === step.version);
      const selectedEvidence = version?.evidence.find(
        (item) => item.id === step.evidence,
      );
      if (selectedEvidence) setEvidence(selectedEvidence);
      document.getElementById(step.target)?.scrollIntoView({
        behavior: 'smooth',
        block: 'start',
      });
    }, 80);
  }

  async function executeTest(test: TestDefinition) {
    setRunningTest(test.id);
    setTestResult(null);
    try {
      const apiUrl = `http://${window.location.hostname}:4311/api/run-test`;
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: test.id }),
      });
      const result = (await response.json()) as TestResponse;
      if (!response.ok) throw new Error('検証APIが要求を受理できませんでした。');
      setTestResult(result);
    } catch {
      setTestResult({
        ok: false,
        exitCode: -1,
        elapsedSeconds: 0,
        label: test.label,
        output:
          'ライブ検証APIへ接続できません。start-demo.ps1から起動してください。',
      });
    } finally {
      setRunningTest('');
    }
  }

  if (loadError) {
    return <main className="fatal"><h1>{loadError}</h1></main>;
  }
  if (!data || !selected) {
    return <main className="loading"><span />実物証拠を読み込んでいます…</main>;
  }

  return (
    <main>
      <header className="topbar">
        <a className="brand" href="#top" aria-label="Legacy Evolution">
          <span className="brand-mark">LE</span>
          <span>
            <strong>LEGACY EVOLUTION</strong>
            <small>Evidence-guided system history</small>
          </span>
        </a>
        <nav className="topnav" aria-label="ページ内ナビゲーション">
          <a href="#requirements-map">V1–V10一覧</a>
          <a href="#constraint-map">制約一覧</a>
          <a href="#complexity-map">複雑度</a>
          <a href="#story">変化を辿る</a>
          <a href="#evidence">実物を見る</a>
          <a href="#validation">検証する</a>
        </nav>
        <button className="tour-start" onClick={() => runTourStep(0)}>
          7分ガイドを開始
        </button>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy-block">
          <p className="kicker">BUSINESS × CONSTRAINT × IMPLEMENTATION</p>
          <h1>実物で辿る、<br />業務変更とシステム進化。</h1>
          <p className="hero-copy">
            当時の要求と制約、その判断が要件・設計・COBOL・テストへ
            どう接続されたかを、リポジトリの証拠から読み解きます。
          </p>
        </div>
        <aside className="repo-stamp">
          <span className="pulse" />
          <p>LIVE WORKSPACE SNAPSHOT</p>
          <strong>{data.repository}</strong>
          <dl>
            <div><dt>収録Version</dt><dd>{data.versions.length}</dd></div>
            <div><dt>対象成果物</dt><dd>{data.artifactCount}</dd></div>
          </dl>
          <small>更新 {formatGeneratedAt(data.generatedAt)}</small>
        </aside>
      </section>

      {tourIndex >= 0 && (
        <section className="tourbar" aria-label="ガイド進行">
          <button
            className="tour-close"
            onClick={() => setTourIndex(-1)}
            aria-label="ガイドを閉じる"
          >×</button>
          <span>GUIDED TOUR</span>
          <div className="tour-steps">
            {tourSteps.map((step, index) => (
              <button
                key={step.label}
                className={tourIndex === index ? 'current' : ''}
                onClick={() => runTourStep(index)}
              >
                <i>{index + 1}</i>{step.label}
              </button>
            ))}
          </div>
          <button
            className="tour-next"
            disabled={tourIndex === tourSteps.length - 1}
            onClick={() => runTourStep(tourIndex + 1)}
          >次へ →</button>
        </section>
      )}

      <section className="timeline-section" aria-label="Version timeline">
        <div className="timeline-line" />
        <div className="timeline">
          {data.versions.map((version) => (
            <button
              className={selected.id === version.id ? 'version active' : 'version'}
              key={version.id}
              onClick={() => openVersionDetail(version.id)}
              aria-pressed={selected.id === version.id}
            >
              <span className="version-dot" />
              <small>{version.year}</small>
              <strong>{version.label}</strong>
              <em>{version.title}</em>
              <span className="version-action">クリックで詳細を見る →</span>
            </button>
          ))}
        </div>
        {detailVersion && (
          <article className="timeline-detail" id="timeline-detail" key={detailVersion.id}>
            <header>
              <div>
                <p>{detailVersion.year} / {detailVersion.label} DECISION RECORD</p>
                <h2>{detailVersion.detail.headline}</h2>
              </div>
              <button onClick={() => setDetailVersionId('')} aria-label="詳細を閉じる">×</button>
            </header>
            <div className="detail-context">
              <div>
                <span>背景・前提</span>
                <p>{detailVersion.detail.background}</p>
              </div>
              <div className="adoption-summary">
                <span>最終決定</span>
                <p>{detailVersion.detail.adoptionSummary}</p>
              </div>
            </div>
            <div className="decision-groups">
              {detailVersion.detail.decisionGroups.map((group, groupIndex) => (
                <section key={group.title}>
                  <div className="decision-heading">
                    <span>DECISION {String(groupIndex + 1).padStart(2, '0')}</span>
                    <h3>{group.title}</h3>
                    <p>{group.question}</p>
                  </div>
                  <div className="option-grid">
                    {group.options.map((option) => (
                      <article className={option.status === 'selected' ? 'option selected' : 'option'} key={option.id}>
                        <header>
                          <i>案{option.id}</i>
                          <span>{option.status === 'selected' ? '採用' : '不採用'}</span>
                        </header>
                        <h4>{option.label}</h4>
                        <dl>
                          <div><dt>利点</dt><dd>{option.benefit}</dd></div>
                          <div><dt>懸念</dt><dd>{option.concern}</dd></div>
                        </dl>
                        {option.reason && <p className="selection-reason"><strong>選んだ理由</strong>{option.reason}</p>}
                      </article>
                    ))}
                  </div>
                </section>
              ))}
            </div>
            <footer>
              <span>記録に残る検討案をすべて表示</span>
              <button onClick={() => setEvidence(detailVersion.evidence.find((item) => item.stage === '設計判断') ?? null)}>
                設計検討記録を文書で開く →
              </button>
            </footer>
          </article>
        )}
      </section>

      <section className="requirement-map anchor" id="requirements-map">
        <div className="section-heading with-side">
          <div>
            <p>01 / V1–V10 REQUIREMENT MAP</p>
            <h2>事業要求から、追加要件と実現方式を俯瞰する。</h2>
          </div>
          <div className="map-legend" aria-label="整備状況の凡例">
            <span><i className="implemented" />実物成果物あり</span>
            <span><i className="scenario" />進化シナリオ</span>
          </div>
        </div>
        <div className="requirement-table-wrap">
          <table className="requirement-table">
            <thead>
              <tr>
                <th>Version</th>
                <th>事業要求</th>
                <th>追加要件</th>
                <th>概要・実現方式</th>
              </tr>
            </thead>
            <tbody>
              {data.roadmap.map((row) => (
                <tr key={row.id} className={row.status === 'implemented' ? 'implemented-row' : ''}>
                  <th scope="row">
                    {row.status === 'implemented' ? (
                      <button onClick={() => openVersionDetail(row.id)}>
                        <strong>{row.version}</strong><small>{row.year}</small>
                      </button>
                    ) : (
                      <span><strong>{row.version}</strong><small>{row.year}</small></span>
                    )}
                    <em>{row.status === 'implemented' ? '実物あり' : 'シナリオ'}</em>
                  </th>
                  <td>{row.businessRequirement}</td>
                  <td>
                    <ul>{row.additionalRequirements.map((item) => <li key={item}>{item}</li>)}</ul>
                  </td>
                  <td>{row.summary}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p className="map-footnote">
          V1～V10の各行から、要件・設計・実装・テストの実ファイルと設計判断を開けます。
          Java世代のコンパイル実施状況はVersion別テスト成績に明記しています。
        </p>
      </section>

      <section className="constraint-map anchor" id="constraint-map">
        <div className="section-heading with-side">
          <div>
            <p>02 / V1–V10 CONSTRAINT MAP</p>
            <h2>技術だけでなく、開発状態と環境が選択肢を決める。</h2>
          </div>
          <p className="section-note">
            技術プロファイルとVersionシナリオから、各時点で変更を制約した条件を分類しています。
          </p>
        </div>
        <div className="era-strip" aria-label="システム世代区分">
          <div><span>V1–V4</span><strong>MAINFRAME</strong><small>単一基盤から制度ロジック併存へ</small></div>
          <div><span>V5–V8</span><strong>HYBRID</strong><small>Java段階移行と外部連携の拡大</small></div>
          <div><span>V9–V10</span><strong>MULTI-GENERATION</strong><small>多世代監査から知識復元へ</small></div>
        </div>
        <div className="constraint-table-wrap">
          <table className="constraint-table">
            <thead>
              <tr>
                <th>Version</th>
                <th>技術的制約</th>
                <th>開発状態</th>
                <th>開発環境・体制</th>
                <th>納期・運用条件</th>
              </tr>
            </thead>
            <tbody>
              {data.constraintRoadmap.map((row, index) => {
                const era = index < 4 ? 'mainframe' : index < 8 ? 'hybrid' : 'multi';
                return (
                  <tr key={row.id} className={'constraint-era-' + era}>
                    <th scope="row">
                      <strong>{row.version}</strong>
                      <small>{row.year}</small>
                      <em>{era === 'mainframe' ? 'MF' : era === 'hybrid' ? 'HYBRID' : 'MULTI'}</em>
                    </th>
                    <td><ul>{row.technicalConstraints.map((item) => <li key={item}>{item}</li>)}</ul></td>
                    <td><strong className="development-state">{row.developmentState}</strong></td>
                    <td>{row.developmentEnvironment}</td>
                    <td>{row.deliveryOperations}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <p className="map-footnote">
          分類根拠：<code>technical_constraints/version_profiles.yml</code> と
          <code>scenario/version_timeline.yml</code>
        </p>
      </section>

      <section className="complexity-map anchor" id="complexity-map">
        <div className="section-heading with-side">
          <div>
            <p>03 / COMPLEXITY METRICS</p>
            <h2>複雑度の値と、前Versionから増減した理由。</h2>
          </div>
          <p className="section-note">
            コード量だけでなく、変更箇所の特定から情報確信度までを、教材用の複数指標で比較します。
          </p>
        </div>
        <div className="metric-guide">
          <article><span>FEATURE</span><strong>実装機能数</strong><p>システムが提供する機能の規模</p></article>
          <article><span>MDI</span><strong>変更の総困難度</strong><p>V1を10とした教材用の総合値</p></article>
          <article><span>EDGE HEALTH</span><strong>知識接続の健全度</strong><p>100に近いほど要求から試験まで説明可能</p></article>
          <article><span>5D EFFECT</span><strong>当該Versionの影響</strong><p>＋は困難度増、－は回復施策による低減</p></article>
        </div>
        <div className="complexity-table-wrap">
          <table className="complexity-table">
            <thead>
              <tr>
                <th>Version</th>
                <th>機能数</th>
                <th>MDI</th>
                <th>知識接続</th>
                <th>5次元への影響</th>
                <th>前Versionと比べた変化理由</th>
              </tr>
            </thead>
            <tbody>
              {data.complexityRoadmap.map((row, index) => {
                const previous = data.complexityRoadmap[index - 1];
                const mdiDelta = previous ? row.mdi - previous.mdi : 0;
                const featureDelta = previous ? row.featureCount - previous.featureCount : 0;
                const edgeDelta = previous ? row.edgeHealth - previous.edgeHealth : 0;
                return (
                  <tr key={row.id} className={row.id === 'v10' ? 'recovery-row' : ''}>
                    <th scope="row"><strong>{row.version}</strong><small>{row.year}</small></th>
                    <td className="metric-number">
                      <strong>{row.featureCount}</strong>
                      <small>{previous ? `＋${featureDelta}` : '基準'}</small>
                    </td>
                    <td className="mdi-cell">
                      <div><strong>{row.mdi}</strong><small>{previous ? `＋${mdiDelta}` : '基準'}</small></div>
                      <span><i style={{ width: `${(row.mdi / 240) * 100}%` }} /></span>
                      {row.id === 'v10' && <em>回復開始時</em>}
                    </td>
                    <td className="edge-cell">
                      <div>
                        <strong>{row.edgeHealth}</strong>
                        {row.targetEdgeHealth && <><b>→</b><strong>{row.targetEdgeHealth}</strong></>}
                      </div>
                      <span><i style={{ width: `${row.targetEdgeHealth ?? row.edgeHealth}%` }} /></span>
                      <small>
                        {row.targetEdgeHealth ? `回復目標 ＋${row.targetEdgeHealth - row.edgeHealth}` : previous ? `${edgeDelta}` : '基準'}
                      </small>
                    </td>
                    <td>
                      <div className="effect-grid">
                        {effectMetrics.map((metric) => {
                          const value = row.effects[metric.key];
                          const sign = value > 0 ? '+' : '';
                          return (
                            <span className={value < 0 ? 'effect-down' : value > 0 ? 'effect-up' : 'effect-flat'} key={metric.key} title={metric.label}>
                              <i>{metric.short}</i><strong>{sign}{value}</strong><small>{metric.label}</small>
                            </span>
                          );
                        })}
                      </div>
                    </td>
                    <td className="change-reason">{row.changeReason}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <div className="complexity-notes">
          <p><strong>5次元：</strong>L=変更箇所特定、A=影響分析、M=修正実行、V=退行検証、C=情報確信度・組織的エントロピー。</p>
          <p>MDIと機能数は概念設計の推移値、5次元は各Versionイベントの相対影響値の合計です。両者は同じ単位ではありません。V10のMDI 240は回復開始時点を表します。</p>
        </div>
      </section>

      <section className="story-section anchor" id="story">
        <div className="section-heading">
          <p>04 / CHANGE STORY</p>
          <h2>その判断は、当時の制約の中で合理的だった。</h2>
        </div>
        <div className="story-shell" key={selected.id}>
          <div className="story-index">{selected.label}</div>
          <article className="story-main">
            <div className="story-topline">
              <p className="eyebrow">{selected.eyebrow}</p>
              <span className={'risk risk-' + selected.knowledgeRisk.toLowerCase()}>
                KNOWLEDGE RISK {selected.knowledgeRisk}
              </span>
            </div>
            <h3>{selected.event}</h3>
            <div className="story-grid">
              <div>
                <span>当時の判断</span>
                <p>{selected.decision}</p>
              </div>
              <div>
                <span>判断理由</span>
                <p>{selected.rationale}</p>
              </div>
              <div className="impact-cell">
                <span>次へ持ち越したもの</span>
                <p>{selected.impact}</p>
              </div>
            </div>
          </article>
          <aside className="story-metrics">
            <div><small>DELIVERY</small><strong>{selected.releaseWindow}</strong></div>
            <div><small>IMPLEMENTATION</small><strong>{selected.implementation}</strong></div>
            <div><small>VERIFICATION</small><strong>{selected.testSummary}</strong></div>
            <p>{selected.artifactState}</p>
          </aside>
        </div>
      </section>

      <section className="constraints anchor" id="constraints">
        <div className="section-heading compact">
          <p>05 / CONSTRAINTS</p>
          <h2>判断を決めた、三つの現実。</h2>
        </div>
        <div className="constraint-grid">
          {selected.constraints.map((constraint, index) => (
            <article key={constraint.kind}>
              <span>0{index + 1}</span>
              <small>{constraint.kind}の制約</small>
              <p>{constraint.text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="evidence-section anchor" id="evidence">
        <div className="section-heading with-side">
          <div>
            <p>06 / EVIDENCE CHAIN</p>
            <h2>説明の先に、必ず実物がある。</h2>
          </div>
          <p className="section-note">
            画面表示のたびに、指定された行をワークスペースから再取得しています。
          </p>
        </div>
        <div className="chain">
          {selected.evidence.map((item, index) => (
            <button
              className="evidence-card"
              key={item.id}
              onClick={() => setEvidence(item)}
            >
              <span className="chain-index">{String(index + 1).padStart(2, '0')}</span>
              <small>{item.stage}</small>
              <strong>{item.label}</strong>
              <p>{item.note}</p>
              <code>{item.path}</code>
              <em>実物を開く →</em>
            </button>
          ))}
        </div>
      </section>

      <section className="accumulation">
        <div>
          <p className="kicker">WHAT ACCUMULATES</p>
          <h2>機能だけでなく、<br />変更時に読むべき関係も増えていく。</h2>
        </div>
        <div className="risk-ladder">
          {data.versions.map((version, index) => (
            <button key={version.id} onClick={() => selectVersion(version.id)}>
              <span>{version.label}</span>
              <i style={{ width: String(Math.min(100, 24 + index * 8)) + '%' }} />
              <strong>{version.knowledgeRisk}</strong>
              <small>{version.title}</small>
            </button>
          ))}
        </div>
      </section>

      <section className="validation anchor" id="validation">
        <div className="section-heading with-side">
          <div>
            <p>07 / LIVE VALIDATION</p>
            <h2>説明を、その場で実行可能な証拠へ。</h2>
          </div>
          <p className="section-note">
            実行可能なのは登録済みのテストスクリプトだけです。
          </p>
        </div>
        <div className="validation-shell">
          <div className="test-actions">
            {data.tests.map((test) => (
              <button
                key={test.id}
                disabled={Boolean(runningTest)}
                onClick={() => executeTest(test)}
              >
                <span>{runningTest === test.id ? 'RUNNING' : 'RUN TEST'}</span>
                <strong>{test.label}</strong>
                <code>{test.command}</code>
                <em>{runningTest === test.id ? '実行中…' : '再実行 →'}</em>
              </button>
            ))}
          </div>
          <div className="terminal">
            <header>
              <span /><span /><span />
              <strong>VERIFICATION OUTPUT</strong>
              {testResult && (
                <em className={testResult.ok ? 'pass' : 'fail'}>
                  {testResult.ok ? 'PASS' : 'CHECK'}
                </em>
              )}
            </header>
            <pre>
              {testResult
                ? testResult.output
                : '$ テストを選択すると、実際のコンパイル・比較結果を表示します。'}
            </pre>
            {testResult && (
              <footer>
                {testResult.label} / 終了コード {testResult.exitCode} /
                {' '}{testResult.elapsedSeconds.toFixed(1)}秒
              </footer>
            )}
          </div>
        </div>
      </section>

      <footer className="footer">
        <div className="brand">
          <span className="brand-mark">LE</span>
          <span><strong>LEGACY EVOLUTION</strong><small>Local evidence demo</small></span>
        </div>
        <p>要約は入口、実物が根拠。</p>
      </footer>

      {evidence && (
        <div className="drawer-backdrop" onClick={() => setEvidence(null)}>
          <aside
            className="evidence-drawer"
            aria-modal="true"
            role="dialog"
            aria-label={evidence.label}
            onClick={(event) => event.stopPropagation()}
          >
            <header>
              <div>
                <span>
                  {evidence.stage} / {evidence.viewType === 'code' ? 'WORKSPACE CODE' : 'WORKSPACE DOCUMENT'}
                </span>
                <h2>{evidence.label}</h2>
                <p>{evidence.note}</p>
              </div>
              <button onClick={() => setEvidence(null)} aria-label="閉じる">×</button>
            </header>
            <div className="file-meta">
              <code>{evidence.path}</code>
              <span>L{evidence.start}–L{evidence.actualEnd}</span>
              <button
                onClick={() => navigator.clipboard?.writeText(evidence.path)}
              >パスをコピー</button>
            </div>
            {evidence.viewType === 'code' ? (
              <div className="source-view">
                {evidence.lines.map((line) => (
                  <div className={lineClass(line.text)} key={line.number}>
                    <span>{line.number}</span>
                    <code>{line.text || ' '}</code>
                  </div>
                ))}
              </div>
            ) : (
              <DocumentView evidence={evidence} />
            )}
            <footer>
              <span className="pulse" />
              {formatGeneratedAt(data.generatedAt)} に実ファイルから取得
            </footer>
          </aside>
        </div>
      )}
    </main>
  );
}
