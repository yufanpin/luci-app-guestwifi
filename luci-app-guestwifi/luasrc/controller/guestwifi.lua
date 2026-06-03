module("luci.controller.admin.guestwifi", package.seeall)

function index()
	entry({"admin", "network", "guestwifi"}, call("action_index"), _("访客WiFi"), 60)
end

local function get_cfg()
	local uci = require "luci.model.uci".cursor()
	local keys = {
		"enabled", "mode", "radio24g", "radio5g_low", "radio5g_high",
		"ssid", "encryption", "key",
		"ssid_24g", "encryption_24g", "key_24g",
		"ssid_5g_low", "encryption_5g_low", "key_5g_low",
		"ssid_5g_high", "encryption_5g_high", "key_5g_high",
		"ap_isolate", "lan_isolate",
		"subnet", "netmask", "dhcp_start", "dhcp_limit", "leasetime"
	}
	local cfg = {}
	for _, k in ipairs(keys) do
		cfg[k] = uci:get("guestwifi", "settings", k) or ""
	end
	return cfg
end

local function save_cfg()
	local http = require "luci.http"
	local uci = require "luci.model.uci".cursor()
	local flags = {
		"enabled", "radio24g", "radio5g_low", "radio5g_high",
		"ap_isolate", "lan_isolate"
	}
	local keys = {
		"enabled", "mode", "radio24g", "radio5g_low", "radio5g_high",
		"ssid", "encryption", "key",
		"ssid_24g", "encryption_24g", "key_24g",
		"ssid_5g_low", "encryption_5g_low", "key_5g_low",
		"ssid_5g_high", "encryption_5g_high", "key_5g_high",
		"ap_isolate", "lan_isolate",
		"subnet", "netmask", "dhcp_start", "dhcp_limit", "leasetime"
	}
	uci:set("guestwifi", "settings", "guestwifi")
	for _, k in ipairs(flags) do
		uci:set("guestwifi", "settings", k, "0")
	end
	for _, k in ipairs(keys) do
		local v = http.formvalue(k)
		if v ~= nil then
			uci:set("guestwifi", "settings", k, v)
		end
	end
	uci:commit("guestwifi")
end

local function get_clients()
	local sys = require "luci.sys"
	local clients = {}
	local stations = {}
	for mac in sys.exec("(iw dev ath01 station dump 2>/dev/null; iw dev ath11 station dump 2>/dev/null; iw dev ath21 station dump 2>/dev/null) | grep '^Station' | awk '{print $2}'"):gmatch("%S+") do
		stations[mac:lower()] = true
	end
	for line in sys.exec("cat /tmp/dhcp.leases 2>/dev/null | grep ' 192.168.200.'"):gmatch("[^\n]+") do
		local ts, mac, ip, name = line:match("^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
		if mac then
			clients[#clients + 1] = {
				mac = mac,
				ip = ip or "-",
				name = name or "-",
				online = stations[mac:lower()] and "1" or "0"
			}
		end
	end
	return clients
end

function action_index()
	local http = require "luci.http"
	local tmpl = require "luci.template"
	local sys = require "luci.sys"

	local msg = nil
	local action = http.formvalue("gw_action")
	if action == "save" or action == "apply" then
		save_cfg()
		msg = action == "apply" and "配置已保存，正在后台应用。无线可能会短暂重载。" or "配置已保存"
		if action == "apply" then
			sys.call("/usr/bin/guestwifi-setup >/tmp/guestwifi-setup.log 2>&1 &")
		end
	elseif action == "reset" then
		sys.call("/usr/bin/guestwifi-setup cleanup >/tmp/guestwifi-setup.log 2>&1 &")
		msg = "访客 Wi-Fi 配置已清理"
	end

	tmpl.render("guestwifi/index", { cfg = get_cfg(), msg = msg, clients = get_clients() })
end
