uniform float millis;
uniform float saturation;
uniform vec2 screenSize;







/*
#define N 64
#define B 32
#define SS 12
float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12454.1,78345.2))) * 43758.5);
}

vec2 random2(in vec2 st) {
    return vec2(random(st), random(st));    
}

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos(6.28318 * (c*t + d));
}

float iterate(vec2 p) {

    vec2 z = vec2(0), c = p;
    float i;

    for(i=0.; i < N; i++) {
        z = mat2(z, -z.y, z.x) * z + c;
        if(dot(z, z) > B*B) break;
    }

    return i - log(log(dot(z, z)) / log(B)) / log(2.);;     
}

vec4 fractalRender(vec2 fragCoord) {
    vec3 col = vec3(0);
	vec2 R = vec2(screenWidth, screenHeight);
    for (float i = 0; i < SS; i++) {
        vec2 uv = (2 * fragCoord + random2(R+i) - R) / R.y;

        float sn = iterate(uv) / N;   

        col += pal(fract(2.*sn + 0.5), vec3(.5), vec3(0.5), 
                   vec3(1.0,1.0,1.0), vec3(.0, .10, .2));
    }

    return vec4(col / SS, 1.0);
}
*/








//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/stegu/webgl-noise
//

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x*34.0)+10.0)*x);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec2 P) {
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);

    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;  
    g01 *= norm.y;  
    g10 *= norm.z;  
    g11 *= norm.w;  

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
float pnoise(vec2 P, vec2 rep) {
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
    Pi = mod289(Pi);        // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);

    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;  
    g01 *= norm.y;  
    g10 *= norm.z;  
    g11 *= norm.w;  

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}


float fractalNoise(vec2 point) {
	float amp = 1.0;
	float freq = 0.49;

	float total = 0.0; 

	for (int i = 0; i < 3; i++) {
		total += (cnoise(((point * freq) * 1.0 - 1.0) * 8.0) * 0.5 + 0.5) * amp;
		freq *= 2;
		amp *= 0.5;
	}

	return total;
}







vec4 lerpColor(vec4 from, vec4 to, float alpha) {
	return (to - from) * alpha + from;
}
vec4 getShaderColor(vec2 fragCoord) {
	float t = millis/10;

	float n1 = fractalNoise(fragCoord - vec2(t+10, t));
	float n2 = fractalNoise(fragCoord + vec2(t, t+10));

	float n = (n1 + n2) * 0.5;

	vec4 darkColor = vec4((0.0/255.0), (0.0/255.0), (100.0/255.0), 1);
	vec4 lightColor = vec4((147.0/255.0), (125.0/255.0), (234.0/255.0), 1);
	
	return lerpColor(darkColor, lightColor, n);
}





vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, texture_coords);
    vec4 pixelColor = texcolor * color;

    float a = millis;
    if (pixelColor.x == 1 && pixelColor.y == 1 && pixelColor.z == 1) {
        vec4 shaderColor = getShaderColor(screen_coords/screenSize);
        pixelColor = vec4(shaderColor.xyz, pixelColor.w);
    }

    float averageColor = (pixelColor.x + pixelColor.y + pixelColor.z)/3.0;
    vec4 desaturatedColor = vec4(averageColor, averageColor, averageColor, pixelColor.w);
    vec4 finalColor = lerpColor(desaturatedColor, pixelColor, saturation);

    // return vec4(1-finalColor.x,1-finalColor.y,1-finalColor.z,finalColor.w); // inverted
    return finalColor;
}