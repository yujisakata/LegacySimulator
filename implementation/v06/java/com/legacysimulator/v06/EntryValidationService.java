package com.legacysimulator.v06;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

// V6-ADD-002: COBOL取込前の事務点検。最終査定ではない。
public final class EntryValidationService {
    // V6-FIX-001 DEL: V3の正式商品コードと一致しないMD/CAを使用していた。
    // private static final Set<String> PRODUCTS = Set.of("WL", "MD", "CA");
    // V6-FIX-001 ADD: V3から継続する正式商品コードMI/CIへ統一する。
    private static final Set<String> PRODUCTS = Set.of("WL", "MI", "CI");

    public List<String> validate(EntryRequest request) {
        List<String> messages = new ArrayList<>();
        if (request.applicationNumber() == null || request.applicationNumber().length() != 10) messages.add("受付番号は10桁です");
        if (!PRODUCTS.contains(request.productCode())) messages.add("商品コードが対象外です");
        if (request.age() < 0 || request.age() > 120) messages.add("年齢が範囲外です");
        if (request.insuredAmount() == null || request.insuredAmount().signum() < 0) messages.add("保険金額が不正です");
        return List.copyOf(messages);
    }
}
