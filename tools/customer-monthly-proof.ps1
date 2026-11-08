$ErrorActionPreference = 'Stop'

$baseUrl = 'http://127.0.0.1:5090'
$userName = 'customer-sync-proof-user'

$customerBodyObject = [ordered]@{
    name = 'Live Customer Monthly Proof'
    contactName = 'Test Buyer'
    phone = '0500000001'
    relationshipType = 'Wholesale'
    status = 'Active'
    notes = 'Live validation for monthly price'
}

$customerBody = $customerBodyObject | ConvertTo-Json -Compress
$headers = @{ 'X-User-Name' = $userName }

$customer = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/customers') -Headers $headers -ContentType 'application/json' -Body $customerBody
Write-Host ('CUSTOMER_ID=' + $customer.id)
Write-Host ('CUSTOMER_NAME=' + $customer.name)

$priceBodyObject = [ordered]@{
    year = 2026
    month = 11
    monthlyRate = 1500
    currency = 'SAR'
}

$price = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/customers/' + $customer.id + '/monthly-price') -Headers $headers -ContentType 'application/json' -Body ($priceBodyObject | ConvertTo-Json -Compress)
Write-Host ('PRICE_ID=' + $price.id)
Write-Host ('PRICE_RATE=' + $price.monthlyRate)
Write-Host ('PRICE_MESSAGE=' + $price.message)

$prices = Invoke-RestMethod -Method Get -Uri ($baseUrl + '/api/customers/' + $customer.id + '/monthly-prices') -Headers $headers
Write-Host ('PRICE_COUNT=' + $prices.Count)
