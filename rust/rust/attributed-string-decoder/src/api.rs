use std::panic::{catch_unwind, AssertUnwindSafe};

use crabstep::{deserializer::iter::Property, TypedStreamDeserializer};
use flutter_rust_bridge::frb; // attribute macros

const MAX_TYPEDSTREAM_BLOB_BYTES: usize = 8 * 1024 * 1024;
// crabstep 0.2.1 contains recursive numeric and object parsing paths. These
// structural limits keep their maximum depth bounded before parsing begins.
const MAX_TYPEDSTREAM_CONTROL_MARKERS: usize = 1024;
const MAX_CONSECUTIVE_REFERENCE_BYTES: usize = 1024;
const MAX_RESOLVED_PROPERTY_DEPTH: usize = 256;
const MAX_RESOLVED_PROPERTY_NODES: usize = 65_536;

/// Synchronous wrapper for typedstream decoding
#[frb(sync)]
pub fn decode_typedstream_blob(blob: Vec<u8>) -> Result<String, String> {
    validate_typedstream_resource_envelope(&blob)?;

    catch_unwind(AssertUnwindSafe(|| decode_typedstream_blob_inner(&blob)))
        .map_err(|_| "Typedstream decoder panicked within the resource envelope".to_string())?
}

fn decode_typedstream_blob_inner(blob: &[u8]) -> Result<String, String> {
    let mut typedstream = TypedStreamDeserializer::new(blob);
    let root = typedstream
        .oxidize()
        .map_err(|error| format!("Failed to parse typedstream: {error}"))?;
    let root_object = typedstream
        .resolve_properties(root)
        .map_err(|error| format!("Failed to resolve typedstream: {error}"))?;

    let mut pending = root_object
        .map(|property| (property, 0_usize))
        .collect::<Vec<_>>();
    let mut resolved_node_count = 0_usize;
    let mut message_text_candidates = Vec::new();
    while let Some((property, depth)) = pending.pop() {
        resolved_node_count += 1;
        if resolved_node_count > MAX_RESOLVED_PROPERTY_NODES {
            return Err(format!(
                "Typedstream property count exceeds the limit of {MAX_RESOLVED_PROPERTY_NODES}"
            ));
        }

        match property {
            Property::Primitive(primitive) => {
                if let Some(value) = primitive.as_str() {
                    if is_message_text_candidate(value) {
                        message_text_candidates.push(value);
                    }
                }
            }
            Property::Group(mut group) => {
                while let Some(child) = group.pop() {
                    pending.push((child, depth));
                }
            }
            Property::Object { data, .. } => {
                let child_depth = depth + 1;
                if child_depth > MAX_RESOLVED_PROPERTY_DEPTH {
                    return Err(format!(
                        "Typedstream property depth exceeds the limit of {MAX_RESOLVED_PROPERTY_DEPTH}"
                    ));
                }
                let mut nested = data.collect::<Vec<_>>();
                while let Some(child) = nested.pop() {
                    pending.push((child, child_depth));
                }
            }
        }
    }

    message_text_candidates
        .pop()
        .map(str::to_string)
        .ok_or_else(|| "No message text found in attributed body blob".to_string())
}

fn validate_typedstream_resource_envelope(blob: &[u8]) -> Result<(), String> {
    if blob.len() > MAX_TYPEDSTREAM_BLOB_BYTES {
        return Err(format!(
            "Typedstream blob size {} exceeds the limit of {MAX_TYPEDSTREAM_BLOB_BYTES} bytes",
            blob.len()
        ));
    }

    let control_marker_count = blob.iter().filter(|byte| **byte == 0x84).count();
    if control_marker_count > MAX_TYPEDSTREAM_CONTROL_MARKERS {
        return Err(format!(
            "Typedstream control-marker count {control_marker_count} exceeds the limit of {MAX_TYPEDSTREAM_CONTROL_MARKERS}"
        ));
    }

    let mut consecutive_reference_bytes = 0_usize;
    for byte in blob {
        if *byte > 0x92 && *byte != 0x86 {
            consecutive_reference_bytes += 1;
            if consecutive_reference_bytes > MAX_CONSECUTIVE_REFERENCE_BYTES {
                return Err(format!(
                    "Typedstream reference-byte run exceeds the limit of {MAX_CONSECUTIVE_REFERENCE_BYTES}"
                ));
            }
        } else {
            consecutive_reference_bytes = 0;
        }
    }

    Ok(())
}

