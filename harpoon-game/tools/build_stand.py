"""Builds the merchant stand as data and writes two outputs:

  harpoon-game/MerchantStand.rbxmx   Roblox model file. In Studio: drag it into
                                     the 3D view, or right-click Workspace >
                                     Insert from File.
  <out>/stand_scene.json             Part list for the browser 3D preview.

The geometry mirrors harpoon-game/BuildMerchantStand.lua (same sizes and
positions; the front of the stall faces -Z).

Usage: python3 harpoon-game/tools/build_stand.py [scene_json_out_dir]
"""

import json
import math
import os
import sys
from xml.sax.saxutils import escape

import numpy as np

STUD_STYLE = True
SHOP_TITLE = "MERCHANT"

WOOD = (164, 112, 66)
WOOD_LIGHT = (184, 132, 84)
WOOD_DARK = (107, 68, 35)
RED = (232, 67, 42)
CREAM = (243, 227, 195)
GOLD = (255, 201, 60)
NAVY = (14, 42, 63)
IRON = (70, 74, 80)

MATERIAL_TOKENS = {
    "Plastic": 256, "SmoothPlastic": 272, "Neon": 288, "Wood": 512,
    "WoodPlanks": 528, "Metal": 1088, "Fabric": 1312, "Glass": 1568,
}
SHAPE_TOKENS = {"Ball": 0, "Block": 1, "Cylinder": 2}


def angles(rx=0.0, ry=0.0, rz=0.0):
    """Same as Roblox CFrame.Angles(rx, ry, rz) = Rx * Ry * Rz."""
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    cz, sz = math.cos(rz), math.sin(rz)
    rxm = np.array([[1, 0, 0], [0, cx, -sx], [0, sx, cx]])
    rym = np.array([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]])
    rzm = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
    return rxm @ rym @ rzm


IDENTITY = np.eye(3)
UPRIGHT = angles(0, 0, math.radians(90))  # cylinders run along X; tip them up


class Node:
    """A Roblox instance (Model, Part, or anything else) in the tree."""

    def __init__(self, cls, name, parent=None, **props):
        self.cls = cls
        self.name = name
        self.props = props
        self.children = []
        if parent is not None:
            parent.children.append(self)


root = Node("Model", "MerchantStand")
groups = {n: Node("Model", n, root) for n in ["Structure", "Counter", "Awning", "Lanterns", "Props", "Sign"]}
parts = []  # flat list for the viewer


def part(name, size, pos, color, material="SmoothPlastic", parent=None, deco=False,
         rot=IDENTITY, shape="Block", transparency=0.0):
    studs = False
    if STUD_STYLE and material not in ("Neon", "Glass"):
        material = "Plastic"
        studs = shape == "Block"
    node = Node("Part", name, parent, size=tuple(size), pos=tuple(pos), rot=rot, color=color,
                material=material, shape=shape, deco=deco, transparency=transparency,
                studs=studs)
    parts.append(node)
    return node


def cylinder(name, height, diameter, pos, color, material, parent, deco=False):
    return part(name, (height, diameter, diameter), pos, color, material, parent, deco,
                rot=UPRIGHT, shape="Cylinder")


def ball(name, d, pos, color, material, parent):
    return part(name, (d, d, d), pos, color, material, parent, True, shape="Ball")


def v(x, y, z):
    return np.array([x, y, z], dtype=float)


S = groups["Structure"]
C = groups["Counter"]
A = groups["Awning"]
L = groups["Lanterns"]
P = groups["Props"]
G = groups["Sign"]

# Platform
base = part("Base", (20, 0.5, 14), (0, 0.25, 0), WOOD, "Wood", S, True, transparency=1)
base.props["studs"] = False
for i in range(10):
    part("Plank", (1.9, 0.5, 14), (-9 + i * 2, 0.25, 0), WOOD if i % 2 == 0 else WOOD_LIGHT, "Wood", S)
part("FrontEdge", (20.2, 0.6, 0.6), (0, 0.3, -7), WOOD_DARK, "Wood", S)
part("BackEdge", (20.2, 0.6, 0.6), (0, 0.3, 7), WOOD_DARK, "Wood", S)

# Posts, wall, shelves, rails
for x in (-7.5, 7.5):
    part("FrontPost", (1, 9.5, 1), (x, 5.25, -4), WOOD_DARK, "Wood", S)
    part("BackPost", (1, 11, 1), (x, 6, 4.5), WOOD_DARK, "Wood", S)
    part("SideRail", (0.4, 0.4, 8.5), (x, 3.5, 0.25), WOOD_DARK, "Wood", S)
    part("SideRailLow", (0.4, 0.4, 8.5), (x, 1.8, 0.25), WOOD_DARK, "Wood", S)
