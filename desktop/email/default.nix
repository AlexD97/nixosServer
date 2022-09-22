{ config, pkgs, ... }: {
  accounts.email = {
    maildirBasePath = "~/.mail";

    accounts = {
      main = {
        address = concatStringsSep "@" [ "alexding97" "gmail.com" ];
        userName = concatStringsSep "@" [ "alexding97" "gmail.com" ];
        maildir.path = "alexding97";
        flavor = "gmail.com";
        passwordCommand = "${pkgs.pass}/bin/pass google_nix 2> /dev/null";

        folders = {
            inbox = "Inbox";
            drafts = "[Gmail]/Drafts";
            sent = "[Gmail]/SentMail";
            trash = "[Gmail]/Trash";
          };

        imap.port = 993;

        mbsync.enable = true;
      };
    };
  };
}
