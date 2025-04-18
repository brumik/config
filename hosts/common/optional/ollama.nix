{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    port = 11434;
    # included only 25.05 release
    # loadModels = [ "codellama:7b" ];
  };
}
