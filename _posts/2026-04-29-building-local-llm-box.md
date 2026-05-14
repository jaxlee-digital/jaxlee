---

date: 2026-04-29 18:45:00 -0400
last_updated: 2026-04-29
tags: [ai, infra, tutorial, ollama]
excerpt: "A build log of getting a Framework Desktop with the AMD Ryzen AI Max+ 395 configured as a remote-accessible LLM inference server."
cover: /assets/images/llm-box/framework-desktop.jpg
---

<figure>
  <img src="{{ '/assets/images/llm-box/framework-desktop.jpg' | relative_url }}"
       alt="Framework Desktop with checkered tile front panel on a desk, next to a salt lamp, amethyst cluster, monitor, and pink keyboard.">
</figure>

A build log of getting a Framework Desktop with the AMD Ryzen AI Max+ 395 ("Strix Halo") configured as a remote-accessible LLM inference server.

## The hardware

- Framework Desktop / Ryzen AI Max+ 395 / 128GB LPDDR5X-8000 / Radeon 8060S iGPU
- WD_BLACK SN850X 2TB (OS) + 4TB (models)
- Fedora Workstation 43, kernel 6.17

The whole reason for this hardware is unified memory. Up to ~110GB of system RAM can be exposed to the iGPU as VRAM‑equivalent through the GTT (Graphics Translation Table) — enough to run models that would otherwise need multi‑GPU workstations.

## The goal

A local Ollama API that's:
- Reachable over Tailscale from my MacBook and my agent machine (openclaw)
- Invisible to the LAN and public internet
- Always‑on, no sleep, no idle
- Models on the 4TB drive, not the OS drive

## Models

- `gpt-oss:120b` — primary reasoning. MoE, ~5B active params, ~20 tok/s, 65GB
- `qwen3:32b` — fast everyday/agent default, 20GB
- `gemma3:27b` — multimodal option, 17GB

(Aside: my agent claimed Gemma's context was capped at 8192. That's Ollama's *default*, not the model's *limit* — Gemma 3 actually does 128K. Setting `OLLAMA_CONTEXT_LENGTH=32768` solves it across the board.)

## Ollama config

Systemd drop‑in at `/etc/systemd/system/ollama.service.d/override.conf`:

```
[Service]
Environment="OLLAMA_HOST=100.66.1.89:11434"
Environment="OLLAMA_MODELS=/mnt/secondary/ollama"
Environment="OLLAMA_CONTEXT_LENGTH=32768"
Environment="OLLAMA_KEEP_ALIVE=24h"
Environment="OLLAMA_FLASH_ATTENTION=1"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
```

`KEEP_ALIVE=-1` pins models in memory permanently — instant agent responses, no cold loads. Binding to the Tailscale IP (not `0.0.0.0`) is the actual security boundary.

## GTT tuning — the real performance unlock

Initial test of `gpt-oss:120b`: 3% CPU / 97% GPU. Small fraction of the model spilling to CPU because the default 64GB GTT pool wasn't quite big enough.

Bumped to 112GB via kernel parameters in `/etc/default/grub`:

```
ttm.pages_limit=28311552 ttm.page_pool_size=28311552
```

The trap: every guide online says `amdttm.pages_limit=…`. On Fedora 43 / kernel 6.17, the module is just `ttm` — the AMD‑specific TTM was consolidated into the generic module a few kernel versions back. Wrong parameter names are silently ignored. Verify with:

```
ls /sys/module/ | grep -i ttm
modinfo ttm | grep ^parm
```

After regenerating GRUB and rebooting:

```
amdgpu: 110592M of GTT memory ready ← was 64038M
```

108GB effective GTT, `gpt-oss:120b` now runs 100% GPU.

## Don't go to sleep

Fedora Workstation defaults assume interactive use. For a headless‑ish server:

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

gsettings set org.gnome.desktop.session idle-delay 0

sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF
sudo systemctl restart NetworkManager
```

Both layers (systemd + GNOME) need addressing. WiFi powersave dropping the radio during idle is a sneaky failure mode.

## Network security

Three layers:

1. Bind address. Ollama listens only on `100.66.1.89:11434` (Tailscale interface). Other interfaces have no process to accept — TCP RST.
2. Firewalld drop rule for `tcp:11434` on the active zone (FedoraWorkstation, not public — Fedora Workstation's default isn't what most guides assume). Belt‑and‑suspenders if the bind ever drifts.
3. Tailscale interface in `trusted` zone. This was the bug that took longest to find. Local API worked, but my MacBook couldn't connect — TCP timeouts. `tailscale0` had no zone assignment, so traffic was being processed under the default zone's drop rule:

```
sudo firewall-cmd --permanent --zone=trusted --add-interface=tailscale0
sudo firewall-cmd --reload
```

Tailnet is the auth boundary, so allow‑all there is correct.

## Lessons

1. Chat‑app markdown copy‑paste hazard: copying `kernel.parameter_name` from chat that auto‑linkifies dotted text can paste `[name](http://name)` into config files. Bit me twice. Now I paste tricky lines into a plain editor first.
2. `amdttm` is not the module name on modern kernels. It's `ttm`. Most guides haven't been updated.
3. fstab persistence is non‑negotiable. Manual mounts feel fine until your first reboot, then Ollama looks empty because the drive isn't mounted.
4. firewalld zones are subtle. Default zone isn't always public. Tailscale interfaces aren't in any zone by default but still get processed under default rules.
5. Strix Halo is genuinely good for this. The GTT trick is what makes it work; tuning is what gets it to its real potential.

## Final state

3 models loaded, 108GB effective GTT, `gpt-oss:120b` at 100% GPU. API reachable only via Tailscale. Models pinned in memory. No suspend. Agent on openclaw hits the API across the tailnet at full GPU speed.

Next up: an ethernet switch so both machines can drop WiFi entirely.

**Citation:** Content generated by Claude Opus 4.7; edited by the local Ollama `gpt-oss:120b` model.
