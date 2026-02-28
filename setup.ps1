$OutputEncoding = [System.Text.Encoding]::UTF8
$Esc = [char]27
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$Blue = "$Esc[34m"
$Green = "$Esc[32m"
$Yellow = "$Esc[33m"

function Confirm-Action ($Message) {
    $choice = Read-Host "$Bold??$Reset $Message [y/N]"
    return $choice -match '^[Yy]$'
}

Clear-Host
Write-Host "$Blue$Bold`tsinit$Reset | TypeScript Project Generator" -NoNewline
Write-Host "`n------------------------------------------"


Write-Host "$Bold`Select a project template:$Reset"
Write-Host "1) Starter (Simple console.log)"
Write-Host "2) Test Logic (Greet + Add functions)"
$template_choice = Read-Host "Selection [1-2]"

if (!(Test-Path "package.json")) {
    pnpm init | Out-Null
}

Write-Host -NoNewline "?? Installing dependencies... "
pnpm add -D typescript tsx @types/node | Out-Null
Write-Host "$Green`Done$Reset"

if (!(Test-Path "src")) { New-Item -ItemType Directory -Path "src" | Out-Null }

if ($template_choice -eq "2") {
    $content = @"
const greet = (name: string): string => \`Hello, \${name}!\`;
const add = (a: number, b: number): number => a + b;

console.log(greet("Developer"));
console.log(\`Total: \${add(5, 10)}\`);
"@
} else {
    $content = 'console.log("Hello World");'
}
Set-Content -Path "src\index.ts" -Value $content

$tsconfig = @"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
"@
Set-Content -Path "tsconfig.json" -Value $tsconfig

# 5. Optional Files
if (Confirm-Action "Add .gitignore?") {
    $gitignore = "node_modules`ndist`n.DS_Store`n*.log"
    Set-Content -Path ".gitignore" -Value $gitignore
}

if (Confirm-Action "Add README.md (with tsinit credits)?") {
    $readme = @"
# Project

Initialized with [tsinit](https://github.com/JesseHoekema/tsinit).

- Dev: \`pnpm dev\`
- Build: \`pnpm build\`
- Start: \`pnpm start\`
"@
    Set-Content -Path "README.md" -Value $readme
}

node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json'));
pkg.scripts = {
  ...pkg.scripts,
  build: 'tsc',
  dev: 'tsx src/index.ts',
  start: 'node dist/index.js'
};
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
" | Out-Null

Write-Host "`n$Green`🚀 Project ready.$Reset"
Write-Host "Run $Yellow`pnpm dev$Reset to start."