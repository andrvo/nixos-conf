{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
  ];

  boot.growPartition = true;

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
 };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
 };

  services.waagent.enable = true;
  services.cloud-init.enable = true;
  systemd.services.cloud-config.serviceConfig = {
    Restart = "on-failure";
  };
  services.cloud-init.network.enable = true;
  networking.useDHCP = false;
  networking.useNetworkd = true;

}

