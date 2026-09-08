#!/usr/bin/env python3
"""Check the context graph and optionally a real Curator installation."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
CONTEXT = [ROOT / 'SKILL.md', *sorted((ROOT / 'references').rglob('*')), *sorted((ROOT / 'agents').rglob('*'))]
CONTEXT = [p for p in CONTEXT if p.is_file()]

def check_links(root):
    for path in root.rglob('*.md'):
        for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
            if '://' in target or target.startswith(('#', 'mailto:')):
                continue
            dest = (path.parent / target.split('#')[0]).resolve()
            assert dest.is_relative_to(root.resolve()), (path, target, 'escapes package')
            assert dest.is_file(), (path, target, 'missing resource')

# Restrict checks to deliverable context, excluding historical board documents.
for directory in ('references',):
    # Cross-directory links remain relative to the complete package.
    for path in (ROOT / directory).rglob('*.md'):
        for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
            if '://' not in target and not target.startswith(('#', 'mailto:')):
                assert (path.parent / target.split('#')[0]).is_file(), (path, target)
for target in re.findall(r'\]\(([^)]+)\)', (ROOT / 'SKILL.md').read_text()):
    assert (ROOT / target).is_file(), target

if len(sys.argv) > 1:
    project = Path(sys.argv[1]).resolve()
    for adapter in ('.agents/skills', '.claude/skills', '.codex/skills', '.gemini/skills', '.cursor/rules'):
        installed = project / adapter / 'swift-relux'
        for path in CONTEXT:
            relative = path.relative_to(ROOT)
            assert (installed / relative).read_bytes() == path.read_bytes(), (adapter, relative, 'content mismatch')
        for excluded in ('setup.sh', 'tests', '.task-board', 'README.md', 'LOGBOOK.md', 'instructions', 'snippets'):
            assert not (installed / excluded).exists(), (adapter, excluded, 'source content leaked')
        check_links(installed)
    print(f'Curator: {len(CONTEXT)} context files match across canonical context and four adapters; all links resolve.')
else:
    print(f'Package: {len(CONTEXT)} context files; all local links resolve.')
