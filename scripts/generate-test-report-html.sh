#!/bin/bash
# Script para generar reporte HTML desde XML de Surefire

REPORT_DIR="tests/e2e/target/surefire-reports"
OUTPUT_FILE="test-report.html"

if [ ! -d "$REPORT_DIR" ]; then
    echo "No se encontró directorio de reportes"
    exit 0
fi

# Crear HTML básico
cat > $OUTPUT_FILE <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>E2E Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #4CAF50; padding-bottom: 10px; }
        .summary { display: flex; gap: 20px; margin: 20px 0; }
        .stat-box { flex: 1; padding: 20px; border-radius: 5px; text-align: center; }
        .success { background: #4CAF50; color: white; }
        .failure { background: #f44336; color: white; }
        .skipped { background: #ff9800; color: white; }
        .total { background: #2196F3; color: white; }
        .stat-number { font-size: 48px; font-weight: bold; }
        .stat-label { font-size: 14px; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #333; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background: #f5f5f5; }
        .pass { color: #4CAF50; font-weight: bold; }
        .fail { color: #f44336; font-weight: bold; }
        .time { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 E2E Test Report</h1>
EOF

# Contar tests
TOTAL=$(find $REPORT_DIR -name "*.xml" -exec grep -o 'tests="[0-9]*"' {} \; | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
FAILURES=$(find $REPORT_DIR -name "*.xml" -exec grep -o 'failures="[0-9]*"' {} \; | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
ERRORS=$(find $REPORT_DIR -name "*.xml" -exec grep -o 'errors="[0-9]*"' {} \; | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
SKIPPED=$(find $REPORT_DIR -name "*.xml" -exec grep -o 'skipped="[0-9]*"' {} \; | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
SUCCESS=$((TOTAL - FAILURES - ERRORS - SKIPPED))

# Agregar resumen
cat >> $OUTPUT_FILE <<EOF
        <div class="summary">
            <div class="stat-box total">
                <div class="stat-number">$TOTAL</div>
                <div class="stat-label">Total Tests</div>
            </div>
            <div class="stat-box success">
                <div class="stat-number">$SUCCESS</div>
                <div class="stat-label">Passed</div>
            </div>
            <div class="stat-box failure">
                <div class="stat-number">$((FAILURES + ERRORS))</div>
                <div class="stat-label">Failed</div>
            </div>
            <div class="stat-box skipped">
                <div class="stat-number">$SKIPPED</div>
                <div class="stat-label">Skipped</div>
            </div>
        </div>
        
        <h2>Test Details</h2>
        <table>
            <thead>
                <tr>
                    <th>Test Class</th>
                    <th>Tests</th>
                    <th>Failures</th>
                    <th>Errors</th>
                    <th>Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
EOF

# Agregar detalles de cada test
for xml_file in $REPORT_DIR/*.xml; do
    if [ -f "$xml_file" ]; then
        CLASS=$(grep -o 'name="[^"]*"' "$xml_file" | head -1 | cut -d'"' -f2)
        TESTS=$(grep -o 'tests="[0-9]*"' "$xml_file" | head -1 | cut -d'"' -f2)
        FAILS=$(grep -o 'failures="[0-9]*"' "$xml_file" | head -1 | cut -d'"' -f2)
        ERRS=$(grep -o 'errors="[0-9]*"' "$xml_file" | head -1 | cut -d'"' -f2)
        TIME=$(grep -o 'time="[^"]*"' "$xml_file" | head -1 | cut -d'"' -f2)
        
        if [ "$FAILS" = "0" ] && [ "$ERRS" = "0" ]; then
            STATUS="<span class='pass'>✓ PASS</span>"
        else
            STATUS="<span class='fail'>✗ FAIL</span>"
        fi
        
        cat >> $OUTPUT_FILE <<EOF
                <tr>
                    <td>$CLASS</td>
                    <td>$TESTS</td>
                    <td>$FAILS</td>
                    <td>$ERRS</td>
                    <td class="time">${TIME}s</td>
                    <td>$STATUS</td>
                </tr>
EOF
    fi
done

# Cerrar HTML
cat >> $OUTPUT_FILE <<'EOF'
            </tbody>
        </table>
    </div>
</body>
</html>
EOF

echo "✅ Reporte HTML generado: $OUTPUT_FILE"
