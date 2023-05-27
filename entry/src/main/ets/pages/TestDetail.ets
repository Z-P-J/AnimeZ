import { PanelController } from '../components/CustomPanel';
import ImmersionBarSpace from '../components/ImmersionBarSpace';
import router from '@ohos.router';
import { ShareDialog } from '../components/dialog/ShareDialog';
import { getTheme } from '../utils/Themes';
import { VideoCollectionTable } from '../db/impl/VideoCollectionDao';
import SQLite from '../db/SQLite';
import VideoCollectionInfo from '../entity/VideoCollectionInfo';
import CustomPanel from '../components/CustomPanel';
import Logger from '../utils/Logger';
import { VideoList } from '../components/VideoList';
import DataSource from '../api/DataSource';
import BimiAcgDataSource from '../api/impl/BimiAcgDataSource';
import EpisodeInfo from '../entity/EpisodeInfo';
import EpisodeList from '../entity/EpisodeList';
import VideoDetailInfo from '../entity/VideoDetailInfo';

enum DownloadState {
  NONE = 0,
  DOWNLOADING = 1,
  COMPLETE = 2
}

@Entry
@Component
struct TestDetail {
  @StorageLink('theme') theme: number = 0
  @State message: string = 'Hello World'
  @State videoDetailInfo: VideoDetailInfo = null
  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiAcgDataSource()
  @State episodeListIndex: number = 0;
  @State episodeIndex: number = 0;
  private url: string
  @State collectionInfo: VideoCollectionInfo = null
  @State panelContentType: number = 0
  @State isBackgroundLoaded: boolean = false

  private readonly panelController: PanelController = new PanelController()

  aboutToAppear() {
    this.url = 'http://www.bimiacg4.net/bangumi/bi/8552/'
    this.getDetailInfo()
  }

  onBackPress() {
    if (this.panelController.isShow()) {
      this.panelController.close()
      return true;
    }
    return false
  }

