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
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          apktool
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          binaryninja-free # Update this after licensed
        ]
        ++ [

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

          # Pentest
          rlwrap
          metasploit
          snmpcheck
          minicom
          picocom
          socat
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