part("FrontBeam", (16, 0.6, 0.6), (0, 9.7, -4), WOOD_DARK, "Wood", S)
part("BackWall", (14, 10, 0.5), (0, 5.5, 4.75), WOOD, "WoodPlanks", S)
part("ShelfLow", (13, 0.35, 1.6), (0, 4.0, 3.7), WOOD_DARK, "Wood", S)
part("ShelfHigh", (13, 0.35, 1.6), (0, 7.0, 3.7), WOOD_DARK, "Wood", S)
Node("Attachment", "MerchantNPCSpot", base, cf=((0, 0.25, 1.2), IDENTITY))

# Counter
part("CounterBody", (14, 3.5, 2), (0, 2.25, -3.5), WOOD, "WoodPlanks", C)
countertop = part("Countertop", (15.2, 0.4, 2.8), (0, 4.2, -3.6), WOOD_DARK, "Wood", C)
part("GoldTrim", (14, 0.35, 0.15), (0, 3.3, -4.55), GOLD, "Metal", C, True)
part("NavyKick", (14, 0.5, 0.15), (0, 0.75, -4.55), NAVY, "SmoothPlastic", C, True)
sell = Node("Attachment", "SellPoint", countertop, cf=((0, 0.6, -0.6), IDENTITY))
Node("ProximityPrompt", "SellPrompt", sell, prompt=True)

# Awning
backZ, backY, frontZ, frontY = 5.2, 11.8, -6.2, 9.6
dz, dy = backZ - frontZ, backY - frontY
length = math.hypot(dz, dy)
tilt = math.atan2(dy, dz)
cy, cz = (backY + frontY) / 2, (backZ + frontZ) / 2
for i in range(8):
    x = -7 + i * 2
    part("Stripe", (2, 0.25, length), (x, cy, cz), RED if i % 2 == 0 else CREAM, "Fabric", A,
         rot=angles(-tilt, 0, 0))
    part("Valance", (2, 0.9, 0.2), (x, frontY - 0.45, frontZ - 0.05), CREAM if i % 2 == 0 else RED,
         "Fabric", A, True)
    ball("Tassel", 0.5, (x, frontY - 1.05, frontZ - 0.05), GOLD, "Metal", A)
part("Ridge", (17, 0.5, 0.5), (0, backY + 0.15, backZ), WOOD_DARK, "Wood", A)


def awning_y(z):
    return frontY + (z - frontZ) * (dy / dz)


# Lanterns
for x in (-6.5, 6.5):
    z = -5
    top = awning_y(z) - 0.1
    lan = Node("Model", "Lantern", L)
    part("Chain", (0.15, 1.2, 0.15), (x, top - 0.6, z), IRON, "Metal", lan, True)
    part("Cap", (0.9, 0.25, 0.9), (x, top - 1.3, z), IRON, "Metal", lan, True)
    glow = part("Glow", (0.65, 1, 0.65), (x, top - 1.95, z), (255, 200, 110), "Neon", lan, True)
    part("Bottom", (0.9, 0.2, 0.9), (x, top - 2.55, z), IRON, "Metal", lan, True)
    Node("PointLight", "PointLight", glow, light=True)

# Sign
for x in (-3.5, 3.5):
    part("SignPole", (0.4, 1.6, 0.4), (x, backY + 0.9, backZ - 0.4), WOOD_DARK, "Wood", G)
sign = part("SignBoard", (10, 2.4, 0.35), (0, backY + 2.6, backZ - 0.4), WOOD_DARK, "Wood", G)
sign.props["label"] = {"text": SHOP_TITLE, "color": GOLD, "kind": "sign"}
Node("SurfaceGui", "SignGui", sign, gui="sign")


# Treasure props
def chest(p):
    m = Node("Model", "Chest", P)
    part("Body", (1.6, 0.9, 1), p + v(0, 0.45, 0), WOOD_DARK, "Wood", m, True)
    part("Lid", (1.6, 0.4, 1), p + v(0, 1.1, 0), WOOD, "Wood", m, True)
    part("Band", (1.65, 0.15, 1.05), p + v(0, 0.9, 0), GOLD, "Metal", m, True)
    part("Lock", (0.3, 0.35, 0.1), p + v(0, 0.75, -0.55), GOLD, "Metal", m, True)


