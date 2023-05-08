/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
    *
  * http://www.apache.org/licenses/LICENSE-2.0
    *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */


export class Unit8ArrayUtils {
    public static Uint8ArrayTostring(array: Uint8Array | null | undefined): string {
        var out, i, len, c;
        var char2, char3;
        let tempAry: Uint8Array = array;
        out = "";
        len = tempAry.length;
        i = 0;
        while (i < len) {
            c = tempAry[i++];
            switch (c >> 4) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                // 0xxxxxxx
                    out += String.fromCharCode(c);
                    break;
                case 12:
                case 13:
                // 110x xxxx   10xx xxxx
                    char2 = tempAry[i++];
                    out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
                    break;
                case 14:
                // 1110 xxxx  10xx xxxx  10xx xxxx
                    char2 = tempAry[i++];
                    char3 = tempAry[i++];
                    out += String.fromCharCode(((c & 0x0F) << 12) |
                    ((char2 & 0x3F) << 6) |
                    ((char3 & 0x3F) << 0));
                    break;
            }
        }
        return out;
    }

    public static stringToUint8Array(string: string) {

        let pos = 0;
        const len = string.length;
        const out = [];
        let at = 0; // output position
        let tlen = Math.max(32, len + (len >> 1) + 7); // 1.5x size
        let target = new Uint8Array((tlen >> 3) << 3); // ... but at 8 byte offset
        while (pos < len) {
            let value = string.charCodeAt(pos++);
            if (value >= 0xd800 && value <= 0xdbff) {
                // high surrogate
                if (pos < len) {
                    const extra = string.charCodeAt(pos);
                    if ((extra & 0xfc00) === 0xdc00) {
                        ++pos;
                        value = ((value & 0x3ff) << 10) + (extra & 0x3ff) + 0x10000;
                    }
                }
                if (value >= 0xd800 && value <= 0xdbff) {
                    continue; // drop lone surrogate
                }
            }
            // expand the buffer if we couldn't write 4 bytes
            if (at + 4 > target.length) {
                tlen += 8; // minimum extra
                tlen *= (1.0 + (pos / string.length) * 2); // take 2x the remaining
                tlen = (tlen >> 3) << 3; // 8 byte offset
                const update = new Uint8Array(tlen);
                update.set(target);
                target = update;
            }
            if ((value & 0xffffff80) === 0) { // 1-byte
                target[at++] = value; // ASCII
                continue;
            } else if ((value & 0xfffff800) === 0) { // 2-byte
                target[at++] = ((value >> 6) & 0x1f) | 0xc0;
            } else if ((value & 0xffff0000) === 0) { // 3-byte
                target[at++] = ((value >> 12) & 0x0f) | 0xe0;
                target[at++] = ((value >> 6) & 0x3f) | 0x80;
            } else if ((value & 0xffe00000) === 0) { // 4-byte
                target[at++] = ((value >> 18) & 0x07) | 0xf0;
                target[at++] = ((value >> 12) & 0x3f) | 0x80;
                target[at++] = ((value >> 6) & 0x3f) | 0x80;
            } else {
                continue;
            }
            target[at++] = (value & 0x3f) | 0x80;
        }
        return target.subarray(0, at);
    }
}
