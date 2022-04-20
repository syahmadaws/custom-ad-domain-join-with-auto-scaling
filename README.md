# custom-ad-domain-join-with-auto-scaling
Custom Active Directory (AD) domain join and unjoin with an AWS Systems Manager Automation runbook. The template leverages AWS Systems Manager Parameter Store for AD credentials and Organizational Unit (OU) management, custom PowerShell to perform basic domain join or domain unjoin (removal) from AD, and tags instances based on the action selected (Join or Unjoin). For scalability, the template also supports Auto Scaling groups based on launch and termination lifecycle hooks, https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html. The Auto Scaling group is associated with an Elastic Load Balancer (ELB), both of which are launched using an included AWS CloudFormation template.

# Prerequisites
To get started, a new Automation runbook needs to be created in the account where domain join/unjoin activities will be managed. The document is YAML formatted and can simply be copied and pasted into the SSM Document editor.

The Automation runbook requires parameters stored in SSM Parameter Store to complete the domain join and unjoining activities. This includes the AD domain name (FQDN), AD username, AD password, and a targetOU. To learn more about Parameter Store, visit the [AWS documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html).

Create new parameters with the following names, value, and type (the values are cAsE-SeNsItIvE):

AD domain name
- **Name** : *domainName*
- **Value** : *corp.example.com*
- **Type** : String

AD user with domain join rights
- **Name** : *domainJoinUserName*
- **Value** : *CORP\domainadmin*
- **Type** : String

AD user password
*Requires an AWS KMS key*
- **Name** : *domainJoinPassword*
- **Value** : *YOURSECRET*
- **Type** : SecureString

Specify the target Organization Unit (OU) for the domain account.
- **Name** : *defaultTargetOU*
- **Value** : *OU=Servers,OU=CORP,dc=corp,dc=example,dc=com*
- **Type** : String
