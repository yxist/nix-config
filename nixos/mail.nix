{ config, lib, pkgs, ... }:

let
  submissionHeaderCleanupRules = pkgs.writeText "submission_header_cleanup_rules" (''
     # Removes sensitive headers from mails handed in via the submission port.
     /^Received:/            IGNORE
     /^X-Originating-IP:/    IGNORE
     /^X-Mailer:/            IGNORE
     /^User-Agent:/          IGNORE
     /^X-Enigmail:/          IGNORE

     # Replaces the user submitted hostname with the server's FQDN to hide the
     # user's host or network.
     /^Message-ID:\s+<(.*?)@.*?>/ REPLACE Message-ID: <$1@${cfg.fqdn}>
  '');
in
{
  environment.systemPackages = with pkgs; [
    pypolicyd-spf
  ];

  services.postfix = {
    enable = true;
    hostname = "mail.xdd.sk"
    networksStyle = "host"; 
    sslCert = "${config.security.acme.certs."mail.xdd.sk".directory}/fullchain.pem";
    sslKey = "${config.security.acme.certs."mail.xdd.sk".directory}/key.pem";
    enableSubmission = true;
    config = {
      mydestination = "";
      recipient_delimiter = "+";
      smtpd_banner = "$myhostname ESMTP $mail_name";

      # virtual mail system
      virtual_uid_maps = "static:5000";
      virtual_gid_maps = "static:5000";
      virtual_mailbox_base = "/var/vmail";
      virtual_transport = "lmtp:unix:/run/dovecot2/dovecot-lmtp";

      # sasl with dovecot
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/run/dovecot2/auth";
      smtpd_sasl_auth_enable = true;
      smtpd_relay_restrictions = [
        "permit_mynetworks" "permit_sasl_authenticated" "defer_unauth_destination"
      ];

      policy-spf_time_limit = "3600s";

      smtpd_recipient_restrictions = [
        "check_policy_service inet:localhost:12340" # quota
        "check_policy_service unix:private/policy-spf"
      ];

      smtpd_tls_security_level = "may";
      smtpd_tls_eecdh_grade = "ultra";
      
      smtpd_tls_protocols = "TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3";
      smtp_tls_protocols = "TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3";
      smtpd_tls_mandatory_protocols = "TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3";
      smtp_tls_mandatory_protocols = "TLSv1.3, TLSv1.2, TLSv1.1, !TLSv1, !SSLv2, !SSLv3";

      smtp_tls_ciphers = "high";
      smtpd_tls_ciphers = "high";
      smtp_tls_mandatory_ciphers = "high";
      smtpd_tls_mandatory_ciphers = "high";

      smtpd_tls_mandatory_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtpd_tls_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtp_tls_mandatory_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";
      smtp_tls_exclude_ciphers = "MD5, DES, ADH, RC4, PSD, SRP, 3DES, eNULL, aNULL";

      tls_preempt_cipherlist = true;

      smtpd_tls_auth_only = true;
      smtpd_tls_loglevel = "1";

      tls_random_source = "dev:/dev/urandom";

      smtpd_milters = [
        "unix:/run/opendkim/opendkim.sock"
      ];
      non_smtpd_milters = [
        "unix:/run/opendkim/opendkim.sock"
      ];
      milter_protocol = "6";
      milter_mail_macros = "i {mail_addr} {client_addr} {client_name} {auth_type} {auth_authen} {auth_author} {mail_addr} {mail_host} {mail_mailer}";
    };

    submissionOptions = {
      smtpd_tls_security_level = "encrypt";
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/run/dovecot2/auth";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_sasl_local_domain = "$myhostname";
      smtpd_client_restrictions = "permit_sasl_authenticated,reject";
      smtpd_sender_login_maps = "hash:/etc/postfix/vaccounts"; # TODO
      smtpd_sender_restrictions = "reject_sender_login_mismatch";
      smtpd_recipient_restrictions = "reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject";
      cleanup_service_name = "submission-header-cleanup";
    };

    masterConfig = {
      "policy-spf" = {
        type = "unix";
        privileged = true;
        chroot = false;
        command = "spawn";
        args = [ "user=nobody" "argv=${pkgs.pypolicyd-spf}/bin/policyd-spf"];
      };
      "submission-header-cleanup" = {
        type = "unix";
        private = false;
        chroot = false;
        maxproc = 0;
        command = "cleanup";
        args = ["-o" "header_checks=pcre:${submissionHeaderCleanupRules}"];
      };
    };
  };

  services.opendkim = {
    enable = true;
    selector = "202009";
    domains = "dsn:pgsql://opendkim@localhost/mail/table=dkim_domains?"; # TODO
  };

  users.users.postfix.extraGroups = [ "opendkim" ];
}
