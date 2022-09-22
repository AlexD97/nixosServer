{ config, pkgs, lib, ... }: {
  programs.mbsync.enable = true;
  services.mbsync.enable = true;
  programs.notmuch.enable = true;

  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/.mail";

    accounts = {
      main = {
        address = lib.concatStringsSep "@" [ "alexding97" "gmail.com" ];
        userName = lib.concatStringsSep "@" [ "alexding97" "gmail.com" ];
        realName = "Alexander Dinges";
        maildir.path = "alexding97";
        flavor = "gmail.com";
        passwordCommand = "${pkgs.pass}/bin/pass google_nix 2> /dev/null";
        primary = true;

        folders = {
            inbox = "Inbox";
            #drafts = "[Gmail]/Drafts";
            #sent = "[Gmail]/SentMail";
            #trash = "[Gmail]/Trash";
          };

        imap.port = 993;

        mbsync = {
          enable = true;
          create = "maildir";
        };
        notmuch.enable = true;
        msmtp.enable = true;

      };
    };
  };
}
