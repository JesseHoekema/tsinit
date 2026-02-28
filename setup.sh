set -e
RESET='\033[0m'
BOLD='\033[1m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'

confirm() {
    read -p "$(echo -e "${BOLD}??${RESET} $1 [y/N]: ")" choice
    [[ "$choice" =~ ^[Yy]$ ]]
}


clear
echo -e "${BLUE}${BOLD}tsinit${RESET} | TypeScript Project Generator"
echo "------------------------------------------"


echo -e "${BOLD}Select a project template:${RESET}"
echo "1) Starter (Simple console.log)"
echo "2) Test Logic (Greet + Add functions)"
read -p "Selection [1-2]: " template_choice


if [ ! -f package.json ]; then
    pnpm init > /dev/null 2>&1
fi

echo -n "?? Installing dependencies... "
pnpm add -D typescript tsx @types/node > /dev/null 2>&1
echo -e "${GREEN}Done${RESET}"


mkdir -p src
if [ "$template_choice" = "2" ]; then
    cat <<EOL > src/index.ts
const greet = (name: string): string => \`Hello, \${name}!\`;
const add = (a: number, b: number): number => a + b;

console.log(greet("Developer"));
console.log(\`Total: \${add(5, 10)}\`);
EOL
else
    cat <<EOL > src/index.ts
console.log("Hello World");
EOL
fi


cat <<EOL > tsconfig.json
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
EOL


if confirm "Add .gitignore?"; then
    cat <<EOL > .gitignore
node_modules
dist
.DS_Store
*.log
EOL
fi

if confirm "Add README.md (with tsinit credits)?"; then
    cat <<EOL > README.md


Initialized with [tsinit](https://github.com/JesseHoekema/tsinit).


- Dev: \`pnpm dev\`
- Build: \`pnpm build\`
- Start: \`pnpm start\`
EOL
fi


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
" > /dev/null 2>&1

echo -e "\n${GREEN}🚀 Project ready.${RESET}"
echo -e "Run ${YELLOW}pnpm dev${RESET} to start."