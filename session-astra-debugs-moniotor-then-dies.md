# Investigation: fairydust Apple DCP/DPTX external display negatives

**Session ID:** ses_f6016ac8cffe1Kzt8Htz20feFl
**Created:** 9/14/2026, 1:34:23 PM
**Updated:** 9/14/2026, 1:49:20 PM

---

## User

Yep — I'd give Astra enough context to independently inspect fairydust rather than biasing it too hard toward our `call 22/24` theory:

```text
I'm debugging experimental external display support on Asahi Linux on an M2 MacBook Air running NixOS.

Hardware/software:
- M2 MacBook Air
- NixOS 26.05
- Asahi Linux fairydust kernel branch:
  https://github.com/AsahiLinux/linux/tree/fairydust
- Exact kernel commit:
  ce9f2eba72c061a50b2d790450e90af3439d8c24
- Running kernel reports 7.1.13
- External display is currently an ultrawide connected through a USB-C display dongle
- Internal display works normally

The fairydust kernel is definitely booted and the external DCP/DPTX path appears to initialize.

The external DRM connector exists:

    /sys/class/drm/card2-DP-1/status
    disconnected

Its EDID is empty:

    hexdump -C /sys/class/drm/card2-DP-1/edid
    # no output

And it exposes no modes:

    cat /sys/class/drm/card2-DP-1/modes
    # empty

Relevant boot messages include:

    apple-dcp 271c00000.dcp: DCP index:1 dptx target phy: 1 dptx die: 0
    apple-dcp 271c00000.dcp: DCP booted
    apple-dcp 271c00000.dcp: DCP is_main_display: 0
    apple-dcp 271c00000.dcp: dcp_hotplug() connected:0 valid_mode:0 nr_modes:0

When connecting/reconnecting the external display, DPTX activity occurs:

    apple-dcp 271c00000.dcp: DPTXPort: acking unhandled call 20
    apple-dcp 271c00000.dcp: dcp_dptx_disconnect(port=0)
    apple-dcp 271c00000.dcp: dcp_dptx_connect(port=0)
    apple-dcp 271c00000.dcp: RTKit: ... AppleDCPDPTX.cpp:355: [AFK]powering nub ...
    apple-dcp 271c00000.dcp: DPTXPort: acking unhandled call 22
    apple-dcp 271c00000.dcp: DPTXPort: acking unhandled call 24
    apple-dcp 271c00000.dcp: dcp_dptx_connect(port=0)

This sequence repeats on reconnect.

There are also messages involving:

    Failed to get dp-xbar: -517

during early initialization, followed later by:

    fwnode_typec_mux_get() returned: 0

The DCP firmware also produces:

    display HPD asserted

However, note that this HPD line appears under 231c00000.dcp (the main/internal DCP), whereas the external DPTX activity is on 271c00000.dcp. Please investigate whether that's expected rather than assuming it represents successful external HPD.

The external DCP reports during initialization:

    IOMFB setup_video_limits called on secondary display with no timing set

What I want you to investigate:

1. Inspect the fairydust source at the commit above, particularly the Apple DCP/DPTX implementation.
2. Determine what DPTX calls 20, 22, and 24 represent and whether "acking unhandled call" is expected/incomplete functionality or likely relevant to this failure.
3. Work out where the external display connection should transition into EDID/AUX handling and DRM connector status becoming "connected".
4. Determine why HPD/DPTX activity can occur while card2-DP-1 remains disconnected with no EDID/modes.
5. Check whether M2 MacBook Air external display support has known hardware/port limitations on fairydust.
6. Check whether USB-C -> HDMI adapters are currently expected to work, or whether I should test direct USB-C -> DisplayPort first.
7. Check whether ultrawide displays/particular timings could matter this early in detection. My suspicion is that an entirely empty EDID means the failure occurs before mode selection, but verify that.
8. Look for relevant commits, issues, patches, TODOs, mailing-list discussion, or Asahi developer notes concerning these DPTX calls or this failure mode.
9. Give me specific diagnostic commands or small kernel instrumentation patches that would narrow down exactly where the connection fails.

Please don't just give generic DisplayPort/Linux troubleshooting. This is experimental Asahi DCP/DPTX support, so investigate the fairydust implementation itself and correlate the source with these logs.

Also distinguish clearly between:
- facts confirmed from source/logs,
- likely hypotheses,
- things that still need testing.

I can rebuild the kernel and apply patches if necessary.
```

That last sentence is important. **Give Astra permission to go full kernel goblin.** We have already crossed the Rubicon; if there's a strategic `dev_info()` to shove into fairydust, we are absolutely doing it. :p 

---

## Assistant (Build · GPT-6 Astra · 6.5s)

I’ll trace the pinned fairydust code from USB-C hotplug through DPTX, EDID, and DRM detection, then check developer notes for known limitations. I’ll also look at your Nix kernel setup so any proposed instrumentation can be applied to the kernel you’re actually running.

**Tool: todowrite**

**Input:**
```json
{
  "todos": [
    {
      "content": "Inspect pinned fairydust source and local kernel configuration",
      "status": "in_progress",
      "priority": "high"
    },
    {
      "content": "Research support limitations and relevant upstream discussions",
      "status": "pending",
      "priority": "high"
    },
    {
      "content": "Trace failure paths and prepare targeted diagnostics or instrumentation",
      "status": "pending",
      "priority": "high"
    },
    {
      "content": "Summarize confirmed facts, hypotheses, and test sequence",
      "status": "pending",
      "priority": "high"
    }
  ]
}
```

**Output:**
```
[
  {
    "content": "Inspect pinned fairydust source and local kernel configuration",
    "status": "in_progress",
    "priority": "high"
  },
  {
    "content": "Research support limitations and relevant upstream discussions",
    "status": "pending",
    "priority": "high"
  },
  {
    "content": "Trace failure paths and prepare targeted diagnostics or instrumentation",
    "status": "pending",
    "priority": "high"
  },
  {
    "content": "Summarize confirmed facts, hypotheses, and test sequence",
    "status": "pending",
    "priority": "high"
  }
]
```

---

## Assistant (Build · GPT-6 Astra · 310.6s)

**Tool: task**

**Input:**
```json
{
  "description": "Inspect local kernel setup",
  "prompt": "Research only, no edits. Thoroughness medium. Inspect /home/ivy/nix for Asahi fairydust kernel source configuration, patches, debugging notes, exact revision, any local cached source paths. Return specific relevant paths and how kernel patches are integrated. Do not access secrets. Also note any repo instructions relevant to editing.",
  "subagent_type": "explore",
  "task_id": "",
  "command": ""
}
```

**Output:**
```
task_id: ses_f60167205ffewlSv5K40q4rIe3 (for resuming to continue this task if needed)

<task_result>
## Kernel configuration and exact revision

The active fairydust configuration is in **`/home/ivy/nix/modules/hardware/apple-silicon.nix`**. It is an **uncommitted working-tree change**; the committed version only enabled the upstream Apple Silicon module.

- **Host integration:** `/home/ivy/nix/hosts/nixos/alder/default.nix:7` imports this hardware module.
- **Kernel selection:** `/home/ivy/nix/modules/hardware/apple-silicon.nix:111` uses `boot.kernelPackages = lib.mkForce fairydustPackages`.
- **Effective version:** `7.1.13`.
- **Source:** `AsahiLinux/linux`.
- **Exact revision:** `ce9f2eba72c061a50b2d790450e90af3439d8c24`.
- **Configured source hash:** `sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=`.

The effective overrides are at lines **87–97**. The earlier `7.1.5` / `asahi-7.1.5-2` declaration at lines 42–51 is a base definition, overridden through `lib.recursiveUpdate`; it is **not the selected source**. “fairydust” is the local package-set name, not a branch explicitly named in the fetcher.

Upstream module pin:
- `/home/ivy/nix/flake.nix:14–17`: `nixos-apple-silicon/release-2026-07-30`.
- `/home/ivy/nix/flake.lock:3–23`: revision `66d8dd2c27f99bd5420c99938b60695aac1785c4`.

## How patches are integrated

In `/home/ivy/nix/modules/hardware/apple-silicon.nix`:

1. Lines **54–75** define an `"Asahi config"` kernel-patch entry with **`patch = null`**. This supplies configuration, not a source-code diff:
   - 16K ARM64 pages, memory-model control and ACTLR state.
   - Apple watchdog, CPU PMU and power-management support.
   - Apple HID as a module.
   - `features.rust = true`.
2. Line **76** appends `_kernelPatches`.
3. Line **87** sets `_kernelPatches = config.boot.kernelPatches`.
4. The combined definition goes through `buildLinux`, then `linuxPackagesFor`.

Thus, **`boot.kernelPatches` is already wired into the custom kernel build**. I found no repository-local `.patch` files or additional explicit kernel-patch definitions in the inspected host/system modules.

The existing built kernel’s cached derivation lists one actual source patch:

`/nix/store/23728y7zgh1jb55kpwxv5qnjbq0ykca6-randstruct-provide-seed-5.19.patch`

This is separate from the configuration-only Asahi entry. Its build metadata also contains standard kernel post-patch adjustments for depmod, script interpreters and deterministic randstruct seeding.

## Confirmed local cached paths

- **Full source used by the existing 7.1.13 build:**  
  `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source`  
  The kernel derivation points here; its source-fetch derivation names the exact revision above.

- **Relevant source locations:**  
  `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/asahi/`  
  `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/configs/asahi.config`  
  `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/include/uapi/drm/asahi_drm.h`

- **Older cached source whose Makefile reports 7.1.5:**  
  `/nix/store/j5qb59snh3yins9x1jyvy4krrggrm0k9-source`

- **7.1.13 kernel derivation:**  
  `/nix/store/vnmzbyw64c4l8xrbx2vh8xqjcxgn1mg3-linux-asahi-7.1.13.drv`

- **Built kernel image:**  
  `/nix/store/4yr4iwkcjw0rpjxvqw4dnza7qiqlk3rf-linux-asahi-7.1.13/Image`

`/home/ivy/nix/result` points to an Alder system build containing that kernel. This confirms the **build result**, not which kernel is currently running.

## Debugging notes

- **`/home/ivy/nix/home/chat/vesktop.nix:5–8`** documents Asahi GPU crashes under Chromium hardware-accelerated compositing/video, including whole-machine crashes. The workaround is `hardwareAcceleration = false`.
- **`/home/ivy/nix/result/kernel-params`** contains `earlycon`, `console=tty0`, `boot.shell_on_fail`, `nvme_apple.flush_interval=0`, and `loglevel=4`, alongside normal boot parameters.
- No dedicated fairydust debugging document or kernel crash log was found in the inspected repository files.

## Editing guidance

- No `AGENTS.md` or `CLAUDE.md` was found in the repository or checked ancestor directories; `/home/ivy/nix/.claude/` is empty.
- **`/home/ivy/nix/TODO.md:65–74`** gives repository rules: explicit hosts, small reusable system modules, user configuration under `home/`, avoid premature abstractions, build/commit successful layers independently, and keep proprietary Apple firmware outside the public repository.
- **`/home/ivy/nix/justfile`** provides `just fmt`, `just check`, and `just build`.
- Firmware is referenced externally at `/etc/nixos/asahi-firmware` by `/home/ivy/nix/flake.nix:20–23`; that directory is firmware, not kernel source.
- Preserve existing staged/unstaged work, particularly the custom kernel module changes.

No edits, builds, input fetches, or secret-file reads were performed.
</task_result>
```

**Tool: task**

**Input:**
```json
{
  "description": "Research fairydust display support",
  "prompt": "Research only no code edits. Investigate public Asahi Linux fairydust external display support, specifically M2 MacBook Air, port restrictions, USB-C HDMI vs DP, ultrawides, known DPTX call 20 22 24 and no EDID failures. Target kernel commit ce9f2eba72c061a50b2d790450e90af3439d8c24. Use web and gh where appropriate. Distinguish direct developer statements / sources vs inference; give URLs and quotes, dates. Search recent info with 2026 (current year). Return useful evidence and limitations; don't assume unknown call messages are cause.",
  "subagent_type": "general",
  "task_id": "",
  "command": ""
}
```

**Output:**
```
task_id: ses_f601671caffe1TSr5q9TFgTXgO (for resuming to continue this task if needed)

<task_result>
**Bottom Line**
As of **2026-09-14**, public evidence supports **experimental external-display output on M2 MacBook Air through fairydust**, including USB-C-to-HDMI. At your exact commit, both M2 Air models are configured for the **left-front USB-C port**, farther from MagSafe and closer to the trackpad.

However, neither universal adapter compatibility nor reliable hot-plug is established. **Calls 20, 22 and 24 have names in the source, but their “unhandled” messages do not establish why a connection failed.** Missing EDID also needs careful interpretation because this driver obtains its mode list separately from the EDID it exposes to Linux.

Research only; no workspace files or configuration were changed.

**Commit And Port**
**Primary source, exact revision:** [`ce9f2eba72c061a50b2d790450e90af3439d8c24`](https://github.com/AsahiLinux/linux/commit/ce9f2eba72c061a50b2d790450e90af3439d8c24).

- Author date: **2026-09-07**; committed by Janne Grunau on **2026-09-08**.
- Kernel version in this tree: **7.1.13**.
- Commit title: **“arm64: dts: apple: t8103: Add SIO alias”**.
- Commit message: “Tested on a J313 MacBook Air (M1). … DisplayPort audio becomes functional.”
- It adds one `sio` alias to an **M1** device-tree include. **The commit itself is not an M2 display, EDID or DPTX-call fix.**

**Primary source, routing at that revision:**

Both [`t8112-j413.dts`, 13-inch M2 Air](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/arch/arm64/boot/dts/apple/t8112-j413.dts) and [`t8112-j415.dts`, 15-inch M2 Air](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/arch/arm64/boot/dts/apple/t8112-j415.dts) define `ENABLE_DCPEXT_TYPEC` and label:

```text
typec0: USB-C Left-back
typec1: USB-C Left-front
```

Their [shared include](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/arch/arm64/boot/dts/apple/t8112-jxxx.dtsi) assigns `displayport = <&dcpext>` to `typec1`, with:

```text
apple,dptx-phy = <1>;
phys = <&atcphy1 PHY_TYPE_DP>;
```

**Conclusion from source:** this is a **fixed front-port configuration**, not “either port, provided only one is used.” It is a software restriction of this tree, not evidence that the rear port is physically incapable.

**Developer Statements**
James Calligeros, official Asahi progress report, **2026-02-15**:

> “Currently, the fairydust branch ‘blesses’ a specific USB-C port on a machine for use with DisplayPort…”

> “There are also some quirks regarding both cold and hot plug of displays.”

> “…we provide the fairydust branch strictly as-is.”

The report also mentions incorrect colours and missing timing modes, and says the team cannot offer support until it is ready for general use.  
Source: [Progress Report: Linux 6.19](https://asahilinux.org/2026/02/progress-report-6-19/).

The [official M2 support table](https://asahilinux.org/docs/platform/feature-support/m2/), retrieved **2026-09-14**, still labels **DP Alt Mode** and **Thunderbolt** as **WIP**. That does not contradict experimental fairydust success.

**HDMI Versus DP**
**USB-C-to-HDMI is demonstrably possible, not categorically unsupported.**

The same official report describes Sven Peter’s **December 2025, 39C3** demonstration:

> “…an M1 MacBook Air, connected to the venue’s AV system via a USB-C to HDMI adapter!”

That establishes the adapter path on M1, not every M2 combination. More directly relevant:

| Date | Public report | Evidence and limits |
|---|---|---|
| **2026-08-18** | [AsahiLinux/linux #571](https://github.com/AsahiLinux/linux/issues/571) | **13-inch M2 Air, J413**, fairydust `7.1.6+`, Philips 2560×1440 HDMI monitor. UGREEN **CM478 worked at 2560×1440@60**. A VIA Labs multiport hub with a Parade **PS186 DP-to-HDMI** bridge repeatedly disconnected. |
| **2026-01-10** | [#437, reporter’s follow-up](https://github.com/AsahiLinux/linux/issues/437#issuecomment-3733551838) | M2 Air on NixOS: “Its ok with 6.18.4 fairydust branch”; specifies the port farther from MagSafe. Adapter and monitor are unspecified. |
| **2026-09-03** | [omarchy-mac #336](https://github.com/omacom/omarchy-mac/issues/336) | J413, partially backported fairydust stack, HDMI-connected Dell U2422H: first connection worked at 1080p60; unplug/replug returned identification and modes but no picture. Not a pristine build of your commit. |

The useful controlled comparison in #571 is:

> “With a simple single-purpose USB-C→HDMI adapter on the same port, cable, and monitor, the link is stable…”

This is **user-reported testing**, not a maintainer-certified adapter list. Importantly, the failing hub **already exposed a 256-byte EDID and 28 modes**. Its failure was not “no EDID.”

**Direct developer cable advice:** in a Studio Display discussion, Asahi member `chadmed`, **2026-08-29**, wrote:

> “Please try with a _non-Thunderbolt_ full-spec USB-C cable. Do not try to use a Thunderbolt cable or a cheap/charging-only USB-C cable.”

Source: [#579, developer comment](https://github.com/AsahiLinux/linux/issues/579#issuecomment-5459790089).

That advice is specifically for the Studio Display investigation. It should not be broadened into a claim that all Thunderbolt-labelled cables fail in every arrangement.

**Inference:** direct USB-C-to-DP is a useful comparison because it removes the DP-to-HDMI converter from the path. The evidence does **not** establish that native DP is required or guaranteed to work.

**Calls And EDID**
At the exact target revision, [`dptxep.h`](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/drivers/gpu/drm/apple/dptxep.h) defines:

| Call | Source name |
|---|---|
| `20` | `DPTX_APCALL_INACTIVE_SINK_DETECTED` |
| `22` | `DPTX_APCALL_DEVICE_NOT_RESPONDING` |
| `24` | `DPTX_APCALL_DEVICE_NOT_STARTED` |

These are **named but unhandled callbacks**, not completely unknown numeric messages. In [`dptxep.c:556–566`](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/drivers/gpu/drm/apple/dptxep.c#L556-L566), they enter the default branch:

> `/* just try to ACK and hope for the best... */`

The handler logs the call, copies the request into the reply, clears the first four reply bytes when available, and returns success.

**What that establishes:** there is no dedicated handling for these notifications.

**What it does not establish:** that the acknowledgement caused the failure, that implementing a guessed reply would fix it, or which component did not respond/start.

There is a particularly useful counterexample. In **#579**, a user initially attributed Studio Display failure to call 20. On **2026-09-04**, another participant tested an Apple USB-C Digital AV adapter and Samsung TV on an M1 Max:

> “So the call 20/disconnect pair can occur on a connection that later succeeds…”

The connection recovered and displayed **4096×2160@60**.  
Source: [full control-test comment](https://github.com/AsahiLinux/linux/issues/579#issuecomment-5533889161).

This disproves **“call 20 means an irrecoverable failure”**, but does not prove every acknowledgement is correct.

For **22 and 24**, I verified the definitions and handling in your tree, but did **not** locate a reliable public M2 Air report with a maintainer-confirmed causal diagnosis connecting those calls to a no-EDID failure.

**Why “no EDID” is ambiguous**

Primary source: [`iomfb.c:346–381`](https://github.com/AsahiLinux/linux/blob/ce9f2eba72c061a50b2d790450e90af3439d8c24/drivers/gpu/drm/apple/iomfb.c#L346-L381).

The driver:

1. Adds modes from its existing `dcp->modes` list.
2. Only attempts EDID copying if `dcp->nr_modes` is nonzero and the AV service is enabled.
3. Logs `copy_edid failed` if that copy fails, but still returns `dcp->nr_modes`.

**Source-based conclusion:** an empty sysfs EDID does not, by itself, prove that the monitor’s physical EDID transaction failed. If there are no modes, this function does not even attempt the copy. Conversely, modes can remain available despite a failed EDID copy.

The closest public no-detection case above is **#579**: the Studio Display stayed disconnected with no modes. That is evidence of failed bring-up, **not a verified EDID-specific diagnosis**.

**Ultrawides**
I found concrete failures, but no authoritative statement that ultrawides are universally unsupported:

- **2026-02-23, [#456](https://github.com/AsahiLinux/linux/issues/456):** M2 Max MacBook Pro, **native HDMI**, Sansui **3440×1440**. Resolution detected, connector connected, no image; a different travel monitor worked. This is neither an M2 Air nor a no-EDID case.
- **2026-09-10, [#611](https://github.com/AsahiLinux/linux/issues/611):** M1 Pro, direct Cable Matters USB-C-to-DP, Samsung **57-inch G95NC**. Reporter obtained 28 modes and apparent modesetting but no picture. Switching the monitor to DP 1.2 stopped link drops, **not the black screen**. The reporter used a custom partial backport and rerouted device tree after failing to boot `ce9f2eba7`; their drive-strength explanation remains an unconfirmed hypothesis.

The official [display-controller hardware documentation](https://asahilinux.org/docs/hw/soc/display-controllers/) says:

> “DP 1.4 (4 lanes) with DSC. No MST!”

It also labels its quoted controller resolution limits **“Apple-provided information, not tested.”** These are hardware descriptions, not validation of fairydust’s ultrawide, DSC or refresh-rate combinations.

**Useful Interpretation**
For an M2 Air investigation at this SHA, the evidence supports separating these cases:

- **No external controller/connector:** verify the *booted* device tree, not only the kernel version. A [2026-08-02 community report](https://github.com/bharambetejas/asahi-fairydust-display/issues/11) documents stock kernel updates replacing the selected DTB and breaking fairydust output.
- **External connector, no modes/EDID:** investigate correct port, cable/adapter path and bring-up sequence; calls 20/22/24 are observations, not a diagnosis.
- **EDID and modes present, no picture:** matches several adapter, ultrawide and replug reports, but those reports do not establish one shared cause.
- **Cold-plug versus hot-plug:** test separately. Reports disagree about which works better; #437’s author explicitly reported on **2026-01-11** that [cold-plug did not work](https://github.com/AsahiLinux/linux/issues/437#issuecomment-3734551230).

**Main limitation:** I found no controlled public test matching **M2 Air + your exact SHA + an identified ultrawide + calls 20/22/24 + absent EDID**. Reddit retrieval also failed, so this is not an exhaustive survey of social discussions. The strongest conclusions come from the exact source tree, official developer statements, and the narrowly scoped hardware comparisons above.
</task_result>
```

**Tool: bash**

**Input:**
```json
{
  "command": "git status --short",
  "timeout": 120000,
  "workdir": "/home/ivy/nix",
  "description": "Check existing workspace changes before investigation"
}
```

**Output:**
```
 M home/scripts/default.nix
AM home/scripts/tdev
 M hosts/nixos/alder/default.nix
 M modules/hardware/apple-silicon.nix
A  modules/system/boot/blahaj.nix

```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://raw.githubusercontent.com/AsahiLinux/linux/ce9f2eba72c061a50b2d790450e90af3439d8c24/drivers/gpu/drm/apple/dptx.c",
  "format": "text",
  "timeout": 60
}
```

**Error:**
```
StatusCode: non 2xx status code (404 GET https://raw.githubusercontent.com/AsahiLinux/linux/ce9f2eba72c061a50b2d790450e90af3439d8c24/drivers/gpu/drm/apple/dptx.c)
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/tmp/opencode",
  "offset": 1,
  "limit": 100
}
```

**Output:**
```
<path>/tmp/opencode</path>
<type>directory</type>
<entries>
aporetic/
corvid-a11y.mjs
corvid-lighthouse-final.json
corvid-lighthouse-home.json
corvid-preview.log
flyctl-research/
node_modules/
package.json
pnpm-lock.yaml

