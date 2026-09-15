"""V4の固定期待値から3商品を選び、実COBOL出力を検証して渡す。"""
import importlib.util,json,sys,hashlib,subprocess,os
from pathlib import Path
sys.dont_write_bytecode=True
root=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('v4',root/'test/v04/scripts/verify_v04.py')
v4=importlib.util.module_from_spec(spec);spec.loader.exec_module(v4)
work=Path(sys.argv[1]).resolve();work.mkdir(parents=True,exist_ok=True)
cases=v4.read_cases('test/v04/cases/integrated_cases.csv')
selected=[next(r for r in cases if r['CaseId']=='MATRIX-02-YNY-'+product) for product in ['WL','MI','CI']]
v4.write_lines(work/'REGDATE.DAT',['19950401'])
os.environ['COB_LS_FIXED']='TRUE'
for prefix in ['NB','MD']:
 rows=[r for r in selected if (r['Product']=='WL')==(prefix=='NB')]
 source,target=('APPLICATION.DAT','ASSESSMENT.DAT') if prefix=='NB' else ('MEDICAL.DAT','MEDASSESS.DAT')
 v4.write_lines(work/source,[v4.input_record(r) for r in rows])
 result=subprocess.run([str(root/'build/v04'/(prefix+'ASSESS.exe'))],cwd=work,capture_output=True,timeout=20)
 assert result.returncode==0,result.stdout
 actual=(work/target).read_bytes().decode('ascii').splitlines()
 assert actual==[v4.expected_record(r) for r in rows],(actual,rows)
print('V4 actual COBOL source fixtures: 3 cases PASS')
