# Evidence as code. When a record carries an `evidence` block, every control the
# applicable frameworks require must have at least one evidence item, and that
# item must still be within its validity window on the evaluation date.
#
#   evidence:
#     enforce: true              # stale evidence is a deny (default: warn)
#     default_valid_days: 365
#     items:
#       - control: AIG-03
#         type: document
#         ref: https://wiki.example.com/aia/credit-assistant
#         date: "2026-08-01"
#         valid_days: 365
#
# Records without an `evidence` block are not checked, so adopting evidence is
# opt-in per system. Missing evidence is always a warning: the gate blocks on
# the control itself, not on the paperwork for it.
package aigov

evidence_present if is_object(input.evidence)

evidence_items[c] contains item if {
	some item in object.get(input, ["evidence", "items"], [])
	c := item.control
}

valid_days(item) := item.valid_days if {
	item.valid_days
} else := object.get(input.evidence, "default_valid_days", 365)

expiry(item) := time.format([time.add_date(time.parse_ns("2006-01-02", item.date), 0, 0, valid_days(item)), "UTC", "2006-01-02"])

fresh[c] if {
	some c, items in evidence_items
	some item in items
	eval_date <= expiry(item)
}

latest_expiry[c] := max({expiry(item) | some item in items}) if {
	some c, items in evidence_items
}

stale_severity := "deny" if {
	input.evidence.enforce == true
} else := "warn"

findings contains {
	"id": sprintf("evidence:%s:missing", [c]),
	"control": c,
	"severity": "warn",
	"frameworks": sort([fw | some fw in fws]),
	"message": sprintf("no evidence recorded for required control %s; add an evidence item (document, ticket, scan, test report or attestation)", [c]),
} if {
	evidence_present
	some c, fws in required
	not evidence_items[c]
}

findings contains {
	"id": sprintf("evidence:%s:stale", [c]),
	"control": c,
	"severity": stale_severity,
	"frameworks": sort([fw | some fw in fws]),
	"message": sprintf("evidence for %s expired on %s; refresh it (evidence.enforce=%v)", [c, latest_expiry[c], input.evidence.enforce == true]),
} if {
	evidence_present
	some c, fws in required
	evidence_items[c]
	not fresh[c]
}

evidence_status[c] := "fresh" if {
	evidence_present
	some c, _ in required
	fresh[c]
}

evidence_status[c] := "stale" if {
	evidence_present
	some c, _ in required
	evidence_items[c]
	not fresh[c]
}

evidence_status[c] := "missing" if {
	evidence_present
	some c, _ in required
	not evidence_items[c]
}
