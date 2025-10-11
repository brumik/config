{ lib, ... }:
with lib;
{
  options.globals = mkOption {
    type = types.attrs;
    description = "Global values reused across all configurations.";
    default = { };
  };

  config.globals.users = {
    gamer = {
      uname = "gamer";
      uid = 1000;
    };
    levente = {
      uname = "levente";
      uid = 1010;
    };
    work = {
      uname = "work";
      uid = 1011;
    };
    katerina = {
      uname = "katerina";
      uid = 1000;
    };
  };
}

