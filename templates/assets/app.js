const TYPES = {
  diary:       'Diary',
  writing:     'Writing',
  simulation:  'Simulations',
  interactive: 'Interactive',
  animation:   'Animations',
  cartography: 'Cartography',
  art:         'Art',
  code:        'Code',
  exploration: 'Explorations',
  other:       'Other',
};

const EXT_MODE = {
  html: 'iframe', htm: 'iframe',
  md: 'markdown', markdown: 'markdown',
  txt: 'raw', text: 'raw', ascii: 'raw', log: 'raw', asc: 'raw',
  js: 'animation', mjs: 'animation',
  svg: 'svg',
  json: 'json',
  py: 'raw', sh: 'raw', bash: 'raw',
  ts: 'raw', rs: 'raw', go: 'raw', rb: 'raw',
  cpp: 'raw', c: 'raw', lua: 'raw', r: 'raw',
};

// Support files: present in the folder but never shown as tabs
const SUPPORT_EXTS = new Set(['css', 'map', 'lock']);

const EXT_COLOR = {
  js: '#f0b429', mjs: '#f0b429',
  html: '#e67e22', htm: '#e67e22',
  md: '#4a9edd', markdown: '#4a9edd',
  svg: '#a78bfa',
  json: '#34d399',
  py: '#4ade80', sh: '#4ade80', bash: '#4ade80',
  css: '#f472b6',
  ts: '#60a5fa',
};

// ── State ──────────────────────────────────────────

let entries     = [];
let activeEntry = null;
let folderFiles = [];
let splitMode   = false;
let panelAFile  = null;
let panelBFile  = null;

const panels = {
  a: { frame: null, rendered: null },
  b: { frame: null, rendered: null },
};

// ── Init ───────────────────────────────────────────

function init() {
  panels.a.frame    = document.getElementById('frame-a');
  panels.a.rendered = document.getElementById('rendered-a');
  panels.b.frame    = document.getElementById('frame-b');
  panels.b.rendered = document.getElementById('rendered-b');

  document.getElementById('split-btn').addEventListener('click', enterSplit);
  document.getElementById('unsplit-btn').addEventListener('click', exitSplit);

  initInfoBar();
  initResize();
  loadManifest();
  setInterval(loadManifest, 30000);
}

// ── Manifest ───────────────────────────────────────

async function loadManifest() {
  flash();
  try {
    const r = await fetch('pages/manifest.json?_=' + Date.now());
    if (!r.ok) throw 0;
    const fresh = await r.json();
    const changed = JSON.stringify(fresh) !== JSON.stringify(entries);
    entries = fresh;
    if (changed) renderSidebar();
  } catch {
    document.getElementById('entry-count').textContent = 'No pages yet';
  }
}

// ── Sidebar ────────────────────────────────────────

function renderSidebar() {
  const list  = document.getElementById('sidebar-entries');
  const count = document.getElementById('entry-count');

  if (!entries.length) {
    count.textContent = 'No creations yet';
    list.innerHTML = '<div class="no-entries">Corner sessions will appear here as Claude creates things.</div>';
    return;
  }

  count.textContent = entries.length === 1 ? '1 creation' : `${entries.length} creations`;

  const groups = {};
  [...entries].reverse().forEach(e => {
    const k = TYPES[(e.type || '').toLowerCase()] ? (e.type || 'other').toLowerCase() : 'other';
    (groups[k] = groups[k] || []).push(e);
  });

  list.innerHTML = '';
  for (const [type, items] of Object.entries(groups)) {
    const section = document.createElement('div');
    section.className = 'category';
    section.innerHTML = `<div class="category-label">${TYPES[type] || 'Other'}</div>`;

    for (const e of items) {
      const key = getKey(e);
      const ext = getExt(e);
      const el  = document.createElement('div');
      el.className   = 'entry' + (activeEntry && getKey(activeEntry) === key ? ' active' : '');
      el.dataset.key = key;
      el.innerHTML   = `
        <div class="entry-title">${x(e.title)}</div>
        <div class="entry-meta">
          <span class="entry-date">${x(fmt(e.date))}</span>
          ${ext ? `<span class="entry-ext">.${x(ext)}</span>` : ''}
        </div>`;
      el.addEventListener('click', () => openEntry(e));
      section.appendChild(el);
    }
    list.appendChild(section);
  }
}

// ── Open entry ─────────────────────────────────────

