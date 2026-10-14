# `incidents/`

One YAML record per runtime incident, written by [`hooks/receiver.py`](../hooks/README.md)
from platform events or opened by hand with `tools/incident.py`. Open
incidents show up in `docs/INVENTORY.md`, in `tools/report.py` audit packs and,
when high or critical, in the weekly review-reminder issues (AIG-16).

Records hold only allow-listed fields from the source event — never prompts,
completions or personal data. Close an incident with
`python3 tools/incident.py close INC-… --resolution "…"` in a pull request so
the closure is reviewed like any other change.

Triage queues, assignment, SLA timers and Slack/Jira routing are part of the
NexGuide.AI GovMap edition (see `docs/EDITIONS.md`).
