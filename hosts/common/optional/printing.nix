{ ... }: {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  services.printing = {
    enable = true;
  };
}