async function openEntry(e) {
  activeEntry = e;

  document.querySelectorAll('.entry').forEach(el =>
    el.classList.toggle('active', el.dataset.key === getKey(e))
  );

  if (e.folder) {
    if (e.files && e.files.length) {
      folderFiles = e.files;
    } else {
      folderFiles = await fetchFolderFiles(e.folder);
      if (!folderFiles.length) folderFiles = e.entry ? [e.entry] : [];
    }
    folderFiles = folderFiles.filter(f => !SUPPORT_EXTS.has(f.split('.').pop().toLowerCase()));
  } else if (e.file) {
    folderFiles = [e.file.split('/').pop()];
  } else {
    folderFiles = [];
  }

  // Put the entry file first
  if (e.entry && folderFiles.includes(e.entry)) {
    folderFiles = [e.entry, ...folderFiles.filter(f => f !== e.entry)];
  }

  panelAFile = e.entry || folderFiles[0] || null;
  panelBFile = folderFiles.find(f => f !== panelAFile) || folderFiles[0] || null;

  if (!splitMode) {
    document.getElementById('tab-bar').style.display = folderFiles.length ? 'flex' : 'none';
  }
  document.getElementById('split-btn').style.display = folderFiles.length > 1 ? '' : 'none';

  buildTabs();
  updateInfoBar(e);

  document.getElementById('empty-state').style.display = 'none';

  if (panelAFile) await renderFile('a', panelAFile);
  if (splitMode && panelBFile) await renderFile('b', panelBFile);
}

// ── Fetch folder files ─────────────────────────────

async function fetchFolderFiles(folder) {
  try {
    const r = await fetch(`pages/${folder}/`);
    if (!r.ok) return [];
    const html = await r.text();
    const doc  = new DOMParser().parseFromString(html, 'text/html');
    return [...doc.querySelectorAll('a[href]')]
      .map(a => decodeURIComponent(a.getAttribute('href') || ''))
      .filter(h => h && h !== '../' && h !== './' && !h.endsWith('/') && !h.startsWith('?') && !h.startsWith('http'));
  } catch {
    return [];
  }
}

// ── Build tab bars ─────────────────────────────────

function buildTabs() {
  const targets = splitMode
    ? [{ id: 'tab-list-a', panel: 'a' }, { id: 'tab-list-b', panel: 'b' }]
    : [{ id: 'tab-list-single', panel: 'a' }];

  for (const { id, panel } of targets) {
    const container = document.getElementById(id);
    if (!container) continue;
    container.innerHTML = '';

    const activeFile = panel === 'a' ? panelAFile : panelBFile;

    for (const filename of folderFiles) {
      const ext   = filename.split('.').pop().toLowerCase();
      const color = EXT_COLOR[ext] || '#4E4A46';

      const tab = document.createElement('div');
      tab.className = 'tab' + (filename === activeFile ? ' active' : '');
      tab.innerHTML = `<span class="tab-dot" style="background:${color}"></span>${x(filename)}`;
      tab.addEventListener('click', () => selectFile(panel, filename));
      container.appendChild(tab);
    }
  }
}

async function selectFile(panelId, filename) {
  if (panelId === 'a') panelAFile = filename;
  else panelBFile = filename;
  buildTabs();
  await renderFile(panelId, filename);
}

// ── Render file into panel ─────────────────────────

async function renderFile(panelId, filename) {
  const e = activeEntry;
  if (!e || !filename) return;

  const url  = e.folder ? `pages/${e.folder}/${filename}` : `pages/${e.file}`;
  const ext  = filename.split('.').pop().toLowerCase();
  const mode = EXT_MODE[ext] || 'raw';

  const { frame, rendered } = panels[panelId];

  frame.style.display    = 'none';
  rendered.style.display = 'none';
  frame.removeAttribute('srcdoc');
  frame.removeAttribute('src');

  try {
    if (mode === 'iframe') {
      frame.src = url;
      frame.style.display = 'block';

    } else if (mode === 'markdown') {
      await ensureMarked();
      const text = await fetch(url + '?_=' + Date.now()).then(r => r.text());
      rendered.innerHTML     = `<div class="md-body">${marked.parse(text)}</div>`;
      rendered.style.display = 'block';

    } else if (mode === 'animation') {
      const code = await fetch(url + '?_=' + Date.now()).then(r => r.text());
      frame.srcdoc        = wrapAnimation(code);
      frame.style.display = 'block';

    } else if (mode === 'svg') {
      const svg = await fetch(url + '?_=' + Date.now()).then(r => r.text());
      rendered.innerHTML     = `<div class="svg-body">${svg}</div>`;
      rendered.style.display = 'block';

    } else if (mode === 'json') {
      const raw = await fetch(url + '?_=' + Date.now()).then(r => r.text());
      try {
        rendered.innerHTML = `<pre class="json-body">${x(JSON.stringify(JSON.parse(raw), null, 2))}</pre>`;
      } catch {
        rendered.innerHTML = `<pre class="raw-body">${x(raw)}</pre>`;
      }
      rendered.style.display = 'block';

    } else {
      const text = await fetch(url + '?_=' + Date.now()).then(r => r.text());
      rendered.innerHTML     = `<pre class="raw-body">${x(text)}</pre>`;
      rendered.style.display = 'block';
    }
  } catch {
    rendered.innerHTML     = `<pre class="raw-body">Could not load: ${x(url)}</pre>`;
    rendered.style.display = 'block';
  }
}

// ── Split ──────────────────────────────────────────

