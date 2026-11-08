from pathlib import Path
source = Path(r'D:\YASIN_WORKSHOP\.verification\flutter_analyze_proof.txt')
out = Path(r'D:\YASIN_WORKSHOP\.verification\flutter_analyze_proof_decoded.txt')
raw = source.read_bytes()
out.write_text(raw.decode('utf-16'), encoding='utf-8')
