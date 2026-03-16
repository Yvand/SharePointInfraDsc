# SharePoint.Full

This folder contains the DSC configuration files for all the virtual machines required to run a SharePoint server farm.

## Configuration details

Extensive configuration with many SharePoint and AD features configured:

### DC

- AD CS is configured and used for all the certificates generated.
- AD FS is configured with both an OpenID Connect app and a SAML 1.1 trust.
- LDAPS (LDAP over SSL) is configured with a certificate issued by AD CS.

### SharePoint

- SharePoint service applications configured: User Profiles, add-ins, session state.
- SharePoint User Profiles service is configured with a directory synchronization connection, and the MySite host is a host-named site collection.
- SharePoint has 1 web application with path based and host-named site collections, and contains 2 zones:
  - Default zone: HTTP using Windows authentication.
  - Intranet zone: HTTPS using federated (ADFS) authentication.
- An OAuth trust is created, as well as a custom IIS site to host your high-trust add-ins.
- Custom claims provider [LDAPCP](https://www.ldapcp.com/) is installed and configured.
- The HTTPS site certificate is managed by SharePoint, which has the private key and sets the binding itself in the IIS site.
- Federated authentication with ADFS is configured using OpenID Connect.

#### About SharePoint legacy (2019 / 2016)

- The HTTPS site certificate is set in IIS manually.
- Federated authentication with ADFS is configured using SAML 1.1.
