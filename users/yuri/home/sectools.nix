{ ... }:
{
  flake.modules.homeManager.yuri-devtools =
    { pkgs, ... }:
    {
      programs.zsh.shellAliases = {
        gdb = "pwndbg";
      };

      home.packages = with pkgs; [
        # aflplusplus
        patchelf
        pwntools
        badchars
        pwndbg
        ghidra-bin
        bingrep
        # unicorn # TODO: Separate this to a shell with QBDI.
        radare2
        rizin
        frida-tools
        apktool
        binaryninja-free # Update this after licensed

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
        wordlists

        # Web
        (burpsuite.override { proEdition = false; })
        sqlmap
        wireshark

        # Pentest
        metasploit
        snmpcheck
        minicom
        picocom
        socat
        goreplay
        tcpdump
        netsniff-ng
        # bloodhound-ce # See #6
        bloodhound-cli
        bloodhound-py
        enum4linux-ng
        evil-winrm-py
        nbtscan
        powerview
        samba
        smbscan
        python3Packages.impacket

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
