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
  @State showPanel: boolean = false
  @State ty: number | string = '-100%'
  @State panelOpacity: number = 0
  private url: string
  @State collectionInfo: VideoCollectionInfo = null
  @State downloadState: number = DownloadState.NONE

  aboutToAppear() {
    this.url = 'http://www.bimiacg4.net/bangumi/bi/8552/'
    this.getDetailInfo()
  }

  build() {
    Stack() {
      Column() {
        if (this.videoDetailInfo) {
          Scroll() {
            Column({ space: 16 }) {
              this.VideoDetail()
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
        }
      }
      .width('100%')
      .height('100%')

      //      Panel(this.showPanel) { // 展示日程
      //        Column() {
      //          Text('Today Calendar')
      //          Divider()
      //          Text('1. afternoon 4:00 The project meeting')
      //        }
      //      }
      //      .type(PanelType.Minibar)
      //      .mode(PanelMode.Full)
      //      .miniHeight(0)
      //      .backgroundMask('#80000000')
      //      .backgroundColor(Color.White)
      //      .dragBar(true) // 默认开启
      ////      .halfHeight(500) // 默认一半
      //      .onHeightChange((value) => {
      //        Logger.e(this, 'onHeightChange value=' + value)
      //      })
      //      .onChange((width: number, height: number, mode: PanelMode) => {
      //        Logger.e(this, `width:${width},height:${height},mode:${mode}`)
      //        if (mode == PanelMode.Mini) {
      ////          this.showPanel = false
      //        }
      //      })

      CustomPanel({ showPanel: $showPanel, content: () => {
        this.VideoDetail()
      } })

      //      if (this.showPanel) {
      //        Stack() {
      //          Column() {
      //            this.VideoDetail()
      //          }
      //          .animation({
      //            duration: 500,
      //            curve: Curve.Friction,
      //            iterations: 1,
      //            playMode: PlayMode.Normal
      //          })
      //          .backgroundColor(Color.Gray)
      //          .translate({y: this.ty})
      //          .width('100%')
      //          .height('100%')
      //        }
      //        .backgroundColor('#80000000')
      //        .opacity(this.panelOpacity)
      //        .animation({
      //          duration: 500,
      //          curve: Curve.Friction,
      //          iterations: 1,
      //          playMode: PlayMode.Normal,
      //          onFinish: () => {
      //            if (this.ty != 0) {
      //              this.showPanel = false
      //            }
      //          }
      //        })
      //        .width('100%')
      //        .height('100%')
      //        .onAppear(() => {
      //          this.panelOpacity = 1
      //          this.ty = 0
      //        })
      //        .onClick(() => {
      //          this.ty = '-100%'
      //          this.panelOpacity = 0
      //        })
      //      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder VideoDetail() {
    Row() {
      Image(this.videoDetailInfo.coverUrl)
        .objectFit(ImageFit.Cover)
        .margin({ right: 16 })
        .borderRadius(8)
        .borderWidth(1)
        .borderColor('#cccccc')
        .width('33%')
        .aspectRatio(0.7)
        .onClick(() => {
          this.showPanel = true
        })
      Column({ space: 8 }) {
        Row() {
          Text(this.videoDetailInfo.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .align(Alignment.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text("收藏")
            .fontSize(12)
            .padding({ top: 8, bottom: 8, left: 16, right: 16 })
            .borderRadius(4)
            .margin({ left: 8 })
            .backgroundColor($r('app.color.primary_color'))
            .textAlign(TextAlign.Center)
            .fontColor(Color.White)
        }

        if (this.videoDetailInfo.updateTime) {
          Text(this.videoDetailInfo.updateTime).fontSize(12)
        }
        if (this.videoDetailInfo.director) {
          Text(this.videoDetailInfo.director).fontSize(12)
        }
        if (this.videoDetailInfo.category) {
          Text(`分类：${this.videoDetailInfo.category}`).fontSize(12)
        }
        if (this.videoDetailInfo.protagonist) {
          Text(this.videoDetailInfo.protagonist).fontSize(12)
        }

        if (this.videoDetailInfo.desc) {
          Text(this.videoDetailInfo.desc).fontSize(12)
            .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .padding(16)
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder ButtonGroup() {
    Row() {
      //      if (this.collectionInfo) {
      //        this.IconWithText($r('app.media.ic_collection'), "已收藏", () => {
      //          this.removeCollect()
      //        })
      //      } else {
      //        this.IconWithText($r('app.media.ic_collection'), "收藏", () => {
      //          this.collect()
      //        })
      //      }
      this.IconWithText(
        this.collectionInfo ? $r('app.media.ic_collected2') : $r('app.media.ic_collection'),
        this.collectionInfo ? '已收藏' : "收藏",
        () => {
          if (this.collectionInfo) {
            this.removeCollect()
          } else {
            this.collect()
          }
        }
      )
      this.IconWithText(
      $r('app.media.ic_download2'),
          this.downloadState == DownloadState.NONE ? "缓存" : (this.downloadState == DownloadState.DOWNLOADING ? '缓存中' : '已缓存'),
        () => {
          this.downloadState = DownloadState.DOWNLOADING
        }
      )
      this.IconWithText($r('app.media.ic_share'), "分享", () => {
        Logger.e(this, 'videoDetailInfo=' + JSON.stringify(this.videoDetailInfo))
        let sourceController = new CustomDialogController({
          builder: ShareDialog({detailInfo: this.videoDetailInfo}),
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
        .width(24)
        .height(24)
      Text(text)
        .fontSize(12)
        .fontWeight(300)
        .width(40)
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
    }
    .backgroundColor($r('app.color.background_color_accent'))
    .padding({ left: 20, top: 16, right: 20, bottom: 16 })
    .borderRadius(16)
    .onClick(onClick)
  }

  @Builder EpisodeList() {
    ForEach(this.videoDetailInfo.episodes, (episodeList: EpisodeList, episodeListIndex: number) => {
      Column() {
        //        Text(episodeList.title).fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
        this.Header(episodeList.title)
        Flex({ alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
          ForEach(episodeList.episodes, (item: EpisodeInfo, episodeIndex: number) => {
            Text(item.title)
              .textAlign(TextAlign.Center)
              .backgroundColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? $r('app.color.primary_color') : '#f5f5f5')
              .fontColor(
                  (this.episodeListIndex == episodeListIndex && this.episodeIndex == episodeIndex)
                  ? Color.White : $r('app.color.color_text_major'))
              .fontSize(12)
              .padding({ top: 8, bottom: 8 })
              .borderRadius(4)
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
      //      Text("猜你喜欢").fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
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