function enterSplit() {
  if (!activeEntry || folderFiles.length < 2) return;
  splitMode = true;

  document.getElementById('tab-bar').style.display        = 'none';
  document.getElementById('panel-a-tabrow').style.display = 'flex';
  document.getElementById('panel-b').style.display        = 'flex';
  document.getElementById('panel-b-tabrow').style.display = 'flex';
  document.getElementById('resize-handle').style.display  = 'block';

  buildTabs();
  if (panelBFile) renderFile('b', panelBFile);
}

function exitSplit() {
  splitMode = false;

  document.getElementById('tab-bar').style.display        = folderFiles.length ? 'flex' : 'none';
  document.getElementById('panel-a-tabrow').style.display = 'none';
  document.getElementById('panel-b').style.display        = 'none';
  document.getElementById('panel-b-tabrow').style.display = 'none';
  document.getElementById('resize-handle').style.display  = 'none';

  document.getElementById('panel-a').style.flex = '';
  document.getElementById('panel-b').style.flex = '';

  buildTabs();
}

// ── Info bar ───────────────────────────────────────

function updateInfoBar(e) {
  const bar = document.getElementById('info-bar');
  if (!e) { bar.style.display = 'none'; return; }

  const typeName  = TYPES[(e.type || '').toLowerCase()] || (e.type || 'Other');
  const dateStr   = fmt(e.date);
  const fileCount = folderFiles.length;

  document.getElementById('info-type-badge').textContent    = typeName;
  document.getElementById('info-summary-date').textContent  = dateStr;
  document.getElementById('info-summary-files').textContent = fileCount > 1 ? `${fileCount} files` : '';

  document.getElementById('info-title-full').textContent  = e.title || '';
  document.getElementById('info-meta-type').textContent   = typeName;
  document.getElementById('info-meta-date').textContent   = dateStr;
  document.getElementById('info-meta-files').textContent  =
    fileCount === 1 ? `${fileCount} file` : `${fileCount} files`;

  bar.style.display       = 'flex';
  bar.style.flexDirection = 'column';
}

function initInfoBar() {
  document.getElementById('info-summary').addEventListener('click', () => {
    document.getElementById('info-bar').classList.toggle('expanded');
  });
}

// ── Resize drag ────────────────────────────────────

function initResize() {
  const handle  = document.getElementById('resize-handle');
  const panelA  = document.getElementById('panel-a');
  const panelB  = document.getElementById('panel-b');
  const viewers = document.getElementById('viewers');
  let dragging  = false;

  handle.addEventListener('mousedown', e => {
    dragging = true;
    handle.classList.add('dragging');
    document.body.style.cursor     = 'col-resize';
    document.body.style.userSelect = 'none';
    e.preventDefault();
  });

  document.addEventListener('mousemove', e => {
    if (!dragging) return;
    const rect    = viewers.getBoundingClientRect();
    const handleW = handle.offsetWidth;
    const total   = rect.width - handleW;
    const pct     = Math.min(Math.max((e.clientX - rect.left) / total * 100, 15), 85);
    panelA.style.flex = `0 0 ${pct}%`;
    panelB.style.flex = `0 0 ${100 - pct}%`;
  });

  document.addEventListener('mouseup', () => {
    if (!dragging) return;
    dragging = false;
    handle.classList.remove('dragging');
    document.body.style.cursor     = '';
    document.body.style.userSelect = '';
  });
}

// ── Helpers ────────────────────────────────────────

function wrapAnimation(code) {
  const escaped = code.replace(/<\/script>/gi, '<\\/script>');
  return `<!DOCTYPE html><html><head>
<meta charset="UTF-8">
<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#191714;overflow:hidden}canvas{display:block}</style>
</head><body>
<canvas id="canvas"></canvas>
<script>
const canvas=document.getElementById('canvas');
const ctx=canvas.getContext('2d');
function _resize(){canvas.width=window.innerWidth;canvas.height=window.innerHeight;}
_resize();
window.addEventListener('resize',_resize);
${escaped}
<\/script>
</body></html>`;
}

function getKey(e) { return e.folder || e.file || ''; }

function getExt(e) {
  const name = (e.entry || (e.file ? e.file.split('/').pop() : '')) || '';
  const parts = name.split('.');
  return parts.length > 1 ? parts.pop().toLowerCase() : '';
}

function flash() {
  const p = document.getElementById('pulse');
  p.classList.add('on');
  setTimeout(() => p.classList.remove('on'), 500);
}

function fmt(s) {
  if (!s) return '';
  try {
    return new Date(s + 'T12:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  } catch { return s; }
}

function x(s) {
  return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

async function ensureMarked() {
  if (typeof marked !== 'undefined') return;
  return new Promise((resolve, reject) => {
    const s   = document.createElement('script');
    s.src     = 'https://cdn.jsdelivr.net/npm/marked/marked.min.js';
    s.onload  = resolve;
    s.onerror = () => reject(new Error('Could not load marked.js'));
    document.head.appendChild(s);
  });
}

init();
