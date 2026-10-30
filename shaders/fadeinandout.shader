#version 130

uniform mat2x4 color_xform;
uniform sampler2D palettetex;
uniform float palette;

uniform float waterheight;

#if COMPILING_VERTEX_PROGRAM

    void vert(){
        //gl_FrontColor = gl_Color * color_xform[0] + color_xform[1];
        vec4 outcolor = gl_Color * color_xform[0] + color_xform[1];
        gl_FrontColor = vec4(texture(palettetex, vec2((outcolor.r*15.0+.5)/16.0,(palette+.5)/64.0)).rgb, outcolor.a);
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    }
    
#elif COMPILING_FRAGMENT_PROGRAM

    void frag(){

        vec4 outcolor = gl_Color;

        float shadow_alpha = (waterheight / 30.0);
        shadow_alpha -= .5;
        shadow_alpha = clamp(shadow_alpha, 0.0, 1.0);

        outcolor.a = shadow_alpha;
        gl_FragColor = outcolor;
    }
    
#endif
