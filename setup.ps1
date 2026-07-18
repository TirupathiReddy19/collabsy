# ==========================================
# Collabsy - Milestone 1 Project Setup
# ==========================================

Write-Host "🚀 Setting up Collabsy project structure..." -ForegroundColor Cyan

$folders = @(
    "lib/app",

    "lib/core",
    "lib/core/constants",
    "lib/core/theme",
    "lib/core/utils",
    "lib/core/services",
    "lib/core/extensions",

    "lib/shared",
    "lib/shared/widgets",
    "lib/shared/models",
    "lib/shared/components",
    "lib/shared/animations",

    "lib/features",
    "lib/features/splash",
    "lib/features/onboarding",
    "lib/features/auth",
    "lib/features/creator",
    "lib/features/brand",
    "lib/features/profile",

    "assets",
    "assets/images",
    "assets/icons",
    "assets/fonts",
    "assets/animations"
)

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Host "✔ Created $folder"
    }
    else {
        Write-Host "⏩ Exists $folder"
    }
}

Write-Host ""
Write-Host "✅ Folder structure created successfully!" -ForegroundColor Green