(9 entries)
</entries>
```

---

## Assistant (Build · GPT-6 Astra · 232.8s)

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c",
  "offset": 1,
  "limit": 2000
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c</path>
<type>file</type>
<content>
1: // SPDX-License-Identifier: GPL-2.0-only OR MIT
2: /* Copyright 2022 Sven Peter <sven@svenpeter.dev> */
3: 
4: #include <linux/bitfield.h>
5: #include <linux/completion.h>
6: #include <linux/phy/phy.h>
7: #include <linux/delay.h>
8: 
9: #include "afk.h"
10: #include "dcp.h"
11: #include "dptxep.h"
12: #include "parser.h"
13: #include "trace.h"
14: 
15: struct dcpdptx_connection_cmd {
16: 	__le32 unk;
17: 	__le32 target;
18: } __attribute__((packed));
19: 
20: struct dcpdptx_hotplug_cmd {
21: 	u8 _pad0[16];
22: 	__le32 unk;
23: } __attribute__((packed));
24: 
25: struct dptxport_apcall_link_rate {
26: 	__le32 retcode;
27: 	u8 _unk0[12];
28: 	__le32 link_rate;
29: 	u8 _unk1[12];
30: } __attribute__((packed));
31: 
32: struct dptxport_apcall_lane_count {
33: 	__le32 retcode;
34: 	u8 _unk0[12];
35: 	__le64 lane_count;
36: 	u8 _unk1[8];
37: } __attribute__((packed));
38: 
39: struct dptxport_apcall_set_active_lane_count {
40: 	__le32 retcode;
41: 	u8 _unk0[12];
42: 	__le64 lane_count;
43: 	u8 _unk1[8];
44: } __packed;
45: 
46: struct dptxport_apcall_get_support {
47: 	__le32 retcode;
48: 	u8 _unk0[12];
49: 	__le32 supported;
50: 	u8 _unk1[12];
51: } __attribute__((packed));
52: 
53: struct dptxport_apcall_max_drive_settings {
54: 	__le32 retcode;
55: 	u8 _unk0[12];
56: 	__le32 max_drive_settings[2];
57: 	u8 _unk1[8];
58: };
59: 
60: struct dptxport_apcall_drive_settings {
61: 	__le32 retcode;
62: 	u8 _unk0[12];
63: 	__le32 unk1;
64: 	__le32 unk2;
65: 	__le32 unk3;
66: 	__le32 unk4;
67: 	__le32 unk5;
68: 	__le32 unk6;
69: 	__le32 unk7;
70: };
71: 
72: int dptxport_validate_connection(struct apple_epic_service *service, u8 core,
73: 				 u8 atc, u8 die)
74: {
75: 	struct dptx_port *dptx = service->cookie;
76: 	struct dcpdptx_connection_cmd cmd, resp;
77: 	int ret;
78: 	u32 target = FIELD_PREP(DCPDPTX_REMOTE_PORT_CORE, core) |
79: 		     FIELD_PREP(DCPDPTX_REMOTE_PORT_ATC, atc) |
80: 		     FIELD_PREP(DCPDPTX_REMOTE_PORT_DIE, die) |
81: 		     DCPDPTX_REMOTE_PORT_CONNECTED;
82: 
83: 	trace_dptxport_validate_connection(dptx, core, atc, die);
84: 
85: 	cmd.target = cpu_to_le32(target);
86: 	cmd.unk = cpu_to_le32(0x100);
87: 	ret = afk_service_call(service, 0, 12, &cmd, sizeof(cmd), 40, &resp,
88: 			       sizeof(resp), 40);
89: 	if (ret)
90: 		return ret;
91: 
92: 	if (le32_to_cpu(resp.target) != target)
93: 		return -EINVAL;
94: 	if (le32_to_cpu(resp.unk) != 0x100)
95: 		return -EINVAL;
96: 
97: 	return 0;
98: }
99: 
100: int dptxport_connect(struct apple_epic_service *service, u8 core, u8 atc,
101: 		     u8 die)
102: {
103: 	struct dptx_port *dptx = service->cookie;
104: 	struct dcpdptx_connection_cmd cmd, resp;
105: 	u32 unk_field = 0x0; // seen as 0x100 under some conditions
106: 	int ret;
107: 	u32 target = FIELD_PREP(DCPDPTX_REMOTE_PORT_CORE, core) |
108: 		     FIELD_PREP(DCPDPTX_REMOTE_PORT_ATC, atc) |
109: 		     FIELD_PREP(DCPDPTX_REMOTE_PORT_DIE, die) |
110: 		     DCPDPTX_REMOTE_PORT_CONNECTED;
111: 
112: 	trace_dptxport_connect(dptx, core, atc, die);
113: 
114: 	cmd.target = cpu_to_le32(target);
115: 	cmd.unk = cpu_to_le32(unk_field);
116: 	ret = afk_service_call(service, 0, 11, &cmd, sizeof(cmd), 24, &resp,
117: 			       sizeof(resp), 24);
118: 	if (ret)
119: 		return ret;
120: 
121: 	if (le32_to_cpu(resp.target) != target)
122: 		return -EINVAL;
123: 	if (le32_to_cpu(resp.unk) != unk_field)
124: 		dev_notice(service->ep->dcp->dev, "unexpected unk field in reply: 0x%x (0x%x)\n",
125: 			  le32_to_cpu(resp.unk), unk_field);
126: 
127: 	return 0;
128: }
129: 
130: int dptxport_request_display(struct apple_epic_service *service)
131: {
132: 	return afk_service_call(service, 0, 6, NULL, 0, 16, NULL, 0, 16);
133: }
134: 
135: int dptxport_release_display(struct apple_epic_service *service)
136: {
137: 	return afk_service_call(service, 0, 7, NULL, 0, 16, NULL, 0, 16);
138: }
139: 
140: int dptxport_set_hpd(struct apple_epic_service *service, bool hpd)
141: {
142: 	struct dcpdptx_hotplug_cmd cmd, resp;
143: 	int ret;
144: 
145: 	memset(&cmd, 0, sizeof(cmd));
146: 
147: 	if (hpd)
148: 		cmd.unk = cpu_to_le32(1);
149: 
150: 	ret = afk_service_call(service, 8, 8, &cmd, sizeof(cmd), 12, &resp,
151: 			       sizeof(resp), 12);
152: 	if (ret)
153: 		return ret;
154: 	if (le32_to_cpu(resp.unk) != 1)
155: 		return -EINVAL;
156: 	return 0;
157: }
158: 
159: static int
160: dptxport_call_get_max_drive_settings(struct apple_epic_service *service,
161: 				     void *reply_, size_t reply_size)
162: {
163: 	struct dptxport_apcall_max_drive_settings *reply = reply_;
164: 
165: 	if (reply_size < sizeof(*reply))
166: 		return -EINVAL;
167: 
168: 	reply->retcode = cpu_to_le32(0);
169: 	reply->max_drive_settings[0] = cpu_to_le32(0x3);
170: 	reply->max_drive_settings[1] = cpu_to_le32(0x3);
171: 
172: 	return 0;
173: }
174: 
175: static int
176: dptxport_call_get_drive_settings(struct apple_epic_service *service,
177: 				     const void *request_, size_t request_size,
178: 				     void *reply_, size_t reply_size)
179: {
180: 	struct dptx_port *dptx = service->cookie;
181: 	const struct dptxport_apcall_drive_settings *request = request_;
182: 	struct dptxport_apcall_drive_settings *reply = reply_;
183: 
184: 	if (reply_size < sizeof(*reply) || request_size < sizeof(*request))
185: 		return -EINVAL;
186: 
187: 	*reply = *request;
188: 
189: 	/* Clear the rest of the buffer */
190: 	memset(reply_ + sizeof(*reply), 0, reply_size - sizeof(*reply));
191: 
192: 	/*
193: 	 * retcode appears to be lane count, seeing 2 for USB-C dp alt mode
194: 	 * with lanes splitted for DP/USB3.
195: 	 */
196: 	if (le32_to_cpu(reply->retcode) != dptx->lane_count)
197: 		dev_err(service->ep->dcp->dev,
198: 			"get_drive_settings: unexpected retcode %d\n",
199: 			reply->retcode);
200: 
201: 	reply->retcode = cpu_to_le32(dptx->lane_count);
202: 	reply->unk5 = cpu_to_le32(dptx->drive_settings[0]);
203: 	reply->unk6 = cpu_to_le32(0);
204: 	reply->unk7 = cpu_to_le32(dptx->drive_settings[1]);
205: 
206: 	return 0;
207: }
208: 
209: static int
210: dptxport_call_set_drive_settings(struct apple_epic_service *service,
211: 				     const void *request_, size_t request_size,
212: 				     void *reply_, size_t reply_size)
213: {
214: 	struct dptx_port *dptx = service->cookie;
215: 	const struct dptxport_apcall_drive_settings *request = request_;
216: 	struct dptxport_apcall_drive_settings *reply = reply_;
217: 
218: 	if (reply_size < sizeof(*reply) || request_size < sizeof(*request))
219: 		return -EINVAL;
220: 
221: 	*reply = *request;
222: 	reply->retcode = cpu_to_le32(0);
223: 
224: 	dev_info(service->ep->dcp->dev, "set_drive_settings: %d:%d:%d:%d:%d:%d:%d\n",
225: 		 request->unk1, request->unk2, request->unk3, request->unk4,
226: 		 request->unk5, request->unk6, request->unk7);
227: 
228: 	dptx->drive_settings[0] = le32_to_cpu(reply->unk5);
229: 	dptx->drive_settings[1] = le32_to_cpu(reply->unk7);
230: 
231: 	return 0;
232: }
233: 
234: static int dptxport_call_get_max_link_rate(struct apple_epic_service *service,
235: 					   void *reply_, size_t reply_size)
236: {
237: 	struct dptxport_apcall_link_rate *reply = reply_;
238: 
239: 	if (reply_size < sizeof(*reply))
240: 		return -EINVAL;
241: 
242: 	reply->retcode = cpu_to_le32(0);
243: 	reply->link_rate = cpu_to_le32(LINK_RATE_HBR3);
244: 
245: 	return 0;
246: }
247: 
248: static int dptxport_call_get_max_lane_count(struct apple_epic_service *service,
249: 					   void *reply_, size_t reply_size)
250: {
251: 	struct dptxport_apcall_lane_count *reply = reply_;
252: 	struct dptx_port *dptx = service->cookie;
253: 	struct apple_dcp *dcp = service->ep->dcp;
254: 	union phy_configure_opts phy_ops;
255: 	int ret;
256: 
257: 	if (reply_size < sizeof(*reply))
258: 		return -EINVAL;
259: 
260: 	ret = phy_validate(dptx->atcphy, PHY_MODE_DP, 0, &phy_ops);
261: 	if (ret < 0) {
262: 		dev_err(dcp->dev, "phy_validate failed: %d\n", ret);
263: 		reply->retcode = cpu_to_le32(1);
264: 		reply->lane_count = cpu_to_le64(0);
265: 	} else {
266: 		if (phy_ops.dp.lanes < 2) {
267: 			// phy_validate might return 0 lanes if atc phy is not
268: 			// yet switched to DP mode
269: 			dev_dbg(dcp->dev, "get_max_lane_count: phy lanes: %d\n",
270: 				phy_ops.dp.lanes);
271: 			// default to 4 lanes
272: 			dptx->lane_count = 4;
273: 		} else {
274: 			dptx->lane_count = phy_ops.dp.lanes;
275: 		}
276: 		reply->retcode = cpu_to_le32(0);
277: 		reply->lane_count = cpu_to_le64(dptx->lane_count);
278: 	}
279: 
280: 	return 0;
281: }
282: 
283: static int dptxport_call_set_active_lane_count(struct apple_epic_service *service,
284: 					       const void *data, size_t data_size,
285: 					       void *reply_, size_t reply_size)
286: {
287: 	struct dptx_port *dptx = service->cookie;
288: 	struct apple_dcp *dcp = service->ep->dcp;
289: 	const struct dptxport_apcall_set_active_lane_count *request = data;
290: 	struct dptxport_apcall_set_active_lane_count *reply = reply_;
291: 	int ret = 0;
292: 	int retcode = 0;
293: 
294: 	if (reply_size < sizeof(*reply))
295: 		return -1;
296: 	if (data_size < sizeof(*request))
297: 		return -1;
298: 
299: 	u64 lane_count = le64_to_cpu(request->lane_count);
300: 
301: 	if (dptx->lane_count < lane_count)
302: 		dev_err(dcp->dev, "set_active_lane_count: unexpected lane "
303: 			"count:%llu phy: %d\n", lane_count, dptx->lane_count);
304: 
305: 	switch (lane_count) {
306: 	case 0 ... 2:
307: 	case 4:
308: 		dptx->phy_ops.dp.lanes = lane_count;
309: 		// Use dptx phy index > 3 as indication for dptx-phy or
310: 		// lpdptx-phy and configure the number of lanes for those
311: 		dptx->phy_ops.dp.set_lanes = (dcp->dptx_phy > 3);
312: 		break;
313: 	default:
314: 		dev_err(dcp->dev, "set_active_lane_count: invalid lane count:%llu\n", lane_count);
315: 		retcode = 1;
316: 		lane_count = 0;
317: 		break;
318: 	}
319: 
320: 	if (dptx->phy_ops.dp.set_lanes) {
321: 		if (dptx->atcphy) {
322: 			ret = phy_configure(dptx->atcphy, &dptx->phy_ops);
323: 			if (ret)
324: 				return ret;
325: 		}
326: 		dptx->phy_ops.dp.set_lanes = 0;
327: 		dptx->lane_count = lane_count;
328: 	}
329: 
330: 	reply->retcode = cpu_to_le32(retcode);
331: 	reply->lane_count = cpu_to_le64(lane_count);
332: 
333: 	if (lane_count > 0)
334: 		complete(&dptx->linkcfg_completion);
335: 
336: 	return ret;
337: }
338: 
339: static int dptxport_call_get_link_rate(struct apple_epic_service *service,
340: 				       void *reply_, size_t reply_size)
341: {
342: 	struct dptx_port *dptx = service->cookie;
343: 	struct dptxport_apcall_link_rate *reply = reply_;
344: 
345: 	if (reply_size < sizeof(*reply))
346: 		return -EINVAL;
347: 
348: 	reply->retcode = cpu_to_le32(0);
349: 	reply->link_rate = cpu_to_le32(dptx->link_rate);
350: 
351: 	return 0;
352: }
353: 
354: static int
355: dptxport_call_will_change_link_config(struct apple_epic_service *service)
356: {
357: 	struct dptx_port *dptx = service->cookie;
358: 
359: 	dptx->phy_ops.dp.set_lanes = 0;
360: 	dptx->phy_ops.dp.set_rate = 0;
361: 	dptx->phy_ops.dp.set_voltages = 0;
362: 
363: 	return 0;
364: }
365: 
366: static int
367: dptxport_call_did_change_link_config(struct apple_epic_service *service)
368: {
369: 	/* assume the link config did change and wait a little bit */
370: 	mdelay(10);
371: 
372: 	return 0;
373: }
374: 
375: static int dptxport_call_set_link_rate(struct apple_epic_service *service,
376: 				       const void *data, size_t data_size,
377: 				       void *reply_, size_t reply_size)
378: {
379: 	struct dptx_port *dptx = service->cookie;
380: 	const struct dptxport_apcall_link_rate *request = data;
381: 	struct dptxport_apcall_link_rate *reply = reply_;
382: 	u32 link_rate, phy_link_rate;
383: 	bool phy_set_rate = false;
384: 	int ret;
385: 
386: 	if (reply_size < sizeof(*reply))
387: 		return -EINVAL;
388: 	if (data_size < sizeof(*request))
389: 		return -EINVAL;
390: 
391: 	link_rate = le32_to_cpu(request->link_rate);
392: 	trace_dptxport_call_set_link_rate(dptx, link_rate);
393: 
394: 	switch (link_rate) {
395: 	case LINK_RATE_RBR:
396: 		phy_link_rate = 1620;
397: 		phy_set_rate = true;
398: 		break;
399: 	case LINK_RATE_HBR:
400: 		phy_link_rate = 2700;
401: 		phy_set_rate = true;
402: 		break;
403: 	case LINK_RATE_HBR2:
404: 		phy_link_rate = 5400;
405: 		phy_set_rate = true;
406: 		break;
407: 	case LINK_RATE_HBR3:
408: 		phy_link_rate = 8100;
409: 		phy_set_rate = true;
410: 		break;
411: 	case 0:
412: 		phy_link_rate = 0;
413: 		phy_set_rate = true;
414: 		break;
415: 	default:
416: 		dev_err(service->ep->dcp->dev,
417: 			"DPTXPort: Unsupported link rate 0x%x requested\n",
418: 			link_rate);
419: 		link_rate = 0;
420: 		phy_set_rate = false;
421: 		break;
422: 	}
423: 
424: 	if (phy_set_rate) {
425: 		dptx->phy_ops.dp.link_rate = phy_link_rate;
426: 		dptx->phy_ops.dp.set_rate = 1;
427: 
428: 		if (dptx->atcphy) {
429: 			ret = phy_configure(dptx->atcphy, &dptx->phy_ops);
430: 			if (ret)
431: 				return ret;
432: 		}
433: 
434: 		//if (dptx->phy_ops.dp.set_rate)
435: 		dptx->link_rate = dptx->pending_link_rate = link_rate;
436: 
437: 	}
438: 
439: 	//dptx->pending_link_rate = link_rate;
440: 	reply->retcode = cpu_to_le32(0);
441: 	reply->link_rate = cpu_to_le32(link_rate);
442: 
443: 	return 0;
444: }
445: 
446: static int dptxport_call_get_supports_hpd(struct apple_epic_service *service,
447: 					  void *reply_, size_t reply_size)
448: {
449: 	struct dptxport_apcall_get_support *reply = reply_;
450: 
451: 	if (reply_size < sizeof(*reply))
452: 		return -EINVAL;
453: 
454: 	reply->retcode = cpu_to_le32(0);
455: 	reply->supported = cpu_to_le32(0);
456: 	return 0;
457: }
458: 
459: static int
460: dptxport_call_get_supports_downspread(struct apple_epic_service *service,
461: 				      void *reply_, size_t reply_size)
462: {
463: 	struct dptxport_apcall_get_support *reply = reply_;
464: 
465: 	if (reply_size < sizeof(*reply))
466: 		return -EINVAL;
467: 
468: 	reply->retcode = cpu_to_le32(0);
469: 	reply->supported = cpu_to_le32(0);
470: 	return 0;
471: }
472: 
473: static int
474: dptxport_call_activate(struct apple_epic_service *service,
475: 		       const void *data, size_t data_size,
476: 		       void *reply, size_t reply_size)
477: {
478: 	struct dptx_port *dptx = service->cookie;
479: 	const struct apple_dcp *dcp = service->ep->dcp;
480: 
481: 	// TODO: hack, use phy_set_mode to select the correct DCP(EXT) input
482: 	// for standalone phy (i.e. not atc phy).
483: 	if (!dcp->typec_mux)
484: 		phy_set_mode_ext(dptx->atcphy, PHY_MODE_DP, dcp->index);
485: 
486: 	memcpy(reply, data, min(reply_size, data_size));
487: 	if (reply_size >= 4)
488: 		memset(reply, 0, 4);
489: 
490: 	return 0;
491: }
492: 
493: static int
494: dptxport_call_deactivate(struct apple_epic_service *service,
495: 		       const void *data, size_t data_size,
496: 		       void *reply, size_t reply_size)
497: {
498: 	struct dptx_port *dptx = service->cookie;
499: 
500: 	/* deactivate phy */
501: 	phy_set_mode_ext(dptx->atcphy, PHY_MODE_INVALID, 0);
502: 
503: 	memcpy(reply, data, min(reply_size, data_size));
504: 	if (reply_size >= 4)
505: 		memset(reply, 0, 4);
506: 
507: 	return 0;
508: }
509: 
510: static int dptxport_call(struct apple_epic_service *service, u32 idx,
511: 			 const void *data, size_t data_size, void *reply,
512: 			 size_t reply_size)
513: {
514: 	struct dptx_port *dptx = service->cookie;
515: 	trace_dptxport_apcall(dptx, idx, data_size);
516: 
517: 	switch (idx) {
518: 	case DPTX_APCALL_WILL_CHANGE_LINKG_CONFIG:
519: 		return dptxport_call_will_change_link_config(service);
520: 	case DPTX_APCALL_DID_CHANGE_LINK_CONFIG:
521: 		return dptxport_call_did_change_link_config(service);
522: 	case DPTX_APCALL_GET_MAX_LINK_RATE:
523: 		return dptxport_call_get_max_link_rate(service, reply,
524: 						       reply_size);
525: 	case DPTX_APCALL_GET_LINK_RATE:
526: 		return dptxport_call_get_link_rate(service, reply, reply_size);
527: 	case DPTX_APCALL_SET_LINK_RATE:
528: 		return dptxport_call_set_link_rate(service, data, data_size,
529: 						   reply, reply_size);
530: 	case DPTX_APCALL_GET_MAX_LANE_COUNT:
531: 		return dptxport_call_get_max_lane_count(service, reply, reply_size);
532:         case DPTX_APCALL_SET_ACTIVE_LANE_COUNT:
533: 		return dptxport_call_set_active_lane_count(service, data, data_size,
534: 							   reply, reply_size);
535: 	case DPTX_APCALL_GET_SUPPORTS_HPD:
536: 		return dptxport_call_get_supports_hpd(service, reply,
537: 						      reply_size);
538: 	case DPTX_APCALL_GET_SUPPORTS_DOWN_SPREAD:
539: 		return dptxport_call_get_supports_downspread(service, reply,
540: 							     reply_size);
541: 	case DPTX_APCALL_GET_MAX_DRIVE_SETTINGS:
542: 		return dptxport_call_get_max_drive_settings(service, reply,
543: 							    reply_size);
544: 	case DPTX_APCALL_GET_DRIVE_SETTINGS:
545: 		return dptxport_call_get_drive_settings(service, data, data_size,
546: 							reply, reply_size);
547: 	case DPTX_APCALL_SET_DRIVE_SETTINGS:
548: 		return dptxport_call_set_drive_settings(service, data, data_size,
549: 							reply, reply_size);
550:         case DPTX_APCALL_ACTIVATE:
551: 		return dptxport_call_activate(service, data, data_size,
552: 					      reply, reply_size);
553: 	case DPTX_APCALL_DEACTIVATE:
554: 		return dptxport_call_deactivate(service, data, data_size,
555: 						reply, reply_size);
556: 	default:
557: 		/* just try to ACK and hope for the best... */
558: 		dev_info(service->ep->dcp->dev, "DPTXPort: acking unhandled call %u\n",
559: 			idx);
560: 		fallthrough;
561: 	case DPTX_APCALL_GET_DOWN_SPREAD:
562: 	case DPTX_APCALL_SET_DOWN_SPREAD:
563: 		memcpy(reply, data, min(reply_size, data_size));
564: 		if (reply_size >= 4)
565: 			memset(reply, 0, 4);
566: 		return 0;
567: 	}
568: }
569: 
570: static void dptxport_init(struct apple_epic_service *service, const char *name,
571: 			  const char *class, s64 unit)
572: {
573: 
574: 	if (strcmp(name, "dcpdptx-port-epic"))
575: 		return;
576: 	if (strcmp(class, "AppleDCPDPTXRemotePort"))
577: 		return;
578: 
579: 	trace_dptxport_init(service->ep->dcp, unit);
580: 
581: 	switch (unit) {
582: 	case 0:
583: 	case 1:
584: 		if (service->ep->dcp->dptxport[unit].enabled) {
585: 			dev_err(service->ep->dcp->dev,
586: 				"DPTXPort: unit %lld already exists\n", unit);
587: 			return;
588: 		}
589: 		service->ep->dcp->dptxport[unit].unit = unit;
590: 		service->ep->dcp->dptxport[unit].service = service;
591: 		service->ep->dcp->dptxport[unit].enabled = true;
592: 		service->cookie = (void *)&service->ep->dcp->dptxport[unit];
593: 		complete(&service->ep->dcp->dptxport[unit].enable_completion);
594: 		break;
595: 	default:
596: 		dev_err(service->ep->dcp->dev, "DPTXPort: invalid unit %lld\n",
597: 			unit);
598: 	}
599: }
600: 
601: static const struct apple_epic_service_ops dptxep_ops[] = {
602: 	{
603: 		.name = "AppleDCPDPTXRemotePort",
604: 		.init = dptxport_init,
605: 		.call = dptxport_call,
606: 	},
607: 	{}
608: };
609: 
610: int dptxep_init(struct apple_dcp *dcp)
611: {
612: 	int ret;
613: 	u32 port;
614: 	unsigned long timeout = msecs_to_jiffies(1000);
615: 
616: 	init_completion(&dcp->dptxport[0].enable_completion);
617: 	init_completion(&dcp->dptxport[1].enable_completion);
618: 	init_completion(&dcp->dptxport[0].linkcfg_completion);
619: 	init_completion(&dcp->dptxport[1].linkcfg_completion);
620: 
621: 	dcp->dptxep = afk_init(dcp, DPTX_ENDPOINT, dptxep_ops);
622: 	if (IS_ERR(dcp->dptxep))
623: 		return PTR_ERR(dcp->dptxep);
624: 
625: 	ret = afk_start(dcp->dptxep);
626: 	if (ret)
627: 		return ret;
628: 
629: 	for (port = 0; port < dcp->hw.num_dptx_ports; port++) {
630: 		ret = wait_for_completion_timeout(&dcp->dptxport[port].enable_completion,
631: 						timeout);
632: 		if (!ret)
633: 			return -ETIMEDOUT;
634: 		else if (ret < 0)
635: 			return ret;
636: 		timeout = ret;
637: 	}
638: 
639: 	return 0;
640: }

(End of file - total 640 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.h",
  "offset": 1,
  "limit": 500
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.h</path>
<type>file</type>
<content>
1: #ifndef __APPLE_DCP_DPTXEP_H__
2: #define __APPLE_DCP_DPTXEP_H__
3: 
4: #include <linux/phy/phy.h>
5: #include <linux/mux/consumer.h>
6: 
7: enum dptx_apcall {
8: 	DPTX_APCALL_ACTIVATE = 0,
9: 	DPTX_APCALL_DEACTIVATE = 1,
10: 	DPTX_APCALL_GET_MAX_DRIVE_SETTINGS = 2,
11: 	DPTX_APCALL_SET_DRIVE_SETTINGS = 3,
12: 	DPTX_APCALL_GET_DRIVE_SETTINGS = 4,
13: 	DPTX_APCALL_WILL_CHANGE_LINKG_CONFIG = 5,
14: 	DPTX_APCALL_DID_CHANGE_LINK_CONFIG = 6,
15: 	DPTX_APCALL_GET_MAX_LINK_RATE = 7,
16: 	DPTX_APCALL_GET_LINK_RATE = 8,
17: 	DPTX_APCALL_SET_LINK_RATE = 9,
18: 	DPTX_APCALL_GET_MAX_LANE_COUNT = 10,
19: 	DPTX_APCALL_GET_ACTIVE_LANE_COUNT = 11,
20: 	DPTX_APCALL_SET_ACTIVE_LANE_COUNT = 12,
21: 	DPTX_APCALL_GET_SUPPORTS_DOWN_SPREAD = 13,
22: 	DPTX_APCALL_GET_DOWN_SPREAD = 14,
23: 	DPTX_APCALL_SET_DOWN_SPREAD = 15,
24: 	DPTX_APCALL_GET_SUPPORTS_LANE_MAPPING = 16,
25: 	DPTX_APCALL_SET_LANE_MAP = 17,
26: 	DPTX_APCALL_GET_SUPPORTS_HPD = 18,
27: 	DPTX_APCALL_FORCE_HOTPLUG_DETECT = 19,
28: 	DPTX_APCALL_INACTIVE_SINK_DETECTED = 20,
29: 	DPTX_APCALL_SET_TILED_DISPLAY_HINTS = 21,
30: 	DPTX_APCALL_DEVICE_NOT_RESPONDING = 22,
31: 	DPTX_APCALL_DEVICE_BUSY_TIMEOUT = 23,
32: 	DPTX_APCALL_DEVICE_NOT_STARTED = 24,
33: };
34: 
35: #define DCPDPTX_REMOTE_PORT_CORE GENMASK(3, 0)
36: #define DCPDPTX_REMOTE_PORT_ATC GENMASK(7, 4)
37: #define DCPDPTX_REMOTE_PORT_DIE GENMASK(11, 8)
38: #define DCPDPTX_REMOTE_PORT_CONNECTED BIT(15)
39: 
40: enum dptx_link_rate {
41: 	LINK_RATE_RBR = 0x06,
42: 	LINK_RATE_HBR = 0x0a,
43: 	LINK_RATE_HBR2 = 0x14,
44: 	LINK_RATE_HBR3 = 0x1e,
45: };
46: 
47: struct apple_epic_service;
48: 
49: struct dptx_port {
50: 	bool enabled, connected;
51: 	struct completion enable_completion;
52: 	struct completion linkcfg_completion;
53: 	u32 unit;
54: 	struct apple_epic_service *service;
55: 	union phy_configure_opts phy_ops;
56: 	struct phy *atcphy;
57: 	struct mux_control *mux;
58: 	u32 lane_count;
59: 	u32 link_rate, pending_link_rate;
60: 	u32 drive_settings[2];
61: };
62: 
63: int dptxport_validate_connection(struct apple_epic_service *service, u8 core,
64: 				 u8 atc, u8 die);
65: int dptxport_connect(struct apple_epic_service *service, u8 core, u8 atc,
66: 		     u8 die);
67: int dptxport_request_display(struct apple_epic_service *service);
68: int dptxport_release_display(struct apple_epic_service *service);
69: int dptxport_set_hpd(struct apple_epic_service *service, bool hpd);
70: #endif

(End of file - total 70 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/ivy/nix/modules/hardware/apple-silicon.nix",
  "offset": 1,
  "limit": 200
}
```

**Output:**
```
<path>/home/ivy/nix/modules/hardware/apple-silicon.nix</path>
<type>file</type>
<content>
1: {
2:   inputs,
3:   lib,
4:   pkgs,
5:   config,
6:   ...
7: }:
8: 
9: let
10:   fairydustPackages =
11:     pkgs.callPackage
12:       (
13:         {
14:           lib,
15:           callPackage,
16:           linuxPackagesFor,
17:           _kernelPatches ? [ ],
18:           ...
19:         }@args:
20: 
21:         let
22:           extraArgs = lib.removeAttrs args [
23:             "lib"
24:             "callPackage"
25:             "linuxPackagesFor"
26:             "_kernelPatches"
27:           ];
28: 
29:           linux-asahi-pkg =
30:             {
31:               stdenv,
32:               lib,
33:               fetchFromGitHub,
34:               buildLinux,
35:               ...
36:             }:
37:             buildLinux (
38:               lib.recursiveUpdate rec {
39:                 inherit stdenv lib;
40: 
41:                 pname = "linux-asahi";
42:                 version = "7.1.5";
43:                 modDirVersion = version;
44: 
45:                 extraMeta.branch = "7.1";
46: 
47:                 src = fetchFromGitHub {
48:                   owner = "AsahiLinux";
49:                   repo = "linux";
50:                   tag = "asahi-7.1.5-2";
51:                   hash = "sha256-z7S0YTmDshMK2frFhMm4M4wUOV3rPOwxPkR2IXk4R+Y=";
52:                 };
53: 
54:                 kernelPatches = [
55:                   {
56:                     name = "Asahi config";
57:                     patch = null;
58: 
59:                     structuredExtraConfig = with lib.kernel; {
60:                       ARM64_16K_PAGES = yes;
61:                       ARM64_MEMORY_MODEL_CONTROL = yes;
62:                       ARM64_ACTLR_STATE = yes;
63: 
64:                       APPLE_WATCHDOG = yes;
65:                       APPLE_M1_CPU_PMU = yes;
66: 
67:                       HID_APPLE = module;
68: 
69:                       APPLE_PMGR_MISC = yes;
70:                       APPLE_PMGR_PWRSTATE = yes;
71:                     };
72: 
73:                     features.rust = true;
74:                   }
75:                 ]
76:                 ++ _kernelPatches;
77:               } extraArgs
78:             );
79: 
80:           linux-asahi = callPackage linux-asahi-pkg { };
81:         in
82:         lib.recurseIntoAttrs (
83:           linuxPackagesFor linux-asahi
84:         )
85:       )
86:       {
87:         _kernelPatches = config.boot.kernelPatches;
88: 
89:         version = "7.1.13";
90:         modDirVersion = "7.1.13";
91: 
92:         src = pkgs.fetchFromGitHub {
93:           owner = "AsahiLinux";
94:           repo = "linux";
95:           rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
96:           hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
97:         };
98:       };
99: in
100: {
101:   imports = [
102:     inputs.apple-silicon.nixosModules.default
103:   ];
104: 
105:   hardware.asahi = {
106:     enable = true;
107:     extractPeripheralFirmware = true;
108:     peripheralFirmwareDirectory = inputs.asahi-firmware;
109:   };
110: 
111:   boot.kernelPackages = lib.mkForce fairydustPackages;
112: 
113:   boot.loader = {
114:     systemd-boot.enable = true;
115:     efi.canTouchEfiVariables = false;
116:   };
117: }

(End of file - total 117 lines)
</content>
```

