{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    # included only 25.05 release
    # loadModels = [ "codellama:7b" ];
  };
}
