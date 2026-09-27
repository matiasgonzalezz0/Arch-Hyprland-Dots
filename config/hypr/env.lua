-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- NVIDIA variables
-- Unset on purpose: hybrid laptop. eDP-2/DP-3 are on the AMD iGPU, DP-1/HDMI-A-1
-- on the NVIDIA dGPU, so pinning either driver is wrong for half the outputs.
-- Letting libva auto-detect per render node fixes black video / stutter in Electron.
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

-- VA-API hardware video acceleration
-- Only configures libva-nvidia-driver, which is no longer forced above -> inert.
-- hl.env("NVD_BACKEND", "direct")
