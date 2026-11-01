# Halcyon AR Jamf Pro assets

This repository contains macOS deployment assets for managing the Halcyon AR
application with Jamf Pro. It does not contain the application installer.

## Repository contents

| Path | Purpose |
| --- | --- |
| `mdm-profiles/Halcyon - Content Filter.mobileconfig` | Configures Halcyon's socket content filter. |
| `mdm-profiles/Halcyon - System Extensions.mobileconfig` | Allows the Halcyon Endpoint Security and Network extensions for the configured team. User overrides are allowed. |
| `mdm-profiles/Managed Login Items - Halcyon.mobileconfig` | Manages login items signed by Halcyon's team identifier. |
| `mdm-profiles/Notifications - Halcyon.mobileconfig` | Enables notifications for the `ai.halcyon.agent` bundle identifier. |
| `mdm-profiles/PPPC - Halcyon.mobileconfig` | Grants Full Disk Access to the Halcyon system extension identified in the profile. |
| `scripts/halcyon-app-launchagent.zsh` | Creates and loads a LaunchAgent that opens `/Applications/Halcyon AR.app` at the current user's login. |
| `scripts/halcyon-client-configuration.sh` | Writes the install token to `/Library/Application Support/Halcyon/HalcyonAR/token.toml`. |
| `extension-attributes/halcyon-sensor-ea.sh` | Jamf Extension Attribute reporting whether the Halcyon system extension identifier appears in `systemextensionsctl list` output when the app is installed. |

## Deploying with Jamf Pro

1. Review the configuration profiles and upload the required `.mobileconfig`
   files to Jamf Pro. Scope them to the intended macOS computers.
2. Deploy and install Halcyon AR at `/Applications/Halcyon AR.app` before
   running the LaunchAgent script.
3. Configure `halcyon-client-configuration.sh` as a Jamf policy script and
   provide the install token as **Parameter 4**. The script must run as root.
   It stores the token in a root-owned file with mode `0600`; do not put real
   install tokens in this repository.
4. Configure `halcyon-app-launchagent.zsh` as a Jamf policy script and run it
   as root while a user is logged in. It installs the LaunchAgent at
   `/Library/LaunchAgents/ai.halcyon.agent.UserAgent.plist`. The app opens at
   login, but is not automatically relaunched if the user quits it.
5. Add `halcyon-sensor-ea.sh` as a Jamf Extension Attribute to report the
   extension state in inventory.

The client configuration script replaces the token file on each successful
run. The LaunchAgent script can be rerun to recreate and reload its LaunchAgent.
Review policy scope and execution timing in Jamf before deployment.

## Profile review

The profiles are system-scoped and marked as non-removable. Before deploying,
verify their payloads, identifiers, signing/team requirements, and organization
metadata against the target environment. Several profiles currently use
`Company Name` as the payload organization; replace that placeholder if it is
not appropriate for your Jamf environment.

## Validation

On macOS, validate the profiles and shell syntax with:

```sh
for profile in mdm-profiles/*.mobileconfig; do plutil -lint "$profile"; done
bash -n scripts/halcyon-client-configuration.sh
zsh -n scripts/halcyon-app-launchagent.zsh
sh -n extension-attributes/halcyon-sensor-ea.sh
```
