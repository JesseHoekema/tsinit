#!/bin/bash

set -e

echo "🚀 Setting up TypeScript project..."

# Initialize package.json if it doesn't exist
if [ ! -f package.json ]; then
  pnpm init
fi

# Install core dependencies
pnpm add -D typescript tsx @types/node

# Create source directory
mkdir -p src

# Create a sample index file
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
  echo "📄 Added .gitignore"
fi

# Add scripts to package.json safely using Node
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
echo "To get started:"
echo "  1. Run development mode:  pnpm dev"
echo "  2. Build for production:  pnpm build"
echo "  3. Run the build:         pnpm start"
