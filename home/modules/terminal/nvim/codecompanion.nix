{ ... }:

{
  programs.nixvim = {
    plugins = {
      codecompanion = {
        enable = true;
        settings = {
          adapters = {
            ollama = {
              __raw = ''
                function()
                  return require('codecompanion.adapters').extend('ollama', {
                      env = {
                          url = "https://ollama.berky.me",
                      },
                      schema = {
                          model = {
                              default = 'devstral:24b',
                              -- default = 'gemma3:12b',
                          },
                          num_ctx = {
                              default = 128000,
                          },
                      },
                  })
                end
              '';
            };
          };
          opts = {
            log_level = "TRACE";
            send_code = true;
            use_default_actions = true;
            use_default_prompts = true;
          };
          strategies = {
            agent = { adapter = "ollama"; };
            chat = { adapter = "ollama"; };
            inline = { adapter = "ollama"; };
          };
        };
      };
    };
  };
}
