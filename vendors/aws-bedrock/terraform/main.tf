data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  # The five harmful-content categories, all at the same strength on input and output.
  harmful_content_filters = ["HATE", "INSULTS", "SEXUAL", "VIOLENCE", "MISCONDUCT"]

  pii_entities = concat(var.baseline_pii_entities, var.additional_pii_entities)

  # ARN:version, the form accepted by bedrock:GuardrailIdentifier and by BEDROCK_POLICY.
  guardrail_identifier = "${aws_bedrock_guardrail.baseline.guardrail_arn}:${aws_bedrock_guardrail_version.baseline.version}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Guardrail
# ─────────────────────────────────────────────────────────────────────────────

# AIG-05 AIG-09 AIG-10
# Baseline guardrail: harmful-content and prompt-attack filters, PII masking and
# blocking, denied topics, managed profanity list and contextual grounding.
resource "aws_bedrock_guardrail" "baseline" {
  name                      = "${var.name_prefix}-baseline"
  description               = "AI governance baseline guardrail (AIG-05, AIG-10)."
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  kms_key_arn               = var.guardrail_kms_key_arn

  content_policy_config {
    dynamic "filters_config" {
      for_each = toset(local.harmful_content_filters)
      content {
        type            = filters_config.value
        input_strength  = var.content_filter_strength
        output_strength = var.content_filter_strength
      }
    }

    # Prompt attacks are only evaluated on input. For InvokeModel and
    # InvokeModelWithResponseStream the caller must wrap user input in guard
    # content tags, or prompt attacks are not filtered.
    filters_config {
      type            = "PROMPT_ATTACK"
      input_strength  = var.prompt_attack_strength
      output_strength = "NONE"
    }

    tier_config = [{ tier_name = var.guardrail_tier }]
  }

  sensitive_information_policy_config {
    dynamic "pii_entities_config" {
      for_each = local.pii_entities
      content {
        type   = pii_entities_config.value.type
        action = pii_entities_config.value.action
      }
    }

    dynamic "regexes_config" {
      for_each = var.pii_regexes
      content {
        name        = regexes_config.value.name
        description = regexes_config.value.description
        pattern     = regexes_config.value.pattern
        action      = regexes_config.value.action
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = length(var.denied_topics) > 0 ? [1] : []
    content {
      dynamic "topics_config" {
        for_each = var.denied_topics
        content {
          name       = topics_config.value.name
          definition = topics_config.value.definition
          examples   = topics_config.value.examples
          type       = "DENY"
        }
      }
      tier_config = [{ tier_name = var.guardrail_tier }]
    }
  }

  dynamic "word_policy_config" {
    for_each = var.enable_profanity_filter || length(var.blocked_words) > 0 ? [1] : []
    content {
      dynamic "managed_word_lists_config" {
        for_each = var.enable_profanity_filter ? ["PROFANITY"] : []
        content {
          type = managed_word_lists_config.value
        }
      }
      dynamic "words_config" {
        for_each = var.blocked_words
        content {
          text = words_config.value
        }
      }
    }
  }

  dynamic "contextual_grounding_policy_config" {
    for_each = var.enable_contextual_grounding ? [1] : []
    content {
      filters_config {
        type      = "GROUNDING"
        threshold = var.grounding_threshold
      }
      filters_config {
        type      = "RELEVANCE"
        threshold = var.relevance_threshold
      }
    }
  }

  dynamic "cross_region_config" {
    for_each = var.guardrail_profile_identifier == null ? [] : [var.guardrail_profile_identifier]
    content {
      guardrail_profile_identifier = cross_region_config.value
    }
  }

  lifecycle {
    precondition {
      condition     = var.guardrail_tier == "CLASSIC" || var.guardrail_profile_identifier != null
      error_message = "guardrail_tier = STANDARD needs guardrail_profile_identifier (cross-Region guardrail inference)."
    }
  }
}

# AIG-10 AIG-15
# Immutable, numbered version. IAM conditions and BEDROCK_POLICY must reference
# a numbered version, never DRAFT. A new version is cut whenever the guardrail
# changes; old versions are retained (skip_destroy) for audit and rollback.
resource "aws_bedrock_guardrail_version" "baseline" {
  guardrail_arn = aws_bedrock_guardrail.baseline.guardrail_arn
  description   = "Baseline version managed by Terraform."
  skip_destroy  = true

  lifecycle {
    replace_triggered_by = [aws_bedrock_guardrail.baseline]
  }
}
