#!/bin/bash

set -e

echo "🚀 Setting up TypeScript project..."

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

# Add scripts safely
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
