#!/bin/sh
PYTHONIOENCODING=utf-8 python -c "
import sys, json, datetime

try:
    data = json.loads(sys.stdin.read())
    rl = data.get('rate_limits', {})
except Exception:
    sys.exit(0)

def fmt_reset(ts):
    try:
        return datetime.datetime.fromtimestamp(int(ts)).strftime('%m/%d %H:%M')
    except Exception:
        return ''

parts = []

model_name = data.get('model', {}).get('display_name', '')
if model_name:
    parts.append(model_name)

five = rl.get('five_hour', {})
if five.get('used_percentage') is not None:
    pct = five['used_percentage']
    reset = fmt_reset(five['resets_at']) if five.get('resets_at') else ''
    parts.append('S:' + str(round(pct)) + '%' + (' ' + reset if reset else ''))

week = rl.get('seven_day', {})
if week.get('used_percentage') is not None:
    pct = week['used_percentage']
    reset = fmt_reset(week['resets_at']) if week.get('resets_at') else ''
    parts.append('W:' + str(round(pct)) + '%' + (' ' + reset if reset else ''))

if parts:
    sys.stdout.buffer.write(' | '.join(parts).encode('utf-8'))
" <<< "$(cat)"