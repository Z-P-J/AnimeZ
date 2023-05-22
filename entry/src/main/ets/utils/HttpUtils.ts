import Logger from './Logger';
import http from '@ohos.net.http';
import { Document } from "domhandler"
import { parseDocument } from 'htmlparser2'

const USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36 Edg/94.0.992.50'

export default class HttpUtils {


    static async getHtml(url: string): Promise<Document> {
//        let httpRequest = http.createHttp()
//        let resp: http.HttpResponse = await httpRequest.request(url, {
//            method: http.RequestMethod.GET,
//            readTimeout: 20000,
//            connectTimeout: 20000,
//            expectDataType: http.HttpDataType.STRING,
//            header: {
//                'user-agent': USER_AGENT
//            }
//        })
//        if (resp.result) {
//            return parseDocument(resp.result as string)
//        } else {
//            throw new Error(JSON.stringify(resp))
//        }
        let str = await this.getString(url)
        if (str) {
            return parseDocument(str)
        } else {
            throw new Error("content is empty!")
        }
    }

    static async getString(url: string): Promise<string> {
        let httpRequest = http.createHttp()
        let resp: http.HttpResponse = await httpRequest.request(url, {
            method: http.RequestMethod.GET,
            readTimeout: 20000,
            connectTimeout: 20000,
            expectDataType: http.HttpDataType.STRING,
            header: {
                'user-agent': USER_AGENT
            }
        })
        if (resp.result) {
            return resp.result as string
        } else {
            throw new Error(JSON.stringify(resp))
        }
    }

}