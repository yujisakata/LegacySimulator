"""2026教材検証。期待値はCSVで宣言し、COBOL出力から生成しない。"""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
COUNTS = {}


def read_cases(path):
    with (ROOT / path).open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def field(row, name, width, numeric=False):
    value = row.get(name, "")
    assert len(value) <= width, (name, value)
    return value.zfill(width) if numeric else value.ljust(width)


MAIN_FIELDS = [("AppNumber", 10), ("ApplicationDate", 8),
               ("DisclosureDate", 8), ("PremiumDate", 8),
               ("ReceiptDate", 8), ("ProcessDate", 8),
               ("DeficiencyDate", 8), ("Age", 2), ("Amount", 8),
               ("Product", 2), ("DocumentComplete", 1),
               ("MedicalClass", 1), ("ManagerDecision", 1),
               ("Withdrawal", 1)]
RIDER_FIELDS = [("AdCode", 2), ("AdAmount", 8), ("AdDecision", 1),
                ("HiCode", 2), ("HiBenefit", 6), ("HiDecision", 1)]


def input_record(row, prefix=None):
    s = "".join(field(row, n, w, n in ("Age", "Amount"))
                for n, w in MAIN_FIELDS)
    if prefix == "NB" or (prefix is None and row["Product"] == "WL"):
        s += "".join(field(row, n, w, n in ("AdAmount", "HiBenefit"))
                     for n, w in RIDER_FIELDS)
    else:
        s += field(row, "ReservedData", 20)
    s += "".join(field(row, n, 1) for n in
                 ("Redisclosure", "OldAnswer", "NewAnswer")) + " " * 23
    assert len(s) == 120
    return s


def expected_record(row, audit=True, prefix=None):
    fields = [("AppNumber", 10), ("ExpectedCode", 2),
              ("ExpectedApproval", 1), ("ExpectedReason", 3),
              ("ExpectedResponsibility", 8), ("ProcessDate", 8),
              ("ReceiptDate", 8)]
    s = "".join(field(row, n, w) for n, w in fields)
    if prefix == "NB" or (prefix is None and row["Product"] == "WL"):
        for kind, width in (("Ad", 8), ("Hi", 6)):
            s += row.get(f"Expected{kind}Result", "N")
            s += row.get(f"Expected{kind}Approval", "N")
            s += row.get(f"Expected{kind}Reason", "000")
            s += row.get(f"Expected{kind}Amount" if kind == "Ad"
                         else "ExpectedHiBenefit", "0").zfill(width)
    else:
        s += " " * 24
    s += (field(row, "ExpectedRule", 3)
          + field(row, "ExpectedAppliedDate", 8)) if audit else " " * 11
    s += " " * 5
    assert len(s) == 80
    return s


def execute(exe, work, stdin=None):
    result = subprocess.run([str(exe)], cwd=work, input=stdin,
                            capture_output=True, timeout=20)
    return result.returncode, result.stdout.decode("utf-8", errors="replace")


def write_lines(path, rows):
    path.write_bytes(("\n".join(rows) + ("\n" if rows else "")).encode("ascii"))


def batch_suite(bin_dir, rows, label, inherited=False):
    for prefix in ("NB", "MD"):
        cases = (rows if prefix == ("MD" if label == "inherited_v03" else "NB") else []) if inherited else [r for r in rows if (r["Product"] == "WL") == (prefix == "NB")]
        if not cases:
            continue
        with tempfile.TemporaryDirectory(prefix="v04-test-") as tmp:
            work = Path(tmp)
            write_lines(work / "REGDATE.DAT", ["19950401"])
            input_name, output_name = (("APPLICATION.DAT", "ASSESSMENT.DAT")
                                       if prefix == "NB" else
                                       ("MEDICAL.DAT", "MEDASSESS.DAT"))
            write_lines(work / input_name, [input_record(c, prefix) for c in cases])
            rc, log = execute(bin_dir / (prefix + "ASSESS.exe"), work)
            assert rc == 0, (label, prefix, rc, log)
            actual = (work / output_name).read_bytes().decode("ascii").splitlines()
            assert len(actual) == len(cases), (label, "record count", log)
            for row, got in zip(cases, actual):
                want = expected_record(row, not inherited, prefix)
                assert len(got) == 80, (row["CaseId"], len(got))
                if inherited:
                    # Explicitly permit only new audit bytes 65-75 to differ.
                    got = got[:64] + " " * 11 + got[75:]
                assert got == want, (row["CaseId"], repr(want), repr(got))
            COUNTS[label] = COUNTS.get(label, 0) + len(cases)


