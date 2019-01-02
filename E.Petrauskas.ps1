<# TASK:
Please write a script (PowerShell / PowerCLI), which will assign virtual machines to predefined DRS group and Resource Pool:
In vm notes there should be 2 additional lines of information defining service level (to which resource pool should vm go) and DRS group accord to datacenter site:

ResourcePool:

Good (in vm notes will be note “serviceLevel: Good”)

Better (in vm notes will be note “serviceLevel: Better”)

Best (in vm notes will be note “serviceLevel: Best”)

DRS group:

DC1_vms (in vm notes will be note “SiteAffinity: DC1_VMs”)

DC2_vms (in vm notes will be note “SiteAffinity: DC2_VMs”)

Script should go through all compute clusters in vCenter and check, if all virtual machines are assigned to correct 
DRS group and resourcepool (or even without resourcepool or DRS group). If machine is assigned to wrong DRS group or 
resourcepool it should be moved to correct one according to information provided in notes (same for vms without 
resourcepool or DRS groups).

If machine doesn’t have notes, which indicates to which DRS group machine should be assigned, we by default assign it 
to DRS group which matches naming of datastore (e.x. Big_datastore_DC1_sample or Big_datastore_DC2_sample).

If machine doesn’t have note, which shows resource pool – assig it to lowest one – Good.

Example of virtual machine notes:

Requester: Petras Petrauskas
Role: Plain
serviceLevel: Best
environment: Prod
Is_sched_for_decomm: No
RequestNumber: 088a4092-36ea-4fac-b080-d7f262a51c80
SiteAffinity: DC1_VMs
#>

$allvms = get-vm
$VMNotes = $allvms | Select-Object Name, Notes |fl

foreach ($vm in $allvms) {

	if ($vm.notes -like "*serviceLevel*" -OR $vm.notes -like "*SiteAffinity*" ) { 

		if ($vm.notes -like "*serviceLevel: Best*") { 
			if ($vm.resourcepool.name -ne "Best") {Move-VM -VM $vm -Destination "Best" -RunAsync}
		}
		if ($vm.notes -like "*serviceLevel: Good*") {
			if ($vm.resourcepool.name -ne "Good") {Move-VM -VM $vm -Destination "Good" -RunAsync}
		}
		if ($vm.notes -like "*serviceLevel: Better*") {
			if ($vm.resourcepool.name -ne "Better") {Move-VM -VM $vm -Destination "Better" -RunAsync}
		}
		if ($vm.notes -like "*SiteAffinity: DC1_VMs*") {
			if (($vm|Get-DrsClusterGroup).name -ne "DC1_VMs") {($vm|Get-DrsClusterGroup)|Set-DrsClusterGroup -VM $vm -remove; Set-DrsClusterGroup -DrsClusterGroup DC1_VMs -VM $vm -add}
		}	
		if ($vm.notes -like "*SiteAffinity: DC2_VMs*") {
			if (($vm|Get-DrsClusterGroup).name -ne "DC2_VMs") {($vm|Get-DrsClusterGroup)|Set-DrsClusterGroup -VM $vm -remove; Set-DrsClusterGroup -DrsClusterGroup DC2_VMs -VM $vm -add}
		}	
	}	
	else {
		if ($vm.notes -notlike "*serviceLevel:*" ) {
			if ($vm.resourcepool.name -ne "Good") {Move-VM -VM $vm -Destination "Good" -RunAsync}
		}
		if ($vm.notes -notlike "*SiteAffinity:*") {
			if (($vm|Get-Datastore).name -eq "Big_datastore_DC1_sample" ) {($vm|Get-DrsClusterGroup)|Set-DrsClusterGroup -VM $vm -remove; Set-DrsClusterGroup -DrsClusterGroup DC1_VMs -VM $vm -add}
		}
		if ($vm.notes -notlike "*SiteAffinity:*") {
			if (($vm|Get-Datastore).name -eq "Big_datastore_DC2_sample" ) {($vm|Get-DrsClusterGroup)|Set-DrsClusterGroup -VM $vm -remove; Set-DrsClusterGroup -DrsClusterGroup DC2_VMs -VM $vm -add}
		}
	}
		
}











































<#Evaldas Petrauskas 
petrauskasevaldas92@gmail.com
#>


