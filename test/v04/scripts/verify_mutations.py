"""補正漏れの検出力を検証する。配布ソースは変更しない。"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
import verify_v04 as verifier


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bin", type=Path, required=True)
    args = parser.parse_args()
    compiler = shutil.which("cobc")
    if not compiler:
        raise RuntimeError("Run after build-v04.ps1 in the same shell")
    rows = verifier.read_cases("test/v04/cases/integrated_cases.csv")
    results = []
    for folder, name in (("batch", "NBASSESS"), ("batch", "MDASSESS"),
                         ("online", "NBENTRY"), ("online", "MDENTRY")):
        for mutation in ("missing_patch", "boundary"):
            # Both directions of the business date comparison need coverage.
            source = verifier.ROOT / "implementation/v04" / folder / (name + ".cbl")
            text = source.read_text(encoding="utf-8")
            old, new = (( 'IF APP-REDISCLOSURE = "Y"',
                          'IF APP-REDISCLOSURE = "Z"') if mutation == "missing_patch"
                        else ('IF WS-REG-DATE < WS-EFFECTIVE-DATE',
                              'IF WS-REG-DATE <= WS-EFFECTIVE-DATE'))
            assert text.count(old) == 1
            with tempfile.TemporaryDirectory(prefix="v04-mutation-") as temp:
                work = Path(temp)
                for exe in args.bin.resolve().glob("*.exe"):
                    shutil.copyfile(exe, work / exe.name)
                mutant = work / (name + ".cbl")
                mutant.write_text(text.replace(old, new), encoding="utf-8")
                build = subprocess.run([compiler, "-x", "-fixed", "-I",
                                        str(verifier.ROOT / "implementation/v04/copybook"),
                                        "-o", str(work / (name + ".exe")), str(mutant)],
                                       capture_output=True, timeout=30)
                assert build.returncode == 0, build.stderr.decode(errors="replace")
                try:
                    if folder == "batch":
                        verifier.batch_suite(work, rows, "mutation")
                    else:
                        verifier.online_suite(work, rows)
                except AssertionError as failure:
                    results.append({"program": name, "mutation": mutation,
                                    "detected": True, "evidence": str(failure)})
                else:
                    raise AssertionError(f"Undetected mutation: {name}/{mutation}")
    (args.bin / "mutation-verification.json").write_text(
        json.dumps(results, indent=2), encoding="utf-8")
    print(f"V4 mutation checks PASS: {len(results)} / {len(results)} detected")


if __name__ == "__main__":
    import os
    os.environ["COB_LS_FIXED"] = "TRUE"
    main()
