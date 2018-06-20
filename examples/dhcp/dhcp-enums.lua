MESSAGE_TYPES = {
[0]="Pad",
[1]="Subnet Mask",
[2]="Time Offset",
[3]="Router",
[4]="Time Server",
[5]="Name Server",
[6]="Domain Server",
[7]="Log Server",
[8]="Quotes Server",
[9]="LPR Server",
[10]="Impress Server",
[11]="RLP Server",
[12]="Hostname",
[13]="Boot File Size",
[14]="Merit Dump File",
[15]="Domain Name",
[16]="Swap Server",
[17]="Root Path",
[18]="Extension File",
[19]="Forward On/Off",
[20]="SrcRte On/Off",
[21]="Policy Filter",
[22]="Max DG Assembly",
[23]="Default IP TTL",
[24]="MTU Timeout",
[25]="MTU Plateau",
[26]="MTU Interface",
[27]="MTU Subnet",
[28]="Broadcast Address",
[29]="Mask Discovery",
[30]="Mask Supplier",
[31]="Router Discovery",
[32]="Router Request",
[33]="Static Route",
[34]="Trailers",
[35]="ARP Timeout",
[36]="Ethernet",
[37]="Default TCP TTL",
[38]="Keepalive Time",
[39]="Keepalive Data",
[40]="NIS Domain",
[41]="NIS Servers",
[42]="NTP Servers",
[43]="Vendor Specific",
[44]="NETBIOS Name Srv",
[45]="NETBIOS Dist Srv",
[46]="NETBIOS Node Type",
[47]="NETBIOS Scope",
[48]="X Window Font",
[49]="X Window Manager",
[50]="Address Request",
[51]="Address Time",
[52]="Overload",
[53]="DHCP Msg Type",
[54]="DHCP Server Id",
[55]="Parameter List",
[56]="DHCP Message",
[57]="DHCP Max Msg Size",
[58]="Renewal Time",
[59]="Rebinding Time",
[60]="Class Id",
[61]="Client Id",
[62]="NetWare/IP Domain",
[63]="NetWare/IP Option",
[64]="NIS-Domain-Name",
[65]="NIS-Server-Addr",
[66]="Server-Name",
[67]="Bootfile-Name",
[68]="Home-Agent-Addrs",
[69]="SMTP-Server",
[70]="POP3-Server",
[71]="NNTP-Server",
[72]="WWW-Server",
[73]="Finger-Server",
[74]="IRC-Server",
[75]="StreetTalk-Server",
[76]="STDA-Server",
[77]="User-Class",
[78]="Directory Agent",
[79]="Service Scope",
[80]="Rapid Commit",
[81]="Client FQDN",
[82]="Relay Agent Information",
[83]="iSNS",
[84]="REMOVED/Unassigned",
[85]="NDS Servers",
[86]="NDS Tree Name",
[87]="NDS Context",
[88]="BCMCS Controller Domain Name list",
[89]="BCMCS Controller IPv4 address option",
[90]="Authentication",
[91]="client-last-transaction-time option",
[92]="associated-ip option",
[93]="Client System",
[94]="Client NDI",
[95]="LDAP",
[96]="REMOVED/Unassigned",
[97]="UUID/GUID",
[98]="User-Auth",
[99]="GEOCONF_CIVIC",
[100]="PCode",
[101]="TCode",
[102-107]="REMOVED/Unassigned",
[108]="REMOVED/Unassigned",
[109]="Unassigned",
[110]="REMOVED/Unassigned",
[111]="Unassigned",
[112]="Netinfo Address",
[113]="Netinfo Tag",
[114]="URL",
[115]="REMOVED/Unassigned",
[116]="Auto-Config",
[117]="Name Service Search",
[118]="Subnet Selection Option",
[119]="Domain Search",
[120]="SIP Servers DHCP Option",
[121]="Classless Static Route Option",
[122]="CCC",
[123]="GeoConf Option",
[124]="V-I Vendor Class",
[125]="V-I Vendor-Specific Information",
[126]="Removed/Unassigned",
[127]="Removed/Unassigned",
[128]="PXE - undefined (vendor specific)",
[128]="Etherboot signature. 6 bytes: E4:45:74:68:00:00",
[128]="DOCSIS full security server IP address",
[128]="TFTP Server IP address (for IP Phone software load)",
[129]="PXE - undefined (vendor specific)",
[129]="Kernel options. Variable length string",
[129]="Call Server IP address",
[130]="PXE - undefined (vendor specific)",
[130]="Ethernet interface. Variable length string.",
[130]="Discrimination string (to identify vendor)",
[131]="PXE - undefined (vendor specific)",
[131]="Remote statistics server IP address",
[132]="PXE - undefined (vendor specific)",
[132]="IEEE 802.1Q VLAN ID",
[133]="PXE - undefined (vendor specific)",
[133]="IEEE 802.1D/p Layer 2 Priority",
[134]="PXE - undefined (vendor specific)",
[134]="Diffserv Code Point (DSCP) for VoIP signalling and media streams",
[135]="PXE - undefined (vendor specific)",
[135]="HTTP Proxy for phone-specific applications",
[136]="OPTION_PANA_AGENT",
[137]="OPTION_V4_LOST",
[138]="OPTION_CAPWAP_AC_V4",
[139]="OPTION-IPv4_Address-MoS",
[140]="OPTION-IPv4_FQDN-MoS",
[141]="SIP UA Configuration Service Domains",
[142]="OPTION-IPv4_Address-ANDSF",
[143]="OPTION_V4_ZEROTOUCH_REDIRECT (TEMPORARY - registered 2018-02-08, expires 2019-02-08)",
[144]="GeoLoc",
[145]="FORCERENEW_NONCE_CAPABLE",
[146]="RDNSS Selection",
[150]="TFTP server address",
[150]="Etherboot",
[150]="GRUB configuration path name",
[151]="status-code",
[152]="base-time",
[153]="start-time-of-state",
[154]="query-start-time",
[155]="query-end-time",
[156]="dhcp-state",
[157]="data-source",
[158]="OPTION_V4_PCP_SERVER",
[159]="OPTION_V4_PORTPARAMS",
[160]="DHCP Captive-Portal",
[161]="OPTION_MUD_URL_V4 (TEMPORARY - registered 2016-11-17, extension registered 2017-10-02, expires 2018-11-17)",
[175]="Etherboot (Tentatively Assigned - 2005-06-23)",
[176]="IP Telephone (Tentatively Assigned - 2005-06-23)",
[177]="Etherboot (Tentatively Assigned - 2005-06-23)",
[177]="PacketCable and CableHome (replaced by 122)",
[208]="PXELINUX Magic",
[209]="Configuration File",
[210]="Path Prefix",
[211]="Reboot Time",
[212]="OPTION_6RD",
[213]="OPTION_V4_ACCESS_DOMAIN",
[220]="Subnet Allocation Option",
[221]="Virtual Subnet Selection (VSS) Option",
[255]="End",
} 

MSG_TYPE_53 = { 
[1]="DHCPDISCOVER",
[2]="DHCPOFFER",
[3]="DHCPREQUEST",
[4]="DHCPDECLINE",
[5]="DHCPACK",
[6]="DHCPNAK",
[7]="DHCPRELEASE",
[8]="DHCPINFORM",
[9]="DHCPFORCERENEW",
[10]="DHCPLEASEQUERY",
[11]="DHCPLEASEUNASSIGNED",
[12]="DHCPLEASEUNKNOWN",
[13]="DHCPLEASEACTIVE",
[14]="DHCPBULKLEASEQUERY",
[15]="DHCPLEASEQUERYDONE",
[16]="DHCPACTIVELEASEQUERY",
[17]="DHCPLEASEQUERYSTATUS",
[18]="DHCPTLS",
} 
