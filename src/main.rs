// Copyright © 2020 Jose Carlos Venegas Munoz <jose.carlos.venegas.munoz@intel.com>
//
// SPDX-License-Identifier: Apache-2.0 OR MIT
//

//! PROGRAM-SUMMARY

pub fn hello(number: i32) -> i32 {
    println!("Hello");
    number
}

fn main() {
    hello(1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hello() {
        assert_eq!(hello(1), 1);
        assert_eq!(hello(2), 2);
    }
}