def bottle(p, color):
    m = Node("Model", "Bottle", P)
    cylinder("Glass", 1, 0.5, p + v(0, 0.5, 0), color, "Glass", m, True).props["transparency"] = 0.25
    cylinder("Neck", 0.4, 0.22, p + v(0, 1.2, 0), color, "Glass", m, True).props["transparency"] = 0.25
    cylinder("Cork", 0.2, 0.24, p + v(0, 1.5, 0), WOOD_LIGHT, "Wood", m, True)


def chalice(p):
    m = Node("Model", "Chalice", P)
    cylinder("Foot", 0.12, 0.7, p + v(0, 0.06, 0), GOLD, "Metal", m, True)
    cylinder("Stem", 0.6, 0.18, p + v(0, 0.4, 0), GOLD, "Metal", m, True)
    cylinder("Cup", 0.6, 0.8, p + v(0, 1.0, 0), GOLD, "Metal", m, True)


def coin_stack(p, layers):
    m = Node("Model", "Coins", P)
    for i in range(1, layers + 1):
        cylinder("Coin", 0.15, 0.7, p + v((i % 2) * 0.05, 0.075 + (i - 1) * 0.15, 0), GOLD, "Metal", m, True)


low, high, ctr = 4.175, 7.175, 4.4
chest(v(-5, low, 3.7))
bottle(v(-2.6, low, 3.7), (95, 214, 200))
bottle(v(-1.8, low, 3.7), (69, 178, 255))
coin_stack(v(0.4, low, 3.7), 5)
coin_stack(v(1.2, low, 3.5), 3)
chest(v(4.4, low, 3.7))
chalice(v(-4.5, high, 3.7))
ball("Pearl", 0.6, (-2.2, high + 0.3, 3.7), (245, 240, 255), "SmoothPlastic", P)
ball("Pearl", 0.45, (-1.5, high + 0.225, 3.8), (255, 225, 240), "SmoothPlastic", P)
chalice(v(0.8, high, 3.7))
bottle(v(3, high, 3.7), (193, 123, 255))
coin_stack(v(4.8, high, 3.7), 7)
coin_stack(v(-5, ctr, -3.6), 6)
coin_stack(v(-4.3, ctr, -3.4), 3)

sc = Node("Model", "Scale", P)
sx = 4.5
part("Post", (0.2, 1.6, 0.2), (sx, ctr + 0.8, -3.5), GOLD, "Metal", sc, True)
part("Beam", (2.2, 0.15, 0.15), (sx, ctr + 1.6, -3.5), GOLD, "Metal", sc, True)
cylinder("PanL", 0.1, 0.9, v(sx - 1, ctr + 0.9, -3.5), GOLD, "Metal", sc, True)
cylinder("PanR", 0.1, 0.9, v(sx + 1, ctr + 0.9, -3.5), GOLD, "Metal", sc, True)
part("StringL", (0.05, 0.7, 0.05), (sx - 1, ctr + 1.25, -3.5), IRON, "Metal", sc, True)
part("StringR", (0.05, 0.7, 0.05), (sx + 1, ctr + 1.25, -3.5), IRON, "Metal", sc, True)


def barrel(p):
    m = Node("Model", "Barrel", P)
    cylinder("Body", 3, 2.4, p + v(0, 1.5, 0), WOOD, "Wood", m)
    cylinder("BandTop", 0.25, 2.5, p + v(0, 2.4, 0), IRON, "Metal", m, True)
    cylinder("BandBottom", 0.25, 2.5, p + v(0, 0.6, 0), IRON, "Metal", m, True)


barrel(v(-8.8, 0.5, 2.2))
barrel(v(-8.8, 0.5, 5.2))
part("Crate", (2.2, 2.2, 2.2), (8.8, 1.6, 4.8), WOOD_LIGHT, "WoodPlanks", P)
part("CrateSmall", (1.5, 1.5, 1.5), (8.8, 3.45, 4.8), WOOD, "WoodPlanks", P, rot=angles(0, math.radians(20), 0))
part("Crate", (2, 2, 2), (8.8, 1.5, 2.2), WOOD, "WoodPlanks", P)

# WANTED board
W = Node("Model", "WantedBoard", root)
bx, bz = -12.5, -4.5
for dx in (-2.75, 2.75):
    part("Leg", (0.5, 8, 0.5), (bx + dx, 4, bz + 0.3), WOOD_DARK, "Wood", W)
board = part("Board", (6, 5, 0.3), (bx, 5.2, bz), WOOD_DARK, "Wood", W)
board.props["label"] = {"text": "WANTED", "color": (255, 231, 163), "kind": "wanted"}
part("Roof", (6.8, 0.3, 1.4), (bx, 8.1, bz + 0.2), RED, "Fabric", W)
Node("SurfaceGui", "WantedGui", board, gui="wanted")

