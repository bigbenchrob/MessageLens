# Inside `imessage-exporter`: Reverse Engineering Apple's `typedstream` Format

**Source:** https://chrissardegna.com/blog/reverse-engineering-apples-typedstream-format/  
**Author:** Christopher Sardegna (@rxcs)  
**Date:** January 31, 2025

---

## Table of Contents

- [iMessage Data Extraction](#imessage-data-extraction)
  - [Identifying the Message Storage Format](#identifying-the-message-storage-format)
  - [`typedstream` Origins](#typedstream-origins)
- [Understanding the Format](#understanding-the-format)
  - [Header](#header)
  - [Visible Patterns](#visible-patterns)
  - [Assumptions so Far](#assumptions-so-far)
  - [Inheritance](#inheritance)
  - [Stumbling Across the Type Cache](#stumbling-across-the-type-cache)
  - [Updating our Assumptions](#updating-our-assumptions)
  - [Discovering a Second Cache](#discovering-a-second-cache)
  - [Putting it All Together](#putting-it-all-together)
  - [Format Specification Summary](#format-specification-summary)
- [Using Decoded `typedstream` Data](#using-decoded-typedstream-data)
  - [Data Representations](#data-representations)
  - [Using the Data](#using-the-data)
- [Conclusion](#conclusion)

---

## iMessage Data Extraction

### Identifying the Message Storage Format

In the iMessage database, message body data is stored in a `BLOB` column called `attributedBody` that appears to describe an instance of a [NSMutableAttributedString](https://developer.apple.com/documentation/foundation/nsmutableattributedstring).

If we save a blob into a file called `sample` and inspect it with the `file` program, it emits:

```bash
❯ file sample
sample: NeXT/Apple typedstream data, little endian, version 4, system 1000
```

The system recognizes this blob, so let's examine its contents.

### `typedstream` Origins

The `typedstream` format is a binary serialization protocol designed for `C` and `Objective-C` data structures. It is primarily used by Apple's `Foundation` framework, [specifically](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Articles/archives.html#//apple_ref/doc/uid/20000946-BAJDBJAI) within their internal implementation of `NSArchiver` and `NSUnarchiver`. While those classes are the public APIs, `typedstream` is the underlying implementation detail.

The format itself is not part of the official `Foundation` specification, meaning other implementations use [different approaches](https://github.com/gnustep/libs-base/blob/master/Source/NSArchiver.m). This also means Apple's `typedstream` remains largely undocumented: it was never intended to be a cross-platform standard, rather it is Apple's internal solution for object serialization. In fact, archived documentation makes [no reference](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Archiving.html#//apple_ref/doc/uid/10000047-SW1) to the `typedstream` format or its implementation.

[imessage-exporter](https://github.com/ReagentX/imessage-exporter)'s goal is to provide the most comprehensive representation of iMessage data available. Message data is stored in a [legacy](https://developer.apple.com/documentation/foundation/nsarchiver) format that appears to be a stream that represents objects.

Originally, `imessage-exporter` used a [naive algorithm](https://github.com/ReagentX/imessage-exporter/blob/8ccf7321ab3a432fa6acea613571d359e0b284e4/imessage-database/src/util/streamtyped.rs#L11-L71) to extract text data from this blob and inferred other context from the surrounding table data. However, as Apple introduced new iMessage features, additional information was stored only in this blob.

Since `typedstream` contains critical message content, `imessage-exporter` must understand the format in a platform-agnostic way. This post explores the reverse engineering process, revealing the structure and logic behind this proprietary binary serialization protocol.

---

## Understanding the Format

An example of a simple iMessage `attributedBody` looks like:

```
00000000  04 0b 73 74 72 65 61 6d  74 79 70 65 64 81 e8 03  |..streamtyped...|
00000010  84 01 40 84 84 84 19 4e  53 4d 75 74 61 62 6c 65  |..@....NSMutable|
00000020  41 74 74 72 69 62 75 74  65 64 53 74 72 69 6e 67  |AttributedString|
00000030  00 84 84 12 4e 53 41 74  74 72 69 62 75 74 65 64  |....NSAttributed|
00000040  53 74 72 69 6e 67 00 84  84 08 4e 53 4f 62 6a 65  |String....NSObje|
00000050  63 74 00 85 92 84 84 84  0f 4e 53 4d 75 74 61 62  |ct.......NSMutab|
00000060  6c 65 53 74 72 69 6e 67  01 84 84 08 4e 53 53 74  |leString....NSSt|
00000070  72 69 6e 67 01 95 84 01  2b 0a 4e 6f 74 65 72 20  |ring....+.Noter |
00000080  74 65 73 74 86 84 02 69  49 01 0a 92 84 84 84 0c  |test...iI.......|
00000090  4e 53 44 69 63 74 69 6f  6e 61 72 79 00 95 84 01  |NSDictionary....|
000000a0  69 01 92 84 98 98 1d 5f  5f 6b 49 4d 4d 65 73 73  |i......__kIMMess|
000000b0  61 67 65 50 61 72 74 41  74 74 72 69 62 75 74 65  |agePartAttribute|
000000c0  4e 61 6d 65 86 92 84 84  84 08 4e 53 4e 75 6d 62  |Name......NSNumb|
000000d0  65 72 00 84 84 07 4e 53  56 61 6c 75 65 00 95 84  |er....NSValue...|
000000e0  01 2a 84 9b 9b 00 86 86  86                       |.*.......       |
```

After extracting several samples, we can start to infer some patterns from this data.

### Header

The first 16 bytes are always identical and appear to be some sort of header describing the data structure:

```
00000000  04 0b 73 74 72 65 61 6d  74 79 70 65 64 81 e8 03  |..streamtyped...|
```

Breaking this down, we see 2 bytes `04 0b`, 11 bytes representing the text `streamtyped`, and 3 bytes `81 e8 03`. Interestingly, `0x0b` is 11, which suggests that it describes the length of the data that follows it, leaving us with two unknowns to investigate: the first `0x04`, and the final `81 e8 03`.

Let's re-examine the output of the `file` command:

```
NeXT/Apple typedstream data, little endian, version 4, system 1000
```

The first header byte, `0x04`, matches the version emitted by `file`, and the last two bytes `e8 03` form `1000` as `u16`, leaving `0x81` to solve for.

### Visible Patterns

Each legible text segment in the `typedstream` is preceded by a byte sequence like `84 xx`, where `xx` varies depending on the data. Strings sometimes end in `0x00`, suggesting null-termination. For example:

```
00000010  84 01 40 84 84 84 19 4e  53 4d 75 74 61 62 6c 65  |..@....NSMutable|
00000020  41 74 74 72 69 62 75 74  65 64 53 74 72 69 6e 67  |AttributedString|
00000030  00 84 84 12 4e 53 41 74  74 72 69 62 75 74 65 64  |....NSAttributed|
00000040  53 74 72 69 6e 67 00                              |String.         |
```

Before `NSMutableAttributedString`, we see `84 19`, where `0x19` is 25, the length of the string. Similarly, `NSAttributedString` is prepended by `84 12`, where again `0x12` matches the length of the data.

This pattern suggests that `0x84` signals the beginning of a new data block, and the subsequent byte represents how much data that block contains. Given these are class names, it appears to be some metadata block describing classes, but not the data that the classes contain.

#### Embedded Data

Objects contain more than just class names; they also have fields that contain data owned by the object. The first class name we encounter–`NSMutableAttributedString`–is documented by Apple, and includes a field that [contains](https://developer.apple.com/documentation/foundation/nsmutableattributedstring/1416955-mutablestring) the string data.

Following the pattern we saw above, let's find the first `0x84` before the message's text:

```
00000070                    84 01  2b 0a 4e 6f 74 65 72 20  |      ..+.Noter |
00000080  74 65 73 74 86                                    |test.           |
```

`0x84` denotes some type of new data, but the next byte `0x01` suggests we only need to read one more byte of data: `0x2b`, which happens to be the char `+`. However, the subsequent byte `0a` matches the length of the message text: `"Noter test "`. The final byte, `0x86`, is also repeated at the very end of the stream, suggesting it may indicate the end of some data.

#### Another Pattern Emerges

Continuing from our prior assumptions, we see this short blob:

```
00000080                 84 02 69  49 01 0A                 |     ..iI..     |
```

The `84 02` suggests we need to read two bytes, `0x69` and `0x49`, which happen to be `i` and `I`. Twice now the stream has a pattern where `0x84` seems to denote some data type, so let's take a look at the `NSMutableAttributedString` [documentation](https://developer.apple.com/documentation/foundation/nsmutableattributedstring) and see if there are any clues:

> The primitive `setAttributes(_:range:)` method sets attributes and values for a given range of characters, replacing any previous attributes and values for that range.

Under the [changing attributes](https://developer.apple.com/documentation/foundation/nsmutableattributedstring#1653959) section, many of the methods receive a parameter like `range: NSRange`. Per the [documentation](https://developer.apple.com/documentation/foundation/nsrange), `NSRange` encodes a `location` integer and a `length` integer.

The `i` in integer stands out now, because the new data `iI` in the stream seems to indicate that we are meant to read a pair of integers. The bytes `01 0A` follow, where `0A` matches the message length and `01` appears to represent the starting character index, suggesting this sequence defines an `NSRange` spanning the complete message.

The fields for these range objects aren't documented, indicating they're likely private class members. The `typedstream` format's deterministic packing ensures `NSRange`s consistently store their `location` and `length` values in sequence, probably as different integer types.

#### Solving the `+` Mystery

Let's translate the stream of bytes into plain language given our current assumptions:

```
00000080                 84 02 69  49 01 0A                 |     ..iI..     |
```

We can read this as "a new data type of two bytes, `iI`, followed by the packed field data of `1` and `10`". The data appears to be stored as `u8` since it is only one byte, but that leaves an open question as to how the stream can store larger values.

Ignoring that caveat for now, let's apply that logic to the message text field:

```
00000070                    84 01  2b 0a 4e 6f 74 65 72 20  |      ..+.Noter |
00000080  74 65 73 74 86                                    |test.           |
```

We can read this as "new data type of 1 byte, `+`, followed by the field data for a string of `0x0a` length."

There is one other instance of this pattern early on, right before the class names appear:

```
00000010  84 01 40 84 84 84 19 4e  53 4d 75 74 61 62 6c 65  |..@....NSMutable|
```

Since the data following this initial `0x84` appears to describe the class names, the 1 byte `0x40` (`@`) may indicate the start of a new object instance.

### Assumptions so Far

- `0x84` indicates the start of some data blob
- `0x86` indicates the end of some data blob
- `0x81` indicates something that we don't know yet
- The byte following `0x84` denotes the length of the data blob
- Sometimes, there are bytes that describe packed field data:
  - `i` and `I` seem to indicate an integer value `u8`
  - `+` seems to indicate a string
  - `@` seems to indicate a new object instance
- Class names are null-terminated
- Class field data is packed in order at the end of the definition

### Inheritance

There are several places where multiple `0x84`s bytes appear together, possibly indicating a nested structure. Let's isolate the first major block that appears to define the `NSMutableAttributedString`:

```
00000010  84 01 40 84 84 84 19 4e  53 4d 75 74 61 62 6c 65  |..@....NSMutable|
00000020  41 74 74 72 69 62 75 74  65 64 53 74 72 69 6e 67  |AttributedString|
00000030  00 84 84 12 4e 53 41 74  74 72 69 62 75 74 65 64  |....NSAttributed|
00000040  53 74 72 69 6e 67 00 84  84 08 4e 53 4f 62 6a 65  |String....NSObje|
00000050  63 74 00 85 92 84 84 84  0f 4e 53 4d 75 74 61 62  |ct.......NSMutab|
00000060  6c 65 53 74 72 69 6e 67  01 84 84 08 4e 53 53 74  |leString....NSSt|
00000070  72 69 6e 67 01 95 84 01  2b 0a 4e 6f 74 65 72 20  |ring....+.Noter |
00000080  74 65 73 74 86                                    |test.           |
```

Operating under the assumption that the first 3 bytes tell us we are looking at a new object instance, we see 3 `0x84`s proceeding 3 strings that look like class names: `NSMutableAttributedString`, `NSAttributedString`, and `NSObject`. Continuing further, we see 3 more `0x84`s followed by 2 more class names, `NSMutableString` and `NSString`, and the interior string data.

These two blocks are separated by an `0x85`. Given we assume `0x84` is a start byte and `0x86` is an end byte, it is likely that `0x85` has some special meaning. Checking the `NSMutableAttributedString` [docs](https://developer.apple.com/documentation/foundation/nsmutableattributedstring) again, we see that `NSMutableAttributedString` inherits from `NSAttributedString`, and its only field contains a `NSMutableString`, which [inherits](https://developer.apple.com/documentation/foundation/nsmutablestring) from `NSString`.

We can infer that `0x85` serves as an end token, perhaps a terminator or something similar, as it seems to separate the class hierarchy from its field data.

#### Assembling Nested Data

This leaves us with a few bits of missing data. Class names end with a single byte, here `0x01` or `0x00`. Previously, the assumption was that names were null terminated, but perhaps this is class data or some type of version number. Immediately after the `0x85`, there is a `0x92` that we are ignoring for now. Further, there is a `0x95` that seems to take the place of what should be a third part to the second class hierarchy:

```
└── NSMutableAttributedString (v0)
    ├── Superclass Chain
    │   └── NSAttributedString (v0)
    │       └── NSObject (v0)
    │           └── 0x85
    │
    └── Fields
        └── NSMutableString (v1)
            ├── Superclass Chain
            │   └── NSString (v1)
            │       └── 0x95
            │
            └── Fields
                └── "Noter test "
```

We know that `NSString` [extends](https://developer.apple.com/documentation/foundation/nsstring?language=objc) `NSObject`, so even though no bytes explicitly indicate this relationship, it must be represented somehow. But how can we confirm that?

### Stumbling Across the Type Cache

The `0x92` and `0x95` must mean something. They are only 3 values apart, and they appear in places where we would expect something else to occur: The first time we saw `84 84 84`, it was prepended by `84 01 40` (`@`), which we are assuming represents the start of a new object instance. However, the second time we saw that same pattern, it was prepended by `0x92`. We also know that `NSString` [inherits](https://developer.apple.com/documentation/foundation/nsstring) from `NSObject`, but instead the stream contains `0x95`.

There has to be a pattern here, so let's look at the data every time we see a new `0x84` in the stream to see if we can discern anything. Beginning after the header and ending before the known encoded message content, we have the following:

| Index | Value |
|-------|-------|
| 1 | @ |
| 2 | NSMutableAttributedString |
| 3 | NSAttributedString |
| 4 | NSObject |
| 5 | NSMutableString |
| 6 | NSString |

#### Assembling the Cache

Our intuition tells us that where we see `0x92`, we should be `84 01 40` (the start of a a new object), and where we see `0x95`, we should see the `NSObject` bytes. Just as `0x92` and `0x95` are 3 values apart, so are `@` and `NSObject` in the order of streamed data. Could these bytes represent an index?

If we assume that `0x92` is the first index, we get the following:

| Index | Byte | Value |
|-------|------|-------|
| 1 | 0x92 | @ |
| 2 | 0x93 | NSMutableAttributedString |
| 3 | 0x94 | NSAttributedString |
| 4 | 0x95 | NSObject |
| 5 | 0x96 | NSMutableString |
| 6 | 0x97 | NSString |

The indexes `0x92` and `0x95` appear to point to our missing data! Let's reassemble our object with this in mind:

```
└── NSMutableAttributedString (v0)
    ├── Superclass Chain
    │   └── NSAttributedString (v0)
    │       └── NSObject (v0)
    │           └── 0x85
    │
    └── Fields
        └── NSMutableString (v1)
            ├── Superclass Chain
            │   └── NSString (v1)
            │       └── NSObject (v0)
            │           └── 0x85
            │
            └── Fields
                └── "Noter test "
```

This indicates that `0x92` and larger values indicate the index in a cache of previously-seen data.

### Updating our Assumptions

- `0x84` indicates the start of a data blob
  - The byte following `0x84` denotes the length of the data blob
- `0x85` indicates the end of a class inheritance chain
- `0x86` indicates the end of a data blob
- `0x81` indicates something that we don't know yet, but seems to be related to integers
- In order of appearance, new blobs are stored in a cache
  - The first index is `0x92`, and references are stored in the stream directly
- Sometimes, there are bytes that describe packed field data:
  - `i` and `I` seem to indicate an integer value `u8`
  - `+` seems to indicate a string
  - `@` seems to indicate a new object instance
  - `*` seems to indicate some unknown data type
- Class names are followed by some `u8` version information
- Class field data is packed in order at the end of the definition

#### Defining Terms

Leveraging our assumptions, we can define a few concepts:

1. **Type Tags**: Bytes like `+`, `@`, and the like seem to define primitive types like integers and strings. Since these define data that is packed together, let's think of them as a group like `Vec<Type>`.
   - For example, the earlier `iI` would be a type tag like `[Int, Int]`.
   - We can reference these type tags by index in order of appearance, so we can enclose that type tag as a larger vector like `Vec<Vec<Type>>`.
2. **Indicators**: Bytes like `0x81` and `0x84..0x86` seem to have specific meanings, indicating that we are meant to read the subsequent data in a specific way.
3. **Archivable Objects**: As we read the stream, we find class inheritance hierarchies that pertain to specific object instances

#### Testing the Theory

In order of appearance, the type tags thus far are:

| Index | Type Tag |
|-------|----------|
| 0x92 | [@] |
| 0x93 | [String("NSMutableAttributedString")] |
| 0x94 | [String("NSAttributedString")] |
| 0x95 | [String("NSObject")] |
| 0x96 | [String("NSMutableString")] |
| 0x97 | [String("NSString")] |
| 0x98 | [+] |
| 0x99 | [i, I] |
| 0x9a | [String("NSDictionary")] |
| 0x9b | [i] |

And the archivable objects stored in the stream:

| Index | Object |
|-------|--------|
| 1 | Top-level object container |
| 2 | Class { name: "NSMutableAttributedString", version: 0, ... } |
| 3 | Class { name: "NSAttributedString", version: 0, ... } |
| 4 | Class { name: "NSObject", version: 0} |
| 5 | Object(Class { name: "NSMutableString", version: 1, ... }, [String("Noter test")]) |
| 6 | Class { name: "NSMutableString", version: 1, ... } |
| 7 | Class { name: "NSString", version: 1, ... } |
| 8 | Object(Class { name: "NSDictionary", version: 0, ... }, [SignedInteger(1)]) |
| 9 | Class { name: "NSDictionary", version: 0, ... } |

### Discovering a Second Cache

One thing that stands out later in the stream are these bytes:

```
000000a0  69 01 92 84 98 98 1d 5f  5f 6b 49 4d 4d 65 73 73  |i......__kIMMess|
```

Given our assumptions, we can read the first half of this slice:

- `0x92` refers to `@` in the type tags table, indicating a new object
- `0x84` indicates we want to start a new blob of data

The remaining two `0x98` are pointers, but to what? In the type tag table, `0x98` points to `+`, but it wouldn't make sense to have two type tags referenced together, as a type tag can already have multiple types within it.

#### Building the Archivable Object Cache

So far, we have some readable object instances and some class hierarchies defined in inheritance order. One thing that stands out is that `0x98`, what we previously thought was a type tag reference, also aligns with an entry in the archivable objects table. If we instead number the output starting at `0x92`, we get:

| Index | Object |
|-------|--------|
| 0x92 | Top-level object container |
| 0x93 | Class { name: "NSMutableAttributedString", version: 0, ... } |
| 0x94 | Class { name: "NSAttributedString", version: 0, ... } |
| 0x95 | Class { name: "NSObject", version: 0} |
| 0x96 | Object(Class { name: "NSMutableString", version: 1 }, [String("Noter test")]) |
| 0x97 | Class { name: "NSMutableString", version: 1, ... } |
| 0x98 | Class { name: "NSString", version: 1, ... } |
| 0x99 | Object(Class { name: "NSDictionary", version: 0, ... }, [SignedInteger(1)]) |
| 0x9a | Class { name: "NSDictionary", version: 0, ... } |

This makes a lot more sense: the first `0x98` isn't referencing the type tag `[+]`, rather it is referencing the `NSString` class at `0x98`. The subsequent `0x98`, then, denotes the data associated with that class instance. Further, our `0x95` from earlier is not simply referencing the string `"NSObject"`, rather it is referencing the specific `NSObject` class that contains `0x85` as its parent.

#### Using the Archivable Object Cache

With this new assumption, we can now read the rest of the data in the slice:

- `0x92` refers to `@` in the type tags table, indicating a new object
- `0x84` indicates we want to start a new blob of data
- `0x98` refers to the `NSString` class
- `0x98` refers to `+`, indicating we should read the next data as a string

Thus, we can read this slice as "new `NSString` object, whose field data is encoded as `+`."

This logic also follows the pattern we see with string length bytes. Just as with the text after the first `+`, the bytes after the referenced `+` start with a byte that tells us the length of the string (here, `0x1d`, or `29`):

```
000000a0  69 01 92 84 98 98 1d 5f  5f 6b 49 4d 4d 65 73 73  |i......__kIMMess|
000000b0  61 67 65 50 61 72 74 41  74 74 72 69 62 75 74 65  |agePartAttribute|
000000c0  4e 61 6d 65 86 92 84 84  84 08 4e 53 4e 75 6d 62  |Name......NSNumb|
```

Let's assemble this object:

```
└── NSString (v1)
    ├── Superclass Chain
    │   └── NSObject (v0)
    │       └── 0x85
    │
    └── Fields
        └── "__kIMMessagePartAttributeName"
```

The class comes from the data referenced by `0x98` in the archivable objects table. The string `__kIMMessagePartAttributeName` is the data owned by this instance of `NSString`, encoded in the stream as `+`.

### Putting it All Together

Let's isolate the last part of the stream that appears to define a `NSDictionary` object to see if our assumptions hold:

```
00000080  74 65 73 74 86 84 02 69  49 01 0a 92 84 84 84 0c  |test...iI.......|
00000090  4e 53 44 69 63 74 69 6f  6e 61 72 79 00 95 84 01  |NSDictionary....|
000000a0  69 01 92 84 98 98 1d 5f  5f 6b 49 4d 4d 65 73 73  |i......__kIMMess|
000000b0  61 67 65 50 61 72 74 41  74 74 72 69 62 75 74 65  |agePartAttribute|
000000c0  4e 61 6d 65 86 92 84 84  84 08 4e 53 4e 75 6d 62  |Name......NSNumb|
000000d0  65 72 00 84 84 07 4e 53  56 61 6c 75 65 00 95 84  |er....NSValue...|
000000e0  01 2a 84 9b 9b 00 86 86  86                       |.*.......       |
```

The three `0x92` bytes indicate that there should be three objects stored here. Given the provided class names, we can intuit that this slice probably stores a dictionary that looks like:

```
{
    "__kIMMessagePartAttributeName": NSNumber(?)
}
```

#### Translating the Stream - Object 1

Here is the first new object definition:

```
00000080  74 65 73 74 86 84 02 69  49 01 0a 92 84 84 84 0c  |test...iI.......|
00000090  4e 53 44 69 63 74 69 6f  6e 61 72 79 00 95 84 01  |NSDictionary....|
000000a0  69 01 92 84 98 98 1d 5f  5f 6b 49 4d 4d 65 73 73  |i......__kIMMess|
```

And here is how our assumptions apply to that slice:

| Bytes | Meaning | Description |
|-------|---------|-------------|
| 0x84 | Blob Indicator | Signals the start of a new data block |
| 0x0c | Length Byte | Indicates the next 12 bytes contain relevant data |
| NSDictionary | Class Name | The 12 bytes encoding the class name |
| 0x00 | Version Tag | Previously thought to be a null terminator |
| 0x95 | Class | References NSObject in the archivable objects table |
| 0x84 | Blob Indicator | Signals the start of a new data block |
| 0x01 | Length Byte | Indicates the next byte contains relevant data |
| 0x69 | Type Tag | Represents i (likely u8) |
| 0x01 | Dictionary Size | Indicates a single key/value pair |

The final `0x01` may represent something else, but given we can look at the stream and see only a single key/value pair, for now let's assume it represents the length field. Let's visualize what we have so far:

```
└── NSDictionary (v0)
    ├── Superclass Chain
    │   └── NSObject (v0)
    │       └── 0x85
    │
    └── Fields
        └── 0x01
```

#### Translating the Stream - Object 2

This is the `NSString` we parsed earlier:

```
└── NSString (v1)
    ├── Superclass Chain
    │   └── NSObject (v0)
    │       └── 0x85
    │
    └── Fields
        └── String("__kIMMessagePartAttributeName")
```

Given its location in the stream and its prefix of `__k`, let's assume this is the first key in the dictionary and add it to the overall object:

```
└── NSDictionary (v0)
    ├── Superclass Chain
    │   └── NSObject (v0)
    │       └── 0x85
    │
    └── Fields
        ├── 0x01
        └── NSString (v1)
            ├── Superclass Chain
            │   └── NSObject (v0)
            │       └── 0x85
            │
            └── Fields:
                └── String("__kIMMessagePartAttributeName")
```

#### Translating the Stream - Object 3

Finally, let's isolate the last slice of bytes we need to translate:

```
000000c0  4e 61 6d 65 86 92 84 84  84 08 4e 53 4e 75 6d 62  |Name......NSNumb|
000000d0  65 72 00 84 84 07 4e 53  56 61 6c 75 65 00 95 84  |er....NSValue...|
000000e0  01 2a 84 9b 9b 00 86 86  86                       |.*.......       |
```

Most of this we have already seen: until address `0xdf`, the stream encodes the inheritance hierarchy for `NSNumber`:

```
└── NSNumber (v0)
    ├── Superclass Chain
    │   └── NSValue (v0)
    │       └── NSObject (v0)
    │           └── 0x85
    │
    └── Fields
        └── ?
```

However, where we expect the field data, we see a byte pattern indicating a new type tag `*`. Checking the `NSNumber` [documentation](https://developer.apple.com/documentation/foundation/nsnumber?language=objc#1776615), we can start to chase these type tags down. The docs make an offhand mention of these tags:

> 1. Your implementation of [objCType](https://developer.apple.com/documentation/foundation/nsvalue/1412365-objctype?language=objc) must return one of "c", "C", "s", "S", "i", "I", "l", "L", "q", "Q", "f", and "d". This is required for the other methods of `NSNumber` to behave correctly.
> 2. Your subclass must override the accessor method that corresponds to the declared type—for example, if your implementation of `objCType` returns "i", you must override `intValue`.

This confirms our prior hypothesis that `i` (and probably `I`) tell the stream that the following data is an integer! However, the documentation for [objCType](https://developer.apple.com/documentation/foundation/nsvalue/1412365-objctype?language=objc) doesn't have much information about what these characters mean. [Searching](https://kagi.com/search?q=site%3Aapple.com++%22%40encode%22&r=us&sh=niRuA-WBujycClDVm26K8g) for `site:apple.com "@encode"`, we find [this](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Articles/codingobjects.html) archived documentation pointing to a book called The Objective-C Programming Language.

In that book, we land upon a [table](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1) of enumerated type encodings. That table confirms that `i` and `I` do represent integers, signed and unsigned, respectively. It also tells us that this mystery `*` refers to "A character string `(char *)".

So far, we know that `NSNumber` extends `NSValue`, specifically dealing with numeric variants. We also know that `NSValue` uses `objCType` to represent the type it encapsulates internally. The `objCType` documentation states that it is:

> A `C` string containing the `Objective-C` type of the data contained in the value object.

Thus, it seems like the data that follows `*` should be read as a type tag describing the data that follows. Let's isolate just that block:

```
000000d0  65 72 00 84 84 07 4e 53  56 61 6c 75 65 00 95 84  |er....NSValue...|
000000e0  01 2a 84 9b 9b 00 86 86  86                       |.*.......       |
```

Translating this following our assumptions, we get the following result:

| Bytes | Meaning | Description |
|-------|---------|-------------|
| 0x84 | Blob Indicator | Signals the start of a new data block |
| 0x01 | Type Tag | * |
| 0x84 | Blob Indicator | Signals the start of a new data block |
| 0x9b | Type Tag Reference | i |
| 0x9b | Type Tag Reference | i |
| 0x00 | Signed Integer | 0 |
| 0x86 | End of Object Indicator | Signals the end of the new object |

This sequence represents an `NSNumber` object containing an integer value. Like other object instances in the stream, the object's data follows its class definition. Here, the first `0x9b` represents the `objCType` of the `NSValue` instance. Because it is larger than `0x92`, we look it up in the type tags table. This means our `NSValue` represents the `objCType` of `i`, or a signed integer.

The second `0x9b` references a type tag in the type tags table, indicating that the next byte (`0x00`) should be read as a signed integer. Both of these values refer to the same type tag, `i`, but they use that type tag in different ways: the first one tells us what type of data the `NSValue` instance owns, and the second tells us how to read the next byte from the stream.

The object structure can be represented as:

```
└── NSNumber (v0)
    ├── Superclass Chain
    │   └── NSValue (v0)
    │       └── NSObject (v0)
    │           └── 0x85
    │
    └── Fields
        └── SignedInteger(0x00)
```

#### The Whole Dictionary

Combining all of what we have translated, the resultant dictionary looks like this:

```
└── NSDictionary (v0)
    ├── Superclass Chain
    │   └── NSObject (v0)
    │       └── 0x85
    │
    └── Fields
        ├── SignedInteger(0x01)
        ├── NSString (v1)
        │   ├── Superclass Chain
        │   │   └── NSObject (v0)
        │   │       └── 0x85
        │   │
        │   └── Fields:
        │       └── "__kIMMessagePartAttributeName"
        └── NSNumber (v0)
            ├── Superclass Chain
            │   └── NSValue (v0)
            │       └── NSObject (v0)
            │           └── 0x85
            │
            └── Fields
                └── SignedInteger(0x00)
```

This confirms that the stream encodes a dictionary with a single key-value pair, as expected.

### Format Specification Summary

Through systematic analysis and validation of our assumptions against the data samples, we can now attempt to describe the `typedstream` specification's core structure and behavior.

#### Updating Assumptions Again

First, let's update our assumptions based on what we have learned:

- **Type Tags**
  - Primitive types in the stream are prefixed by a type tag or a reference to a type tag, as [defined](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1) in the Objective-C Runtime Programming Guide
  - As we find them, distinct type tags are cached in a table and referenced by index
- **Indicators**
  - `0x84` indicates the start of a data blob
    - The byte following `0x84` denotes the length of the data blob
    - If the byte is `0x92` or larger, it indicates a reference to a type tag stored in the type tags table
  - `0x85` indicates the end of a class inheritance chain
  - `0x86` indicates the end of a data blob
  - `0x81` indicates something related to integers
  - There are probably more indicators, likely in the range `0x81..0x86`
- **Archivable Objects**
  - In order of inheritance, new objects and classes are stored in a cache of archivable objects
    - Similar to type tags, the first index is `0x92`, and references are stored in the stream directly
  - Class names are followed by some `u8` version information
  - Class field data is packed in order at the end of the definition

##### Discovering more Indicators

###### Indicator `0x81`

Aside from the header, this byte showed up in several very long iMessages:

```
00000070  72 69 6e 67 01 95 84 01  2b 81 37 09 53 65 64 20  |ring....+.7.Sed |
```

This sample contained a message with `2359` characters. The bytes following `0x81` are `0x37 0x09`, which represent that value as a 16-bit integer. This also matches our header, which we know ends with the bytes for `1000`, confirming that `0x81` indicates a 16-bit integer follows.

```
00000000  04 0b 73 74 72 65 61 6d  74 79 70 65 64 81 e8 03  |..streamtyped...|
```

###### Inferring Other Indicators

`0x82` and `0x83` were not in any samples, but continuing from the pattern, we can infer that since `0x81` represents a 2-byte (`u16`/`i16`) integer, `0x82` and `0x83` also refer to different width numbers. Going back to the [table](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1) defined in the Objective-C Runtime Programming Guide, we can use the type tags to infer the meaning of these indicators:

| Type | Description | Indicator |
|------|-------------|-----------|
| i | An int | None |
| s | A short | 0x81 |
| l | A long (l is treated as a 32-bit quantity on 64-bit programs) | 0x82 |
| q | A long long | 0x83 |

The type tag determines whether the integer is signed or unsigned, while the presence and value of the indicator byte determines the integer's width in the stream. We can use this to predict the byte representation we might see:

| Example | Description |
|---------|-------------|
| 0x69 0x00 | Integer, single byte width = 0 as i8 |
| 0x69 0x81 0x37 0x09 | Integer, two-byte width = 2359 as i16 |
| 0x49 0x81 0x37 0x09 | Unsigned Integer, two-byte width = 2359 as u16 |
| 0x49 0x81 0xe8 0x03 | Unsigned Integer, two-byte width = 1000 as u16 |

In order to confirm this, we would need more sample data that included values of these sizes.

#### Defining Format Rules

Given this information, we can write a simple set of steps as a baseline for reading this format:

1. Validate the header
2. `0x84` indicates we are creating a new piece of archivable data
   - If the subsequent byte is `0x92` or greater, we have a reference to a previously-seen object or class
   - If the subsequent byte less than `0x92`, it describes the length of the object or class data
3. Objects are stored in the following order:
   - The class hierarchy, including inheritance
   - The field data owned by the class
   - Field names are not stored, but their data is always stored in the same order
4. As we encounter new objects, add them to a table of archivable objects
5. As we encounter new type tags, add them to a table of type tags

---

## Using Decoded `typedstream` Data

Now that we understand how to read a `typedstream`, we need to think about how to use and represent it in `imessage-exporter`.

Since the stream encodes `Objective-C` data structures, specifically instances of classes and the data they own, we can use these rules to yield objects out of the stream. `imessage-exporter` does this, then reads the objects as they are yielded to build a message's [components](https://docs.rs/imessage-database/latest/imessage_database/tables/messages/models/enum.BubbleComponent.html).

### Data Representations

Since non-Apple platforms do not natively support `Foundation` data structures, we must define an alternative representation.

#### Type Tags

We can define an enum to represent the known type tags. Given the legacy documentation and our own observations, this definition should distill it to a single data structure:

```rust
fn from_byte(byte: &u8) -> Self {
    match byte {
        0x40 => Self::Object,
        0x2B => Self::Utf8String,
        0x2A => Self::EmbeddedData,
        0x66 => Self::Float,
        0x64 => Self::Double,
        0x63 | 0x69 | 0x6c | 0x71 | 0x73 => Self::SignedInt,
        0x43 | 0x49 | 0x4c | 0x51 | 0x53 => Self::UnsignedInt,
        other => Self::Unknown(*other),
    }
}
```

Note that `0x2B`, or `+`, is not mentioned in the legacy documentation, but we can infer what the type tag represents based on the context in the collected `typedstream` samples.

This data structure allows us to leverage Rust's pattern matching to dispatch data as we encounter it in the stream. It also implies we need a separate data structure to represent the data stored after these type tags:

```rust
pub enum OutputData {
    String(String),
    SignedInteger(i64),
    UnsignedInteger(u64),
    Float(f32),
    Double(f64),
    Byte(u8),
    Array(Vec<u8>),
    Class(Class),
}
```

By combining these structures, we can implement the serialization logic in Rust as follows:

```rust
fn extract(data_type: Type) -> OutputData {
    match data_type {
        Type::SignedInt => OutputData::SignedInteger(read_signed_int()),
        Type::UnsignedInt => OutputData::UnsignedInteger(read_unsigned_int()),
        Type::Float => OutputData::Float(read_float()),
        _ => ...
    }
}
```

#### Classes

We can define a simple structure that represents the class data stored in the stream:

```rust
pub struct Class {
    pub name: String,
    pub version: u64,
}
```

The only data stored in the stream is the class name and the class version. We can pattern match against these names to build any arbitrary structures later, if necessary.

#### Archivable Objects

We also need to encapsulate the data to store in the archivable object cache. This can be a class, an object, or an object's field data.

```rust
pub enum Archivable {
    Object(Class, Vec<OutputData>),
    Data(Vec<OutputData>),
    Class(Class),
    Type(Vec<Type>),
}
```

An object, for example, contains a specific class, followed by a vector of field data owned by that class's instance. An example of this looks like:

```rust
Archivable::Object(
    Class {
        name: "NSDictionary".to_string(),
        version: 0,
    },
    vec![OutputData::SignedInteger(2)],
)
```

Given what we learned about `NSDictionary`, the `OutputData` here refers to the number of key-value pairs in the dictionary, indicating the next 4 objects yielded from the stream are alternating key-value pairs belonging to this `NSDictionary`.

### Using the Data

The [crabstep](https://github.com/ReagentX/crabstep) crate provides a deserialization [struct](https://docs.rs/crabstep/latest/crabstep/deserializer/typedstream/struct.TypedStreamDeserializer.html) that yields objects and their data from a `typedstream`.

`imessage-exporter` [body](https://github.com/ReagentX/imessage-exporter/blob/develop/imessage-database/src/tables/messages/body.rs) module leverages the foregoing data models to represent attributes of the message body in a data structure called [BubbleComponent](https://docs.rs/imessage-database/latest/imessage_database/tables/messages/models/enum.BubbleComponent.html).

---

## Conclusion

Reverse engineering of Apple's `typedstream` format reveals a sophisticated and elegantly designed binary serialization protocol. Through careful analysis of patterns, documentation fragments, and sample data, we've uncovered a format that efficiently encodes complex object hierarchies.

The resulting implementation in `imessage-exporter` demonstrates how this legacy format can be deserialized, enabling platform-agnostic access to iMessage data that was previously locked within Apple's ecosystem. This work not only enables practical applications like message export and analysis but also serves as a case study in reverse engineering binary formats through pattern recognition and hypothesis testing.

---

## Related Resources

- [imessage-exporter GitHub Repository](https://github.com/ReagentX/imessage-exporter)
- [crabstep crate](https://github.com/ReagentX/crabstep)
- [Apple's NSArchiver Documentation](https://developer.apple.com/documentation/foundation/nsarchiver)
- [Objective-C Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
