/*
 * Feasibility prototype (throwaway, no tests): blink the on-board RGB LED.
 * Cycles red, green, blue at low brightness (WS2812 is very bright).
 */

#include <array>

#include <zephyr/device.h>
#include <zephyr/drivers/led_strip.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(blink, CONFIG_BLINK_LOG_LEVEL);

namespace
{

constexpr auto kStrip = DEVICE_DT_GET(DT_ALIAS(led_strip));
constexpr auto kNumPixels = DT_PROP(DT_ALIAS(led_strip), chain_length);
constexpr auto kPeriod = K_MSEC(500);
constexpr uint8_t kLevel = 16;

struct NamedColor {
	const char *name;
	led_rgb color;
};

constexpr auto kColors = std::to_array<NamedColor>({
	{"red",   {.r = kLevel, .g = 0,      .b = 0      }},
	{"-",     {.r = 0,      .g = 0,      .b = 0      }},
	{"green", {.r = 0,      .g = kLevel, .b = 0      }},
	{"-",     {.r = 0,      .g = 0,      .b = 0      }},
	{"blue",  {.r = 0,      .g = 0,      .b = kLevel }},
	{"-",     {.r = 0,      .g = 0,      .b = 0      }},
});

} // namespace

int main()
{
	if (!device_is_ready(kStrip)) {
		LOG_ERR("LED strip device %s is not ready", kStrip->name);
		return 0;
	}

	std::array<led_rgb, kNumPixels> pixels{};
	size_t index = 0;

	LOG_INF("Starting Hello World Blinker");
	while (true) {
		pixels.fill(kColors[index].color);
		const int rc = led_strip_update_rgb(kStrip, pixels.data(), pixels.size());
		if (rc != 0) {
			LOG_ERR("led_strip_update_rgb failed: %d", rc);
		}
		index = (index + 1) % kColors.size();
		k_sleep(kPeriod);
	}
	LOG_INF("Blinker Loop Unexpectedly Finished!");
}
