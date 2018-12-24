This script will create many of the necessary components needed to configure an instance of the NSX-V Distributed Firewall.

Step 1 - Update the CSV files with the proper information. If you don't know what the proper information is, don't touch them!
Step 2 - Login to NSX Manager
Step 3 - Run the Powershell script
Step 4 - After each step, manually validate that the objects were created. 
		Services (NSX Manager > Grouping Objects > Services)
		Services (NSX Manager > Grouping Objects > Service Groups)
		Security Groups with Tags (NSX Manager > Security Composer > Security Groups) & (NSX Manager > Security Tags)
		Security Groups with IPSets (NSX Manager > Security Composer > Security Groups)
		Security Groups with Dynamic Membership (NSX Manager > Security Composer > Security Groups) & (NSX Manager > Grouping Objects > IPSets)

Note : IPSets are used to make specific IP addresses members of a Security Group, since a Security Tag cannot be associated to servers that exist outside of NSX's scope, within a single vCenter. For example, NTP servers are in the INFRA vCenter, not in the yCommerce vCenter, therefore, NSX does not see the VM, it only knows the IP address.
