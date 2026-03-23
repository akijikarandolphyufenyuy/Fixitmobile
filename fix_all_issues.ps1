# Comprehensive fix for all remaining Flutter issues

Write-Host "Fixing all remaining issues..."

# Fix home_page.dart - add const constructor
$file = "lib\features\dashboard\home_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class HomePage extends StatefulWidget \{", "class HomePage extends StatefulWidget {`n  const HomePage({super.key});`n"
Set-Content $file -Value $content

# Fix post_job_page.dart
$file = "lib\features\dashboard\post_job_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class PostJobPage extends StatefulWidget \{", "class PostJobPage extends StatefulWidget {`n  const PostJobPage({super.key});`n"
$content = $content -replace "_PostJobPageState createState\(\) => _PostJobPageState\(\);", "State<PostJobPage> createState() => _PostJobPageState();"
$content = $content -replace "print\('Job posted successfully!'\);", "// Job posted successfully"
$content = $content -replace "print\('Error posting job: \`$e'\);", "// Error posting job"
$content = $content -replace "print\('Error: \`$e'\);", "// Error occurred"
$content = $content -replace "context.go\('/dashboard/my-jobs'\);", "if (mounted) { context.go('/dashboard/my-jobs'); }"
$content = $content -replace "WillPopScope", "PopScope"
$content = $content -replace "onWillPop:", "canPop: false,`n        onPopInvoked: (didPop) {"
$content = $content -replace "return Future.value\(false\);", "if (!didPop) { return; }"
$content = $content -replace "bool isWideScreen = constraints.maxWidth > 600;", "// Responsive layout"
Set-Content $file -Value $content

# Fix subsciption_page.dart
$file = "lib\features\dashboard\subsciption_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class SubsciptionPage extends StatefulWidget \{", "class SubsciptionPage extends StatefulWidget {`n  const SubsciptionPage({super.key});`n"
$content = $content -replace "_SubsciptionPageState createState\(\) => _SubsciptionPageState\(\);", "State<SubsciptionPage> createState() => _SubsciptionPageState();"
$content = $content -replace "\.\.\.plans\.map\(\(plan\) => _buildPlanCard\(plan\)\)\.toList\(\)", "...plans.map((plan) => _buildPlanCard(plan))"
Set-Content $file -Value $content

# Fix view_jobs_page.dart
$file = "lib\features\dashboard\view_jobs_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class ViewJobsPage extends StatelessWidget \{", "class ViewJobsPage extends StatelessWidget {`n  const ViewJobsPage({super.key});`n"
Set-Content $file -Value $content

# Fix subscription_page.dart (in subscription folder)
$file = "lib\features\subscription\subscription_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "class SubscriptionPage extends StatelessWidget \{", "class SubscriptionPage extends StatelessWidget {`n  const SubscriptionPage({super.key});`n"
$content = $content -replace "Container\(", "SizedBox(" -replace "width: double.infinity,`n              height:", "width: double.infinity,`n              height:"
Set-Content $file -Value $content

# Fix settings_page.dart
$file = "lib\features\dashboard\settings_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "Key\? key,", "super.key,"
$content = $content -replace ": super\(key: key\);", ";"
$content = $content -replace "\.withOpacity\(", ".withValues(alpha: "
$content = $content -replace "activeColor:", "activeThumbColor:"
$content = $content -replace "_SettingsPageState createState\(\) => _SettingsPageState\(\);", "State<SettingsPage> createState() => _SettingsPageState();"
Set-Content $file -Value $content

# Fix onboarding3_page.dart
$file = "lib\features\onboarding\onboarding3_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "if \(mounted\) \{ context.push\('/signup'\); \}", "context.push('/signup');"
Set-Content $file -Value $content

# Fix homepage.dart (onboarding)
$file = "lib\features\onboarding\homepage.dart"
$content = Get-Content $file -Raw
$content = $content -replace "Container\(`n                      width: double.infinity,`n                      height:", "SizedBox(`n                      width: double.infinity,`n                      height:"
Set-Content $file -Value $content

# Fix my_cv_page.dart - remove print
$file = "lib\features\dashboard\my_cv_page.dart"
$content = Get-Content $file -Raw
$content = $content -replace "print\('Error loading personal info: \`$e'\);", "// Error loading personal info"
Set-Content $file -Value $content

Write-Host "All fixes applied successfully!"
