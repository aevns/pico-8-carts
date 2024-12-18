import numpy as np
import scipy.optimize as opt
import scipy.integrate as integrate

class Color:
    _linear_srgb : np.ndarray = np.array([0, 0, 0])
    
    def __init__(self, value = [0, 0, 0], format = "linear srgb"):
        if format == "linear srgb" or format =="linear":
            self.linear_srgb = value
        elif format == "srgb" or format == "rgb":
            self.srgb = value
        elif format == "web":
            self.web = value
        elif format == "hex" or format == "hexcode":
            self.hexcode = value
        elif format == "xyz" or format == "xyzd65"  or format == "ciexyz":
            self.xyzd65 = value
        else:
            raise ValueError("Invalid color format")
    
    # LINEAR SRGB
    @property
    def linear_srgb(self):
        return self._linear_srgb
    @linear_srgb.setter
    def linear_srgb(self, value):
        value = np.asarray(value, dtype = float)
        self._linear_srgb = value

    # SRGB
    @property
    def srgb(self):
        gamma = 1.055 * self._linear_srgb ** (1 / 2.4) - 0.055
        linear = self._linear_srgb * 12.92
        return np.where(linear > 0.04045, gamma, linear)
    @srgb.setter
    def srgb(self, value):
        value = np.asarray(value, dtype = float)
        gamma = ((value + 0.055) / 1.055)**2.4
        linear = value / 12.92
        self._linear_srgb = np.where(value > 0.04045, gamma, linear)

    # WEB COLORS (SRGB 8 BIT COLOR)
    @property
    def web(self):
        return np.clip(np.rint(self.srgb * 255).astype(int), 0, 255)
    @web.setter
    def web(self, value):
        value = np.asarray(value, dtype = int)
        self.srgb = value / 255

    # HEXCODE FOR WEB COLORS
    @property
    def hexcode(self):
        web = self.web
        return hex((web[0] << 16) + (web[1] << 8) + web[2])
    @hexcode.setter
    def hexcode(self, value):
        val = int(value, 16)
        r = (val >> 16) & 255
        g = (val >> 8) & 255
        b = val & 255
        self.web = [r, g, b]

    # CIE XYZ
    _BT709_2_MATRIX = np.array([
        [0.4124, 0.3576, 0.1805],
        [0.2126, 0.7152, 0.0722],
        [0.0193, 0.1192, 0.9505]])
    @property
    def xyzd65(self):
        return Color._BT709_2_MATRIX @ self._linear_srgb
    @xyzd65.setter
    def xyzd65(self, value):
        value = np.asarray(value)
        self._linear_srgb = np.linalg.inv(Color._BT709_2_MATRIX) @ value

    # Jzazbz (FOR HIGH DYNAMIC RANGE)
    _JZAZBZ_LMS_MATRIX = np.array([
        [0.41478972, 0.579999, 0.0146480],
        [-0.2015100, 1.120649, 0.0531008],
        [-0.0166008, 0.264800, 0.6684799]])
    _JZAZBZ_IAB_MATRIX = np.array([
        [0.5, 0.5, 0],
        [3.524, -4.066708, 0.542708],
        [0.199076, 1.096799, -1.295875]])
    @property
    def jzazbz(self):
        xyz = self.xyzd65
        xp = 1.15 * xyz[0] - (1.15 - 1) * xyz[2]
        yp = 0.66 * xyz[1] - (0.66 - 1) * xyz[0]
        lms = Color._JZAZBZ_LMS_MATRIX @ np.array([xp, yp, xyz[2]])
        lmsp = ((3424 / 2**12 + 2413 / 2**7 * (lms / 10**4)**(2610 / 2**14)) / (1 + 2392 / 2**7 * (lms / 10**4)**(2610 / 2**14)))**(1.7 * 2523 / 2**5)
        iab = Color._JZAZBZ_IAB_MATRIX @ lmsp
        iab[0] = (1 - 0.56) * iab[0] / (1 + 0.56 * iab[0]) - 1.6295499532821566 * 10**(-11)
        return iab

    # PERCEPTUAL DISTANCE (BASED ON JZAZBZ)
    def perceptual_distance(self, other):
        return np.sum((self.jzazbz - other.jzazbz)**2)
    
    def clamped_perceptual(self):
        def opt_fun(args):
            other = Color(args)
            return np.sum((self.jzazbz - other.jzazbz)**2)
        
        bounds = opt.Bounds([0, 0, 0], [1, 1, 1])
        vals = opt.minimize(opt_fun, [0.5, 0.5, 0.5], bounds = bounds)['x']
        return Color(vals)