# **新契約受付～査定結果通知業務 業務用語集 (V1)**

**文書ID:** DOC-BUS-004  
**関連仕様書:** [ビジネス仕様書 (DOC-BUS-001)](./new_business_business_specification_v01.md), [ビジネスルール仕様書 (DOC-BUS-002)](./new_business_business_rules_v01.md)  
**発行日:** 1980年1月1日（昭和55年1月1日）  
**バージョン:** V1  
**管轄部署:** 新契約部 / 査定部  

---

## **1. ドメイン業務用語一覧**

| 用語（和名） | 用語（英名/略称） | 概念定義・ビジネス上の意味 | 関連するシステムエンティティ | 備考・注意点 |
| :--- | :--- | :--- | :--- | :--- |
| **申込者** | Applicant / APPLICANT | 会社に対し保険契約の締結を申し入れる主体。契約成立後は契約者となる。 | `POLICY_APPLICANT` | 被保険者と同一人物または親族等 |
| **被保険者** | Insured Person / INSURED | その生死が保険事故（死亡等）の対象となる人物。 | `INSURED_PERSON` | 加入年齢範囲は満15歳～満65歳 |
| **責任開始日** | Commencement Date / COMMENCEMENT_DATE | 会社が保険金の支払義務（補償責任）を負い始める起算日。 | `COMMENCEMENT_DATE` | 申込・告知・領収の3要件具備日に遡及 |
| **契約日（効力発生日）** | Policy Date / POLICY_DATE | 契約上の諸期間（年齢計算、配当計算等）の基準となる日付。 | `POLICY_DATE` | 原則責任開始日の属する月の応当日 |
| **告知** | Declaration / DECLARATION | 被保険者が現在の健康状態や傷病歴、職業等を書面で事実通り申告する行為。 | `MEDICAL_DECLARATION` | 告知義務違反時は契約解除対象 |
| **環境査定** | Environmental Underwriting / ENV_UW | 被保険者の職業リスクおよび死亡保険金額の妥当性（モラルリスク）を評価する業務。 | `ENV_UNDERWRITING` | 最高保険金額上限5,000万円 |
| **医的査定** | Medical Underwriting / MED_UW | 告知書等の医学的情報に基づき将来の死亡リスクを評定する業務。 | `MED_UNDERWRITING` | 必要に応じて社医回付を実施 |
| **承諾** | Acceptance / ACCEPTANCE | 規定の引受基準を満たし、保険契約の締結を認める引受決定。 | `ACCEPTANCE_DECISION` | 保険証券発行手配へ移行 |
| **延期** | Postponement / POSTPONEMENT | 現在の健康状態等により直ちには引き受けず、一定期間後に再評価する決定。 | `POSTPONEMENT_DECISION` | 結果通知書を送付し手続一時終了 |
| **謝絶** | Decline / DECLINE | リスクが許容範囲を超過しており、引受を拒否する決定。 | `DECLINE_DECISION` | 結果通知書送付および保険料返金 |
| **申込取下げ** | Withdrawal / WITHDRAWAL | 契約成立前に、申込者の意思表示により手続を途中で取りやめる行為。 | `APPLICATION_WITHDRAWAL` | 納付済保険料の返金を実施 |
| **査定決裁権限** | Approval Authority / UW_AUTHORITY | 保険金額およびリスク区分に応じた引受決裁の職務階層マトリクス。 | `UW_APPROVAL_AUTHORITY` | 一次決裁（2,000万以下）、二次決裁 |
| **事務点検** | Inspection / INSPECTION | 提出書類の記載漏れ、押印漏れ、加入資格等の形式的完全性を確認する業務。 | `DOCUMENT_INSPECTION` | 不備発見時は不備照会を起票 |
| **不備照会** | Deficiency Inquiry / DEFICIENCY | 書類不備が発生した際、営業職員を通じて顧客へ訂正・再提出を求める手続。 | `DEFICIENCY_INQUIRY` | 30日間の手続猶予期間を設定 |
| **社医回付** | Medical Officer Referral / MED_REFERRAL | 査定担当者単独で判断困難な案件を、専門医（社医）へ意見照会する手続。 | `MEDICAL_OFFICER_REFERRAL` | 目標SLAは点検完了後5営業日 |
| **受付日** | Application Receipt Date / RECEIPT_DATE | 申込書類が支社等に到着し、公式に受け付けられた日。 | `APPLICATION_RECEIPT_DATE` | 事務点検SLAの起算日 |
| **不備照会起票日** | Deficiency Open Date / DEFICIENCY_DATE | 事務点検で不備を認定し、不備照会を起票した日。 | `DEFICIENCY_OPEN_DATE` | 不備猶予期間（30日）の起算日 |
| **三要件の具備** | Tripartite Requirements / THREE_REQS | 「申込の完了」「告知の完了」「第1回保険料の受領」の3つが揃うこと。 | `REQUIREMENTS_FULFILLED` | 責任開始の成立不可欠条件 |

---

## **2. 関連ドキュメント**

* **[ビジネス仕様書 (DOC-BUS-001)](./new_business_business_specification_v01.md)**
* **[ビジネスルール仕様書 (DOC-BUS-002)](./new_business_business_rules_v01.md)**
* **[業務フロー定義書 (DOC-BUS-003)](./new_business_business_flow_v01.md)**
