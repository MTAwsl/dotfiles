_: {
  flake.modules.users.yuri.home.sectools =
    { lib, pkgs, ... }:
    {
      programs.zsh.shellAliases = {
        gdb = "pwndbg";
      };

      home.packages =
        with pkgs;
        [
          # aflplusplus
          patchelf
          pwntools
          badchars
          pwndbg
          ghidra-bin
          bingrep
          unicorn # TODO: Separate this to a shell with QBDI.
          radare2
          rizin
          frida-tools
          netexec
          username-anarchy
          mimikatz
          kerbrute
          hash-identifier
          hashid
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          apktool
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          binaryninja-free # Update this after licensed
        ]
        ++ [
          # Remote Desktop
          freerdp
          tigervnc

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
          dig
          rustscan
          nmap-formatter
          putty
          whois
          netcat
          scrcpy
          proxychains-ng
          wireshark

          # Password
          hashcat
          hashcat-utils
          nth
          john
          wordlists

          # Web
          burpsuite
          sqlmap
          whatweb
          wpscan

          # Pentest
          rlwrap
          metasploit
          snmpcheck
          minicom
          picocom
          socat
          pwncat
          goreplay
          tcpdump
          netsniff-ng
          bloodhound-cli
          bloodhound-py
          enum4linux-ng
          evil-winrm-py
          nbtscan
          powerview
          samba
          smbscan
          penelope
          python3Packages.impacket
          python3Packages.pypykatz
          certipy
          kerbrute

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