**Tool: task**

**Input:**
```json
{
  "description": "Trace firmware DRM hotplug",
  "prompt": "Research exact cached kernel /nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source (ce9f2eba72c061a50b2d790450e90af3439d8c24), no edits. Trace external DCP path from DPTX connection to firmware mode/timing callbacks, HPD, dcp_hotplug, DRM detect/get_modes, AV EDID copy. Explain why internal 231c00000.dcp display HPD asserted is not external evidence; secondary setup_video_limits with no timing. Identify all gates and ordering traps leading disconnected no modes despite physical plug, including timing filtering. Return precise file/line refs, key code excerpts, strategic logging spots. Thorough review but bounded to apple DRM code and relevant calls.",
  "subagent_type": "explore",
  "task_id": "",
  "command": ""
}
```

**Output:**
```
task_id: ses_f6011a57bffeLXzuTCflJMXj2B (for resuming to continue this task if needed)

<task_result>
## Conclusion

I reviewed the files directly in the requested cached source:

`/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source`

—the tree you identified as `ce9f2eba72c061a50b2d790450e90af3439d8c24`. No edits or state-changing commands were made.

**A physical plug, a successful-looking DPTX connect log, firmware “display HPD asserted,” Linux’s connector-connected flag, and a usable timing list are separate milestones. This driver does not automatically reconcile them.**

The most important ordering problem is:

> **Receiving `TimingElements` updates `dcp->modes/nr_modes`, but does not set the connector connected and does not schedule a hotplug event. Conversely, a hotplug callback can mark the connector connected before timings exist.**

Consequently:

- **Disconnected + no exposed modes** can occur even when cached firmware modes exist: DRM stops before `get_modes()`.
- **Connected + no modes** can occur when timings never arrive, parsing/filtering eliminates them, or DRM rejects them.
- **No EDID** can simply be downstream fallout: this driver only attempts AV EDID copy when `nr_modes > 0`.

Below, citations use file names and exact line ranges. The reference index at the end resolves every file name to an absolute path.

---

## 1. External connection path: what each stage actually proves

### A. External HPD enters through OOB notification or the HDMI GPIO

**USB-C/OOB path**

```text
Type-C controller / DP-altmode HPD
  → drm_connector_oob_hotplug_event(connector_fwnode, status)
  → apple_connector_oob_hotplug()
  → dcp_dptx_connect_oob(..., 0)
  → dcp_dptx_connect(dcp, 0)
```

Relevant implementation:

- `apple_drv.c:87–101`: connected/disconnected OOB statuses call the DPTX wrappers, always with **port 0**. Return values are ignored.
- `drm_connector.c:3486–3535`: finds a connector by matching its fwnode, then invokes its OOB callback. **No matching connector means a silent return; this function does not queue a replay.**
- `apple_drv.c:323–339,390–398`: the external connector receives the DCP device’s fwnode; “external” here means `apple,dcpext` **or a node with `phys`**.
- For the Apple CD321x controller, `tipd/core.c:657–658,688–749`: HPD level/change is distinct from physical plug presence. It can issue disconnect first, updates Type-C mux/PHY state, and then issues connected if HPD is high.
- The generic DP-altmode implementation has its own configuration/pending-HPD ordering: `altmodes/displayport.c:162–225`.

**Ordering gate:** an OOB event before connector creation/fwnode matching, or before DPTX service enablement, can be lost or rejected. Apple DRM supplies no deferred-connect retry for that failure.

**DP-to-HDMI GPIO path**

- `dcp.c:454–476`: samples HPD; on high, sleeps **500 ms**, resamples, and connects only if still high.
- Falling-edge IRQs are logged but **deliberately do not disconnect**. The comment says to trust firmware detection.
- `dcp.c:1224–1258`: GPIOs are optional; IRQ is requested with `IRQF_NO_AUTOEN`; converter power GPIOs are raised because converter power is required for HPD.
- `dcp.c:590–631`: after DCP readiness, samples the already-high level before enabling IRQs, to cover an already-plugged monitor.

Thus a connector being physically populated is not enough: the relevant HPD source must deliver the right event to the right DCP.

### B. DPTX connects a transport; it does not set DRM connected

Key excerpt, `dcp.c:377–399`:

```c
if (dcp->dptxport[port].connected)
        goto out_unlock;

reinit_completion(&dcp->dptxport[port].linkcfg_completion);
dcp->dptxport[port].atcphy = dcp->phy;
dptxport_connect(...);
dptxport_request_display(...);
dcp->dptxport[port].connected = true;

mutex_unlock(&dcp->hpd_mutex);
ret = wait_for_completion_timeout(..., DPTX_CONNECT_TIMEOUT);
...
if (dcp->connector_type == DRM_MODE_CONNECTOR_DisplayPort)
        dptxport_set_hpd(..., true);
```

Important gates and misleading-success cases:

1. **Missing PHY:** returns `-ENODEV` (`dcp.c:364–367`).
2. **DPTX service not enabled:** returns `-ENODEV` (`371–375`).
3. **Already marked transport-connected:** exits without repeating request-display, waiting, or asserting HPD (`377–378`).
4. **Both connect and request-display errors are discarded**, yet the transport flag is set true (`382–384`).
5. The wait is **2 seconds**. `wait_for_completion_timeout()` reports timeout as **zero**, but the warning checks `ret < 0`. A real timeout follows the debug “waited …” path and execution continues (`358,387–404`).
6. `dptxport_set_hpd(true)` is called **only for `DRM_MODE_CONNECTOR_DisplayPort`**, not HDMI-A, USB, or Unknown; its return value is also ignored.
7. This function never sets `dcp->connector->connected`.

**Practical trap:** one failed attempt can leave `dptxport[0].connected = true`, making subsequent connected notifications ineffective until the release/disconnect path clears it.

Also, the mutex is released **before** the wait and outgoing HPD assertion. A concurrent disconnect can interleave, followed by the original connect path asserting HPD afterward. There is no post-wait revalidation (`dcp.c:386–402,419–451`).

### C. Firmware DPTX callbacks are not proof of a trained/displaying link

Protocol calls in `dptxep.c`:

| Operation | Location | AFK group/command |
|---|---:|---:|
| Connect target core/PHY/die | 100–128 | `0/11` |
| Request display | 130–133 | `0/6` |
| Release display | 135–138 | `0/7` |
| Set HPD | 140–157 | `8/8` |

The function `dptxport_validate_connection()` exists (`72–98`) but is **not called by `dcp_dptx_connect()`**.

Firmware AP calls configure routing, rate and lanes:

- Activate selects the DCP input using `phy_set_mode_ext()` when there is no Type-C mux; its error is not checked (`dptxep.c:473–490`).
- Maximum-lane query uses `phy_validate()`; failure reports zero lanes. If the PHY is not yet switched to DP and reports fewer than two lanes, the code defaults to four (`248–280`).
- Link-rate programming uses `phy_configure()` and can fail (`375–443`).
- Active-lane programming accepts `0,1,2,4`; configuration failures return early. **Any accepted positive lane count completes `linkcfg_completion`** (`283–337`).

That completion is a **lane-configuration callback**, not a definitive “monitor timings available / DRM connected / link trained” completion.

`get_supports_hpd` returns supported = 0 (`446–457`); it does not sample physical HPD.

---

## 2. Firmware startup, `setup_video_limits`, and timing delivery

### Firmware/version/service gates

- `dcp.c:938–971`: only 12.3 and the supported 13.5 compatibility cases are accepted. Compatibility 13.3 is accepted only with actual firmware 13.5.
- `dcp.c:522–558`: DPTX startup additionally requires a PHY and firmware compatibility ≥13.5.
- The **13.5 IOMFB implementation is named `v13_3`**. Do not mistake the source filename for the actual supported DPTX firmware version.
- `dptxep.c:570–639`: requires service name `dcpdptx-port-epic`, class `AppleDCPDPTXRemotePort`, and unit 0 or 1. Startup waits for the hardware-declared number of ports using a shared **1-second** budget.
- `afk.c:276–318`: service-property parsing/matching must succeed. The generic “new service” log follows `ops->init()`; it does not itself prove the DPTX-specific initializer accepted/enabled the unit.

### Why secondary `setup_video_limits` is not evidence of a monitor

`A029` is the `setup_video_limits` method in both method tables:

- `iomfb_v13_3.c:8–31`
- `iomfb_v12_3.c:8–31`

It is sent as part of the generic boot callback sequence, unconditionally:

```c
static void boot_2(...)
{
        dcp_setup_video_limits(dcp, false, boot_3, NULL);
}
```

`iomfb_template.c:608–657`:

```text
boot callback
 → set_create_dfb
 → create_default_fb
 → setup_video_limits
 → flush_supports_power
 → late_init_signal
 → set_display_refresh_properties
 → ACK boot callback
```

**A secondary DCP reaching `setup_video_limits` proves that its boot/control sequence reached that request. It does not prove that the request returned, an external sink was acquired, or a timing dictionary was delivered.**

Actual mode publication follows a separate firmware callback path:

```text
IOMFB endpoint 0x37
 → callback dispatch
 → property Start / Chunk / End
 → key == "TimingElements"
 → enumerate_modes()
 → dcp->modes, dcp->nr_modes
```

Callback IDs:

| IOMFB implementation | Start / Chunk / End | Hotplug |
|---|---|---|
| 13.5 using `v13_3` | `D126 / D127 / D128` | `D576` |
| 12.3 | `D122 / D123 / D124` | `D576` |

References: `iomfb_v13_3.c:59–65,91`; `iomfb_v12_3.c:54–60,85`.

Incoming routing/dispatch is at `dcp.c:222–245` and `iomfb.c:262–344,516–525`. Unknown/missing callback handlers produce a warning and return without the normal callback ACK (`iomfb.c:272–275`).

### Timing transfer gates

`iomfb_template.c:510–605`:

- Only one chunk transfer per DCP at a time.
- Rejects a second start while a buffer exists.
- Rejects allocation failure, chunk without start, overflowing chunk, and end without start.
- Requires the serialized header to parse.
- Only the exact key **`TimingElements`** populates modes.
- Enumeration error resets `modes = NULL`, `nr_modes = 0`.
- Successful enumeration with zero accepted modes logs:
  `TimingElements without valid modes!`

**Neither successful timing publication nor `DisplayAttributes` processing schedules hotplug.**

Raw dictionaries are moved into the connector’s debugfs storage even when parsing fails (`595–605`; `connector.c:124–150`). Therefore:

> A nonempty debugfs `TimingElements` proves receipt/storage, not successful parsing or accepted modes.

---

## 3. HPD → Linux connector state: the critical ordering traps

There are two normal writers that can make the connector connected.

### Startup inference from the current mode count

`iomfb_template.c:1420–1435`:

```c
dcp->main_display = result != 0;

if (connector) {
        connector->connected = dcp->nr_modes > 0;
        schedule_work(&connector->hotplug_wq);
}

dcp->active = true;
complete(&dcp->start_done);
```

This assignment happens for **both main and secondary DCPs**.

Consequences:

- DCP can be **active/ready with zero modes and disconnected**.
- If a connected callback occurred earlier, startup can **overwrite it with disconnected** because timings have not arrived yet.
- If timings arrive afterward, they **do not repair the connected flag**.
- `main_display` is a firmware-returned property, not equivalent to `active`, `valid_mode`, or transport connected.

### Firmware hotplug callback

`iomfb_template.c:1009–1045`:

```c
if (dcp->main_display)
        return;

if (dcp->during_modeset)
        return;

if (!(*connected))
        dcp->valid_mode = false;

if (connector && connector->connected != !!(*connected)) {
        connector->connected = !!(*connected);
        dcp->valid_mode = false;
        schedule_work(&connector->hotplug_wq);
}
```

The gates are:

- Main displays ignore these callbacks entirely.
- Callbacks during modeset are discarded, **not deferred/replayed**.
- Only a **state change** queues connector hotplug.
- A disconnected callback invalidates the current mode, but does **not clear the firmware mode list**.
- A connected callback does **not require `nr_modes > 0`**.

Two particularly important sequences:

**Sequence 1: persistent disconnected**

```text
res_is_main_display: nr_modes=0 → connected=false
TimingElements later succeeds → nr_modes>0
no subsequent accepted D576 connected transition
→ detect remains disconnected; get_modes is skipped
```

**Sequence 2: connected but initial probe has no modes**

```text
D576 connected → connected=true → hotplug work → probe sees nr_modes=0
TimingElements arrives later
repeated D576 connected sees no flag change → no new hotplug work
→ userspace may retain its empty mode list until another reprobe
```

These are code-supported failure sequences, not proof that either occurred on the machine.

### Workqueue and late modeset

`iomfb.c:227–260`: `dcp_hotplug()` runs outside the RTKit thread to avoid deadlock when DRM clients submit commits that need firmware callbacks.

It:

1. Logs `connected`, `valid_mode`, `nr_modes`.
2. Frees cached EDID if disconnected.
3. Marks link status **BAD** if connector state exists, connected is true, and no valid mode is programmed.
4. Sends the connector hotplug event.

The code explicitly says firmware defers link training until a display mode is set. Therefore **waiting for a fully trained link before exposing/choosing a mode would be circular**.

The current modeset is invoked from atomic enable (`apple_drv.c:103–118`), although the older comment in `dcp_hotplug()` mentions atomic flush. Modeset uses the firmware timing/color IDs and suppresses HPD callbacks for up to **8.5 seconds** (`iomfb_template.c:1193–1277`).

---

## 4. Why `231c00000.dcp: … display HPD asserted` is not external evidence

For the **internal instance identified in your question**:

1. RTKit firmware logs are emitted using that RTKit instance’s device:
   ```c
   dev_info(rtk->dev, "RTKit: syslog message: %s: %s\n", ...);
   ```
   `rtkit.c:471–486`.

2. DCP creates its RTKit instance with its own device/cookie (`dcp.c:1076–1084`). Its connector, mode list, flags and endpoints are per-instance (`dcp-internal.h:117–210,238–268`).

3. The literal “display HPD asserted” is not an Apple DRM host-code status setter in this tree. A firmware syslog line is not the same operation as `D576`, nor as writing `connector->connected`.

4. Internal panels deliberately ignore `D576` after `main_display` becomes true, because firmware produces power-state-related hotplug callbacks that must not disconnect an integrated panel (`iomfb_template.c:1013–1021`).

Thus **internal HPD says nothing about whether the secondary DCP received an external HPD, published timings, or changed its connector flag**. Correlate by device prefix throughout.

The address is not universally an “internal-only” architectural classification: `231c00000` is the primary `dcp` node in both `t8103.dtsi:646–666` and `t8112.dtsi:737–759`; board configuration determines its use. The relevant distinction here is the identified instance and its panel/connector configuration.

---

## 5. DRM detect/get_modes and why EDID cannot rescue missing firmware timings

### Detect is just a cached Boolean

`apple_drv.c:78–85`:

```c
return apple_connector->connected ? connector_status_connected :
                                    connector_status_disconnected;
```

It does **not**:

- sample GPIO HPD;
- query DPTX;
- inspect `nr_modes`;
- read EDID;
- retry connection.

The connector is initialized disconnected and marked `DRM_CONNECTOR_POLL_HPD` (`apple_drv.c:332–336`). Generic polling skips HPD-only connectors (`drm_probe_helper.c:792–795`), so polling is not an automatic repair mechanism.

### Disconnected blocks mode enumeration entirely

`drm_probe_helper.c:641–649`:

```c
if (connector->status == connector_status_disconnected) {
        drm_connector_update_edid_property(connector, NULL);
        drm_mode_prune_invalid(dev, &connector->modes, false);
        goto exit;
}

count = drm_helper_probe_get_modes(connector);
```

This explains **disconnected + empty modes even with `dcp->nr_modes > 0`**.

The hotplug helper itself emits notifications and invokes DRM clients; it does not independently detect hardware (`drm_probe_helper.c:714–754`).

### Modes come from firmware, not copied EDID

`iomfb.c:346–381`:

```c
for (i = 0; i < dcp->nr_modes; ++i) {
        mode = drm_mode_duplicate(dev, &dcp->modes[i].mode);
        ...
        drm_mode_probed_add(connector, mode);
}

if (dcp->nr_modes && dcp->dcpavserv.enabled &&
    !apple_connector->drm_edid)
        edid = dcpavserv_copy_edid(...);

...
return dcp->nr_modes;
```

EDID is used with `drm_edid_connector_update()`, **not `drm_edid_connector_add_modes()`**.

### AV EDID gates and pitfalls

The EDID service is **DPAVSERV endpoint `0x28`**, not the audio AV endpoint `0x29` (`dcp-internal.h:36–46`).

- `unstable_edid` defaults true (`dcp.c:57–59`).
- DPAVSERV starts only with `unstable_edid && !dcp_has_panel(dcp)` (`515–520`); panel detection here is width > 0 (`193–196`).
- Requires the unit-0 `dcpav-service-epic` service (`dpavservep.c:17–33`).
- **Service-enable wait timeout incorrectly counts as success:** `ret >= 0` includes zero (`211–232`). Initialization can return success while `dcpavserv.enabled` is still false.
- Service arrival does not trigger a DRM reprobe.
- Copy occurs only with nonzero modes, enabled service and no cached EDID.
- Copy uses group/command **`1/7`**; validates returned maximum size, minimum one block plus 8 leading bytes, and exact extension-count-derived length (`158–193`).
- AFK transport has a 1-second command timeout and rejects firmware retcode/header mismatches (`afk.c:951–965,1013–1034`).
- EDID-copy failure is logged but the firmware modes are still returned.

**Therefore absence of EDID is not sufficient evidence of an EDID transport failure. The copy may never have been attempted.**

Additional exact-tree issue: `dpavservep.c:173` passes `sizeof(resp) + EDID_BUF_SIZE`, where `resp` is a pointer, rather than `sizeof(*resp) + EDID_BUF_SIZE`. This is a response-buffer-length discrepancy worth logging, but not an explanation for **zero timing callbacks**.

---

## 6. Timing filtering: received does not mean usable

### Parser-level filtering

`parser.c:332–428,444–611`:

- Timing entries with parsing errors are skipped individually.
- Virtual timing modes are rejected.
- Timing modes without a selected valid color-mode ID are rejected.
- Color entries default to virtual and are skipped if virtual, negative score, or negative ID.
- Accepted color candidates require:
  - depth **8–12**;
  - colorimetry, dynamic range, EOTF and pixel encoding within their enum ranges.
- Selection preference is:
  1. SDR RGB ≤10 bpc;
  2. SDR YCbCr444 ≤10 bpc;
  3. other SDR;
  4. best remaining valid color mode.

**There is no blanket “RGB only,” “SDR only,” or 60-Hz limit in this parser.** The ≤10-bpc limit is a preference-bucket condition, not a universal rejection of 12-bpc modes.

`enumerate_modes()` can successfully return an allocation with **count zero** if all entries are skipped.

**Trace trap:** `iomfb_parse_mode_success` occurs at `parser.c:500–501`, **before** the no-color and virtual-mode rejection checks (`506–515`). It is not proof of an accepted mode. The final `iomfb_timing_mode` at `562–564` is the better acceptance milestone.

Parser robustness caveats relevant to malformed dictionaries:

- Several temporary structures/fields are not initialized, and required-field presence is not comprehensively tracked.
- Nested iterator macros discard `iterator_begin()` errors.
- An early per-entry parse failure does not explicitly resynchronize to the next timing dictionary.

References: `parser.c:245–267,370–407,448–489,584–597`. These are assumptions/risks to investigate with raw dictionaries, not evidence that malformed data occurred.

### DRM-level filtering

`iomfb.c:384–408,448–458`: modes must match the driver’s firmware list by **timings and clock**. Arbitrary synthesized/override modes are not accepted unless they match that list.

`drm_probe_helper.c:445–495,649–689` additionally applies generic validation and prunes rejected modes.

Hence generic no-EDID fallback modes, command-line modes and the DP 640×480 fallback **cannot rescue an empty firmware list**: Apple’s `mode_valid()` rejects every unmatched mode.

---

## 7. Other ordering gates worth checking

- **Readiness budget:** all DCP readiness waits share a 3-second deadline; failures are only warned about (`apple_drv.c:424–438`). HDMI IRQ enablement is tied to reaching active readiness (`dcp.c:609–631`).
- **No mandatory initialization reconnect cycle:** the disconnect/connect workaround is under `DCP_DPTX_DISCONNECT_ON_INIT`; the comment says it is avoided because of possible startup issues (`dcp.c:532–554`).
- **Routing/configuration:** PHY acquisition, converter power, crossbar selection, DCP index, PHY target and die all matter. Several routing failures only warn/log (`dcp.c:989–997,1185–1189,1260–1290`).
- **Disconnect/reconnect state can be asymmetric:** GPIO falling edges rely on firmware; transport-connected is cleared by release-display paths, not directly by `D576`. A stale transport-connected flag can suppress the next physical reconnect attempt.
- **Suspend/resume:** suspend clears the HDMI-associated connection and transport state; platform resume merely reenables IRQ, without a level resample there (`dcp.c:1307–1339`). `dcp_poweron()` does resample (`649–659`), so this is a dependency on subsequent poweron/resume ordering, not an unconditional failure.
- **Crash:** RTKit crash explicitly forces disconnected, clears cached EDID and schedules hotplug (`dcp.c:251–264`).

---

## 8. Strategic logging spots

For every log, include **device name, connector name/ID, port, and timestamp**. Otherwise the internal and secondary paths are easily conflated.

| Location | Log these values / purpose |
|---|---|
| `apple_drv.c:87–101`; `drm_connector.c:3527–3532` | OOB source fwnode, matched connector/DCP, requested status; distinguish event never delivered from rejected connect. |
| `dcp.c:360–404` | PHY presence, enabled/connected transport flags, target core/PHY/die; **capture all discarded connect/request/HPD return values**; classify wait zero as timeout; state before and after wait. |
| `dptxep.c:248–337,375–490` | Actual PHY lanes, fallback-to-four use, active lanes, rate, routing/configure return codes, completion issuance. |
| `iomfb.c:262–291` | Callback device, tag, context, in/out lengths; detect unknown callback/ABI mismatch. |
| `iomfb_template.c:510–605` | Transfer length, chunk offset/length, end key, parse result, old/new `nr_modes`; distinguish absent, malformed and fully filtered timings. |
| `parser.c:332–428,486–515,591–600` | Explicit color/timing rejection reason; input entry count and accepted count. Do not rely on “parse success.” |
| `iomfb_template.c:1009–1045,1420–1435` | Incoming HPD; `main_display`, `during_modeset`; old/new connector flag, `nr_modes`; startup overwrite and ignored callbacks. |
| `iomfb.c:234–260`; `apple_drv.c:78–85` | Workqueue execution versus callback receipt; actual detect return and current firmware mode count. |
| `iomfb.c:346–408` | Whether `get_modes` was reached, duplicate failures, AV-enabled/cache gates, mode-match rejection. |
| `dpavservep.c:17–46,158–193,227–232` | Service arrival/teardown, actual enable-wait result, copy attempted?, AFK error, returned size/extension count. |

Existing useful instrumentation:

- `dcp:iomfb_callback`, `dcp:iomfb_push`: device-attributed callbacks and method sends (`trace.h:208–248`).
- DPTX initialization/connect/AP-call/link-rate tracepoints (`trace.h:366–435`).
- Raw connector debugfs dictionaries: `TimingElements`, `ColorElements`, `DisplayAttributes`, `Transport` (`connector.c:101–112`).
- Firmware verbose logging parameter: `systemep.c:10–16,44–63,118–134`.

One tracing caveat in this exact tree: `dcpep_process_chunks()` sets `ctx.dcp` **before** calling `parse()`, but `parse()` overwrites the entire context without preserving that field (`iomfb_template.c:557–560`; `parser.c:269–277`). Consequently color/timing tracepoints using `handle->dcp` can lose instance attribution. The parse-success/fail events also lack a device field (`trace.h:323–352`). Prefer device-attributed callback/end-of-transfer logs when correlating multiple DCPs.

**Highest-value diagnostic sequence:** on the secondary instance, establish **OOB/GPIO delivery → accepted DPTX request and return codes → `D128`/`D124` with `TimingElements` → accepted mode count → accepted `D576` or startup connected assignment → `dcp_hotplug` → detect → get_modes → optional AV EDID copy**. Stop at the first missing milestone; do not use the internal HPD log or secondary `A029` alone to skip ahead.

---

## Absolute reference index

### Apple DRM

- **`dcp.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c`
- **`apple_drv.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/apple_drv.c`
- **`dptxep.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c`
- **`iomfb.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb.c`
- **`iomfb_template.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c`
- **`iomfb_v13_3.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_v13_3.c`
- **`iomfb_v12_3.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_v12_3.c`
- **`parser.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/parser.c`
- **`connector.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/connector.c`
- **`dpavservep.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/epic/dpavservep.c`
- **`afk.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/afk.c`
- **`dcp-internal.h`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp-internal.h`
- **`trace.h`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/trace.h`
- **`systemep.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/systemep.c`

### Directly relevant callers/helpers and address mapping

- **`drm_connector.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/drm_connector.c`
- **`drm_probe_helper.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/drm_probe_helper.c`
- **`tipd/core.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c`
- **`altmodes/displayport.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/altmodes/displayport.c`
- **`rtkit.c`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/soc/apple/rtkit.c`
- **`t8103.dtsi`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8103.dtsi`
- **`t8112.dtsi`** — `/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8112.dtsi`
</task_result>
```

**Tool: task**

**Input:**
```json
{
  "description": "Trace Type-C AUX routing",
  "prompt": "Research only, no edits. In pinned kernel /nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source trace USB-C DP altmode / mux / crossbar / ATC PHY interactions with drivers/gpu/drm/apple/dptxep.c. Identify HPD routing, activation prerequisites, AUX which side owns it, meaning of Failed to get dp-xbar -517 and fwnode_typec_mux_get 0, errors ignored or state flags early leading failed retried connect. M2 Air t8112 phy1. Return concrete file line refs and best 3-5 minimal logging spots including errors that currently disappear. Don't assume calls 22 24 cause defect. Thoroughness medium.",
  "subagent_type": "explore",
  "task_id": "",
  "command": ""
}
```

**Output:**
```
task_id: ses_f6011a4ffffebby4ZFEEdxLRNl (for resuming to continue this task if needed)

<task_result>
## Summary

**The strongest source-level suspects are swallowed errors and cached “connected/configured” state—not calls 22/24 themselves.** Two independent paths can suppress a meaningful retry:

1. CD321x caches the requested Type-C mode **before** calling the ATC mux, ignores failure, then skips subsequent identical requests.
2. DCP ignores connect/request-display failures, sets `connected = true`, and does not recognize its link-configuration timeout.

Research only; no files changed. Findings below are from the pinned source, not a runtime trace.

## 1. M2 Air / t8112 phy1 wiring

The J413 DTS enables `ENABLE_DCPEXT_TYPEC` and identifies Type-C port 1 as **USB-C Left-front**:
[t8112-j413.dts:12–15,87–93](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8112-j413.dts#L12).

The shared board DTS wires:

- CD321x `usb-pd@3f` → `typec1`.
- `typec1.displayport` → `dcpext`, for out-of-band HPD.
- Type-C SuperSpeed graph → `atcphy1`, for orientation/mode switching.
- `dcpext`: `apple,dptx-phy = 1`, `dp-phy = atcphy1`, crossbar controller **0**, selected state **2**.

References: [t8112-jxxx.dtsi:88–118,148–159,240–255](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8112-jxxx.dtsi#L88).

`atcphy1` is `phy@503000000`; its separate display crossbar is `mux@50304c000`. The PHY advertises both `orientation-switch` and `mode-switch`:
[t8112.dtsi:1906–1928](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8112.dtsi#L1906).

**Do not conflate the two muxes:**

- **Display crossbar:** statically selects the DCP display stream during DCP probe. Controller 0 is `dpphy`; state 2 is printed as **`dispext1,0`**. It programs clocks/routing and includes the 10 µs RD_PCLK toggle workaround.
  [apple-display-crossbar.c:86–87,254–262,317–351](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/mux/apple-display-crossbar.c#L254)
- **ATC Type-C mux:** dynamically selects USB/DP lane allocation and enables AUX according to CD321x’s negotiated mode.

## 2. HPD route and activation order

The actual route here is:

```text
CD321x data-status HPD level
  → cd321x_update_work()
  → drm_connector_oob_hotplug_event(dcpext fwnode, status)
  → apple_connector_oob_hotplug()
  → dcp_dptx_connect_oob(..., port 0)
  → dptxport_connect + request_display
  → wait for SET_ACTIVE_LANE_COUNT
  → dptxport_set_hpd(true)
