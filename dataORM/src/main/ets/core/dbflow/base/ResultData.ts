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

export class ResultData {
    private resultSet: any

    constructor(resultSet: any) {
        this.resultSet = resultSet;

    }

    public columnNames(): string{
        return this.resultSet.columnNames;
    }

    public columnCount(): number{

        return this.resultSet.columnCount
    }

    public getColumnIndex(columnName: string): number{
        return this.resultSet.getColumnIndex(columnName);
    }

    public getColumnName(columnIndex: number): string{
        return this.resultSet.getColumnName(columnIndex);
    }

    public goTo(offset: number): boolean{
        return this.resultSet.goTo(offset);
    }

    public goToRow(position: number): boolean{
        return this.resultSet.goToRow(position);

    }

    public goToFirstRow(): boolean{
        return this.resultSet.goToFirstRow();
    }

    public goToLastRow(): boolean{
        return this.resultSet.goToLastRow();

    }

    public goToNextRow(): boolean{
        return this.resultSet.goToNextRow()
    }

    public goToPreviousRow(): boolean{
        return this.resultSet.goToPreviousRow()
    }

    public getBlob(columnIndex: number): Uint8Array{
        return this.resultSet.getBlob(columnIndex)

    }

    public getString(columnIndex: number): string{
        return this.resultSet.getString(columnIndex)

    }

    public getLong(columnIndex: number): number{
        return this.resultSet.getLong(columnIndex)
    }

    public getDouble(columnIndex: number): number{
        return this.resultSet.getDouble(columnIndex)
    }

    public isColumnNull(columnIndex: number): boolean{
        return this.resultSet.isColumnNull(columnIndex)

    }

    public close(): void{
        return this.resultSet.close();
        this.resultSet = null

    }
}