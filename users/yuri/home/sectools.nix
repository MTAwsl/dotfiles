{ ... }:
{
  flake.modules.homeManager.yuri-devtools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # aflplusplus
        patchelf
        pwntools
        badchars
        pwndbg
        ghidra-bin
        bingrep
        unicorn
        radare2
        rizin
        frida-tools
        apktool
        # binary-ninja-free-wayland
        python3Packages.angr
        python3Packages.impacket

        # Credential
        trufflehog
        gitleaks
        whispers
        secretscanner

        # Docker
        dive
        grype
        trivy

        # DNS
        subfinder
        findomain
        dnspeep
        dnsmonster

        exploitdb
        go-exploitdb
        keedump
        sploitscan
        cargo-audit

        # Files
        foremost
        recoverjpeg
        volatility3
        exiftool
        exiflooter
        srm

        # Fuzz
        ffuf
        gobuster

        # hecker.
        sherlock

        # LDAP
        silenthound
        hekatomb
        ldapnomnom
        openldap

        # Network
        nmap
        rustscan
        nmap-formatter
        putty
        whois
        netcat
        scrcpy
        proxychains-ng

        # Password
        hashcat
        hashcat-utils
        nth
        john
        seclists

        # Web
        (burpsuite.override { proEdition = false; })
        sqlmap
        wireshark

        # Pentest
        metasploit
        snmpcheck
        minicom # See #5
        picocom
        socat
        goreplay
        tcpdump
        netsniff-ng
        bloodhound-ce
        bloodhound-py
        enum4linux-ng
        evil-winrm-py
        nbtscan
        powerview
        samba
        smbscan

        # Tunnel
        sshuttle
        stunnel
        wstunnel
        udptunnel
        chisel
        ligolo-ng
        ntlmrecon
      ];
    };
}
