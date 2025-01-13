{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # included only 25.05 release
    # loadModels = [ "codellama:7b" ];
  };
}
