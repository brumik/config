#include QMK_KEYBOARD_H


/* THIS FILE WAS GENERATED!
 *
 * This file was generated by qmk json2c. You may or may not want to
 * edit it directly.
 */


const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[0] = LAYOUT_split_3x5_3(KC_Q, KC_W, KC_F, KC_P, KC_B, KC_J, KC_L, KC_U, KC_Y, KC_QUOT, LGUI_T(KC_A), LALT_T(KC_R), LCTL_T(KC_S), LSFT_T(KC_T), KC_G, KC_M, LSFT_T(KC_N), LCTL_T(KC_E), LALT_T(KC_I), LGUI_T(KC_O), KC_Z, KC_X, KC_C, KC_D, KC_V, KC_K, KC_H, KC_COMM, KC_DOT, KC_SLSH, LT(3,KC_ESC), LT(2,KC_SPC), LT(1,KC_TAB), LT(4,KC_ENT), LT(5,KC_BSPC), LT(6,KC_DEL)),
	[1] = LAYOUT_split_3x5_3(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT, KC_NO, CW_TOGG, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_INS, KC_HOME, KC_PGUP, KC_PGDN, KC_END, KC_NO, KC_NO, KC_NO, KC_ENT, KC_BSPC, KC_DEL),
	[2] = LAYOUT_split_3x5_3(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LGUI, KC_LALT, KC_LCTL, KC_LSFT, KC_NO, KC_NO, KC_MS_L, KC_MS_D, KC_MS_U, KC_MS_R, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_WH_L, KC_WH_D, KC_WH_U, KC_WH_R, KC_NO, KC_NO, KC_NO, KC_BTN1, KC_BTN2, KC_BTN3),
	[3] = LAYOUT_split_3x5_3(KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_MPRV, KC_VOLD, KC_VOLU, KC_MNXT, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_MSTP, KC_MPLY, KC_MUTE),
	[4] = LAYOUT_split_3x5_3(KC_LBRC, KC_7, KC_8, KC_9, KC_RBRC, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_SCLN, KC_4, KC_5, KC_6, KC_EQL, KC_NO, KC_LSFT, KC_LCTL, KC_LALT, KC_LGUI, KC_GRV, KC_1, KC_2, KC_3, KC_BSLS, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_DOT, KC_0, KC_MINS, KC_NO, KC_NO, KC_NO),
	[5] = LAYOUT_split_3x5_3(KC_LCBR, KC_AMPR, KC_ASTR, KC_LPRN, KC_RCBR, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_COLN, KC_DLR, KC_PERC, KC_CIRC, KC_PLUS, KC_NO, KC_LSFT, KC_LCTL, KC_LALT, KC_LGUI, KC_TILD, KC_EXLM, KC_AT, KC_HASH, KC_PIPE, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LPRN, KC_RPRN, KC_UNDS, KC_NO, KC_NO, KC_NO),
	[6] = LAYOUT_split_3x5_3(KC_F12, KC_F7, KC_F8, KC_F9, KC_PSCR, KC_NO, KC_NO, KC_NO, KC_NO, QK_BOOT, KC_F11, KC_F4, KC_F5, KC_F6, KC_SCRL, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_F10, KC_F1, KC_F2, KC_F3, KC_PAUS, TO(11), TO(9), TO(8), TO(7), TO(0), KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO),
	[7] = LAYOUT_split_3x5_3(KC_ESC, KC_Q, KC_W, KC_E, KC_F1, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_TAB, KC_A, KC_S, KC_D, KC_F, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LCTL, KC_LSFT, KC_C, KC_M, KC_K, KC_NO, KC_NO, KC_NO, KC_NO, TO(0), KC_1, KC_2, KC_3, KC_NO, KC_NO, KC_NO),
	[8] = LAYOUT_split_3x5_3(KC_SPC, KC_M, KC_W, KC_SLSH, KC_NO, KC_F1, KC_F2, KC_F3, KC_F4, KC_EQL, KC_TAB, KC_A, KC_S, KC_D, KC_H, KC_C, KC_I, KC_J, KC_NO, KC_NO, KC_1, KC_2, KC_3, KC_4, KC_5, KC_NO, KC_NO, KC_NO, KC_NO, TO(0), KC_6, KC_7, KC_8, KC_ESC, KC_F5, KC_F9),
	[9] = LAYOUT_split_3x5_3(KC_ESC, KC_Q, KC_W, KC_E, KC_R, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_TAB, KC_A, KC_S, KC_D, KC_F, KC_H, KC_NO, KC_NO, KC_NO, KC_NO, KC_LCTL, KC_B, KC_C, KC_M, KC_V, KC_NO, KC_NO, KC_NO, KC_NO, TO(0), KC_LALT, KC_SPC, LT(10,KC_LSFT), KC_NO, KC_NO, KC_NO),
	[10] = LAYOUT_split_3x5_3(KC_NO, KC_7, KC_8, KC_9, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_4, KC_5, KC_6, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_1, KC_2, KC_3, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_TRNS, KC_NO, KC_NO, KC_NO),
	[11] = LAYOUT_split_3x5_3(KC_TAB, KC_Q, KC_W, KC_E, KC_R, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_LCTL, KC_A, KC_S, KC_D, KC_G, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_Z, KC_LALT, KC_C, KC_F, KC_V, KC_NO, KC_NO, KC_NO, KC_NO, TO(0), KC_ESC, KC_LSFT, KC_SPC, KC_NO, KC_NO, KC_NO)
};

#if defined(ENCODER_ENABLE) && defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {

};
#endif // defined(ENCODER_ENABLE) && defined(ENCODER_MAP_ENABLE)





