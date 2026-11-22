{ lib, ... }:
{
  dconf.settings = {
    # Never blank the screen on idle; the idle suspend in
    # org/gnome/settings-daemon/plugins/power still takes over.
    #
    # The CHUWI MiniBook X (U300) drives its MIPI DSI panel through i915, which
    # waits only 2500 us for the DSI link to become ready when it lights the
    # panel again after a blank (drivers/gpu/drm/i915/display/icl_dsi.c). This
    # panel can take longer, so the kernel logs "DSI link not ready" and the
    # screen comes back covered in lines. Waking from suspend re-initialises
    # the display and does not hit it. Raising the timeout to 10000 us fixes
    # it, but needs a rebuilt i915 module on every kernel update; the timeout
    # is still 2500 us as of Linux 7.3. Drop this once a kernel waits longer.
    "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 0;
  };
}
