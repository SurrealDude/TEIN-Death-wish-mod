#version 130

uniform mat2x4 color_xform;
uniform sampler2D palettetex;
uniform sampler2D framebuf;
uniform float palette;

uniform vec2 screensize;
uniform float timer;

uniform float level_param;
uniform float waterheight;

varying vec2 worldPos;

const float light_distance = 0.5;  // Less = farther distance
const float glow_strength = 5;     // Strength of glow effect


#if COMPILING_VERTEX_PROGRAM

    void vert(){
        //gl_FrontColor = gl_Color * color_xform[0] + color_xform[1];
        vec4 outcolor = gl_Color * color_xform[0] + color_xform[1];
        gl_FrontColor = outcolor;
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
        worldPos = (gl_ModelViewMatrix * gl_Vertex).xy;
    }
    
#elif COMPILING_FRAGMENT_PROGRAM
    float hash(float x){
        return fract(sin(x)*43758.5453);
    }
    float noise( float u ){
        vec3 x = vec3(u, 0, 0);

        vec3 p = floor(x);
        vec3 f = fract(x);

        f       = f*f*(3.0-2.0*f);
        float n = p.x + p.y*57.0 + 113.0*p.z;

        return mix(mix(mix( hash(n+0.0), hash(n+1.0),f.x),
            mix( hash(n+57.0), hash(n+58.0),f.x),f.y),
            mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    }

    vec4 gblend(vec4 a, vec4 b){
        return 1.0-(1.0-a)*(1.0-b);
    }

    void frag(){
        vec4 screencoords = gl_FragCoord;

        screencoords.x /= screensize.x;
        screencoords.y /= screensize.y;

        vec4 outcolor = texture(framebuf, screencoords.xy);

        float dy = waterheight - worldPos.y;

        dy += noise(worldPos.x / 64.0 +timer  * 2)*32;
		
		dy *= (1 - level_param);

        float glowval = -(dy / 360.0);
        glowval = glowval*light_distance;
        glowval += 1;
        glowval = clamp(glowval, 0.0, 1.0);
        glowval = glowval*glowval;

        float lightval = glowval;
		lightval = 1.0+(1.0-lightval)*glow_strength;
		
		outcolor *= lightval;

        outcolor.a = gl_Color.a;
        gl_FragColor = outcolor;
    }
    
#endif
