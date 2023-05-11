import router from '@ohos.router';
import DataSource from '../api/DataSource';
import { ViewState } from '../components/StateView';
import { VideoList } from '../components/VideoList';
import VideoInfo from '../entity/VideoInfo';
import StateView from '../components/StateView';
import BimiAcgDataSource from '../api/impl/BimiAcgDataSource';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SearchPage {
  @State message: string = 'Hello World'
  @State videoList: VideoInfo[] = []
  @State state: number = ViewState.LOADING
  private keyword: string = ''
  @StorageLink('data_source_bimiacg') dataSource: DataSource = new BimiAcgDataSource()

  aboutToAppear() {


  }

  onBackPress() {
    promptAction.showToast({message: 'onBackPress'})
  }

  build() {
    Column() {

      this.SearchBar()

      StateView(
        {
          state: $state,
          content: () => {
            this.content()
          },
          custom: null
        }
      )
        .width('100%')
        .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
  }

  @Builder content() {
    //    Text(this.message)
    //      .fontSize(50)
    //      .fontWeight(FontWeight.Bold)

    VideoList({ videoList: this.videoList }).height('100%').padding(16)
  }

  @Builder SearchBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .margin({ left: 18 })
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          router.back()
        })
      TextInput({ placeholder: "Plach" })
        .placeholderFont({
          size: 14,
          weight: 300
        })
        .onChange((value) => {
          this.keyword = value
        })
        .onSubmit(() => {
          if (this.keyword.length !== 0) {
            this.doSearch(this.keyword)
          }
        })
        .height(36)
        .margin({ left: 12, right: 12 })
        .backgroundColor('#f5f5f5')
        .layoutWeight(1)
      Blank()

      Text('搜索').fontSize(18).margin({ right: 16 })
    }
    //      .borderWidth(2)
    .height(56)
    .width('100%')
  }

  private doSearch(keyword: string) {
    promptAction.showToast({ message: keyword })

    this.state = ViewState.LOADING
    this.dataSource.search(keyword, 1).then((videoList) => {
      this.videoList = videoList
      if (this.videoList.length == 0) {
        this.state = ViewState.EMPTY
      } else {
        this.state = ViewState.CONTENT
      }
    })
  }
}