import { getTheme } from '../../utils/Themes';
import { DramaList } from '../../entity/HomepageData';
import HomepageData from '../../entity/HomepageData';
import router from '@ohos.router';
import Logger from '../../utils/Logger';
import promptAction from '@ohos.promptAction';
import VideoInfo from '../../entity/VideoInfo';
import StateView, { ViewState } from '../StateView';
import BimiAcgDataSource from '../../api/impl/BimiAcgDataSource';
import DataSource from '../../api/DataSource';
import { VideoList } from '../VideoList';

/**
 * 首页推荐
 */
@Component
export struct Recommend {
  @StorageLink('theme') theme: number = 0
  @State bannerList: VideoInfo[] = []
  @State categoryList: DramaList[] = []
  @State state: number = ViewState.LOADING
  @State errorMessage: string = ''

  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiAcgDataSource()

  aboutToAppear() {
    this.loadNextPage()
  }

  build() {
    StateView(
      {
        state: $state,
        errorMessage: $errorMessage,
        content: () => {
          this.Content()
        },
        custom: null,
        onRetry: () => {
          this.loadNextPage()
          return true;
        }
      }
    )
      .width('100%')
      .layoutWeight(1)
  }

  @Builder Content() {
    Stack() {
      Scroll() {
        Column() {
          this.Banner()
          ForEach(this.categoryList, (category) => {
            this.Category(category)
          })
        }
        .constraintSize({
          minHeight: '100%'
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }

  @Builder Banner() {
    Swiper() {
      ForEach(this.bannerList, (item) => {
        this.BannerItem(item)
      })
    }
    .width('100%')
    .aspectRatio(2)
    .autoPlay(true)
    .interval(5000)
    .loop(true)
    .indicator(false)
//    .indicatorStyle({
//      color: Color.White,
//      selectedColor: $r('app.color.primary_color_accent')
//    })
  }

  @Builder BannerItem(item: VideoInfo) {
    Stack({alignContent: Alignment.BottomStart}) {
      Image(item.imgUrl)
        .alt($r('app.media.pic_load_failed'))
        .objectFit(ImageFit.Cover)
        .borderWidth(2)
        .borderColor(getTheme(this.theme).background_color_dark)
        .brightness(0.7)
        .borderRadius(12)

      Text(item.title)
        .fontColor(Color.White)
        .fontSize(16)
        .padding(12)
        .maxLines(1)
        .textOverflow({overflow: TextOverflow.Ellipsis})
        .alignSelf(ItemAlign.Start)
    }
//    .width('80%')
//    .translate({x: '-50%'})
    .padding(12)
  }

  @Builder Category(category: DramaList) {
    Column() {
      this.Bar(category.title, category.moreUrl)
      VideoList({ videoList: category.videoList, scrollable: false }).padding(16)
    }
  }

  @Builder Bar(title: string, more: string) {
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

      Blank()

      // TODO 打开更多
//      Text('更多')
//        .fontColor($r('app.color.color_text_major'))
//        .fontSize(12)
//      Image($r("app.media.ic_enter"))
//        .width(24)
//        .height(24)
//        .fillColor('#817977')
//        .alignSelf(ItemAlign.End)
//        .objectFit(ImageFit.Contain)
    }
    .alignSelf(ItemAlign.Start)
    .width('100%')
    .padding({ left: 16, top: 16, right: 16, bottom: 0 })
//    .onClick(() => {
//      router
//    })
  }

  private loadNextPage() {
    this.state = ViewState.LOADING
    this.dataSource.getHomepageData()
      .then((data) => {
        Logger.e(this, 'loadNextPage list=' + JSON.stringify(data))
        this.bannerList = data.bannerList
        this.categoryList = data.categoryList
        Logger.e(this, 'categoryList=' + JSON.stringify(data.categoryList))
        this.state = ViewState.CONTENT
      })
      .catch((e) => {
        this.errorMessage = JSON.stringify(e)
        this.state = ViewState.ERROR
      })
  }

}