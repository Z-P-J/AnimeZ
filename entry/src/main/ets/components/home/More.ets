import DataSourceManager from '../../api/DataSourceManager';
import Logger from '../../utils/Logger';
import promptAction from '@ohos.promptAction';
import VideoInfo from '../../entity/VideoInfo';
import StateView, { ViewState } from '../StateView';
import { VideoList } from '../VideoList';

@Component
export struct More {

  @State videoList: VideoInfo[] = []
  private hasMore: boolean
  private currentPage: number = 1
  @State state: number = ViewState.CONTENT
  @State errorMessage: string = ''

  aboutToAppear() {
    this.loadNextPage()
  }

  build() {
    StateView(
      {
        state: $state,
        errorMessage: $errorMessage,
        content: () => {
          this.RecommendVideoList()
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

  @Builder RecommendVideoList() {
    VideoList({ videoList: this.videoList }).padding(16)
  }

  private loadNextPage() {
    this.state = ViewState.LOADING
    // TODO 根据key获取数据源
    DataSourceManager.getCurrentSource()
      .getVideoList(this.currentPage)
      .then((list) => {
        this.currentPage++
        this.videoList = list
        this.state = ViewState.CONTENT
        Logger.e(this, 'loadNextPage list=' + JSON.stringify(list))
      })
      .catch((e) => {
        this.errorMessage = JSON.stringify(e)
        this.state = ViewState.ERROR
      })
  }

}