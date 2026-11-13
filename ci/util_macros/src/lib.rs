//! Stand-in for Zed's `util_macros`, which is not published with this snapshot.
//!
//! Upstream `#[perf]` adds `#[test]` and, only when the perf harness cfg
//! `perf_enabled` is set, wraps the body in a timed loop. CI and `cargo test`
//! do not set that cfg, so this macro only adds `#[test]`.

use proc_macro::TokenStream;
use quote::ToTokens;
use syn::{ItemFn, parse_macro_input, parse_quote};

#[proc_macro_attribute]
pub fn perf(_attr: TokenStream, input: TokenStream) -> TokenStream {
    let mut func = parse_macro_input!(input as ItemFn);
    let has_test = func.attrs.iter().any(|attr| {
        attr.path()
            .segments
            .last()
            .is_some_and(|segment| segment.ident == "test")
    });
    if !has_test {
        func.attrs.push(parse_quote!(#[test]));
    }
    TokenStream::from(func.into_token_stream())
}