def online_suite(bin_dir, rows):
    # Test both directions of date precedence, blank handling and rejection.
    selected = [r for r in rows if r["CaseId"].startswith((
        "MATRIX-02-Y", "MATRIX-20-Y", "MATRIX-11-N",
        "INVALID-", "BAD-DATE-00000000", "RIDERS-NEW-"))]
    for row in selected:
        prefix = "NB" if row["Product"] == "WL" else "MD"
        with tempfile.TemporaryDirectory(prefix="v04-online-") as tmp:
            work = Path(tmp)
            write_lines(work / "REGDATE.DAT", ["19950401"])
            fields = MAIN_FIELDS + (RIDER_FIELDS if prefix == "NB" else [])
            lines = [field(row, n, w, n in ("Age", "Amount", "AdAmount", "HiBenefit"))
                     for n, w in fields]
            lines += [row[n] or " " for n in ("Redisclosure", "OldAnswer", "NewAnswer")]
            rc, log = execute(bin_dir / (prefix + "ENTRY.exe"), work,
                              ("\n".join(lines) + "\n").encode("ascii"))
            output = work / ("APPLICATION.DAT" if prefix == "NB" else "MEDICAL.DAT")
            valid = row["ExpectedCode"] != "08"
            if valid:
                assert rc == 0, (row["CaseId"], rc, log)
                got = output.read_bytes().decode("ascii").splitlines()
                assert got == [input_record(row)], (row["CaseId"], got)
                assert ("APPLIED RULE: " + row["ExpectedRule"]
                        + " DATE: " + row["ExpectedAppliedDate"]) in log
                # Registration is followed by the real assessment executable.
                rc, log = execute(bin_dir / (prefix + "ASSESS.exe"), work)
                result = work / ("ASSESSMENT.DAT" if prefix == "NB" else "MEDASSESS.DAT")
                assert rc == 0 and result.read_bytes().decode("ascii").splitlines() == [expected_record(row)]
            else:
                assert rc != 0 and not output.exists(), (row["CaseId"], rc, log)
            COUNTS["online"] = COUNTS.get("online", 0) + 1


