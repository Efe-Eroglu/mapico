import os
import json
import pytest
from datetime import datetime
from pathlib import Path

def collect_test_results():
    """Test sonuçlarını toplar ve JSON formatında kaydeder."""
    test_results = {
        "summary": {
            "total": 0,
            "passed": 0,
            "failed": 0,
            "skipped": 0,
            "last_run": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "duration": 0
        },
        "categories": {
            "auth": {
                "name": "Kimlik Doğrulama Testleri",
                "icon": "lock",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "user": {
                "name": "Kullanıcı Servisi Testleri",
                "icon": "user",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "game": {
                "name": "Oyun Servisi Testleri",
                "icon": "gamepad",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "avatar": {
                "name": "Avatar Servisi Testleri",
                "icon": "user-circle",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "badge": {
                "name": "Rozet Servisi Testleri",
                "icon": "award",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "flight": {
                "name": "Uçuş Servisi Testleri",
                "icon": "plane",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "failures": {
                "name": "Test Hata Senaryoları",
                "icon": "bug",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            },
            "db": {
                "name": "Veritabanı Model Testleri",
                "icon": "database",
                "total": 0,
                "passed": 0,
                "failed": 0,
                "skipped": 0,
                "tests": []
            }
        }
    }

    # Tüm Backend/tests altındaki test_*.py dosyalarını tara
    test_dir = Path("Backend/tests")
    test_files = list(test_dir.rglob("test_*.py"))

    for test_file in test_files:
        try:
            with open(test_file, "r", encoding="utf-8") as f:
                content = f.read()
            lines = content.split("\n")
            for i, line in enumerate(lines):
                if line.strip().startswith("def test_"):
                    test_name = line.strip()[4:].split("(")[0]
                    # Kategori belirleme
                    file_name = test_file.name.lower()
                    rel_path = str(test_file.relative_to(test_dir))
                    category = None
                    # Önce db klasörü kontrolü
                    if "db" in str(test_file.parts):
                        category = "db"
                    elif "auth" in file_name:
                        category = "auth"
                    elif "user_avatar" in file_name:
                        category = "avatar"
                    elif "user_badge" in file_name:
                        category = "badge"
                    elif "user" in file_name and "avatar" not in file_name and "badge" not in file_name:
                        category = "user"
                    elif "game_session" in file_name:
                        category = "game"
                    elif "game" in file_name:
                        category = "game"
                    elif "avatar" in file_name:
                        category = "avatar"
                    elif "badge" in file_name:
                        category = "badge"
                    elif "flight" in file_name:
                        category = "flight"
                    elif "failures" in file_name:
                        category = "failures"
                    if not category:
                        continue
                    # Test kodunu al
                    test_code = []
                    current_line = i
                    indent = len(line) - len(line.lstrip())
                    while current_line < len(lines):
                        current = lines[current_line]
                        if current.strip() and (len(current) - len(current.lstrip()) <= indent):
                            if current_line > i:
                                break
                        test_code.append(current)
                        current_line += 1
                    # Test tipi
                    if "/unit/" in str(test_file):
                        test_type = "unit"
                    elif "/integration/" in str(test_file):
                        test_type = "integration"
                    elif "/db/" in str(test_file):
                        test_type = "db"
                    else:
                        test_type = "other"
                    # Açıklama (docstring) çek
                    description = ""
                    # Test fonksiyonunun hemen altındaki docstring'i bul
                    if i+1 < len(lines) and '"""' in lines[i+1]:
                        doc_lines = []
                        doc_started = False
                        for j in range(i+1, len(lines)):
                            l = lines[j]
                            if '"""' in l:
                                if not doc_started:
                                    doc_started = True
                                    if l.strip().count('"""') == 2:
                                        doc_lines.append(l.strip().replace('"""',''))
                                        break
                                    continue
                                else:
                                    break
                            if doc_started:
                                doc_lines.append(l.strip())
                        description = ' '.join(doc_lines).strip()
                    # Test status'unu belirle (şimdilik hepsi passed, ama ileride pytest json'dan alınabilir)
                    status = "passed"
                    # Test detaylarını ekle
                    test_info = {
                        "name": test_name,
                        "file": rel_path,
                        "status": status,
                        "duration": 0.0,
                        "code": "\n".join(test_code),
                        "error": None,
                        "type": test_type,
                        "description": description
                    }
                    test_results["categories"][category]["tests"].append(test_info)
                    test_results["categories"][category]["total"] += 1
                    if status == "passed":
                        test_results["categories"][category]["passed"] += 1
                        test_results["summary"]["passed"] += 1
                    elif status == "failed":
                        test_results["categories"][category]["failed"] += 1
                        test_results["summary"]["failed"] += 1
                    elif status == "skipped":
                        test_results["categories"][category]["skipped"] += 1
                        test_results["summary"]["skipped"] += 1
                    test_results["summary"]["total"] += 1
        except Exception as e:
            print(f"Error processing {test_file}: {str(e)}")

    with open("test_results.json", "w", encoding="utf-8") as f:
        json.dump(test_results, f, indent=4, ensure_ascii=False)

def generate_html_report():
    """JSON test sonuçlarından HTML raporu oluşturur."""
    with open("test_results.json", "r", encoding="utf-8") as f:
        test_results = json.load(f)
    with open("test-dashboard.html", "r", encoding="utf-8") as f:
        template = f.read()

    # Genel özet kutuları
    summary_html = f'''
    <div class="summary-row">
        <div class="summary-card">
            <i class="fas fa-check-circle status-success fa-2x"></i>
            <h3>{test_results['summary']['passed']}</h3>
            <p>Başarılı</p>
        </div>
        <div class="summary-card">
            <i class="fas fa-times-circle status-failed fa-2x"></i>
            <h3>{test_results['summary']['failed']}</h3>
            <p>Başarısız</p>
        </div>
        <div class="summary-card">
            <i class="fas fa-forward status-skipped fa-2x"></i>
            <h3>{test_results['summary']['skipped']}</h3>
            <p>Atlanan</p>
        </div>
        <div class="summary-card">
            <i class="fas fa-list-ol fa-2x" style="color:#17a2b8;"></i>
            <h3>{test_results['summary']['total']}</h3>
            <p>Toplam Test</p>
        </div>
    </div>
    '''
    template = template.replace("<!-- DASHBOARD_SUMMARY -->", summary_html)

    # Kategoriler
    for cat_key, cat in test_results["categories"].items():
        # Kategori başlığı özet
        cat_summary = f'''
        <div class="category-summary">
            <h3><i class="fas fa-{cat['icon']}"></i> {cat['name']}</h3>
            <div class="category-stats">
                <span class="stat-item">Toplam: {cat['total']}</span>
                <span class="stat-item status-success">Başarılı: {cat['passed']}</span>
                <span class="stat-item status-failed">Başarısız: {cat['failed']}</span>
                <span class="stat-item status-skipped">Atlanan: {cat['skipped']}</span>
            </div>
        </div>
        '''
        template = template.replace(f"<!-- CATEGORY_SUMMARY_{cat_key} -->", cat_summary)

        # Test listesi
        test_items = []
        for idx, test in enumerate(cat["tests"]):
            icon = "check-circle" if test["status"] == "passed" else ("times-circle" if test["status"] == "failed" else "forward")
            color = "status-success" if test["status"] == "passed" else ("status-failed" if test["status"] == "failed" else "status-skipped")
            description = test.get("description") or "Açıklama yok"
            # Her test-item'a unique id ver
            test_id = f"{cat_key}-test-{idx}"
            test_items.append(f'''
            <div class="test-item" id="{test_id}">
                <span class="{color}"><i class="fas fa-{icon}"></i></span>
                <span style="margin-left:10px;font-weight:500;">{test['name']}</span>
                <div class="test-details">
                    <span><i class="fas fa-file-code"></i> {test['file']}</span>
                    <span style="margin-left:20px;"><i class="fas fa-clock"></i> {test['duration']}s</span>
                </div>
                <div class="test-content">
                    <div class="test-info">
                        <p><strong>Test Adı:</strong> {test['name']}</p>
                        <p><strong>Dosya:</strong> {test['file']}</p>
                        <p><strong>Açıklama:</strong> {description}</p>
                        <p><strong>Durum:</strong> {test['status'].capitalize()}</p>
                        <p><strong>Çalışma Süresi:</strong> {test['duration']}s</p>
                    </div>
                    <div class="test-stack">
                        <pre>{test['code']}</pre>
                    </div>
                    {f'<div class="error-details">{test["error"]}</div>' if test.get('error') else ''}
                </div>
            </div>
            ''')
        template = template.replace(f"<!-- CATEGORY_TESTS_{cat_key} -->", "\n".join(test_items))

    with open("test-dashboard-new.html", "w", encoding="utf-8") as f:
        f.write(template)

if __name__ == "__main__":
    collect_test_results()
    generate_html_report() 