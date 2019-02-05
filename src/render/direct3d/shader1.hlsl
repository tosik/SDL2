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

/*
// finishing
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
*/

/*
// normal
float4 main(PixelShaderInput input) : SV_TARGET
{
  return theTextureY.Sample(theSampler, input.tex).rgba;
}
*/

/*
// mask
float4 main(PixelShaderInput input) : SV_TARGET
{
  // mask
  float4 mask = float4(0, 0, 0, 0);
  float4 sample = theTextureY.Sample(theSampler, input.tex).rgba;

  float brightness = sample.r * 0.6 + sample.g * 0.2 + sample.b * 0.2;
  // float brightness = max(sample.r, max(sample.g, sample.b));

  if (brightness >= 0.9) {
    mask = float4(0.9, 0.9, 0.9, 1);
  } else if (brightness >= 0.3) {
    mask = float4(0.2, 0.2, 0.2, 1);
  }

  // sample.rgb /= 3;
  sample.r *= 1.0;
  sample.g *= 1.0;
  sample.b *= 1.0;
  return mask * sample;
}
*/

/*
// blur
float4 main(PixelShaderInput input) : SV_TARGET
{
  float2 resolution = float2(480, 352) * 3;

  float4 output;

  // gaussian-blur
  float2 off1 = float2(1.3846153846f, 1.3846153846f);
  float2 off2 = float2(3.2307692308f, 3.2307692308f);
  float2 off3 = float2(1.3846153846f, -1.3846153846f);
  float2 off4 = float2(-3.2307692308f, 3.2307692308f);

  float4 blur = float4(0, 0, 0, 0);

  // clang-format off
  blur += theTextureY.Sample(theSampler, input.tex).rgba * 0.2270270270f;

  blur += theTextureY.Sample(theSampler, input.tex + off1 / resolution) * 0.3162162162f / 2;
  blur += theTextureY.Sample(theSampler, input.tex - off1 / resolution) * 0.3162162162f / 2;
  blur += theTextureY.Sample(theSampler, input.tex + off2 / resolution) * 0.0702702703f / 2;
  blur += theTextureY.Sample(theSampler, input.tex - off2 / resolution) * 0.0702702703f / 2;

  blur += theTextureY.Sample(theSampler, input.tex + off3 / resolution) * 0.3162162162f / 2;
  blur += theTextureY.Sample(theSampler, input.tex - off3 / resolution) * 0.3162162162f / 2;
  blur += theTextureY.Sample(theSampler, input.tex + off4 / resolution) * 0.0702702703f / 2;
  blur += theTextureY.Sample(theSampler, input.tex - off4 / resolution) * 0.0702702703f / 2;
  // clang-format on

  output = blur;

  return output;
}
*/

// dof
float4 main(PixelShaderInput input) : SV_TARGET
{
  float2 resolution = float2(480, 352) * 2;

  float4 output;

  // gaussian-blur
  float2 off1 = float2(1.3846153846f, 1.3846153846f);
  float2 off2 = float2(3.2307692308f, 3.2307692308f);
  float2 off3 = float2(1.3846153846f, -1.3846153846f);
  float2 off4 = float2(-3.2307692308f, 3.2307692308f);

  float4 dof = float4(0, 0, 0, 0);

  // clang-format off
  dof += theTextureY.Sample(theSampler, input.tex) * 0.2270270270f;

  dof += theTextureY.Sample(theSampler, input.tex + off1 / resolution) * 0.3162162162f / 2;
  dof += theTextureY.Sample(theSampler, input.tex - off1 / resolution) * 0.3162162162f / 2;
  dof += theTextureY.Sample(theSampler, input.tex + off2 / resolution) * 0.0702702703f / 2;
  dof += theTextureY.Sample(theSampler, input.tex - off2 / resolution) * 0.0702702703f / 2;

  dof += theTextureY.Sample(theSampler, input.tex + off3 / resolution) * 0.3162162162f / 2;
  dof += theTextureY.Sample(theSampler, input.tex - off3 / resolution) * 0.3162162162f / 2;
  dof += theTextureY.Sample(theSampler, input.tex + off4 / resolution) * 0.0702702703f / 2;
  dof += theTextureY.Sample(theSampler, input.tex - off4 / resolution) * 0.0702702703f / 2;
  // clang-format on

  float4 sample = theTextureY.Sample(theSampler, input.tex);

  float scale = 16;
  float y = (input.tex.y - 0.5f) / scale;
  float yy = abs(y * scale * 2);
  dof = dof * yy + sample * (1 - yy);

  output = dof;

  return output;
}
