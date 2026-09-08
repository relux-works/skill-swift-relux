#!/usr/bin/env python3
"""Install a signed task-local snapshot with Curator; never change user config."""
from pathlib import Path
import json
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
(ROOT / '.temp').mkdir(exist_ok=True)
RUN = Path(tempfile.mkdtemp(prefix='curator-test-', dir=ROOT / '.temp'))
SOURCE = RUN / 'sources' / 'swift-relux'
PROJECT = RUN / 'project'
SOURCE.mkdir(parents=True)
PROJECT.mkdir()
ENV = dict(os.environ, CURATOR_CONFIG=str(RUN / 'config.json'))

def run(*args, cwd=ROOT):
    result = subprocess.run(args, cwd=cwd, env=ENV, text=True, capture_output=True)
    with (RUN / 'commands.log').open('a') as log:
        log.write(f'$ {args!r}\n{result.stdout}{result.stderr}exit={result.returncode}\n')
    if result.returncode:
        raise RuntimeError(f'{args[0]} failed; see {RUN / "commands.log"}')
    return result.stdout.strip()

print(f'Evidence: {RUN}', flush=True)
for name in ('SKILL.md', 'agent-skill.json', 'agents', 'references', 'README.md', 'setup.sh', 'tests', 'LOGBOOK.md', 'task-board.config.json'):
    src, dst = ROOT / name, SOURCE / name
    if src.is_dir():
        shutil.copytree(src, dst, ignore=shutil.ignore_patterns('__pycache__'))
    elif src.exists():
        shutil.copy2(src, dst)
run('git', 'init', '-b', 'main', str(SOURCE))
# Carry the configured human identity and signing settings into the fixture.
for key in ('user.name', 'user.email', 'user.signingkey', 'gpg.format', 'gpg.ssh.allowedSignersFile', 'gpg.program', 'gpg.ssh.program'):
    value = subprocess.run(['git', 'config', '--get', key], cwd=ROOT, text=True, capture_output=True)
    if value.returncode == 0:
        run('git', 'config', key, value.stdout.strip(), cwd=SOURCE)
run('git', 'add', '.', cwd=SOURCE)
run('git', 'commit', '-S', '-m', 'test: snapshot Swift Relux Curator package', cwd=SOURCE)
run('git', 'verify-commit', 'HEAD', cwd=SOURCE)
revision = run('git', 'rev-parse', 'HEAD', cwd=SOURCE)
(RUN / 'config.json').write_text(json.dumps({'schema_version': 1, 'skills_root': str(RUN / 'sources'), 'projects': {}, 'adapter_mode': 'copy'}))
(PROJECT / 'Skillfile.json').write_text(json.dumps({'schema_version': 1, 'agents': ['claude_code', 'codex_cli', 'gemini', 'cursor', 'opencode', 'windsurf'], 'skills': [{'name': 'swift-relux', 'source': 'swift-relux', 'revision': revision}]}))
run('curator', 'skill', 'check', str(SOURCE))
run('curator', 'install', str(PROJECT), '--fix-gitignore')
run('python3', str(ROOT / 'tests/package_test.py'), str(PROJECT))
run('curator', 'status', str(PROJECT), '--check')
run('curator', 'install', str(PROJECT))
run('python3', str(ROOT / 'tests/package_test.py'), str(PROJECT))
print(f'PASS: signed snapshot {revision}; install, four adapters, reference graph, status and repeat install.')
