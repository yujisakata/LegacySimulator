# **[モジュール名] 詳細設計書（オンライン）**

**文書ID:** DOC-INT-001  
**プログラムID:** PRG-ON-XXX  

---

## **1. クラス・モジュール構造**
*(クラス図・コールツリー)*

## **2. メソッド・関数仕様**
### `Method: executeAssessment(AppRequest req)`
* **引数:** `AppRequest req`
* **戻り値:** `AssessmentResult`
* **擬似コード / 処理フロー:**
```java
// 1. バリデーション実行
if (!validate(req)) {
    throw new InvalidRequestException();
}
// 2. 引受判定実行
AssessmentResult result = assessmentEngine.evaluate(req);
return result;
```
