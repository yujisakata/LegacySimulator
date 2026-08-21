# Legacy Evolution Simulator

企業システムが業務変更、法制度、技術移行、組織変更を経て複雑化し、知識の対応関係が変化する過程を再現する研究・教育用リポジトリである。

## 現在の実行可能範囲

V1（1980年、終身保険の新契約査定）の業務、要件、設計、COBOL実装、固定長テスト資産を収録している。

- [V1業務仕様](specification/business_specification/v01/new_business_business_specification_v01.md)
- [V1要件定義](specification/requirements/v01/new_business_system_requirements_v01.md)
- [V1外部設計](specification/external_design/v01/new_business_system_design_v01.md)
- [V1内部設計](specification/internal_design/v01/new_business_cobol_design_v01.md)
- [V1実装](implementation/v01/README.md)
- [V1テスト](test/v01/README.md)
- [V1トレーサビリティ](specification/validation_history/v01/traceability_matrix_v01.md)

## 検証

検証資産のみを確認する場合:

```powershell
./test/v01/scripts/run-tests.ps1 -ReferenceOnly
```

GnuCOBOLが利用できる環境では、COBOLのコンパイルと19件の完全一致比較を実行する。

```powershell
./test/v01/scripts/run-tests.ps1
```

V2以降は`scenario/version_timeline.yml`のイベントを適用し、V1を上書きせずVersion別成果物として追加する。
