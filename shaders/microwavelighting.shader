#version 130

uniform mat2x4 color_xform;
uniform sampler2D palettetex;
uniform sampler2D framebuf;
uniform float palette;

uniform vec2 screensize;
uniform float timer;

varying vec2 worldPos;

uniform vec2 playerPos;

uniform vec4 light0;
uniform vec4 light1;
uniform vec4 light2;
uniform vec4 light3;
uniform vec4 light4;
uniform vec4 light5;
uniform vec4 light6;
uniform vec4 light7;

const float glow_opacity = .05;     // Opacity of the glow effect
const float ring_start_red = .045;  // Red glow radius (smaller = bigger)
const float ring_start_green = .02; // Green glow radius (smaller = bigger)
const float ring_start_blue = .04;  // Blue glow radius (smaller = bigger)

#if COMPILING_VERTEX_PROGRAM

    void vert(){
        //gl_FrontColor = gl_Color * color_xform[0] + color_xform[1];
        vec4 outcolor = gl_Color * color_xform[0] + color_xform[1];
        gl_FrontColor = outcolor;
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
        worldPos = (gl_ModelViewMatrix * gl_Vertex).xy;
    }
    
#elif COMPILING_FRAGMENT_PROGRAM

    void frag(){
        vec4 screencoords = gl_FragCoord;

        screencoords.x /= screensize.x;
        screencoords.y /= screensize.y;

        vec4 outcolor = texture(framebuf, screencoords.xy);
        

        float d = length(playerPos - worldPos);

        float ambient_light = 1.5*1.5;
        float l_p = min(1.0, 60.0/(d+50.0));
        float l_0 = min(1.0, light0.z / (length(light0.xy - worldPos) + 65.0));
        float l_1 = min(1.0, light1.z / (length(light1.xy - worldPos) + 65.0));
        float l_2 = min(1.0, light2.z / (length(light2.xy - worldPos) + 65.0));
        float l_3 = min(1.0, light3.z / (length(light3.xy - worldPos) + 65.0));
        float l_4 = min(1.0, light4.z / (length(light4.xy - worldPos) + 65.0));
        float l_5 = min(1.0, light5.z / (length(light5.xy - worldPos) + 65.0));
        float l_6 = min(1.0, light6.z / (length(light6.xy - worldPos) + 65.0));
        float l_7 = min(1.0, light7.z / (length(light7.xy - worldPos) + 65.0));

        l_p = l_p*l_p;
        l_0 = l_0*l_0*2;
        l_1 = l_1*l_1*2;
        l_2 = l_2*l_2*2;
        l_3 = l_3*l_3*2;
        l_4 = l_4*l_4*2;
        l_5 = l_5*l_5*2;
        l_6 = l_6*l_6*2;
        l_7 = l_7*l_7*2;

        float lightval = l_p+l_0+l_1+l_2+l_3+l_4+l_5+l_6+l_7;
		
		lightval = lightval * glow_opacity;

		if (lightval > ring_start_red)   outcolor.r += lightval;
		if (lightval > ring_start_green) outcolor.g += lightval;
		if (lightval > ring_start_blue)  outcolor.b += lightval;

        outcolor.a = gl_Color.a;
        gl_FragColor = outcolor;
    }
    
#endif