fn is_message_text_candidate(value: &str) -> bool {
    let trimmed = value.trim();
    !trimmed.is_empty() && !trimmed.starts_with("__") && !trimmed.starts_with("NS")
}

/// Rich metadata extracted from URL preview plists
#[frb]
pub struct UrlPreviewMetadata {
    pub title: Option<String>,
    pub summary: Option<String>,
    pub site_name: Option<String>,
    pub image_url: Option<String>,
    pub video_url: Option<String>,
    pub icon_url: Option<String>,
    pub url: Option<String>,
}

/// Parse a binary plist file (typically .pluginpayloadattachment)
/// and extract rich link preview metadata
#[frb(sync)]
pub fn parse_url_preview_plist(file_path: String) -> Result<UrlPreviewMetadata, String> {
    use plist::Value;

    let plist: Value =
        plist::from_file(&file_path).map_err(|e| format!("Failed to parse plist: {}", e))?;

    let mut metadata = UrlPreviewMetadata {
        title: None,
        summary: None,
        site_name: None,
        image_url: None,
        video_url: None,
        icon_url: None,
        url: None,
    };

    // Navigate the plist structure to extract metadata
    if let Value::Dictionary(root) = plist {
        // Try to find rich link metadata
        if let Some(Value::Dictionary(rich_link)) = root.get("richLinkMetadata") {
            extract_from_rich_link(rich_link, &mut metadata);
        }

        // Fallback: check top-level keys
        if let Some(Value::String(title)) = root.get("title") {
            metadata.title = Some(title.clone());
        }
        if let Some(Value::String(summary)) = root.get("summary") {
            metadata.summary = Some(summary.clone());
        }
        if let Some(Value::String(url)) = root.get("URL") {
            metadata.url = Some(url.clone());
        }
        if let Some(Value::String(url)) = root.get("url") {
            metadata.url = Some(url.clone());
        }
    }

    Ok(metadata)
}

