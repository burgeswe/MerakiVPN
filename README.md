# MerakiVPN

This script was created to allow for an automated creation of a VPN for Meraki Clients.

Since Meraki doesn't support Always-On VPN, the only way I could think of to do this was to create a PowerShell Script to run one time on each user's profile.

The additional settings to disable Split Tunnelling, Force Interface Metric, and Optionally Allow for processing on the 192.168.1.x network were to fix specific problems in my environment, but I left them in for posterity and in case anyone needs help figuring it out like I did