# Model's PrimaryPart and pivot
root.props["primary"] = base


# ---------------------------------------------------------------------------
# rbxmx writer
# ---------------------------------------------------------------------------
_ref = [0]


def ref():
    _ref[0] += 1
    return f"RBX{_ref[0]:04d}"


def f(x):
    return f"{float(x):.6g}"


def cframe_xml(tag, pos, rot):
    r = rot
    return (f'<CoordinateFrame name="{tag}"><X>{f(pos[0])}</X><Y>{f(pos[1])}</Y><Z>{f(pos[2])}</Z>'
            f'<R00>{f(r[0][0])}</R00><R01>{f(r[0][1])}</R01><R02>{f(r[0][2])}</R02>'
            f'<R10>{f(r[1][0])}</R10><R11>{f(r[1][1])}</R11><R12>{f(r[1][2])}</R12>'
            f'<R20>{f(r[2][0])}</R20><R21>{f(r[2][1])}</R21><R22>{f(r[2][2])}</R22></CoordinateFrame>')


def color3(name, rgb):
    return f'<Color3 name="{name}"><R>{f(rgb[0] / 255)}</R><G>{f(rgb[1] / 255)}</G><B>{f(rgb[2] / 255)}</B></Color3>'


def udim2(name, xs, xo, ys, yo):
    return f'<UDim2 name="{name}"><XS>{f(xs)}</XS><XO>{xo}</XO><YS>{f(ys)}</YS><YO>{yo}</YO></UDim2>'


def s(name, text):
    return f'<string name="{name}">{escape(text)}</string>'


def font(family, weight=400):
    return (f'<Font name="FontFace"><Family><url>rbxasset://fonts/families/{family}.json</url></Family>'
            f'<Weight>{weight}</Weight><Style>Normal</Style></Font>')


def gui_item(cls, name, props, children=()):
    return f'<Item class="{cls}" referent="{ref()}"><Properties>{s("Name", name)}{"".join(props)}</Properties>{"".join(children)}</Item>'


def label(name, text, size, pos, color, family="FredokaOne", weight=400, stroke=None):
    kids = []
    if stroke:
        kids.append(gui_item("UIStroke", "UIStroke", [f'<float name="Thickness">{stroke}</float>', color3("Color", (6, 21, 33))]))
    return gui_item("TextLabel", name, [
        f'<float name="BackgroundTransparency">1</float>', udim2("Size", *size), udim2("Position", *pos),
        s("Text", text), '<bool name="TextScaled">true</bool>', color3("TextColor3", color), font(family, weight),
    ], kids)


def surface_gui(name, pps, children):
    return gui_item("SurfaceGui", name, [
        '<token name="Face">5</token>', '<token name="SizingMode">1</token>',
        f'<float name="PixelsPerStud">{pps}</float>', '<float name="LightInfluence">0</float>',
    ], children)


def wanted_gui():
    posters = []
    for i, rot_deg in enumerate((-3, 2, -1.5), start=1):
        posters.append(gui_item("Frame", f"Poster{i}", [
            udim2("Size", 0.3, 0, 1, 0), color3("BackgroundColor3", CREAM), f'<float name="Rotation">{rot_deg}</float>',
        ], [
            gui_item("UICorner", "UICorner", ['<UDim name="CornerRadius"><S>0.06</S><O>0</O></UDim>']),
            gui_item("ImageLabel", "Icon", [color3("BackgroundColor3", NAVY), udim2("Size", 0.8, 0, 0.45, 0),
                                            udim2("Position", 0.1, 0, 0.06, 0), '<token name="ScaleType">3</token>'],
                     [gui_item("UICorner", "UICorner", ['<UDim name="CornerRadius"><S>0.12</S><O>0</O></UDim>'])]),
            label("ItemName", "???", (0.9, 0, 0.2, 0), (0.05, 0, 0.53, 0), (62, 38, 20)),
            label("Multiplier", "×3", (0.9, 0, 0.24, 0), (0.05, 0, 0.74, 0), (181, 48, 27)),
        ]))
    layout = gui_item("UIListLayout", "UIListLayout", [
        '<token name="FillDirection">0</token>', '<token name="HorizontalAlignment">0</token>',
        '<UDim name="Padding"><S>0.03</S><O>0</O></UDim>', '<token name="SortOrder">0</token>',
    ])
    return surface_gui("WantedGui", 60, [
        label("Title", "WANTED", (1, 0, 0.2, 0), (0, 0, 0.02, 0), (255, 231, 163)),
        gui_item("Frame", "Posters", ['<float name="BackgroundTransparency">1</float>',
                                      udim2("Size", 0.94, 0, 0.62, 0), udim2("Position", 0.03, 0, 0.24, 0)],
                 [layout] + posters),
        label("NewIn", "New list at 02:00", (1, 0, 0.1, 0), (0, 0, 0.88, 0), CREAM, "GothamSSm", 700),
    ])


