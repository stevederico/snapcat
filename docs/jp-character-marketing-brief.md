# Japanese Product Character Marketing — Research Brief

**Date:** 2026-07-31  
**Scope:** How Japan sells products with cute characters (grocery, snacks, transit, regions) — and whether this window-snap app should rebrand into that style.  
**Outcome (later):** Product renamed **Snap Cat** (`stevederico/snapcat`); character is **Snapu**. Brief text below still uses the historical name HalfSnap where written.  
**Non-goals (at time of writing):** No rename, logo, or UI art shipped in this brief.

---

## 1. Core concepts

### Yuru-chara (ゆるキャラ / yuru-kyara)

“Loose / laid-back characters.” Coined by critic Jun Miura in the early 2000s. Usually promote a **place, event, org, or business**. Traits:

- **Kawaii but unsophisticated** — round, soft, often slightly awkward
- **Local motif baked into the body** (produce, castle, dialect pun)
- Often exist as **kigurumi** (full-body costumes) at events
- Miura’s classic rules: love for a hometown, unique/unstable movement, *yurui* (gentle, not slick)

They are **not** the same as polished corporate IPs (Hello Kitty, Rilakkuma), though the public lumps “cute mascots” together.

**Gotōchi-kyara (ご当地キャラ)** = “local characters” — the regional subset of yuru-chara (towns, prefectures, castle anniversaries).

### Kawaii / commercial cute

*Kawaii* is a broad aesthetic: big head, big eyes or simple eyes, soft shapes, low threat, high approachability. On **grocery packaging** it does three jobs:

1. **Shelf stop** — face beats plain typography at 2 meters  
2. **Trust / softens commodity** — mayo, milk candy, IC cards feel friendlier  
3. **Cross-age** — kids point; adults buy nostalgia and “giftability”

### Brand kyara (企業・商品キャラ) vs regional yuru-chara

| | **Regional yuru-chara** | **Brand / product kyara** |
|--|-------------------------|---------------------------|
| Owner | City, prefecture, tourism board | Company or product line |
| Job | Tourism, local pride, merch GDP | Package recognition, loyalty, category ownership |
| Design | Often amateurish on purpose; local puns | Usually tighter, long-lived, on every SKU |
| Money | Free licensing (e.g. Kumamon) + events + souvenirs | Packaging, ads, collabs, Pensta-style shops |
| Failure mode | Too many mascots dilute a region | Character outlives product or feels “kids only” |

HalfSnap would be closer to **brand kyara** (product-owned) with **yuru-chara aesthetics** (loose, friendly, one job), not a prefecture mascot.

---

## 2. Named examples (with design / marketing traits)

### A. Regional / product tourism yuru-chara

#### Kumamon (くまモン) — Kumamoto Prefecture

- Black bear with wide white eyes; name puns *kuma* (bear) + *mon* (person) + “Kumamoto.”
- **Why it works:** silhouette reads at pin size; free commercial license if goods promote Kumamoto → viral merch economy (Bank of Japan–cited tourism/product lift in the billions of yen era post-2011).
- **Trait for packaging/apps:** **one color block + two dots for eyes** beats complex illustration when the face is the brand.

#### Hikonyan (ひこにゃん) — Hikone Castle / city

- Samurai-helmeted white cat; created for the castle’s 400th anniversary (2007).
- **Why it works:** credited with kicking off the modern **yuru-chara boom** — history + cat = tourism + plush.
- **Trait:** **costume-ready** (big head, simple limbs) so the character can “appear” IRL and on stickers the same way.

#### Funassyi (ふなっしー) — Funabashi (unofficial pear)

- Hyperactive, screaming pear; **not** a quiet silent kigurumi.
- **Why it works:** breaks the “silent mascot” rule with personality volume → TV / viral, not just souvenir.
- **Trait:** **behavior is the brand** (noise, dance) as much as drawing — for software, that maps to **micro-animations / sound** more than a static logo.

### B. Grocery / consumer-goods brand characters

#### Kewpie (キューピー) — Kewpie mayonnaise

- Rose O’Neill’s Kewpie doll (1909 US) licensed by Toichiro Nakashima; face on every bottle since 1925.
- **Why it works on packaging:** cherub silhouette + red/white bottle is recognizable without reading Japanese; character **is** the trademark, not a side sticker.
- **Trait:** **face as logo** — works on squeeze bottle, ads, and cult export (“Japanese mayo”) without explaining the product.

#### Peko-chan (ペコちゃん) / Poko-chan — Fujiya Milky candy

- Pigtailed girl licking her lips (1950); life-size store dolls nationwide.
- **Why it works:** post-war “milk / nutrition” story + **fixed gesture** (licking lips) = instant brand recall on red Milky bags; dual Peko/Poko for girl/boy shelf presence.
- **Trait:** **one signature move** (lip lick) that kids can imitate and adults remember for decades.