```

Important details:

- CD321x reads `CD321X_DATA_STATUS_HPD_LEVEL`. It emits **disconnect first** when HPD is low **or changed**, then updates orientation and Type-C mode, then emits connected if HPD is high.
  [tipd/core.c:650–711,742–749](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c#L650)
- Thus a disconnect/connect pair can be intentional processing of a changed HPD level, not proof of a fault. This path does not separately forward DP IRQ-HPD pulses.
- The Apple OOB callback always uses **DPTX service port 0**; that is distinct from **ATC PHY index 1**.
  [apple_drv.c:87–100](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/apple_drv.c#L87)
- OOB delivery silently disappears if the DRM connector has not registered yet:
  [drm_connector.c:3522–3532](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/drm_connector.c#L3522).

### What must already work

1. Crossbar provider available and correct stream selected.
2. Orientation applied; ATC switched to negotiated DP mode:
   - C/E → four-lane DP.
   - D → two-lane DP + USB3.
   - ATC powers up, applies tunables, enables AUX, configures lanes.
   [atc.c:2222–2239,2294–2329](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/phy/apple/atc.c#L2222),
   [atc.c:1866–1959](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/phy/apple/atc.c#L1866)
3. DCP has its PHY and an enabled DPTX service:
   [dcp.c:360–384](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c#L360).
4. Firmware link-rate requests reach `phy_configure()`, which configures the ATC PLL/lanes:
   [dptxep.c:375–443](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c#L375),
   [atc.c:1652–1747](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/phy/apple/atc.c#L1652).

**`ACTIVATE` itself does not perform ATC bring-up.** ATC explicitly says setup happened in `mux_set`; its PHY `set_mode` accepts only `(PHY_MODE_DP, submode 0)`:
[atc.c:2038–2043](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/phy/apple/atc.c#L2038).

There is a concrete mismatch worth logging: with DCP’s Type-C mux NULL, `ACTIVATE` calls `phy_set_mode_ext(..., PHY_MODE_DP, dcp->index)`. DCPEXT’s index is **1**, so this ATC operation returns **`-EINVAL`**, which is ignored and ACKed as success. `DEACTIVATE` similarly passes `PHY_MODE_INVALID`, also rejected/ignored. This does **not** establish causality: ATC activation is supposed to have happened separately through CD321x.
[dptxep.c:473–507](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c#L473),
[t8112.dtsi:1757](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/arch/arm64/boot/dts/apple/t8112.dtsi#L1757).

## 3. AUX ownership

Separate **physical AUX enablement** from **AUX transactions**:

- Linux ATC owns physical AUX power/clamp/clock/setup through `atcphy_enable_dp_aux()`, invoked during DP mux configuration; power-off disables it.
  [atc.c:1343–1414,1932–1934](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/phy/apple/atc.c#L1343)
- The Apple DRM driver does not implement a host `drm_dp_aux` transaction engine here. `dptxep.c` handles firmware requests for PHY capabilities/configuration, not AUX reads/writes. EDID retrieval goes through a firmware service call:
  [dpavservep.c:167–192](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/epic/dpavservep.c#L167).

**Therefore the firmware/DPTX side owns sink-facing AUX transactions; Linux must first make the physical AUX path usable.** The pinned host source does not expose firmware’s internal AUX failure reason.

Also, `GET_SUPPORTS_HPD` returns zero, but explicit host→firmware `set_hpd()` still exists. This is not evidence HPD is unused:
[dptxep.c:140–156,446–456](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c#L140).

## 4. Meaning of the two probe messages

### `Failed to get dp-xbar: -517`

**`-EPROBE_DEFER`: the DT-referenced mux chip has not registered yet.** The mux core returns this after successfully resolving the phandle but failing to find its provider; DCP returns the error to defer probe.
[mux/core.c:571–587](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/mux/core.c#L571),
[dcp.c:1260–1269](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c#L1260).

A transient occurrence is dependency ordering, **not an AUX/link-training failure**. Persistent deferral means investigate the crossbar provider. A subsequent successful crossbar selection is stronger evidence than this earlier message.

### `fwnode_typec_mux_get() returned: 0`

At this print site, **0 means NULL/no matching connection**, not “a mux was acquired successfully.”
[dcp.c:1275–1289](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c#L1275),
[typec/mux.c:297–325](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/mux.c#L297).

That fits this DTS: DCP has the crossbar/PHY references, while **the Type-C connector graph** leads to ATC’s mode-switch. CD321x acquires its own mux using that connector fwnode:
[tipd/core.c:1199–1208](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c#L1199).

## 5. Errors/state that can defeat retries

| Location | Concrete behavior |
|---|---|
| [tipd/core.c:585–595](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c#L585) | Caches DP alt/mode **before** `typec_mux_set`; ignores return. Same alt/mode next time returns immediately. HPD-high delivery proceeds despite failed PHY setup. |
| [dcp.c:377–404](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c#L377) | Ignores `connect` and `request_display` returns, sets `connected=true` before completion. Later connected events skip the handshake. |
| Same location | Two-second `wait_for_completion_timeout()` returns **0 on timeout**, but code checks **`ret < 0`**. Timeout proceeds to HPD-high and returns success. |
| [dptxep.c:260–277,299–334](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c#L260) | PHY reporting zero available lanes is converted into a successful **four-lane fallback**. Positive SET_ACTIVE_LANE_COUNT completes the wait; on phy1 it does not program lane count. Thus completion is not proof of successful sink communication/training. |
| [afk.c:480–491](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/afk.c#L480) | Any DPTX callback error is silently discarded **without sending its ACK**. Includes `phy_configure()` failure returned by SET_LINK_RATE. ACK-send return is also ignored. |
| [afk.c:1013–1025](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/afk.c#L1013) | Firmware command retcode is collapsed to `-EINVAL` without logging the original value or distinguishing malformed response headers. |

Disconnect also ignores HPD-low/release-display failures while clearing the software connection flag:
[dcp.c:419–451](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c#L419).

Calls **22 = DEVICE_NOT_RESPONDING**, **24 = DEVICE_NOT_STARTED** are named notifications and currently take the generic ACK path. Treat them as **symptoms/timeline markers**, not established initiating defects:
[dptxep.h:30–32](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.h#L30),
[dptxep.c:556–566](/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dptxep.c#L556).

## Best five minimal logging spots

1. **CD321x DP mode update — `tipd/core.c:585–595`.**  
   Log requested/cached mode, pin assignment, DP status/configuration, HPD level/change, mux presence, **mux return**, and identical-state skip. Highest-value check for a failed setup that subsequently cannot retry.

2. **ATC mux boundary — `atc.c:2263–2329`.**  
   Log old/target mode, `swap_lanes`, `pipehandler_up`, same-mode skip, configure return and resulting mode. Distinguishes negotiation success from actual PHY/AUX setup.

3. **DCP connect/disconnect — `dcp.c:377–425`.**  
   Log `enabled/connected`, target core/ATC/die, **each connect/request/release/HPD return**, and wait result with **zero explicitly labeled timeout**. Include the connected-state early exit.

4. **DPTX PHY callbacks — `dptxep.c:260–277,424–431,473–507`.**  
   Small targeted logs: actual validated lanes versus fallback; link-rate/options plus configure return; ACTIVATE/DEACTIVATE mode, index and **ignored `phy_set_mode_ext` return**.

5. **AFK error exits — `afk.c:480–491,1013–1025`.**  
   Log endpoint/channel/AP-call index and callback errno **before the no-ACK return**; capture ACK-send failure. For outgoing calls, log group/command, transport errno, original firmware retcode, and response-header mismatch.

These five boundaries should identify the first failed operation and whether a later “connect” was a real retry or merely a cached-state early return, without starting with broad register dumps or blaming 22/24.
</task_result>
```

---

## Assistant (Build · GPT-6 Astra · 8.2s)

_Thinking:_



The source gives calls 20/22/24 names, but the larger finding is that “DPTX connected” and “DRM connected” are separate states, with several errors silently discarded between them. Also, empty sysfs EDID does not prove an AUX read failed here: Linux normally copies EDID only after firmware modes are available and DRM considers the connector connected.

At this commit, the M2 Air is wired for the front USB-C port, farther from MagSafe. I’ll prepare an optional logging patch that exposes the swallowed errors and firmware hotplug/timing transitions without changing connection behavior.

**Tool: todowrite**

**Input:**
```json
{
  "todos": [
    {
      "content": "Inspect pinned fairydust source and local kernel configuration",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Research support limitations and relevant upstream discussions",
      "status": "completed",
      "priority": "high"
    },
    {
      "content": "Trace failure paths and prepare targeted diagnostics or instrumentation",
      "status": "in_progress",
      "priority": "high"
    },
    {
      "content": "Summarize confirmed facts, hypotheses, and test sequence",
      "status": "pending",
      "priority": "high"
    }
  ]
}
```

**Output:**
```
[
  {
    "content": "Inspect pinned fairydust source and local kernel configuration",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Research support limitations and relevant upstream discussions",
    "status": "completed",
    "priority": "high"
  },
  {
    "content": "Trace failure paths and prepare targeted diagnostics or instrumentation",
    "status": "in_progress",
    "priority": "high"
  },
  {
    "content": "Summarize confirmed facts, hypotheses, and test sequence",
    "status": "pending",
    "priority": "high"
  }
]
```

---

## Assistant (Build · GPT-6 Astra · 8.9s)

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c",
  "offset": 350,
  "limit": 105
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp.c</path>
<type>file</type>
<content>
350: 
351: int dcp_get_connector_type(struct platform_device *pdev)
352: {
353: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
354: 
355: 	return (dcp->connector_type);
356: }
357: 
358: #define DPTX_CONNECT_TIMEOUT msecs_to_jiffies(2000)
359: 
360: static int dcp_dptx_connect(struct apple_dcp *dcp, u32 port)
361: {
362: 	int ret = 0;
363: 
364: 	if (!dcp->phy) {
365: 		dev_warn(dcp->dev, "dcp_dptx_connect: missing phy\n");
366: 		return -ENODEV;
367: 	}
368: 	dev_info(dcp->dev, "%s(port=%d)\n", __func__, port);
369: 
370: 	mutex_lock(&dcp->hpd_mutex);
371: 	if (!dcp->dptxport[port].enabled) {
372: 		dev_warn(dcp->dev, "dcp_dptx_connect: dptx service for port %d not enabled\n", port);
373: 		ret = -ENODEV;
374: 		goto out_unlock;
375: 	}
376: 
377: 	if (dcp->dptxport[port].connected)
378: 		goto out_unlock;
379: 
380: 	reinit_completion(&dcp->dptxport[port].linkcfg_completion);
381: 	dcp->dptxport[port].atcphy = dcp->phy;
382: 	dptxport_connect(dcp->dptxport[port].service, 0, dcp->dptx_phy, dcp->dptx_die);
383: 	dptxport_request_display(dcp->dptxport[port].service);
384: 	dcp->dptxport[port].connected = true;
385: 
386: 	mutex_unlock(&dcp->hpd_mutex);
387: 	ret = wait_for_completion_timeout(&dcp->dptxport[port].linkcfg_completion,
388: 				    DPTX_CONNECT_TIMEOUT);
389: 	if (ret < 0)
390: 		dev_warn(dcp->dev, "dcp_dptx_connect: port %d link complete failed:%d\n",
391: 			 port, ret);
392: 	else
393: 		dev_dbg(dcp->dev, "dcp_dptx_connect: waited %d ms for link\n",
394: 			jiffies_to_msecs(DPTX_CONNECT_TIMEOUT - ret));
395: 
396: 	usleep_range(5, 10);
397: 
398: 	if (dcp->connector_type == DRM_MODE_CONNECTOR_DisplayPort)
399: 		dptxport_set_hpd(dcp->dptxport[port].service, true);
400: 
401: 	if (dcp->avep)
402: 		av_service_connect(dcp);
403: 
404: 	return 0;
405: 
406: out_unlock:
407: 	mutex_unlock(&dcp->hpd_mutex);
408: 	return ret;
409: }
410: 
411: static void disconnected_hpd_event(struct apple_connector *con)
412: {
413: 	if (con && con->connected) {
414: 		con->connected = 0;
415: 		drm_kms_helper_connector_hotplug_event(&con->base);
416: 	}
417: }
418: 
419: static int dcp_dptx_disconnect(struct apple_dcp *dcp, u32 port)
420: {
421: 	dev_info(dcp->dev, "%s(port=%d)\n", __func__, port);
422: 
423: 	mutex_lock(&dcp->hpd_mutex);
424: 	if (dcp->dptxport[port].enabled && dcp->dptxport[port].connected) {
425: 		dptxport_release_display(dcp->dptxport[port].service);
426: 		dcp->dptxport[port].connected = false;
427: 	}
428: 	mutex_unlock(&dcp->hpd_mutex);
429: 
430: 	return 0;
431: }
432: 
433: int dcp_dptx_connect_oob(struct platform_device *pdev, u32 port)
434: {
435: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
436: 	return dcp_dptx_connect(dcp, port);
437: }
438: 
439: int dcp_dptx_disconnect_oob(struct platform_device *pdev, u32 port)
440: {
441: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
442: 
443: 	disconnected_hpd_event(dcp->connector);
444: 
445: 	if (dcp->avep)
446: 		av_service_disconnect(dcp);
447: 
448: 	if (dcp->dptxport[port].enabled)
449: 		dptxport_set_hpd(dcp->dptxport[port].service, false);
450: 
451: 	return dcp_dptx_disconnect(dcp, port);
452: }
453: 
454: static irqreturn_t dcp_dp2hdmi_hpd(int irq, void *data)

