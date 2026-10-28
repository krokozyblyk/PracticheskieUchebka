const fs = require('node:fs');
const path = require('node:path');

const root = process.argv[2] || 'build/web';
const canvaskit = path.join(root, 'canvaskit');

let removed = 0;

function remove(file) {
  if (fs.existsSync(file) && fs.statSync(file).isFile()) {
    removed += fs.statSync(file).size;
    fs.unlinkSync(file);
  }
}

function stripSymbols(directory) {
  if (!fs.existsSync(directory)) return;
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const full = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      stripSymbols(full);
    } else if (entry.name.endsWith('.symbols')) {
      remove(full);
    }
  }
}

stripSymbols(canvaskit);

if (fs.existsSync(root)) {
  for (const entry of fs.readdirSync(root)) {
    if (/^main\.dart\.js_\d+\.part\.js$/.test(entry)) {
      remove(path.join(root, entry));
    }
  }
}

console.log(`removed ${removed} bytes of unused debug files`);
