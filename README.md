# JUPITER Booster deep dive

Технічний аудит ресурсів JUPITER Booster для account `e-dev-2026d09-128`,
зафіксований 2 вересня 2026 року. Канонічною моделлю даних є
[`facts.json`](facts.json); Markdown і HTML мають узгоджуватися з нею.

Публічна інтерактивна версія: [u-lm.github.io/jupiter-deep-dive](https://u-lm.github.io/jupiter-deep-dive/).

## Документи

- [System architecture](system-architecture.md)
- [GH200 node and NUMA](node-gh200-numa.md)
- [Allocation and accounting](allocation-accounting.md)
- [Storage](storage.md)
- [Workload playbook](workload-playbook.md)
- [Evidence register](evidence-register.md)
- [Published HTML](index.html)

## Типи доказів

| Тип | Значення |
| --- | --- |
| `official` | Число або правило прямо опубліковане JSC, EuroHPC, NVIDIA чи Eviden. |
| `observed` | Результат поточного `sinfo`, `scontrol`, `jutil`, `sacct` або Slurm probe. |
| `derived` | Детермінований розрахунок з `official` або `observed` даних. |
| `inferred` | Інженерний висновок, який потребує обережності або окремого підтвердження. |

`source.confidence` оцінює придатність замороженого джерела для заявленого scope.
`fact.confidence` оцінює конкретне твердження. Validator не дозволяє твердженню
перевищувати confidence найслабшого використаного джерела.

## Межі аудиту

Installed Booster capacity, Slurm-visible стан, project allocation і storage quota
представлені окремими scopes. Snapshot швидко старіє, оскільки JUPITER перебуває
в Early Access. Для operational рішень слід повторно запустити read-only collector.

## Відтворення

```bash
scripts/collect_jupiter_snapshot.sh
scripts/run_jupiter_probes.sh
.venv/bin/python scripts/build_jupiter_evidence_register.py
.venv/bin/python scripts/build_jupiter_site.py
.venv/bin/python scripts/validate_jupiter_deep_dive.py
.venv/bin/pytest -q
npm ci
npm run test:site
```

Обчислювальні probes виконуються лише через Slurm. Raw evidence містить timestamp,
job ID, команди у batch scripts і SHA-256 checksums. Credentials у bundle не
зберігаються.
