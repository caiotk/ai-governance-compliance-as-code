# Applicable risks. A risk from catalog/risks.yaml applies to a system when it
# is marked `always` or when any of its conditions holds on the record. The
# gate does not raise findings for risks (controls do that); it names them so
# reports and reviewers can see what the controls are treating.
package aigov

import data.aigov_catalog as catalog

risk_applies(rid) if catalog.risks[rid].always

risk_applies(rid) if {
	some c in catalog.risks[rid].any
	object.get(input, c.path, null) == c.equals
}

risks := sort([rid | some rid, _ in catalog.risks; risk_applies(rid)])
