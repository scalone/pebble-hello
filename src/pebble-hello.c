#include <pebble.h>
#include <string.h>
#include "mruby.h"
#include "mruby/value.h"
#include "mruby/compile.h"
#include "mruby/proc.h"

static Window *window;
static TextLayer *text_layer;

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Select");
}

static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Up");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Down");
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  text_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 20 } });
  text_layer_set_text(text_layer, "Press a button");
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  layer_add_child(window_layer, text_layer_get_layer(text_layer));
}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
}

static void init(void) {
  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
}

int mruby_execute(void)
{
  mrb_state *mrb;
  mrbc_context *c;
  static int s_buffer[5];
  char code[] = "puts 'aaaaa'";

  mrb = mrb_open();
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Test 1");

  c = mrbc_context_new(mrb);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Test 2");

  mrb_load_string_cxt(mrb, code, c);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Test 3");

  mrbc_context_free(mrb, c);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Test 4");

  mrb_close(mrb);
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Test 5");

  return 0;
}

int main(void) {
  init();

  /*mruby_execute();*/

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