(Showing lines 350-454 of 1390. Use offset=455 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/afk.c",
  "offset": 420,
  "limit": 80
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/afk.c</path>
<type>file</type>
<content>
420: 	}
421: 	if (service->cmds[idx].completion)
422: 		complete(service->cmds[idx].completion);
423: 
424: 	spin_unlock_irqrestore(&service->lock, flags);
425: 
426: 	if (rxbuf && rxlen)
427: 		dma_free_coherent(ep->dcp->dev, rxlen, rxbuf, rxbuf_dma);
428: 	if (txbuf && txlen)
429: 		dma_free_coherent(ep->dcp->dev, txlen, txbuf, txbuf_dma);
430: }
431: 
432: struct epic_std_service_ap_call {
433: 	__le32 unk0;
434: 	__le32 unk1;
435: 	__le32 type;
436: 	__le32 len;
437: 	__le32 magic;
438: 	u8 _unk[48];
439: } __attribute__((packed));
440: 
441: static void afk_recv_handle_std_service(struct apple_dcp_afkep *ep, u32 channel,
442: 					u32 type, struct epic_hdr *ehdr,
443: 					struct epic_sub_hdr *eshdr,
444: 					void *payload, size_t payload_size)
445: {
446: 	struct apple_epic_service *service = afk_epic_find_service(ep, channel);
447: 
448: 	if (!service) {
449: 		dev_warn(ep->dcp->dev,
450: 			 "AFK[ep:%02x]: std service notify on disabled channel %u\n",
451: 			 ep->endpoint, channel);
452: 		return;
453: 	}
454: 	if (service->torndown) {
455: 		dev_warn(ep->dcp->dev,
456: 			 "AFK[ep:%02x]: std service notify on torn down service "
457: 			 "(chan:%u)\n", ep->endpoint, channel);
458: 		return;
459: 	}
460: 
461: 	if (type == EPIC_TYPE_NOTIFY && eshdr->category == EPIC_CAT_NOTIFY) {
462: 		struct epic_std_service_ap_call *call = payload;
463: 		size_t call_size;
464: 		void *reply;
465: 		int ret;
466: 
467: 		if (payload_size < sizeof(*call))
468: 			return;
469: 
470: 		call_size = le32_to_cpu(call->len);
471: 		if (payload_size < sizeof(*call) + call_size)
472: 			return;
473: 
474: 		if (!service->ops->call)
475: 			return;
476: 		reply = kzalloc(payload_size, GFP_KERNEL);
477: 		if (!reply)
478: 			return;
479: 
480: 		ret = service->ops->call(service, le32_to_cpu(call->type),
481: 					 payload + sizeof(*call), call_size,
482: 					 reply + sizeof(*call), call_size);
483: 		if (ret) {
484: 			kfree(reply);
485: 			return;
486: 		}
487: 
488: 		memcpy(reply, call, sizeof(*call));
489: 		afk_send_epic(ep, channel, le16_to_cpu(eshdr->tag),
490: 			      EPIC_TYPE_NOTIFY_ACK, EPIC_CAT_REPLY,
491: 			      EPIC_SUBTYPE_STD_SERVICE, reply, payload_size);
492: 		kfree(reply);
493: 
494: 		return;
495: 	}
496: 
497: 	if (type == EPIC_TYPE_NOTIFY && eshdr->category == EPIC_CAT_REPORT) {
498: 		if (service->ops->report)
499: 			service->ops->report(service, le16_to_cpu(eshdr->type),

(Showing lines 420-499 of 1181. Use offset=500 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c",
  "offset": 560,
  "limit": 195
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/usb/typec/tipd/core.c</path>
<type>file</type>
<content>
560: 
561: 		switch (TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT(st->data_status)) {
562: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_A:
563: 			mode = TYPEC_DP_STATE_A;
564: 			break;
565: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_B:
566: 			mode = TYPEC_DP_STATE_B;
567: 			break;
568: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_C:
569: 			mode = TYPEC_DP_STATE_C;
570: 			break;
571: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_D:
572: 			mode = TYPEC_DP_STATE_D;
573: 			break;
574: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_E:
575: 			mode = TYPEC_DP_STATE_E;
576: 			break;
577: 		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_F:
578: 			mode = TYPEC_DP_STATE_F;
579: 			break;
580: 		default:
581: 			dev_err(tps->dev, "Invalid DP pin assignment\n");
582: 			return;
583: 		}
584: 
585: 		if (cd321x->state.alt == cd321x->port_altmode_dp &&
586: 		   cd321x->state.mode == mode) {
587: 			return;
588: 		}
589: 
590: 		dp_data.status = le32_to_cpu(st->dp_sid_status.status_rx);
591: 		dp_data.conf = le32_to_cpu(st->dp_sid_status.configure);
592: 		cd321x->state.alt = cd321x->port_altmode_dp;
593: 		cd321x->state.data = &dp_data;
594: 		cd321x->state.mode = mode;
595: 		typec_mux_set(cd321x->mux, &cd321x->state);
596: 	} else if (st->data_status & TPS_DATA_STATUS_TBT_CONNECTION) {
597: 		struct typec_thunderbolt_data tbt_data;
598: 
599: 		if (cd321x->state.alt == cd321x->port_altmode_tbt &&
600: 		   cd321x->state.mode == TYPEC_TBT_MODE)
601: 			return;
602: 
603: 		tbt_data.cable_mode = le16_to_cpu(st->intel_vid_status.cable_mode);
604: 		tbt_data.device_mode = le16_to_cpu(st->intel_vid_status.device_mode);
605: 		tbt_data.enter_vdo = le16_to_cpu(st->intel_vid_status.enter_vdo);
606: 		cd321x->state.alt = cd321x->port_altmode_tbt;
607: 		cd321x->state.mode = TYPEC_TBT_MODE;
608: 		cd321x->state.data = &tbt_data;
609: 		typec_mux_set(cd321x->mux, &cd321x->state);
610: 	} else if (st->data_status & CD321X_DATA_STATUS_USB4_CONNECTION) {
611: 		struct enter_usb_data eusb_data;
612: 
613: 		if (cd321x->state.alt == NULL && cd321x->state.mode == TYPEC_MODE_USB4)
614: 			return;
615: 
616: 		eusb_data.eudo = le32_to_cpu(st->usb4_status.eudo);
617: 		eusb_data.active_link_training =
618: 			!!(st->data_status & TPS_DATA_STATUS_ACTIVE_LINK_TRAIN);
619: 
620: 		cd321x->state.alt = NULL;
621: 		cd321x->state.data = &eusb_data;
622: 		cd321x->state.mode = TYPEC_MODE_USB4;
623: 		typec_mux_set(cd321x->mux, &cd321x->state);
624: 	} else {
625: 		if (cd321x->state.alt == NULL && cd321x->state.mode == TYPEC_STATE_USB)
626: 			return;
627: 		cd321x->state.alt = NULL;
628: 		cd321x->state.mode = TYPEC_STATE_USB;
629: 		cd321x->state.data = NULL;
630: 		typec_mux_set(cd321x->mux, &cd321x->state);
631: 	}
632: 
633: 	/* Clear data since it's no longer used after typec_mux_set and points to the stack */
634: 	cd321x->state.data = NULL;
635: }
636: 
637: static void cd321x_update_work(struct work_struct *work)
638: {
639: 	struct cd321x *cd321x = container_of(to_delayed_work(work),
640: 					    struct cd321x, update_work);
641: 	struct tps6598x *tps = &cd321x->tps;
642: 	struct cd321x_status st;
643: 
644: 	guard(mutex)(&tps->lock);
645: 
646: 	st = cd321x->update_status;
647: 	cd321x->update_status.status_changed = 0;
648: 	cd321x->update_status.data_status_changed = 0;
649: 
650: 	bool old_connected = !!tps->partner;
651: 	bool new_connected = st.status & TPS_STATUS_PLUG_PRESENT;
652: 	bool was_disconnected = st.status_changed & TPS_STATUS_PLUG_PRESENT;
653: 
654: 	bool usb_connection = st.data_status &
655: 			      (TPS_DATA_STATUS_USB2_CONNECTION | TPS_DATA_STATUS_USB3_CONNECTION);
656: 
657: 	bool dp_hpd = st.data_status & CD321X_DATA_STATUS_HPD_LEVEL;
658: 	bool dp_hpd_changed = st.data_status_changed & CD321X_DATA_STATUS_HPD_LEVEL;
659: 
660: 	enum usb_role old_role = usb_role_switch_get_role(tps->role_sw);
661: 	enum usb_role new_role = USB_ROLE_NONE;
662: 	enum typec_pwr_opmode pwr_opmode = TYPEC_PWR_MODE_USB;
663: 	enum typec_orientation orientation = TYPEC_ORIENTATION_NONE;
664: 
665: 	if (usb_connection) {
666: 		if (tps->data_status & TPS_DATA_STATUS_USB_DATA_ROLE)
667: 			new_role = USB_ROLE_DEVICE;
668: 		else
669: 			new_role = USB_ROLE_HOST;
670: 	}
671: 
672: 	if (new_connected) {
673: 		pwr_opmode = TPS_POWER_STATUS_PWROPMODE(st.pwr_status);
674: 		orientation = TPS_STATUS_TO_UPSIDE_DOWN(st.status) ?
675: 			TYPEC_ORIENTATION_REVERSE : TYPEC_ORIENTATION_NORMAL;
676: 	}
677: 
678: 	bool is_pd = pwr_opmode == TYPEC_PWR_MODE_PD;
679: 	bool partner_changed = old_connected && new_connected &&
680: 		(was_disconnected ||
681: 		 (is_pd && memcmp(&st.partner_identity,
682: 				  &cd321x->cur_partner_identity, sizeof(struct usb_pd_identity))));
683: 
684: 	/* If we are switching from an active role, transition to USB_ROLE_NONE first */
685: 	if (old_role != USB_ROLE_NONE && (new_role != old_role || was_disconnected))
686: 		usb_role_switch_set_role(tps->role_sw, USB_ROLE_NONE);
687: 
688: 	if (cd321x->connector_fwnode && (!dp_hpd || dp_hpd_changed)) {
689: 		drm_connector_oob_hotplug_event(cd321x->connector_fwnode, connector_status_disconnected);
690: 	}
691: 
692: 	/* Process partner disconnection or change */
693: 	if (!new_connected || partner_changed) {
694: 		if (!IS_ERR(tps->partner))
695: 			typec_unregister_partner(tps->partner);
696: 		tps->partner = NULL;
697: 	}
698: 
699: 	/* If there was a disconnection, set PHY to off */
700: 	if (!new_connected || was_disconnected) {
701: 		cd321x->state.alt = NULL;
702: 		cd321x->state.mode = TYPEC_STATE_SAFE;
703: 		cd321x->state.data = NULL;
704: 		typec_set_mode(tps->port, TYPEC_STATE_SAFE);
705: 	}
706: 
707: 	/* Update Type-C properties */
708: 	typec_set_pwr_opmode(tps->port, pwr_opmode);
709: 	typec_set_pwr_role(tps->port, TPS_STATUS_TO_TYPEC_PORTROLE(st.status));
710: 	typec_set_vconn_role(tps->port, TPS_STATUS_TO_TYPEC_VCONN(st.status));
711: 	typec_set_orientation(tps->port, orientation);
712: 	typec_set_data_role(tps->port, TPS_STATUS_TO_TYPEC_DATAROLE(st.status));
713: 	power_supply_changed(tps->psy);
714: 
715: 	/* If the plug is disconnected, we are done */
716: 	if (!new_connected)
717: 		return;
718: 
719: 	/* Set up partner if we were previously disconnected (or changed). */
720: 	if (!tps->partner) {
721: 		struct typec_partner_desc desc;
722: 
723: 		desc.usb_pd = is_pd;
724: 		desc.accessory = TYPEC_ACCESSORY_NONE; /* XXX: handle accessories */
725: 		desc.identity = NULL;
726: 
727: 		if (desc.usb_pd)
728: 			desc.identity = &st.partner_identity;
729: 
730: 		tps->partner = typec_register_partner(tps->port, &desc);
731: 		if (IS_ERR(tps->partner)) {
732: 			dev_warn(tps->dev, "%s: failed to register partner\n", __func__);
733: 			return;
734: 		}
735: 
736: 		if (desc.identity) {
737: 			typec_partner_set_identity(tps->partner);
738: 			cd321x->cur_partner_identity = st.partner_identity;
739: 		}
740: 	}
741: 
742: 	/* Update the TypeC MUX/PHY state */
743: 	cd321x_typec_update_mode(tps, &st);
744: 
745: 	/* Launch the USB role switch */
746: 	usb_role_switch_set_role(tps->role_sw, new_role);
747: 
748: 	if (cd321x->connector_fwnode && dp_hpd)
749: 		drm_connector_oob_hotplug_event(cd321x->connector_fwnode, connector_status_connected);
750: 
751: 	power_supply_changed(tps->psy);
752: }
753: 
754: static void cd321x_queue_status(struct cd321x *cd321x)

(Showing lines 560-754 of 1933. Use offset=755 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c",
  "offset": 540,
  "limit": 68
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c</path>
<type>file</type>
<content>
540: 	}
541: 
542: 	memcpy(dcp->chunks.data + req->offset, req->data, req->length);
543: 	return true;
544: }
545: 
546: static bool dcpep_process_chunks(struct apple_dcp *dcp,
547: 				 struct dcp_set_dcpav_prop_end_req *req)
548: {
549: 	struct dcp_parse_ctx ctx;
550: 	int ret;
551: 
552: 	if (!dcp->chunks.data) {
553: 		dev_warn(dcp->dev, "ignoring spurious end\n");
554: 		return false;
555: 	}
556: 
557: 	/* used just as opaque pointer for tracing */
558: 	ctx.dcp = dcp;
559: 
560: 	ret = parse(dcp->chunks.data, dcp->chunks.length, &ctx);
561: 
562: 	if (ret) {
563: 		dev_warn(dcp->dev, "bad header on dcpav props\n");
564: 		return false;
565: 	}
566: 
567: 	if (!strcmp(req->key, "TimingElements")) {
568: 		dcp->modes = enumerate_modes(&ctx, &dcp->nr_modes,
569: 					     dcp->width_mm, dcp->height_mm,
570: 					     dcp->notch_height);
571: 
572: 		if (IS_ERR(dcp->modes)) {
573: 			dev_warn(dcp->dev, "failed to parse modes\n");
574: 			dcp->modes = NULL;
575: 			dcp->nr_modes = 0;
576: 			return false;
577: 		}
578: 		if (dcp->nr_modes == 0)
579: 			dev_warn(dcp->dev, "TimingElements without valid modes!\n");
580: 	} else if (!strcmp(req->key, "DisplayAttributes")) {
581: 		ret = parse_display_attributes(&ctx, &dcp->width_mm,
582: 					&dcp->height_mm);
583: 
584: 		if (ret) {
585: 			dev_warn(dcp->dev, "failed to parse display attribs\n");
586: 			return false;
587: 		}
588: 
589: 		dcp_set_dimensions(dcp);
590: 	}
591: 
592: 	return true;
593: }
594: 
595: static u8 dcpep_cb_prop_end(struct apple_dcp *dcp,
596: 			    struct dcp_set_dcpav_prop_end_req *req)
597: {
598: 	u8 resp = dcpep_process_chunks(dcp, req);
599: 
600: 	/* move chunked data to connector to provide it via debugfs */
601: 	dcp_connector_update_dict(dcp->connector, req->key, &dcp->chunks);
602: 	dcp->chunks.data = NULL;
603: 	dcp->chunks.length = 0;
604: 
605: 	return resp;
606: }
607: 

(Showing lines 540-607 of 1473. Use offset=608 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c",
  "offset": 1000,
  "limit": 50
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c</path>
<type>file</type>
<content>
1000: 					  msecs_to_jiffies(1000));
1001: 
1002: 	if (ret == 0)
1003: 		dev_warn(dcp->dev, "setDCPPower(0) timeout %u ms\n", 1000);
1004: 
1005: 	kref_put(&cookie->refcount, release_wait_cookie);
1006: 	dev_info(dcp->dev, "dcp_sleep() done\n");
1007: }
1008: 
1009: static void dcpep_cb_hotplug(struct apple_dcp *dcp, u64 *connected)
1010: {
1011: 	struct apple_connector *connector = dcp->connector;
1012: 
1013: 	/* DCP issues hotplug_gated callbacks after SetPowerState() calls on
1014: 	 * devices with display (macbooks, imacs). This must not result in
1015: 	 * connector state changes on DRM side. Some applications won't enable
1016: 	 * a CRTC with a connector in disconnected state. Weston after DPMS off
1017: 	 * is one example. dcp_is_main_display() returns true on devices with
1018: 	 * integrated display. Ignore the hotplug_gated() callbacks there.
1019: 	 */
1020: 	if (dcp->main_display)
1021: 		return;
1022: 
1023: 	if (dcp->during_modeset) {
1024: 		dev_info(dcp->dev,
1025: 			 "cb_hotplug() ignored during modeset connected:%llu\n",
1026: 			 *connected);
1027: 		return;
1028: 	}
1029: 
1030: 	dev_info(dcp->dev, "cb_hotplug() connected:%llu, valid_mode:%d\n",
1031: 		 *connected, dcp->valid_mode);
1032: 
1033: 	/* Hotplug invalidates mode. DRM doesn't always handle this. */
1034: 	if (!(*connected)) {
1035: 		dcp->valid_mode = false;
1036: 		/* after unplug swap will not complete until the next
1037: 		 * set_digital_out_mode */
1038: 		schedule_work(&dcp->vblank_wq);
1039: 	}
1040: 
1041: 	if (connector && connector->connected != !!(*connected)) {
1042: 		connector->connected = !!(*connected);
1043: 		dcp->valid_mode = false;
1044: 		schedule_work(&connector->hotplug_wq);
1045: 	}
1046: }
1047: 
1048: static void
1049: dcpep_cb_swap_complete_intent_gated(struct apple_dcp *dcp,

(Showing lines 1000-1049 of 1473. Use offset=1050 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c",
  "offset": 1415,
  "limit": 30
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb_template.c</path>
<type>file</type>
<content>
1415: 		iomfb_set_matrix(dcp, false, &mat, do_swap, NULL);
1416: 	} else
1417: 		do_swap(dcp, NULL, NULL);
1418: }
1419: 
1420: static void res_is_main_display(struct apple_dcp *dcp, void *out, void *cookie)
1421: {
1422: 	struct apple_connector *connector;
1423: 	int result = *(int *)out;
1424: 	dev_info(dcp->dev, "DCP is_main_display: %d\n", result);
1425: 
1426: 	dcp->main_display = result != 0;
1427: 
1428: 	connector = dcp->connector;
1429: 	if (connector) {
1430: 		connector->connected = dcp->nr_modes > 0;
1431: 		schedule_work(&connector->hotplug_wq);
1432: 	}
1433: 
1434: 	dcp->active = true;
1435: 	complete(&dcp->start_done);
1436: }
1437: 
1438: static void init_3(struct apple_dcp *dcp, void *out, void *cookie)
1439: {
1440: 	dcp_is_main_display(dcp, false, res_is_main_display, NULL);
1441: }
1442: 
1443: static void init_2(struct apple_dcp *dcp, void *out, void *cookie)
1444: {

(Showing lines 1415-1444 of 1473. Use offset=1445 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/ivy/nix",
  "offset": 1,
  "limit": 100
}
```

**Output:**
```
<path>/home/ivy/nix</path>
<type>directory</type>
<entries>
.claude/
.git/
.gitattributes
.gitignore
.sops.yaml
flake.lock
flake.nix
home/
hosts/
justfile
metadata.nix
modules/
README.md
result/
secrets/
session-ses_f896_2.md
session-ses_f8ce.md
TODO.md

(18 entries)
</entries>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/systemep.c",
  "offset": 1,
  "limit": 140
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/systemep.c</path>
<type>file</type>
<content>
1: // SPDX-License-Identifier: GPL-2.0-only OR MIT
2: /* Copyright 2022 Sven Peter <sven@svenpeter.dev> */
3: 
4: #include <linux/completion.h>
5: 
6: #include "afk.h"
7: #include "dcp.h"
8: #include "parser.h"
9: 
10: static bool enable_verbose_logging;
11: module_param(enable_verbose_logging, bool, 0644);
12: MODULE_PARM_DESC(enable_verbose_logging, "Enable DCP firmware verbose logging");
13: 
14: /*
15:  * Serialized setProperty("gAFKConfigLogMask", 0xffff) IPC call which
16:  * will set the DCP firmware log level to the most verbose setting
17:  */
18: #define SYSTEM_SET_PROPERTY 0x43
19: static const u8 setprop_gAFKConfigLogMask_ffff[] = {
20: 	0x14, 0x00, 0x00, 0x00, 0x67, 0x41, 0x46, 0x4b, 0x43, 0x6f,
21: 	0x6e, 0x66, 0x69, 0x67, 0x4c, 0x6f, 0x67, 0x4d, 0x61, 0x73,
22: 	0x6b, 0x00, 0x00, 0x00, 0xd3, 0x00, 0x00, 0x00, 0x40, 0x00,
23: 	0x00, 0x84, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
24: };
25: 
26: struct systemep_work {
27: 	struct apple_epic_service *service;
28: 	struct work_struct work;
29: };
30: 
31: static void system_log_work(struct work_struct *work_)
32: {
33: 	struct systemep_work *work =
34: 		container_of(work_, struct systemep_work, work);
35: 
36: 	afk_send_command(work->service, SYSTEM_SET_PROPERTY,
37: 			 setprop_gAFKConfigLogMask_ffff,
38: 			 sizeof(setprop_gAFKConfigLogMask_ffff), NULL,
39: 			 sizeof(setprop_gAFKConfigLogMask_ffff), NULL);
40: 	complete(&work->service->ep->dcp->systemep_done);
41: 	kfree(work);
42: }
43: 
44: static void system_init(struct apple_epic_service *service, const char *name,
45: 			const char *class, s64 unit)
46: {
47: 	struct systemep_work *work;
48: 
49: 	if (!enable_verbose_logging)
50: 		return;
51: 
52: 	/*
53: 	 * We're called from the service message handler thread and can't
54: 	 * dispatch blocking message from there.
55: 	 */
56: 	work = kzalloc(sizeof(*work), GFP_KERNEL);
57: 	if (!work)
58: 		return;
59: 
60: 	work->service = service;
61: 	INIT_WORK(&work->work, system_log_work);
62: 	schedule_work(&work->work);
63: }
64: 
65: static void powerlog_init(struct apple_epic_service *service, const char *name,
66: 			  const char *class, s64 unit)
67: {
68: }
69: 
70: static int powerlog_report(struct apple_epic_service *service, enum epic_subtype type,
71: 			 const void *data, size_t data_size)
72: {
73: 	struct dcp_system_ev_mnits mnits;
74: 	struct dcp_parse_ctx parse_ctx;
75: 	struct apple_dcp *dcp = service->ep->dcp;
76: 	int ret;
77: 
78: 	dev_dbg(dcp->dev, "systemep[ch:%u]: report type:%02x len:%zu\n",
79: 		service->channel, type, data_size);
80: 
81: 	if (type != EPIC_SUBTYPE_STD_SERVICE)
82: 		return 0;
83: 
84: 	ret = parse(data, data_size, &parse_ctx);
85: 	if (ret) {
86: 		dev_warn(service->ep->dcp->dev, "systemep: failed to parse report: %d\n", ret);
87: 		return ret;
88: 	}
89: 
90: 	ret = parse_system_log_mnits(&parse_ctx, &mnits);
91: 	if (ret) {
92: 		/* ignore parse errors in the case dcp sends unknown log events */
93: 		dev_dbg(dcp->dev, "systemep: failed to parse mNits event: %d\n", ret);
94: 		return 0;
95: 	}
96: 
97: 	dev_dbg(dcp->dev, "systemep: mNits event: Nits: %u.%03u, iDAC: %u\n",
98: 		mnits.millinits / 1000, mnits.millinits % 1000, mnits.idac);
99: 
100: 	dcp->brightness.nits = mnits.millinits / 1000;
101: 
102: 	return 0;
103: }
104: 
105: static const struct apple_epic_service_ops systemep_ops[] = {
106: 	{
107: 		.name = "system",
108: 		.init = system_init,
109: 	},
110: 	{
111: 		.name = "powerlog-service",
112: 		.init = powerlog_init,
113: 		.report = powerlog_report,
114: 	},
115: 	{}
116: };
117: 
118: int systemep_init(struct apple_dcp *dcp)
119: {
120: 	init_completion(&dcp->systemep_done);
121: 
122: 	dcp->systemep = afk_init(dcp, SYSTEM_ENDPOINT, systemep_ops);
123: 	afk_start(dcp->systemep);
124: 
125: 	if (!enable_verbose_logging)
126: 		return 0;
127: 
128: 	/*
129: 	 * Timeouts aren't really fatal here: in the worst case we just weren't
130: 	 * able to enable additional debug prints inside DCP
131: 	 */
132: 	if (!wait_for_completion_timeout(&dcp->systemep_done,
133: 					 msecs_to_jiffies(MSEC_PER_SEC)))
134: 		dev_err(dcp->dev, "systemep: couldn't enable verbose logs\n");
135: 
136: 	return 0;
137: }

(End of file - total 137 lines)
</content>
```

---

## Assistant (Build · GPT-6 Astra · 201.0s)

_Thinking:_



**Tool: task**

**Input:**
```json
{
  "description": "Create targeted diagnostic patch",
  "prompt": "Implement optional instrumentation artifact, not active config. Use apply_patch to create /home/ivy/nix/modules/hardware/patches/fairydust-dptx-diagnostics.patch targeting exact source /nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source. Preserve all existing user changes and do not edit apple-silicon.nix. Goal compact (~200-300 lines max) logging-only patch with FDDBG prefix, device attribution, no semantic error recovery or protocol changes. Read exact sources. Instrument: dcp.c dcp_dptx_connect capture ignored dptxport_connect/request_display/set_hpd returns in separate variable (preserve return/state), log already-connected early exit, wait zero explicit timeout vs positive lane callback; optionally release/HPD-low too. tipd/core.c CD321x DP branch capture mux return incl missing mux, cached-same mode skip; update_work HPD/presence/orientation timeline. afk.c service callback error before no-ACK return (ep/channel/call/ret), ACK-send error optional. iomfb_template.c log property-end bounded key, result, nr_modes and connected; incoming hotplug before all gates; startup connected assignment old/new/nr_modes. iomfb.c get_modes gating EDID nr_modes av enabled cache. dptxep.c default apcall include port, size, lanes rate without payload dump; get_max_lane_count log actual phy lanes and reported fallback and error (do not read uninitialized phy_ops on failure), link-rate phy_configure ret. Prioritize small correct patch. No unrelated fixes, no broad trace changes, no active enabling. Validate ordinary git apply --check on pristine store source directory and run scripts/checkpatch.pl --no-tree --file on artifact if possible; no full kernel rebuild. You can use git apply --numstat or --check --unsafe-paths needed? file application must remain optional. Ensure unified hunk counts valid. Return exact coverage, checks and limits. Create only patch file, I will create investigation report and integration instructions.",
  "subagent_type": "general",
  "task_id": "",
  "command": ""
}
```

**Output:**
```
task_id: ses_f600dc671ffe2F13Ds8AkB9xY7 (for resuming to continue this task if needed)

<task_result>
Created only [`modules/hardware/patches/fairydust-dptx-diagnostics.patch`](modules/hardware/patches/fairydust-dptx-diagnostics.patch): **225 lines**, targeting the exact requested store source. Not applied or enabled; `apple-silicon.nix` and existing user changes remain untouched.

**Coverage**
- `dcp.c`: separate capture of ignored connect/request-display/HPD-high returns; already-connected skip; explicit timeout versus positive-lane callback completion.
- `tipd/core.c`: DP mux return and missing-mux indicator; cached-same-mode skip; presence, HPD, orientation and outgoing hotplug timeline.
- `afk.c`: callback error before no-ACK return, including endpoint/channel/call/result.
- `iomfb_template.c`: 64-byte-bounded property key, processing result, modes and connection state; incoming hotplug before all gates; startup old/new connection assignment.
- `iomfb.c`: mode count, AV-service enablement, EDID-cache and connection state at `get_modes` entry.
- `dptxep.c`: default apcall port/call/sizes/lanes/rate without payload dumps; actual versus reported/fallback lanes, validation errors without reading failed PHY output; link-rate `phy_configure` result.

**Checks**
- Ordinary `git apply --check` in the pristine store source: **passed**, without `--unsafe-paths` or `--recount`.
- `git apply --numstat`: six files, 60 insertions, 10 deletions.
- Checkpatch patch mode, `--no-tree --no-signoff`: **0 errors, 0 warnings**.
- Requested `--no-tree --file`: 24 trailing-whitespace errors, all from required blank unified-diff context prefixes being treated as source text.

**Limits**
All instrumentation uses device-attributed `FDDBG` logging; existing returns, state transitions and protocol behavior are preserved. Optional release/HPD-low and ACK-send-error logs were omitted for compactness. No build or runtime testing; logging can affect timing and log volume.
</task_result>
```

---

## Assistant (Build · GPT-6 Astra · 8.9s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/ivy/nix/modules/hardware/patches/fairydust-dptx-diagnostics.patch",
  "offset": 1,
  "limit": 300
}
```

**Output:**
```
<path>/home/ivy/nix/modules/hardware/patches/fairydust-dptx-diagnostics.patch</path>
<type>file</type>
<content>
1: Subject: [PATCH] display: add optional FDDBG connection diagnostics
2: 
3: Optional FDDBG instrumentation only; no recovery or protocol changes.
4: Target: /nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source
5: 
6: diff --git a/drivers/gpu/drm/apple/dcp.c b/drivers/gpu/drm/apple/dcp.c
7: --- a/drivers/gpu/drm/apple/dcp.c
8: +++ b/drivers/gpu/drm/apple/dcp.c
9: @@ -361,5 +361,6 @@ static int dcp_dptx_connect(struct apple_dcp *dcp, u32 port)
10:  {
11:  	int ret = 0;
12: +	int call_ret;
13:  
14:  	if (!dcp->phy) {
15:  		dev_warn(dcp->dev, "dcp_dptx_connect: missing phy\n");
16: @@ -374,17 +375,25 @@ static int dcp_dptx_connect(struct apple_dcp *dcp, u32 port)
17:  		goto out_unlock;
18:  	}
19:  
20: -	if (dcp->dptxport[port].connected)
21: +	if (dcp->dptxport[port].connected) {
22: +		dev_info(dcp->dev, "FDDBG connect port=%u already-connected skip\n", port);
23:  		goto out_unlock;
24: +	}
25:  
26:  	reinit_completion(&dcp->dptxport[port].linkcfg_completion);
27:  	dcp->dptxport[port].atcphy = dcp->phy;
28: -	dptxport_connect(dcp->dptxport[port].service, 0, dcp->dptx_phy, dcp->dptx_die);
29: -	dptxport_request_display(dcp->dptxport[port].service);
30: +	call_ret = dptxport_connect(dcp->dptxport[port].service, 0,
31: +				    dcp->dptx_phy, dcp->dptx_die);
32: +	dev_info(dcp->dev, "FDDBG connect port=%u phy=%u die=%u ret=%d\n",
33: +		 port, dcp->dptx_phy, dcp->dptx_die, call_ret);
34: +	call_ret = dptxport_request_display(dcp->dptxport[port].service);
35: +	dev_info(dcp->dev, "FDDBG request_display port=%u ret=%d\n", port, call_ret);
36:  	dcp->dptxport[port].connected = true;
37:  
38:  	mutex_unlock(&dcp->hpd_mutex);
39:  	ret = wait_for_completion_timeout(&dcp->dptxport[port].linkcfg_completion,
40:  				    DPTX_CONNECT_TIMEOUT);
41: +	dev_info(dcp->dev, "FDDBG link_wait port=%u ret=%d %s\n", port, ret,
42: +		 ret < 0 ? "error" : ret == 0 ? "timeout" : "positive-lane-callback");
43:  	if (ret < 0)
44:  		dev_warn(dcp->dev, "dcp_dptx_connect: port %d link complete failed:%d\n",
45: @@ -395,8 +404,10 @@ static int dcp_dptx_connect(struct apple_dcp *dcp, u32 port)
46:  
47:  	usleep_range(5, 10);
48:  
49: -	if (dcp->connector_type == DRM_MODE_CONNECTOR_DisplayPort)
50: -		dptxport_set_hpd(dcp->dptxport[port].service, true);
51: +	if (dcp->connector_type == DRM_MODE_CONNECTOR_DisplayPort) {
52: +		call_ret = dptxport_set_hpd(dcp->dptxport[port].service, true);
53: +		dev_info(dcp->dev, "FDDBG set_hpd port=%u hpd=1 ret=%d\n", port, call_ret);
54: +	}
55:  
56:  	if (dcp->avep)
57:  		av_service_connect(dcp);
58: diff --git a/drivers/usb/typec/tipd/core.c b/drivers/usb/typec/tipd/core.c
59: --- a/drivers/usb/typec/tipd/core.c
60: +++ b/drivers/usb/typec/tipd/core.c
61: @@ -557,6 +557,7 @@ static void cd321x_typec_update_mode(struct tps6598x *tps, struct cd321x_status *st)
62:  	} else if (st->data_status & TPS_DATA_STATUS_DP_CONNECTION) {
63:  		struct typec_displayport_data dp_data;
64:  		unsigned long mode;
65: +		int mux_ret;
66:  
67:  		switch (TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT(st->data_status)) {
68:  		case TPS_DATA_STATUS_DP_SPEC_PIN_ASSIGNMENT_A:
69: @@ -584,6 +585,8 @@ static void cd321x_typec_update_mode(struct tps6598x *tps, struct cd321x_status *st)
70:  
71:  		if (cd321x->state.alt == cd321x->port_altmode_dp &&
72:  		   cd321x->state.mode == mode) {
73: +			dev_info(tps->dev, "FDDBG DP cached-same mode=%lu mux_missing=%d skip\n",
74: +				 mode, IS_ERR_OR_NULL(cd321x->mux));
75:  			return;
76:  		}
77:  
78: @@ -592,7 +595,10 @@ static void cd321x_typec_update_mode(struct tps6598x *tps, struct cd321x_status *st)
79:  		cd321x->state.alt = cd321x->port_altmode_dp;
80:  		cd321x->state.data = &dp_data;
81:  		cd321x->state.mode = mode;
82: -		typec_mux_set(cd321x->mux, &cd321x->state);
83: +		mux_ret = typec_mux_set(cd321x->mux, &cd321x->state);
84: +		dev_info(tps->dev, "FDDBG DP mux mode=%lu mux_missing=%d ret=%d status=%#x conf=%#x\n",
85: +			 mode, IS_ERR_OR_NULL(cd321x->mux), mux_ret,
86: +			 dp_data.status, dp_data.conf);
87:  	} else if (st->data_status & TPS_DATA_STATUS_TBT_CONNECTION) {
88:  		struct typec_thunderbolt_data tbt_data;
89:  
90: @@ -681,11 +687,16 @@ static void cd321x_update_work(struct work_struct *work)
91:  		 (is_pd && memcmp(&st.partner_identity,
92:  				  &cd321x->cur_partner_identity, sizeof(struct usb_pd_identity))));
93:  
94: +	dev_info(tps->dev, "FDDBG update present=%d->%d disconnected=%d hpd=%d changed=%d orientation=%u\n",
95: +		 old_connected, new_connected, was_disconnected, dp_hpd,
96: +		 dp_hpd_changed, orientation);
97: +
98:  	/* If we are switching from an active role, transition to USB_ROLE_NONE first */
99:  	if (old_role != USB_ROLE_NONE && (new_role != old_role || was_disconnected))
100:  		usb_role_switch_set_role(tps->role_sw, USB_ROLE_NONE);
101:  
102:  	if (cd321x->connector_fwnode && (!dp_hpd || dp_hpd_changed)) {
103: +		dev_info(tps->dev, "FDDBG update oob disconnected\n");
104:  		drm_connector_oob_hotplug_event(cd321x->connector_fwnode, connector_status_disconnected);
105:  	}
106:  
107: @@ -745,8 +756,10 @@ static void cd321x_update_work(struct work_struct *work)
108:  	/* Launch the USB role switch */
109:  	usb_role_switch_set_role(tps->role_sw, new_role);
110:  
111: -	if (cd321x->connector_fwnode && dp_hpd)
112: +	if (cd321x->connector_fwnode && dp_hpd) {
113: +		dev_info(tps->dev, "FDDBG update oob connected\n");
114:  		drm_connector_oob_hotplug_event(cd321x->connector_fwnode, connector_status_connected);
115: +	}
116:  
117:  	power_supply_changed(tps->psy);
118:  }
119: diff --git a/drivers/gpu/drm/apple/afk.c b/drivers/gpu/drm/apple/afk.c
120: --- a/drivers/gpu/drm/apple/afk.c
121: +++ b/drivers/gpu/drm/apple/afk.c
122: @@ -481,6 +481,8 @@ static void afk_recv_handle_std_service(struct apple_dcp_afkep *ep, u32 channel,
123:  					 payload + sizeof(*call), call_size,
124:  					 reply + sizeof(*call), call_size);
125:  		if (ret) {
126: +			dev_info(ep->dcp->dev, "FDDBG AFK no-ACK ep=%#x channel=%u call=%u ret=%d\n",
127: +				 ep->endpoint, channel, le32_to_cpu(call->type), ret);
128:  			kfree(reply);
129:  			return;
130:  		}
131: diff --git a/drivers/gpu/drm/apple/iomfb_template.c b/drivers/gpu/drm/apple/iomfb_template.c
132: --- a/drivers/gpu/drm/apple/iomfb_template.c
133: +++ b/drivers/gpu/drm/apple/iomfb_template.c
134: @@ -597,6 +597,10 @@ static u8 dcpep_cb_prop_end(struct apple_dcp *dcp,
135:  {
136:  	u8 resp = dcpep_process_chunks(dcp, req);
137:  
138: +	dev_info(dcp->dev, "FDDBG prop_end key=%.*s result=%u nr_modes=%u connected=%d\n",
139: +		 (int)sizeof(req->key), req->key, resp, dcp->nr_modes,
140: +		 dcp->connector ? dcp->connector->connected : -1);
141: +
142:  	/* move chunked data to connector to provide it via debugfs */
143:  	dcp_connector_update_dict(dcp->connector, req->key, &dcp->chunks);
144:  	dcp->chunks.data = NULL;
145: @@ -1010,6 +1014,11 @@ static void dcpep_cb_hotplug(struct apple_dcp *dcp, u64 *connected)
146:  {
147:  	struct apple_connector *connector = dcp->connector;
148:  
149: +	dev_info(dcp->dev, "FDDBG hotplug incoming=%llu connected=%d main=%d modeset=%d valid=%d nr_modes=%u\n",
150: +		 *connected, connector ? connector->connected : -1,
151: +		 dcp->main_display, dcp->during_modeset, dcp->valid_mode,
152: +		 dcp->nr_modes);
153: +
154:  	/* DCP issues hotplug_gated callbacks after SetPowerState() calls on
155:  	 * devices with display (macbooks, imacs). This must not result in
156:  	 * connector state changes on DRM side. Some applications won't enable
157: @@ -1427,6 +1436,8 @@ static void res_is_main_display(struct apple_dcp *dcp, void *out, void *cookie)
158:  
159:  	connector = dcp->connector;
160:  	if (connector) {
161: +		dev_info(dcp->dev, "FDDBG startup connected=%d->%d nr_modes=%u\n",
162: +			 connector->connected, dcp->nr_modes > 0, dcp->nr_modes);
163:  		connector->connected = dcp->nr_modes > 0;
164:  		schedule_work(&connector->hotplug_wq);
165:  	}
166: diff --git a/drivers/gpu/drm/apple/iomfb.c b/drivers/gpu/drm/apple/iomfb.c
167: --- a/drivers/gpu/drm/apple/iomfb.c
168: +++ b/drivers/gpu/drm/apple/iomfb.c
169: @@ -353,6 +353,10 @@ int dcp_get_modes(struct drm_connector *connector)
170:  	struct drm_display_mode *mode;
171:  	int i;
172:  
173: +	dev_info(dcp->dev, "FDDBG get_modes nr_modes=%u av_enabled=%d edid_cached=%d connected=%d\n",
174: +		 dcp->nr_modes, dcp->dcpavserv.enabled,
175: +		 !!apple_connector->drm_edid, apple_connector->connected);
176: +
177:  	for (i = 0; i < dcp->nr_modes; ++i) {
178:  		mode = drm_mode_duplicate(dev, &dcp->modes[i].mode);
179:  
180: diff --git a/drivers/gpu/drm/apple/dptxep.c b/drivers/gpu/drm/apple/dptxep.c
181: --- a/drivers/gpu/drm/apple/dptxep.c
182: +++ b/drivers/gpu/drm/apple/dptxep.c
183: @@ -259,7 +259,9 @@ static int dptxport_call_get_max_lane_count(struct apple_epic_service *service,
184:  
185:  	ret = phy_validate(dptx->atcphy, PHY_MODE_DP, 0, &phy_ops);
186:  	if (ret < 0) {
187: -		dev_err(dcp->dev, "phy_validate failed: %d\n", ret);
188: +		dev_err(dcp->dev,
189: +			"FDDBG get_max_lane_count port=%u phy_lanes=unknown reported=0 ret=%d\n",
190: +			dptx->unit, ret);
191:  		reply->retcode = cpu_to_le32(1);
192:  		reply->lane_count = cpu_to_le64(0);
193:  	} else {
194: @@ -275,6 +277,9 @@ static int dptxport_call_get_max_lane_count(struct apple_epic_service *service,
195:  		}
196:  		reply->retcode = cpu_to_le32(0);
197:  		reply->lane_count = cpu_to_le64(dptx->lane_count);
198: +		dev_info(dcp->dev, "FDDBG get_max_lane_count port=%u phy_lanes=%u reported=%u fallback=%d ret=%d\n",
199: +			 dptx->unit, phy_ops.dp.lanes, dptx->lane_count,
200: +			 phy_ops.dp.lanes < 2, ret);
201:  	}
202:  
203:  	return 0;
204: @@ -427,6 +432,9 @@ static int dptxport_call_set_link_rate(struct apple_epic_service *service,
205:  
206:  		if (dptx->atcphy) {
207:  			ret = phy_configure(dptx->atcphy, &dptx->phy_ops);
208: +			dev_info(service->ep->dcp->dev, "FDDBG link_rate port=%u rate=%#x phy_rate=%u lanes=%u ret=%d\n",
209: +				 dptx->unit, link_rate, phy_link_rate,
210: +				 dptx->phy_ops.dp.lanes, ret);
211:  			if (ret)
212:  				return ret;
213:  		}
214: @@ -555,8 +563,9 @@ static int dptxport_call(struct apple_epic_service *service, u32 idx,
215:  						reply, reply_size);
216:  	default:
217:  		/* just try to ACK and hope for the best... */
218: -		dev_info(service->ep->dcp->dev, "DPTXPort: acking unhandled call %u\n",
219: -			idx);
220: +		dev_info(service->ep->dcp->dev, "FDDBG unhandled apcall port=%u call=%u size=%zu reply_size=%zu lanes=%u rate=%#x ACK\n",
221: +			 dptx->unit, idx, data_size, reply_size,
222: +			 dptx->lane_count, dptx->link_rate);
223:  		fallthrough;
224:  	case DPTX_APCALL_GET_DOWN_SPREAD:
225:  	case DPTX_APCALL_SET_DOWN_SPREAD:

(End of file - total 225 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/Makefile",
  "offset": 1,
  "limit": 90
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/Makefile</path>
<type>file</type>
<content>
1: # SPDX-License-Identifier: GPL-2.0-only OR MIT
2: 
3: CFLAGS_trace.o = -I$(src)
4: 
5: appledrm-y := apple_drv.o
6: appledrm-y += afk.o dcp.o dcp_backlight.o dptxep.o iomfb.o parser.o systemep.o
7: appledrm-$(CONFIG_DRM_APPLE_AUDIO) += audio.o
8: appledrm-$(CONFIG_DRM_APPLE_AUDIO) += av.o
9: appledrm-y += connector.o
10: appledrm-y += ibootep.o
11: appledrm-y += iomfb_v12_3.o
12: appledrm-y += iomfb_v13_3.o
13: appledrm-y += epic/dpavservep.o
14: appledrm-y += plane.o
15: 
16: 
17: appledrm-$(CONFIG_TRACING) += trace.o
18: 
19: obj-$(CONFIG_DRM_APPLE) += appledrm.o

(End of file - total 19 lines)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/trace.h",
  "offset": 190,
  "limit": 250
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/trace.h</path>
<type>file</type>
<content>
190: 
191: 	TP_fast_assign(__assign_str(devname);
192: 		       __entry->endpoint = ep->endpoint;
193: 		       __entry->channel = channel; __entry->type = type;
194: 		       __entry->data_size = data_size;
195: 		       __entry->category = eshdr->category,
196: 		       __entry->subtype = le16_to_cpu(eshdr->type),
197: 		       __entry->tag = le16_to_cpu(eshdr->tag)),
198: 
199: 	TP_printk(
200: 		"%s: endpoint 0x%x (%s): channel 0x%x, type 0x%x (%s), data_size 0x%x, category: 0x%x (%s), subtype: 0x%x, seq: 0x%x",
201: 		__get_str(devname), __entry->endpoint,
202: 		show_dcp_endpoint(__entry->endpoint), __entry->channel,
203: 		__entry->type, print_epic_type(__entry->type),
204: 		__entry->data_size, __entry->category,
205: 		print_epic_category(__entry->category), __entry->subtype,
206: 		__entry->tag));
207: 
208: TRACE_EVENT(iomfb_callback,
209: 	    TP_PROTO(struct apple_dcp *dcp, int tag, const char *name),
210: 	    TP_ARGS(dcp, tag, name),
211: 
212: 	    TP_STRUCT__entry(
213: 				__string(devname, dev_name(dcp->dev))
214: 				__field(int, tag)
215: 				__field(const char *, name)
216: 			),
217: 
218: 	    TP_fast_assign(
219: 				__assign_str(devname);
220: 				__entry->tag = tag; __entry->name = name;
221: 			),
222: 
223: 	    TP_printk("%s: Callback D%03d %s", __get_str(devname), __entry->tag,
224: 		      __entry->name));
225: 
226: TRACE_EVENT(iomfb_push,
227: 	    TP_PROTO(struct apple_dcp *dcp,
228: 		     const struct dcp_method_entry *method, int context,
229: 		     int offset, int depth),
230: 	    TP_ARGS(dcp, method, context, offset, depth),
231: 
232: 	    TP_STRUCT__entry(
233: 				__string(devname, dev_name(dcp->dev))
234: 				__string(name, method->name)
235: 				__field(int, context)
236: 				__field(int, offset)
237: 				__field(int, depth)),
238: 
239: 	    TP_fast_assign(
240: 				__assign_str(devname);
241: 				__assign_str(name);
242: 				__entry->context = context; __entry->offset = offset;
243: 				__entry->depth = depth;
244: 			),
245: 
246: 	    TP_printk("%s: Method %s: context %u, offset %u, depth %u",
247: 		      __get_str(devname), __get_str(name), __entry->context,
248: 		      __entry->offset, __entry->depth));
249: 
250: TRACE_EVENT(iomfb_swap_submit,
251: 	    TP_PROTO(struct apple_dcp *dcp, u32 swap_id),
252: 	    TP_ARGS(dcp, swap_id),
253: 	    TP_STRUCT__entry(
254: 			     __field(u64, dcp)
255: 			     __field(u32, swap_id)
256: 	    ),
257: 	    TP_fast_assign(
258: 			   __entry->dcp = (u64)dcp;
259: 			   __entry->swap_id = swap_id;
260: 	    ),
261: 	    TP_printk("dcp=%llx, swap_id=%d",
262: 		      __entry->dcp,
263: 		      __entry->swap_id)
264: );
265: 
266: TRACE_EVENT(iomfb_swap_complete,
267: 	    TP_PROTO(struct apple_dcp *dcp, u32 swap_id),
268: 	    TP_ARGS(dcp, swap_id),
269: 	    TP_STRUCT__entry(
270: 			     __field(u64, dcp)
271: 			     __field(u32, swap_id)
272: 	    ),
273: 	    TP_fast_assign(
274: 			   __entry->dcp = (u64)dcp;
275: 			   __entry->swap_id = swap_id;
276: 	    ),
277: 	    TP_printk("dcp=%llx, swap_id=%d",
278: 		      __entry->dcp,
279: 		      __entry->swap_id
280: 	    )
281: );
282: 
283: TRACE_EVENT(iomfb_swap_complete_intent_gated,
284: 	    TP_PROTO(struct apple_dcp *dcp, u32 swap_id, u32 width, u32 height),
285: 	    TP_ARGS(dcp, swap_id, width, height),
286: 	    TP_STRUCT__entry(
287: 			     __field(u64, dcp)
288: 			     __field(u32, swap_id)
289: 			     __field(u32, width)
290: 			     __field(u32, height)
291: 	    ),
292: 	    TP_fast_assign(
293: 			   __entry->dcp = (u64)dcp;
294: 			   __entry->swap_id = swap_id;
295: 			   __entry->height = height;
296: 			   __entry->width = width;
297: 	    ),
298: 	    TP_printk("dcp=%llx, swap_id=%u %ux%u",
299: 		      __entry->dcp,
300: 		      __entry->swap_id,
301: 		      __entry->width,
302: 		      __entry->height
303: 	    )
304: );
305: 
306: TRACE_EVENT(iomfb_abort_swap_ap_gated,
307: 	    TP_PROTO(struct apple_dcp *dcp, u32 swap_id),
308: 	    TP_ARGS(dcp, swap_id),
309: 	    TP_STRUCT__entry(
310: 			     __field(u64, dcp)
311: 			     __field(u32, swap_id)
312: 	    ),
313: 	    TP_fast_assign(
314: 			   __entry->dcp = (u64)dcp;
315: 			   __entry->swap_id = swap_id;
316: 	    ),
317: 	    TP_printk("dcp=%llx, swap_id=%u",
318: 		      __entry->dcp,
319: 		      __entry->swap_id
320: 	    )
321: );
322: 
323: DECLARE_EVENT_CLASS(iomfb_parse_mode_template,
324: 	    TP_PROTO(s64 id, struct dimension *horiz, struct dimension *vert, s64 best_color_mode, bool is_virtual, s64 score),
325: 	    TP_ARGS(id, horiz, vert, best_color_mode, is_virtual, score),
326: 
327: 	    TP_STRUCT__entry(__field(s64, id)
328: 			     __field_struct(struct dimension, horiz)
329: 			     __field_struct(struct dimension, vert)
330: 			     __field(s64, best_color_mode)
331: 			     __field(bool, is_virtual)
332: 			     __field(s64, score)),
333: 
334: 	    TP_fast_assign(__entry->id = id;
335: 			   __entry->horiz = *horiz;
336: 			   __entry->vert = *vert;
337: 			   __entry->best_color_mode = best_color_mode;
338: 			   __entry->is_virtual = is_virtual;
339: 			   __entry->score = score;),
340: 
341: 	    TP_printk("id: %lld, best_color_mode: %lld, resolution:%lldx%lld virtual: %d, score: %lld",
342: 		      __entry->id, __entry->best_color_mode,
343: 		      __entry->horiz.active, __entry->vert.active,
344: 		      __entry->is_virtual, __entry->score));
345: 
346: DEFINE_EVENT(iomfb_parse_mode_template, iomfb_parse_mode_success,
347: 	    TP_PROTO(s64 id, struct dimension *horiz, struct dimension *vert, s64 best_color_mode, bool is_virtual, s64 score),
348: 	    TP_ARGS(id, horiz, vert, best_color_mode, is_virtual, score));
349: 
350: DEFINE_EVENT(iomfb_parse_mode_template, iomfb_parse_mode_fail,
351: 	    TP_PROTO(s64 id, struct dimension *horiz, struct dimension *vert, s64 best_color_mode, bool is_virtual, s64 score),
352: 	    TP_ARGS(id, horiz, vert, best_color_mode, is_virtual, score));
353: 
354: TRACE_EVENT(dcpavserv_init, TP_PROTO(struct apple_dcp *dcp, u64 unit),
355: 	    TP_ARGS(dcp, unit),
356: 
357: 	    TP_STRUCT__entry(__string(devname, dev_name(dcp->dev))
358: 				     __field(u64, unit)),
359: 
360: 	    TP_fast_assign(__assign_str(devname);
361: 			   __entry->unit = unit;),
362: 
363: 	    TP_printk("%s: dcpav-service unit %lld initialized", __get_str(devname),
364: 		      __entry->unit));
365: 
366: TRACE_EVENT(dptxport_init, TP_PROTO(struct apple_dcp *dcp, u64 unit),
367: 	    TP_ARGS(dcp, unit),
368: 
369: 	    TP_STRUCT__entry(__string(devname, dev_name(dcp->dev))
370: 				     __field(u64, unit)),
371: 
372: 	    TP_fast_assign(__assign_str(devname);
373: 			   __entry->unit = unit;),
374: 
375: 	    TP_printk("%s: dptxport unit %lld initialized", __get_str(devname),
376: 		      __entry->unit));
377: 
378: TRACE_EVENT(
379: 	dptxport_apcall,
380: 	TP_PROTO(struct dptx_port *dptx, int idx, size_t len),
381: 	TP_ARGS(dptx, idx, len),
382: 
383: 	TP_STRUCT__entry(__string(devname, dev_name(dptx->service->ep->dcp->dev))
384: 			__field(u32, unit) __field(int, idx) __field(size_t, len)),
385: 
386: 	TP_fast_assign(__assign_str(devname);
387: 		       __entry->unit = dptx->unit; __entry->idx = idx; __entry->len = len;),
388: 
389: 	TP_printk("%s: dptx%d: AP Call %d (%s) with len %lu", __get_str(devname),
390: 		  __entry->unit,
391: 		  __entry->idx, show_dptxport_apcall(__entry->idx), __entry->len));
392: 
393: TRACE_EVENT(
394: 	dptxport_validate_connection,
395: 	TP_PROTO(struct dptx_port *dptx, u8 core, u8 atc, u8 die),
396: 	TP_ARGS(dptx, core, atc, die),
397: 
398: 	TP_STRUCT__entry(__string(devname, dev_name(dptx->service->ep->dcp->dev))
399: 			 __field(u32, unit) __field(u8, core) __field(u8, atc) __field(u8, die)),
400: 
401: 	TP_fast_assign(__assign_str(devname);
402: 		       __entry->unit = dptx->unit; __entry->core = core; __entry->atc = atc; __entry->die = die;),
403: 
404: 	TP_printk("%s: dptx%d: core %d, atc %d, die %d", __get_str(devname),
405: 		  __entry->unit, __entry->core, __entry->atc, __entry->die));
406: 
407: TRACE_EVENT(
408: 	dptxport_connect,
409: 	TP_PROTO(struct dptx_port *dptx, u8 core, u8 atc, u8 die),
410: 	TP_ARGS(dptx, core, atc, die),
411: 
412: 	TP_STRUCT__entry(__string(devname, dev_name(dptx->service->ep->dcp->dev))
413: 			 __field(u32, unit) __field(u8, core) __field(u8, atc) __field(u8, die)),
414: 
415: 	TP_fast_assign(__assign_str(devname);
416: 		       __entry->unit = dptx->unit; __entry->core = core; __entry->atc = atc; __entry->die = die;),
417: 
418: 	TP_printk("%s: dptx%d: core %d, atc %d, die %d", __get_str(devname),
419: 		  __entry->unit, __entry->core, __entry->atc, __entry->die));
420: 
421: TRACE_EVENT(
422: 	dptxport_call_set_link_rate,
423: 	TP_PROTO(struct dptx_port *dptx, u32 link_rate),
424: 	TP_ARGS(dptx, link_rate),
425: 
426: 	TP_STRUCT__entry(__string(devname, dev_name(dptx->service->ep->dcp->dev))
427: 			 __field(u32, unit)
428: 			 __field(u32, link_rate)),
429: 
430: 	TP_fast_assign(__assign_str(devname);
431: 		       __entry->unit = dptx->unit;
432: 		       __entry->link_rate = link_rate;),
433: 
434: 	TP_printk("%s: dptx%d: link rate 0x%x", __get_str(devname), __entry->unit,
435: 		  __entry->link_rate));
436: 
437: TRACE_EVENT(iomfb_brightness,
438: 	    TP_PROTO(struct apple_dcp *dcp, u32 nits),
439: 	    TP_ARGS(dcp, nits),

(Showing lines 190-439 of 608. Use offset=440 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/connector.c",
  "offset": 1,
  "limit": 160
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/connector.c</path>
<type>file</type>
<content>
1: // SPDX-License-Identifier: GPL-2.0+ OR MIT
2: /*
3:  * Copyright (C) The Asahi Linux Contributors
4:  */
5: 
6: #include "connector.h"
7: 
8: #include "linux/err.h"
9: #include <linux/debugfs.h>
10: #include <linux/module.h>
11: #include <linux/seq_file.h>
12: #include <linux/string_helpers.h>
13: #include <linux/uaccess.h>
14: 
15: #include <drm/drm_managed.h>
16: 
17: #include "dcp-internal.h"
18: 
19: enum dcp_chunk_type {
20: 	DCP_CHUNK_COLOR_ELEMENTS,
21: 	DCP_CHUNK_TIMING_ELELMENTS,
22: 	DCP_CHUNK_DISPLAY_ATTRIBUTES,
23: 	DCP_CHUNK_TRANSPORT,
24: 	DCP_CHUNK_NUM_TYPES,
25: };
26: 
27: static int chunk_show(struct seq_file *m,
28: 		      enum dcp_chunk_type chunk_type)
29: {
30: 	struct apple_connector *apple_con = m->private;
31: 	struct dcp_chunks *chunk = NULL;
32: 
33: 	mutex_lock(&apple_con->chunk_lock);
34: 
35: 	switch (chunk_type) {
36: 	case DCP_CHUNK_COLOR_ELEMENTS:
37: 		chunk = &apple_con->color_elements;
38: 		break;
39: 	case DCP_CHUNK_TIMING_ELELMENTS:
40: 		chunk = &apple_con->timing_elements;
41: 		break;
42: 	case DCP_CHUNK_DISPLAY_ATTRIBUTES:
43: 		chunk = &apple_con->display_attributes;
44: 		break;
45: 	case DCP_CHUNK_TRANSPORT:
46: 		chunk = &apple_con->transport;
47: 		break;
48: 	default:
49: 		break;
50: 	}
51: 
52: 	if (chunk)
53:                 seq_write(m, chunk->data, chunk->length);
54: 
55: 	mutex_unlock(&apple_con->chunk_lock);
56: 
57: 	return 0;
58: }
59: 
60: #define CONNECTOR_DEBUGFS_ENTRY(name, type) \
61: static int chunk_ ## name ## _show(struct seq_file *m, void *data) \
62: { \
63:         return chunk_show(m, type); \
64: } \
65: static int chunk_ ## name ## _open(struct inode *inode, struct file *file) \
66: { \
67:         return single_open(file,  chunk_ ## name ## _show, inode->i_private); \
68: } \
69: static const struct file_operations chunk_ ## name ## _fops = { \
70:         .owner = THIS_MODULE, \
71:         .open = chunk_ ## name ## _open, \
72:         .read = seq_read, \
73:         .llseek = seq_lseek, \
74:         .release = single_release, \
75: }
76: 
77: CONNECTOR_DEBUGFS_ENTRY(color, DCP_CHUNK_COLOR_ELEMENTS);
78: CONNECTOR_DEBUGFS_ENTRY(timing, DCP_CHUNK_TIMING_ELELMENTS);
79: CONNECTOR_DEBUGFS_ENTRY(display_attribs, DCP_CHUNK_DISPLAY_ATTRIBUTES);
80: CONNECTOR_DEBUGFS_ENTRY(transport, DCP_CHUNK_TRANSPORT);
81: 
82: static void dcp_afk_debugfs_root(struct platform_device *pdev, int ep, struct dentry *root)
83: {
84: #if IS_ENABLED(CONFIG_DRM_APPLE_DEBUG)
85: 	struct dentry *entry = NULL;
86: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
87: 
88: 	switch (ep) {
89: 	case AV_ENDPOINT:
90: 		entry = debugfs_create_dir("avep", root);
91: 		break;
92: 	default:
93: 		break;
94: 	}
95: 
96: 	if (!IS_ERR_OR_NULL(entry))
97: 		dcp->ep_debugfs[ep - 0x20] = entry;
98: #endif
99: }
100: 
101: void apple_connector_debugfs_init(struct drm_connector *connector, struct dentry *root)
102: {
103: 	struct apple_connector *apple_con = to_apple_connector(connector);
104: 
105:         debugfs_create_file("ColorElements", 0444, root, apple_con,
106:                             &chunk_color_fops);
107:         debugfs_create_file("TimingElements", 0444, root, apple_con,
108:                             &chunk_timing_fops);
109:         debugfs_create_file("DisplayAttributes", 0444, root, apple_con,
110:                             &chunk_display_attribs_fops);
111:         debugfs_create_file("Transport", 0444, root, apple_con,
112:                             &chunk_transport_fops);
113: 
114: 	switch (connector->connector_type) {
115: 	case DRM_MODE_CONNECTOR_DisplayPort:
116: 	case DRM_MODE_CONNECTOR_HDMIA:
117: 		dcp_afk_debugfs_root(apple_con->dcp, AV_ENDPOINT, root);
118: 		break;
119: 	default:
120: 		break;
121: 	}
122: }
123: 
124: static void dcp_connector_set_dict(struct apple_connector *connector,
125: 				   struct dcp_chunks *dict,
126: 				   struct dcp_chunks *chunks)
127: {
128: 	if (dict->data)
129: 		devm_kfree(&connector->dcp->dev, dict->data);
130: 
131: 	*dict = *chunks;
132: }
133: 
134: void dcp_connector_update_dict(struct apple_connector *connector, const char *key,
135: 			       struct dcp_chunks *chunks)
136: {
137: 	mutex_lock(&connector->chunk_lock);
138: 	if (!strcmp(key, "ColorElements"))
139: 		dcp_connector_set_dict(connector, &connector->color_elements, chunks);
140: 	else if (!strcmp(key, "TimingElements"))
141: 		dcp_connector_set_dict(connector, &connector->timing_elements, chunks);
142: 	else if (!strcmp(key, "DisplayAttributes"))
143: 		dcp_connector_set_dict(connector, &connector->display_attributes, chunks);
144: 	else if (!strcmp(key, "Transport"))
145: 		dcp_connector_set_dict(connector, &connector->transport, chunks);
146: 
147: 	chunks->data = NULL;
148: 	chunks->length = 0;
149: 
150: 	mutex_unlock(&connector->chunk_lock);
151: }

(End of file - total 151 lines)
</content>
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://asahilinux.org/2026/02/progress-report-6-19/",
  "format": "markdown",
  "timeout": 60
}
```

**Output:**
```
 Progress Report: Linux 6.19 - Asahi Linux                

[![](/img/AsahiLinux_logo.svg?d619e737)](/)

-   [About](/about)
-   [Community](/community)
-   [Contribute](/contribute)
-   [Governance](/governance)
-   [Documentation](/docs)
-   [GitHub](https://github.com/AsahiLinux)
-   [Blog](/blog)
-   [Merch](/merch)
-   [Donate](/support)

[](https://asahilinux.org/)/ [Blog](https://asahilinux.org/blog/) / [Progress Report: Linux 6.19](https://asahilinux.org/2026/02/progress-report-6-19/)

# Progress Report: Linux 6.19

-   [Previous](https://asahilinux.org/2025/12/progress-report-6-18/)

-   [Next](https://asahilinux.org/2026/04/progress-report-7-0/)

Happy belated new year! Linux 6.19 is now out in the wild and… ah, let’s just cut to the chase. We know what you’re here for.

## The big one

Asahi Linux turns 5 this year. In those five years, we’ve gone from Hello World over a serial port to being one of the best supported desktop-grade AArch64 platform in the Linux ecosystem. The sustained interest in Asahi was the push many developers needed to start taking AArch64 seriously, with a whole slew of platform-specific bugs in popular software being fixed specifically to enable their use on Apple Silicon devices running Linux. We are immensely proud of what we have achieved and consider the project a resounding and continued success.

And yet, there has remained one question seemingly on everyone’s lips. Every announcement, every upstreaming victory, every blog post has drawn this question out in one way or another. It is asked at least once a week on IRC and Matrix, and we even occasionally receive emails asking it.

“When will display out via USB-C be supported?”

“Is there an ETA for DisplayPort Alt Mode?”

“Can I use an HDMI adapter on my MacBook Air yet?”

Despite repeated polite requests to not ask us for specific feature ETAs, the questions kept coming. In an effort to try and curtail this, we toyed with setting a “minimum” date for the feature and simply doubling it every time the question was asked. This very quickly led to the date being after the predicted heat death of the universe. We fell back on a tried and tested response pioneered by id Software; DP Alt Mode will be done when it’s done.

And, well, it’s done. Kind of.

In December, Sven gave a [talk at 39C3](https://media.ccc.de/v/39c3-asahi-linux-porting-linux-to-apple-silicon) recounting the Asahi story so far, our reverse engineering process, and what the immediate future looks like for us. At the end, he revealed that the slide deck had been running on an M1 MacBook Air, connected to the venue’s AV system via a USB-C to HDMI adapter!

At the same time, we quietly pushed the [fairydust](https://github.com/AsahiLinux/linux/tree/fairydust) branch to our downstream Linux tree. This branch is the culmination of years of hard work from Sven, Janne and marcan, wrangling and taming the fragile and complicated USB and display stacks on this platform. Getting a display signal out of a USB-C port on Apple Silicon involves four distinct hardware blocks; DCP[1](#fn:1), DPXBAR[2](#fn:2), ATCPHY[3](#fn:3), and ACE[4](#fn:4). These four pieces of hardware each required reverse engineering, a Linux driver, and then a whole lot of convincing to play nicely with each other.

All of that said, there is still work to do. Currently, the fairydust branch “blesses” a specific USB-C port on a machine for use with DisplayPort, meaning that multiple USB-C displays is still not possible. There are also some quirks regarding both cold and hot plug of displays. Moreover, some users have reported that DCP does not properly handle certain display setups, variously exhibiting incorrect or oversaturated colours or missing timing modes.

For all of these reasons, we provide the fairydust branch strictly as-is. It is intended primarily for developers who may be able to assist us with ironing out these kinks with minimal support or guidance from us. Of course, users who are comfortable with building and installing their own kernels on Apple Silicon are more than welcome to try it out for themselves, but we cannot offer any support for this until we deem it ready for general use.

## The other big one

For quite some time, m1n1 has had basic support for the M3 series machines. What has been missing are Devicetrees for each machine, as well as patches to our Linux kernel drivers to support M3-specific hardware quirks and changes from M2. Our intent was always to get to fleshing this out once our existing patchset became more manageable, but with the quiet hope that the groundwork being laid would excite a new contributor enough to step up to the plate and attempt to help out. Well, we actually ended up with *three* new contributors!

Between the three of them, [Alyssa Milburn (noopwafel)](https://noopwafel.net), [Michael Reeves (integralpilot)](https://github.com/IntegralPilot), and [Shiz](https://shiz.me), with help from Janne, wrote some preliminary Devicetrees and found that a great deal of hardware worked without any changes! Adding in some minor kernel changes for the NVMe and interrupt controllers, Michael was able to [boot](https://www.reddit.com/r/AsahiLinux/comments/1qnddjd/m3_now_has_fedora_43_asahi_remix_working_with_kde/) all the way to Plasma on an M3 MacBook Air!

In fact, the current state of M3 support is about where M1 support was when we released the first Arch Linux ARM based beta; keyboard, touchpad, WiFi, NVMe and USB3 are all working, albeit with some local patches to m1n1 and the Asahi kernel (yet to make their way into a pull request) required. So that must mean we will have a release ready soon, right?

A lot has changed in five years. We have earnt a reputation for being the most complete and polished AArch64 desktop Linux experience available, and *one of* the most complete and polished desktop Linux experiences in general. It is a reputation that we are immensely proud of, and has come at a great personal cost to many. We will not squander it or take it for granted.

Ideally, the current state of M1 and M2 support should be the baseline for any general availability release for M3. We know that’s not *realistic*, however nor is releasing a janky, half-baked and unfinished mess like the initial ALARM releases all those years ago. So, what needs to be done before we can cut a release? Quite a bit, actually.

The first thing intrepid testers will notice is that the graphical environment is entirely software-rendered. This is extremely slow and energy intensive, and barely keeps up with scrolling text in a terminal window. Unfortunately, this is not likely to change any time soon; the GPU design found in M3 series SoCs is a significant departure from the GPU found in M1 and M2, introducing hardware accelerated ray tracing and mesh shaders, as well as Dynamic Caching, which Apple claims enables more efficient allocation of low-level GPU resources. Alyssa M. and Michael have volunteered their time to M3 GPU reverse engineering, and building on the work done by dougallj and TellowKrinkle, have already made some progress on the myriad changes to the GPU ISA between M2 and M3.

We are also relying on iBoot to initialise DCP and allocate us a framebuffer, rather than driving DCP directly (and correctly) ourselves. This is extremely slow and inefficient, and prevents us from properly managing many display features, such as the backlight. Since no M3 devices can run macOS 13.5, and since Apple made a number of changes to the DCP firmware interface for macOS 14, bringing up DCP on M3 devices will require more reverse engineering. Luckily these changes only affect the API itself, and not the protocol used to communicate between the OS and coprocessor. This means we can reuse our existing tooling to trace the new firmware interface with minimal changes.

Beyond hardware enablement, there are also the numerous integrations and finishing touches that make the Asahi experience what it is. Energy-Aware Scheduling, speaker safety and EQ tuning, microphone and webcam support, and a whole host of other features that folks expect are still not there, and won’t be for some time. Some of these, like Energy-Aware Scheduling, are quality of life features that are not likely to block a release. Others, such as getting M3 devices supported in speakersafetyd, are release-blocking.

We don’t expect it to take *too* long to get M3 support into a shippable state, but much as with everything else we do, we cannot provide an ETA and request that you do not ask for one.

## Hertz so good

The 14" and 16" MacBook Pros have very nice displays. They have extremely accurate colour reproduction, are extremely bright, *and* are capable of a 120 Hz refresh rate. But there’s a catch.

On macOS, you cannot simply set these displays to 120 Hz and call it a day. Instead, Apple hides refresh rates above 60 Hz behind their ProMotion feature, which is really just a marketing term for bog standard variable refresh rate. One could be forgiven for assuming that this is just a quirk of macOS, and that simply selecting the 120 Hz timing mode in the DCP firmware would be enough to drive the panel at that refresh rate on Linux, however this is not the case.

For reasons known only to Apple, DCP will refuse to drive the MacBook Pro panels higher than 60 Hz unless three specific fields in the surface swap request struct are filled. We have known for some time that these fields were some form of timestamp, however we never had the time to investigate them more deeply than that. Enter yet another new contributor!

[Oliver Bestmann](https://github.com/oliverbestmann) took it upon himself to get 120 Hz working on MacBook Pros, and to that end looked into the three timestamps. Analysing traces from macOS revealed them to count upward in CPU timer ticks. The timestamps are almost always exactly one frame apart, hinting that they are used for frame presentation timekeeping. Presentation timekeeping is required for VRR to work properly, as the compositor and driver must both be aware of when specific frames are actually being shown on the display. Compositors can also use this sort of information to help with maintaining consistent frame pacing and minimising tearing, even when VRR is not active.

At this stage, we are only interested in a consistent 120 Hz, not VRR. Since macOS couples the two together, it is difficult to ascertain exactly what DCP expects us to do for 120 Hz. Clearly the timestamps are required, but why? What does DCP do with them, and what *exactly* are they supposed to represent?

Sometimes, doing something stupid is actually very smart. Assuming that the timestamps are only *meaningful* for VRR, Oliver tried stuffing a static value into each timestamp field. And it worked! Starting with kernel version 6.18.4, owners of 14" and 16" MacBook Pros are able to drive their builtin displays at 120 Hz.

Now of course, this solution is quite clearly jank. The presentation timestamps are currently being set every time the KMS subsystem triggers an atomic state flush, and they are definitely not supposed to be set to a static value. While it works for our use case, this solution precludes support for VRR, which brings us nicely to our next topic.

## Landing the plane

The DCP driver for Linux has historically been rather incomplete. This shouldn’t be surprising; display engines are massively complex, and this is reflected in the absolutely enormous 9 MiB blob of firmware that DCP runs. This firmware exposes interfaces which are designed to integrate tightly with macOS. These interfaces also change in breaking ways between macOS releases, requiring special handling for versioned structures and function calls.

All of this has led to a driver that has been developed in an suboptimal, piecemeal fashion. There are many reasons for this:

-   We lacked the time to do anything else, especially Janne, who took on the burden of maintaining and rebasing the Asahi kernel tree
-   There were more important things to do, like bringing up other hardware
-   We plan to rewrite the driver in Rust anyway to take advantage of better firmware version handling

On top of all that, it simply did not matter for the design goals at the time. The initial goal was to get enough of DCP brought up to reliably drive the builtin displays on the laptops and the HDMI ports on the desktops, and we achieved that by gluing just enough of DCP’s firmware interface to the KMS API to scan out a single 8-bit ARGB framebuffer on each swap.

We have since implemented support for audio over DisplayPort/HDMI, basic colour management for Night Light implementations that support Colour Transformation Matrices, and rudimentary hardware overlays. But this still leaves a lot of features on the table, such as HDR, VRR, support for other framebuffer formats, hardware brightness control for external displays (DDC/CI), and direct scanout support for multimedia and fullscreen applications.

Supporting these within the confines of the current driver architecture would be difficult. There are a number of outstanding issues with userspace integration and the way in which certain components interact with the KMS API. That said, want to push forward with new features, and waiting for Rust KMS bindings to land upstream could leave us waiting for quite some time. We have instead started refactoring sections of the existing DCP driver where necessary, starting with the code for handling hardware planes.

Why start there? Having proper support for hardware planes is important for performance and efficiency. Most display engines have facilities for compositing multiple framebuffers in hardware, and DCP is no exception. It can layer, move, blend and even apply basic colour transformations to these framebuffers. The classical use case for this functionality has been cursors; rather than have the GPU redraw the entire desktop every time the cursor moves, we can put the cursor on one of the display engine’s overlay planes and then command it to move that static framebuffer around the screen. The GPU is only actively rendering when on-screen *content* needs redrawing, such as when hovering over a button.

I shoehorned extremely limited support for this into the driver a while ago, and it has been working nicely with Plasma 6’s hardware cursor support. But we need to go deeper.

DCP is capable of some very nifty features, some of which are absolutely necessary for HDR and direct video scanout. Importantly for us, DCP can:

-   Directly scan out semiplanar Y’CbCr framebuffers (both SDR and HDR)
-   Take multiple framebuffers of differing colourspaces and normalise them to the connected display’s colourspace before scanout
-   Directly scan out compressed framebuffers created by AGX[5](#fn:5) and AVD[6](#fn:6)
-   Automatically normalise mixed dynamic range content

All of these are tied to DCP’s idea of a plane. I had initially attempted to add support for Y’CbCr framebuffers without any refactoring, however this this was proving to be messy and overly complicated to integrate with the way we were constructing a swap request at the time. Refactoring the plane code made both adding Y’CbCr support *and* constructing a swap request simpler.

We have also been able to begin *very early* HDR experiments, and get more complete overlay support working, including for Y’CbCr video sources. Plasma 6.5 has very basic support for overlay planes hidden behind a feature flag, however it is still quite broken. A few Kwin bugs related to this are slated to be fixed for Plasma 6.7, which may enable us to expand DCP’s overlay support even further.

On top of this, Oliver has also begun working on compressed framebuffer support. There are currently two proprietary Apple framebuffer formats we know of in use on Apple Silicon SoCs; AGX has its own framebuffer format which is already supported in Mesa, however macOS never actually sends framebuffers in this format to DCP. Instead, DCP always scans out framebuffers in the “Apple Interchange” format for both GPU-rendered framebuffers and AVD-decoded video. Oliver reverse engineered this new format and added experimental support for it to Mesa and the DCP driver. While still a work in progress, this should eventually enable significant memory bandwidth and energy savings, particularly when doing display-heavy tasks like watching videos. Experimentation with DCP and its firmware suggests that it may be capable of directly reading AGX-format framebuffers too, however this will require further investigation as we cannot rely on observations from macOS.

Additionally, Lina observed macOS using shader code to decompress Interchange framebuffers while reverse engineering AGX, suggesting that some variants of AGX may not be capable of working with the format. If this is the case, we will be restricted to only using Interchange for AVD-decoded video streams, falling back to either AGX format if it turns out to be supported by DCP, or linear framebuffers for content rendered by the GPU.

Beyond adding new features, reworking the plane handling code has also enabled us to more easily fix oversaturated colours on the builtin MacBook displays, starting with kernel version 6.18. Folks currently using an ICC profile to work around this problem should disable this, as it will conflict with DCP’s internal colour handling.

Planes are just one part of the puzzle, however. There is still much work to be done cleaning up the driver and getting features like HDR into a shippable state. Watch this space!

## Say cheese!

It’s been quite a while since we shipped webcam support, and for *most* users it seems to have Just Worked! But not for *all* users.

Users of certain webcam applications, most notable GNOME’s Camera app, have been reporting severe issues with webcam support since day one. Doing some initial debugging on this pointed to it being an issue with GNOME’s app, however this turned out not to be the case. The Asahi OpenGL driver was actually improperly handling planar video formats. The ISP/webcam exports planar video framebuffers via V4L2, which must then be consumed and turned into RGB framebuffers for compositing with the desktop. Apps such as GNOME’s Camera app do this with the GPU, and thus were failing hard. While studying the [fix](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/38160) for this, Janne noticed that Honeykrisp was not properly announcing the number of planes in any planar framebuffers, and [fixed](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/38200) that too. In the process of debugging these issues, Robert Mader found that Fedora was not building GStreamer’s gtk4paintablesink plugin with Y’CbCr support, which will be fixed for Fedora Linux 43.

So all good right? Nope! Hiding behind these bugs in the GPU drivers were two more bugs, this time in PipeWire. The first was an integer overflow in PipeWire’s GStreamer code, [fixed](https://gitlab.freedesktop.org/pipewire/pipewire/-/merge_requests/2582) by Robert. This then revealed the second bug; the code which determines the latency of a stream was assuming a period numerator of 1, which is not always the case. With Apple Silicon machines, the period is expressed as 256/7680, which corresponds to 30 frames per second. Since the numerator is not 1, the latency calculation was not being normalised, and thus ended up so long that streams would crash waiting for data from PipeWire. Janne submitted a [merge request](https://gitlab.freedesktop.org/pipewire/pipewire/-/merge_requests/2636) with a fix, which made it in to Pipewire 1.4.10. Why 256/7680 is not reduced to 1/30 is another mystery that needs solving, however at least now with these two patches, we’re all good right? Right?

So, graphics programming is actually really hard. As it happens, the GPU kernel driver was not properly handling DMA-BUFs from external devices, deadlocking once it was done using the imported buffer. After fixing this and removing a very noisy log message that was being triggered for every imported frame, the webcam came to life! This should mean that the webcam is now fully supported across the vast majority of applications.

## The beast stirs

We’ve made incredible progress upstreaming patches over the past 12 months. Our patch set has shrunk from 1232 patches with 6.13.8, to 858 as of 6.18.8. Our total delta in terms of lines of code has also shrunk, from 95,000 lines to 83,000 lines for the same kernel versions. Hmm, a 15% reduction in lines of code for a 30% reduction in patches seems a bit wrong…

Not all patches are created equal. Some of the upstreamed patches have been small fixes, others have been thousands of lines. All of them, however, pale in comparison to the GPU driver.

The GPU driver is 21,000 lines by itself, discounting the downstream Rust abstractions we are still carrying. It is almost double the size of the DCP driver and thrice the size of the ISP/webcam driver, its two closest rivals. And upstreaming work has now begun.

We were very graciously granted leave to upstream our UAPI headers *without* an accompanying driver by the DRM maintainers quite some time ago, on the proviso that the driver would follow. Janne has now been laying the groundwork for that to happen with [patches to IGT](https://lore.kernel.org/asahi/20260105-asahi-tests-wave1-v1-0-a6c72617e680@jannau.net/T/#t), the test suite for DRM drivers.

There is still some cleanup work required to get the driver into an upstreamable state, and given its size we expect the review process to take quite some time even when it is ready. We hope to have more good news on this front shortly!

## Correct, then fast

GPU drivers have a lot of moving parts, and all of them are expected to work perfectly. They are also expected to be *fast*. As it so happens, writing software that is both correct *and* fast is quite the challenge. The typical development cycle for any given GPU driver feature is to make it work properly first, then find ways to speed it up later if possible. Performance is sometimes left on the table though.

While looking at [gpu-ratemeter](https://gitlab.freedesktop.org/mesa/gpu-ratemeter) benchmark results, Janne noticed that memory copies via the OpenGL driver were pathologically slow, much slower than Vulkan-initiated memory copies. As in, taking an hour to complete just this one microbenchmark slow. Digging around in the Asahi OpenGL driver revealed that memory copy operations were being offloaded to the CPU rather than implemented as GPU code like with Vulkan. After writing a shader to implement this, OpenGL copies now effectively saturate the memory bus, which is about as good as one could hope for!

But why stop there? Buffer *copies* are now fast, but what about clearing memory? The Asahi driver was using Mesa’s default buffer clearing helpers, which work but cannot take advantage of hardware-specific optimisations. Janne also replaced this with calls to AGX-optimised functions which take optimised paths for memory-aligned buffers. This allows an M1 Ultra to clear buffers aligned to 16 byte boundaries at 355 GB/s.

But wait, there’s more! While Vulkan copies were indeed faster than OpenGL copies, they weren’t as fast as they could be. Once again, we were neglecting to use our AGX-optimised routines for copying aligned buffers. Fixing this gives us some pretty hefty performance increases for such buffers, ranging from 30% faster for 16 KiB buffers to more than twice as fast for buffers 8 MiB and larger!

## Perfecting packages

All this stuff around pushing pixels perfectly requires good delivery of the code, and Neal has worked on improving the package management experience in Fedora Asahi Remix.

The major piece of technical debt that existed in Fedora’s package management stack was that it technically shipped *two* versions of the DNF package manager concurrently, which is exactly as bad as it sounds. Both versions had their own configuration, feature sets and behavioural quirks.

DNF5, the newer version, introduces the ability to automatically transition packages across vendors. This is important for us, as it streamlines our ability to seamlessly replace our Asahi-specific forks with their upstreams packages as we get our code merged. DNF4 cannot do this, and until Fedora Linux 41 was the default version used when running `dnf` from the command line. To make matters worse, PackageKit, the framework used by GUI software stores like KDE Discover, only supports DNF4’s API. Or rather, it *did* only support DNF4’s API.

Neal has been working with the both the DNF and PackageKit teams to make this work seamlessly. To that end, he [developed](https://github.com/PackageKit/PackageKit/pull/931) a DNF5-based backend for PackageKit, allowing GUI software managers to take advantage of this new feature. This will be [integrated](https://fedoraproject.org/wiki/Changes/PackageKit-DNF5) in Fedora Linux 44, however we will also be shipping it in the upcoming Fedora Asahi Remix 43.

The automated transition to upstream packages will begin with Mesa and virglrenderer in Fedora Asahi Remix 44.

## More conferences

Sven, chaos\_princess, Neal and Davide met up at FOSDEM in Belgium last month to discuss strategies for supporting M3 and M4, and to try their luck at nerd sniping folks into helping out. Additionally, both Neal and Davide will once again be at at [SCaLE](https://www.socallinuxexpo.org/scale/23x) next month. Davide will be hosting an Asahi demo system at Meta’s booth, so be sure to drop in if you’re attending!

## One more go around

2026 is starting off with some exciting progress, and we’re hoping to keep it coming. As ever we are extremely grateful to our supporters on [OpenCollective](https://opencollective.com/AsahiLinux) and [GitHub Sponsors](https://github.com/sponsors/AsahiLinux), without whom we would not have been able to sustain this effort through last year. Here’s to another 12 months of hacking!

---

1.  Display Coprocessor [↩︎](#fnref:1)
    
2.  Display Crossbar [↩︎](#fnref:2)
    
3.  Apple Type-C PHY [↩︎](#fnref:3)
    
4.  USB-C Power Delivery Controller [↩︎](#fnref:4)
    
5.  Apple Graphics Accelerator, the GPU on M-series SoCs [↩︎](#fnref:5)
    
6.  Apple Video Decoder, the AVC, HEVC, VP9, and AV1 hardware video decoder on M-series SoCs [↩︎](#fnref:6)
    

James Calligeros · 2026-02-15

 [![Asahi Linux logo](/img/AsahiLinux_logomark.svg)](/)Licensed under CC BY-SA 4.0 Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries. All other product names, logos, and brands are property of their respective owners. Kawaii Asahi Linux logo by [SAWARATSUKI](https://github.com/SAWARATSUKI/Logos) (see link for license).

-   [](https://social.treehouse.systems/@AsahiLinux)
-   [](https://bsky.app/profile/asahilinux.org)
-   [](https://www.linkedin.com/company/asahilinux/)
-   [](https://github.com/AsahiLinux)

-   [About](/about)
-   [Code of Conduct](/code-of-conduct)
-   [Copyright policy](/copyright)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://github.com/AsahiLinux/linux/issues/571",
  "format": "markdown",
  "timeout": 60
}
```

**Output:**
```
                                                                                                                                                                        \[fairydust\] M2 Air: DP Alt Mode link repeatedly bounces with VIA Labs hub adapter (PS186); stable with UGREEN CM478 · Issue #571 · AsahiLinux/linux · GitHub                                              

[Skip to content](#start-of-content)    

           

## Navigation Menu

[](/)

[Sign in](/login?return_to=https%3A%2F%2Fgithub.com%2FAsahiLinux%2Flinux%2Fissues%2F571)

Appearance settings

-   Platform
    
    -   AI CODE CREATION
        
        -   [GitHub CopilotWrite better code with AI](https://github.com/features/copilot)
        -   [GitHub Copilot appDirect agents from issue to merge](https://github.com/features/ai/github-app)
        -   [MCP RegistryIntegrate external tools](https://github.com/mcp)
        
    -   DEVELOPER WORKFLOWS
        
        -   [ActionsAutomate any workflow](https://github.com/features/actions)
        -   [CodespacesInstant dev environments](https://github.com/features/codespaces)
        -   [IssuesPlan and track work](https://github.com/features/issues)
        -   [Code ReviewManage code changes](https://github.com/features/code-review)
        -   [Code QualityEnforce quality at merge](https://github.com/features/code-quality)
        
    -   APPLICATION SECURITY
        
        -   [GitHub Advanced SecurityFind and fix vulnerabilities](https://github.com/security/advanced-security)
        -   [Code securitySecure your code as you build](https://github.com/security/advanced-security/code-security)
        -   [Secret protectionStop leaks before they start](https://github.com/security/advanced-security/secret-protection)
        
    -   EXPLORE
        
        -   [Why GitHub](https://github.com/why-github)
        -   [Documentation](https://docs.github.com)
        -   [Blog](https://github.blog)
        -   [Changelog](https://github.blog/changelog)
        -   [Marketplace](https://github.com/marketplace)
        
    
    [View all features](https://github.com/features)
    
-   Solutions
    
    -   BY COMPANY SIZE
        
        -   [Enterprises](https://github.com/enterprise)
        -   [Small and medium teams](https://github.com/team)
        -   [Startups](https://github.com/enterprise/startups)
        -   [Nonprofits](https://github.com/solutions/industry/nonprofits)
        
    -   BY USE CASE
        
        -   [App Modernization](https://github.com/solutions/use-case/app-modernization)
        -   [DevSecOps](https://github.com/solutions/use-case/devsecops)
        -   [DevOps](https://github.com/solutions/use-case/devops)
        -   [CI/CD](https://github.com/solutions/use-case/ci-cd)
        -   [View all use cases](https://github.com/solutions/use-case)
        
    -   BY INDUSTRY
        
        -   [Healthcare](https://github.com/solutions/industry/healthcare)
        -   [Financial services](https://github.com/solutions/industry/financial-services)
        -   [Manufacturing](https://github.com/solutions/industry/manufacturing)
        -   [Government](https://github.com/solutions/industry/government)
        -   [View all industries](https://github.com/solutions/industry)
        
    
    [View all solutions](https://github.com/solutions)
    
-   Resources
    
    -   EXPLORE BY TOPIC
        
        -   [AI](https://github.com/resources/articles?topic=ai)
        -   [Software Development](https://github.com/resources/articles?topic=software-development)
        -   [DevOps](https://github.com/resources/articles?topic=devops)
        -   [Security](https://github.com/resources/articles?topic=security)
        -   [View all topics](https://github.com/resources/articles)
        
    -   EXPLORE BY TYPE
        
        -   [Customer stories](https://github.com/customer-stories)
        -   [Events & webinars](https://github.com/resources/events)
        -   [Ebooks & reports](https://github.com/resources/whitepapers)
        -   [Business insights](https://github.com/solutions/executive-insights)
        -   [GitHub Skills](https://skills.github.com)
        
    -   SUPPORT & SERVICES
        
        -   [Documentation](https://docs.github.com)
        -   [Customer support](https://support.github.com)
        -   [Community forum](https://github.com/orgs/community/discussions)
        -   [Trust center](https://github.com/trust-center)
        -   [Partners](https://github.com/partners)
        
    
    [View all resources](https://github.com/resources)
    
-   Open Source
    
    -   COMMUNITY
        
        -   [GitHub SponsorsFund open source developers](https://github.com/open-source/sponsors)
        
    -   PROGRAMS
        
        -   [Security Lab](https://securitylab.github.com)
        -   [Maintainer Community](https://maintainers.github.com)
        -   [GitHub Stars](https://stars.github.com)
        -   [Archive Program](https://archiveprogram.github.com)
        
    -   REPOSITORIES
        
        -   [Topics](https://github.com/topics)
        -   [Trending](https://github.com/trending)
        -   [Collections](https://github.com/collections)
        
    
-   Enterprise
    
    -   ENTERPRISE SOLUTIONS
        
        -   [Enterprise platformAI-powered developer platform](https://github.com/enterprise)
        
    -   AVAILABLE ADD-ONS
        
        -   [GitHub Advanced SecurityEnterprise-grade security features](https://github.com/security/advanced-security)
        -   [Copilot for BusinessEnterprise-grade AI features](https://github.com/features/copilot/copilot-business)
        -   [Premium SupportEnterprise-grade 24/7 support](https://github.com/enterprise/premium-support)
        
    
-   [Pricing](https://github.com/pricing)

Search/

[Sign in](/login?return_to=https%3A%2F%2Fgithub.com%2FAsahiLinux%2Flinux%2Fissues%2F571)

[Sign up](/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fvoltron%2Fissues_fragments%2Fissue_layout&source=header-repo&source_repo=AsahiLinux%2Flinux)

Appearance settings

You signed in with another tab or window. Reload to refresh your session. You signed out in another tab or window. Reload to refresh your session. You switched accounts on another tab or window. Reload to refresh your session. Dismiss alert

### Uh oh!

There was an error while loading. Please reload this page.

[AsahiLinux](/AsahiLinux) / **[linux](/AsahiLinux/linux)** Public

forked from [torvalds/linux](/torvalds/linux)

-   [Notifications](/login?return_to=%2FAsahiLinux%2Flinux) You must be signed in to change notification settings
-   [Fork 203](/login?return_to=%2FAsahiLinux%2Flinux)
-   [Star 3k](/login?return_to=%2FAsahiLinux%2Flinux)
    

-   [Code](/AsahiLinux/linux)
-   [Issues 124](/AsahiLinux/linux/issues)
-   [Pull requests 22](/AsahiLinux/linux/pulls)
-   [Actions](/AsahiLinux/linux/actions)
-   [Security and quality 0](/AsahiLinux/linux/security)
-   [Insights](/AsahiLinux/linux/pulse)

Additional navigation options

-   [Code](/AsahiLinux/linux)
-   [Issues](/AsahiLinux/linux/issues)
-   [Pull requests](/AsahiLinux/linux/pulls)
-   [Actions](/AsahiLinux/linux/actions)
-   [Security and quality](/AsahiLinux/linux/security)
-   [Insights](/AsahiLinux/linux/pulse)

# \[fairydust\] M2 Air: DP Alt Mode link repeatedly bounces with VIA Labs hub adapter (PS186); stable with UGREEN CM478 #571

New issue

Copy link

New issue

Copy link

Open

Open

[\[fairydust\] M2 Air: DP Alt Mode link repeatedly bounces with VIA Labs hub adapter (PS186); stable with UGREEN CM478](/AsahiLinux/linux/issues/571#top)#571

Copy link

## Description

[![@Hegghammer](https://avatars.githubusercontent.com/u/64712218?u=07f43849f1b66b70e98534f3ef25b1f4e802dc7e&v=4&size=48)](https://github.com/Hegghammer)

[Hegghammer](https://github.com/Hegghammer)

opened [on Aug 18, 2026](https://github.com/AsahiLinux/linux/issues/571#issue-5186526909)

Issue body actions

# fairydust: DP Alt Mode link repeatedly bounces with VIA Labs hub adapter (PS186); stable with simple adapter — M2 MacBook Air

## Hardware / software

-   **Machine:** Apple MacBook Air (13-inch, M2, 2022) — apple,j413 / t8112
-   **Distro:** Fedora Asahi Remix 42, i3 on X11
-   **Kernel:** `fairydust` branch, self-built, `uname -r` = `7.1.6+` (`CONFIG_DRM_ASAHI=m`, `CONFIG_TYPEC_DP_ALTMODE=m`, 16K pages)
-   **Monitor:** Philips 27E2N1500L, 2560x1440@60, connected via HDMI
-   **Failing adapter:** USB-C multiport hub — VIA Labs VL817-family (USB2 hub `2109:2817`, USB3 hub `2109:0817`, billboard `2109:0103`); DCP matches `AppleDCPPS186` (Parade DP→HDMI)
-   **Working adapter:** Ugreen CM478

## Summary

With the VIA Labs hub adapter, the DP link trains successfully — HPD asserts, full 256-byte EDID is read, 28 modes enumerated — but then drops within seconds and re-trains in a continuous bounce cycle. A modeset attempted during a bounce leaves X half-configured (virtual screen resized, output never activated). With a simple single-purpose USB-C→HDMI adapter on the same port, cable, and monitor, the link is stable and external output works at 2560x1440@60.

## Behaviour with the failing adapter

Repeating cycle, observed at multiple uptimes (708s, 760s, 1553s...):

1.  `dcp_dptx_connect(port=0)` → `powering nub` → `DCPDP13Service`/`DCPDPService` version 14 → `AppleDCPDP2HDMI matched` → `AppleDCPPS186 matched`
2.  HPD asserted, `cb_hotplug() connected:1`, `nr_modes:28`, EDID readable from sysfs (256 bytes)
3.  Within ~2–60 s: `HPD removed` → `cb_hotplug() connected:0` → `dcp_dptx_disconnect(port=0)`
4.  Loop.

Each cycle also logs:

```
apple-dcp 271c00000.dcp: AFK[ep:28]: too many enabled services!
apple-dcp 271c00000.dcp: AFK[ep:28]: too many enabled services!
apple-dcp 271c00000.dcp: AFK[ep:28]: expected announce but got 0xc0 on channel <n>
apple-dcp 271c00000.dcp: DPTXPort: acking unhandled call 20
apple-dcp 271c00000.dcp: DPTXPort: acking unhandled call 21
apple-dcp 271c00000.dcp: set_drive_settings: 2:0:1089342832:-1:0:0:0
```

The `too many enabled services!` pair repeats on every reconnect, which may be an endpoint/service leak across bounce cycles.

Example excerpt of one bounce (modeset issued at ~1552, link dropped ~2 s later):

```
[ 1552.176526] apple-dcp 271c00000.dcp: cb_hotplug() connected:1, valid_mode:1
[ 1552.176539] apple-dcp 271c00000.dcp: dcp_hotplug() connected:1 valid_mode:0 nr_modes:28
[ 1553.998528] ... VideoInterfaceIOAV::unplug_gated(...): display HPD removed
[ 1553.999227] apple-dcp 271c00000.dcp: cb_hotplug() connected:0, valid_mode:0
[ 1554.011892] apple-dcp 271c00000.dcp: dcp_dptx_disconnect(port=0)
[ 1555.510421] apple-dcp 271c00000.dcp: dcp_dptx_connect(port=0)
```

Userspace side effect: `xrandr --output DP-1 --mode 1920x1080` during a bounce shrank the X virtual screen to 1920x1080 (cropping the 2560x1600 eDP panel) while DP-1 was never activated (no `*` mode). Recoverable with `xrandr --output eDP-1 --auto --pos 0x0`.

## Behaviour with the working adapter

Same port, cable, and monitor. Connect sequence completes identically, then the link stays up (no disconnects over 30+ s idle and through modesets). `xrandr --output DP-1 --mode 2560x1440 --rate 60` works; external display fully functional.

## Steps to reproduce

1.  Boot fairydust kernel with `typec_displayport` loaded, VIA Labs adapter connected.
2.  Observe `dmesg -w`: connect sequence completes (HPD asserted, EDID read, 28 modes), then HPD drops within seconds and the cycle repeats indefinitely.
3.  Swap to the UGREEN CM478 on the same port, cable, and monitor: link stays up and `xrandr --output DP-1 --mode 2560x1440 --rate 60` works.

## Attached logs

-   **`dp-dmesg.log`** — failing adapter (VIA Labs/PS186): full bounce cycle, including the repeated `too many enabled services!` / `expected announce` lines on each reconnect.
-   **`dp-test.log`** — xrandr and connector status captured around a modeset attempted during a bounce, showing the half-applied result: X virtual screen resized to 1920x1080 (cropping the 2560x1600 eDP panel) while DP-1 was never activated.
-   **`dp2-working-session.log`** — working adapter (UGREEN CM478): identical connect sequence, then a stable link through successful modesets at 1920x1080 and 2560x1440, no disconnects.

## Notes

-   Cold plug vs hot plug made no difference for the failing adapter; both bounce.
-   The X cropping is recoverable with `xrandr --output eDP-1 --auto --pos 0x0`.
-   Happy to provide full dmesg from boot, an EDID dump of the Philips panel, Type-C identity sysfs state, or to test patches on this hardware.

[dp-dmesg.log](https://github.com/user-attachments/files/31198931/dp-dmesg.log)

[dp-test.log](https://github.com/user-attachments/files/31198943/dp-test.log)

[dp2-working-session.log](https://github.com/user-attachments/files/31198948/dp2-working-session.log)

Reactions are currently unavailable

## Activity

[Sign up for free](/signup?return_to=https://github.com/AsahiLinux/linux/issues/571) **to join this conversation on GitHub.** Already have an account? [Sign in to comment](/login?return_to=https://github.com/AsahiLinux/linux/issues/571)

## Metadata

## Metadata

### Assignees

No one assigned

### Labels

No labels

No labels

### Type

No type

### Projects

No projects

### Milestone

No milestone

### Relationships

None yet

### Development

No branches or pull requests

## Issue actions

-   ![](https://github.githubassets.com/assets/github-copilot-app-light-15ad5534265eeacd.svg)Open in GitHub Copilot app

## Footer

[](https://github.com)© 2026 GitHub, Inc.

### Footer navigation

-   [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
-   [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
-   [Security](https://github.com/security)
-   [Status](https://www.githubstatus.com/)
-   [Community](https://github.community/)
-   [Docs](https://docs.github.com/)
-   [Contact](https://support.github.com?tags=dotcom-footer)
-   Manage cookies
-   Do not share my personal information

You can’t perform that action at this time.
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/ivy/nix/justfile",
  "offset": 1,
  "limit": 140
}
```

**Output:**
```
<path>/home/ivy/nix/justfile</path>
<type>file</type>
<content>
1: default:
2:     @just --list
3: 
4: fmt:
5:     nix fmt
6: 
7: check:
8:     nix flake check
9: 
10: build:
11:     nh os build .
12: 
13: switch:
14:     nh os switch .
15: 
16: update:
17:     nix flake update
18: 
19: sync-noctalia:
20:     noctalia config export > ./home/desktop/noctalia/noctalia.toml

(End of file - total 20 lines)
</content>
```

---

## Assistant (Build · GPT-6 Astra · 13.2s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "gh api 'repos/AsahiLinux/linux/commits?sha=ce9f2eba72c061a50b2d790450e90af3439d8c24&path=drivers/gpu/drm/apple/dptxep.c&per_page=20' --jq '.[] | {sha: .sha, date: .commit.author.date, message: .commit.message}'",
  "timeout": 120000,
  "workdir": "/home/ivy/nix",
  "description": "Inspect pinned DPTX implementation commit history"
}
```

**Output:**
```
{"date":"2026-07-15T10:41:20Z","message":"fixup! drm: apple: dptx: Fix get_drive_settings retcode\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"fc8538e1bb7408c6b70c62a20f20938ba09b695c"}
{"date":"2026-07-15T10:39:16Z","message":"fixup! drm: apple: dptxep: Implement drive settings stuff\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"90c9f91b25f4cff4fec56c2870b0d7d243f20fb1"}
{"date":"2025-12-21T19:14:16Z","message":"drm: apple: Use typec mux to switch atc-phy into DP\n\nThe upstream atc phy driver has no longer special handling for the phy\nonly use case on 14/16-inch Macbook Pros. So simply let dcp handle this\nand switch the type-c mux to full 4 lane DisplayPort mode.\nThis requires devicetree changes in the form of a graph based connection\nbetween dcpext0 and atc-phy.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"743d498c621c6837b1d0fd65e590be6f0cbddc3c"}
{"date":"2025-01-21T22:35:27Z","message":"drm: apple: dptx: Configure number of lanes for dptx-phy\n\nConfiguring the number of lanes is required for M2* desktop devices\neither if those were not initialized by m1n1 or after hotplug.\n\nFixes: 07e4bfb1599bc (\"drm: apple: dptx: Tidy up lane count handling\")\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"fd1ca0b128d9c68d03fd35e71ee9aca4df5985e5"}
{"date":"2025-01-21T19:20:20Z","message":"drm: apple: dptx: Rework/document get_max_lane_count()\n\nphy_validate() on the DP only ATC phy returns 0 lanes if it happens\nbefore the phy_set_mode(PHY_MODE_DP). Since this is the only known case\ndefault to 4 lanes as the phy is used exclusively for DP.\n\nFixes: https://github.com/AsahiLinux/linux/issues/367\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"00b8d01492d686b7316e12ed02c998d3caa687ba"}
{"date":"2025-01-16T22:23:15Z","message":"drm: apple: dptx: Tidy up lane count handling\n\nDo not try to configure the DP phy's lane count as this is configured by\ncd321x via the USB type-c mux.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"204734cbaf6d5a587afff1ef85f0561bb971280e"}
{"date":"2025-01-16T22:29:40Z","message":"drm: apple: dptx: Silence DPTX_APCALL_{GET,SET}_DOWN_SPREAD\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"4631f5a71d38f34f91c174185035381f6e19c6aa"}
{"date":"2024-06-09T20:01:59Z","message":"drm: apple: dptxport: get_max_lane_count: Retrieve lane count from phy\n\nThis unfortunately doesn't work relieably with typec-altmode-displayport\nsince the oob hotplug notification arrives before atc-phy is configured\nto the appropiate DP mode.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"0ce15de0289e90b3d2e41c907c3c0c11d768e36f"}
{"date":"2024-06-09T19:49:43Z","message":"drm: apple: dptx: Fix get_drive_settings retcode\n\nThis appears to be lane count as \"2\" is observed for USB-C DP alt mode\nin shared DP/USB3 mode.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"f390525e7ac6f2e3a895ca245cf3504618b1b5a2"}
{"date":"2023-12-03T22:57:25Z","message":"drm: apple: dptx: Wait for link config on connect\n\nShould make connect more reliable by avoiding hardcoded waits which are\neither to long or too short. In the second case the display can't be\nbrought up since dcp fails to report any modes during start.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"d14c6535b6aa07df8cb66e0b167b192813a2aca1"}
{"date":"2023-11-21T22:32:07Z","message":"drm: apple: dptx: Wait for completion of dptx_connect.\n\nMakes connects more reliable.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"335528f431c26e3fd9ee0b99ea8d1e51082d7a06"}
{"date":"2023-11-20T21:48:02Z","message":"drm: apple: dptx: Implement APCALL_DEACTIVATE and reset the phy\n\nThis mirrors what macOS does and should make reconnections more\nreliable.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"ce8f775e7e73deadc43fbbc929490e021bd8d649"}
{"date":"2023-11-16T15:03:51Z","message":"drm: apple: dptxep: Implement drive settings stuff\n\nJust in case, for consistency with macOS.\n\nSigned-off-by: Hector Martin \u003cmarcan@marcan.st\u003e","sha":"5c6ae6268ac0e6ef27e765e859397bc9d2b58199"}
{"date":"2023-11-16T15:03:36Z","message":"drm: apple: dptxep: Fix reply size check\n\nSigned-off-by: Hector Martin \u003cmarcan@marcan.st\u003e","sha":"3143affaa83d7570dd88d5a51efcd77122f48f94"}
{"date":"2023-11-06T22:44:08Z","message":"drm: apple: dptx: Adapt dptxport_connect() to observed behavior\n\nAdapt to behavior seen on j474s with dcp0 driving lpdptx-phy and\ndp2hdmi using the macOS 13.5 firmware.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"ef43adabc63f48f48252b0bbf08b182493368cbf"}
{"date":"2023-11-06T22:37:27Z","message":"drm: apple: dptx: Add DPTX_APCALL_ACTIVATE\n\nConfigures the phy to the correct dcp(ext) source by abusing submode in\nthe phy_set_mode_ext() call.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"c40cabea8daee06abf599ce4143c9177623d874c"}
{"date":"2023-11-06T22:36:20Z","message":"drm: apple: dptx: Add set_active_lanes APCALL\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"def49724fc038b5bca70aa7fa26511161e14393c"}
{"date":"2023-08-17T22:05:15Z","message":"drm: apple: dptx: port interface to macOS 13.5 firmware\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"d4f061da2053bfc08c59362014772cf8af7cb8af"}
{"date":"2023-04-28T20:24:59Z","message":"drm: apple: dptx: Port APCALL to macOS 13.3 firmware\n\nThe 13.3 firmware has an additional get_max_lane_count call inserted\nwith ID 10.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"5d3ac16a182cb2982b17bc285eadce82579e23ad"}
{"date":"2022-11-05T12:15:34Z","message":"drm: apple: Add DPTX support\n\nThis is required for DP Altmode, DP Thunderbolt tunneling and HDMI\noutput on 14/16-inch Macbook Pros and M2* desktop devices.\n\nM2* desktops and 14 and 16 inch Macbook Pros expose a DisplayPort to\nHDMI converter which is driven by the DP output of one of the DCP/DCPext\ndisplay coprocessor/controller blocks.\nTwo gpio pins are used for power control. Another gpio pin acts as HDMI\nhpd.\nDo not use the hpd as direct drm_connector interrupt since that is\nalready wired to DCPs hotplug notification. Instead use it to trigger\nlink setup via the dptx endpoint.\n\nSigned-off-by: Sven Peter \u003csven@svenpeter.dev\u003e\nCo-developed-by: Janne Grunau \u003cj@jannau.net\u003e\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"4c8a6375f79b53c6c77e188435bbacd4e24120c4"}

```

**Tool: bash**

**Input:**
```json
{
  "command": "gh api 'repos/AsahiLinux/linux/commits?sha=ce9f2eba72c061a50b2d790450e90af3439d8c24&path=drivers/usb/typec/tipd/core.c&per_page=10' --jq '.[] | {sha: .sha, date: .commit.author.date, message: .commit.message}'",
  "timeout": 120000,
  "workdir": "/home/ivy/nix",
  "description": "Inspect Type-C routing changes at pinned revision"
}
```

**Output:**
```
{"date":"2025-12-22T21:08:35Z","message":"usb: typec: tipd: HACK: Use drm oob hotplug event\n\nThis is not how dp-altmode support should be implemented but it works\nfor new. Requires a \"displayport\" property in the connector node with a\nphandle of the connector.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"9c16792154f8454ccbc6a28309d57d531ced015a"}
{"date":"2025-09-10T22:01:39Z","message":"usb: typec: tipd: Track data_status changes for CD321x\n\nHDP status for DisplayPort alt-mode is signaled data_status. Track\nchanges to have a debounced HPD to forward to the DRM KMS driver.\n\nSigned-off-by: Janne Grunau \u003cj@jannau.net\u003e","sha":"296c91ac1fa51a21117524561cd77eaf0c7fe62a"}
{"date":"2026-08-01T21:30:12Z","message":"usb: typec: tipd: Add sn201202x support\n\nAdd support for sn201202x (aka ACE3), a tipd variant that uses a very\nsimilar register map, that is exposed over a \"logical register\"\ninterface on the SPMI bus.\n\nCo-developed-by: Alyssa Milburn \u003camilburn@zall.org\u003e\nSigned-off-by: Alyssa Milburn \u003camilburn@zall.org\u003e\nSigned-off-by: Sasha Finkelstein \u003ck@chaosmail.tech\u003e","sha":"550afd1aa62bb43183aad36aca4ba97580858dbe"}
{"date":"2026-08-01T21:30:11Z","message":"usb: typec: tipd: Factor out i2c specifics\n\nMake the core driver more bus-agnostic to prepare for SPMI variants of\nthe tipd chip\n\nSigned-off-by: Alyssa Milburn \u003camilburn@zall.org\u003e\nSigned-off-by: Sasha Finkelstein \u003ck@chaosmail.tech\u003e","sha":"da16cc966d153550b2fc99e207ccc95cf32d5e31"}
{"date":"2026-05-12T10:14:59Z","message":"usb: typec: tipd: Fix error code in tps6598x_probe()\n\nSet the error code on these two error paths.  The existing code returns\nsuccess.\n\nFixes: 77ed2f4538da (\"usb: typec: tipd: Use read_power_status function in probe\")\nFixes: 04041fd7d6ec (\"usb: typec: tipd: Read data status in probe and cache its value\")\nCc: stable \u003cstable@kernel.org\u003e\nSigned-off-by: Dan Carpenter \u003cerror27@gmail.com\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nLink: https://patch.msgid.link/agL9o7wUK1dOVBTy@stanley.mountain\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"b02900c85a6423cf9b3dcc6b47bf060c85075e69"}
{"date":"2026-02-18T21:46:21Z","message":"usb: typec: Fix error pointer dereference\n\nThe variable tps-\u003epartner is checked for an error pointer and then if it\nis, it sends an error message but does not return and then immediately\ndereferenced a few lines below:\n\ntps-\u003epartner = typec_register_partner(tps-\u003eport, \u0026desc);\nif (IS_ERR(tps-\u003epartner))\n\tdev_warn(tps-\u003edev, \"%s: failed to register partnet\\n\", __func__);\n\nif (desc.identity) {\n\ttypec_partner_set_identity(tps-\u003epartner);\n\tcd321x-\u003ecur_partner_identity = st.partner_identity;\n}\n\nAdd early return and fix spelling mistake in error message.\n\nDetected by Smatch:\ndrivers/usb/typec/tipd/core.c:827 cd321x_update_work() error:\n'tps-\u003epartner' dereferencing possible ERR_PTR()\n\nFixes: 82432bbfb9e83 (\"usb: typec: tipd: Handle mode transitions for CD321x\")\nSigned-off-by: Ethan Tidmore \u003cethantidmore06@gmail.com\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nLink: https://patch.msgid.link/20260218214621.38154-1-ethantidmore06@gmail.com\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"f2529d08fcb429ea01bb87c326342f41483f8b2f"}
{"date":"2025-11-07T15:13:10Z","message":"usb: typec: tipd: mark as orientation aware\n\nThe driver contains orientation detection logic and correctly calls\ntypec_set_orientation(), but forgets to set the orientation_aware\ncapability, so the orientation value is not visible in sysfs - Fix that.\n\nSigned-off-by: Peter Korsgaard \u003cpeter@korsgaard.com\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nLink: https://patch.msgid.link/20251107151311.2089806-1-peter@korsgaard.com\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"66371878dfe3376a55cb44bc0918a56232522590"}
{"date":"2025-09-20T12:28:03Z","message":"usb: typec: tipd: Fix error handling in cd321x_read_data_status\n\nRight now cd321x_read_data_status always returns true even if it\nencounters any errors: tps6598x_read_data_status returns a boolean but\nwe treated it as an errno and then we have a bunch of dev_errs in case\ntps6598x_block_read fails but just continue along and return true.\nFix that to correctly report errors to the callee.\n\nReported-by: Dan Carpenter \u003cdan.carpenter@linaro.org\u003e\nCloses: https://lore.kernel.org/linux-usb/aMvWJo3IkClmFoAA@stanley.mountain/\nSigned-off-by: Sven Peter \u003csven@kernel.org\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nLink: https://lore.kernel.org/r/20250920-tipd-fix-v1-1-49886d4f081d@kernel.org\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"1c1b2a247c384179fcc97b63bb0c17e112217d7a"}
{"date":"2025-09-14T12:56:16Z","message":"usb: typec: tipd: Handle mode transitions for CD321x\n\nOn Apple Silicon machines there is no control over which alt mode is\nchosen. The CD321x' firmware negotiates the target mode on its own and\nonly lets the main CPU know after the mode has already been chosen.\nEspecially after plugging a new cable in this can result to quick mode\nchanges from e.g. power only -\u003e USB3 only -\u003e USB3+DisplayPort in a short\ntime. It is not possile to influence this in any way and we also do not\nget direct access to the PDOs or VDOs exchanged via USB PD.\n\nAdditionally, mode changes must be tightly synchronized between DWC3 and\nthe Type C PHY and most mode changes require a full reset of DWC3 to\nmake the port work correctly.\nThis is all done synchronously from the role switch handler inside the\nDWC3 glue driver on these machines to avoid tripping any failsafes or\nwatchdogs inside the Type-C PHY that may, in the worst case, reset the\nentire SoC.\n\nTo be able to control all this we trigger the entire process in the\ncorrect order directly from the TIPD driver and de-bounce any mode\nchanges to avoid tearing down and re-setting DWC3 back up multiple times\nany time a new connection is made.\n\nSigned-off-by: Hector Martin \u003cmarcan@marcan.st\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nReviewed-by: Neal Gompa \u003cneal@gompa.dev\u003e\nCo-developed-by: Sven Peter \u003csven@kernel.org\u003e\nSigned-off-by: Sven Peter \u003csven@kernel.org\u003e\nReviewed-by: Janne Grunau \u003cj@jannau.net\u003e\nLink: https://lore.kernel.org/r/20250914-apple-usb3-tipd-v1-11-4e99c8649024@kernel.org\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"82432bbfb9e83b7e81d04660fe129b99a29b2ac2"}
{"date":"2025-09-14T12:56:15Z","message":"usb: typec: tipd: Read data status in probe and cache its value\n\nJust like for power status we also need to keep track of data status to\nbe able to detect mode changes once we introduce de-bouncing for CD321x.\nRead it during probe and keep a cached copy of its value.\n\nSigned-off-by: Hector Martin \u003cmarcan@marcan.st\u003e\nReviewed-by: Heikki Krogerus \u003cheikki.krogerus@linux.intel.com\u003e\nReviewed-by: Neal Gompa \u003cneal@gompa.dev\u003e\nSigned-off-by: Sven Peter \u003csven@kernel.org\u003e\nLink: https://lore.kernel.org/r/20250914-apple-usb3-tipd-v1-10-4e99c8649024@kernel.org\nSigned-off-by: Greg Kroah-Hartman \u003cgregkh@linuxfoundation.org\u003e","sha":"04041fd7d6ec0bc5c4277711e17b43ffb45e30ba"}

```

**Tool: websearch**

**Input:**
```json
{
  "query": "site:lore.kernel.org/asahi DPTX fairydust \"2026\"",
  "numResults": 5,
  "livecrawl": "preferred",
  "type": "auto",
  "contextMaxCharacters": 6000
}
```

**Output:**
```
{
  "search_id": "search_fb1ff6dac120c09992d71fb4d3ab55d3",
  "results": [],
  "warnings": null,
  "metadata": null,
  "session_id": "ses_f6016ac8cffe1Kzt8Htz20feFl"
}
```

**Tool: grep**

**Input:**
```json
{
  "pattern": "nr_modes|dptx_phy|dptx_die",
  "path": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp-internal.h",
  "include": "*"
}
```

**Output:**
```
Found 3 matches
/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/dcp-internal.h:
  Line 210: 	unsigned int nr_modes;

  Line 266: 	u32 dptx_phy;

  Line 267: 	u32 dptx_die;

```

**Tool: read**

**Input:**
```json
{
  "filePath": "/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb.c",
  "offset": 227,
  "limit": 190
}
```

**Output:**
```
<path>/nix/store/7y3r5zmv4la3ljw11bp6kznlrk3f4aya-source/drivers/gpu/drm/apple/iomfb.c</path>
<type>file</type>
<content>
227: /*
228:  * Helper to send a DRM hotplug event. The DCP is accessed from a single
229:  * (RTKit) thread. To handle hotplug callbacks, we need to call
230:  * drm_kms_helper_hotplug_event, which does an atomic commit (via DCP) and
231:  * waits for vblank (a DCP callback). That means we deadlock if we call from
232:  * the RTKit thread! Instead, move the call to another thread via a workqueue.
233:  */
234: void dcp_hotplug(struct work_struct *work)
235: {
236: 	struct apple_connector *connector;
237: 	struct apple_dcp *dcp;
238: 
239: 	connector = container_of(work, struct apple_connector, hotplug_wq);
240: 
241: 	dcp = platform_get_drvdata(connector->dcp);
242: 	dev_info(dcp->dev, "%s() connected:%d valid_mode:%d nr_modes:%u\n", __func__,
243: 		 connector->connected, dcp->valid_mode, dcp->nr_modes);
244: 
245: 	if (!connector->connected) {
246: 		drm_edid_free(connector->drm_edid);
247: 		connector->drm_edid = NULL;
248: 	}
249: 
250: 	/*
251: 	 * DCP defers link training until we set a display mode. But we set
252: 	 * display modes from atomic_flush, so userspace needs to trigger a
253: 	 * flush, or the CRTC gets no signal.
254: 	 */
255: 	if (connector->base.state && !dcp->valid_mode && connector->connected)
256: 		drm_connector_set_link_status_property(&connector->base,
257: 						       DRM_MODE_LINK_STATUS_BAD);
258: 
259: 	drm_kms_helper_connector_hotplug_event(&connector->base);
260: }
261: 
262: static void dcpep_handle_cb(struct apple_dcp *dcp, enum dcp_context_id context,
263: 			    void *data, u32 length, u16 offset)
264: {
265: 	struct device *dev = dcp->dev;
266: 	struct dcp_packet_header *hdr = data;
267: 	void *in, *out;
268: 	int tag = dcp_parse_tag(hdr->tag);
269: 	struct dcp_channel *ch = dcp_get_channel(dcp, context);
270: 	u8 depth;
271: 
272: 	if (tag < 0 || tag >= IOMFB_MAX_CB || !dcp->cb_handlers || !dcp->cb_handlers[tag]) {
273: 		dev_warn(dev, "received unknown callback %c%c%c%c\n",
274: 			 hdr->tag[3], hdr->tag[2], hdr->tag[1], hdr->tag[0]);
275: 		return;
276: 	}
277: 
278: 	in = data + sizeof(*hdr);
279: 	out = in + hdr->in_len;
280: 
281: 	// TODO: verify that in_len and out_len match our prototypes
282: 	// for now just clear the out data to have at least consistent results
283: 	if (hdr->out_len)
284: 		memset(out, 0, hdr->out_len);
285: 
286: 	depth = dcp_push_depth(&ch->depth);
287: 	ch->output[depth] = out;
288: 	ch->end[depth] = offset + ALIGN(length, DCP_PACKET_ALIGNMENT);
289: 
290: 	if (dcp->cb_handlers[tag](dcp, tag, out, in))
291: 		dcp_ack(dcp, context);
292: }
293: 
294: static void dcpep_handle_ack(struct apple_dcp *dcp, enum dcp_context_id context,
295: 			     void *data, u32 length)
296: {
297: 	struct dcp_packet_header *header = data;
298: 	struct dcp_channel *ch = dcp_get_channel(dcp, context);
299: 	void *cookie;
300: 	dcp_callback_t cb;
301: 
302: 	if (!ch) {
303: 		dev_warn(dcp->dev, "ignoring ack on context %X\n", context);
304: 		return;
305: 	}
306: 
307: 	dcp_pop_depth(&ch->depth);
308: 
309: 	cb = ch->callbacks[ch->depth];
310: 	cookie = ch->cookies[ch->depth];
311: 
312: 	ch->callbacks[ch->depth] = NULL;
313: 	ch->cookies[ch->depth] = NULL;
314: 
315: 	if (cb)
316: 		cb(dcp, data + sizeof(*header) + header->in_len, cookie);
317: }
318: 
319: static void dcpep_got_msg(struct apple_dcp *dcp, u64 message)
320: {
321: 	enum dcp_context_id ctx_id;
322: 	u16 offset;
323: 	u32 length;
324: 	int channel_offset;
325: 	void *data;
326: 
327: 	ctx_id = FIELD_GET(IOMFB_MSG_CONTEXT, message);
328: 	offset = FIELD_GET(IOMFB_MSG_OFFSET, message);
329: 	length = FIELD_GET(IOMFB_MSG_LENGTH, message);
330: 
331: 	channel_offset = dcp_channel_offset(ctx_id);
332: 
333: 	if (channel_offset < 0) {
334: 		dev_warn(dcp->dev, "invalid context received %u\n", ctx_id);
335: 		return;
336: 	}
337: 
338: 	data = dcp->shmem + channel_offset + offset;
339: 
340: 	if (FIELD_GET(IOMFB_MSG_ACK, message))
341: 		dcpep_handle_ack(dcp, ctx_id, data, length);
342: 	else
343: 		dcpep_handle_cb(dcp, ctx_id, data, length, offset);
344: }
345: 
346: int dcp_get_modes(struct drm_connector *connector)
347: {
348: 	struct apple_connector *apple_connector = to_apple_connector(connector);
349: 	struct platform_device *pdev = apple_connector->dcp;
350: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
351: 
352: 	struct drm_device *dev = connector->dev;
353: 	struct drm_display_mode *mode;
354: 	int i;
355: 
356: 	for (i = 0; i < dcp->nr_modes; ++i) {
357: 		mode = drm_mode_duplicate(dev, &dcp->modes[i].mode);
358: 
359: 		if (!mode) {
360: 			dev_err(dev->dev, "Failed to duplicate display mode\n");
361: 			return 0;
362: 		}
363: 
364: 		drm_mode_probed_add(connector, mode);
365: 	}
366: 
367: 	if (dcp->nr_modes && dcp->dcpavserv.enabled &&
368: 	    !apple_connector->drm_edid) {
369: 		const struct drm_edid *edid;
370: 		edid = dcpavserv_copy_edid(dcp->dcpavserv.service);
371: 		if (IS_ERR_OR_NULL(edid)) {
372: 			dev_info(dcp->dev, "copy_edid failed: %pe\n", edid);
373: 		} else {
374: 			drm_edid_free(apple_connector->drm_edid);
375: 			apple_connector->drm_edid = edid;
376: 		}
377: 	}
378: 	if (dcp->nr_modes && apple_connector->drm_edid)
379: 		drm_edid_connector_update(connector, apple_connector->drm_edid);
380: 
381: 	return dcp->nr_modes;
382: }
383: 
384: /* The user may own drm_display_mode, so we need to search for our copy */
385: struct dcp_display_mode *lookup_mode(struct apple_dcp *dcp,
386: 					    const struct drm_display_mode *mode)
387: {
388: 	int i;
389: 
390: 	for (i = 0; i < dcp->nr_modes; ++i) {
391: 		if (drm_mode_match(mode, &dcp->modes[i].mode,
392: 				   DRM_MODE_MATCH_TIMINGS |
393: 					   DRM_MODE_MATCH_CLOCK))
394: 			return &dcp->modes[i];
395: 	}
396: 
397: 	return NULL;
398: }
399: 
400: enum drm_mode_status dcp_mode_valid(struct drm_connector *connector,
401: 				    const struct drm_display_mode *mode)
402: {
403: 	struct apple_connector *apple_connector = to_apple_connector(connector);
404: 	struct platform_device *pdev = apple_connector->dcp;
405: 	struct apple_dcp *dcp = platform_get_drvdata(pdev);
406: 
407: 	return lookup_mode(dcp, mode) ? MODE_OK : MODE_BAD;
408: }
409: 
410: int dcp_crtc_atomic_modeset(struct drm_crtc *crtc,
411: 			    struct drm_atomic_state *state)
412: {
413: 	struct apple_crtc *apple_crtc = to_apple_crtc(crtc);
414: 	struct apple_dcp *dcp = platform_get_drvdata(apple_crtc->dcp);
415: 	struct drm_crtc_state *crtc_state;
416: 	int ret = -EIO;

(Showing lines 227-416 of 558. Use offset=417 to continue.)
</content>
```

---

## Assistant (Build · GPT-6 Astra · 106.8s)

_Thinking:_



The commit history directly supports investigating connection ordering: an earlier DPTX change says short waits could leave DCP reporting no modes, and another documents hotplug arriving before PHY configuration. In your pinned tree, the two-second wait still checks for a negative return, although timeout returns zero.

The logging patch is ready and applies cleanly. It leaves the existing behavior intact so we can distinguish a failed mux operation, firmware call failure, missed lane

---

