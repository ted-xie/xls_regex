fn donut_regex (bytes: u8[256]) -> u8[256] {
  u8[256]:[u8:3, ...]
}

#![test]
fn donut_test (){
  assert_eq(donut_regex(u8[256]:[u8:123, 0, ...]),
            u8[256]:[u8:3, ...])
}
