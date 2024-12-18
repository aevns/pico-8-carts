#%%
import numpy as np
from color_space_calculations import Color

#%% All useable colors
color_hexcodes = {
      0: "000000",   1: "1d2b53",   2: "7e2553",   3: "008751",
      4: "ab5236",   5: "5f574f",   6: "c2c3c7",   7: "fff1e8",
      8: "ff004d",   9: "ffa300",  10: "ffec27",  11: "00e436",
     12: "29adff",  13: "83769c",  14: "ff77a8",  15: "ffccaa",
    128: "291814", 129: "111d35", 130: "422136", 131: "125359",
    132: "742f29", 133: "49333b", 134: "a28879", 135: "f3ef7d",
    136: "be1250", 137: "ff6c24", 138: "a8e72e", 139: "00b543",
    140: "065ab5", 141: "754665", 142: "ff6e59", 143: "ff9d81"
}

colors = {k: Color(v, format = "hex") for k,v in color_hexcodes.items()}

#%%
ambient_color = Color([0.12, 0.1, 0.2], format = "srgb")
ambient = ambient_color.linear_srgb

lit_color = Color([1, 1, 1], format = "srgb")
lit = lit_color.linear_srgb

lights_linear_srgb = np.array([
    ambient,
    ambient + (lit - ambient) / 8,
    ambient + (lit - ambient) / 4,
    ambient + (lit - ambient) / 2,
    lit,
    ambient + (lit - ambient) * 2,
    ambient + (lit - ambient) * 4,
    ambient + (lit - ambient) * 8
    ])

lights = [Color(val) for val in lights_linear_srgb]

#%%

custom_palette = [
    0, 129, 130, 3,
    4, 5, 6, 7,
    8, 9 + 128, 10, 11,
    131, 140, 132, 134
    ]

grayscale_palette = [
    0, 128, 133, 5, 134, 6, 7
]

#%%
#TODO Return light levels based on used_palette indices, AND an output screen palette
used_palette = custom_palette
screen_palette = grayscale_palette
output_palettes = np.zeros((len(lights), len(used_palette)), dtype = int)

errors = np.zeros(len(lights))
for l in range(0, len(lights)):
    for i in range(0, len(used_palette)):

        c = Color(colors[used_palette[i]].linear_srgb * lights[l].linear_srgb)

        min_dist = np.inf
        for j in range(0, len(screen_palette)):
            dist = c.perceptual_distance(colors[screen_palette[j]])
            if dist < min_dist:
                min_dist = dist
                output_palettes[l, i] = screen_palette[j]
        errors[l] += min_dist

    print("light_level_", l, " = {[0]=", str(output_palettes[l].tolist())[1:-1], "}", sep = '')

for l in range(0, len(lights)):
    print("light level ", l, " error: ", 10000 * errors[l] / (len(colors) * lights[l].jzazbz[0]), sep = '')
# %%
