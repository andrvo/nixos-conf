{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
  ];

  boot.growPartition = true;

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
 };

  virtualisation.azure.agent.enable = true;
  services.cloud-init.enable = true;
  systemd.services.cloud-config.serviceConfig = {
    Restart = "on-failure";
  };
  services.cloud-init.network.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;

}

