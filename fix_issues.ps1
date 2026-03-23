# Fix all remaining Flutter analyze issues

# Fix onboarding3_page.dart
$file = "lib\features\onboarding\onboarding3_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "print\('Get Started button pressed on page 3!'\);", "// Get Started button pressed"
$content = $content -replace "context.push\('/signup'\);", "if (mounted) { context.push('/signup'); }"
Set-Content $file -Value $content

# Fix onboarding1_page.dart
$file = "lib\features\onboarding\onboarding1_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class St1 extends StatelessWidget \{", "class St1 extends StatelessWidget {`r`n  const St1({super.key});"
Set-Content $file -Value $content

# Fix view_jobs_page.dart
$file = "lib\features\dashboard\view_jobs_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class ViewJobsPage extends StatelessWidget \{", "class ViewJobsPage extends StatelessWidget {`r`n  const ViewJobsPage({super.key});"
$content = $content -replace "bool isWideScreen = constraints.maxWidth > 600;", "// bool isWideScreen = constraints.maxWidth > 600;"
Set-Content $file -Value $content

# Fix subsciption_page.dart
$file = "lib\features\dashboard\subsciption_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class SubsciptionPage extends StatefulWidget \{", "class SubsciptionPage extends StatefulWidget {`r`n  const SubsciptionPage({super.key});"
$content = $content -replace "\.\.\.plans\.map\(\(plan\) => _buildPlanCard\(plan\)\)\.toList\(\)", "...plans.map((plan) => _buildPlanCard(plan))"
Set-Content $file -Value $content

Write-Host "Fixed all issues!"