  build() {
    Stack() {
      if (this.videoDetailInfo) {
        Image(this.videoDetailInfo.coverUrl)
          .objectFit(ImageFit.Cover)
          .height('100%')
          .width('100%')
          .onComplete(() => {
            // TODO 背景加载完成
            this.isBackgroundLoaded = true;
          })
          .blur(16)
      }


//      Stack()
//        .height(42)
//        .width('100%')
//        .linearGradient({
//          angle: 180,
//          colors: [['#00000000', 0.0], ['#99000000', 0.5], ['#ff000000', 1.0]]
//        })

      this.RootContent()
      if (this.videoDetailInfo) {
        CustomPanel(
          {
            controller: this.panelController,
            panelContent: () => {
              this.SecondaryContent()
            }
          }
        )
          .hitTestBehavior(HitTestMode.None)
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder RootContent() {
    Column() {
      if (this.videoDetailInfo) {
        Scroll() {
          Column({ space: 16 }) {
            Row() {
              Column() {
                Text(this.videoDetailInfo.title)
                  .alignSelf(ItemAlign.Start)
                  .fontColor(getTheme(this.theme).color_text_major)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(18)
                Column() {
                  if (this.videoDetailInfo.updateTime) {
                    Text(this.videoDetailInfo.updateTime).fontSize(12)
                  }
                  if (this.videoDetailInfo.category) {
                    Text(`分类：${this.videoDetailInfo.category}`).fontSize(12)
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .height('100%')
              .margin(8)
              .justifyContent(FlexAlign.SpaceBetween)

              Blank()

              Image(this.videoDetailInfo.coverUrl)
                .alt($r('app.media.pic_load_failed'))
                .objectFit(ImageFit.Cover)
                .height('100%')
                .aspectRatio(1.4)
                .borderRadius(6)
                .borderColor('#cccccc')
                .onClick(() => {
                  this.panelContentType = 0
                  this.panelController.show()
                })
            }
            .width('100%')
            .height(100)
            .padding(16)

            this.ButtonGroup()
            this.EpisodeList()
            this.GuessYouLike()
            Text("没有更多了").fontSize(14)
              .textAlign(TextAlign.Center)
              .margin({ top: 16, bottom: 32 })
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .constraintSize({
            minHeight: '100%'
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .height('100%')
      }
    }
    .backgroundColor('#80ffffff')
    .width('100%')
    .height('100%')
  }

  @Builder SecondaryContent() {
    Column() {
      Row() {
        Text(this.panelContentType == 0 ? '详情' : '缓存')
          .fontColor(getTheme(this.theme).color_text_major)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()
        Image($r('app.media.ic_close'))
          .width(24).height(24)
          .onClick(() => {
            this.panelController.close()
          })
      }
      .padding({ left: 16, top: 16, right: 16, bottom: 8 })
      .width('100%')

      if (this.panelContentType == 0) {
        Scroll() {
          Column() {
            //            if (this.panelContentType == 0) {
            //              this.VideoDetail()
            //            } else {
            //              this.DownloadPage()
            //            }
            this.VideoDetail()
          }
          .alignItems(HorizontalAlign.Start)
          .constraintSize({
            minHeight: '100%'
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
      } else {
        this.DownloadPage()
      }
    }
    .backgroundColor(getTheme(this.theme).background_color)
    .width('100%')
    .height('100%')
  }

  /**
   * 下载页
   */
  @Builder DownloadPage() {
    Column() {
      Row() {
        Scroll() {
          Column() {
            ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
              Column() {
                // TODO 展开和折叠、单个下载列表缓存全部
//                this.Header(episodeList.title)
                Row() {
                  Row()
                    .height(14)
                    .width(6)
                    .margin({ right: 2 })
                    .borderRadius(4)
                    .backgroundColor(getTheme(this.theme).primary_color)
                  Text(episodeList.title)
                    .fontColor(getTheme(this.theme).color_text_major)
                    .fontSize(16)
                  Blank()
                  Text('缓存全部')
                    .fontSize(12)
                    .padding(8)
                    .borderRadius(6)
                    .onClick(() => {
                      // TODO
                    })
                }
                .padding({ left: 16, top: 16, right: 16, bottom: 8 })
                .width('100%')
                Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
                  ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
                    Text(item.title)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(
                          (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                          ? '#bb3366ff' : '#aaf5f5f5')
                      .fontColor(
                          (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                          ? Color.White : $r('app.color.color_text_major'))
                      .fontSize(12)
                      .padding({top: 12, bottom: 12})
                      .borderRadius(6)
                      .margin({ bottom: 8, right: (episodeIndex + 1) % 4 == 0 ? 0 : '4%' })
                      .width('22%')
                      .maxLines(1)
                  })
                }
                .margin({ top: 8 })
                .padding({ left: 16, right: 16 })
              }
              .alignItems(HorizontalAlign.Start)
            })
          }
          .alignItems(HorizontalAlign.Start)
          .constraintSize({
            minHeight: '100%'
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        Text("缓存全部")
          .height('100%')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor(getTheme(this.theme).color_text_normal)
          .onClick(() => {
          })
        Stack()
          .size({ width: 1.5, height: '30%' })
          .backgroundColor("#80cccccc")
        Text("下载列表")
          .textAlign(TextAlign.Center)
          .fontSize(14)
          .fontColor("#317ef5")
          .height('100%')
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DownloadManagerPage' })
          })
          .height(46)
          .width('100%')
      }
      .height(46)
      .width('100%')

      ImmersionBarSpace()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder VideoDetail() {
    Column() {
      Row() {
        Image(this.videoDetailInfo.coverUrl)
          .alt($r('app.media.pic_load_failed'))
          .objectFit(ImageFit.Cover)
          .height('100%')
          .aspectRatio(0.7)
          .borderRadius(8)
          .borderColor('#cccccc')
          .onClick(() => {
            this.panelController.show()
          })
        Column() {
          Text(this.videoDetailInfo.title)
            .alignSelf(ItemAlign.Start)
            .fontColor(getTheme(this.theme).color_text_major)
            .fontSize(16)
          Column() {
            if (this.videoDetailInfo.updateTime) {
              Text(this.videoDetailInfo.updateTime).fontSize(12)
            }
            if (this.videoDetailInfo.category) {
              Text(`分类：${this.videoDetailInfo.category}`).fontSize(12)
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .height('100%')
        .margin(8)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(160)
      .padding(16)
      if (this.videoDetailInfo.desc) {
        this.Header('简介')
        Text(this.videoDetailInfo.desc).fontSize(12).padding(16)
      }
      if (this.videoDetailInfo.protagonist) {
        this.Header('角色声优')
        Text(this.videoDetailInfo.protagonist).fontSize(12).padding(16)
      }
      if (this.videoDetailInfo.director) {
        this.Header('制作信息')
        Text(this.videoDetailInfo.director).fontSize(12).padding(16)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  @Builder ButtonGroup() {
    Row() {
      if (this.collectionInfo) {
        this.IconWithText($r('app.media.ic_collected2'), "已收藏", () => {
          this.removeCollect()
        })
      } else {
        this.IconWithText($r('app.media.ic_collection'), "收藏", () => {
          this.collect()
        })
      }
      this.IconWithText(
      $r('app.media.ic_download2'),
        '缓存',
        () => {
          this.panelContentType = 1
          this.panelController.show()
        }
      )
      this.IconWithText($r('app.media.ic_share'), "分享", () => {
        Logger.e(this, 'videoDetailInfo=' + JSON.stringify(this.videoDetailInfo))
        let sourceController = new CustomDialogController({
          builder: ShareDialog(
            {
              detailInfo: this.videoDetailInfo,
              onClose: () => {
                sourceController.close()
              }
            }
          ),
          cancel: () => {
            console.log("cancel")
          },
          alignment: DialogAlignment.Bottom,
          autoCancel: true,
          customStyle: true
        })
        sourceController.open()
      })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder IconWithText(src: string | PixelMap | Resource, text: string | Resource, onClick?: (event?: ClickEvent) => void) {
    Column() {
      Image(src)
        .width(20)
        .height(20)
      Text(text)
        .fontSize(10)
        .width(40)
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
    }
    .backgroundColor(
      this.isBackgroundLoaded ? '#aaffffff' : getTheme(this.theme).background_color_accent
    )
    .padding({ left: 20, top: 8, right: 20, bottom: 8 })
    .borderRadius(12)
    .borderWidth(1.5)
    .borderColor(getTheme(this.theme).background_color_accent)
    .onClick(onClick)
  }

  @Builder EpisodeList() {
    ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
      Column() {
        this.Header(episodeList.title)
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
          ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
            Text(item.title)
              .textAlign(TextAlign.Center)
              .backgroundColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? '#bb3366ff' : '#aaf5f5f5')
              .fontColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? Color.White : $r('app.color.color_text_major'))
              .fontSize(12)
              .padding({ top: 8, bottom: 8 })
              .borderRadius(6)
              .borderWidth(1.5)
              .borderColor(getTheme(this.theme).background_color_accent)
              .margin({ bottom: 8, right: '2%' })
              .width('18%')
              .maxLines(1)
          })
        }
        .margin({ top: 8 })
        .padding({ left: 16, right: 16 })
      }
      .alignItems(HorizontalAlign.Start)
    })
  }

  @Builder GuessYouLike() {
    Column() {
      this.Header('猜你喜欢')
      VideoList({ videoList: this.videoDetailInfo.recommends, scrollable: false })
        .padding({ left: 16, right: 16 })
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder Header(title: string) {
    Row() {
      Row()
        .height(14)
        .width(6)
        .margin({ right: 2 })
        .borderRadius(4)
        .backgroundColor(getTheme(this.theme).primary_color)
      Text(title)
        .fontColor(getTheme(this.theme).color_text_major)
        .fontSize(16)
        .fontWeight(500)
    }
    .padding({ left: 16, top: 16, right: 16, bottom: 8 })
    .width('100%')
  }

  private getDetailInfo() {
    this.dataSource.getVideoDetailInfo(this.url)
      .then(async (info) => {
        Logger.e(this, 'videoDetailInfo=' + JSON.stringify(info))

        this.videoDetailInfo = info
      })
      .catch((e) => {

      })
  }

  private removeCollect() {
    this.collectionInfo = null

    //    SQLite.with(VideoCollectionTable)
    //      .delete(this.collectionInfo)
    //      .then((result) => {
    //        Logger.e(this, 'delete collection info success! result=' + result)
    //        this.collectionInfo = null
    //      })
    //      .catch((e) => {
    //        Logger.e(this, 'delete collection info failed! e=' + JSON.stringify(e))
    //      })
  }

  private collect() {

    this.collectionInfo = {
      src: this.url,
      title: this.videoDetailInfo.title,
      coverUrl: this.videoDetailInfo.coverUrl,
      accessTime: new Date().getTime()
    }

    //    let collectionInfo = {
    //      src: this.url,
    //      title: this.videoDetailInfo.title,
    //      coverUrl: this.videoDetailInfo.coverUrl,
    //      accessTime: new Date().getTime()
    //    }
    //    SQLite.with(VideoCollectionTable)
    //      .insert(collectionInfo)
    //      .then((result) => {
    //        Logger.e(this, 'insert collection info success! result=' + result)
    //        this.collectionInfo = collectionInfo
    //      })
    //      .catch((e) => {
    //        Logger.e(this, 'insert collection info failed! e=' + JSON.stringify(e))
    //      })
  }
}