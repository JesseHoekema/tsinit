#!/bin/bash

set -e

echo "🚀 Creating TypeScript project..."

if [ ! -f package.json ]; then
  pnpm init
fi

pnpm add -D typescript tsx @types/node

mkdir -p src

if [ ! -f src/index.ts ]; then
  cat <<EOL > src/index.ts
const greet = (name: string): string => {
  return \`Hello, \${name}!\`;
};

console.log(greet("World"));
EOL
fi

# Create tsconfig.json
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

# Create .gitignore
if [ ! -f .gitignore ]; then
  cat <<EOL > .gitignore
node_modules
dist
.DS_Store
*.log
EOL
  echo "📄 Created .gitignore"
fi

# Create README.md
cat <<EOL > README.md
# TypeScript Project

This project was initialized using [tsinit](https://github.com/JesseHoekema/tsinit).

## Getting Started

### Development
To run the project in development mode with auto-reloading:
\`\`\`bash
pnpm dev
\`\`\`

### Build
To compile the TypeScript code to JavaScript:
\`\`\`bash
pnpm build
\`\`\`

### Production
To run the compiled JavaScript code:
\`\`\`bash
pnpm start
\`\`\`
EOL
echo "📄 Created README.md"

# Add scripts safely using Node
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
"

echo "✅ Done!"
echo ""
echo "Run development mode with:"
echo "pnpm dev"
