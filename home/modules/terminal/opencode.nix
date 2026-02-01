{ config, ... }:
{
  sops.secrets = { "n100/ollama/bearer" = { }; };
  programs.opencode = {
    enable = true;
    settings = {
      model = "ollama/ctx-glm-4.7-flash:latest";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (Local)";
          options = {
            baseURL = "https://ollama.berky.me/v1";
            apiKey = "{file:${config.sops.secrets."n100/ollama/bearer".path}}";
          };
          models = {
            "ctx-glm-4.7-flash:latest" = {
              name = "GLM-4.7-flash";
            };
          };
        };
      };
    };
  };
}
