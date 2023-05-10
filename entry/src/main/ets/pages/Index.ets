import { VideoHistoryTable } from '../db/impl/VideoHistoryDao';
import { SearchHistoryTable } from '../db/impl/SearchHistoryDao';
import SQLite from '../db/SQLite';
import { VideoHistoryInfo } from '../entity/VideoHistoryInfo';
import DataSource from '../api/DataSource';
import BimiDataSource from '../api/impl/BimiAcgDataSource';
import HttpUtils from '../utils/HttpUtils';
import { VideoList } from '../components/VideoList';
import { CssSelector } from '../utils/CssSelector';
import Logger from '../utils/Logger';
import http from '@ohos.net.http';
import VideoInfo from '../entity/VideoInfo';
import { parseDocument } from 'htmlparser2'
import * as DomUtils from 'domutils'
import { Element, Document, AnyNode } from "domhandler"
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World11111111'
  @State isLoading: boolean = false
  @State videoList: VideoInfo[] = []
  private hasMore: boolean
  private isError: boolean
  private currentPage: number = 1

  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiDataSource()

  aboutToAppear() {
    this.isLoading = true
    this.loadNextPage()

    let info = new VideoHistoryInfo()
    info.link = '111111111'
    let type = typeof info
    Logger.e(this, 'type=' + JSON.stringify(type))
    Logger.e(this, 'getPrototypeOf=' + JSON.stringify(Object.getPrototypeOf(info)))
    Logger.e(this, 'keys=' + JSON.stringify(Object.keys(info)))
    Logger.e(this, 'ownKeys=' + JSON.stringify(Reflect.ownKeys(Object.getPrototypeOf(info))))
    Logger.e(this, 'getOwnPropertyNames=' + JSON.stringify(Object.getOwnPropertyNames(info)))
    Logger.e(this, 'getOwnPropertyNames=' + JSON.stringify(Object.getOwnPropertyNames(info)))



    SQLite.with(VideoHistoryTable)
      .insert(info)
      .then((result) => {
        Logger.e(this, 'insert result=' + result)

        SQLite.with(VideoHistoryTable)
          .queryAll()
          .then((results) => {
            Logger.e(this, 'queryAll size=' + results.length)
            for (let item of results) {
              Logger.e(this, 'queryAll item=' + JSON.stringify(item))
            }
          })
          .catch((e) => {
            Logger.e(this, 'queryAll e=' + JSON.stringify(e))
          })
      })
      .catch((e) => {
        Logger.e(this, 'insert e=' + JSON.stringify(e))
      })

    SQLite.with(SearchHistoryTable)
      .insert({id: 0, keyword: 'Test', accessTime: new Date().getTime()})
      .then((result) => {
        Logger.e(this, 'SearchHistoryTable insert result=' + result)
      })
      .catch((e) => {
        Logger.e(this, 'SearchHistoryTable insert e=' + (typeof e))
      })


    Logger.e(this, 'link=' + info['link'])

    for (let key of Object.keys(info)) {
      Logger.e(this, 'key=' + key)
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        // 加载中
        LoadingProgress().width(64).height(64).layoutWeight(1)
      } else if (this.isError) {
        // 出错了或者什么都没有
        Text(this.message).fontSize(18).padding(20).fontWeight(FontWeight.Bold).layoutWeight(1)
      } else {
        VideoList({ videoList: this.videoList }).height('100%').padding(16)
      }
    }
    .width('100%')
    .height('100%')
  }

  private loadNextPage() {
    this.isError = false

    this.dataSource.getVideoList(this.currentPage)
      .then((list) => {
        this.currentPage++
        this.videoList = list
        this.isLoading = false
      })
      .catch((e) => {
        promptAction.showToast({ message: JSON.stringify(e) })
        this.isError = true
        this.message = JSON.stringify(e)
        this.isLoading = false
      })


//    let url = "http://www.bimiacg4.net/type/riman-" + page
//
//    let httpRequest = http.createHttp()
//    httpRequest.request(url, {
//      method: http.RequestMethod.GET,
//      readTimeout: 20000,
//      connectTimeout: 20000,
//      expectDataType: http.HttpDataType.STRING,
//      header: {
//        'user-agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36 Edg/94.0.992.50"
//      }
//    }, (err, data) => {
//      // todo 代码优化
//      Logger.e(this, 'loadData err=' + JSON.stringify(err) + ' data=' + JSON.stringify(data))
//      this.parseHtml(data.result as string)
//        .then((list) => {
//          this.videoList = list
//          this.isLoading = false
//        })
//        .catch((e) => {
//          promptAction.showToast({ message: JSON.stringify(e) })
//          this.isError = true
//          this.message = JSON.stringify(e)
//          this.isLoading = false
//        })
//    })
  }

  private async parseHtml(html: string): Promise<VideoInfo[]> {
    let doc: Document = parseDocument(html)
    let drama = CssSelector.findFirst(doc, 'ul.drama-module')
    Logger.e(this, 'parseHtml drama=' + drama)
    let elements = CssSelector.find(drama, 'li')
    Logger.e(this, 'parseHtml elements=' + elements)
    let videoList: VideoInfo[] = []

    // TODO 代码优化
    elements.forEach((el) => {
      Logger.e(this, "parseHtml el=" + el)
      let img = CssSelector.findFirst(el, 'img')
      let a = CssSelector.findFirst(el, "div.info > a")
      videoList.push({
        url: "http://www.bimiacg4.net" + DomUtils.getAttributeValue(a as Element, 'href'),
        imgUrl: DomUtils.getAttributeValue(img as Element, 'src'),
        title: DomUtils.textContent(a),
        episode: DomUtils.textContent(CssSelector.findFirst(el, "div.info > p > span.fl"))
      })
    })
    return videoList
  }

}