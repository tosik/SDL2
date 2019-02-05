Texture2D theTextureY : register(t0);
Texture2D theTextureU : register(t1);
Texture2D theTextureV : register(t2);
SamplerState theSampler = sampler_state
{
  addressU = Clamp;
  addressV = Clamp;
  mipfilter = NONE;
  minfilter = LINEAR;
  magfilter = LINEAR;
};

struct PixelShaderInput
{
  float2 tex : TEXCOORD0;
  float4 color : COLOR0;
};

float4 main(PixelShaderInput input) : SV_TARGET
{
  // 352

  // scan_line
  float scan_line;
  if (trunc(input.tex.y * 352) % 2 == 0)
    scan_line = 1.0;
  else
    scan_line = 0.97;

  // pick color
  float4 c;
  c.rgb = theTextureY.Sample(theSampler, input.tex).rgb;
  c.a = 1;

  // contrast
  float contrast = 6;
  return 1 / (1 + exp(-contrast * (c * scan_line - 0.5)));
}