#### Suica Penguin — JR East IC card (corporate kyara)

- Adelie-style penguin by Chiharu Sakazaki (2001); deliberately **unnamed** so each rider feels “my companion.”
- **Why it works:** made a **scary new tech** (IC fare) feel safe and daily; later Pensta merch shops; still strong after 25 years (scheduled “graduation” / replacement process announced for end of FY2026).
- **Trait:** **utility product + calm cute** — not food, but same rule: soft character on a hard tool (card / app / machine).

#### Calbee snack bags (category cue)

- Potato-man / bright character art on chips (e.g. usu-shio orange bag) — when Calbee briefly went monochrome (2026 ink shortage), the **missing character face** made the brand feel “wrong” in news coverage.
- **Trait:** **character is part of flavor recognition**, not decoration.

---

## 3. Design pattern checklist (software / indie tool)

Use this when adopting grocery-style kyara for a Mac utility — grounded in the examples above, not generic brand decks.

| # | Pattern | Why (from research) | HalfSnap application |
|---|---------|---------------------|----------------------|
| 1 | **One product job** | Kewpie = mayo; Suica = tap to ride; Kumamon = Kumamoto love | Character “does” window halves / fill / minimize — not a generic tech buddy |
| 2 | **Big face, few features** | Reads on bottle cap, Suica card, LINE sticker, menu bar | Menu bar ~16pt: need bold silhouette, not detailed fur |
| 3 | **Silhouette first** | Kumamon black blob + eyes | Split-window body or left/right limbs readable at 1cm |
| 4 | **Signature gesture** | Peko lip-lick; Funassyi scream | Pose set: lean left, lean right, stretch tall, shrink small |
| 5 | **Personality story (1 line)** | “Even a penguin can use Suica” | “A tiny helper who puts windows in their place” |
| 6 | **Adult + kid dual audience** | Merch for adults (sake, credit cards); candy for kids | Dev tool for adults; stickers/emoji for fun — not childish product |
| 7 | **Merch / stickiness optional** | Economic engine for yuru-chara | Only if you want pins/stickers later; not required for v1 |
| 8 | **Don’t over-polish** | Yurui wins hearts; slick anime can feel corporate | Sketchy / soft lines > Unreal Engine mascot |
| 9 | **Name does double duty** | Kumamon, Hikonyan, Funassyi = place + pun | Product name should say snap/window/half OR be so sticky the face carries it |
| 10 | **Stay product-owned** | Brand kyara ≠ tourism board | Character on GitHub + app, not “city of Cupertino” cosplay |

---

## 4. HalfSnap-specific name + mascot directions

Product truths these must map to: **⌘← left half · ⌘→ right half · ⌘↑ fill usable screen · ⌘↓ minimize · menu bar only · tiny macOS tool**.

### Option A — **Half-kun (ハーフくん)**

| | |
|--|--|
| **Name** | Half-kun |
| **Character** | Round blob split by a vertical seam (left cheek / right cheek); arms push walls apart |
| **Personality** | Cheerful, slightly bossy organizer — “left side, right side, done!” |
| **Maps to actions** | Left/right = leaning poses; fill = arms up stretched; minimize = ball into a tiny circle |
| **Vibe** | Classic yuru-chara name ending; English-readable |

### Option B — **Mado-chan (窓ちゃん)** — “window-chan”

| | |
|--|--|
| **Name** | Mado-chan |
| **Character** | Cat or round face framed like a window sash; ears = title-bar buttons |
| **Personality** | Quiet desk companion (Suica-penguin energy), not hyper Funassyi |
| **Maps to actions** | Left/right = peeking from frame edges; fill = open sash wide; minimize = curtain drop |
| **Vibe** | Soft grocery-shelf cute; Japanese word *mado* = window |

### Option C — **Snappei (スナッペイ)** — snap + -pei (echoes Peko/Poko candy rhythm)

| | |
|--|--|
| **Name** | Snappei |
| **Character** | Soft square “window spirit” with magnet hands that *click* to screen edges |
| **Personality** | Satisfying, tidy, a little proud of clean halves |
| **Maps to actions** | Magnets snap left/right; stretch = fill; magnets off = minimize to Dock |
| **Vibe** | Candy-brand naming energy without copying Peko |

### Option D — **Waribear / Warikuma (割くま)** — “split bear”

