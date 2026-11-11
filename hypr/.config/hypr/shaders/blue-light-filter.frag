precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    // Warm tone (approx 4500K)
    pixColor.b = pixColor.b * 0.70;
    pixColor.g = pixColor.g * 0.90;
    gl_FragColor = pixColor;
}
