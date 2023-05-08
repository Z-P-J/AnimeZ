/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Property } from '../Property'

export class SqlUtils {
    private static HEX_ARRAY: string[] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];

    public static appendProperty(builder: string, tablePrefix: string, property: Property): string {
        if (tablePrefix != null) {
            builder = builder.concat(tablePrefix).concat('.');
        }
        builder = builder.concat(property.columnName.toString());

        return builder;
    }

    public static appendColumn(builder: string, column: string): string{
        builder = builder.concat(column);
        return builder;
    }

    public static appendColumn2(builder: string, tableAlias: string, column: string): string{
        builder = builder.concat(tableAlias).concat(".").concat(column);
        return builder;
    }

    public static appendColumns(builder: string, tableAlias: string, columns: string[]): string {
        let length = columns.length;
        for (let i = 0; i < length; i++) {
            builder = this.appendColumn2(builder, tableAlias, columns[i]);
            if (i < length - 1) {
                builder = builder.concat(',');
            }
        }
        return builder;
    }

    public static appendColumns2(builder: string, columns: string[]): string {
        let length = columns.length;
        for (let i = 0; i < length; i++) {
            builder = builder.concat(columns[i]);
            if (i < length - 1) {
                builder = builder.concat(',');
            }
        }
        return builder;
    }

    public static appendPlaceholders(builder: string, count: number): string{
        for (let i = 0; i < count; i++) {
            if (i < count - 1) {
                builder = builder.concat("?,");
            } else {
                builder = builder.concat('?');
            }
        }
        return builder;
    }

    public static appendColumnsEqualPlaceholders(builder: string, columns: string[]): string{
        for (let i = 0; i < columns.length; i++) {
            builder = this.appendColumn(builder, columns[i]).concat("=?");
            if (i < columns.length - 1) {
                builder = builder.concat(',');
            }
        }
        return builder;
    }

    public static appendColumnsEqValue(builder: string, tableAlias: string, columns: string[]): string{

        for (let i = 0; i < columns.length; i++) {
            builder = this.appendColumn2(builder, tableAlias, columns[i]).concat("=?");
            if (i < columns.length - 1) {
                builder = builder.concat(',');
            }
        }
        return builder;
    }

    public static createSqlInsert(insertInto: string, tablename: string, columns: string[]): string{
        let builder = insertInto;
        builder = builder.concat(tablename).concat(" (");
        builder = this.appendColumns2(builder, columns);
        builder = builder.concat(") VALUES (");
        builder = this.appendPlaceholders(builder, columns.length);
        builder = builder.concat(')');
        return builder.toString();
    }

    /** Creates an select for given columns with a trailing space */
    public static createSqlSelect(tablename: string, tableAlias: string, columns: string[], distinct: boolean): string {
        if (tableAlias == null || tableAlias.length < 0) {
            throw new Error("Table alias required");
        }

        let builder = distinct ? "SELECT DISTINCT " : "SELECT ";
        builder = SqlUtils.appendColumns(builder, tableAlias, columns).concat(" FROM ");
        builder = builder
            .concat(tablename)
            .concat(' ')
            .concat(tableAlias)
            .concat(' ');
        return builder.toString();
    }

    /** Creates SELECT COUNT(*) with a trailing space. */
    public static createSqlSelectCountStar(tablename: string, tableAliasOrNull: string): string {
        let builder = "SELECT COUNT(*) FROM ";
        builder = builder.concat('"').concat(tablename).concat('"').concat(' ');
        if (tableAliasOrNull != null) {
            builder = builder.concat(tableAliasOrNull).concat(' ');
        }
        return builder.toString();
    }

    /** Remember: SQLite does not support joins nor table alias for DELETE. */
    public static createSqlDelete(tablename: string, columns: string[]): string {
        let quotedTablename = tablename;
        let builder = "DELETE FROM ";
        builder = builder.concat(quotedTablename);
        if (columns != null && columns.length > 0) {
            builder = builder.concat(" WHERE ");
            builder = this.appendColumnsEqValue(builder, quotedTablename, columns);
        }
        return builder.toString();
    }

    public static createSqlUpdate(tablename: string, updateColumns: string[], whereColumns: string[]): string {
        let quotedTablename = tablename;
        let builder = "UPDATE ";
        builder = builder.concat(quotedTablename).concat(" SET ");
        builder = this.appendColumnsEqualPlaceholders(builder, updateColumns);
        builder = builder.concat(" WHERE ");
        builder = this.appendColumnsEqValue(builder, quotedTablename, whereColumns);
        return builder.toString();
    }

    public static createSqlCount(tablename: string): string  {
        return "SELECT COUNT(*) FROM " + tablename + ' ';
    }

    public static escapeBlobArgument(bytes: Uint8Array): string  {
        return "X'" + this.toHex(bytes) + "'";
    }

    public static toHex(bytes: Uint8Array): string {
        let hexChars = [];
        for (let i = 0; i < bytes.length; i++) {
            let byteValue = bytes[i].valueOf() & 0xFF;
            hexChars[i * 2] = this.HEX_ARRAY[byteValue >>> 4];
            hexChars[i * 2 + 1] = this.HEX_ARRAY[byteValue & 0x0F];
        }
        return hexChars.join('');
    }
}