def infrastructure_suite(bin_dir, sample):
    invalid_masters = [None, [], ["19950229"], ["19000229"], ["00000000"],
                       ["abcdefgh"], ["1995040"], ["199504011"],
                       ["19950401", "19950402"], ["19950401", ""],
                       ["18991231"], ["21000101"]]
    for prefix in ("NB", "MD"):
        for suffix in ("ENTRY", "ASSESS"):
            for master in invalid_masters:
                with tempfile.TemporaryDirectory(prefix="v04-master-") as tmp:
                    work = Path(tmp)
                    if master is not None:
                        write_lines(work / "REGDATE.DAT", master)
                    rc, log = execute(bin_dir / (prefix + suffix + ".exe"), work)
                    assert rc != 0, (prefix, suffix, master, log)
                    assert not any(work.glob("*ASSESS.DAT"))
                    assert not (work / "ASSESSMENT.DAT").exists()
                    assert not (work / "APPLICATION.DAT").exists()
                    assert not (work / "MEDICAL.DAT").exists()
                    COUNTS["invalid_master"] = COUNTS.get("invalid_master", 0) + 1
        for kind in ("empty", "short", "long", "missing", "output_directory"):
            with tempfile.TemporaryDirectory(prefix="v04-io-") as tmp:
                work = Path(tmp)
                write_lines(work / "REGDATE.DAT", ["19950401"])
                source, target = (("APPLICATION.DAT", "ASSESSMENT.DAT") if prefix == "NB"
                                  else ("MEDICAL.DAT", "MEDASSESS.DAT"))
                if kind == "empty":
                    write_lines(work / source, [])
                elif kind != "missing":
                    value = input_record(sample)
                    if kind == "short":
                        value = value[:-1]
                    if kind == "long":
                        value += "X"
                    write_lines(work / source, [value])
                if kind == "output_directory":
                    (work / target).mkdir()
                rc, log = execute(bin_dir / (prefix + "ASSESS.exe"), work)
                assert (rc == 0) == (kind == "empty"), (prefix, kind, rc, log)
                if kind == "empty":
                    assert (work / target).read_bytes() == b""
                COUNTS["io"] = COUNTS.get("io", 0) + 1
        # Master must affect the decision; no hidden hard-coded cutoff.
        with tempfile.TemporaryDirectory(prefix="v04-master-change-") as tmp:
            work = Path(tmp)
            row = dict(sample, Product="WL" if prefix == "NB" else "MI",
                       Amount="10000000" if prefix == "NB" else "5000",
                       ReceiptDate="19950401", DisclosureDate="19950401",
                       Redisclosure="N", OldAnswer="Y", NewAnswer="N",
                       ExpectedRule="OLD", ExpectedAppliedDate="19950401",
                       ExpectedCode="03", ExpectedApproval="N",
                       ExpectedReason="OLD", ExpectedResponsibility="00000000")
            source, target = (("APPLICATION.DAT", "ASSESSMENT.DAT") if prefix == "NB"
                              else ("MEDICAL.DAT", "MEDASSESS.DAT"))
            write_lines(work / "REGDATE.DAT", ["19950402"])
            write_lines(work / source, [input_record(row)])
            rc, log = execute(bin_dir / (prefix + "ASSESS.exe"), work)
            assert rc == 0, log
            assert (work / target).read_bytes().decode("ascii").splitlines() == [expected_record(row)]
            COUNTS["master_change"] = COUNTS.get("master_change", 0) + 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bin", type=Path, required=True)
    parser.add_argument("--reference-only", action="store_true")
    args = parser.parse_args()
    bin_dir = args.bin.resolve()
    rows = read_cases("test/v04/cases/integrated_cases.csv")
    for row in rows:
        input_record(row)
        expected_record(row)
    if args.reference_only:
        print(f"V4 declared fixtures: {len(rows)}")
        return
    os.environ["COB_LS_FIXED"] = "TRUE"
    batch_suite(bin_dir, rows, "integrated")
    # Check per-record work areas are independent of preceding records.
    batch_suite(bin_dir, list(reversed(rows)), "reverse_order")
    for version, filename in (("v01", "assessment"), ("v02", "rider"), ("v03", "medical")):
        batch_suite(bin_dir, read_cases(f"test/{version}/cases/{filename}_cases.csv"),
                    f"inherited_{version}", inherited=True)
    online_suite(bin_dir, rows)
    infrastructure_suite(bin_dir, rows[0])
    evidence = {"status": "PASS", "counts": COUNTS, "sha256": {}}
    for pattern in ("implementation/v04/**/*", "test/v04/**/*"):
        for path in sorted(ROOT.glob(pattern)):
            if path.is_file() and "__pycache__" not in str(path):
                evidence["sha256"][path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    (bin_dir / "verification.json").write_text(json.dumps(evidence, indent=2), encoding="utf-8")
    print(json.dumps(COUNTS))
    print("V4 verification PASS")


if __name__ == "__main__":
    main()

