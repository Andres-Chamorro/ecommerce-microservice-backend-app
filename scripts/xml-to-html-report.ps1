# Script para convertir reportes XML de Surefire a HTML bonito
# Uso: .\xml-to-html-report.ps1 -XmlFolder "ruta/a/surefire-reports"

param(
    [string]$XmlFolder = "tests/e2e/target/surefire-reports",
    [string]$OutputFile = "e2e-test-report.html"
)

if (-not (Test-Path $XmlFolder)) {
    Write-Host "❌ No se encontró la carpeta: $XmlFolder"
    exit 1
}

$xmlFiles = Get-ChildItem -Path $XmlFolder -Filter "TEST-*.xml"

if ($xmlFiles.Count -eq 0) {
    Write-Host "❌ No se encontraron archivos XML en: $XmlFolder"
    exit 1
}

Write-Host "📊 Procesando $($xmlFiles.Count) archivos XML..."

# Inicializar contadores
$totalTests = 0
$totalFailures = 0
$totalErrors = 0
$totalSkipped = 0
$totalTime = 0
$testDetails = @()

# Procesar cada archivo XML
foreach ($xmlFile in $xmlFiles) {
    [xml]$xml = Get-Content $xmlFile.FullName
    $testsuite = $xml.testsuite
    
    $tests = [int]$testsuite.tests
    $failures = [int]$testsuite.failures
    $errors = [int]$testsuite.errors
    $skipped = [int]$testsuite.skipped
    $time = [double]$testsuite.time
    
    $totalTests += $tests
    $totalFailures += $failures
    $totalErrors += $errors
    $totalSkipped += $skipped
    $totalTime += $time
    
    $status = if ($failures -eq 0 -and $errors -eq 0) { "PASS" } else { "FAIL" }
    
    $testDetails += [PSCustomObject]@{
        Name = $testsuite.name
        Tests = $tests
        Failures = $failures
        Errors = $errors
        Skipped = $skipped
        Time = [math]::Round($time, 3)
        Status = $status
    }
}

$successTests = $totalTests - $totalFailures - $totalErrors - $totalSkipped
$successRate = if ($totalTests -gt 0) { [math]::Round(($successTests / $totalTests) * 100, 1) } else { 0 }

# Generar HTML
$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E2E Test Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: white; 
            padding: 30px; 
            border-radius: 12px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        h1 { 
            color: #333; 
            border-bottom: 4px solid #667eea; 
            padding-bottom: 15px; 
            margin-bottom: 30px;
            font-size: 32px;
        }
        .summary { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
            gap: 20px; 
            margin: 30px 0; 
        }
        .stat-box { 
            padding: 25px; 
            border-radius: 10px; 
            text-align: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .stat-box:hover { transform: translateY(-5px); }
        .success { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .total { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; }
        .failure { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); color: white; }
        .time { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; }
        .stat-number { 
            font-size: 48px; 
            font-weight: bold; 
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        .stat-label { 
            font-size: 14px; 
            text-transform: uppercase; 
            letter-spacing: 1px;
            opacity: 0.9;
        }
        .success-rate {
            text-align: center;
            font-size: 24px;
            margin: 20px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 5px solid #667eea;
        }
        .success-rate strong { color: #667eea; font-size: 36px; }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        thead { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        th { 
            padding: 15px; 
            text-align: left; 
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 1px;
        }
        td { 
            padding: 12px 15px; 
            border-bottom: 1px solid #e0e0e0; 
        }
        tr:hover { background: #f5f5f5; }
        tr:last-child td { border-bottom: none; }
        .pass { 
            color: #10b981; 
            font-weight: bold;
            display: inline-block;
            padding: 4px 12px;
            background: #d1fae5;
            border-radius: 20px;
        }
        .fail { 
            color: #ef4444; 
            font-weight: bold;
            display: inline-block;
            padding: 4px 12px;
            background: #fee2e2;
            border-radius: 20px;
        }
        .time-cell { color: #6b7280; font-size: 0.9em; }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
            text-align: center;
            color: #6b7280;
            font-size: 14px;
        }
        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            margin: 0 5px;
        }
        .badge-success { background: #d1fae5; color: #10b981; }
        .badge-danger { background: #fee2e2; color: #ef4444; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 E2E Test Report - Staging</h1>
        
        <div class="success-rate">
            Tasa de Éxito: <strong>$successRate%</strong>
            <div style="margin-top: 10px;">
                <span class="badge badge-success">✓ $successTests Passed</span>
                <span class="badge badge-danger">✗ $($totalFailures + $totalErrors) Failed</span>
            </div>
        </div>
        
        <div class="summary">
            <div class="stat-box total">
                <div class="stat-number">$totalTests</div>
                <div class="stat-label">Total Tests</div>
            </div>
            <div class="stat-box success">
                <div class="stat-number">$successTests</div>
                <div class="stat-label">Passed</div>
            </div>
            <div class="stat-box failure">
                <div class="stat-number">$($totalFailures + $totalErrors)</div>
                <div class="stat-label">Failed</div>
            </div>
            <div class="stat-box time">
                <div class="stat-number">$([math]::Round($totalTime, 2))s</div>
                <div class="stat-label">Total Time</div>
            </div>
        </div>
        
        <h2 style="margin-top: 40px; color: #333;">📋 Test Details</h2>
        <table>
            <thead>
                <tr>
                    <th>Test Suite</th>
                    <th style="text-align: center;">Tests</th>
                    <th style="text-align: center;">Failures</th>
                    <th style="text-align: center;">Errors</th>
                    <th style="text-align: center;">Time (s)</th>
                    <th style="text-align: center;">Status</th>
                </tr>
            </thead>
            <tbody>
"@

foreach ($test in $testDetails) {
    $statusClass = if ($test.Status -eq "PASS") { "pass" } else { "fail" }
    $statusIcon = if ($test.Status -eq "PASS") { "✓" } else { "✗" }
    
    $html += @"
                <tr>
                    <td><strong>$($test.Name)</strong></td>
                    <td style="text-align: center;">$($test.Tests)</td>
                    <td style="text-align: center;">$($test.Failures)</td>
                    <td style="text-align: center;">$($test.Errors)</td>
                    <td style="text-align: center;" class="time-cell">$($test.Time)</td>
                    <td style="text-align: center;"><span class="$statusClass">$statusIcon $($test.Status)</span></td>
                </tr>
"@
}

$html += @"
            </tbody>
        </table>
        
        <div class="footer">
            <p>Generado el $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</p>
            <p>Pipeline: Staging | Namespace: ecommerce-staging</p>
        </div>
    </div>
</body>
</html>
"@

# Guardar HTML
$html | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "✅ Reporte HTML generado: $OutputFile"
Write-Host ""
Write-Host "📊 Resumen:"
Write-Host "   Total Tests: $totalTests"
Write-Host "   Passed: $successTests"
Write-Host "   Failed: $($totalFailures + $totalErrors)"
Write-Host "   Success Rate: $successRate%"
Write-Host ""
Write-Host "🌐 Abre el archivo en tu navegador para verlo"
