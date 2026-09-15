"""一時コピーへの誤変更を、実Javaテストが検出するか確認する。"""
import json,os,subprocess,sys,tempfile
from pathlib import Path
root=Path(__file__).resolve().parents[3]
build=root/'build/v05'
last=Path((build/'last-run.txt').read_text(encoding='utf-8-sig').strip())
sources=list((root/'implementation/v05/java').rglob('*.java'))+list((root/'test/v05/java').glob('*.java'))
deps=list((build/'deps').glob('*.jar'));cp=os.pathsep.join(map(str,deps))
mutations=[
 ('blank_to_zero','FixedLengthInquiryConverter.java','BigDecimal amount=null;','BigDecimal amount=BigDecimal.ZERO;','blank amount NULL'),
 ('commit_on_failure','SnapshotImportJob.java','try { c.rollback(); }','try { c.commit(); }','rollback restores previous whole snapshot'),
 ('wrong_medical_label','ContractInquiryServlet.java','"入院日額"','"死亡保険金額"','HTTP product-specific amount label MI')]
results=[]
for label,name,old,new,expected in mutations:
 with tempfile.TemporaryDirectory(prefix='v05-mutation-') as tmp:
  work=Path(tmp);classes=work/'classes';classes.mkdir()
  original=next(p for p in sources if p.name==name)
  text=original.read_text(encoding='utf-8');assert text.count(old)==1
  mutated=work/name;mutated.write_text(text.replace(old,new),encoding='utf-8')
  altered=[mutated if p==original else p for p in sources]
  compile=subprocess.run(['java','-jar',str(build/'deps/ecj-3.26.0.jar'),'-8','-proc:none','-encoding','UTF-8','-classpath',cp,'-d',str(classes)]+list(map(str,altered)),capture_output=True,timeout=30)
  assert compile.returncode==0,compile.stderr
  run=subprocess.run(['java','-cp',str(classes)+os.pathsep+cp,'V5IntegrationTest',str(root),str(work/'run'),str(last/'v4')],capture_output=True,timeout=60)
  output=(run.stdout+run.stderr).decode('utf-8',errors='replace')
  assert run.returncode!=0 and 'AssertionError: '+expected in output,(label,output[-3000:])
  results.append(dict(mutation=label,detected=True,failing_assertion=expected))
  print('Detected:',label)
(build/'mutation-result.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
