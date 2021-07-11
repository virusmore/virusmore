 Name: netdog

 Version: 0.2

 Description:
 Check if default gateway DOES exist, if so, output network and mask number

 Params:
 $1 - what kind of network will be processed
		0: A-Sec Net
		1: B-Sec Net
		2: C-Sec Net
 $2 - network ID without masks, such as 10, 10.0, 10.10.0
 $3 - num of packets to be sent by each ping command, default 1 packet
 $4 - deadline of ping command, default 1 sec


 Change Log:
 20210711:
	-- $3 added. This param defines a user specific ICMP packet to be sent, default 1,
		if network is in jam, this may be increased to a larger integer
	-- $4 added. This param defines a user specific deadline for waiting for income ICMP
		response, default 1 second. This usually works well for IoT network or intranet.
		However, this may be tuned by user to cope with network in jam.
	-- As Darwin and Linux are NOT the same in ping command options, so discover_cnet is
		modified to detect the OS running. This means you can run this script on darwin &
		linux from now on without considering the diffierences any more.

ATTENTION$:
1. Random ping is NOT implemented in this version, maybe next version.
2. If default gateway IP are NOT *.*.*.1 or *.*.*.254, you may easily add new ones for your own in the
   for-loop statement
3. Keep it in mind that our team just focus on making IoT hacking much easier on mobile hacking platform,
   so do NOT see things in the f*cking old view of PC or Laptop. Got it?
