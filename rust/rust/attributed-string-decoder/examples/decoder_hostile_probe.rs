use std::time::Instant;

use attributed_string_decoder::api::decode_typedstream_blob;

const NATIVE_BLOB_BUDGET_BYTES: usize = 8 * 1024 * 1024;

fn main() {
    let valid = decode_hex(
        "040B73747265616D747970656481E803840140848484124E534174747269\
         6275746564537472696E67008484084E534F626A65637400859284848408\
         4E53537472696E67019484012B045445535486840269490104928484840C\
         4E5344696374696F6E617279009484016901928496961D5F5F6B494D4D65\
         7373616765506172744174747269627574654E616D658692848484084E53\
         4E756D626572008484074E5356616C7565009484012A84999900868686",
    );
    let mut malformed_length = b"\x04\x0bstreamtyped\x81\xe8\x03".to_vec();
    malformed_length.extend_from_slice(&[0x84, 0x82, 0xff, 0xff, 0xff, 0x7f]);

    let mut random_state = 0x9e37_79b9_u32;
    let random = (0..1024 * 1024)
        .map(|_| {
            random_state = random_state
                .wrapping_mul(1_664_525)
                .wrapping_add(1_013_904_223);
            (random_state >> 24) as u8
        })
        .collect();

    let cases = [
        ("valid", valid.clone()),
        ("empty", Vec::new()),
        ("truncated", valid[..valid.len() / 2].to_vec()),
        ("malformed_length", malformed_length),
        ("deep_control_markers", vec![0x84; 4096]),
        ("recursive_reference_bytes", vec![0xff; 4096]),
        ("random_1_mib", random),
        ("large_8_mib", vec![0_u8; NATIVE_BLOB_BUDGET_BYTES]),
        ("over_limit", vec![0_u8; NATIVE_BLOB_BUDGET_BYTES + 1]),
    ];

    for (name, blob) in cases {
        let blob_bytes = blob.len();
        let started = Instant::now();
        let outcome = if decode_typedstream_blob(blob).is_ok() {
            "decoded"
        } else {
            "decode_unavailable"
        };
        println!(
            "case={name} bytes={blob_bytes} elapsed_micros={} outcome={outcome}",
            started.elapsed().as_micros()
        );
    }
}

fn decode_hex(input: &str) -> Vec<u8> {
    let compact: String = input
        .chars()
        .filter(|character| !character.is_whitespace())
        .collect();
    compact
        .as_bytes()
        .chunks_exact(2)
        .map(|chunk| {
            let pair = std::str::from_utf8(chunk).unwrap();
            u8::from_str_radix(pair, 16).unwrap()
        })
        .collect()
}
