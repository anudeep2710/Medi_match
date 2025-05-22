$base64 = Get-Content -Raw "image_base64.txt"
# Remove any newlines or carriage returns that might be in the file
$base64 = $base64.Replace("`r", "").Replace("`n", "")

# Create the JSON payload with proper escaping
$body = "{`"image_base64`":`"$base64`"}"

try {
    $response = Invoke-RestMethod -Method Post -Uri "https://us-central1-said-eb2f5.cloudfunctions.net/gemini_medical_assistant" -ContentType "application/json" -Body $body
    Write-Output "API Response:"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Output "Error occurred:"
    Write-Output $_.Exception.Message
    if ($_.Exception.Response) {
        Write-Output $_.Exception.Response.StatusCode
    }
}