fn extract_from_rich_link(dict: &plist::Dictionary, metadata: &mut UrlPreviewMetadata) {
    use plist::Value;

    // Extract title
    if let Some(Value::String(title)) = dict.get("title") {
        metadata.title = Some(title.clone());
    }

    // Extract summary/description
    if let Some(Value::String(summary)) = dict.get("summary") {
        metadata.summary = Some(summary.clone());
    }

    // Extract site name
    if let Some(Value::String(site)) = dict.get("siteName") {
        metadata.site_name = Some(site.clone());
    }

    // Extract URL
    if let Some(Value::String(url)) = dict.get("URL") {
        metadata.url = Some(url.clone());
    }
    if let Some(Value::String(url)) = dict.get("url") {
        metadata.url = Some(url.clone());
    }

    // Extract image URL
    if let Some(Value::Dictionary(image_dict)) = dict.get("image") {
        if let Some(Value::String(img_url)) = image_dict.get("URL") {
            metadata.image_url = Some(img_url.clone());
        }
        if let Some(Value::String(img_url)) = image_dict.get("url") {
            metadata.image_url = Some(img_url.clone());
        }
    }

    // Extract icon URL
    if let Some(Value::Dictionary(icon_dict)) = dict.get("icon") {
        if let Some(Value::String(icon_url)) = icon_dict.get("URL") {
            metadata.icon_url = Some(icon_url.clone());
        }
        if let Some(Value::String(icon_url)) = icon_dict.get("url") {
            metadata.icon_url = Some(icon_url.clone());
        }
    }

    // Extract video URL
    if let Some(Value::Dictionary(video_dict)) = dict.get("video") {
        if let Some(Value::String(vid_url)) = video_dict.get("URL") {
            metadata.video_url = Some(vid_url.clone());
        }
        if let Some(Value::String(vid_url)) = video_dict.get("url") {
            metadata.video_url = Some(vid_url.clone());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{
        decode_typedstream_blob, MAX_CONSECUTIVE_REFERENCE_BYTES, MAX_TYPEDSTREAM_BLOB_BYTES,
        MAX_TYPEDSTREAM_CONTROL_MARKERS,
    };

    #[test]
    fn decodes_message_text_from_attributed_body_blob() {
        let blob = valid_test_blob();

        let decoded = decode_typedstream_blob(blob).unwrap();

        assert_eq!(decoded, "TEST");
    }

    #[test]
    fn rejects_blob_larger_than_the_native_budget() {
        let blob = vec![0_u8; MAX_TYPEDSTREAM_BLOB_BYTES + 1];

        let error = decode_typedstream_blob(blob).unwrap_err();

        assert!(error.contains("blob size"));
    }

    #[test]
    fn rejects_deep_control_marker_input_before_parsing() {
        let blob = vec![0x84; MAX_TYPEDSTREAM_CONTROL_MARKERS + 1];

        let error = decode_typedstream_blob(blob).unwrap_err();

        assert!(error.contains("control-marker count"));
    }

    #[test]
    fn rejects_recursive_reference_byte_input_before_parsing() {
        let blob = vec![0xff; MAX_CONSECUTIVE_REFERENCE_BYTES + 1];

        let error = decode_typedstream_blob(blob).unwrap_err();

        assert!(error.contains("reference-byte run"));
    }

    #[test]
    fn recursive_reference_byte_input_at_the_limit_returns_an_error() {
        let blob = vec![0xff; MAX_CONSECUTIVE_REFERENCE_BYTES];

        assert!(decode_typedstream_blob(blob).is_err());
    }

    #[test]
    fn truncated_valid_blobs_return_without_panicking() {
        let valid_blob = valid_test_blob();

        for prefix_length in 0..valid_blob.len() {
            let _result = decode_typedstream_blob(valid_blob[..prefix_length].to_vec());
        }
    }

    #[test]
    fn malformed_length_and_random_inputs_return_errors() {
        let mut malformed_length = b"\x04\x0bstreamtyped\x81\xe8\x03".to_vec();
        malformed_length.extend_from_slice(&[0x84, 0x82, 0xff, 0xff, 0xff, 0x7f]);
        assert!(decode_typedstream_blob(malformed_length).is_err());

        let mut state = 0x9e37_79b9_u32;
        let random_blob = (0..1024 * 1024)
            .map(|_| {
                state = state.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                (state >> 24) as u8
            })
            .collect();
        assert!(decode_typedstream_blob(random_blob).is_err());
    }

    #[test]
    fn empty_and_large_synthetic_inputs_return_errors() {
        assert!(decode_typedstream_blob(Vec::new()).is_err());
        assert!(decode_typedstream_blob(vec![0_u8; MAX_TYPEDSTREAM_BLOB_BYTES]).is_err());
    }

    fn valid_test_blob() -> Vec<u8> {
        decode_hex(
            "040B73747265616D747970656481E803840140848484124E534174747269\
             6275746564537472696E67008484084E534F626A65637400859284848408\
             4E53537472696E67019484012B045445535486840269490104928484840C\
             4E5344696374696F6E617279009484016901928496961D5F5F6B494D4D65\
             7373616765506172744174747269627574654E616D658692848484084E53\
             4E756D626572008484074E5356616C7565009484012A84999900868686",
        )
    }

    fn decode_hex(input: &str) -> Vec<u8> {
        let compact: String = input.chars().filter(|c| !c.is_whitespace()).collect();
        compact
            .as_bytes()
            .chunks_exact(2)
            .map(|chunk| {
                let pair = std::str::from_utf8(chunk).unwrap();
                u8::from_str_radix(pair, 16).unwrap()
            })
            .collect()
    }
}