def sign_gui():
    return surface_gui("SignGui", 50, [label("Title", SHOP_TITLE, (0.9, 0, 0.8, 0), (0.05, 0, 0.1, 0), GOLD, stroke=4)])


def node_xml(n):
    r = ref()
    n.props["_ref"] = r
    props = [s("Name", n.name)]
    kids = []
    if n.cls == "Part":
        p = n.props
        props += [
            '<bool name="Anchored">true</bool>',
            cframe_xml("CFrame", p["pos"], p["rot"]),
            f'<Vector3 name="size"><X>{f(p["size"][0])}</X><Y>{f(p["size"][1])}</Y><Z>{f(p["size"][2])}</Z></Vector3>',
            f'<Color3uint8 name="Color3uint8">{0xFF000000 | (p["color"][0] << 16) | (p["color"][1] << 8) | p["color"][2]}</Color3uint8>',
            f'<token name="Material">{MATERIAL_TOKENS[p["material"]]}</token>',
            f'<token name="shape">{SHAPE_TOKENS[p["shape"]]}</token>',
            f'<token name="TopSurface">{3 if p["studs"] else 0}</token>',
            f'<token name="BottomSurface">{4 if p["studs"] else 0}</token>',
            f'<float name="Transparency">{f(p["transparency"])}</float>',
        ]
        if p["deco"]:
            props += ['<bool name="CanCollide">false</bool>', '<bool name="CanTouch">false</bool>',
                      '<bool name="CastShadow">false</bool>']
        if n.name == "Base":
            props += ['<bool name="CanQuery">false</bool>',
                      cframe_xml("PivotOffset", (0, -0.25, 0), IDENTITY)]
    elif n.cls == "Attachment":
        pos, rot = n.props["cf"]
        props.append(cframe_xml("CFrame", pos, rot))
    elif n.cls == "ProximityPrompt":
        props += [s("ActionText", "Sell"), s("ObjectText", SHOP_TITLE), '<token name="KeyboardKeyCode">101</token>',
                  '<float name="HoldDuration">0</float>', '<float name="MaxActivationDistance">10</float>',
                  '<bool name="RequiresLineOfSight">false</bool>']
    elif n.cls == "PointLight":
        props += ['<float name="Range">14</float>', '<float name="Brightness">1.4</float>',
                  color3("Color", (255, 190, 120)), '<bool name="Shadows">false</bool>']
    elif n.cls == "SurfaceGui":
        # Built separately below; the Node only marks where it goes.
        return wanted_gui() if n.props["gui"] == "wanted" else sign_gui()
    for c in n.children:
        kids.append(node_xml(c))
    if n.cls == "Model" and "primary" in n.props:
        props.append(f'<Ref name="PrimaryPart">{n.props["primary"].props["_ref"]}</Ref>')
    return f'<Item class="{n.cls}" referent="{r}"><Properties>{"".join(props)}</Properties>{"".join(kids)}</Item>'


def write_rbxmx(path):
    # Children first so Base has a referent before the root Model names it as PrimaryPart.
    body = node_xml(root)
    xml = ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
           'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
           'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
           f'{body}</roblox>')
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(xml)


def write_scene(path):
    out = []
    for n in parts:
        p = n.props
        if p["transparency"] >= 1:
            continue
        out.append({
            "name": n.name, "size": list(p["size"]), "pos": [round(float(c), 4) for c in p["pos"]],
            "rot": [round(float(c), 6) for c in np.asarray(p["rot"]).flatten()],
            "color": list(p["color"]), "material": p["material"], "shape": p["shape"],
            "studs": p["studs"], "transparency": p["transparency"], "label": p.get("label"),
        })
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, separators=(",", ":"))
    return len(out)


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    rbxmx = os.path.join(here, "..", "MerchantStand.rbxmx")
    write_rbxmx(rbxmx)
    out_dir = sys.argv[1] if len(sys.argv) > 1 else here
    count = write_scene(os.path.join(out_dir, "stand_scene.json"))
    print(f"Wrote {os.path.normpath(rbxmx)} and stand_scene.json ({count} visible parts)")
