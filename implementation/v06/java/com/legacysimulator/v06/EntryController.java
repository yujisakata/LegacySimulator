package com.legacysimulator.v06;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

// V6-ADD-013: Spring MVC相当の受付Controller。HTTP値を業務要求へ変換する。
public final class EntryController {
    private final EntryWorkflowService workflowService;
    public EntryController(EntryWorkflowService workflowService) { this.workflowService = workflowService; }

    public EntryReceipt submit(String number, String product, String age, String amount) {
        try {
            EntryRequest request = new EntryRequest(number, product,
                    Integer.parseInt(age), new BigDecimal(amount));
            return workflowService.accept(request, new Date());
        } catch (NumberFormatException error) {
            return EntryReceipt.rejected(List.of("年齢または保険金額が数字ではありません"));
        }
    }
}
