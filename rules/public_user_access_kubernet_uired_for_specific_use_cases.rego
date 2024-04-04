package rules.public_user_access_kubernet_uired_for_specific_use_cases

__rego__metadoc__ := {
	"custom": {
		"controls": {
			"Kubernetes": [
				"Kubernetes_1.0"
			]
		},
		"severity": "Medium"
	},
	"description": "Document: Technology Engineering - AWS EKS - Best Practice - Version: 1",
	"id": "1.0",
	"title": "Public user access to kubernetes clusters shall be restricted unless explicitly required for specific use cases.",
}

# Please write your OPA rule here
resource_type := "aws_subnet"

default allow = false

allow {
	input.map_public_ip_on_launch == false
}
