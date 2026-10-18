/**
 * Cylinder page curl (after Andrew Hung's breakdown). Every fragment is
 * measured against a curl axis: within the radius it maps onto the roll
 * (front underneath, back on top), behind the axis onto the flat back of
 * the sheet, and beyond the roll it shows the page underneath with the
 * roll's shadow on it.
 */

export const VERTEX_SHADER =
  'attribute vec2 a;void main(){gl_Position=vec4(a,0.,1.);}';

export const FRAGMENT_SHADER = [
  'precision highp float;',
  'uniform sampler2D uTex,uBg;uniform vec2 uRes,uA,uD;uniform vec3 uPaper;uniform float uHasBg;',
  'uniform float uDpr,uSign,uR,uShadow,uEdge,uSpec,uInk;',
  'const float PI=3.14159265;',
  'vec2 tx(vec2 q){return vec2(uSign>0.?q.x:uRes.x-q.x,q.y)/uRes;}',
  'float edgeDist(vec2 q){return min(min(q.x,uRes.x-q.x),min(q.y,uRes.y-q.y));}',
  'float cover(vec2 q){return clamp(edgeDist(q)+.5,0.,1.);}',
  'vec3 front(vec2 q){return texture2D(uTex,tx(q)).rgb;}',
  'vec3 back(vec2 q){return mix(uPaper,texture2D(uTex,tx(q)).rgb,uInk);}',
  'vec4 bgU(vec2 p,float s){if(uHasBg>.5){return vec4(texture2D(uBg,p/uRes).rgb*(1.-s),1.);}return vec4(0.,0.,0.,s);}',
  'void main(){',
  '  vec2 p=vec2(gl_FragCoord.x,uRes.y*uDpr-gl_FragCoord.y)/uDpr;',
  '  vec2 q=vec2(uSign>0.?p.x:uRes.x-p.x,p.y);',
  '  float d=dot(q-uA,uD);vec2 lp=q-uD*d;',
  '  vec4 under;vec4 over=vec4(0.);',
  '  if(d>uR){',
  '    under=bgU(p,uShadow*(1.-smoothstep(0.,uR*1.3+22.,d-uR)));',
  '  }else if(d>=0.){',
  '    float k=clamp(d/uR,0.,1.);float th=asin(k);float n=sqrt(1.-k*k);',
  '    vec2 p1=lp+uD*(th*uR);vec2 p2=lp+uD*((PI-th)*uR);',
  '    float c1=cover(p1),c2=cover(p2);',
  '    under=mix(bgU(p,uShadow),vec4(front(p1)*(.6+.4*n),1.),c1);',
  '    float g=(k-.42)/.2;',
  '    vec3 b=back(p2)*(.72+.28*n)+vec3(uSpec*exp(-g*g));',
  '    over=vec4(b*c2,c2);',
  '  }else{',
  '    vec2 p2=lp+uD*(PI*uR-d);float c2=cover(p2);',
  '    float gap=max(0.,-edgeDist(p2));',
  '    float es=uEdge*(1.-smoothstep(0.,14.+uR*.4,gap));',
  '    under=vec4(front(q)*(1.-es),1.);',
  '    float e=smoothstep(0.,uR*1.6,-d);',
  '    over=vec4(back(p2)*(.955+.045*(1.-e))*c2,c2);',
  '  }',
  '  gl_FragColor=over+under*(1.-over.a);',
  '}',
].join('\n');
