# AIG-02 AIG-13 AIG-16
# Microsoft Defender for Cloud "threat protection for AI services" (Defender
# for AI Services plan) on the subscription: resource_type "AI", tier
# "Standard". It raises security alerts for attacks on Azure OpenAI and Azure
# AI Model Inference deployments (text tokens only), which feed monitoring and
# incident response.
resource "azurerm_security_center_subscription_pricing" "ai" {
  count = var.enable_defender_for_ai ? 1 : 0

  resource_type = "AI"
  tier          = "Standard"

  # UNVERIFIED: whether the azurerm provider accepts the AIPromptEvidence
  # extension for resource_type AI. The ARM schema documents the extension
  # ("Exposes the prompts passed between the user and the AI model as alert
  # evidence"). Enable "user prompt evidence" in the portal, or test this
  # block in a sandbox subscription before uncommenting.
  # extension {
  #   name = "AIPromptEvidence"
  # }
}
