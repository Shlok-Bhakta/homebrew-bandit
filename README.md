# bandit-mac

A small macOS menu bar helper for [Bandit](https://github.com/Shlok-Bhakta/bandit), the dongle
that turns a Meta Neural Band into a Bluetooth keyboard and mouse. It tells the dongle which app is
in front, so the band's gestures switch profile with the app: a browser profile in Chrome, an
editor profile in Xcode, and back to your usual profile everywhere else.

It only sends the front app's bundle id (like `com.google.Chrome`) to the dongle, over the
Bluetooth link the Mac already has with it. Nothing goes over the network.

## Install

```sh
brew install shlok-bhakta/bandit/bandit-mac
brew services start bandit-mac        # runs it now and at every login
```

It builds from source, so it needs the Xcode Command Line Tools (`xcode-select --install`;
Homebrew already asks for them). macOS 13 or later. (It's `bandit-mac`, not `bandit`: Homebrew
already has an unrelated `bandit`.)

The first time it runs, macOS asks to let **bandit-mac** use Bluetooth: allow it. A hand appears
in the menu bar (crossed out until it's connected to the dongle).

**Needs:** dongle firmware **0.12.0** or later, and the Mac paired with the dongle as a computer
(it's then the Mac's keyboard and mouse; the helper shares that connection).

## Coming from np-appwatch

bandit-mac is np-appwatch renamed. To switch:

```sh
brew services stop np-appwatch && brew uninstall np-appwatch && brew untap shlok-bhakta/np
brew install shlok-bhakta/bandit/bandit-mac
brew services start bandit-mac
bandit-mac copilot install            # if you used the Copilot buzzes: removes np-appwatch's hooks too
```

macOS asks for Bluetooth again (to macOS it's a new app): allow it.

## Which apps switch to which profile

The dongle decides, from the `apps` of its gesture profiles (the profile file the Bandit iPhone
app edits):

```json
{
  "id": "browser",
  "name": "Browser",
  "hosts": ["computer"],
  "apps": ["com.google.Chrome", "com.apple.Safari", "company.thebrowser.Browser"],
  "gestures": { "swipe.left": "key:cmd+[", "swipe.right": "key:cmd+]", "index.doubleTap": "key:cmd+t" }
}
```

- An app a profile lists comes to the front: the Mac switches to that profile (quietly, no buzz).
- Any other app: the Mac goes back to the profile it was in before.
- Switching by hand (the letter menu, the app) sticks until the next listed app.
- Pausing or quitting the helper puts the Mac back in its own profile.

To find an app's bundle id, bring it to the front and open the menu bar item (it shows it, with a
copy button), or run:

```sh
bandit-mac front     # the app in front
bandit-mac apps      # every running app
```

## Buzz when Copilot needs you

```sh
bandit-mac copilot install
```

Then restart the GitHub Copilot app. Copilot's hooks run bandit-mac, and the band buzzes:

| | Pattern | When |
|---|---|---|
| **Question** | two taps and a long one | the agent asks you something, or wants approval |
| **Done** | two firm pulses | the agent finished its turn |
| **Error** | one very long | something failed |

No buzz while Copilot is in front and you've used the Mac in the last 30 s: you're already
there. Events that come close together (a question, then the turn ending) each buzz, one
after another (dongle firmware 0.13.1 plays them in turn; 0.13.0 may blur them together). It
installs a small Copilot plugin (`bandit`, with `copilot plugin install` when Copilot CLI is
installed) and the same hooks as personal hooks for Copilot CLI, and removes np-appwatch's
(`np-band`) if they're there. Each hook that fires is logged to
`~/Library/Logs/bandit-mac/copilot-hooks.log`: watch it with `tail -f` to see what Copilot sends.
Try the patterns with `bandit-mac notify question` (or `done`, `error`); `bandit-mac copilot
check` shows what's installed, anything np-appwatch left behind, and the last hooks that ran.
Needs dongle firmware 0.13.0 or later. `bandit-mac copilot uninstall` removes it.

## Commands

```text
bandit-mac              watch the app in front, with the menu bar item
bandit-mac --no-menu    the same, without it
bandit-mac front        print the front app's bundle id
bandit-mac apps         print every running app's bundle id
bandit-mac send <id>    tell the dongle once that <id> is in front ("" for none)
bandit-mac status       print the dongle's status JSON
bandit-mac notify done|question|error [--app <id>]   buzz the band
bandit-mac copilot install|uninstall|check           Copilot's hooks (check: what's installed, what ran)
```

Logs (when run by `brew services`): `$(brew --prefix)/var/log/bandit-mac.log`.

## Troubleshooting

- **The hand stays crossed out.** Is the Mac paired with the dongle (System Settings › Bluetooth
  shows "Bandit" connected)? Is Bluetooth allowed for bandit-mac (System Settings › Privacy &
  Security › Bluetooth)?
- **The menu says Bluetooth is off while Bluetooth is on.** Quit Bandit from the menu (launchd
  restarts it). It also tries to recover on its own within a minute or so.
- **macOS asks for Bluetooth again after an upgrade.** It's built on your Mac and not signed by a
  developer, so macOS sees each build as a new app. Allow it again.
- **Nothing switches.** Check the bundle id against the profile's `apps` (case doesn't matter),
  and that the dongle runs 0.12.0 or later (`bandit-mac status` shows `"fw"`).

## Uninstall

```sh
brew services stop bandit-mac
brew uninstall bandit-mac
brew untap shlok-bhakta/bandit
```

MIT licensed. Not open to contributions.
