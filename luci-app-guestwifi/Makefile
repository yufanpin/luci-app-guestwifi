include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-guestwifi
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=guestwifi

LUCI_TITLE:=Guest WiFi Manager
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-base +bash

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-guestwifi/conffiles
/etc/config/guestwifi
endef

define Package/luci-app-guestwifi/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_DATA) ./luasrc/controller/guestwifi.lua $(1)/usr/lib/lua/luci/controller/admin/guestwifi.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/guestwifi
	$(INSTALL_DATA) ./luasrc/view/guestwifi/index.htm $(1)/usr/lib/lua/luci/view/guestwifi/index.htm
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/guestwifi $(1)/etc/config/guestwifi
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/luci-guestwifi $(1)/etc/uci-defaults/luci-guestwifi
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/guestwifi-setup $(1)/usr/bin/guestwifi-setup
endef

$(eval $(call BuildPackage,luci-app-guestwifi))