| | |
|--|--|
| **Name** | Warikuma (“split bear”) |
| **Character** | Mini black bear (Kumamon-adjacent silhouette language, **not** a copy) with a zipper down the middle |
| **Personality** | Strong, simple, slightly serious about “fair halves” |
| **Maps to actions** | Zip open left/right; unzip full = fill; zip closed tiny = minimize |
| **Vibe** | Strong face-as-logo; risk: too close to Kumamon black-bear trope |

### Option E — **Docko (ドッコ)**

| | |
|--|--|
| **Name** | Docko |
| **Character** | Small creature that lives in the menu bar / Dock; pops up to shove windows |
| **Personality** | Menu-bar gremlin helper — mischievous but helpful |
| **Maps to actions** | Shoves left/right; inflates = fill; dives into Dock = minimize |
| **Vibe** | Explains **where the app lives** (status item); very software-native |

---

## 5. Rename recommendation

### **Do not rename now. Add character *later* as optional brand layer.**

**Why wait**

1. **Product clarity already works.** “HalfSnap” states the job (halves + snap). Kewpie/Peko succeed because the product is ubiquitous *and* the face is decades old — character didn’t replace a clear name, it rode it.
2. **You’re pre-mass-market.** Yuru-chara ROI shows up with merch, events, or daily shelf presence. A ~350-line OSS menu-bar tool wins on GitHub stars and utility first.
3. **Hotkeys are the brand today.** Users remember ⌘←/→/↑/↓ more than a logo. Changing the app name burns search, repo URL, Accessibility TCC entries, and word-of-mouth for little gain.
4. **Cultural fit risk.** A full “Japanese grocery rebrand” from a non-Japanese indie can read as costume if the character is shallow. Better: one strong mascot **as art**, keep English product name (like Suica Penguin supporting “Suica,” not renaming the card “Penguin”).

**What to do instead (when ready)**

1. Keep **HalfSnap** as product / repo name.  
2. Design a **menu-bar-readable** face (checklist §3) as *optional* brand kyara.  
3. Pilot as: GitHub social preview, README hero, sticker pack — **not** a rename.  
4. If the character sticks, consider a **subtitle** (“HalfSnap — featuring Mado-chan”) before any legal rename.

**If you insist on renaming later**, strongest shortlist:

1. **Snappei** — sticky, product-linked, candy rhythm  
2. **Half-kun** — clearest yuru-chara signal  
3. **Docko** — best “lives in menu bar” story  

Avoid **Warikuma** unless design is clearly distinct from Kumamon.

---

## 6. Caveats (not legal advice)

- **Trademarks:** Kewpie, Peko-chan, Kumamon, Suica Penguin, Funassyi, etc. are owned marks. Do not copy shapes, colors, or names. “-chan / -kun / -pei” endings are common language patterns, not free licenses to clone a design.
- **Cultural respect:** Kawaii and yuru-chara are living Japanese commercial culture. Using the *patterns* (face-as-logo, one job, soft shapes) is normal globally; claiming to be an “official yuru-chara of X prefecture” or parodying sacred/local icons is not.
- **Oversaturation:** Japan itself has complained of too many mascots diluting identity (e.g. Osaka commentary mid-2010s). One character is better than a cast.

---

## 7. Sources (selected)

- Wikipedia: [Yuru-kyara](https://en.wikipedia.org/wiki/Yuru-kyara), [Kumamon](https://en.wikipedia.org/wiki/Kumamon), [Fujiya / Peko-chan](https://en.wikipedia.org/wiki/Fujiya)
- Kewpie corporate history: [kewpie.com history](https://www.kewpie.com/en/company/about/history/)
- Kewpie brand narrative: [supergoods.io — How Kewpie Mayo become a cult brand](https://www.supergoods.io/p/kewpie) (2024)
- Peko-chan: [Japan Candy Store — Milky & Peko-chan](https://www.japancandystore.com/blogs/okashi/milky); [asahiimports.com history](https://asahiimports.com/2022/06/26/peko-chan-and-fujiya-a-history-of-japan-though-candy/)
- Suica Penguin: [nippon.com — Sayonara Suica Penguin](https://www.nippon.com/en/japan-data/h02630/) (2025); [jrpass.com — Tokyo’s Most Famous Penguin](https://www.jrpass.com/blog/tokyo-s-most-famous-penguin); [tokyoweekender.com](https://www.tokyoweekender.com/japan-life/news-and-opinion/suica-penguin-ic-card-character-retires/)
- Yuru-chara economy / culture: [bammascots.com overview](https://www.bammascots.com/blog/yuru-chara-mascots-are-a-cultural-phenomenon-in-japan); CNN coverage of Funassyi / mascot cull debates (via Wikipedia citations)
- Calbee packaging / character presence: NPR / Global News coverage of 2026 monochrome packaging (character absence as news)

---

*End of brief. No product rename or art implementation in this deliverable.*
