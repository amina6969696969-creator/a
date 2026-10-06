# Loot Lighthouse: Project Brief for Claude

You are helping build **Loot Lighthouse**, a Roblox game. This file is the full design and build brief. Read it before doing any work, follow it, and ask the user before changing the core design.

## 0. How to work on this project
- Language: **Luau**. Project layout: **Rojo-compatible** (`default.project.json`, `src/` folders) so the user can sync into Roblox Studio.
- You cannot run Roblox Studio. Write code carefully, keep modules small and testable, and tell the user exactly how to load and test each piece.
- Build in the order of section 13. Do not start a later stage until the earlier one works and the user confirms it feels fun.
- **Server authority is mandatory.** The client only sends intent (for example "I fired the beam at this position"). The server validates, calculates results, and owns all currency, loot, crew and inventory state. Never trust a number sent from the client.
- Keep all player-facing text in a localization table from day one, not hardcoded in scripts.
- Prefer clear, boring, well-commented code over clever code. Mobile (touch) must work for every feature.
- Before coding a major system, state a short plan. After coding, list what to test.
- Lessons from the user's previous game: **ask the user for these** and record them in a `LESSONS.md` file, then follow them.

## 1. Pitch
Run a lighthouse on your own island, pull treasure out of the sea with your beam, hire a crew of pets to work for you, and defend your loot from other players. Every server shares one ocean with moods (tides, storms, bosses).

Target audience: Roblox players aged 8 to 16, mostly on phones. The design should be understandable in 10 seconds, rewarding in the first minute, and share-friendly (clips, rare drops, drama).

## 2. World
- Server size: 12 to 16 players.
- A ring of 12 player islands around a central **Ocean**. Each island has a lighthouse, a dock and a vault.
- **Reef Hub**: neutral island with shop, trading, leaderboards, daily voyage board and mini-games. No raiding or stealing there.
- Players in the first 10 minutes sit in a protected **starter ring** (cannot be raided).

## 3. Core loop
**Beaming (minute to minute):**
1. Hold to charge the beam, release to fire into the ocean.
2. A **sweet spot** timing window gives a "Perfect" shot: 2x loot and a screen flash.
3. Loot floats toward the dock. The player taps to collect, or crew collect it.
4. Rarity tiers: Common, Uncommon, Rare, Epic, Legendary, **Mythic**. Mythics are announced server-wide.

**Upgrades (five-minute loop):** beam power (loot per shot), beam range (deeper water, rarer loot), lens types (Fire, Frost, Storm, Ghost: different loot tables), vault size.

**Long loop (30+ minutes):** hire crew, build defenses, Rebirth.

## 4. Crew system
Crew are pets that work for the player. Collecting them is the long-term goal.
- Types: **Collectors** (auto-grab loot: Crab, Seagull, Otter), **Guards** (defend: Pufferfish, Ghost Pirate, Mini Kraken), **Boosters** (income or luck: Lucky Cat Captain, Golden Parrot).
- Each crew member has rarity, level and traits (two Crabs can differ, which enables trading).
- **Fusion:** merge three duplicates into one stronger crew member so every drop is useful.
- **Eggs:** found in the ocean, hatch over a few minutes with a suspense animation.
- **Synergies:** certain pairings give combo bonuses (for example Crab + Seagull).

## 5. Raids
1. Player picks a target island from a list. Wealthy islands show a crown icon.
2. They sail a boat there. A **lighthouse alarm** rings for the owner.
3. They hold the interact button at the vault for **8 seconds** to steal part of the unprotected loot.
4. The owner can chase them off, use traps, or let guard crew defend.

**Fairness rules (do not weaken these):**
- Protected stash: the first 30% of loot (grows with upgrades) can never be stolen.
- Steal cap: max 15% of unprotected loot per raid.
- After being raided: 3-minute shield.
- Offline players cannot be raided. Offline income is safe.
- Raid matchmaking: servers and targets grouped by progression tier and wealth range, so veterans cannot farm beginners.
- No raids for new players in their first 10 minutes.
- **Revenge button** after being raided: one tap to sail to the raider, with a bonus for taking loot back.
- Defenses: traps (tar pit, trapdoor, swinging anchor), searchlight (stuns raiders for 2 seconds), guard crew abilities.

## 6. Progression and rebirth
- Levels 1 to 50 with upgrades and unlocks.
- **Rebirth:** reset the island for a permanent income multiplier and a visible **Rebirth Crest** on the lighthouse.
- Prestige tiers: Bronze, Silver, Gold, Diamond, Cosmic. Each changes the lighthouse look, beam color and sound so progress is visible from across the map.
- Island expansions: tavern, dock extension, lookout tower. Each adds a function (crew slots, vault size, defense).

## 7. Shared ocean events
- **Tide cycle (every 10 minutes):** high tide gives more loot, low tide exposes walkable Treasure Flats.
- **Storm Hour:** beam is harder to aim, Legendary drop rate triples.
- **Blood Moon:** raids more rewarding, Ghost lens loot spawns.
- **Leviathan boss:** all players aim beams at it. Mythic loot goes to everyone, split by **contribution** (not last hit).
- **Ghost Ship:** first player to reach it claims a guaranteed Epic or better.
- Treasure maps: rare items that reveal a hidden dig spot. Tradable and shareable.

## 8. Retention
- Daily Voyage board: three quick quests plus a streak bonus.
- 7-day login streak ending in a crew egg.
- Weekly Expedition with a limited cosmetic reward.
- Monthly seasons with free and premium tracks and a theme (Pirate, Arctic, Haunted).
- Later: Pirate Guilds (up to 20 players, guild chat, weekly guild leaderboard), Reef Hub mini-games (fishing, treasure map hunt, crew race), live holiday events.

## 9. Economy
- Currency: Gold (earned from loot), plus premium currency only if truly needed.
- Needs **sinks**, not just sources: crew fusion costs, lens crafting, island decorations, cosmetic upgrades.
- All economy numbers live in one config module (`Config/Economy`) so they can be tuned without touching logic.
- Log suspicious gains (large currency jumps, impossible beam rates).

## 10. Monetization (keep it fair)
Game passes: 2x Loot, Auto-Collect, VIP (chat tag, extra crew slot, small daily bonus). Developer products: Lucky Boost (15 minutes better odds), egg bundles, cosmetics. Season pass for the premium track.

**Hard rule:** no purchase makes a player unraidable or lets them exceed the standard steal cap. Paid items boost convenience and looks only.

## 11. Social and viral features
Trading at the Reef Hub with a confirm screen. Co-op islands with a friend. Photo mode. Server-wide Mythic announcements. Leaderboards (richest lighthouse, most raids defended, most Perfect shots). Instant replay or clip overlay for Mythic drops and raids.

## 12. Art, audio, feel
- Bright chunky low-poly, cozy-spooky pirate tone. Must read clearly on a phone screen.
- Warm ocean ambience, satisfying "clink" on pickup, deepening hum while the beam charges.
- Juice: screen shake on Mythics, big number pops, a unique sound per rarity.
- Accessibility: rarity shown by shape as well as color, adjustable screen shake, simple aim mode.

## 13. Build order (follow strictly)
1. **Prototype:** one island, beam mechanic, loot spawning and collecting. Confirm it is fun before continuing.
2. **Economy and saving:** currency, upgrades, DataStore saving with retries, session locking and safe fallbacks. Data loss kills games.
3. **Tutorial and first 5 minutes:** guided first shot, guaranteed early Rare, free first crew member.
4. **Crew system:** Collectors first, then Guards and Boosters.
5. **Raids:** boat travel, vault steal, all fairness rules, matchmaking.
6. **Shared events:** tide cycle, then the Leviathan boss.
7. **Retention layer:** dailies, streaks, season pass.
8. **Monetization and polish:** passes, products, juice, mobile testing, localization pass.
9. **Post-launch:** guilds, customization, mini-games, live events.

## 14. Suggested repo layout
```
default.project.json
LESSONS.md
src/
  ReplicatedStorage/   (shared config, types, remotes definitions)
  ServerScriptService/ (services: Data, Economy, Loot, Crew, Raid, Events, Shop)
  StarterPlayer/StarterPlayerScripts/ (UI, input, effects)
  ServerStorage/       (templates, loot tables)
```
Use a service/controller pattern. Each system is a module with a small public API. Remotes go through one validated entry point with rate limiting.

## 15. Anti-exploit checklist (apply to every feature)
- Server validates every beam shot (cooldown, charge time, position within range).
- Server rolls loot. The client never decides drops.
- Rate limit every RemoteEvent and RemoteFunction.
- Trades and purchases are atomic and confirmed on the server.
- Never store authoritative state on the client.

## 16. Risks to watch
Raid frustration (tune protection numbers early with playtests), exploits, mobile controls, scope creep. If a request conflicts with this brief, point it out and ask before proceeding.
